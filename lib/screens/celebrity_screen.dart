import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/friendly_limit_widgets.dart';
import '../services/theme_service.dart';
import '../services/crush_service.dart';
import '../services/streak_service.dart';
import '../services/secure_time_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/scanner_economy_service.dart';
import '../services/locale_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'result_screen.dart';
import '../widgets/scanner_economy_panel.dart';
import 'premium_screen.dart';

class CelebrityScreen extends StatefulWidget {
  final String userName;

  const CelebrityScreen({super.key, required this.userName});

  @override
  State<CelebrityScreen> createState() => _CelebrityScreenState();
}

class _CelebrityScreenState extends State<CelebrityScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCelebrities = [];
  bool _isSearching = false;
  BannerAd? _bannerAd;
  Timer? _dailyResetTimer;
  String _lastCheckedDate = '';

  @override
  void initState() {
    super.initState();
    _filteredCelebrities = CrushService.instance.celebrities;
    _lastCheckedDate = SecureTimeService.instance
        .getSecureDate()
        .toIso8601String()
        .split('T')[0];
    _loadBannerAd();
    _startDailyResetTimer();
  }

  @override
  void dispose() {
    _dailyResetTimer?.cancel();
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _startDailyResetTimer() {
    _dailyResetTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final currentDate = SecureTimeService.instance
          .getSecureDate()
          .toIso8601String()
          .split('T')[0];
      if (currentDate != _lastCheckedDate) {
        _lastCheckedDate = currentDate;
        setState(() {});
      }
    });
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd!.load();
    }
  }

  void _filterCelebrities(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredCelebrities = CrushService.instance.celebrities;
      } else {
        _filteredCelebrities = CrushService.instance.celebrities
            .where(
              (celebrity) =>
                  celebrity.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _selectCelebrity(String celebrity) async {
    try {
      final canScan = await MonetizationService.instance.canScanToday();
      if (!canScan) {
        await _showLimitDialog();
        return;
      }

      final manipCheck = await StreakService.instance.checkManipulation();
      if (manipCheck.manipulationDetected) {
        if (!mounted) return;
        final message = manipCheck.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.security, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }

      if (!mounted) return;
      final localizations = AppLocalizations.of(context);
      final result = localizations != null
          ? await CrushService.instance.generateResult(
              widget.userName,
              celebrity,
              localizations,
            )
          : await CrushService.instance.generateSimpleResult(
              widget.userName,
              celebrity,
            );

      await MonetizationService.instance.recordScan();
      final streakUpdate = await StreakService.instance.recordScan();
      final coinsEarned =
          await ScannerEconomyService.instance.rewardScan(isCelebrity: true);
      AdMobService.instance.trackUserAction();

      if (mounted &&
          !streakUpdate.alreadyScannedToday &&
          !streakUpdate.manipulationDetected) {
        final message = streakUpdate.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  streakUpdate.isNewRecord
                      ? Icons.emoji_events
                      : Icons.local_fire_department,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: streakUpdate.isNewRecord
                ? Colors.amber.shade600
                : streakUpdate.streakBroken
                    ? Colors.orange.shade600
                    : Colors.green.shade600,
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.coinsWonMessage(coinsEarned)),
            backgroundColor: Colors.teal,
            duration: const Duration(seconds: 6),
          ),
        );
      }

      await MonetizationService.instance.showInterstitialAd();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ResultScreen(result: result, fromScreen: 'celebrity'),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorGeneratingResult),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    }
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
          success ? localizations.youGotPlusTwoScansMessage : localizations.noAdAvailableNowMessage,
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
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
    final bannerSlot = FutureBuilder<bool>(
      future: MonetizationService.instance.isPremiumAsync(),
      builder: (context, snapshot) {
        final isPremium = snapshot.data ?? false;
        if (_bannerAd != null && !isPremium) {
          return SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: AdWidget(ad: _bannerAd!),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );

    return Scaffold(
      bottomNavigationBar: bannerSlot,
      body: AnimatedBackground(
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
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
                            AppLocalizations.of(context)!.celebrityCrush,
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
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
                            Text(
                              'ðŸŒŸ',
                              style: const TextStyle(fontSize: 52),
                            ).animate().scale(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.elasticOut,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.helloCelebrity(widget.userName),
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: ThemeService.instance.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.chooseCelebrityDescription,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: ThemeService.instance.textColor.withOpacity(0.78),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.12, end: 0),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCelebrities,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchCelebrity,
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: ThemeService.instance.primaryColor,
                      ),
                      suffixIcon: _isSearching
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _filterCelebrities('');
                              },
                              icon: Icon(
                                Icons.clear,
                                color: ThemeService.instance.primaryColor,
                              ),
                            )
                          : null,
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(
                        begin: 0.3,
                        duration: const Duration(milliseconds: 600),
                      ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ScannerEconomyPanel(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  12 + MediaQuery.of(context).viewInsets.bottom,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final celebrity = _filteredCelebrities[index];
                      return GestureDetector(
                        onTap: () => _selectCelebrity(celebrity),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: ThemeService.instance.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeService.instance.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                celebrity,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate(
                            delay:
                                Duration(milliseconds: index < 20 ? 50 * index : 0),
                          )
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.8, 0.8));
                    },
                    childCount: _filteredCelebrities.length,
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


