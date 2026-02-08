import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _currentThemeString = 'System Default';

  ThemeMode get themeMode => _themeMode;
  String get currentThemeString => _currentThemeString;

  ThemeNotifier(String savedTheme) {
    _currentThemeString = savedTheme;
    _updateThemeMode(savedTheme);
  }

  static Future<String> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme') ?? 'System Default';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme);
    _currentThemeString = theme;
    _updateThemeMode(theme);
    notifyListeners();
  }

  void _updateThemeMode(String theme) {
    if (theme == 'Light Mode') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'Dark Mode') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
  }
}
