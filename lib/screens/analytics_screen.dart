import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/analytics_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../screens/premium_screen.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  CompatibilityStats? _stats;
  List<PersonalInsight>? _insights;
  List<LovePrediction>? _predictions;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPremium = false;
  bool _insightsUnlockedByAd = false;
  bool _predictionsUnlockedByAd = false;
  bool _isLoadingInsights = false;
  bool _isLoadingPredictions = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _checkPremiumAndLoad();
    }
  }

  Future<void> _checkPremiumAndLoad() async {
    _isPremium = await MonetizationService.instance.isPremiumAsync();
    // Siempre cargar estadísticas (gratis para todos)
    await _loadStats();
    // Track que el usuario abrió analytics
    AdMobService.instance.trackUserAction();
    // Insights y predictions solo se cargan si es premium
    if (_isPremium) {
      await _loadInsightsAndPredictions();
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await AnalyticsService.instance.getCompatibilityStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadInsightsAndPredictions() async {
    try {
      final loc = AppLocalizations.of(context)!;
      final results = await Future.wait([
        AnalyticsService.instance.getPersonalInsights(loc, bypassPremiumCheck: true),
        AnalyticsService.instance.getLovePredictions(loc, bypassPremiumCheck: true),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout loading analytics.');
        },
      );
      if (mounted) {
        setState(() {
          _insights = results[0] as List<PersonalInsight>;
          _predictions = results[1] as List<LovePrediction>;
        });
      }
    } catch (e) {
      // Non-critical: insights/predictions failed but stats still work
    }
  }

  /// Ver anuncio para desbloquear insights temporalmente
  Future<void> _unlockInsightsByAd() async {
    setState(() { _isLoadingInsights = true; });
    final shown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        if (mounted) {
          setState(() { _insightsUnlockedByAd = true; });
          await _loadInsightsAndPredictions();
        }
      },
    );
    if (mounted) {
      setState(() { _isLoadingInsights = false; });
      if (!shown) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.adNotAvailable ?? 'Ad not available right now'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Ver anuncio para desbloquear predictions temporalmente
  Future<void> _unlockPredictionsByAd() async {
    setState(() { _isLoadingPredictions = true; });
    final shown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        if (mounted) {
          setState(() { _predictionsUnlockedByAd = true; });
          await _loadInsightsAndPredictions();
        }
      },
    );
    if (mounted) {
      setState(() { _isLoadingPredictions = false; });
      if (!shown) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.adNotAvailable ?? 'Ad not available right now'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _tabController.dispose();
    super.dispose();
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
                          AppLocalizations.of(context)?.loveAnalytics ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    if (_isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ThemeService.instance.primaryColor, ThemeService.instance.secondaryColor],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              FutureBuilder<bool>(
                future: MonetizationService.instance.isPremiumAsync(),
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return _buildLoadingScreen();
                  } else if (_errorMessage != null) {
                    return _buildErrorScreen();
                  } else {
                    return _buildAnalyticsContent();
                  }
                },
              ),

              // Banner ad para usuarios no premium
              if (_bannerAd != null && _isBannerAdReady && !_isPremium)
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
    );
  }

  /// Widget reutilizable para prompt de desbloqueo por anuncio
  Widget _buildAdUnlockPrompt({
    required IconData icon,
    required String description,
    required String buttonText,
    required bool isLoading,
    required VoidCallback onWatchAd,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    ThemeService.instance.primaryColor.withOpacity(0.8),
                    ThemeService.instance.secondaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 48),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 24),

            Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: ThemeService.instance.subtitleColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            // Botón ver anuncio
            isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(ThemeService.instance.primaryColor),
                  )
                : GradientButton(
                    text: buttonText,
                    icon: Icons.play_circle_outline,
                    onPressed: onWatchAd,
                  ).animate().scale(delay: 600.ms),

            const SizedBox(height: 16),

            // Enlace a premium
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumScreen()),
                );
              },
              child: Text(
                AppLocalizations.of(context)?.orGetPremium ?? 'o hazte Premium',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ThemeService.instance.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ThemeService.instance.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)?.analyzingLoveLife ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ThemeService.instance.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)?.errorLoadingAnalytics ?? '',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? (AppLocalizations.of(context)?.unknownErrorAnalytics ?? 'Error desconocido'),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() { _isLoading = true; _errorMessage = null; });
                _checkPremiumAndLoad();
              },
              child: Text(AppLocalizations.of(context)?.retry ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    return Expanded(
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: ThemeService.instance.cardColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: ThemeService.instance.primaryGradient,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: ThemeService.instance.subtitleColor,
              tabs: [
                    Tab(text: AppLocalizations.of(context)?.statisticsTab ?? ''),
                    Tab(text: AppLocalizations.of(context)?.insightsTab ?? ''),
                    Tab(text: AppLocalizations.of(context)?.predictionsTab ?? ''),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(),
                _buildInsightsTab(),
                _buildPredictionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    if (_stats == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '💕',
                      AppLocalizations.of(context)?.totalScansAnalytics ?? '',
                  _stats!.totalScans.toString(),
                  Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '📊',
                      AppLocalizations.of(context)?.averageAnalytics ?? '',
                  '${_stats!.averageCompatibility.toInt()}%',
                  Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '🔥',
                      AppLocalizations.of(context)?.bestMatch ?? '',
                  '${_stats!.highestCompatibility}%',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '⭐',
                      AppLocalizations.of(context)?.celebritiesAnalytics ?? '',
                  _stats!.celebrityScans.toString(),
                  Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Compatibility trend chart
          _buildTrendChart(),

          const SizedBox(height: 24),

          // Top matches - solo mostrar si hay datos
          if (_stats!.topMatches.isNotEmpty) _buildTopMatches(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    // Si no es premium y no ha desbloqueado por anuncio, mostrar prompt
    if (!_isPremium && !_insightsUnlockedByAd) {
      return _buildAdUnlockPrompt(
        icon: Icons.insights,
        description: AppLocalizations.of(context)?.insightsLockedDescription ??
            'Descubre patrones únicos sobre tu vida amorosa. Mira un breve anuncio o hazte Premium.',
        buttonText: AppLocalizations.of(context)?.watchAdToUnlockInsights ?? 'Ver anuncio para desbloquear',
        isLoading: _isLoadingInsights,
        onWatchAd: _unlockInsightsByAd,
      );
    }

    // Loading después de ver anuncio
    if (_isLoadingInsights && (_insights == null || _insights!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeService.instance.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.analyzingLoveLife ?? '',
              style: GoogleFonts.poppins(fontSize: 14, color: ThemeService.instance.subtitleColor),
            ),
          ],
        ),
      );
    }

    if (_insights == null || _insights!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights,
              size: 64,
              color: ThemeService.instance.subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noInsightsYet ?? 'No hay insights todavía',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.scanMoreForInsights ?? 'Realiza más escaneos para obtener insights personalizados',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _insights!.length,
      itemBuilder: (context, index) {
        final insight = _insights![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _getInsightGradient(insight.type),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getInsightColor(insight.type).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    insight.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      insight.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight.description,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: Duration(milliseconds: 200 * index))
          .slideX(begin: 0.3, duration: 500.ms);
      },
    );
  }

  Widget _buildPredictionsTab() {
    // Si no es premium y no ha desbloqueado por anuncio, mostrar prompt
    if (!_isPremium && !_predictionsUnlockedByAd) {
      return _buildAdUnlockPrompt(
        icon: Icons.auto_awesome,
        description: AppLocalizations.of(context)?.predictionsLockedDescription ??
            'Obtén predicciones personalizadas sobre tu futuro amoroso. Mira un breve anuncio o hazte Premium.',
        buttonText: AppLocalizations.of(context)?.watchAdToUnlockPredictions ?? 'Ver anuncio para desbloquear',
        isLoading: _isLoadingPredictions,
        onWatchAd: _unlockPredictionsByAd,
      );
    }

    // Loading después de ver anuncio
    if (_isLoadingPredictions && (_predictions == null || _predictions!.isEmpty)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeService.instance.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.analyzingLoveLife ?? '',
              style: GoogleFonts.poppins(fontSize: 14, color: ThemeService.instance.subtitleColor),
            ),
          ],
        ),
      );
    }

    if (_predictions == null || _predictions!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 64,
              color: ThemeService.instance.subtitleColor,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.noPredictionsYet ?? 'No hay predicciones disponibles',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)?.scanMoreForPredictions ?? 'Realiza más escaneos para generar predicciones sobre tu vida amorosa',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: ThemeService.instance.subtitleColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.predictionInfoExplanation ??
                  'El porcentaje en la frase es tu compatibilidad promedio real. El número en la esquina es la confianza de la predicción.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ThemeService.instance.subtitleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _predictions!.length,
            itemBuilder: (context, index) {
              final prediction = _predictions![index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.withOpacity(0.8),
                      Colors.purple.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          prediction.icon,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                prediction.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                prediction.timeframe,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${prediction.confidence}%',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      prediction.description,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: Duration(milliseconds: 300 * index))
                .slideY(begin: 0.3, duration: 600.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().scale(delay: 400.ms);
  }

  Widget _buildTrendChart() {
    if (_stats!.trendData.isEmpty) {
      return Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeService.instance.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            AppLocalizations.of(context)?.notEnoughDataTrends ?? 'No hay suficientes datos para mostrar tendencias',
            style: GoogleFonts.poppins(
              color: ThemeService.instance.subtitleColor,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.instance.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeService.instance.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.compatibilityTrend ?? '📈 Tendencia de Compatibilidad (30 días)',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _stats!.trendData.asMap().entries.map((entry) {
                final index = entry.key;
                final point = entry.value;
                final height = (point.average / 100) * 120; // Max height 120
                
                return Flexible(
                  child: Container(
                    width: 4,
                    height: height.clamp(5.0, 120.0),
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          ThemeService.instance.primaryColor,
                          ThemeService.instance.primaryColor.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate(delay: Duration(milliseconds: index * 50))
                    .slideY(begin: 1, duration: 800.ms)
                    .fadeIn(),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)?.last30Days ?? 'Últimos 30 días',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ThemeService.instance.subtitleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMatches() {
    if (_stats!.topMatches.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.instance.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ThemeService.instance.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)?.yourBestMatches ?? '🏆 Tus Mejores Matches',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...(_stats!.topMatches.take(5).map((result) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getPercentageColor(result.percentage),
                        _getPercentageColor(result.percentage).withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${result.percentage}%',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.crushName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      Text(
                        result.isCelebrity ? (AppLocalizations.of(context)?.celebrity ?? 'Celebrity') : (AppLocalizations.of(context)?.personal ?? 'Personal'),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: ThemeService.instance.subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  result.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ))),
        ],
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 40) return Colors.amber;
    return Colors.red;
  }

  LinearGradient _getInsightGradient(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return LinearGradient(colors: [Colors.green, Colors.teal]);
      case InsightType.achievement:
        return LinearGradient(colors: [Colors.amber, Colors.orange]);
      case InsightType.fun:
        return LinearGradient(colors: [Colors.purple, Colors.pink]);
      case InsightType.motivational:
        return LinearGradient(colors: [Colors.blue, Colors.indigo]);
      default:
        return LinearGradient(colors: [Colors.grey, Colors.blueGrey]);
    }
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return Colors.green;
      case InsightType.achievement:
        return Colors.amber;
      case InsightType.fun:
        return Colors.purple;
      case InsightType.motivational:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
