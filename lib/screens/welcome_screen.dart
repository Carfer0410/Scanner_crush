import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/daily_love_service.dart';
import '../services/audio_service.dart';
import '../services/locale_service.dart';
import '../services/streak_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/global_economy_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form_screen.dart';
import 'settings_screen.dart';
import 'celebrity_form_screen.dart';
import 'daily_love_screen.dart';
import 'analytics_screen.dart';
import 'themes_screen.dart';
import 'tournament_setup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _titleController;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // Load banner ad for non-premium users
    _loadBannerAd();
  }

  void _loadBannerAd() async {
    // Solo cargar banner ads para usuarios no premium
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) {
          setState(() {
            _isBannerAdReady = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _heartController.dispose();
    _titleController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color getTextColor([Color? fallback]) => isDark ? Colors.white : (fallback ?? ThemeService.instance.textColor);
    Color getSubtitleColor([Color? fallback]) => isDark ? Colors.white70 : (fallback ?? ThemeService.instance.textColor.withOpacity(0.7));
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              children: [
                // Header with buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Daily Love button
                      GestureDetector(
                        onTap: () async {
                          // 🎵 Sonido de transición
                          AudioService.instance.playTransition();

                          try {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeService.instance.primaryColor,
                                  ),
                                ),
                              ),
                            );
                            await DailyLoveService.instance.updateStreak();

                            // Dismiss loading
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            if (!context.mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailyLoveScreen(),
                                ),
                              );
                          } catch (e) {
                            // Dismiss loading
                            if (!context.mounted) return;
                            Navigator.pop(context);

                            // Show error dialog
                            if (!context.mounted) return;
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: ThemeService.instance.cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    AppLocalizations.of(context)!.errorTitle,
                                    style: TextStyle(
                                      color: ThemeService.instance.textColor,
                                    ),
                                  ),
                                  content: Text(
                                    AppLocalizations.of(context)!.errorLoadingLoveDay(e.toString()),
                                    style: TextStyle(
                                      color: ThemeService.instance.subtitleColor,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        AppLocalizations.of(context)!.ok,
                                        style: TextStyle(
                                          color: ThemeService.instance.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ThemeService.instance.primaryColor.withOpacity(0.8),
                                ThemeService.instance.secondaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: ThemeService.instance.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                AppLocalizations.of(context)!.dailyLove,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Settings button
                      IconButton(
                        onPressed: () {
                          // 🎵 Sonido de transición
                          AudioService.instance.playTransition();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.settings,
                          color: ThemeService.instance.textColor,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildCoinsChip(),
                  ),
                ),

                // Streak card
                _buildStreakCard(),

                // Banner de límites
                _buildLimitsBanner(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Animated heart logo
                      AnimatedBuilder(
                        animation: _heartController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_heartController.value * 0.1),
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    ThemeService.instance.primaryColor,
                                    ThemeService.instance.secondaryColor,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ThemeService.instance.primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          );
                        },
                      ).animate().scale(delay: 200.ms, duration: 800.ms),

                      // Title Section
                      FadeTransition(
                        opacity: _titleController,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _titleController,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.appTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: getTextColor(),
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ThemeService.instance.cardColor.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: ThemeService.instance.primaryColor.withOpacity(0.35),
                                  ),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.loveIntelligenceStudio,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.35,
                                    color: getTextColor(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('💘', style: const TextStyle(fontSize: 40))
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .rotate(duration: 2.seconds),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context)!.welcomeTitle,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: getTextColor(ThemeService.instance.textColor.withOpacity(0.8)),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          AppLocalizations.of(context)!.welcomeSubtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: getSubtitleColor(),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 1.seconds, duration: 800.ms),
                      ),

                      // Two scan options
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            // Regular Crush Scanner
                            _buildScanOption(
                              context: context,
                              title: AppLocalizations.of(context)!.startScan,
                              subtitle:
                                  AppLocalizations.of(
                                    context,
                                  )!.regularScanSubtitle,
                              icon: Icons.favorite,
                              colors: const [Color(0xFF00A86B), Color(0xFF36D399)],
                              onTap: () => _navigateToRegularScanner(context),
                              delay: 1200,
                            ),

                            const SizedBox(height: 20),

                            // Celebrity Crush Scanner
                            _buildScanOption(
                              context: context,
                              title:
                                  AppLocalizations.of(context)!.celebrityScan,
                              subtitle:
                                  AppLocalizations.of(
                                    context,
                                  )!.celebrityScanSubtitle,
                              icon: Icons.star,
                              colors: [ThemeService.instance.primaryColor, ThemeService.instance.secondaryColor],
                              onTap: () => _navigateToCelebrityScanner(context),
                              delay: 1400,
                            ),

                            const SizedBox(height: 20),

                            // Love Tournament 🏆
                            _buildScanOption(
                              context: context,
                              title: AppLocalizations.of(context)!.tournamentTitle,
                              subtitle: AppLocalizations.of(context)!.tournamentWelcomeSubtitle,
                              icon: Icons.emoji_events,
                              colors: [Colors.orange, Colors.deepOrange],
                              onTap: () => _navigateToTournament(context),
                              delay: 1600,
                            ),

                            const SizedBox(height: 20),

                            // Premium Analytics (Premium Feature)
                            _buildScanOption(
                              context: context,
                              title: AppLocalizations.of(context)!.premiumAnalytics,
                              subtitle: AppLocalizations.of(context)!.analyzeCompatibilityPatterns,
                              icon: Icons.analytics,
                              colors: [Colors.blue, Colors.blueAccent],
                              onTap: () => _navigateToAnalytics(context),
                              delay: 1800,
                            ),

                            const SizedBox(height: 20),

                            // Premium Themes (Premium Feature)
                            _buildScanOption(
                              context: context,
                              title: AppLocalizations.of(context)!.premiumThemes,
                              subtitle: AppLocalizations.of(context)!.customizeWithThemes,
                              icon: Icons.palette,
                              colors: [Colors.purple, Colors.purpleAccent],
                              onTap: () => _navigateToThemes(context),
                              delay: 2000,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    AppLocalizations.of(context)!.madeWithLove,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: ThemeService.instance.textColor.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 1.5.seconds),
                ),

                // Banner Ad for non-premium users
                FutureBuilder<bool>(
                  future: MonetizationService.instance.isPremiumAsync(),
                  builder: (context, snapshot) {
                    final isPremium = snapshot.data ?? false;
                    if (_bannerAd != null && _isBannerAdReady && !isPremium) {
                      return Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        margin: const EdgeInsets.only(bottom: 20),
                        child: AdWidget(ad: _bannerAd!),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScanOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
    required int delay,
    bool isPremium = false,
  }) {
    return FutureBuilder<bool>(
      future: MonetizationService.instance.isPremiumAsync(),
      builder: (context, snapshot) {
        final hasPremiumAccess = snapshot.data ?? false;
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 92, maxHeight: 128),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.9],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.24),
                    ),
                  ),
                  child: Icon(icon, size: 24, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.05,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (isPremium && !hasPremiumAccess) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PRO', // TODO: Add localization key 'proBadge'
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.88),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.18),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.3, duration: 600.ms);
      },
    );
  }

  void _navigateToRegularScanner(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const FormScreen(),
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
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _navigateToCelebrityScanner(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const CelebrityFormScreen(),
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
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _navigateToTournament(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const TournamentSetupScreen(),
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
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _navigateToAnalytics(BuildContext context) async {
    // Abrir AnalyticsScreen siempre; el propio screen maneja el desbloqueo
    // (estadísticas gratis; insights/predictions via premium o anuncio).
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AnalyticsScreen(),
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

  void _navigateToThemes(BuildContext context) {
    // 🎵 Sonido de transición
    AudioService.instance.playTransition();

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const ThemesScreen(),
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

  Widget _buildCoinsChip() {
    return FutureBuilder<int>(
      future: GlobalEconomyService.instance.getCoins(),
      builder: (context, snapshot) {
        final coins = snapshot.data ?? 0;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ThemeService.instance.cardColor.withOpacity(0.88),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.amber.withOpacity(0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.toll, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Coins: $coins',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.textColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build streak card widget
  /// Construir widget de tarjeta de racha
  Widget _buildStreakCard() {
    return GestureDetector(
      onTap: () {
        _showStreakDetails();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeService.instance.primaryColor.withOpacity(0.1),
              ThemeService.instance.secondaryColor.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ThemeService.instance.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeService.instance.primaryColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListenableBuilder(
          listenable: StreakService.instance,
          builder: (context, _) {
            final streakService = StreakService.instance;
            final currentStreak = streakService.currentStreak;

            return Row(
              children: [
                // Streak icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        currentStreak > 0
                            ? Colors.orange
                            : ThemeService.instance.subtitleColor.withOpacity(
                              0.3,
                            ),
                  ),
                  child: Icon(
                    currentStreak > 0
                        ? Icons.local_fire_department
                        : Icons.favorite_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // Streak info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.dailyStreak,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    Text(
                        currentStreak > 0
                            ? '🔥 ${AppLocalizations.of(context)!.daysStreak(currentStreak)}'
                            : AppLocalizations.of(context)!.startLoveStreak,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Best streak
                if (streakService.bestStreak > 0)
                  Column(
                    children: [
                      Text(
                        '${streakService.bestStreak}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context)!.best,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3);
  }

  /// Show streak details dialog
  /// Mostrar diálogo de detalles de racha
  void _showStreakDetails() {
    showDialog(
      context: context,
      builder:
          (context) => ListenableBuilder(
            listenable: StreakService.instance,
            builder: (context, _) {
              final streakService = StreakService.instance;

              return AlertDialog(
                backgroundColor: ThemeService.instance.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.streakStatsTitle,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: ThemeService.instance.primaryColor,
                        size: 20,
                      ),
                      onPressed: () => _showStreakInfoDialog(),
                      tooltip:
                          AppLocalizations.of(context)!.learnAboutStats,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatRow(
                      AppLocalizations.of(context)!.currentStreak,
                      AppLocalizations.of(context)!.daysStreak(streakService.currentStreak),
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      AppLocalizations.of(context)!.bestStreak,
                      AppLocalizations.of(context)!.daysStreak(streakService.bestStreak),
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      AppLocalizations.of(context)!.totalScans,
                      '${streakService.totalScans}',
                      Icons.favorite,
                      Colors.pink,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      streakService.getMotivationalMessage(
                        LocaleService.instance.currentLocale.languageCode,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: ThemeService.instance.subtitleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppLocalizations.of(context)!.close,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  /// Show streak information dialog explaining what each statistic means
  /// Mostrar diálogo de información de racha explicando qué significa cada estadística
  void _showStreakInfoDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: ThemeService.instance.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: ThemeService.instance.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.streakInfoDialogTitle,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: ThemeService.instance.textColor,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Streak explanation
                  _buildInfoSection(
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                    title: AppLocalizations.of(context)!.currentStreak,
                    description: AppLocalizations.of(context)!.streakInfoCurrentDesc,
                    example: AppLocalizations.of(context)!.streakInfoCurrentExample,
                  ),
                  const SizedBox(height: 20),

                  // Best Streak explanation
                  _buildInfoSection(
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                    title: AppLocalizations.of(context)!.bestStreak,
                    description: AppLocalizations.of(context)!.streakInfoBestDesc,
                    example: AppLocalizations.of(context)!.streakInfoBestExample,
                  ),
                  const SizedBox(height: 20),

                  // Total Scans explanation
                  _buildInfoSection(
                    icon: Icons.favorite,
                    color: Colors.pink,
                    title: AppLocalizations.of(context)!.totalScans,
                    description: AppLocalizations.of(context)!.streakInfoTotalDesc,
                    example: AppLocalizations.of(context)!.streakInfoTotalExample,
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.primaryColor.withOpacity(
                        0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ThemeService.instance.primaryColor.withOpacity(
                          0.3,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.streakInfoTip,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ThemeService.instance.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppLocalizations.of(context)!.gotIt,
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

  /// Build an information section for the streak info dialog
  /// Construir una sección de información para el diálogo de información de racha
  Widget _buildInfoSection({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String example,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.textColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: ThemeService.instance.textColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                example,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ThemeService.instance.subtitleColor,
                  fontStyle: FontStyle.italic,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a stat row for the streak dialog
  /// Construir una fila de estadísticas para el diálogo de racha
  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: ThemeService.instance.subtitleColor,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Banner de límites para usuarios regulares
  Widget _buildLimitsBanner() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getLimitsInfo(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) return const SizedBox.shrink();
        
        final remaining = data['remaining'] as int;
        final isPremium = data['isPremium'] as bool;
        final canWatchAd = data['canWatchAd'] as bool;
        
        if (isPremium) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: remaining > 2 
                ? [Colors.blue.shade400, Colors.purple.shade400]
                : [Colors.orange.shade400, Colors.red.shade400],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (remaining > 2 ? Colors.blue : Colors.orange).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  remaining > 0 ? Icons.favorite : Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      remaining > 0 
                        ? AppLocalizations.of(context)!.scansRemainingToday(remaining)
                        : AppLocalizations.of(context)!.limitReached,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      remaining > 0
                        ? (canWatchAd 
                          ? AppLocalizations.of(context)!.watchAdForMore
                          : AppLocalizations.of(context)!.upgradeForUnlimited)
                        : AppLocalizations.of(context)!.watchAdOrUpgrade,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (remaining == 0 || canWatchAd)
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ).animate().slideX(begin: 0.3).fadeIn();
      },
    );
  }

  Future<Map<String, dynamic>> _getLimitsInfo() async {
    final remaining = await MonetizationService.instance.getRemainingScansTodayForFree();
    final isPremium = await MonetizationService.instance.isPremiumAsync();
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    
    return {
      'remaining': remaining,
      'isPremium': isPremium,
      'canWatchAd': canWatchAd,
    };
  }

}
