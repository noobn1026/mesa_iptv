import 'package:flutter/material.dart';

class Constants {
  // API Configuration
  static const String apiBaseUrl = 'https://admini.pxxl.click/api';
  static const String proxyBase = 'https://admini.pxxl.click/api/proxy/stream';
  
  // Device detection
  static bool isTV(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 900;
  }
  
  static bool isTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > 600 && shortestSide <= 900;
  }
  
  static bool isPhone(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide <= 600;
  }
  
  static bool isLandscape(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height;
  }
  
  // Dynamic sidebar width
  static double getSidebarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isTV(context)) return width * 0.28;
    if (isTablet(context)) return width * 0.32;
    return width * 0.45;
  }
  
  static const double sidebarWidth = 320;
  
  // Item heights
  static double getChannelItemHeight(BuildContext context) {
    if (isTV(context)) return 80;
    if (isTablet(context)) return 72;
    return 65;
  }
  
  static double getGenreItemHeight(BuildContext context) {
    if (isTV(context)) return 80;
    if (isTablet(context)) return 72;
    return 65;
  }
  
  static const double channelItemHeight = 65;
  static const double genreItemHeight = 65;
  
  // Font sizes
  static double getGenreHeaderFontSize(BuildContext context) {
    if (isTV(context)) return 18;
    if (isTablet(context)) return 16;
    return 14;
  }
  
  static double getGenreNameFontSize(BuildContext context) {
    if (isTV(context)) return 16;
    if (isTablet(context)) return 15;
    return 13;
  }
  
  static double getChannelHeaderFontSize(BuildContext context) {
    if (isTV(context)) return 18;
    if (isTablet(context)) return 16;
    return 14;
  }
  
  static double getChannelNameFontSize(BuildContext context) {
    if (isTV(context)) return 15;
    if (isTablet(context)) return 14;
    return 13;
  }
  
  // TV focus scale
  static double getTVFocusScale(BuildContext context) {
    return isTV(context) ? 1.05 : 1.03;
  }
  
  // Timeouts
  static const int controlsHideMs = 4000;
  static const int doubleTapMs = 300;
  static const int streamTimeoutMs = 8000;
  static const int bufferingTimeoutMs = 5000;
  static const int maxAutoRetries = 3;
  
  // Colors
  static const Color primary = Color(0xFFe50914);
  static const Color primaryDark = Color(0xFFb20710);
  static const Color background = Color(0xFF0a0a0a);
  static const Color sidebar = Color(0xFF111111);
  static const Color sidebarLight = Color(0xFF1a1a1a);
  static const Color active = Color(0xFF330000);
  static const Color focused = Color(0xFFe50914);
  static const Color focusedLight = Color(0xFFff1a1a);
  static const Color text = Color(0xFFffffff);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textMuted = Color(0xFF666666);
  static const Color border = Color(0xFF2a2a2a);
  static const Color borderLight = Color(0xFF3a3a3a);
  static const Color hd = Color(0xFF4fc3f7);
  static const Color lastChannel = Color(0xFFf9a825);
  static const Color success = Color(0xFF4caf50);
  static const Color warning = Color(0xFFff9800);
  static const Color preview = Color(0xFF3498db);
  static const Color previewBorder = Color(0xFF2980b9);
  static const Color lastChannelColor = Color(0xFFf9a825);

  
  // Legacy support for existing code
  static const Color primaryColor = primary;
  static const Color backgroundColor = background;
  static const Color sidebarColor = sidebar;
  static const Color borderColor = border;
  static const Color activeColor = active;
  static const Color focusedColor = focused;
  static const Color textColor = text;
  static const Color previewColor = preview;
  static const Color previewBorderColor = previewBorder;
}