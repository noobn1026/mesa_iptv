import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  Map<String, dynamic> _settings = {};
  
  Map<String, dynamic> get settings => _settings;
  
  String get playbackMode => _settings['playbackMode'] ?? 'direct';
  bool get isDirectMode => playbackMode == 'direct';
  bool get isProxyMode => playbackMode == 'proxy';
  bool get autoFallbackToProxy => _settings['autoFallbackToProxy'] ?? true;
  bool get forceSoftwareDecoder => _settings['forceSoftwareDecoder'] ?? false;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _settings = StorageService.getSettings();
    notifyListeners();
  }

  Future<void> updateSetting(String key, dynamic value) async {
    _settings[key] = value;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetSettings() async {
    _settings = {
      'playbackMode': 'direct',
      'autoFallbackToProxy': true,
      'forceSoftwareDecoder': false,
    };
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }
  
  void toggleDecoder() {
    updateSetting('forceSoftwareDecoder', !forceSoftwareDecoder);
  }
}