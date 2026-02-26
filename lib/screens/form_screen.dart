import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/friendly_limit_widgets.dart';
import '../services/theme_service.dart';
import '../services/crush_service.dart';
import '../services/audio_service.dart';
import '../services/streak_service.dart';
import '../services/locale_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/secure_time_service.dart';
import '../services/scanner_economy_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'result_screen.dart';
import 'premium_screen.dart';
import '../widgets/scanner_economy_panel.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _crushNameController = TextEditingController();
  bool _isLoading = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  Timer? _dailyResetTimer;
  String _lastCheckedDate = '';

  @override
  void initState() {
    super.initState();
    _lastCheckedDate = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    _loadBannerAd();
    _startDailyResetTimer();
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    _userNameController.dispose();
    _crushNameController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _startDailyResetTimer() {
    // Verificar cada minuto si cambió el día
    _dailyResetTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      final currentDate = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
      if (currentDate != _lastCheckedDate) {
        _lastCheckedDate = currentDate;
        setState(() {}); // Reconstruir para actualizar el contador
      }
    });
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() { _isBannerAdReady = true; });
      });
    }
  }

  // Duplicate dispose() removed; logic merged into the single dispose() above.

  Future<void> _scanLove() async {
    if (!_formKey.currentState!.validate()) {
      // Add haptic feedback for validation error
      HapticFeedback.lightImpact();
      return;
    }

    // Verificar límites de escaneo ANTES de proceder
    final canScan = await MonetizationService.instance.canScanToday();
    if (!mounted) return;
    if (!canScan) {
      await _showLimitDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // 🎵 Reproducir sonido de inicio de escaneo
    AudioService.instance.playMagicWhoosh();

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    try {
      // Simulate scanning process
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // 🔒 VERIFICACIÓN DE SEGURIDAD PRIMERO (sin registrar racha aún)
      final streakUpdate = await StreakService.instance.checkManipulation();
      if (!mounted) return;
      
      // 🚨 BLOQUEAR ESCANEO SI HAY MANIPULACIÓN DETECTADA
      if (streakUpdate.manipulationDetected) {
        final message = streakUpdate.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.security, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              duration: const Duration(seconds: 6),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return; // 🛑 DETENER ESCANEO AQUÍ
      }

      // Get localizations safely
      final localizations = AppLocalizations.of(context)!;

      // Generate result FIRST (before recording scan/streak)
      final result = await CrushService.instance.generateResult(
        _userNameController.text.trim(),
        _crushNameController.text.trim(),
        localizations,
      );

      // Only record scan AFTER successful result generation
      await MonetizationService.instance.recordScan();
      final streakResult = await StreakService.instance.recordScan();
      final coinsEarned = await ScannerEconomyService.instance.rewardScan(
        isCelebrity: false,
      );

      // Track user action para sistema de frecuencia de anuncios
      AdMobService.instance.trackUserAction();

      // Show streak feedback message solo si no fue manipulación
      if (mounted && !streakResult.alreadyScannedToday && !streakResult.manipulationDetected) {
        final message = streakResult.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  streakResult.isNewRecord
                      ? Icons.emoji_events
                      : Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor:
                streakResult.isNewRecord
                    ? Colors.amber.shade600
                    : streakResult.streakBroken
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.coinsWonMessage(coinsEarned)),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }

      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => ResultScreen(
                  result: result,
                ), // Personal scanner - no fromScreen needed
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.unknownError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLimitDialog() async {
    final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => FriendlyLimitDialog(
        remainingScans: remainingScans,
        onWatchAd: canWatchAd ? _watchAdForScans : null,
        onUseCoins: _useCoinsForScans,
        onUpgrade: () {
          Navigator.pop(context);
          _navigateToPremium();
        },
      ),
    );
  }

  Future<void> _watchAdForScans() async {
    final screenContext = context;
    final localizations = AppLocalizations.of(screenContext)!;
    Navigator.pop(context); // Cerrar diálogo
    
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
              localizations.processing,
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
    
    Navigator.pop(context); // Cerrar loading
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text(localizations.extraScansWon),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 6),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.noAdsAvailable),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  Future<void> _useCoinsForScans() async {
    final localizations = AppLocalizations.of(context)!;
    Navigator.pop(context);
    final currentCost = await ScannerEconomyService.instance.getCurrentScanPackCost();
    final spend = await ScannerEconomyService.instance.buyExtraScansWithCoins();
    if (!mounted) return;

    final text = spend == ScannerCoinSpendResult.success
        ? localizations.scanPackBoughtMessage(ScannerEconomyService.instance.scanPackScans, currentCost)
        : spend == ScannerCoinSpendResult.insufficientCoins
            ? localizations.notEnoughCoinsThisPackMessage(currentCost)
            : spend == ScannerCoinSpendResult.premiumNotNeeded
                ? localizations.premiumUnlimitedScansMessage
                : localizations.dailyPackLimitReachedTryTomorrowMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: spend == ScannerCoinSpendResult.success ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
  }
  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleService.instance,
      builder: (context, child) {
        final localizations = AppLocalizations.of(context)!;

        return Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeService.instance.cardColor.withOpacity(0.72),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: ThemeService.instance.borderColor.withOpacity(0.9),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: ThemeService.instance.textColor,
                                size: 20,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                localizations.personalScannerTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeService.instance.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: FutureBuilder<int>(
                                future: MonetizationService.instance.getRemainingScansTodayForFree(),
                                builder: (context, snapshot) {
                                  final remaining = snapshot.data ?? 0;
                                  final isPremium = MonetizationService.instance.isPremium;
                                  return ScanCounterWidget(
                                    remainingScans: remaining,
                                    isPremium: isPremium,
                                  );
                                },
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
                            const SizedBox(height: 18),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ThemeService.instance.cardColor.withOpacity(0.92),
                                    ThemeService.instance.surfaceColor.withOpacity(0.82),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: ThemeService.instance.primaryColor.withOpacity(0.25),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    localizations.personalCompatibilityTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeService.instance.textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.formInstructions,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: ThemeService.instance.subtitleColor,
                                      height: 1.45,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.12, end: 0),

                            const SizedBox(height: 24),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                localizations.retentionRewardsTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeService.instance.textColor,
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            const ScannerEconomyPanel(),

                            const SizedBox(height: 36),

                            // User name field
                            CustomTextField(
                              hintText:
                                  localizations.enterYourName,
                              icon: Icons.person,
                              controller: _userNameController,
                            ),

                            const SizedBox(height: 30),

                            // Connector
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: ThemeService.instance.primaryColor.withOpacity(0.35),
                                    thickness: 1.2,
                                  ),
                                ),
                                Container(
                                  width: 42,
                                  height: 42,
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: ThemeService.instance.primaryGradient,
                                  ),
                                  child: const Icon(
                                    Icons.favorite_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: ThemeService.instance.primaryColor.withOpacity(0.35),
                                    thickness: 1.2,
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 200.ms),

                            const SizedBox(height: 30),

                            // Crush name field
                            CustomTextField(
                              hintText:
                                  localizations.enterCrushName,
                              icon: Icons.favorite,
                              controller: _crushNameController,
                            ),

                            const SizedBox(height: 60),

                            // Scan button
                            GradientButton(
                              text:
                                  _isLoading
                                      ? localizations.scanning
                                      : localizations.scanLoveButton,
                              onPressed: _scanLove,
                              isLoading: _isLoading,
                              icon: _isLoading ? null : Icons.search,
                            ),

                            const SizedBox(height: 40),

                            // Info card
                            Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ThemeService.instance.cardColor.withOpacity(0.95),
                                        ThemeService.instance.surfaceColor.withOpacity(0.82),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: ThemeService.instance.primaryColor
                                          .withOpacity(0.24),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color:
                                            ThemeService.instance.primaryColor,
                                        size: 28,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        localizations.personalAlgorithm,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ThemeService.instance.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        localizations.algorithmDescription,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color:
                                              ThemeService
                                                  .instance
                                                  .subtitleColor,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideY(begin: 30, end: 0),
                          ],
                        ),
                      ),
                    ),

                    // Banner ad para usuarios no premium
                    if (_bannerAd != null && _isBannerAdReady && !MonetizationService.instance.isPremium)
                      Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}




