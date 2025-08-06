import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import '../widgets/custom_widgets.dart';
import 'onboarding_screen.dart';
import 'welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimation();
    _navigateToNextScreen();
  }

  void _startAnimation() async {
    // Start heart animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      _heartController.forward();
      _pulseController.repeat();
    }
  }

  void _navigateToNextScreen() async {
    // Wait for splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check onboarding status
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      // Play transition sound
      AudioService.instance.playTransition();

      // Navigate to appropriate screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) =>
                  seenOnboarding
                      ? const WelcomeScreen()
                      : const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      // If error, default to welcome screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: ThemeService.instance,
        builder: (context, child) {
          return AnimatedBackground(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    ThemeService.instance.primaryColor.withOpacity(0.1),
                    ThemeService.instance.secondaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Main logo with animations
                    Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulse background
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 200 + (50 * _pulseController.value),
                                  height: 200 + (50 * _pulseController.value),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        ThemeService.instance.primaryColor
                                            .withOpacity(
                                              0.3 -
                                                  (0.2 *
                                                      _pulseController.value),
                                            ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Main heart icon
                            AnimatedBuilder(
                              animation: _heartController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.5 + (0.5 * _heartController.value),
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          ThemeService.instance.primaryColor,
                                          ThemeService.instance.secondaryColor,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ThemeService
                                              .instance
                                              .primaryColor
                                              .withOpacity(0.4),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 70,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Floating hearts
                            ...List.generate(6, (index) {
                              return Positioned(
                                left: 50 + (index * 30.0),
                                top: 50 + (index * 25.0),
                                child: Icon(
                                      Icons.favorite,
                                      size: 12 + (index * 2.0),
                                      color: ThemeService.instance.primaryColor
                                          .withOpacity(0.6),
                                    )
                                    .animate(
                                      delay: Duration(
                                        milliseconds: index * 200,
                                      ),
                                    )
                                    .fadeIn(duration: 1000.ms)
                                    .moveY(
                                      begin: 0,
                                      end: -20,
                                      duration: 2000.ms,
                                    )
                                    .then()
                                    .fadeOut(duration: 500.ms),
                              );
                            }),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 800.ms)
                        .scale(delay: 300.ms, duration: 800.ms),

                    const SizedBox(height: 50),

                    // App name - adapts to theme
                    Text(
                          'Scanner Crush',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: ThemeService.instance.textColor,
                            letterSpacing: 1.2,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 800.ms, duration: 600.ms)
                        .slideY(begin: 20, end: 0, duration: 600.ms),

                    const SizedBox(height: 12),

                    // Subtitle - adapts to theme
                    Text(
                          '💘 Descubre tu amor secreto',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: ThemeService.instance.subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 1200.ms, duration: 600.ms)
                        .slideY(begin: 15, end: 0, duration: 600.ms),

                    const Spacer(flex: 2),

                    // Loading indicator
                    Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      child: Column(
                        children: [
                          // Custom loading dots - theme-aware
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          ThemeService.instance.primaryColor,
                                          ThemeService.instance.secondaryColor,
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .scale(
                                    delay: Duration(milliseconds: index * 200),
                                    duration: 600.ms,
                                  );
                            }),
                          ),

                          const SizedBox(height: 20),

                          // Loading text - theme-aware
                          Text(
                            'Iniciando...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: ThemeService.instance.subtitleColor
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ).animate().fadeIn(delay: 1600.ms, duration: 400.ms),
                        ],
                      ),
                    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
