import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = true;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final token = StorageService.getToken();
      final userData = StorageService.getUser();
      
      if (token != null && userData != null) {
        _user = User.fromJson(userData);
        _isAuthenticated = true;
      }
    } catch (e) {
      print('Error loading auth data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final result = await ApiService.login(username, password);
      
      if (result['success'] == true) {
        await StorageService.saveUser(result['user']);
        await StorageService.saveToken(result['token']);
        
        _user = User.fromJson(result['user']);
        _isAuthenticated = true;
        notifyListeners();
        
        return {'success': true};
      }
      
      return {'success': false, 'message': result['message']};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
  
  Future<bool> checkAndLogoutIfExpired() async {
    if (_user != null && _user!.isExpired) {
      await logout();
      return true;
    }
    return false;
  }
  
  Future<bool> checkSubscriptionStatus({bool showWarning = false}) async {
    if (_user == null) return false;
    if (_user!.isExpired) {
      if (showWarning) {
        // Warning will be shown by caller
      }
      return true;
    }
    return false;
  }
}