import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/admob_service.dart';
import '../services/audio_service.dart';
import '../services/monetization_service.dart';
import '../models/crush_result.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form_screen.dart';
import 'celebrity_screen.dart';
import 'premium_screen.dart';

class ResultScreen extends StatefulWidget {
  final CrushResult result;
  final String? fromScreen; // 'celebrity' or null for personal

  const ResultScreen({super.key, required this.result, this.fromScreen});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _percentageController;
  late AnimationController _heartController;
  late Animation<double> _percentageAnimation;
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();

    _percentageController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _percentageAnimation = Tween<double>(
      begin: 0,
      end: widget.result.percentage.toDouble(),
    ).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 500), () {
      _percentageController.forward();
      _heartController.forward();

      // 🎵 Reproducir sonido basado en compatibilidad después de la animación
      Future.delayed(const Duration(seconds: 2), () {
        AudioService.instance.playCompatibilityResult(widget.result.percentage);
      });

      // Add haptic feedback for celebration
      if (widget.result.percentage >= 70) {
        _celebrationHaptic();
      }
    });

    // Initialize banner ad for non-premium users
    if (!MonetizationService.instance.isPremium) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd!.load();
    }
  }

  void _celebrationHaptic() {
    // Create a celebration haptic pattern
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _heartController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _shareResult() async {
    try {
      await Share.share(widget.result.shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.shareError),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _scanAgain() async {
    // Verificar límites antes de permitir escanear de nuevo
    final canScan = await MonetizationService.instance.canScanToday();
    
    if (canScan) {
      _navigateToForm();
      return;
    }

    // Usuario ha alcanzado límite - mostrar opciones
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¡Límite alcanzado! 🎯'),
        content: Text(
          canWatchAd 
            ? 'Has usado todos tus escaneos de hoy. ¿Qué quieres hacer?'
            : 'Has usado todos tus escaneos de hoy. Upgradeaa Premium para escaneos ilimitados.',
        ),
        actions: [
          if (canWatchAd) ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _watchAdForMoreScans();
              },
              child: Text('Ver anuncio (+2 escaneos)'),
            ),
          ],
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const PremiumScreen()),
              );
              if (result == true && mounted) {
                _navigateToForm();
              }
            },
            child: Text('Ir a Premium'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Esperar hasta mañana'),
          ),
        ],
      ),
    );
  }

  Future<void> _watchAdForMoreScans() async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeService.instance.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando anuncio...',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
    
    // Intentar mostrar anuncio con recompensa
    final success = await MonetizationService.instance.watchAdForExtraScans();
    
    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡+2 escaneos ganados! Ahora puedes escanear de nuevo 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      _navigateToForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay anuncios disponibles. Intenta más tarde.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _navigateToForm() async {
    // Mostrar anuncio intersticial si no es premium
    if (!MonetizationService.instance.isPremium) {
      final shouldShow = await AdMobService.instance.shouldShowInterstitialAd();
      if (shouldShow && AdMobService.instance.isInterstitialAdReady) {
        await AdMobService.instance.showInterstitialAd();
        // Pequeña pausa para que el anuncio se procese
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    Widget destinationScreen;

    if (widget.fromScreen == 'celebrity') {
      // Return to celebrity screen with the user name
      destinationScreen = CelebrityScreen(userName: widget.result.userName);
    } else {
      // Return to personal form screen
      destinationScreen = const FormScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => destinationScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) {
      return const Color(0xFF4CAF50); // Green - Perfect compatibility
    } else if (percentage >= 60) {
      return const Color(0xFFFF9800); // Orange - Great compatibility
    } else if (percentage >= 40) {
      return const Color(
        0xFF2196F3,
      ); // Blue - Good compatibility (better visibility)
    } else {
      return const Color(0xFFE91E63); // Pink - There is potential
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          () => Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          ),
                      icon: Icon(
                        Icons.home,
                        color: ThemeService.instance.textColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!.resultTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _shareResult,
                      icon: Icon(
                        Icons.share,
                        color: ThemeService.instance.textColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Names display
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: ThemeService.instance.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ThemeService.instance.borderColor,
                            width: 1,
                          ),
                          boxShadow: ThemeService.instance.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.result.userName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    Icons.person,
                                    color: ThemeService.instance.primaryColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),

                            AnimatedBuilder(
                              animation: _heartController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_heartController.value * 0.2),
                                  child: Text(
                                    '💕',
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                );
                              },
                            ),

                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    widget.result.crushName,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    Icons.favorite,
                                    color: ThemeService.instance.primaryColor,
                                    size: 30,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms),

                      const SizedBox(height: 40),

                      // Percentage circle
                      AnimatedBuilder(
                        animation: _percentageAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _getPercentageColor(widget.result.percentage),
                                  _getPercentageColor(
                                    widget.result.percentage,
                                  ).withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getPercentageColor(
                                    widget.result.percentage,
                                  ).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_percentageAnimation.value.round()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    widget.result.emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ).animate().scale(delay: 500.ms, duration: 1.seconds),

                      const SizedBox(height: 30),

                      // Compatibility level
                      Text(
                        widget.result.percentage >= 80
                            ? AppLocalizations.of(context)!.perfectCompatibility
                            : widget.result.percentage >= 60
                            ? AppLocalizations.of(context)!.greatCompatibility
                            : widget.result.percentage >= 40
                            ? AppLocalizations.of(context)!.goodCompatibility
                            : AppLocalizations.of(context)!.thereIsPotential,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getPercentageColor(widget.result.percentage),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 1.seconds),

                      const SizedBox(height: 30),

                      // Message card
                      Container(
                            padding: const EdgeInsets.all(25),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: ThemeService.instance.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.result.message,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: ThemeService.instance.textColor,
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 1.2.seconds)
                          .slideY(begin: 20, end: 0),

                      const SizedBox(height: 40),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: AppLocalizations.of(context)!.shareButton,
                              icon: Icons.share,
                              backgroundColor: Colors.blue,
                              onPressed: _shareResult,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GradientButton(
                              text:
                                  AppLocalizations.of(context)!.scanAgainButton,
                              icon: Icons.refresh,
                              onPressed: _scanAgain,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1.5.seconds),

                      const SizedBox(height: 20),

                      // Ad banner for non-premium users
                      if (!MonetizationService.instance.isPremium && _bannerAd != null)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 50,
                          child: AdWidget(ad: _bannerAd!),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
