import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../models/crush_result.dart';
import 'form_screen.dart';
import 'premium_screen.dart';

class ResultScreen extends StatefulWidget {
  final CrushResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _percentageController;
  late AnimationController _heartController;
  late Animation<double> _percentageAnimation;

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

      // Add haptic feedback for celebration
      if (widget.result.percentage >= 70) {
        _celebrationHaptic();
      }
    });
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
    super.dispose();
  }

  Future<void> _shareResult() async {
    try {
      await Share.share(widget.result.shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al compartir. Inténtalo de nuevo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _scanAgain() async {
    if (AdService.instance.isPremiumUser) {
      _navigateToForm();
      return;
    }

    // Show ad before allowing to scan again
    final adShown = await AdService.instance.showInterstitialAd();
    if (adShown && mounted) {
      _navigateToForm();
    } else if (mounted) {
      // Offer premium upgrade
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const PremiumScreen()),
      );

      if (result == true && mounted) {
        _navigateToForm();
      }
    }
  }

  void _navigateToForm() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const FormScreen(),
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
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 60) {
      return const Color(0xFFFF9800); // Orange
    } else if (percentage >= 40) {
      return const Color(0xFFFFC107); // Amber
    } else {
      return const Color(0xFFE91E63); // Pink
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
                      'Resultado',
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
                            ? '¡Compatibilidad Perfecta!'
                            : widget.result.percentage >= 60
                            ? '¡Gran Compatibilidad!'
                            : widget.result.percentage >= 40
                            ? 'Buena Compatibilidad'
                            : 'Hay Potencial',
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
                              text: 'Compartir',
                              icon: Icons.share,
                              backgroundColor: Colors.blue,
                              onPressed: _shareResult,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GradientButton(
                              text: 'Escanear Otra Vez',
                              icon: Icons.refresh,
                              onPressed: _scanAgain,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1.5.seconds),

                      const SizedBox(height: 20),

                      // Ad banner for non-premium users
                      if (!AdService.instance.isPremiumUser)
                        AdService.instance.createBannerAd(),
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
