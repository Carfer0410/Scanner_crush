import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  Future<void> _goToCelebritySelection() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    // 🔒 Validar si puede escanear hoy (monetización)
    final canScan = await MonetizationService.instance.canScanToday();
    
    if (!canScan) {
      HapticFeedback.lightImpact();
      _showLimitDialog();
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

  void _showLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.star,
              color: ThemeService.instance.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '¡Límite alcanzado!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has usado todos tus escaneos gratuitos de hoy.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ThemeService.instance.textColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Qué puedes hacer?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildDialogOption(
              icon: Icons.play_circle,
              title: 'Ver anuncio',
              subtitle: 'Gana +2 escaneos más',
              onTap: () async {
                Navigator.pop(context);
                final success = await MonetizationService.instance.watchAdForExtraScans();
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '¡+2 escaneos ganados!',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            _buildDialogOption(
              icon: Icons.diamond,
              title: 'Ir a Premium',
              subtitle: 'Escaneos ilimitados',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navegar a pantalla de premium
              },
            ),
            const SizedBox(height: 8),
            _buildDialogOption(
              icon: Icons.schedule,
              title: 'Esperar',
              subtitle: 'Más escaneos mañana',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: GoogleFonts.poppins(
                color: ThemeService.instance.subtitleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeService.instance.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeService.instance.primaryColor.withOpacity(0.1),
              ),
              child: Icon(
                icon,
                color: ThemeService.instance.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ThemeService.instance.textColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: ThemeService.instance.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: ThemeService.instance.subtitleColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        localizations?.celebrityCrush ?? '',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
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
                              localizations?.celebrityCrushTitle ?? '',
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
                          localizations?.celebrityCrushDescription ?? '',
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
                          hintText: localizations?.yourName ?? '',
                          icon: Icons.person,
                          controller: _userNameController,
                        ).animate().slideX(delay: 600.ms),

                        const SizedBox(height: 60),

                        // Continue button
                        GradientButton(
                          text: localizations?.chooseMyCommit ?? '',
                          onPressed: _goToCelebritySelection,
                          backgroundColor: Colors.purple,
                          icon: Icons.stars,
                        ).animate().fadeIn(delay: 800.ms),

                        const SizedBox(height: 40),

                        // Info card
                        Container(
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
                                    localizations?.celebrityMode ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ThemeService.instance.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations?.celebrityModeDescription ??
                                        '',
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
                                    localizations?.popularCelebrities ?? '',
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
                                    localizations?.andManyMore ?? '',
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
