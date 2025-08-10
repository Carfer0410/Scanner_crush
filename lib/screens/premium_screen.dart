import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/purchase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final currentTier = MonetizationService.instance.currentTier;
    
    // Solo mostrar anuncios si no es premium
    if (currentTier == SubscriptionTier.free) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        setState(() {
          _isBannerAdReady = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.all_inclusive,
      'title': 'unlimitedScansTitle',
      'description': 'unlimitedScansDescription',
    },
    {
      'icon': Icons.block,
      'title': 'noAdsTitle',
      'description': 'noAdsDescription',
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
      'icon': Icons.analytics,
      'title': 'advancedAnalytics',
      'description': 'analyticsDescription',
    },
    {
      'icon': Icons.palette,
      'title': 'specialThemesTitle',
      'description': 'specialThemesDescription',
    },
    {
      'icon': Icons.backup,
      'title': 'cloudBackup',
      'description': 'cloudBackupDescription',
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
      // Intentar compra real con PurchaseService
      final success = await PurchaseService.instance.buySubscription(
        PurchaseService.premiumMonthlyId
      );

      if (success && mounted) {
        // Mostrar diálogo de éxito
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
                      AppLocalizations.of(context)?.welcomeToPremium ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  AppLocalizations.of(context)?.premiumActivated ?? '',
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
                      AppLocalizations.of(context)?.great ?? '',
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
            content: Text(
              'Error en la compra: ${e.toString()}',
            ),
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
    // Restaurar compras reales con PurchaseService
    final success = await PurchaseService.instance.restorePurchases();
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.purchasesRestoredSuccessfully ?? 'Purchases restored successfully'
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.noPreviousPurchases ?? ''),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<String> _getPremiumPrice() async {
    // Obtener precio real desde PurchaseService
    final price = PurchaseService.instance.getFormattedPrice(
      PurchaseService.premiumMonthlyId
    );
    
    if (price != 'N/A') {
      return '$price/mes';
    }
    
    // Precio por defecto si no se puede cargar
    return AppLocalizations.of(context)?.defaultPrice ?? '\$4.99/month';
  }

  String _getFeatureTitle(String key) {
    switch (key) {
      case 'advancedAnalytics':
        return AppLocalizations.of(context)?.advancedAnalytics ?? key;
      case 'cloudBackup':
        return AppLocalizations.of(context)?.cloudBackup ?? key;
      case 'noAdsTitle':
        return AppLocalizations.of(context)?.noAdsTitle ?? key;
      case 'unlimitedScansTitle':
        return AppLocalizations.of(context)?.unlimitedScansTitle ?? key;
      case 'exclusiveResultsTitle':
        return AppLocalizations.of(context)?.exclusiveResultsTitle ?? key;
      case 'crushHistoryTitle':
        return AppLocalizations.of(context)?.crushHistoryTitle ?? key;
      case 'specialThemesTitle':
        return AppLocalizations.of(context)?.specialThemesTitle ?? key;
      case 'premiumSupportTitle':
        return AppLocalizations.of(context)?.premiumSupportTitle ?? key;
      default:
        return key;
    }
  }

  String _getFeatureDescription(String key) {
    switch (key) {
      case 'analyticsDescription':
        return AppLocalizations.of(context)?.analyticsDescription ?? key;
      case 'cloudBackupDescription':
        return AppLocalizations.of(context)?.cloudBackupDescription ?? key;
      case 'noAdsDescription':
        return AppLocalizations.of(context)?.noAdsDescription ?? key;
      case 'unlimitedScansDescription':
        return AppLocalizations.of(context)?.unlimitedScansDescription ?? key;
      case 'exclusiveResultsDescription':
        return AppLocalizations.of(context)?.exclusiveResultsDescription ?? key;
      case 'crushHistoryDescription':
        return AppLocalizations.of(context)?.crushHistoryDescription ?? key;
      case 'specialThemesDescription':
        return AppLocalizations.of(context)?.specialThemesDescription ?? key;
      case 'premiumSupportDescription':
        return AppLocalizations.of(context)?.premiumSupportDescription ?? key;
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
                      AppLocalizations.of(context)?.premium ?? '',
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
                AppLocalizations.of(context)?.unlockFullPotential ?? 'Unlock the full potential of love!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),                      const SizedBox(height: 16),

              Text(
                AppLocalizations.of(context)?.getFullAccess ?? 'Get full access to all special features',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ThemeService.instance.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),                      const SizedBox(height: 40),

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
                                      _getFeatureDescription(
                                        feature['description'],
                                      ),
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
                              AppLocalizations.of(context)?.specialOffer ?? 'Special Offer',
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
                                  AppLocalizations.of(context)?.monthlyPrice ?? '\$2.99',
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  AppLocalizations.of(context)?.perMonth ?? '/month',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)?.cancelAnytime ?? 'Cancel anytime',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 1.2.seconds),

                      const SizedBox(height: 30),

                      // Banner Ad (solo para usuarios gratuitos)
                      if (_bannerAd != null && _isBannerAdReady) ...[
                        Container(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Sección de precios desde PurchaseService
                      FutureBuilder<String>(
                        future: _getPremiumPrice(),
                        builder: (context, snapshot) {
                          final price = snapshot.data ?? '\$4.99/mes';
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.withOpacity(0.1),
                                  Colors.pink.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.purple.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.stars, color: Colors.amber, size: 24),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Premium',
                                      style: GoogleFonts.poppins(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeService.instance.textColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  price,
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)?.cancelAnytime ?? 'Cancel anytime',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: ThemeService.instance.subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ).animate().scale(delay: 1.2.seconds),

                      const SizedBox(height: 20),

                      // Purchase button
                      GradientButton(
                        text:
                            _isLoading
                                ? (AppLocalizations.of(context)?.processing ??
                                    '')
                                : (AppLocalizations.of(
                                      context,
                                    )?.purchasePremium ??
                                    ''),
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
                          AppLocalizations.of(
                                context,
                              )?.restorePurchasesButton ??
                              '',
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
