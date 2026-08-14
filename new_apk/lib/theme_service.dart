// lib/theme_service.dart
import 'package:flutter/material.dart';
import 'app_state.dart';

class ThemeService {
  static ThemeData getTheme(String hexColor, {bool isDark = true}) {
    Color primaryColor = _hexToColor(hexColor);
    primaryColor = _darkenColor(primaryColor, 0.6);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: primaryColor,
              surface: const Color(0xFF151B2B),
              background: const Color(0xFF080B14),
              onPrimary: Colors.white,
              onSurface: const Color(0xFFF8FAFC),
              onBackground: const Color(0xFFF8FAFC),
              error: const Color(0xFFEF4444),
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: primaryColor,
              surface: Colors.white,
              background: Colors.grey[50]!,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              onBackground: Colors.black87,
              error: const Color(0xFFEF4444),
            ),
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF080B14) : Colors.grey[50],
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF151B2B) : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade300,
              width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.transparent : primaryColor,
        foregroundColor: isDark ? const Color(0xFFF8FAFC) : Colors.white,
        elevation: isDark ? 0 : 2,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFF8FAFC) : Colors.white,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
            color: isDark ? const Color(0xFF94A3B8) : Colors.white70),
        actionsIconTheme: IconThemeData(
            color: isDark ? const Color(0xFF94A3B8) : Colors.white70),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor:
            isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      textTheme: isDark
          ? const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC)),
              headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8FAFC)),
              titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8FAFC)),
              bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFF8FAFC)),
              bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
              labelLarge: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF8FAFC)),
            )
          : const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              headlineMedium: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
              bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
              labelLarge: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF151B2B) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
        hintStyle: TextStyle(
            color: isDark ? const Color(0xFF64748B) : Colors.grey.shade500),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? const Color(0xFF1A2133) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.grey.shade300),
        ),
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFFF8FAFC) : Colors.black87,
        ),
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : Colors.black54,
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
    return _darkenColor(color, 0.6);
  }
}
