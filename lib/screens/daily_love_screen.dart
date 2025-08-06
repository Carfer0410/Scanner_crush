import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/daily_love_service.dart';
import '../generated/l10n/app_localizations.dart';

class DailyLoveScreen extends StatefulWidget {
  const DailyLoveScreen({super.key});

  @override
  State<DailyLoveScreen> createState() => _DailyLoveScreenState();
}

class _DailyLoveScreenState extends State<DailyLoveScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Ensure the service is properly initialized
      await DailyLoveService.instance.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar datos: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child:
              _isLoading
                  ? _buildLoadingScreen()
                  : _errorMessage != null
                  ? _buildErrorScreen()
                  : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.preparingLoveDay,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: ThemeService.instance.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? AppLocalizations.of(context)!.unknownError,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ThemeService.instance.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final horoscope = DailyLoveService.instance.getTodayLoveHoroscopeLocalized(context);
    final personalizedTip = DailyLoveService.instance.getPersonalizedTipLocalized(context);
    final achievements = DailyLoveService.instance.getUnlockedAchievementsLocalized(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: ThemeService.instance.textColor,
                ),
              ),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.yourLoveUniverse,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),

          const SizedBox(height: 30),

          // Horóscopo del día
          _buildDailyHoroscope(horoscope),

          const SizedBox(height: 30),

          // Consejo personalizado
          _buildPersonalizedTip(personalizedTip),

          const SizedBox(height: 30),

          // Logros
          if (achievements.isNotEmpty) _buildAchievements(achievements),
        ],
      ),
    );
  }

  Widget _buildDailyHoroscope(Map<String, dynamic> horoscope) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(horoscope['color']),
            Color(horoscope['color']).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Color(horoscope['color']).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.05),
                child: Text(
                  horoscope['title'],
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          Text(
            horoscope['message'],
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    horoscope['advice'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, duration: 800.ms);
  }

  Widget _buildPersonalizedTip(String tip) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withOpacity(0.8),
                Colors.deepPurple.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.personalizedTip,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                tip,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.95),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: 400.ms, duration: 600.ms)
        .slideX(begin: -0.3, duration: 600.ms);
  }

  Widget _buildAchievements(List<Map<String, dynamic>> achievements) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.unlockedAchievements,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: ThemeService.instance.textColor,
          ),
        ),
        const SizedBox(height: 20),
        ...achievements.asMap().entries.map((entry) {
          final index = entry.key;
          final achievement = entry.value;
          return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepOrange.withOpacity(0.9),
                      Colors.red.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepOrange.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      achievement['icon'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            achievement['description'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
              .slideX(begin: 0.3, duration: 500.ms);
        }).toList(),
      ],
    );
  }
}
