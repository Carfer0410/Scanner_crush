import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  static ThemeService get instance => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  LinearGradient get backgroundGradient {
    if (_isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2C1810), // Dark brown
          Color(0xFF5D4037), // Medium brown
          Color(0xFF3E2723), // Dark brown
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE0E6), // Light pink
          Color(0xFFFFB3C1), // Medium pink
          Color(0xFFFF8A95), // Darker pink
        ],
      );
    }
  }

  Color get primaryColor =>
      _isDarkMode ? const Color(0xFFE91E63) : const Color(0xFFFF6F91);
  Color get secondaryColor =>
      _isDarkMode ? const Color(0xFFF48FB1) : const Color(0xFFFFC0CB);
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF2C1810);
  Color get cardColor =>
      _isDarkMode ? const Color(0xFF424242) : Colors.white.withOpacity(0.9);
}
