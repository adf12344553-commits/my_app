// lib/theme_service.dart
import 'package:flutter/material.dart';
import 'app_state.dart';

class ThemeService {
  static ThemeData getTheme(String hexColor) {
    Color primaryColor = _hexToColor(hexColor);
    // 🔥 Force the color to be DARK and bold
    primaryColor = _darkenColor(primaryColor, 0.6);
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  static Color _hexToColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 7)
        buffer.write(hex.substring(1));
      else
        buffer.write(hex);
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.amber.shade900;
    }
  }

  static Color _darkenColor(Color color, double factor) {
    // factor between 0 and 1 – 0.6 makes it 60% darker
    return Color.fromRGBO(
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
      1.0,
    );
  }

  static Color getPrimaryColor(AppState appState) {
    final colorHex = appState.settings?.primaryColor ?? '#FF8F00';
    final color = _hexToColor(colorHex);
    // 🔥 Force darken
    return _darkenColor(color, 0.6);
  }
}
