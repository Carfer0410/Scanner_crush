import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';

import '../services/theme_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _bgRotationAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _bgRotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController.forward();

    Timer(const Duration(milliseconds: 2400), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final l10n = AppLocalizations.of(context);
    final appTitle = l10n?.appTitle ?? 'Crush Scanner';
    final subtitle = l10n?.splashSubtitle ?? 'Descubre tu destino amoroso';
    final slogan = l10n?.splashSlogan ?? 'El amor es solo el principio';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Semantics(
        label: '$appTitle - $subtitle',
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withValues(alpha: isDark ? 0.7 : 0.9),
                    theme.secondaryColor.withValues(alpha: isDark ? 0.75 : 0.95),
                    theme.surfaceColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _bgRotationAnimation,
              builder: (context, _) {
                return Stack(
                  children: [
                    _blob(
                      alignment: Alignment(
                        -0.85 + (math.sin(_bgRotationAnimation.value) * 0.07),
                        -0.78,
                      ),
                      size: 230,
                      color: theme.primaryColor.withValues(alpha: 0.22),
                    ),
                    _blob(
                      alignment: Alignment(
                        0.9,
                        -0.2 + (math.cos(_bgRotationAnimation.value) * 0.08),
                      ),
                      size: 260,
                      color: theme.secondaryColor.withValues(alpha: 0.22),
                    ),
                    _blob(
                      alignment: Alignment(
                        -0.1 + (math.sin(_bgRotationAnimation.value * 0.8) * 0.05),
                        0.9,
                      ),
                      size: 300,
                      color: theme.accentColor.withValues(alpha: 0.18),
                    ),
                  ],
                );
              },
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _logoScaleAnimation,
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, _) {
                                return Container(
                                  width: 132,
                                  height: 132,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.primaryColor.withValues(alpha: 0.95),
                                        theme.secondaryColor.withValues(alpha: 0.95),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.26),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.30 + (_pulseController.value * 0.18),
                                        ),
                                        blurRadius: 28 + (_pulseController.value * 10),
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 68,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 30),
                          Text(
                            appTitle,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: theme.textColor,
                              letterSpacing: 1.5,
                              height: 1.05,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 17,
                              color: theme.subtitleColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.cardColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: theme.borderColor.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Text(
                              slogan,
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textColor.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 36),
                          _buildLoadingBar(theme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Perlaza Studio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.86),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  Widget _buildLoadingBar(ThemeService theme) {
    return SizedBox(
      width: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 6,
          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          backgroundColor: Colors.white.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}
