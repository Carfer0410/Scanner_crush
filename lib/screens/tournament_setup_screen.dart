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
import '../services/analytics_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
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
  TournamentPassState? _passState;
  bool _loadingPass = true;
  bool _unlockingEntryAd = false;
  List<WeeklyMission> _weeklyMissions = <WeeklyMission>[];
  bool _loadingMissions = true;

  @override
  void initState() {
    super.initState();
    _initParticipantControllers(4);
    _loadBannerAd();
    _checkPremium();
    _checkTournament16AdUnlock();
    _refreshTournamentPass();
    _refreshWeeklyMissions();
    AdMobService.instance.trackUserAction();
    AnalyticsService.instance.trackEvent('tournament_setup_opened');
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

  Future<void> _refreshTournamentPass() async {
    final state = await TournamentService.instance.getPassState();
    if (!mounted) return;
    setState(() {
      _passState = state;
      _loadingPass = false;
    });
  }

  Future<void> _refreshWeeklyMissions() async {
    final missions = await TournamentService.instance.getWeeklyMissions();
    if (!mounted) return;
    setState(() {
      _weeklyMissions = missions;
      _loadingMissions = false;
    });
  }

  Future<void> _unlockEntryWithAd() async {
    if (_unlockingEntryAd) return;
    setState(() => _unlockingEntryAd = true);

    final ok = await TournamentService.instance.watchAdForExtraTournamentEntry();
    if (!mounted) return;

    setState(() => _unlockingEntryAd = false);
    await _refreshTournamentPass();
    await _refreshWeeklyMissions();
    if (!mounted) return;

    await AnalyticsService.instance.trackEvent(
      'tournament_ticket_ad_attempt',
      params: {'success': ok},
    );
    if (!mounted) return;

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (isEn ? 'Ticket unlocked! You can start a new tournament.' : '¡Ticket desbloqueado! Ya puedes iniciar otro torneo.')
            : (isEn ? 'No ad available right now. Try again later.' : 'No hay anuncio disponible ahora. Intenta más tarde.')),
        backgroundColor: ok ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
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

  Future<void> _startTournament() async {
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

    final canStart = await TournamentService.instance.canStartTournament();
    if (!canStart) {
      await AnalyticsService.instance.trackEvent('tournament_start_blocked_no_tickets');
      _showNoEntriesDialog();
      return;
    }

    final consumed = await TournamentService.instance.consumeTournamentEntry();
    if (!consumed) {
      await AnalyticsService.instance.trackEvent('tournament_start_consume_failed');
      _showNoEntriesDialog();
      return;
    }

    await _refreshTournamentPass();

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
    await AnalyticsService.instance.trackEvent(
      'tournament_started',
      params: {
        'format': _selectedFormat.name,
        'participants': participants.length,
      },
    );

    // Navigate to bracket screen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TournamentBracketScreen(tournament: tournament),
      ),
    ).then((_) {
      _refreshTournamentPass();
      _refreshWeeklyMissions();
    });
  }

  void _showNoEntriesDialog() {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final state = _passState;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEn ? 'No tournament tickets left today' : 'Sin tickets de torneo por hoy',
          style: TextStyle(color: ThemeService.instance.textColor),
        ),
        content: Text(
          isEn
              ? 'Watch a rewarded ad to unlock +1 ticket, or upgrade to Premium for unlimited tournaments.'
              : 'Mira un anuncio con recompensa para desbloquear +1 ticket, o hazte Premium para torneos ilimitados.',
          style: TextStyle(color: ThemeService.instance.subtitleColor),
        ),
        actions: [
          if ((state?.adTicketsRemainingToday ?? 0) > 0)
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _unlockEntryWithAd();
              },
              child: Text(isEn ? 'Watch ad (+1)' : 'Ver anuncio (+1)'),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: Text(isEn ? 'Go Premium' : 'Hazte Premium'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Close' : 'Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _openCoinShop() async {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    await AnalyticsService.instance.trackEvent('tournament_shop_opened');
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: ThemeService.instance.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        Future<void> buyOne() async {
          final res = await TournamentService.instance.buyTournamentTicketsWithCoins(quantity: 1);
          await _refreshTournamentPass();
          await AnalyticsService.instance.trackEvent(
            'tournament_shop_buy_1',
            params: {'success': res == CoinSpendResult.success},
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res == CoinSpendResult.success
                    ? (isEn ? 'Purchased +1 ticket.' : 'Compraste +1 ticket.')
                    : (isEn ? 'Not enough coins.' : 'No tienes suficientes coins.'),
              ),
              backgroundColor: res == CoinSpendResult.success ? Colors.green : Colors.orange,
            ),
          );
        }

        Future<void> buyBundle() async {
          final res = await TournamentService.instance.buyTournamentTicketBundle3();
          await _refreshTournamentPass();
          await AnalyticsService.instance.trackEvent(
            'tournament_shop_buy_bundle3',
            params: {'success': res == CoinSpendResult.success},
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res == CoinSpendResult.success
                    ? (isEn ? 'Bundle purchased (+3 tickets).' : 'Bundle comprado (+3 tickets).')
                    : (isEn ? 'Not enough coins.' : 'No tienes suficientes coins.'),
              ),
              backgroundColor: res == CoinSpendResult.success ? Colors.green : Colors.orange,
            ),
          );
        }

        final coins = _passState?.coins ?? 0;
        final bundleCost = TournamentService.instance.ticketCoinCost * 3 - 8;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEn ? 'Love Coin Shop' : 'Tienda Love Coin',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '🪙 $coins',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ThemeService.instance.primaryColor,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEn ? '+1 Tournament Ticket' : '+1 Ticket de Torneo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.textColor,
                  ),
                ),
                subtitle: Text(
                  '${TournamentService.instance.ticketCoinCost} coins',
                  style: GoogleFonts.poppins(
                    color: ThemeService.instance.subtitleColor,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: buyOne,
                  child: Text(isEn ? 'Buy' : 'Comprar'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isEn ? '+3 Tournament Tickets' : '+3 Tickets de Torneo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.instance.textColor,
                  ),
                ),
                subtitle: Text(
                  '$bundleCost coins',
                  style: GoogleFonts.poppins(
                    color: ThemeService.instance.subtitleColor,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: buyBundle,
                  child: Text(isEn ? 'Buy Pack' : 'Comprar Pack'),
                ),
              ),
            ],
          ),
        );
      },
    );

    await _refreshWeeklyMissions();
  }

  Future<void> _claimMission(WeeklyMission mission) async {
    final reward = await TournamentService.instance.claimWeeklyMission(mission.id);
    await _refreshTournamentPass();
    await _refreshWeeklyMissions();

    await AnalyticsService.instance.trackEvent(
      'weekly_mission_claimed',
      params: {'id': mission.id, 'reward': reward},
    );

    if (!mounted) return;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reward > 0
              ? (isEn ? 'Mission claimed! +$reward coins.' : '¡Misión reclamada! +$reward coins.')
              : (isEn ? 'Mission not ready.' : 'La misión no está lista.'),
        ),
        backgroundColor: reward > 0 ? Colors.green : Colors.orange,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: _card.withOpacity(0.74),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: ThemeService.instance.borderColor.withOpacity(0.9),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back_ios_new, color: _fg, size: 20),
                      ),
                      Expanded(
                        child: Text(
                          loc.tournamentTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: _fg,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 42),
                    ],
                  ),
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

                      const SizedBox(height: 14),

                      _sectionCard(
                        child: _loadingPass
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDailyPassCard(isEn),
                      ),
                      const SizedBox(height: 14),
                      _sectionCard(
                        child: _loadingMissions
                            ? const Center(child: CircularProgressIndicator())
                            : _buildWeeklyMissionsCard(isEn),
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
        gradient: LinearGradient(
          colors: [
            _card.withOpacity(0.95),
            ThemeService.instance.surfaceColor.withOpacity(0.84),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeService.instance.borderColor.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
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

  Widget _buildDailyPassCard(bool isEn) {
    final state = _passState;
    if (state == null) return const SizedBox.shrink();

    final remainingText = state.isPremium
        ? (isEn ? 'Unlimited' : 'Ilimitado')
        : '${state.remainingEntriesToday}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: ThemeService.instance.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              isEn ? 'Daily Tournament Pass' : 'Pase Diario del Torneo',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _fg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _miniStatChip('🎟️', isEn ? 'Tickets left' : 'Tickets hoy', remainingText),
            _miniStatChip('🪙', isEn ? 'Love Coins' : 'Love Coins', '${state.coins}'),
            _miniStatChip('🔥', isEn ? 'Streak' : 'Racha', '${state.streakDays}'),
          ],
        ),
        if (!state.isPremium) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  isEn
                      ? 'Ad tickets available today: ${state.adTicketsRemainingToday}'
                      : 'Tickets por anuncio disponibles hoy: ${state.adTicketsRemainingToday}',
                  style: GoogleFonts.poppins(fontSize: 12, color: _fgSub),
                ),
              ),
              if (state.adTicketsRemainingToday > 0)
                TextButton.icon(
                  onPressed: _unlockingEntryAd ? null : _unlockEntryWithAd,
                  icon: _unlockingEntryAd
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_fill, size: 16),
                  label: Text(isEn ? 'Get +1' : 'Ganar +1'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _openCoinShop,
              icon: const Icon(Icons.storefront, size: 16),
              label: Text(isEn ? 'Coin Shop' : 'Tienda'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeeklyMissionsCard(bool isEn) {
    if (_weeklyMissions.isEmpty) {
      return Text(
        isEn ? 'No weekly missions yet.' : 'Aún no hay misiones semanales.',
        style: GoogleFonts.poppins(fontSize: 12, color: _fgSub),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEn ? 'Weekly Missions' : 'Misiones Semanales',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _fg,
          ),
        ),
        const SizedBox(height: 10),
        ..._weeklyMissions.map((mission) {
          final title = isEn ? mission.titleEn : mission.titleEs;
          final canClaim = mission.completed && !mission.claimed;
          final progress = (mission.progress / mission.target).clamp(0.0, 1.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeService.instance.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeService.instance.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _fg,
                        ),
                      ),
                    ),
                    Text('🪙 ${mission.rewardCoins}'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress, minHeight: 6),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${mission.progress}/${mission.target}',
                      style: GoogleFonts.poppins(fontSize: 12, color: _fgSub),
                    ),
                    const Spacer(),
                    if (mission.claimed)
                      Text(
                        isEn ? 'Claimed' : 'Reclamada',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.green),
                      )
                    else if (canClaim)
                      TextButton(
                        onPressed: () => _claimMission(mission),
                        child: Text(isEn ? 'Claim' : 'Reclamar'),
                      ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _miniStatChip(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeService.instance.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.instance.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}

