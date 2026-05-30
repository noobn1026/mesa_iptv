// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/channel_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../models/channel_model.dart';
import '../services/api_service.dart';
import '../widgets/tv/sidebar.dart';
import '../widgets/layout/info_bar.dart';
import '../widgets/layout/last_channel_pill.dart';
import '../utils/channel_helpers.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isLoadingStream = false;
  String? _streamError;
  bool _isFullscreen = false;
  bool _showSidebar = false;
  String? _previewChannelId;
  bool _showControls = true;
  String _sidebarView = 'categories';
  String? _selectedGenre;
  Timer? _controlsTimer;
  Timer? _previewTimer;
  Timer? _preloadTimer;
  bool _hasInteracted = false;
  late FocusNode _playerFocusNode;
  late FocusNode _sidebarFocusNode;
  StreamSubscription? _connectivitySubscription;
  bool _hasNetwork = true;
  Channel? _lastChannel;
  int _lastTapTime = 0;

  final Map<String, String> _streamUrlCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerFocusNode = FocusNode();
    _sidebarFocusNode = FocusNode();
    _initialize();
    _setupConnectivity();
    _checkSubscriptionStatus();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChannelsAndPlay();
    });
  }

  Future<void> _initialize() async {
    await WakelockPlus.enable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _setupConnectivity() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _hasNetwork = result != ConnectivityResult.none;
      });
      if (_hasNetwork && _controller == null && context.read<ChannelProvider>().currentChannel != null) {
        _playChannel(context.read<ChannelProvider>().currentChannel!);
      }
    });
  }

  Future<void> _checkSubscriptionStatus() async {
    final authProvider = context.read<AuthProvider>();
    final isExpired = await authProvider.checkAndLogoutIfExpired();
    if (isExpired && mounted) {
      _showExpiredDialog();
    }
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Subscription Expired', style: TextStyle(color: Colors.white)),
        content: const Text('Your subscription has expired. Please contact support to renew.', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.go('/login');
            },
            child: const Text('OK', style: TextStyle(color: Color(0xFFe50914))),
          ),
        ],
      ),
    );
  }

  Future<void> _loadChannelsAndPlay() async {
    final channelProvider = context.read<ChannelProvider>();
    
    await channelProvider.loadChannels();
    
    if (channelProvider.allChannels.isNotEmpty && _controller == null) {
      final firstChannel = channelProvider.allChannels.first;
      _playChannel(firstChannel);
    }
  }

  Future<String?> _getStreamUrl(Channel channel, {bool forceProxy = false}) async {
    final cacheKey = '${channel.uniqueId}_${forceProxy ? 'proxy' : 'direct'}';
    if (_streamUrlCache.containsKey(cacheKey)) {
      print('🎬 Using cached URL for: ${channel.name}');
      return _streamUrlCache[cacheKey];
    }

    final settingsProvider = context.read<SettingsProvider>();
    final mode = forceProxy ? 'proxy' : settingsProvider.playbackMode;
    
    try {
      String? url;
      if (mode == 'proxy' || settingsProvider.autoFallbackToProxy) {
        url = await ApiService.getStreamUrl(
          playlistId: channel.playlistId,
          channelId: channel.channelId ?? channel.id,
          cmd: channel.cmd,
          useProxy: true,
        );
      } else {
        url = await ApiService.getStreamUrl(
          playlistId: channel.playlistId,
          channelId: channel.channelId ?? channel.id,
          cmd: channel.cmd,
          useProxy: false,
        );
      }
      
      print('🎬 Got stream URL for ${channel.name}: $url');
      
      if (url != null) {
        _streamUrlCache[cacheKey] = url;
      }
      return url;
    } catch (e) {
      print('❌ Error getting stream URL: $e');
      return null;
    }
  }

  Future<void> _playChannel(Channel channel, {bool startFullscreen = false}) async {
    if (!_hasNetwork) {
      setState(() {
        _streamError = 'No internet connection';
      });
      return;
    }

    print('🎬 PLAYING CHANNEL: ${channel.name}');
    print('🎬 Channel ID: ${channel.channelId}');
    print('🎬 Playlist ID: ${channel.playlistId}');

    setState(() {
      _hasInteracted = true;
      _isLoadingStream = true;
      _streamError = null;
      _previewChannelId = null;
      if (_previewTimer != null) _previewTimer!.cancel();
    });

    final previousChannel = context.read<ChannelProvider>().currentChannel;
    context.read<ChannelProvider>().selectChannel(channel);
    
    if (previousChannel != null && previousChannel.uniqueId != channel.uniqueId) {
      _releaseStream(previousChannel);
    }

    try {
      String? streamUrl = await _getStreamUrl(channel);
      
      if (streamUrl == null && 
          context.read<SettingsProvider>().playbackMode == 'direct' &&
          context.read<SettingsProvider>().autoFallbackToProxy) {
        print('🎬 Direct failed, trying proxy fallback...');
        streamUrl = await _getStreamUrl(channel, forceProxy: true);
        if (streamUrl != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Switched to proxy mode'), backgroundColor: Colors.orange),
          );
        }
      }

      if (streamUrl == null) {
        print('❌ No stream URL available for: ${channel.name}');
        throw Exception('No stream URL available');
      }

      print('🎬 Initializing video player with URL: $streamUrl');

      await _controller?.dispose();
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        httpHeaders: {
          'User-Agent': 'VLC/3.0.18 LibVLC/3.0.18',
          'Accept': '*/*',
          'Accept-Encoding': 'identity',
          'Connection': 'keep-alive',
        },
      );
      
      await _controller!.initialize();
      print('🎬 Video player initialized successfully!');
      
      await _controller!.play();
      print('🎬 Video playing!');

      setState(() {
        _isLoadingStream = false;
        _lastChannel = previousChannel;
      });

      if (startFullscreen && !_isFullscreen) {
        _toggleFullscreen();
      }
    } catch (e) {
      print('❌ Error playing channel: $e');
      setState(() {
        _isLoadingStream = false;
        _streamError = e.toString();
      });
    }
  }

  Future<void> _releaseStream(Channel channel) async {
    _streamUrlCache.removeWhere((key, value) => key.contains(channel.uniqueId ?? ''));
  }

  void _preloadChannel(Channel channel) {
    if (_preloadTimer != null) _preloadTimer!.cancel();
    _preloadTimer = Timer(const Duration(milliseconds: 300), () async {
      final cacheKey = '${channel.uniqueId}_direct';
      if (!_streamUrlCache.containsKey(cacheKey)) {
        await _getStreamUrl(channel);
      }
    });
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
      if (_isFullscreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        _showSidebar = false;
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() => _showControls = true);
    if (_controlsTimer != null) _controlsTimer!.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _handleVideoTap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastTapTime != 0 && now - _lastTapTime < 300) {
      _lastTapTime = 0;
      _toggleFullscreen();
    } else {
      _lastTapTime = now;
      _showControlsTemporarily();
    }
  }

  void _handleBackNavigation() {
    if (_isFullscreen && _showSidebar) {
      setState(() => _showSidebar = false);
      _playerFocusNode.requestFocus();
    } else if (_isFullscreen) {
      _toggleFullscreen();
    } else if (_previewChannelId != null) {
      setState(() => _previewChannelId = null);
    } else if (_sidebarView == 'channels') {
      setState(() => _sidebarView = 'categories');
    } else {
      _showExitDialog();
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Exit App', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to exit?', style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Yes', style: TextStyle(color: Color(0xFFe50914))),
          ),
        ],
      ),
    );
  }

  void _handleGenrePress(String genre) {
    setState(() {
      _selectedGenre = genre;
      _sidebarView = 'channels';
    });
  }

  void _handleChannelSelect(Channel channel) {
    _playChannel(channel);
    if (_isFullscreen) {
      setState(() => _showSidebar = false);
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _previewTimer?.cancel();
    _preloadTimer?.cancel();
    _connectivitySubscription?.cancel();
    _playerFocusNode.dispose();
    _sidebarFocusNode.dispose();
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelProvider = context.watch<ChannelProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    
    if (channelProvider.isLoading && channelProvider.allChannels.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFe50914)),
              SizedBox(height: 16),
              Text('Loading channels...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
    
    final currentChannel = channelProvider.currentChannel;
    final sections = channelProvider.groupedChannels;
    final currentChannels = _selectedGenre != null && sections.isNotEmpty
        ? sections.firstWhere(
            (s) => s.title == _selectedGenre,
            orElse: () => Section(title: '', data: []),
          ).data
        : channelProvider.filteredChannels;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isFullscreen
          ? _buildFullscreenLayout(currentChannel, settingsProvider, channelProvider)
          : _buildSplitLayout(
              currentChannel,
              sections,
              _selectedGenre,
              currentChannels,
              channelProvider.lastChannel,
              settingsProvider,
              channelProvider,
            ),
    );
  }

  Widget _buildFullscreenLayout(Channel? currentChannel, SettingsProvider settingsProvider, ChannelProvider channelProvider) {
    final previewChannel = _previewChannelId != null
        ? channelProvider.allChannels.firstWhere(
            (ch) => ch.uniqueId == _previewChannelId,
            orElse: () => currentChannel!,
          )
        : null;

    return Stack(
      children: [
        Center(
          child: _controller != null && _controller!.value.isInitialized
              ? GestureDetector(
                  onTap: _handleVideoTap,
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : (_isLoadingStream
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFe50914)))
                  : _buildErrorWidget(currentChannel)),
        ),

        if (_showControls)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (currentChannel != null)
                    Text(currentChannel.name, style: const TextStyle(color: Colors.white, fontSize: 24)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white, size: 48),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(
                          _controller?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed: () {
                          if (_controller?.value.isPlaying == true) {
                            _controller?.pause();
                          } else {
                            _controller?.play();
                          }
                          _showControlsTemporarily();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 48),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  if (settingsProvider.forceSoftwareDecoder)
                    const Text('Software Decoder', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),

        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
            onPressed: _toggleFullscreen,
          ),
        ),

        if (currentChannel != null && !_showControls)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.black54,
              child: Text(currentChannel.name, style: const TextStyle(color: Colors.white)),
            ),
          ),

        if (previewChannel != null && !_showControls)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.black54,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.preview, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(previewChannel.name, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),

        if (_showSidebar)
          Container(
            color: Colors.black87,
            width: 380,
            child: Sidebar(
              sections: channelProvider.groupedChannels,
              selectedGenre: _selectedGenre,
              channels: channelProvider.filteredChannels,
              currentChannel: currentChannel,
              lastChannel: channelProvider.lastChannel,
              previewChannel: previewChannel,
              onGenrePress: _handleGenrePress,
              onChannelPress: _handleChannelSelect,
              onChannelFocus: _preloadChannel,
              onSettingsPress: () => context.push('/settings'),
              viewMode: _sidebarView,
              onBackToCategories: () => setState(() => _sidebarView = 'categories'),
            ),
          ),
      ],
    );
  }

  Widget _buildSplitLayout(
    Channel? currentChannel,
    List<Section> sections,
    String? selectedGenre,
    List<Channel> currentChannels,
    Channel? lastChannel,
    SettingsProvider settingsProvider,
    ChannelProvider channelProvider,
  ) {
    final previewChannel = _previewChannelId != null
        ? channelProvider.allChannels.firstWhere(
            (ch) => ch.uniqueId == _previewChannelId,
            orElse: () => currentChannel!,
          )
        : null;

    return Row(
      children: [
        SizedBox(
          width: 380,
          child: Sidebar(
            sections: sections,
            selectedGenre: selectedGenre,
            channels: currentChannels,
            currentChannel: currentChannel,
            lastChannel: lastChannel,
            previewChannel: previewChannel,
            onGenrePress: _handleGenrePress,
            onChannelPress: _handleChannelSelect,
            onChannelFocus: _preloadChannel,
            onSettingsPress: () => context.push('/settings'),
            viewMode: _sidebarView,
            onBackToCategories: () => setState(() => _sidebarView = 'categories'),
          ),
        ),

        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: _controller != null && _controller!.value.isInitialized
                      ? GestureDetector(
                          onTap: _handleVideoTap,
                          child: VideoPlayer(_controller!),
                        )
                      : (_isLoadingStream
                          ? const Center(child: CircularProgressIndicator(color: Color(0xFFe50914)))
                          : _buildErrorWidget(currentChannel)),
                ),
              ),

              InfoBar(
                currentChannel: currentChannel,
                lastChannel: lastChannel,
                onLastChannelPress: () => _playChannel(lastChannel!),
                playbackMode: settingsProvider.playbackMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(Channel? channel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_streamError ?? 'Unable to play stream', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _playChannel(channel!),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFe50914)),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}