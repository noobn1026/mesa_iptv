import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class AppNavigator {
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  static void navigateToLogin() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  static void navigateToHome() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}