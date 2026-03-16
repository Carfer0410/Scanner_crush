import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/purchase_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  bool _isRestoringPurchases = false;
  DateTime? _lastRestoreTapAt;
  static const Duration _restoreTapCooldown = Duration(seconds: 5);
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isPremium = false;
  String _selectedProductId = PurchaseService.premiumMonthlyId;

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    // Escuchar compras exitosas que llegan asíncronamente desde el purchase stream
    PurchaseService.instance.purchaseSuccessNotifier.addListener(_onPurchaseSuccess);
  }

  void _onPurchaseSuccess() {
    if (!mounted) return;
    setState(() { _isLoading = false; });
    // Mostrar diálogo de éxito
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context, true); // Volver con éxito
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

  Future<void> _checkPremiumStatus() async {
    final isPremiumGrace = await MonetizationService.instance.isPremiumAsync();
    if (mounted) {
      setState(() {
        _isPremium = isPremiumGrace;
      });
      if (!isPremiumGrace) {
        _loadBannerAd();
      }
    }
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
    PurchaseService.instance.purchaseSuccessNotifier.removeListener(_onPurchaseSuccess);
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
      'icon': Icons.emoji_events,
      'title': 'tournament16UnlimitedTitle',
      'description': 'tournament16UnlimitedDescription',
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
  ];

  Future<void> _purchasePremium() async {
    final l10n = AppLocalizations.of(context)!;

    // Pre-check: verificar si el servicio está disponible
    if (!PurchaseService.instance.isAvailable) {
      _showErrorSnackBar(l10n.storeNotAvailable);
      return;
    }

    // Pre-check: verificar si los productos están cargados
    if (!PurchaseService.instance.hasProducts) {
      _showErrorSnackBar(l10n.productNotConfigured);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await PurchaseService.instance.buySubscription(
        _selectedProductId,
      );

      if (!mounted) return;

      switch (result) {
        case PurchaseResult.success:
          // El flujo de compra se abrió correctamente.
          // La compra se completará asíncronamente via purchaseStream.
          // Mostramos un mensaje informativo mientras tanto.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.purchaseStartedCompleteInStore),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 4),
            ),
          );
          // NO quitamos el loading aquí — se quita cuando llega
          // la confirmación via _onPurchaseSuccess o al cancelar.
          // Ponemos un timeout de seguridad por si el usuario cancela el dialog de la tienda.
          Future.delayed(const Duration(seconds: 30), () {
            if (mounted && _isLoading) {
              setState(() { _isLoading = false; });
            }
          });
          return; // No ejecutar el finally

        case PurchaseResult.storeNotAvailable:
          _showErrorSnackBar(l10n.storeNotAvailable);
          break;

        case PurchaseResult.productNotFound:
          _showErrorSnackBar(l10n.productNotConfigured);
          break;

        case PurchaseResult.purchaseAlreadyPending:
          _showErrorSnackBar(l10n.purchaseAlreadyInProgress);
          break;

        case PurchaseResult.purchaseInitFailed:
          _showErrorSnackBar(l10n.purchaseCouldNotStart);
          break;

        case PurchaseResult.error:
          _showErrorSnackBar(
            PurchaseService.instance.lastErrorMessage != null
                ? l10n.purchaseError(PurchaseService.instance.lastErrorMessage!)
                : l10n.purchaseUnexpectedError,
          );
          break;

        case PurchaseResult.validationFailed:
          _showErrorSnackBar(
            PurchaseService.instance.lastErrorMessage ??
                'Purchase validation failed. Please contact support.',
          );
          break;
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(l10n.purchaseError(e.toString()));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _restorePurchases() async {
    if (_isRestoringPurchases) return;

    final now = DateTime.now();
    if (_lastRestoreTapAt != null &&
        now.difference(_lastRestoreTapAt!) < _restoreTapCooldown) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'en'
                ? 'Please wait a few seconds before trying again.'
                : 'Espera unos segundos antes de volver a intentar.',
          ),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    _lastRestoreTapAt = now;
    setState(() => _isRestoringPurchases = true);

    try {
      // Restaurar compras reales con PurchaseService
      final success = await PurchaseService.instance.restorePurchases();
      if (!mounted) return;

      // Esperar un momento para que el purchaseStream procese las compras restauradas
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      // Verificar si realmente hay suscripción activa después de restaurar
      final hasActive = PurchaseService.instance.hasActiveSubscription() ||
          MonetizationService.instance.isPremium;

      if (success && hasActive) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.purchasesRestoredSuccessfully ??
                  'Purchases restored successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.noPreviousPurchases ?? '',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRestoringPurchases = false);
      }
    }
  }

  String _getPriceForProduct(String productId) {
    final price = PurchaseService.instance.getFormattedPrice(productId);
    if (price != '-') return price;
    switch (productId) {
      case PurchaseService.premiumMonthlyId: return '\$2.99';
      case PurchaseService.premiumYearlyId: return '\$9.99';
      default: return '-';
    }
  }

  String _getPeriodLabel(String productId) {
    final l10n = AppLocalizations.of(context)!;
    if (productId.contains('yearly')) return l10n.perYear;
    return l10n.perMonth;
  }

  String _getFeatureTitle(String key) {
    switch (key) {
      case 'advancedAnalytics':
        return AppLocalizations.of(context)?.advancedAnalytics ?? key;
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
      case 'tournament16UnlimitedTitle':
        return AppLocalizations.of(context)?.tournament16UnlimitedTitle ?? key;
      default:
        return key;
    }
  }

  String _getFeatureDescription(String key) {
    switch (key) {
      case 'analyticsDescription':
        return AppLocalizations.of(context)?.analyticsDescription ?? key;
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
      case 'tournament16UnlimitedDescription':
        return AppLocalizations.of(context)?.tournament16UnlimitedDescription ?? key;
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeService.instance.borderColor.withOpacity(0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: ThemeService.instance.textColor,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.premium ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: ThemeService.instance.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withOpacity(0.18),
                              ThemeService.instance.primaryColor.withOpacity(0.2),
                              ThemeService.instance.secondaryColor.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeService.instance.primaryColor.withOpacity(0.14),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orange],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.36),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.stars, color: Colors.white, size: 46),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)?.unlockFullPotential ??
                                  'Unlock the full potential of love!',
                              style: GoogleFonts.poppins(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: ThemeService.instance.textColor,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              AppLocalizations.of(context)?.getFullAccess ??
                                  'Get full access to all special features',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: ThemeService.instance.subtitleColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms).scale(duration: 700.ms),

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

                      const SizedBox(height: 32),

                      // --- Plan selector title ---
                      Text(
                        AppLocalizations.of(context)?.choosePlan ?? 'Choose your plan',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: ThemeService.instance.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 1.seconds),

                      const SizedBox(height: 20),

                      // --- PREMIUM PLANS ---
                      _buildTierSection(
                        tierName: AppLocalizations.of(context)?.premiumPlanTitle ?? 'Premium',
                        icon: Icons.stars,
                        color: Colors.amber,
                        monthlyId: PurchaseService.premiumMonthlyId,
                        yearlyId: PurchaseService.premiumYearlyId,
                      ).animate().fadeIn(delay: 1.1.seconds).slideY(begin: 0.1),

                      const SizedBox(height: 24),

                      // Banner Ad (solo si NO es premium)
                      if (_bannerAd != null && _isBannerAdReady && !_isPremium) ...[
                        Container(
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Purchase button
                      GradientButton(
                        text:
                            _isLoading
                                ? (AppLocalizations.of(context)?.processing ?? '')
                                : (AppLocalizations.of(context)?.purchasePremium ?? ''),
                        icon: Icons.credit_card,
                        backgroundColor: Colors.amber,
                        onPressed: _purchasePremium,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        AppLocalizations.of(context)?.cancelAnytime ?? 'Cancel anytime',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: ThemeService.instance.subtitleColor,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Restore purchases link
                      TextButton(
                        onPressed: _isRestoringPurchases ? null : _restorePurchases,
                        child: Text(
                          _isRestoringPurchases
                              ? (Localizations.localeOf(context).languageCode == 'en'
                                  ? 'Restoring...'
                                  : 'Restaurando...')
                              : (AppLocalizations.of(context)?.restorePurchasesButton ?? ''),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ThemeService.instance.textColor.withOpacity(0.6),
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

  Widget _buildTierSection({
    required String tierName,
    required IconData icon,
    required Color color,
    required String monthlyId,
    required String yearlyId,
    bool isPremiumPlus = false,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.08),
            ThemeService.instance.cardColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedProductId == monthlyId || _selectedProductId == yearlyId
              ? color.withOpacity(0.6)
              : ThemeService.instance.borderColor,
          width: _selectedProductId == monthlyId || _selectedProductId == yearlyId ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tier header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                tierName,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
              ),
              if (isPremiumPlus) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.bestValue,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (isPremiumPlus) ...[
            const SizedBox(height: 8),
            Text(
              l10n.premiumPlusDescription,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: ThemeService.instance.subtitleColor,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Monthly option
          _buildPlanOption(
            productId: monthlyId,
            period: l10n.monthly,
            price: _getPriceForProduct(monthlyId),
            periodSuffix: _getPeriodLabel(monthlyId),
            color: color,
          ),

          const SizedBox(height: 10),

          // Yearly option
          _buildPlanOption(
            productId: yearlyId,
            period: l10n.yearly,
            price: _getPriceForProduct(yearlyId),
            periodSuffix: _getPeriodLabel(yearlyId),
            color: color,
            badge: l10n.mostPopular,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOption({
    required String productId,
    required String period,
    required String price,
    required String periodSuffix,
    required Color color,
    String? badge,
  }) {
    final isSelected = _selectedProductId == productId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = productId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : ThemeService.instance.cardColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : ThemeService.instance.borderColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : ThemeService.instance.subtitleColor,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),

            // Period label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        period,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Text(
              '$price$periodSuffix',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : ThemeService.instance.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


