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
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'result_screen.dart';
import 'premium_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() { _isBannerAdReady = true; });
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _userNameController.dispose();
    _crushNameController.dispose();
    super.dispose();
  }

  Future<void> _scanLove() async {
    if (!_formKey.currentState!.validate()) {
      // Add haptic feedback for validation error
      HapticFeedback.lightImpact();
      return;
    }

    // Verificar límites de escaneo ANTES de proceder
    final canScan = await MonetizationService.instance.canScanToday();
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

      // 🔒 VERIFICACIÓN DE SEGURIDAD PRIMERO (sin registrar racha aún)
      final streakUpdate = await StreakService.instance.checkManipulation();
      
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
      final localizations = AppLocalizations.of(context);

      // Generate result FIRST (before recording scan/streak)
      final result =
          localizations != null
              ? await CrushService.instance.generateResult(
                _userNameController.text.trim(),
                _crushNameController.text.trim(),
                localizations,
              )
              : await CrushService.instance.generateSimpleResult(
                _userNameController.text.trim(),
                _crushNameController.text.trim(),
              );

      // Only record scan AFTER successful result generation
      await MonetizationService.instance.recordScan();
      final streakResult = await StreakService.instance.recordScan();

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
        final localizations = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations?.unknownError ?? 'Error desconocido'), // Error message is localized
            backgroundColor: Colors.red,
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

    showDialog(
      context: context,
      builder: (context) => FriendlyLimitDialog(
        remainingScans: remainingScans,
        onWatchAd: canWatchAd ? _watchAdForScans : null,
        onUpgrade: () {
          Navigator.pop(context);
          _navigateToPremium();
        },
      ),
    );
  }

  Future<void> _watchAdForScans() async {
    final localizations = AppLocalizations.of(context);
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
              localizations?.processing ?? 'Cargando anuncio...',
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
    
    Navigator.pop(context); // Cerrar loading
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text(localizations?.extraScansWon ?? '¡+2 escaneos ganados! 🎉'),
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
          content: Text(localizations?.unknownError ?? 'No hay anuncios disponibles. Intenta más tarde.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 6),
        ),
      );
    }
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
        final localizations = AppLocalizations.of(context);

        return Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: ThemeService.instance.textColor,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            localizations?.personalScannerTitle ??
                                'Personal Scanner', // TODO: Add localization key 'personalScanner'
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeService.instance.textColor,
                            ),
                          ),
                          const Spacer(),
                          // Contador de escaneos (con ancho limitado para evitar overflow)
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

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // Title with heart animation
                            Text(
                                  localizations?.personalCompatibilityTitle ??
                                      'Personal Compatibility', // TODO: Add localization key 'personalCompatibility'
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeService.instance.textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .scale(delay: 200.ms),

                            const SizedBox(height: 16),

                            Text(
                              localizations?.formInstructions ??
                                  'Enter your name and your crush\'s name to discover your compatibility!',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: ThemeService.instance.subtitleColor,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 400.ms),

                            const SizedBox(height: 60),

                            // User name field
                            CustomTextField(
                              hintText:
                                  localizations?.enterYourName ??
                                  'Enter your name', // TODO: Add localization key (already available as 'enterYourName')
                              icon: Icons.person,
                              controller: _userNameController,
                            ),

                            const SizedBox(height: 30),

                            // Plus icon with animation
                            Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ThemeService.instance.primaryColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeService
                                            .instance
                                            .primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                                .animate(
                                  onPlay: (controller) => controller.repeat(),
                                )
                                .rotate(duration: 3.seconds),

                            const SizedBox(height: 30),

                            // Crush name field
                            CustomTextField(
                              hintText:
                                  localizations?.enterCrushName ??
                                  'Enter your crush\'s name', // TODO: Add localization key (already available as 'enterCrushName')
                              icon: Icons.favorite,
                              controller: _crushNameController,
                            ),

                            const SizedBox(height: 60),

                            // Scan button
                            GradientButton(
                              text:
                                  _isLoading
                                      ? (localizations?.scanning ??
                                          'Scanning...')
                                      : (localizations?.scanLoveButton ??
                                          'Scan Love'), // TODO: Add localization key (already available as 'scanLoveButton')
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
                                    color: ThemeService.instance.cardColor
                                        .withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: ThemeService.instance.primaryColor
                                          .withOpacity(0.3),
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
                                        localizations?.personalAlgorithm ??
                                            'Personal Algorithm', // TODO: Add localization key (already available as 'personalAlgorithm')
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              ThemeService.instance.textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        localizations?.algorithmDescription ??
                                            'Our advanced algorithm analyzes name compatibility using numerology and cosmic vibrations.',
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
