import 'package:flutter/material.dart';

enum ThemeType {
  classic,
  sunset,
  ocean,
  forest,
  lavender,
  cosmic,
  cherry,
  golden,
}

class AppTheme {
  final ThemeType type;
  final String name;
  final String description;
  final IconData icon;
  final LinearGradient backgroundGradient;
  final LinearGradient backgroundGradientDark;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final bool isPremium;

  const AppTheme({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.backgroundGradient,
    required this.backgroundGradientDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.isPremium,
  });

  static const List<AppTheme> availableThemes = [
    // Tema clásico (gratuito)
    AppTheme(
      type: ThemeType.classic,
      name: '💘 Clásico',
      description: 'El tema original de amor',
      icon: Icons.favorite,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE0E6), // Rosa claro
          Color(0xFFFFB3C1), // Rosa medio
          Color(0xFFFF8A95), // Rosa más intenso
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
      ),
      primaryColor: Color(0xFFFF6F91),
      secondaryColor: Color(0xFFFFC0CB),
      accentColor: Color(0xFFFF1744),
      isPremium: false,
    ),

    // Tema atardecer (premium)
    AppTheme(
      type: ThemeType.sunset,
      name: '🌌 Aurora Pastel',
      description: 'Degradé moderno de violeta, rosa y azul',
      icon: Icons.wb_sunny,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF8EC5FC), // Azul suave
          Color(0xFFE0C3FC), // Lila claro
          Color(0xFFFFA8A8), // Rosa pastel
          Color(0xFFFF7EB3), // Rosa sunset
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF232526), // Gris azulado oscuro
          Color(0xFF8F94FB), // Azul violeta
          Color(0xFFFC67FA), // Rosa violeta
        ],
      ),
      primaryColor: Color(0xFF8F94FB), // Violeta azulado
      secondaryColor: Color(0xFFFF7EB3), // Rosa sunset
      accentColor: Color(0xFF8EC5FC), // Azul suave
      isPremium: true,
    ),

    // Tema océano (premium)
    AppTheme(
      type: ThemeType.ocean,
      name: '🌊 Océan',
      description: 'Profundos azules marinos',
      icon: Icons.waves,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE1F5FE), // Azul muy claro
          Color(0xFF81D4FA), // Azul claro
          Color(0xFF0277BD), // Azul profundo
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1A2E), Color(0xFF0E2347), Color(0xFF1565C0)],
      ),
      primaryColor: Color(0xFF0277BD),
      secondaryColor: Color(0xFF81D4FA),
      accentColor: Color(0xFF01579B),
      isPremium: true,
    ),

    // Tema bosque (premium)
    AppTheme(
      type: ThemeType.forest,
      name: '🌲 Bosque',
      description: 'Verdes naturales y frescos',
      icon: Icons.nature,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8F5E8), // Verde muy claro
          Color(0xFFA5D6A7), // Verde claro
          Color(0xFF388E3C), // Verde intenso
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0A1A0A), Color(0xFF1B5E20), Color(0xFF2E7D32)],
      ),
      primaryColor: Color(0xFF388E3C),
      secondaryColor: Color(0xFFA5D6A7),
      accentColor: Color(0xFF1B5E20),
      isPremium: true,
    ),

    // Tema lavanda (premium)
    AppTheme(
      type: ThemeType.lavender,
      name: '🌈 Neon Sunset',
      description: 'Vibrante degradé de fucsia, violeta y azul eléctrico',
      icon: Icons.bolt,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF5EDF), // Fucsia neón
          Color(0xFF7A5FFF), // Violeta eléctrico
          Color(0xFF01C8EE), // Azul neón
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF232526), // Gris azulado oscuro
          Color(0xFF7A5FFF), // Violeta eléctrico
          Color(0xFF0F2027), // Azul profundo
        ],
      ),
      primaryColor: Color(0xFF7A5FFF), // Violeta eléctrico
      secondaryColor: Color(0xFFFF5EDF), // Fucsia neón
      accentColor: Color(0xFF01C8EE), // Azul neón
      isPremium: true,
    ),

    // Tema cósmico (premium)
    AppTheme(
      type: ThemeType.cosmic,
      name: '🌌 Cósmico',
      description: 'Misterioso espacio profundo',
      icon: Icons.nights_stay,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A2E), // Azul muy oscuro
          Color(0xFF16213E), // Azul marino
          Color(0xFF0F3460), // Azul profundo
          Color(0xFF533A7B), // Púrpura oscuro
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF000000), // Negro absoluto
          Color(0xFF1A1A2E), // Azul muy oscuro
          Color(0xFF2D1B69), // Púrpura profundo
          Color(0xFF9C27B0), // Púrpura vibrante
        ],
      ),
      primaryColor: Color(0xFF9C27B0),
      secondaryColor: Color(0xFF673AB7),
      accentColor: Color(0xFF3F51B5),
      isPremium: true,
    ),

    // Tema cerezo (premium)
    AppTheme(
      type: ThemeType.cherry,
      name: '🌸 Cerezo',
      description: 'Elegante rosa sakura japonés',
      icon: Icons.local_florist,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF3E5F5), // Lavanda muy claro
          Color(0xFFE1BEE7), // Lila suave
          Color(0xFFBA68C8), // Púrpura medio
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A0A1A), // Púrpura muy oscuro
          Color(0xFF4A148C), // Púrpura profundo
          Color(0xFF7B1FA2), // Púrpura vibrante
        ],
      ),
      primaryColor: Color(0xFFBA68C8),
      secondaryColor: Color(0xFFE1BEE7),
      accentColor: Color(0xFF8E24AA),
      isPremium: true,
    ),

    // Tema dorado (premium)
    AppTheme(
      type: ThemeType.golden,
      name: '✨ Dorado',
      description: 'Lujo y elegancia dorada',
      icon: Icons.star,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF8E1), // Amarillo muy claro
          Color(0xFFFFD54F), // Amarillo dorado
          Color(0xFFFFA000), // Ámbar intenso
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1A0A), // Marrón muy oscuro
          Color(0xFF3E2723), // Marrón chocolate
          Color(0xFFBF360C), // Naranja oscuro
        ],
      ),
      primaryColor: Color(0xFFFFA000),
      secondaryColor: Color(0xFFFFD54F),
      accentColor: Color(0xFFFF8F00),
      isPremium: true,
    ),
  ];

  static AppTheme getThemeByType(ThemeType type) {
    return availableThemes.firstWhere((theme) => theme.type == type);
  }
}
