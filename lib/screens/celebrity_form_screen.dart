import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/friendly_limit_widgets.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/scanner_economy_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'celebrity_screen.dart';
import 'premium_screen.dart';
import '../widgets/scanner_economy_panel.dart';

class CelebrityFormScreen extends StatefulWidget {
  const CelebrityFormScreen({super.key});

  @override
  State<CelebrityFormScreen> createState() => _CelebrityFormScreenState();
}

class _CelebrityFormScreenState extends State<CelebrityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() { _isBannerAdReady = true; });
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
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
      await _showLimitDialog();
      return;
    }

    HapticFeedback.mediumImpact();
    if (!mounted) return;

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

  Future<void> _showLimitDialog() async {
    final remainingScans = await MonetizationService.instance.getRemainingScansTodayForFree();
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => FriendlyLimitDialog(
        remainingScans: remainingScans,
        onWatchAd: canWatchAd ? _watchAdForScans : null,
        onUseCoins: _useCoinsForScans,
        onWatchAdForCoins: _watchAdForCoins,
        onUpgrade: () {
          Navigator.pop(context);
          _navigateToPremium();
        },
      ),
    );
  }

  Future<void> _watchAdForScans() async {
    final localizations = AppLocalizations.of(context)!;
    Navigator.pop(context);
    final success = await MonetizationService.instance.watchAdForExtraScans();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? localizations.extraScansWon : localizations.noAdsAvailable,
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _useCoinsForScans() async {
    final localizations = AppLocalizations.of(context)!;
    Navigator.pop(context);
    final currentCost = await ScannerEconomyService.instance.getCurrentScanPackCost();
    final spend = await ScannerEconomyService.instance.buyExtraScansWithCoins();
    if (!mounted) return;

    final text = spend == ScannerCoinSpendResult.success
        ? localizations.scanPackBoughtMessage(ScannerEconomyService.instance.scanPackScans, currentCost)
        : spend == ScannerCoinSpendResult.insufficientCoins
            ? localizations.notEnoughCoinsThisPackMessage(currentCost)
            : spend == ScannerCoinSpendResult.premiumNotNeeded
                ? localizations.premiumUnlimitedScansMessage
                : localizations.dailyPackLimitReachedTryTomorrowMessage;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: spend == ScannerCoinSpendResult.success ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  Future<void> _watchAdForCoins() async {
    final localizations = AppLocalizations.of(context)!;
    Navigator.pop(context);
    final ok = await ScannerEconomyService.instance.watchAdForCoins();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? localizations.coinsEarnedMessage(ScannerEconomyService.instance.coinAdReward)
              : localizations.noAdsAvailable,
        ),
        backgroundColor: ok ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 6),
      ),
    );
  }

  void _navigateToPremium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PremiumScreen()),
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.cardColor.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ThemeService.instance.borderColor.withOpacity(0.9),
                      ),
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
                            localizations?.celebrityCrush ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ThemeService.instance.textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: FutureBuilder<int>(
                            future: MonetizationService.instance.getRemainingScansTodayForFree(),
                            builder: (context, snapshot) {
                              final remaining = snapshot.data ?? 0;
                              final isPremium = MonetizationService.instance.isPremium;
                              return ScanCounterWidget(
                                remainingScans: remaining,
                                isPremium: isPremium,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ThemeService.instance.cardColor.withOpacity(0.94),
                                ThemeService.instance.surfaceColor.withOpacity(0.82),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: ThemeService.instance.primaryColor.withOpacity(0.24),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 86,
                                height: 86,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: ThemeService.instance.primaryGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: ThemeService.instance.primaryColor.withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                localizations?.celebrityCrushTitle ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeService.instance.textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations?.celebrityCrushDescription ?? '',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: ThemeService.instance.textColor.withOpacity(0.76),
                                  height: 1.42,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.12, end: 0),

                        const SizedBox(height: 36),

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

                        const SizedBox(height: 24),

                        const ScannerEconomyPanel(),

                        const SizedBox(height: 24),

                        // Info card
                        Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: ThemeService.instance.cardColor
                                    .withOpacity(0.8),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: ThemeService.instance.primaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: ThemeService.instance.primaryColor,
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
                                    localizations?.celebrityModeDescription ?? '',
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
                                    ThemeService.instance.primaryColor.withOpacity(0.1),
                                    ThemeService.instance.accentColor.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: ThemeService.instance.primaryColor.withOpacity(0.2),
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
                                                  color: ThemeService.instance.primaryColor
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

                // Banner ad para usuarios no premium
                if (_bannerAd != null && _isBannerAdReady && !MonetizationService.instance.isPremium)
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}








