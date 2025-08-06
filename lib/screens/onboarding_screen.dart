import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/theme_service.dart';
import '../services/locale_service.dart';
import '../services/audio_service.dart';
import '../widgets/custom_widgets.dart';
import 'welcome_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      _buildPage(
        icon: Icons.favorite,
        gradient: [Colors.pink, Colors.red],
        titleEn: 'Welcome to Scanner Crush',
        titleEs: 'Bienvenido a Scanner Crush',
        descEn:
            'Discover your crush in a fun and magical way with our advanced love scanner.',
        descEs:
            'Descubre a tu crush de forma divertida y mágica con nuestro escáner de amor avanzado.',
        featuresEn: [
          '✨ Advanced AI love detection',
          '💖 Celebrity crush matching',
          '🎯 Real-time compatibility',
        ],
        featuresEs: [
          '✨ Detección de amor con IA avanzada',
          '💖 Compatibilidad con celebridades',
          '🎯 Compatibilidad en tiempo real',
        ],
      ),
      _buildPage(
        icon: Icons.auto_awesome,
        gradient: [Colors.purple, Colors.deepPurple],
        titleEn: 'Daily Love Insights',
        titleEs: 'Consejos de Amor Diarios',
        descEn:
            'Get personalized daily horoscopes and track your romantic journey.',
        descEs:
            'Obtén horóscopos personalizados diarios y sigue tu viaje romántico.',
        featuresEn: [
          '📅 Daily personalized horoscope',
          '📊 Love compatibility tracking',
          '🏆 Achievement system',
        ],
        featuresEs: [
          '📅 Horóscopo personalizado diario',
          '📊 Seguimiento de compatibilidad',
          '🏆 Sistema de logros',
        ],
      ),
      _buildPage(
        icon: Icons.star,
        gradient: [Colors.amber, Colors.orange],
        titleEn: 'Unlock Premium Features',
        titleEs: 'Desbloquea Funciones Premium',
        descEn: 'Get unlimited scans, exclusive themes, and premium support.',
        descEs:
            'Obtén escaneos ilimitados, temas exclusivos y soporte premium.',
        featuresEn: [
          '🚫 No ads experience',
          '🎨 Exclusive premium themes',
          '💬 Priority customer support',
        ],
        featuresEs: [
          '🚫 Experiencia sin anuncios',
          '🎨 Temas premium exclusivos',
          '💬 Soporte prioritario',
        ],
      ),
    ]);
  }

  Widget _buildPage({
    required IconData icon,
    required List<Color> gradient,
    required String titleEn,
    required String titleEs,
    required String descEn,
    required String descEs,
    List<String>? featuresEn,
    List<String>? featuresEs,
  }) {
    final isEn = LocaleService.instance.currentLocale.languageCode == 'en';
    final features = isEn ? (featuresEn ?? []) : (featuresEs ?? []);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: gradient),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Semantics(
              label: 'Onboarding Icon',
              child: Icon(icon, size: 60, color: Colors.white),
            ),
          ).animate().scale(delay: 300.ms, duration: 800.ms),

          const SizedBox(height: 40),

          // Title with animation
          Text(
            isEn ? titleEn : titleEs,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().slideY(delay: 500.ms, duration: 600.ms),

          const SizedBox(height: 20),

          // Description with animation
          Text(
            isEn ? descEn : descEs,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: ThemeService.instance.subtitleColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 700.ms, duration: 600.ms),

          // Features list
          if (features.isNotEmpty) ...[
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: ThemeService.instance.cardGradient,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: ThemeService.instance.borderColor,
                  width: 1,
                ),
                boxShadow: ThemeService.instance.cardShadow,
              ),
              child: Column(
                children:
                    features.asMap().entries.map((entry) {
                      final index = entry.key;
                      final feature = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < features.length - 1 ? 12 : 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: gradient),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                feature,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: ThemeService.instance.textColor
                                      .withOpacity(0.9),
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ).animate().slideX(
                          delay: Duration(milliseconds: 900 + (index * 100)),
                          duration: 400.ms,
                        ),
                      );
                    }).toList(),
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ],
      ),
    );
  }

  void _onNext() async {
    // Play transition sound
    AudioService.instance.playTransition();

    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seenOnboarding', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  void _skipOnboarding() async {
    // Play transition sound
    AudioService.instance.playTransition();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        LocaleService.instance.currentLocale.languageCode ==
                                'en'
                            ? 'Skip'
                            : 'Saltar',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ThemeService.instance.subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged:
                      (index) => setState(() => _currentPage = index),
                  children: _pages,
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient:
                                i == _currentPage
                                    ? LinearGradient(
                                      colors: [Colors.pink, Colors.red],
                                    )
                                    : null,
                            color:
                                i == _currentPage
                                    ? null
                                    : ThemeService.instance.borderColor,
                          ),
                        ).animate().scale(
                          delay: Duration(milliseconds: i * 100),
                          duration: 300.ms,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Next button
                    GradientButton(
                      text:
                          _currentPage < _pages.length - 1
                              ? (LocaleService
                                          .instance
                                          .currentLocale
                                          .languageCode ==
                                      'en'
                                  ? 'Next'
                                  : 'Siguiente')
                              : (LocaleService
                                          .instance
                                          .currentLocale
                                          .languageCode ==
                                      'en'
                                  ? 'Get Started'
                                  : 'Comenzar'),
                      icon:
                          _currentPage < _pages.length - 1
                              ? Icons.arrow_forward
                              : Icons.favorite,
                      backgroundColor: ThemeService.instance.primaryColor,
                      onPressed: _onNext,
                    ).animate().slideY(delay: 900.ms, duration: 600.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
