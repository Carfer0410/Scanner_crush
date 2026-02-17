import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/theme_service.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final l10n = AppLocalizations.of(context);
    final appTitle = l10n?.appTitle ?? 'Crush Scanner';
    final subtitle = l10n?.splashSubtitle ?? 'Descubre tu destino amoroso';
    final slogan = l10n?.splashSlogan ?? '¡El amor es solo el principio! 💖';

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Semantics(
        label: '$appTitle - $subtitle',
        child: Stack(
          children: [
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [theme.primaryColor, theme.cardColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withAlpha(77),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: theme.textColor,
                        size: 64,
                        semanticLabel: appTitle,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      appTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: theme.cardColor.withAlpha(77),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.subtitleColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      slogan,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textColor.withAlpha(217),
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1.1,
                        shadows: [
                          Shadow(
                            color: theme.cardColor.withAlpha(38),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 32,
              child: FadeTransition(
                opacity: _animation,
                child: Text(
                  'Perlaza Studio',
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: theme.cardColor.withAlpha(46),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
