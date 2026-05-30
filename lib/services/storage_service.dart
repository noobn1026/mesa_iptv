import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late SharedPreferences _prefs;
  
  static const String _keyUser = '@IPTV:user';
  static const String _keyToken = '@IPTV:token';
  static const String _keySettings = '@IPTV:settings';

  static void init(SharedPreferences prefs) {
    _prefs = prefs;
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs.setString(_keyUser, jsonEncode(user));
  }

  static Map<String, dynamic>? getUser() {
    final data = _prefs.getString(_keyUser);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() {
    return _prefs.getString(_keyToken);
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings));
  }

  static Map<String, dynamic> getSettings() {
    final data = _prefs.getString(_keySettings);
    if (data == null) {
      return {
        'playbackMode': 'direct',
        'autoFallbackToProxy': true,
        'forceSoftwareDecoder': false,
      };
    }
    return jsonDecode(data);
  }

  static Future<void> clearAll() async {
    await _prefs.remove(_keyUser);
    await _prefs.remove(_keyToken);
  }
}

