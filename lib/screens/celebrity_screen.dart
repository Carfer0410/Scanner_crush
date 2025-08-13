import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/crush_service.dart';
import '../services/streak_service.dart';
import '../services/locale_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'result_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _filteredCelebrities = CrushService.instance.celebrities;
    
    // Cargar banner solo para usuarios no premium
    if (!MonetizationService.instance.isPremium) {
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
        _filteredCelebrities =
            CrushService.instance.celebrities
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
      // 🔒 Registrar escaneo para monetización
      await MonetizationService.instance.recordScan();
      
      // Get localizations with null safety
      final localizations = AppLocalizations.of(context);
      
      // Generate result with proper null handling
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

      // 🔥 Update streak after successful scan
      final streakUpdate = await StreakService.instance.recordScan();
      
      // Show streak feedback message
      if (mounted && !streakUpdate.alreadyScannedToday) {
        final message = streakUpdate.getFeedbackMessage(
          LocaleService.instance.currentLocale.languageCode
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  streakUpdate.isNewRecord ? Icons.emoji_events : Icons.local_fire_department,
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
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // 🎬 Mostrar anuncio intersticial después del escaneo
      await MonetizationService.instance.showInterstitialAd();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    ResultScreen(result: result, fromScreen: 'celebrity'),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)?.errorGeneratingResult ?? 'Error generating result'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                      AppLocalizations.of(context)?.celebrityCrush ?? 'Celebrity Crush',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    Text(
                      '🌟',
                      style: const TextStyle(fontSize: 60),
                    ).animate().scale(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                    ),
                    const SizedBox(height: 20),
                    Text(
                          AppLocalizations.of(context)?.helloCelebrity(widget.userName) ?? 'Hello ${widget.userName}!',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: ThemeService.instance.textColor,
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(
                          begin: 0.3,
                          duration: const Duration(milliseconds: 600),
                        ),
                    const SizedBox(height: 10),
                    Text(
                          AppLocalizations.of(context)?.chooseCelebrityDescription ?? 'Choose your favorite celebrity to see your compatibility!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: ThemeService.instance.textColor.withOpacity(
                              0.8,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(
                          begin: 0.3,
                          duration: const Duration(milliseconds: 600),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                      controller: _searchController,
                      onChanged: _filterCelebrities,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)?.searchCelebrity ?? 'Search celebrity...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.pink,
                        ),
                        suffixIcon:
                            _isSearching
                                ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCelebrities('');
                                  },
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.pink,
                                  ),
                                )
                                : null,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(
                      begin: 0.3,
                      duration: const Duration(milliseconds: 600),
                    ),
              ),

              const SizedBox(height: 20),

              // Celebrity grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _filteredCelebrities.length,
                    itemBuilder: (context, index) {
                      final celebrity = _filteredCelebrities[index];
                      return GestureDetector(
                            onTap: () => _selectCelebrity(celebrity),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6B9D),
                                    Color(0xFFC44569),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.3),
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
                          .animate(delay: Duration(milliseconds: 50 * index))
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.8, 0.8))
                          .shimmer(
                            duration: const Duration(milliseconds: 1200),
                            color: Colors.white.withOpacity(0.3),
                          );
                    },
                  ),
                ),
              ),
              // Banner ad al final para usuarios no premium
              if (_bannerAd != null && !MonetizationService.instance.isPremium)
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: const EdgeInsets.only(top: 8),
                  child: AdWidget(ad: _bannerAd!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }
}
