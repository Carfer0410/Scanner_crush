import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/crush_service.dart';
import '../services/audio_service.dart';
import '../services/streak_service.dart';
import '../services/locale_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'result_screen.dart';

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

  @override
  void dispose() {
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

      // Get localizations safely
      final localizations = AppLocalizations.of(context);

      // Generate result with proper null handling
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

      // 🔥 Update streak after successful scan
      final streakUpdate = await StreakService.instance.recordScan();

      // Show streak feedback message
      if (mounted && !streakUpdate.alreadyScannedToday) {
        final message = streakUpdate.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  streakUpdate.isNewRecord
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
                streakUpdate.isNewRecord
                    ? Colors.amber.shade600
                    : streakUpdate.streakBroken
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
            duration: const Duration(seconds: 3),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al escanear: ${e.toString()}'),
            backgroundColor: Colors.red,
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
                                'Personal Scanner',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ThemeService.instance.textColor,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance the back button
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
                                      'Personal Compatibility',
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
                                  'Enter your name',
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
                                  'Enter crush name',
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
                                          'Scan Love'),
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
                                            'Personal Algorithm',
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
