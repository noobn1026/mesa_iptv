import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../utils/constants.dart';

class PlayerArea extends StatefulWidget {
  final VideoPlayerController? controller;
  final bool isLoading;
  final String? error;
  final String? channelName;
  final bool showControls;
  final VoidCallback onTap;
  final VoidCallback onRetry;
  final bool isFullscreen;
  final bool useSoftwareDecoder;

  const PlayerArea({
    super.key,
    this.controller,
    required this.isLoading,
    this.error,
    this.channelName,
    required this.showControls,
    required this.onTap,
    required this.onRetry,
    required this.isFullscreen,
    required this.useSoftwareDecoder,
  });

  @override
  State<PlayerArea> createState() => _PlayerAreaState();
}

class _PlayerAreaState extends State<PlayerArea> {
  bool _errorDismissed = false;

  @override
  void didUpdateWidget(PlayerArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != oldWidget.error) {
      _errorDismissed = false;
    }
  }

  bool get _showErrorBanner => widget.error != null && !_errorDismissed && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Video player
            if (widget.controller != null && widget.controller!.value.isInitialized)
              AspectRatio(
                aspectRatio: widget.controller!.value.aspectRatio,
                child: VideoPlayer(widget.controller!),
              )
            else if (widget.isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Constants.primaryColor),
                    SizedBox(height: 16),
                    Text('Loading stream...', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              )
            else if (widget.error != null && !_errorDismissed)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      widget.error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: widget.onRetry,
                      style: ElevatedButton.styleFrom(backgroundColor: Constants.primaryColor),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.tv, size: 48, color: Colors.white24),
                    SizedBox(height: 16),
                    Text('Select a channel to start watching', style: TextStyle(color: Colors.white24)),
                  ],
                ),
              ),

            // Error banner
            if (_showErrorBanner)
              Positioned(
                top: 60,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0a0804),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFfbbf24).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFfbbf24), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Playback Error', style: TextStyle(color: Color(0xFFfbbf24), fontSize: 12, fontWeight: FontWeight.bold)),
                            Text(widget.error!, style: const TextStyle(color: Colors.white54, fontSize: 10), maxLines: 1),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: widget.onRetry,
                        child: const Text('Retry', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 14, color: Colors.white54),
                        onPressed: () => setState(() => _errorDismissed = true),
                      ),
                    ],
                  ),
                ),
              ),

            // Channel name overlay in fullscreen
            if (widget.isFullscreen && widget.channelName != null && !widget.isLoading && !widget.showControls)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.channelName!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // Decoder indicator
            if (widget.useSoftwareDecoder && !widget.isLoading && widget.controller != null)
              Positioned(
                bottom: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Software Decoder', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}