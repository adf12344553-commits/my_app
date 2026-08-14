// lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDark => _isDark;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDark);
    notifyListeners();
  }

  void setDark(bool value) {
    if (_isDark != value) {
      _isDark = value;
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isDarkMode', _isDark);
      });
      notifyListeners();
    }
  }
}
