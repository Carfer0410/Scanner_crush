import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  static ThemeService get instance => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  ThemeType _currentTheme = ThemeType.classic;

  bool get isDarkMode => _isDarkMode;
  ThemeType get currentTheme => _currentTheme;
  AppTheme get currentAppTheme => AppTheme.getThemeByType(_currentTheme);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    final themeIndex = prefs.getInt('current_theme') ?? 0;
    _currentTheme = ThemeType.values[themeIndex];
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('current_theme', newTheme.index);
    notifyListeners();
  }

  // Método auxiliar para identificar temas inherentemente oscuros
  bool isInherentlyDarkTheme() {
    switch (_currentTheme) {
      case ThemeType.cosmic:
        return true; // Cósmico es inherentemente oscuro
      default:
        // También podemos evaluar la luminancia del color primario
        // para identificar automáticamente temas oscuros
        return currentAppTheme.primaryColor.computeLuminance() < 0.3;
    }
  }

  // Gradientes basados en el tema actual
  LinearGradient get backgroundGradient {
    return _isDarkMode 
      ? currentAppTheme.backgroundGradientDark
      : currentAppTheme.backgroundGradient;
  }

  // Colores basados en el tema actual
  Color get primaryColor => currentAppTheme.primaryColor;
  Color get secondaryColor => currentAppTheme.secondaryColor;
  Color get accentColor => currentAppTheme.accentColor;

  // Colores de texto basados en el tema actual
  Color get textColor {
    // Para temas inherentemente oscuros como cósmico
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return Colors.white.withOpacity(0.95);
    }
    
    // Para temas claros, usar texto oscuro
    return currentAppTheme.primaryColor.computeLuminance() > 0.5 
      ? const Color(0xFF2C1810) // Texto oscuro para temas claros
      : const Color(0xFF1A1A1A); // Texto muy oscuro para temas vibrantes
  }
    
  Color get subtitleColor {
    // Para temas inherentemente oscuros como cósmico
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return Colors.white.withOpacity(0.7);
    }
    
    // Para temas claros
    return currentAppTheme.primaryColor.withOpacity(0.8);
  }

  // Colores de tarjetas y superficies basados en el tema actual
  Color get cardColor {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return Color.lerp(const Color(0xFF1A1A1A), currentAppTheme.primaryColor, 0.1)!.withOpacity(0.95);
    }
    return Colors.white.withOpacity(0.9);
  }
    
  Color get surfaceColor {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return Color.lerp(const Color(0xFF2A2A2A), currentAppTheme.primaryColor, 0.05)!;
    }
    return Color.lerp(Colors.white, currentAppTheme.primaryColor, 0.03)!;
  }

  // Colores para elementos específicos basados en el tema
  Color get iconColor {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return Colors.white.withOpacity(0.9);
    }
    return currentAppTheme.primaryColor.withOpacity(0.8);
  }
    
  Color get borderColor {
    if (isInherentlyDarkTheme() || _isDarkMode) {
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
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get cardGradient {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return LinearGradient(
        colors: [
          Color.lerp(const Color(0xFF1A1A1A), currentAppTheme.primaryColor, 0.1)!,
          Color.lerp(const Color(0xFF2A2A2A), currentAppTheme.primaryColor, 0.05)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    
    return LinearGradient(
      colors: [
        Colors.white.withOpacity(0.9),
        Color.lerp(Colors.white, currentAppTheme.primaryColor, 0.05)!.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Sombras optimizadas para cada tema
  List<BoxShadow> get cardShadow {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primaryColor.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: primaryColor.withOpacity(0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  List<BoxShadow> get buttonShadow {
    if (isInherentlyDarkTheme() || _isDarkMode) {
      return [
        BoxShadow(
          color: primaryColor.withOpacity(0.4),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    }
    
    return [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];
  }
}
