import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/daily_love_service.dart';
import '../services/audio_service.dart';
import '../test_audio_screen.dart';
import 'form_screen.dart';
import 'settings_screen.dart';
import 'celebrity_form_screen.dart';
import 'daily_love_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _titleController;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _heartController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  40,
              child: Column(
                children: [
                  // Header with buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Daily Love button
                        GestureDetector(
                          onTap: () async {
                            // 🎵 Sonido de transición
                            AudioService.instance.playTransition();

                            try {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder:
                                    (context) => const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.pink,
                                            ),
                                      ),
                                    ),
                              );

                              await DailyLoveService.instance.updateStreak();

                              // Dismiss loading
                              if (mounted) Navigator.pop(context);

                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const DailyLoveScreen(),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Dismiss loading
                              if (mounted) Navigator.pop(context);

                              // Show error dialog
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Error'),
                                        content: Text(
                                          'No se pudo cargar tu día del amor: $e',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.8),
                                  Colors.deepPurple.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  'Tu Día',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Test Audio button
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TestAudioScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.audiotrack,
                            color: ThemeService.instance.textColor,
                            size: 28,
                          ),
                        ),

                        // Settings button
                        IconButton(
                          onPressed: () {
                            // 🎵 Sonido de transición
                            AudioService.instance.playTransition();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.settings,
                            color: ThemeService.instance.textColor,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Animated heart logo
                          AnimatedBuilder(
                            animation: _heartController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_heartController.value * 0.1),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        ThemeService.instance.primaryColor,
                                        ThemeService.instance.secondaryColor,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeService
                                            .instance
                                            .primaryColor
                                            .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                ),
                              );
                            },
                          ).animate().scale(delay: 200.ms, duration: 800.ms),

                          // Title Section
                          FadeTransition(
                            opacity: _titleController,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _titleController,
                                  curve: Curves.easeOutBack,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Escáner de Crush',
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                        '💘',
                                        style: const TextStyle(fontSize: 40),
                                      )
                                      .animate(
                                        onPlay:
                                            (controller) => controller.repeat(),
                                      )
                                      .rotate(duration: 2.seconds),
                                  const SizedBox(height: 16),
                                  Text(
                                    '¿Quién te ama en secreto?',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: ThemeService.instance.textColor
                                          .withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Descubre tu compatibilidad amorosa y las señales secretas del corazón',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: ThemeService.instance.textColor
                                    .withOpacity(0.7),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(
                              delay: 1.seconds,
                              duration: 800.ms,
                            ),
                          ),

                          // Two scan options
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                // Regular Crush Scanner
                                _buildScanOption(
                                  context: context,
                                  title: 'Escáner de Crush',
                                  subtitle:
                                      'Descubre tu compatibilidad con alguien especial',
                                  icon: Icons.favorite,
                                  colors: [
                                    ThemeService.instance.primaryColor,
                                    ThemeService.instance.secondaryColor,
                                  ],
                                  onTap:
                                      () => _navigateToRegularScanner(context),
                                  delay: 1200,
                                ),

                                const SizedBox(height: 20),

                                // Celebrity Crush Scanner
                                _buildScanOption(
                                  context: context,
                                  title: 'Celebrity Crush',
                                  subtitle:
                                      'Tu compatibilidad con las estrellas',
                                  icon: Icons.star,
                                  colors: [Colors.purple, Colors.deepPurple],
                                  onTap:
                                      () =>
                                          _navigateToCelebrityScanner(context),
                                  delay: 1400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Hecho con 💕 para descubrir el amor',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ThemeService.instance.textColor.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 1.5.seconds),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(icon, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.3, duration: 600.ms);
  }

  void _navigateToRegularScanner(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const FormScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _navigateToCelebrityScanner(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const CelebrityFormScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
