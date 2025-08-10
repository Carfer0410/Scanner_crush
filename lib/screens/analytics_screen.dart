import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/analytics_service.dart';
import '../services/monetization_service.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    if (!MonetizationService.instance.isPremium) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Premium subscription required';
      });
      return;
    }

    try {
      final stats = await AnalyticsService.instance.getCompatibilityStats();
      final insights = await AnalyticsService.instance.getPersonalInsights();
      final predictions = await AnalyticsService.instance.getLovePredictions();

      setState(() {
        _stats = stats;
        _insights = insights;
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
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
                      '📊 Love Analytics',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.pink],
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
                    ),
                  ],
                ),
              ),

              if (!MonetizationService.instance.isPremium)
                _buildPremiumRequired()
              else if (_isLoading)
                _buildLoadingScreen()
              else if (_errorMessage != null)
                _buildErrorScreen()
              else
                _buildAnalyticsContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRequired() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.pink],
                  ),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 60,
                ),
              ).animate().scale(delay: 200.ms),

              const SizedBox(height: 30),

              Text(
                '🔒 Analytics Premium',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              Text(
                'Desbloquea insights profundos sobre tu vida amorosa con analytics avanzados, predicciones y patrones de compatibilidad.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ThemeService.instance.subtitleColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40),

              GradientButton(
                text: 'Upgrade a Premium',
                icon: Icons.diamond,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                },
              ).animate().scale(delay: 800.ms),
            ],
          ),
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
              'Analizando tu vida amorosa...',
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
              'Error cargando analytics',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeService.instance.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'Error desconocido',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAnalytics,
              child: Text('Reintentar'),
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
              tabs: const [
                Tab(text: 'Estadísticas'),
                Tab(text: 'Insights'),
                Tab(text: 'Predicciones'),
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
                  'Total Escaneos',
                  _stats!.totalScans.toString(),
                  Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '📊',
                  'Promedio',
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
                  'Mejor Match',
                  '${_stats!.highestCompatibility}%',
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '⭐',
                  'Celebridades',
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

          // Top matches
          _buildTopMatches(),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    if (_insights == null) return const SizedBox();

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
    if (_predictions == null) return const SizedBox();

    return ListView.builder(
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
            'No hay suficientes datos para mostrar tendencias',
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
            '📈 Tendencia de Compatibilidad (30 días)',
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
            'Últimos 30 días',
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
            '🏆 Tus Mejores Matches',
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
                        result.isCelebrity ? 'Celebrity' : 'Personal',
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
