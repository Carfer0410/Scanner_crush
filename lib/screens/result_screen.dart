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
import '../services/scanner_economy_service.dart';
import '../models/crush_result.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
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

      // ðŸŽµ Reproducir sonido basado en compatibilidad despuÃ©s de la animaciÃ³n
      Future.delayed(const Duration(seconds: 2), () {
        AudioService.instance.playCompatibilityResult(widget.result.percentage);
      });

      // Add haptic feedback for celebration
      if (widget.result.percentage >= 70) {
        _celebrationHaptic();
      }
    });

    _loadBannerAd();

    // Track user action para sistema de frecuencia de anuncios
    AdMobService.instance.trackUserAction();
  }

  void _loadBannerAd() async {
    // Initialize banner ad for non-premium users
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd!.load().then((_) {
        if (mounted) setState(() {});
      });
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
      final langCode = Localizations.localeOf(context).languageCode;
      await Share.share(widget.result.getShareText(languageCode: langCode));
      if (await MonetizationService.instance.canShareToday()) {
        await MonetizationService.instance.recordShare();
        await ScannerEconomyService.instance.recordShareAction();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.shareError),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }

  Future<void> _scanAgain() async {
    // Verificar lÃ­mites antes de permitir escanear de nuevo
    final canScan = await MonetizationService.instance.canScanToday();
    if (!mounted) return;
    
    if (canScan) {
      _navigateToForm();
      return;
    }

    // Usuario ha alcanzado lÃ­mite - mostrar opciones
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: ThemeService.instance.cardColor,
          title: Text(
            localizations.limitReachedTitle,
            style: TextStyle(color: ThemeService.instance.textColor),
          ),
          content: Text(
            canWatchAd 
              ? localizations.limitReachedBody
              : localizations.upgradeForUnlimited,
            style: TextStyle(color: ThemeService.instance.textColor),
          ),
          actions: [
            if (canWatchAd) ...[
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _watchAdForMoreScans();
                },
                child: Text(localizations.watchAdPlusTwoScans),
              ),
            ],
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final currentCost = await ScannerEconomyService.instance.getCurrentScanPackCost();
                final spendResult = await ScannerEconomyService.instance.buyExtraScansWithCoins();
                if (!context.mounted) return;
                final loc = AppLocalizations.of(context)!;
                final text = spendResult == ScannerCoinSpendResult.success
                    ? loc.scanPackBoughtMessage(
                        ScannerEconomyService.instance.scanPackScans,
                        currentCost,
                      )
                    : spendResult == ScannerCoinSpendResult.insufficientCoins
                        ? loc.notEnoughCoinsThisPackMessage(currentCost)
                        : spendResult == ScannerCoinSpendResult.premiumNotNeeded
                            ? loc.premiumUnlimitedScansMessage
                            : loc.dailyPackLimitReachedTryTomorrowMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(text), duration: const Duration(seconds: 6)),
                );
                if (spendResult == ScannerCoinSpendResult.success) {
                  _navigateToForm();
                }
              },
              child: Text(
                localizations.useCoinsPackPlusTwoScans,
              ),
            ),
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
            child: Text(localizations.goPremium),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.waitUntilTomorrow),
          ),
        ],
      );
      },
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
              AppLocalizations.of(context)!.processing,
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
    if (!mounted) return;
    
    Navigator.pop(context);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.extraScansWon),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 6),
        ),
      );
      
      _navigateToForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noAdsAvailable),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _navigateToForm() async {
    // Mostrar anuncio intersticial si no es premium
    final isPremium = await MonetizationService.instance.isPremiumAsync();
    if (!isPremium) {
      final shouldShow = await AdMobService.instance.shouldShowInterstitialAd();
      if (shouldShow && AdMobService.instance.isInterstitialAdReady) {
        await AdMobService.instance.showInterstitialAd();
        // PequeÃ±a pausa para que el anuncio se procese
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    
    if (!mounted) return;
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
      return const Color(0xFFE91E63); // Pink - Great compatibility (better visibility than orange)
    } else if (percentage >= 40) {
      return const Color(
        0xFF2196F3,
      ); // Blue - Good compatibility (better visibility)
    } else {
      return const Color(0xFF9C27B0); // Purple - There is potential
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ThemeService.instance.borderColor.withOpacity(0.9)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed:
                            () => Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            ),
                        icon: Icon(
                          Icons.home_rounded,
                          color: ThemeService.instance.textColor,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.resultTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: ThemeService.instance.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        onPressed: _shareResult,
                        icon: Icon(
                          Icons.ios_share_rounded,
                          color: ThemeService.instance.textColor,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
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
                          gradient: LinearGradient(
                            colors: [
                              ThemeService.instance.cardColor.withOpacity(0.95),
                              ThemeService.instance.surfaceColor.withOpacity(0.82),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: ThemeService.instance.borderColor.withOpacity(0.9),
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
                                    'ðŸ’•',
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
                            width: 212,
                            height: 212,
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
                              child: Container(
                                width: 156,
                                height: 156,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.16),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${_percentageAnimation.value.round()}%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 42,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      widget.result.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ).animate().scale(delay: 500.ms, duration: 1.seconds),

                      const SizedBox(height: 30),

                      // Compatibility level
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getPercentageColor(widget.result.percentage).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _getPercentageColor(widget.result.percentage).withOpacity(0.35),
                          ),
                        ),
                        child: Text(
                          widget.result.percentage >= 80
                              ? AppLocalizations.of(context)!.perfectCompatibility
                              : widget.result.percentage >= 60
                                  ? AppLocalizations.of(context)!.greatCompatibility
                                  : widget.result.percentage >= 40
                                      ? AppLocalizations.of(context)!.goodCompatibility
                                      : AppLocalizations.of(context)!.thereIsPotential,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _getPercentageColor(widget.result.percentage),
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                      FutureBuilder<bool>(
                        future: MonetizationService.instance.isPremiumAsync(),
                        builder: (context, snapshot) {
                          final isPremium = snapshot.data ?? false;
                          if (!isPremium && _bannerAd != null) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 20),
                              height: 50,
                              child: AdWidget(ad: _bannerAd!),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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



