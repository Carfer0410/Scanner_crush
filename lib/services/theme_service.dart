import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';


class ThemeService extends ChangeNotifier {
  /// Cambia el tema usando el nombre (string) del tema
  Future<void> setThemeByName(String themeName) async {
    try {
      final themeType = ThemeType.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => ThemeType.classic,
      );
      _currentTheme = themeType;
      themeNotifier.value = themeType.name;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_theme', themeType.index);
      notifyListeners();
    } catch (_) {}
  }
  static final ThemeService _instance = ThemeService._internal();
  static ThemeService get instance => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  ThemeType _currentTheme = ThemeType.classic;

  // Notificador reactivo para el nombre del tema actual
  final ValueNotifier<String> themeNotifier = ValueNotifier<String>(ThemeType.classic.name);

  bool get isDarkMode => _isDarkMode;
  ThemeType get currentTheme => _currentTheme;
  AppTheme get currentAppTheme => AppTheme.getThemeByType(_currentTheme);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    final themeIndex = prefs.getInt('current_theme') ?? 0;
    _currentTheme = ThemeType.values[themeIndex];
    themeNotifier.value = _currentTheme.name;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> changeTheme(ThemeType newTheme) async {
    _currentTheme = newTheme;
    themeNotifier.value = newTheme.name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_theme', newTheme.index);
    notifyListeners();
  }

  // --- Contraste dinámico global ---
  static const Color _darkText = Color(0xFF111111);
  static const Color _lightText = Color(0xFFF7F9FC);

  double _avgLuminance(Iterable<Color> colors) {
    if (colors.isEmpty) return 0.5;
    final sum = colors.fold<double>(0.0, (acc, c) => acc + c.computeLuminance());
    return sum / colors.length;
  }

  // Detecta si el fondo activo del tema es visualmente oscuro.
  bool get _isCurrentBackgroundDark {
    final gradient = _isDarkMode
        ? currentAppTheme.backgroundGradientDark
        : currentAppTheme.backgroundGradient;
    final lum = _avgLuminance(gradient.colors);
    return lum < 0.44;
  }

  // Color de texto con contraste fuerte sobre un color de fondo dado.
  Color onColor(Color background) {
    return background.computeLuminance() > 0.45 ? _darkText : _lightText;
  }

  // Gradientes basados en el tema actual
  LinearGradient get backgroundGradient {
    return _isDarkMode 
      ? currentAppTheme.backgroundGradientDark
      : currentAppTheme.backgroundGradient;
  }

  // Colores basados en el tema actual
  Color _normalizeAccent(Color color) {
    final lum = color.computeLuminance();
    if (lum <= 0.45) return color;
    final t = ((lum - 0.45) / 0.55).clamp(0.0, 1.0) * 0.45;
    return Color.lerp(color, Colors.black, t)!;
  }

  Color get primaryColor => _normalizeAccent(currentAppTheme.primaryColor);
  Color get secondaryColor => _normalizeAccent(currentAppTheme.secondaryColor);
  Color get accentColor => _normalizeAccent(currentAppTheme.accentColor);

  // Colores de texto basados en el tema actual
  Color get textColor {
    return _isCurrentBackgroundDark ? _lightText : _darkText;
  }
    
  Color get subtitleColor {
    return _isCurrentBackgroundDark
        ? _lightText.withOpacity(0.82)
        : _darkText.withOpacity(0.68);
  }

  // Colores de tarjetas y superficies basados en el tema actual
  Color get cardColor {
    if (_isCurrentBackgroundDark) {
      return Color.lerp(const Color(0xFF171A22), currentAppTheme.primaryColor, 0.12)!
          .withOpacity(0.94);
    }
    return Color.lerp(Colors.white, currentAppTheme.primaryColor, 0.04)!.withOpacity(0.94);
  }
    
  Color get surfaceColor {
    if (_isCurrentBackgroundDark) {
      return Color.lerp(const Color(0xFF222630), currentAppTheme.primaryColor, 0.08)!;
    }
    return Color.lerp(const Color(0xFFF8FAFC), currentAppTheme.primaryColor, 0.06)!;
  }

  // Colores para elementos específicos basados en el tema
  Color get iconColor {
    if (_isCurrentBackgroundDark) {
      return Colors.white.withOpacity(0.9);
    }
    return currentAppTheme.primaryColor.withOpacity(0.8);
  }
    
  Color get borderColor {
    if (_isCurrentBackgroundDark) {
      return currentAppTheme.primaryColor.withOpacity(0.3);
    }
    return currentAppTheme.primaryColor.withOpacity(0.2);
  }

  // Colores de estado adaptados al tema
  Color get successColor => _isDarkMode 
    ? const Color(0xFF4CAF50)
    : const Color(0xFF2E7D32);
    
  Color get warningColor => _isDarkMode 
    ? const Color(0xFFFF9800)
    : const Color(0xFFF57C00);
    
  Color get errorColor => _isDarkMode 
    ? const Color(0xFFF44336)
    : const Color(0xFFD32F2F);

  // Gradientes especiales para botones y elementos destacados
  LinearGradient get primaryGradient => LinearGradient(
    colors: [
      primaryColor,
      Color.lerp(primaryColor, secondaryColor, 0.6)!,
      secondaryColor,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get cardGradient {
    if (_isCurrentBackgroundDark) {
      return LinearGradient(
        colors: [
          Color.lerp(const Color(0xFF181B24), currentAppTheme.primaryColor, 0.12)!,
          Color.lerp(const Color(0xFF20242E), currentAppTheme.primaryColor, 0.08)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    
    return LinearGradient(
      colors: [
        Colors.white.withOpacity(0.96),
        Color.lerp(const Color(0xFFFDFEFF), currentAppTheme.primaryColor, 0.08)!
            .withOpacity(0.88),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Sombras optimizadas para cada tema
  List<BoxShadow> get cardShadow {
    if (_isCurrentBackgroundDark) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.34),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: primaryColor.withOpacity(0.14),
          blurRadius: 18,
          offset: const Offset(0, 2),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: primaryColor.withOpacity(0.12),
        blurRadius: 14,
        offset: const Offset(0, 3),
      ),
    ];
  }

  List<BoxShadow> get buttonShadow {
    if (_isCurrentBackgroundDark) {
      return [
        BoxShadow(
          color: primaryColor.withOpacity(0.42),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.26),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: primaryColor.withOpacity(0.26),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ];
  }
}
