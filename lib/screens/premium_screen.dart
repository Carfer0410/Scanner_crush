import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/ad_service.dart';
import '../generated/l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.block,
      'title': 'noAdsTitle',
      'description': 'noAdsDescription',
    },
    {
      'icon': Icons.all_inclusive,
      'title': 'unlimitedScansTitle',
      'description': 'unlimitedScansDescription',
    },
    {
      'icon': Icons.star,
      'title': 'exclusiveResultsTitle',
      'description': 'exclusiveResultsDescription',
    },
    {
      'icon': Icons.favorite_border,
      'title': 'crushHistoryTitle',
      'description': 'crushHistoryDescription',
    },
    {
      'icon': Icons.palette,
      'title': 'specialThemesTitle',
      'description': 'specialThemesDescription',
    },
    {
      'icon': Icons.support_agent,
      'title': 'premiumSupportTitle',
      'description': 'premiumSupportDescription',
    },
  ];

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate purchase process
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, implement actual in-app purchase logic here
      // For now, we'll just simulate a successful purchase
      await AdService.instance.setPremiumUser(true);

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.welcomeToPremium,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  AppLocalizations.of(context)!.premiumActivated,
                  style: GoogleFonts.poppins(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(
                        context,
                        true,
                      ); // Return to previous screen with success
                    },
                    child: Text(
                      AppLocalizations.of(context)!.great,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en la compra: ${e.toString()}'),
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

  void _restorePurchases() async {
    // In a real app, implement restore purchases logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noPreviousPurchases),
        backgroundColor: Colors.orange,
      ),
    );
  }

  String _getFeatureTitle(String key) {
    switch (key) {
      case 'noAdsTitle':
        return AppLocalizations.of(context)!.noAdsTitle;
      case 'unlimitedScansTitle':
        return AppLocalizations.of(context)!.unlimitedScansTitle;
      case 'exclusiveResultsTitle':
        return AppLocalizations.of(context)!.exclusiveResultsTitle;
      case 'crushHistoryTitle':
        return AppLocalizations.of(context)!.crushHistoryTitle;
      case 'specialThemesTitle':
        return AppLocalizations.of(context)!.specialThemesTitle;
      case 'premiumSupportTitle':
        return AppLocalizations.of(context)!.premiumSupportTitle;
      default:
        return key;
    }
  }

  String _getFeatureDescription(String key) {
    switch (key) {
      case 'noAdsDescription':
        return AppLocalizations.of(context)!.noAdsDescription;
      case 'unlimitedScansDescription':
        return AppLocalizations.of(context)!.unlimitedScansDescription;
      case 'exclusiveResultsDescription':
        return AppLocalizations.of(context)!.exclusiveResultsDescription;
      case 'crushHistoryDescription':
        return AppLocalizations.of(context)!.crushHistoryDescription;
      case 'specialThemesDescription':
        return AppLocalizations.of(context)!.specialThemesDescription;
      case 'premiumSupportDescription':
        return AppLocalizations.of(context)!.premiumSupportDescription;
      default:
        return key;
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
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: ThemeService.instance.textColor,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!.premium,
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
                      // Premium crown icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(Icons.stars, color: Colors.white, size: 50),
                      ).animate().scale(delay: 200.ms, duration: 800.ms),

                      const SizedBox(height: 30),

                      Text(
                        AppLocalizations.of(context)!.premiumSubtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 16),

                      Text(
                        'Obtén acceso completo a todas las funciones especiales',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ThemeService.instance.subtitleColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 40),

                      // Features list
                      ..._features.asMap().entries.map((entry) {
                        final index = entry.key;
                        final feature = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
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
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ThemeService.instance.primaryColor
                                      .withOpacity(0.2),
                                ),
                                child: Icon(
                                  feature['icon'],
                                  color: ThemeService.instance.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getFeatureTitle(feature['title']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeService.instance.textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getFeatureDescription(feature['description']),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: ThemeService.instance.textColor
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().slideX(
                          delay: Duration(milliseconds: 800 + (index * 100)),
                          duration: 600.ms,
                        );
                      }).toList(),

                      const SizedBox(height: 40),

                      // Price card
                      Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Oferta Especial',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$2.99',
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '/mes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cancela cuando quieras',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 1.2.seconds),

                      const SizedBox(height: 30),

                      // Purchase button
                      GradientButton(
                        text: _isLoading ? AppLocalizations.of(context)!.processing : AppLocalizations.of(context)!.purchasePremium,
                        icon: Icons.credit_card,
                        backgroundColor: Colors.amber,
                        onPressed: _purchasePremium,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 16),

                      // Restore purchases link
                      TextButton(
                        onPressed: _restorePurchases,
                        child: Text(
                          AppLocalizations.of(context)!.restorePurchasesButton,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ThemeService.instance.textColor.withOpacity(
                              0.6,
                            ),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
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
