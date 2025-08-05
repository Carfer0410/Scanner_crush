import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import 'celebrity_screen.dart';

class CelebrityFormScreen extends StatefulWidget {
  const CelebrityFormScreen({super.key});

  @override
  State<CelebrityFormScreen> createState() => _CelebrityFormScreenState();
}

class _CelebrityFormScreenState extends State<CelebrityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  void _goToCelebritySelection() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    HapticFeedback.mediumImpact();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                CelebrityScreen(userName: _userNameController.text.trim()),
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

  @override
  Widget build(BuildContext context) {
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
                        'Celebrity Crush',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // Celebrity icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.deepPurple],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 60,
                          ),
                        ).animate().scale(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 40),

                        // Title
                        Text(
                              '🌟 Celebrity Crush 🌟',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
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
                          'Descubre tu compatibilidad con las estrellas más brillantes de Hollywood y el mundo del entretenimiento',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: ThemeService.instance.textColor.withOpacity(
                              0.7,
                            ),
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 60),

                        // User name field
                        CustomTextField(
                          hintText: 'Tu nombre',
                          icon: Icons.person,
                          controller: _userNameController,
                        ).animate().slideX(delay: 600.ms),

                        const SizedBox(height: 60),

                        // Continue button
                        GradientButton(
                          text: 'Elegir Mi Celebrity Crush ✨',
                          onPressed: _goToCelebritySelection,
                          backgroundColor: Colors.purple,
                          icon: Icons.stars,
                        ).animate().fadeIn(delay: 800.ms),

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
                                  color: Colors.purple.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.purple,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '✨ Celebrity Mode ✨',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nuestro algoritmo estelar analiza tu nombre y la energía cósmica de las celebridades para revelarte conexiones únicas del mundo del entretenimiento.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: ThemeService.instance.textColor
                                          .withOpacity(0.7),
                                      height: 1.4,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 1000.ms)
                            .slideY(begin: 30, end: 0),

                        const SizedBox(height: 40),

                        // Popular celebrities preview
                        Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.withOpacity(0.1),
                                    Colors.deepPurple.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.purple.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '🎬 Celebridades Populares',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        [
                                              'Ryan Gosling',
                                              'Zendaya',
                                              'Harry Styles',
                                              'Bad Bunny',
                                              'Taylor Swift',
                                              'Pedro Pascal',
                                            ]
                                            .map(
                                              (name) => Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  name,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        ThemeService
                                                            .instance
                                                            .textColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Y muchos más...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: ThemeService.instance.textColor
                                          .withOpacity(0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 1200.ms)
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
  }
}
