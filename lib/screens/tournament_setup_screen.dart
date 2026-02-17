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
import 'premium_screen.dart';

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
  String? _celebrityGenderPreference;
  bool _tournament16AdUnlocked = false;

  @override
  void initState() {
    super.initState();
    _initParticipantControllers(4);
    _loadBannerAd();
    _checkPremium();
    _checkTournament16AdUnlock();
    AdMobService.instance.trackUserAction();
  }

  void _checkPremium() async {
    _isPremium = await MonetizationService.instance.isPremiumAsync();
    if (mounted) setState(() {});
  }

  void _checkTournament16AdUnlock() async {
    _tournament16AdUnlocked =
        await MonetizationService.instance.hasTournament16AdUnlockToday();
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
    if (format == TournamentFormat.sixteen && !_isPremium && !_tournament16AdUnlocked) {
      // Show option: watch ad (1x/day) or go premium
      _showTournament16UnlockDialog();
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

  void _showTournament16UnlockDialog() {
    final loc = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '🏆 ${isEn ? "16-Player Tournament" : "Torneo de 16"}',
          style: TextStyle(color: ThemeService.instance.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEn
                  ? 'Unlock today\'s 16-player tournament by watching an ad, or go Premium for unlimited access!'
                  : '¡Desbloquea el torneo de 16 hoy viendo un anuncio, o hazte Premium para acceso ilimitado!',
              style: TextStyle(color: ThemeService.instance.textColor),
            ),
            const SizedBox(height: 20),
            // Watch ad button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success =
                      await MonetizationService.instance.watchAdForTournament16();
                  if (success && mounted) {
                    setState(() {
                      _tournament16AdUnlocked = true;
                      _selectedFormat = TournamentFormat.sixteen;
                      final existing =
                          _participantControllers.map((c) => c.text).toList();
                      _initParticipantControllers(16);
                      for (int i = 0; i < existing.length && i < 16; i++) {
                        _participantControllers[i].text = existing[i];
                      }
                    });
                    AudioService.instance.playTransition();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEn
                            ? '🌟 16-player tournament unlocked for today!'
                            : '🌟 ¡Torneo de 16 desbloqueado por hoy!'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loc.adNotAvailable),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: Text(
                  isEn ? 'Watch ad (free today)' : 'Ver anuncio (gratis hoy)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Go premium button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PremiumScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.stars),
                label: Text(
                  isEn ? 'Go Premium (unlimited)' : 'Hazte Premium (ilimitado)',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeService.instance.primaryColor,
                  side: BorderSide(color: ThemeService.instance.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
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
    // Use CrushService with optional gender preference
    var celebrities = CrushService.instance.getCelebrityNames(gender: _celebrityGenderPreference);
    if (celebrities.isEmpty) {
      celebrities = CrushService.instance.getCelebrityNames();
    }
    celebrities.shuffle();
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
    var celebrities = CrushService.instance.getCelebrityNames(gender: _celebrityGenderPreference);
    if (celebrities.isEmpty) {
      celebrities = CrushService.instance.getCelebrityNames();
    }
    celebrities.shuffle();
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

  // ── Helpers for adaptive contrast ──────────────────────────────────────
  Color get _fg => ThemeService.instance.textColor;
  Color get _fgSub => ThemeService.instance.subtitleColor;
  Color get _card => ThemeService.instance.cardColor;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new, color: _fg),
                    ),
                    Expanded(
                      child: Text(
                        loc.tournamentTitle,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _fg,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // ── Scrollable content ───────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Hero header ─────────────────────────────────
                      const SizedBox(height: 4),
                      Center(
                        child: Column(
                          children: [
                            const Text('🏆', style: TextStyle(fontSize: 48))
                                .animate()
                                .scale(duration: 600.ms, curve: Curves.elasticOut),
                            const SizedBox(height: 6),
                            Text(
                              loc.tournamentDescription,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: _fgSub,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── SECTION 1: Tu nombre ───────────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(loc.tournamentYourName, Icons.person),
                            const SizedBox(height: 10),
                            _buildTextField(
                              controller: _userNameController,
                              hint: loc.tournamentYourNameHint,
                              icon: Icons.person_outline,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── SECTION 2: Formato ─────────────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(loc.tournamentSelectFormat, Icons.grid_view_rounded),
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── SECTION 3: Participantes ───────────────────
                      _sectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel(loc.tournamentParticipants, Icons.favorite),
                            const SizedBox(height: 10),

                            // Action chips row (fill, add, clear)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildActionChip(
                                  label: loc.tournamentAddCelebrity,
                                  icon: Icons.star_rounded,
                                  onTap: _addRandomCelebrity,
                                ),
                                _buildActionChip(
                                  label: loc.tournamentFillAll,
                                  icon: Icons.auto_awesome,
                                  onTap: _fillAllWithCelebrities,
                                ),
                                _buildActionChip(
                                  label: isEn ? 'Clear' : 'Borrar',
                                  icon: Icons.delete_outline,
                                  onTap: () {
                                    setState(() {
                                      for (final c in _participantControllers) {
                                        c.clear();
                                      }
                                    });
                                    AudioService.instance.playTransition();
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Gender preference (compact row inside card)
                            Row(
                              children: [
                                Icon(Icons.wc, size: 16, color: _fgSub),
                                const SizedBox(width: 6),
                                Text(
                                  isEn ? 'Celebrity pref:' : 'Preferencia:',
                                  style: GoogleFonts.poppins(fontSize: 12, color: _fgSub),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: ThemeService.instance.surfaceColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: ThemeService.instance.borderColor),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String?>(
                                        value: _celebrityGenderPreference,
                                        isExpanded: true,
                                        dropdownColor: _card,
                                        style: GoogleFonts.poppins(fontSize: 13, color: _fg),
                                        icon: Icon(Icons.arrow_drop_down, color: _fg),
                                        items: [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text(
                                              isEn ? 'No preference' : 'Sin preferencia',
                                              style: GoogleFonts.poppins(fontSize: 13, color: _fg),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'female',
                                            child: Text(
                                              isEn ? 'Female' : 'Femenino',
                                              style: GoogleFonts.poppins(fontSize: 13, color: _fg),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: 'male',
                                            child: Text(
                                              isEn ? 'Male' : 'Masculino',
                                              style: GoogleFonts.poppins(fontSize: 13, color: _fg),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          setState(() {
                                            _celebrityGenderPreference = v;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Participant text fields
                            ...List.generate(_participantControllers.length, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildTextField(
                                  controller: _participantControllers[i],
                                  hint: '${loc.tournamentCrush} ${i + 1}',
                                  icon: Icons.favorite_border,
                                  index: i + 1,
                                ).animate().fadeIn(delay: (300 + i * 60).ms),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Start button ────────────────────────────────
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

  // ── Reusable section card wrapper ─────────────────────────────────────
  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeService.instance.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ── Section label with icon ───────────────────────────────────────────
  Widget _sectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _fg),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _fg,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatChip(
    TournamentFormat format,
    String label,
    String emoji, {
    bool isPremium = false,
  }) {
    final isSelected = _selectedFormat == format;
    final isLocked = isPremium && !_isPremium && !_tournament16AdUnlocked;

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
                : Border.all(color: ThemeService.instance.borderColor),
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
        color: ThemeService.instance.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeService.instance.borderColor),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: _fg, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: _fgSub, fontSize: 14),
          prefixIcon: Icon(icon, color: _fgSub, size: 20),
          suffixText: index != null ? '#$index' : null,
          suffixStyle: GoogleFonts.poppins(
            color: _fgSub,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: ThemeService.instance.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ThemeService.instance.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: _fg),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
