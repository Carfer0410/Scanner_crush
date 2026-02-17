import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/crush_service.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import '../services/admob_service.dart';
import '../services/monetization_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'tournament_bracket_screen.dart';

class TournamentSetupScreen extends StatefulWidget {
  const TournamentSetupScreen({super.key});

  @override
  State<TournamentSetupScreen> createState() => _TournamentSetupScreenState();
}

class _TournamentSetupScreenState extends State<TournamentSetupScreen>
    with TickerProviderStateMixin {
  TournamentFormat _selectedFormat = TournamentFormat.four;
  final _userNameController = TextEditingController();
  final List<TextEditingController> _participantControllers = [];
  final _scrollController = ScrollController();
  BannerAd? _bannerAd;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _initParticipantControllers(4);
    _loadBannerAd();
    _checkPremium();
    AdMobService.instance.trackUserAction();
  }

  void _checkPremium() async {
    _isPremium = await MonetizationService.instance.isPremiumAsync();
    if (mounted) setState(() {});
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _initParticipantControllers(int count) {
    // Dispose old controllers
    for (final c in _participantControllers) {
      c.dispose();
    }
    _participantControllers.clear();
    for (int i = 0; i < count; i++) {
      _participantControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    for (final c in _participantControllers) {
      c.dispose();
    }
    _scrollController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _onFormatChanged(TournamentFormat format) {
    if (format == TournamentFormat.sixteen && !_isPremium) {
      // Show premium required
      _showPremiumRequired();
      return;
    }
    setState(() {
      _selectedFormat = format;
      final count = format == TournamentFormat.four
          ? 4
          : format == TournamentFormat.eight
              ? 8
              : 16;
      // Preserve existing entries
      final existing = _participantControllers.map((c) => c.text).toList();
      _initParticipantControllers(count);
      for (int i = 0; i < existing.length && i < count; i++) {
        _participantControllers[i].text = existing[i];
      }
    });
    AudioService.instance.playTransition();
  }

  void _showPremiumRequired() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '👑 Premium',
          style: TextStyle(color: ThemeService.instance.textColor),
        ),
        content: Text(
          loc.tournament16PremiumOnly,
          style: TextStyle(color: ThemeService.instance.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  void _addRandomCelebrity() {
    final emptyIdx = _participantControllers.indexWhere((c) => c.text.trim().isEmpty);
    if (emptyIdx == -1) return;

    final celebrities = TournamentService.instance.getRandomCelebrities(1);
    if (celebrities.isNotEmpty) {
      setState(() {
        _participantControllers[emptyIdx].text = celebrities.first;
      });
      AudioService.instance.playTransition();
    }
  }

  void _fillAllWithCelebrities() {
    final count = _participantControllers.where((c) => c.text.trim().isEmpty).length;
    if (count == 0) return;

    final celebrities = TournamentService.instance.getRandomCelebrities(count);
    int celebIdx = 0;
    setState(() {
      for (int i = 0; i < _participantControllers.length; i++) {
        if (_participantControllers[i].text.trim().isEmpty && celebIdx < celebrities.length) {
          _participantControllers[i].text = celebrities[celebIdx];
          celebIdx++;
        }
      }
    });
    AudioService.instance.playTransition();
  }

  void _startTournament() {
    final userName = _userNameController.text.trim();
    if (userName.isEmpty) {
      _showError(AppLocalizations.of(context)!.tournamentEnterYourName);
      return;
    }

    final names = _participantControllers.map((c) => c.text.trim()).toList();
    final emptyCount = names.where((n) => n.isEmpty).length;
    if (emptyCount > 0) {
      _showError(AppLocalizations.of(context)!.tournamentFillAllNames);
      return;
    }

    // Check for duplicates
    final uniqueNames = names.map((n) => n.toLowerCase()).toSet();
    if (uniqueNames.length != names.length) {
      _showError(AppLocalizations.of(context)!.tournamentNoDuplicates);
      return;
    }

    AudioService.instance.playTransition();

    // Create participants
    final participants = names.map((name) {
      return TournamentParticipant(
        name: name,
        isCelebrity: CrushService.instance.checkIsCelebrity(name),
      );
    }).toList();

    // Create tournament
    final tournament = TournamentService.instance.createTournament(
      userName: userName,
      participants: participants,
      format: _selectedFormat,
    );

    // Navigate to bracket screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentBracketScreen(tournament: tournament),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        loc.tournamentTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header description
                      Center(
                        child: Column(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 50))
                                .animate()
                                .scale(duration: 600.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 8),
                            Text(
                              loc.tournamentDescription,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: ThemeService.instance.subtitleColor,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Your Name
                      Text(
                        loc.tournamentYourName,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _userNameController,
                        hint: loc.tournamentYourNameHint,
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 24),

                      // Format Selection
                      Text(
                        loc.tournamentSelectFormat,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ThemeService.instance.textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildFormatChip(TournamentFormat.four, '4', '⚡'),
                          const SizedBox(width: 10),
                          _buildFormatChip(TournamentFormat.eight, '8', '🔥'),
                          const SizedBox(width: 10),
                          _buildFormatChip(TournamentFormat.sixteen, '16', '👑',
                              isPremium: true),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // Participants Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.tournamentParticipants,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ThemeService.instance.textColor,
                            ),
                          ),
                          Row(
                            children: [
                              _buildActionChip(
                                label: loc.tournamentAddCelebrity,
                                icon: Icons.star,
                                onTap: _addRandomCelebrity,
                              ),
                              const SizedBox(width: 8),
                              _buildActionChip(
                                label: loc.tournamentFillAll,
                                icon: Icons.auto_awesome,
                                onTap: _fillAllWithCelebrities,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Participant fields
                      ...List.generate(_participantControllers.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTextField(
                            controller: _participantControllers[i],
                            hint: '${loc.tournamentCrush} ${i + 1}',
                            icon: Icons.favorite,
                            index: i + 1,
                          ).animate().fadeIn(delay: (400 + i * 80).ms),
                        );
                      }),

                      const SizedBox(height: 24),

                      // Start Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _startTournament,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeService.instance.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor:
                                ThemeService.instance.primaryColor.withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏆', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 10),
                              Text(
                                loc.tournamentStart,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().scale(delay: 600.ms, duration: 500.ms),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Banner Ad
              if (_bannerAd != null)
                FutureBuilder<bool>(
                  future: MonetizationService.instance.isPremiumAsync(),
                  builder: (context, snapshot) {
                    final isPremium = snapshot.data ?? false;
                    if (!isPremium) {
                      return Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
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
    );
  }

  Widget _buildFormatChip(
    TournamentFormat format,
    String label,
    String emoji, {
    bool isPremium = false,
  }) {
    final isSelected = _selectedFormat == format;
    final isLocked = isPremium && !_isPremium;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onFormatChanged(format),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: [
                    ThemeService.instance.primaryColor,
                    ThemeService.instance.secondaryColor,
                  ])
                : null,
            color: isSelected ? null : ThemeService.instance.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? null
                : Border.all(
                    color: ThemeService.instance.subtitleColor.withOpacity(0.3)),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color:
                          ThemeService.instance.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : ThemeService.instance.textColor,
                ),
              ),
              if (isLocked)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PRO',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int? index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeService.instance.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: ThemeService.instance.textColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: ThemeService.instance.subtitleColor,
          ),
          prefixIcon: Icon(
            icon,
            color: ThemeService.instance.primaryColor.withOpacity(0.7),
          ),
          suffixText: index != null ? '#$index' : null,
          suffixStyle: GoogleFonts.poppins(
            color: ThemeService.instance.subtitleColor,
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: ThemeService.instance.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: ThemeService.instance.primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ThemeService.instance.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
