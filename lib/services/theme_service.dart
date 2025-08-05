import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  static ThemeService get instance => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('dark_mode') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    notifyListeners();
  }

  // Gradientes mejorados para ambos temas
  LinearGradient get backgroundGradient {
    if (_isDarkMode) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E), // Azul oscuro elegante
          Color(0xFF16213E), // Azul marino profundo
          Color(0xFF0F3460), // Azul medianoche
        ],
      );
    } else {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE0E6), // Rosa claro
          Color(0xFFFFB3C1), // Rosa medio
          Color(0xFFFF8A95), // Rosa más intenso
        ],
      );
    }
  }

  // Colores primarios y secundarios mejorados
  Color get primaryColor => _isDarkMode 
    ? const Color(0xFFFF6B9D) // Rosa vibrante para modo oscuro
    : const Color(0xFFFF6F91); // Rosa original para modo claro
    
  Color get secondaryColor => _isDarkMode 
    ? const Color(0xFFC44EB5) // Magenta suave para modo oscuro
    : const Color(0xFFFFC0CB); // Rosa claro para modo claro

  // Colores de texto optimizados
  Color get textColor => _isDarkMode 
    ? const Color(0xFFF5F5F5) // Blanco suave
    : const Color(0xFF2C1810); // Marrón oscuro original
    
  Color get subtitleColor => _isDarkMode 
    ? const Color(0xFFB0B0B0) // Gris claro para subtítulos
    : const Color(0xFF757575); // Gris medio para subtítulos

  // Colores de tarjetas y superficies mejorados
  Color get cardColor => _isDarkMode 
    ? const Color(0xFF1E1E2E).withOpacity(0.95) // Azul muy oscuro con transparencia
    : Colors.white.withOpacity(0.9);
    
  Color get surfaceColor => _isDarkMode 
    ? const Color(0xFF252540) // Superficie secundaria oscura
    : const Color(0xFFF8F9FA); // Superficie secundaria clara

  // Colores para elementos específicos
  Color get iconColor => _isDarkMode 
    ? const Color(0xFFE0E0E0) // Blanco suave para iconos
    : const Color(0xFF424242); // Gris oscuro para iconos
    
  Color get borderColor => _isDarkMode 
    ? const Color(0xFF3A3A54) // Borde sutil oscuro
    : const Color(0xFFE0E0E0); // Borde sutil claro

  // Colores de estado
  Color get successColor => _isDarkMode 
    ? const Color(0xFF4CAF50) // Verde exitoso
    : const Color(0xFF2E7D32); // Verde más oscuro para modo claro
    
  Color get warningColor => _isDarkMode 
    ? const Color(0xFFFF9800) // Naranja cálido
    : const Color(0xFFF57C00); // Naranja más oscuro para modo claro
    
  Color get errorColor => _isDarkMode 
    ? const Color(0xFFF44336) // Rojo suave
    : const Color(0xFFD32F2F); // Rojo más oscuro para modo claro

  // Gradientes especiales para botones y elementos destacados
  LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  LinearGradient get cardGradient => _isDarkMode 
    ? const LinearGradient(
        colors: [
          Color(0xFF1E1E2E),
          Color(0xFF252540),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )
    : LinearGradient(
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Sombras optimizadas para cada tema
  List<BoxShadow> get cardShadow => _isDarkMode 
    ? [
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
      ]
    : [
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

  List<BoxShadow> get buttonShadow => _isDarkMode 
    ? [
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
      ]
    : [
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ];
}
