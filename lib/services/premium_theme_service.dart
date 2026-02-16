import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'monetization_service.dart';
import 'theme_service.dart';
import 'secure_time_service.dart';

class PremiumThemeService {
  /// Verifica si el acceso temporal al tema premium actual expiró y fuerza el cambio a classic si es necesario
  Future<void> checkAndHandleExpiredPremium() async {
    final now = SecureTimeService.instance.getSecureTime();
    final currentTheme = ThemeService.instance.currentTheme.name;

    // Verificar si el tema actual tiene acceso temporal expirado
    final expiryString = _tempPremiumThemes[currentTheme];
    if (expiryString != null) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && expiry.isBefore(now)) {
        // Acceso expirado, cambiar al tema clásico
        _tempPremiumThemes.remove(currentTheme);
        await _saveTempPremiumThemes();

        // Cambiar al tema clásico usando ThemeService
        await ThemeService.instance.setThemeByName('classic');

        // Notificar cambios
        tempAccessNotifier.value++;
      }
    }

    // También verificar todos los accesos temporales expirados y limpiarlos
    final expiredThemes = <String>[];
    _tempPremiumThemes.forEach((themeId, expiryString) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && expiry.isBefore(now)) {
        expiredThemes.add(themeId);
      }
    });

    // Limpiar temas expirados
    for (final themeId in expiredThemes) {
      _tempPremiumThemes.remove(themeId);
    }

    if (expiredThemes.isNotEmpty) {
      await _saveTempPremiumThemes();
      tempAccessNotifier.value++;
    }
  }
  static final PremiumThemeService _instance = PremiumThemeService._internal();
  factory PremiumThemeService() => _instance;
  PremiumThemeService._internal();

  static PremiumThemeService get instance => _instance;

  SharedPreferences? _prefs;
  String _currentTheme = 'default';

  // Notifier para cambios de tema
  final ValueNotifier<String> themeNotifier = ValueNotifier<String>('default');

  // Mapa de accesos temporales por tema: {themeId: expiryIsoString}
  Map<String, String> _tempPremiumThemes = {};
  // Notificador para cambios en accesos temporales
  final ValueNotifier<int> tempAccessNotifier = ValueNotifier<int>(0);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _currentTheme = _prefs?.getString('premium_theme') ?? 'default';
    themeNotifier.value = _currentTheme;
    _loadTempPremiumThemes();

    // Iniciar temporizador para verificar expiraciones cada 5 minutos
    _startExpirationTimer();
  }

  void _startExpirationTimer() {
    // Verificar expiraciones cada 5 minutos
    Future.delayed(const Duration(minutes: 5), () async {
      await checkAndHandleExpiredPremium();
      _startExpirationTimer(); // Reiniciar el temporizador
    });
  }

  void _loadTempPremiumThemes() {
    final mapString = _prefs?.getString('temp_premium_themes');
    if (mapString != null && mapString.isNotEmpty) {
      try {
        final entries = (mapString.split(';')..removeWhere((e) => e.isEmpty))
            .map((e) {
          final parts = e.split(':');
          if (parts.length == 2) {
            return MapEntry(parts[0], parts[1]);
          }
          return null;
        }).whereType<MapEntry<String, String>>();
        _tempPremiumThemes = Map<String, String>.fromEntries(entries);
      } catch (_) {
        _tempPremiumThemes = {};
      }
    } else {
      _tempPremiumThemes = {};
    }
  }

  Future<void> _saveTempPremiumThemes() async {
    // Serializa el mapa como string: themeId:expiry;themeId2:expiry2
    final mapString = _tempPremiumThemes.entries
        .map((e) => "${e.key}:${e.value}")
        .join(';');
    await _prefs?.setString('temp_premium_themes', mapString);
  }

  /// Otorga acceso temporal a un tema premium por 1 hora
  Future<void> grantTemporaryAccessToTheme(String themeId) async {
    final expiry = SecureTimeService.instance.getSecureTime().add(const Duration(hours: 1));
    _tempPremiumThemes[themeId] = expiry.toIso8601String();
    await _saveTempPremiumThemes();
    tempAccessNotifier.value++;
  }

  /// Método de debug para otorgar acceso temporal con duración específica
  Future<void> grantDebugAccess(String themeId, DateTime expiry) async {
    // Usar tiempo seguro incluso para debug
    final secureNow = SecureTimeService.instance.getSecureTime();
    final secureExpiry = secureNow.add(expiry.difference(secureNow));
    _tempPremiumThemes[themeId] = secureExpiry.toIso8601String();
    await _saveTempPremiumThemes();
    tempAccessNotifier.value++;
  }

  /// Verifica si el usuario tiene acceso temporal activo a un tema premium
  bool hasTemporaryAccessToTheme(String themeId) {
    final expiryString = _tempPremiumThemes[themeId];
    if (expiryString == null) return false;
    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return false;
    if (SecureTimeService.instance.getSecureTime().isAfter(expiry)) {
      // Expiró, limpiar
      _tempPremiumThemes.remove(themeId);
      _saveTempPremiumThemes();
      tempAccessNotifier.value++;
      return false;
    }
    return true;
  }

  /// Devuelve las horas restantes de acceso temporal a un tema premium
  int getTemporaryHoursRemainingForTheme(String themeId) {
    final expiryString = _tempPremiumThemes[themeId];
    if (expiryString == null) return 0;
    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return 0;
    final remaining = expiry.difference(SecureTimeService.instance.getSecureTime()).inHours;
    return remaining.clamp(0, 24);
  }

  String get currentTheme => _currentTheme;

  // 🎨 TEMAS PREMIUM EXCLUSIVOS
  final Map<String, PremiumTheme> _premiumThemes = {
    'default': PremiumTheme(
      id: 'default',
      name: '💕 Clásico Rosa',
      description: 'El tema original y romántico', // TODO: Add localization
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
      description: 'Elegancia oscura con toques dorados', // TODO: Add localization
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
      name: '🌅 Aurora pastel',
      description: 'Colores cálidos de un atardecer perfecto', // TODO: Add localization
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


  // Verificar si un tema está disponible para el usuario actual
  Future<bool> isThemeAvailable(String themeId) async {
    final theme = _premiumThemes[themeId];
    if (theme == null) return false;
    if (!theme.isPremium) return true;

    // Si es premium real o período de gracia, acceso total
    final monet = MonetizationService.instance;
    if (await monet.isPremiumWithGrace()) return true;

    // Acceso temporal por anuncio a este tema
    if (hasTemporaryAccessToTheme(themeId)) return true;

    return false;
  }

  // Cambiar tema
  Future<bool> setTheme(String themeId) async {
    if (!await isThemeAvailable(themeId)) {
      return false;
    }

    _currentTheme = themeId;
    await _prefs?.setString('premium_theme', themeId);
    themeNotifier.value = themeId;
    return true;
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
