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
  aurora,
  moonlight,
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
    AppTheme(
      type: ThemeType.classic,
      name: 'Classic Bloom',
      description: 'Romantic rose with clean contrast.',
      icon: Icons.favorite,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF1F5),
          Color(0xFFFFDDE7),
          Color(0xFFFFC6D5),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF231722),
          Color(0xFF2E1D2A),
          Color(0xFF3B2131),
        ],
      ),
      primaryColor: Color(0xFFD44778),
      secondaryColor: Color(0xFFE86FA3),
      accentColor: Color(0xFF8A1E4F),
      isPremium: false,
    ),
    AppTheme(
      type: ThemeType.sunset,
      name: 'Sunset Luxe',
      description: 'Warm peach and violet twilight.',
      icon: Icons.wb_sunny,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF0E6),
          Color(0xFFFFD6C6),
          Color(0xFFE3C4FF),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2A1A1A),
          Color(0xFF3C233A),
          Color(0xFF4C2D57),
        ],
      ),
      primaryColor: Color(0xFFB2587D),
      secondaryColor: Color(0xFF8E6DD6),
      accentColor: Color(0xFFE07A5F),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.ocean,
      name: 'Ocean Glass',
      description: 'Cool marine tones with depth.',
      icon: Icons.waves,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEAF8FF),
          Color(0xFFCFEFFF),
          Color(0xFFB3E2F2),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0F2333),
          Color(0xFF163849),
          Color(0xFF1D4A57),
        ],
      ),
      primaryColor: Color(0xFF1F6C87),
      secondaryColor: Color(0xFF2A8FAE),
      accentColor: Color(0xFF0F4E63),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.forest,
      name: 'Forest Velvet',
      description: 'Emerald canopy and earthy calm.',
      icon: Icons.nature,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEEF8F1),
          Color(0xFFD9F0DF),
          Color(0xFFC5E6CF),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF10251A),
          Color(0xFF183427),
          Color(0xFF224334),
        ],
      ),
      primaryColor: Color(0xFF2F7A4D),
      secondaryColor: Color(0xFF4C9A69),
      accentColor: Color(0xFF1F5636),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.lavender,
      name: 'Lavender Neon',
      description: 'Modern violet with electric cyan.',
      icon: Icons.bolt,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF4EEFF),
          Color(0xFFDCCEFF),
          Color(0xFFC8E8FF),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1C1B2F),
          Color(0xFF2B2450),
          Color(0xFF1A3550),
        ],
      ),
      primaryColor: Color(0xFF6D4CCF),
      secondaryColor: Color(0xFF8F6BE8),
      accentColor: Color(0xFF2BA8C9),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.cosmic,
      name: 'Cosmic Noir',
      description: 'Deep-space navy with magenta glow.',
      icon: Icons.nights_stay,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1A1D34),
          Color(0xFF272447),
          Color(0xFF3B2A56),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF090B16),
          Color(0xFF14172B),
          Color(0xFF221A38),
        ],
      ),
      primaryColor: Color(0xFF8F59C7),
      secondaryColor: Color(0xFF5C7AE3),
      accentColor: Color(0xFFC85A9E),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.cherry,
      name: 'Cherry Pop',
      description: 'Coral cherry tones with vibrant berry depth.',
      icon: Icons.local_florist,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF4EE),
          Color(0xFFFFC7B8),
          Color(0xFFFF8A7A),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2C1418),
          Color(0xFF4A1E27),
          Color(0xFF6B2432),
        ],
      ),
      primaryColor: Color(0xFFE25555),
      secondaryColor: Color(0xFFFF7A59),
      accentColor: Color(0xFF8C233A),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.golden,
      name: 'Golden Opal',
      description: 'Champagne gold with premium warmth.',
      icon: Icons.star,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF8E8),
          Color(0xFFFFEDC2),
          Color(0xFFFFDC99),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF241A0F),
          Color(0xFF352312),
          Color(0xFF4A2F15),
        ],
      ),
      primaryColor: Color(0xFFB7791F),
      secondaryColor: Color(0xFFD59A2D),
      accentColor: Color(0xFF7A4F13),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.aurora,
      name: 'Aurora Dream',
      description: 'Iridescent sky glow with dreamy neon romance.',
      icon: Icons.auto_awesome,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF4FFF9),
          Color(0xFFDDF8FF),
          Color(0xFFE8DBFF),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0D1A26),
          Color(0xFF182A3D),
          Color(0xFF2A2450),
        ],
      ),
      primaryColor: Color(0xFF3BA7C9),
      secondaryColor: Color(0xFF8B6BE8),
      accentColor: Color(0xFF2CD4B7),
      isPremium: true,
    ),
    AppTheme(
      type: ThemeType.moonlight,
      name: 'Moonlight Velvet',
      description: 'Midnight indigo, silver mist and rose shimmer.',
      icon: Icons.brightness_2,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF9F6FF),
          Color(0xFFE8E0FF),
          Color(0xFFFFEAF2),
        ],
      ),
      backgroundGradientDark: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF111427),
          Color(0xFF1B1E39),
          Color(0xFF2B1F38),
        ],
      ),
      primaryColor: Color(0xFF6E63D9),
      secondaryColor: Color(0xFFB883E6),
      accentColor: Color(0xFFE36FA3),
      isPremium: true,
    ),
  ];

  static AppTheme getThemeByType(ThemeType type) {
    return availableThemes.firstWhere((theme) => theme.type == type);
  }
}
