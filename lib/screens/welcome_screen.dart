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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form_screen.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';
import 'celebrity_form_screen.dart';
import 'daily_love_screen.dart';
import 'analytics_screen.dart';
import 'themes_screen.dart';
import 'ads_test_screen.dart';
import '../test_grace_period_screen.dart';

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

  void _loadBannerAd() {
    // Solo cargar banner ads para usuarios no premium
    if (!MonetizationService.instance.isPremium) {
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
                              builder:
                                  (context) => Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        ThemeService.instance.primaryColor,
                                      ),
                                    ),
                                  ),
                            );
                            await DailyLoveService.instance.updateStreak();

                            // Dismiss loading
                            if (mounted) Navigator.pop(context);

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DailyLoveScreen(),
                                ),
                              );
                            }
                          } catch (e) {
                            // Dismiss loading
                            if (mounted) Navigator.pop(context);

                            // Show error dialog
                            if (mounted) {
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      backgroundColor:
                                          ThemeService.instance.cardColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        'Error',
                                        style: TextStyle(
                                          color:
                                              ThemeService.instance.textColor,
                                        ),
                                      ),
                                      content: Text(
                                        'No se pudo cargar tu día del amor: $e',
                                        style: TextStyle(
                                          color:
                                              ThemeService
                                                  .instance
                                                  .subtitleColor,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text(
                                            'OK',
                                            style: TextStyle(
                                              color:
                                                  ThemeService
                                                      .instance
                                                      .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            }
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
                                Colors.purple.withOpacity(0.8),
                                Colors.deepPurple.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
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
                                AppLocalizations.of(context)?.dailyLove ??
                                    'Tu Día',
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

                // Streak card
                _buildStreakCard(),

                // Banner para nuevos usuarios o límites
                FutureBuilder<Map<String, dynamic>>(
                  future: _getWelcomeInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    
                    final data = snapshot.data;
                    if (data == null) return const SizedBox.shrink();
                    
                    final isNewUser = data['isNewUser'] as bool;
                    final daysRemaining = data['daysRemaining'] as int;
                    
                    if (isNewUser && daysRemaining > 0) {
                      return _buildNewUserBanner();
                    }
                    return _buildLimitsBanner();
                  },
                ),

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
                                  color: ThemeService.instance.textColor,
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
                                  color: ThemeService.instance.textColor
                                      .withOpacity(0.8),
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
                            color: ThemeService.instance.textColor.withOpacity(
                              0.7,
                            ),
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
                              colors: [Colors.purple, Colors.deepPurple],
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
                              colors: [Colors.purple, Colors.deepPurple],
                              onTap: () => _navigateToCelebrityScanner(context),
                              delay: 1400,
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
                              delay: 1600,
                              isPremium: true,
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
                              delay: 1800,
                              isPremium: true,
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
                if (_bannerAd != null && _isBannerAdReady && !MonetizationService.instance.isPremium) ...[
                  Container(
                    alignment: Alignment.center,
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Grace period simulator button
          FloatingActionButton.small(
            onPressed: () async {
              await MonetizationService.instance.simulateNewUser();
              setState(() {}); // Refresh to show grace period card
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '🔧 Usuario simulado como nuevo - Card de gracia debería aparecer',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            backgroundColor: Colors.purple,
            heroTag: "grace_simulator",
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          // Ads test button
          FloatingActionButton.small(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdsTestScreen(),
                ),
              );
            },
            backgroundColor: Colors.green,
            heroTag: "ads_test",
            child: const Icon(Icons.ads_click, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          // Grace period test button
          FloatingActionButton.small(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TestGracePeriodScreen(),
                ),
              );
            },
            backgroundColor: Colors.orange,
            heroTag: "grace_test",
            child: const Icon(Icons.bug_report, color: Colors.white, size: 20),
          ),
        ],
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
    return GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 80, maxHeight: 120),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
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
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                            ),
                          ),
                          if (isPremium && !MonetizationService.instance.isPremium) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PRO',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.3, duration: 600.ms);
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
    );
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
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    // Verificar si tiene premium
    if (!MonetizationService.instance.isPremium) {
      _showPremiumRequired(context);
      return;
    }

    // 🎵 Sonido de transición
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
                        (LocaleService.instance.currentLocale.languageCode ==
                                'en')
                            ? 'Daily Streak'
                            : 'Racha Diaria',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                    Text(
                        currentStreak > 0
                            ? '🔥 $currentStreak ${_getDaysText(currentStreak)}'
                            : (LocaleService
                                    .instance
                                    .currentLocale
                                    .languageCode ==
                                'en')
                            ? 'Start your love streak today!'
                            : '¡Comienza tu racha hoy!',
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
                        (LocaleService.instance.currentLocale.languageCode ==
                                'en')
                            ? 'Best'
                            : 'Mejor',
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
                        (LocaleService.instance.currentLocale.languageCode ==
                                'en')
                            ? '🔥 Streak Stats'
                            : '🔥 Estadísticas de Racha',
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
                          (LocaleService.instance.currentLocale.languageCode ==
                                  'en')
                              ? 'Learn about stats'
                              : 'Aprende sobre las estadísticas',
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatRow(
                      (LocaleService.instance.currentLocale.languageCode ==
                              'en')
                          ? 'Current Streak'
                          : 'Racha Actual',
                      '${streakService.currentStreak} ${_getDaysText(streakService.currentStreak)}',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      (LocaleService.instance.currentLocale.languageCode ==
                              'en')
                          ? 'Best Streak'
                          : 'Mejor Racha',
                      '${streakService.bestStreak} ${_getDaysText(streakService.bestStreak)}',
                      Icons.emoji_events,
                      Colors.amber,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      (LocaleService.instance.currentLocale.languageCode ==
                              'en')
                          ? 'Total Scans'
                          : 'Escaneos Totales',
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
                      (LocaleService.instance.currentLocale.languageCode ==
                              'en')
                          ? 'Close'
                          : 'Cerrar',
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
    final isEnglish = LocaleService.instance.currentLocale.languageCode == 'en';

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
                    isEnglish
                        ? 'What do these stats mean?'
                        : '¿Qué significan estas estadísticas?',
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
                    title: isEnglish ? 'Current Streak' : 'Racha Actual',
                    description:
                        isEnglish
                            ? 'How many consecutive days you\'ve used the app without missing a day.'
                            : 'Cuántos días consecutivos has usado la app sin faltar ni un día.',
                    example:
                        isEnglish
                            ? 'Example: If you used it yesterday and today, your current streak is 2 days.'
                            : 'Ejemplo: Si la usaste ayer y hoy, tu racha actual es de 2 días.',
                  ),
                  const SizedBox(height: 20),

                  // Best Streak explanation
                  _buildInfoSection(
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                    title: isEnglish ? 'Best Streak' : 'Mejor Racha',
                    description:
                        isEnglish
                            ? 'Your personal record - the longest streak you\'ve ever achieved. It\'s always equal or greater than your current streak.'
                            : 'Tu récord personal: la racha más larga que hayas logrado jamás. Siempre es igual o mayor que tu racha actual.',
                    example:
                        isEnglish
                            ? 'Example: If your current streak is 2 days, your best streak is at least 2 days (or higher if you had a longer streak before).'
                            : 'Ejemplo: Si tu racha actual son 2 días, tu mejor racha es de al menos 2 días (o mayor si tuviste una racha más larga antes).',
                  ),
                  const SizedBox(height: 20),

                  // Total Scans explanation
                  _buildInfoSection(
                    icon: Icons.favorite,
                    color: Colors.pink,
                    title: isEnglish ? 'Total Scans' : 'Escaneos Totales',
                    description:
                        isEnglish
                            ? 'The total number of love scans you\'ve performed since you started using the app.'
                            : 'El número total de escaneos de amor que has realizado desde que empezaste a usar la app.',
                    example:
                        isEnglish
                            ? 'Example: Every time you scan your crush compatibility, this number goes up.'
                            : 'Ejemplo: Cada vez que escaneas la compatibilidad con tu crush, este número aumenta.',
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
                      isEnglish
                          ? '💡 Tip: Keep using the app daily to build your streak and discover your love compatibility!'
                          : '💡 Consejo: ¡Sigue usando la app a diario para construir tu racha y descubrir tu compatibilidad amorosa!',
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
                  isEnglish ? 'Got it!' : '¡Entendido!',
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

  /// Get days text based on current locale
  /// Obtener texto de días basado en el idioma actual
  String _getDaysText(int count) {
    final isEnglish = LocaleService.instance.currentLocale.languageCode == 'en';
    if (isEnglish) {
      return count == 1 ? 'day' : 'days';
    } else {
      return count == 1 ? 'día' : 'días';
    }
  }

  /// Banner para nuevos usuarios
  Widget _buildNewUserBanner() {
    return FutureBuilder<int>(
      future: MonetizationService.instance.getGracePeriodDaysRemaining(),
      builder: (context, snapshot) {
        final daysRemaining = snapshot.data ?? 0;
        if (daysRemaining <= 0) return const SizedBox.shrink();
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.celebration, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🎉 ',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            (LocaleService.instance.currentLocale.languageCode == 'en')
                              ? 'FREE Trial Period!'
                              : '¡Período de Prueba GRATIS!',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            daysRemaining == 1 
                              ? (LocaleService.instance.currentLocale.languageCode == 'en')
                                ? '1 DAY LEFT'
                                : '1 DÍA RESTANTE'
                              : (LocaleService.instance.currentLocale.languageCode == 'en')
                                ? '$daysRemaining DAYS LEFT'
                                : '$daysRemaining DÍAS RESTANTES',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (LocaleService.instance.currentLocale.languageCode == 'en')
                              ? 'Unlimited scans!'
                              : '¡Escaneos ilimitados!',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (LocaleService.instance.currentLocale.languageCode == 'en')
                        ? 'Enjoy unlimited love scans during your trial'
                        : 'Disfruta escaneos de amor ilimitados durante tu prueba',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: Colors.white, size: 20),
            ],
          ),
        ).animate().slideX(begin: 0.3).fadeIn().then(delay: 100.ms).shimmer(duration: 1.seconds);
      },
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
                        ? (LocaleService.instance.currentLocale.languageCode == 'en')
                          ? '$remaining scans remaining today'
                          : '$remaining escaneos restantes hoy'
                        : (LocaleService.instance.currentLocale.languageCode == 'en')
                          ? 'Limit reached!'
                          : '¡Límite alcanzado!',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      remaining > 0
                        ? (canWatchAd 
                          ? (LocaleService.instance.currentLocale.languageCode == 'en')
                            ? 'Watch ad for +2 more'
                            : 'Ver anuncio para +2 más'
                          : (LocaleService.instance.currentLocale.languageCode == 'en')
                            ? 'Upgrade for unlimited'
                            : 'Upgradea para ilimitados')
                        : (LocaleService.instance.currentLocale.languageCode == 'en')
                          ? 'Watch ad or upgrade for more'
                          : 'Ve anuncio o upgradea para más',
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

  Future<Map<String, dynamic>> _getWelcomeInfo() async {
    final isNewUser = await MonetizationService.instance.isNewUser();
    final daysRemaining = await MonetizationService.instance.getGracePeriodDaysRemaining();
    
    return {
      'isNewUser': isNewUser,
      'daysRemaining': daysRemaining,
    };
  }

  Future<Map<String, dynamic>> _getLimitsInfo() async {
    final remaining = await MonetizationService.instance.getRemainingScansTodayForFree();
    final isPremium = MonetizationService.instance.isPremium;
    final canWatchAd = await MonetizationService.instance.canWatchAdForScans();
    
    return {
      'remaining': remaining,
      'isPremium': isPremium,
      'canWatchAd': canWatchAd,
    };
  }

  void _showPremiumRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.diamond, color: ThemeService.instance.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Premium Requerido',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
          ],
        ),
        content: Text(
          'Esta función está disponible solo para usuarios Premium. ¡Actualiza ahora y desbloquea todas las funciones exclusivas!',
          style: GoogleFonts.poppins(
            color: ThemeService.instance.subtitleColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.poppins(
                color: ThemeService.instance.subtitleColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PremiumScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeService.instance.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Ver Premium',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
