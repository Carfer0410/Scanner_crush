import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumThemeService {
  static final PremiumThemeService _instance = PremiumThemeService._internal();
  factory PremiumThemeService() => _instance;
  PremiumThemeService._internal();

  static PremiumThemeService get instance => _instance;

  SharedPreferences? _prefs;
  String _currentTheme = 'default';
  
  // Notifier para cambios de tema
  final ValueNotifier<String> themeNotifier = ValueNotifier<String>('default');

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentTheme = _prefs?.getString('premium_theme') ?? 'default';
    themeNotifier.value = _currentTheme;
  }

  String get currentTheme => _currentTheme;

  // 🎨 TEMAS PREMIUM EXCLUSIVOS
  final Map<String, PremiumTheme> _premiumThemes = {
    'default': PremiumTheme(
      id: 'default',
      name: '💕 Clásico Rosa',
      description: 'El tema original y romántico',
      isPremium: false,
      primaryColor: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFF06292),
      backgroundColor: const Color(0xFFFCE4EC),
      cardColor: const Color(0xFFFFFFFF),
      gradientColors: [
        const Color(0xFFE91E63),
        const Color(0xFFF06292),
      ],
    ),
    
    'midnight_passion': PremiumTheme(
      id: 'midnight_passion',
      name: '🌙 Pasión Nocturna',
      description: 'Elegancia oscura con toques dorados',
      isPremium: true,
      primaryColor: const Color(0xFF6A0080),
      secondaryColor: const Color(0xFFAB47BC),
      backgroundColor: const Color(0xFF1A0033),
      cardColor: const Color(0xFF2D1B4E),
      gradientColors: [
        const Color(0xFF6A0080),
        const Color(0xFF9C27B0),
        const Color(0xFFAB47BC),
      ],
      particleColor: const Color(0xFFFFD700),
      glowEffect: true,
    ),
    
    'sunset_dreams': PremiumTheme(
      id: 'sunset_dreams',
      name: '🌅 Sueños del Atardecer',
      description: 'Colores cálidos de un atardecer perfecto',
      isPremium: true,
      primaryColor: const Color(0xFFFF6B35),
      secondaryColor: const Color(0xFFFF8E53),
      backgroundColor: const Color(0xFFFFF4E6),
      cardColor: const Color(0xFFFFE0B2),
      gradientColors: [
        const Color(0xFFFF6B35),
        const Color(0xFFFF8E53),
        const Color(0xFFFFAB73),
      ],
      particleColor: const Color(0xFFFFD54F),
      animated: true,
    ),
    
    'ocean_depths': PremiumTheme(
      id: 'ocean_depths',
      name: '🌊 Profundidades del Océano',
      description: 'Misterioso y profundo como el amor verdadero',
      isPremium: true,
      primaryColor: const Color(0xFF0277BD),
      secondaryColor: const Color(0xFF0288D1),
      backgroundColor: const Color(0xFF002845),
      cardColor: const Color(0xFF1565C0),
      gradientColors: [
        const Color(0xFF0277BD),
        const Color(0xFF0288D1),
        const Color(0xFF03A9F4),
      ],
      particleColor: const Color(0xFF00E5FF),
      bubbleEffect: true,
    ),
    
    'cherry_blossom': PremiumTheme(
      id: 'cherry_blossom',
      name: '🌸 Flor de Cerezo',
      description: 'Delicadeza japonesa con toques de sakura',
      isPremium: true,
      primaryColor: const Color(0xFFE1BEE7),
      secondaryColor: const Color(0xFFF8BBD9),
      backgroundColor: const Color(0xFFFFF0F5),
      cardColor: const Color(0xFFFCE4EC),
      gradientColors: [
        const Color(0xFFE1BEE7),
        const Color(0xFFF8BBD9),
        const Color(0xFFFFCDD2),
      ],
      particleColor: const Color(0xFFFFB3BA),
      petalEffect: true,
    ),
    
    'cosmic_love': PremiumTheme(
      id: 'cosmic_love',
      name: '✨ Amor Cósmico',
      description: 'El universo conspira por tu amor',
      isPremium: true,
      primaryColor: const Color(0xFF7B1FA2),
      secondaryColor: const Color(0xFF9C27B0),
      backgroundColor: const Color(0xFF0A0A2E),
      cardColor: const Color(0xFF16213E),
      gradientColors: [
        const Color(0xFF7B1FA2),
        const Color(0xFF9C27B0),
        const Color(0xFFE1BEE7),
      ],
      particleColor: const Color(0xFFFFFFFF),
      starEffect: true,
      glowEffect: true,
    ),
  };

  // Obtener todos los temas
  List<PremiumTheme> getAllThemes() {
    return _premiumThemes.values.toList();
  }

  // Obtener temas premium disponibles
  List<PremiumTheme> getPremiumThemes() {
    return _premiumThemes.values.where((theme) => theme.isPremium).toList();
  }

  // Obtener temas gratuitos
  List<PremiumTheme> getFreeThemes() {
    return _premiumThemes.values.where((theme) => !theme.isPremium).toList();
  }

  // Obtener tema actual
  PremiumTheme getCurrentTheme() {
    return _premiumThemes[_currentTheme] ?? _premiumThemes['default']!;
  }

  // Verificar si un tema está disponible
  bool isThemeAvailable(String themeId) {
    final theme = _premiumThemes[themeId];
    if (theme == null) return false;
    
    // Temporalmente habilitado para desarrollo - todos los temas disponibles
    return true;
  }

  // Cambiar tema
  Future<bool> setTheme(String themeId) async {
    if (!isThemeAvailable(themeId)) {
      return false;
    }

    _currentTheme = themeId;
    await _prefs?.setString('premium_theme', themeId);
    themeNotifier.value = themeId;
    return true;
  }

  // Obtener tema por ID
  PremiumTheme? getTheme(String themeId) {
    return _premiumThemes[themeId];
  }
}

// 🎨 Clase para definir un tema premium
class PremiumTheme {
  final String id;
  final String name;
  final String description;
  final bool isPremium;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color cardColor;
  final List<Color> gradientColors;
  final Color? particleColor;
  final bool animated;
  final bool glowEffect;
  final bool bubbleEffect;
  final bool petalEffect;
  final bool starEffect;

  const PremiumTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.isPremium,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.gradientColors,
    this.particleColor,
    this.animated = false,
    this.glowEffect = false,
    this.bubbleEffect = false,
    this.petalEffect = false,
    this.starEffect = false,
  });

  // Gradiente principal del tema
  LinearGradient get primaryGradient {
    return LinearGradient(
      colors: gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Gradiente para cards
  LinearGradient get cardGradient {
    return LinearGradient(
      colors: [
        cardColor,
        cardColor.withOpacity(0.9),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Color de texto principal
  Color get textColor {
    return primaryColor.computeLuminance() > 0.5 
        ? Colors.black87 
        : Colors.white;
  }

  // Color de texto secundario
  Color get subtitleColor {
    return textColor.withOpacity(0.7);
  }

  // Color de borde
  Color get borderColor {
    return primaryColor.withOpacity(0.3);
  }

  // Sombras para cards
  List<BoxShadow> get cardShadow {
    return [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        blurRadius: 15,
        offset: const Offset(0, 8),
      ),
      if (glowEffect)
        BoxShadow(
          color: primaryColor.withOpacity(0.3),
          blurRadius: 25,
          offset: const Offset(0, 0),
        ),
    ];
  }
}
