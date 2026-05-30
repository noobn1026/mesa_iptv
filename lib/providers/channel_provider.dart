import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/channel_model.dart';

class ChannelProvider extends ChangeNotifier {
  List<Channel> _allChannels = [];
  List<Section> _sections = [];
  String? _selectedGenre;
  Channel? _currentChannel;
  Channel? _lastChannel;
  bool _isLoading = false;
  String _searchQuery = '';

  List<Channel> get allChannels => _allChannels;
  List<Section> get sections => _sections;
  List<Section> get groupedChannels => _sections;
  String? get selectedGenre => _selectedGenre;
  Channel? get currentChannel => _currentChannel;
  Channel? get lastChannel => _lastChannel;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  
  List<Channel> get filteredChannels {
    List<Channel> result = _allChannels;
    
    if (_selectedGenre != null && _sections.isNotEmpty) {
      final section = _sections.firstWhere(
        (s) => s.title == _selectedGenre,
        orElse: () => Section(title: '', data: []),
      );
      result = section.data;
    }
    
    if (_searchQuery.isNotEmpty) {
      result = result.where((ch) => 
        ch.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    return result;
  }

  Future<void> loadChannels() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final channelsData = await ApiService.getMyChannels();
      _allChannels = channelsData.map((c) => Channel.fromJson(c)).toList();
      _allChannels.sort((a, b) => a.name.compareTo(b.name));
      
      _sections = _groupChannelsByGenre(_allChannels);
      
      if (_sections.isNotEmpty && _selectedGenre == null) {
        _selectedGenre = _sections.first.title;
      }
    } catch (e) {
      print('Error loading channels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Section> _groupChannelsByGenre(List<Channel> channels) {
    final Map<String, List<Channel>> genreMap = {};
    
    for (final channel in channels) {
      final genre = channel.group ?? channel.category ?? 'General';
      genreMap.putIfAbsent(genre, () => []).add(channel);
    }
    
    final sortedKeys = genreMap.keys.toList()..sort();
    return sortedKeys.map((key) => Section(title: key, data: genreMap[key]!)).toList();
  }

  void selectGenre(String genre) {
    if (_selectedGenre == genre) return;
    _selectedGenre = genre;
    notifyListeners();
  }

  void selectChannel(Channel channel) {
    if (_currentChannel != null && _currentChannel != channel) {
      _lastChannel = _currentChannel;
    }
    _currentChannel = channel;
    notifyListeners();
  }
  
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}