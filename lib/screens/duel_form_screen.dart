import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import '../widgets/custom_widgets.dart';
import '../services/theme_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import '../services/tournament_service.dart';
import '../services/crush_service.dart';
import '../services/audio_service.dart';
import '../services/scanner_economy_service.dart';
import '../models/duel.dart';
import 'duel_battle_screen.dart';
import 'premium_screen.dart';

class DuelFormScreen extends StatefulWidget {
  const DuelFormScreen({super.key});

  @override
  State<DuelFormScreen> createState() => _DuelFormScreenState();
}

class _DuelFormScreenState extends State<DuelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _crushAController = TextEditingController();
  final _crushBController = TextEditingController();
  bool _isLoading = false;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  TournamentPassState? _passState;
  bool _loadingPass = true;
  bool _unlockingEntryAd = false;
  List<WeeklyMission> _weeklyMissions = <WeeklyMission>[];
  bool _loadingMissions = true;
  late int _funFactIndex;

  @override
  void initState() {
    super.initState();
    _funFactIndex = Random().nextInt(5);
    _loadBannerAd();
    _refreshTournamentPass();
    _refreshWeeklyMissions();
    AdMobService.instance.trackUserAction();
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() => _isBannerAdReady = true);
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _userNameController.dispose();
    _crushAController.dispose();
    _crushBController.dispose();
    super.dispose();
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

  Future<void> _claimMission(WeeklyMission mission) async {
    final reward = await TournamentService.instance.claimWeeklyMission(mission.id);
    await _refreshTournamentPass();
    await _refreshWeeklyMissions();
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _unlockEntryWithAd() async {
    if (_unlockingEntryAd) return;
    setState(() => _unlockingEntryAd = true);

    final ok = await TournamentService.instance.watchAdForExtraTournamentEntry();
    if (!mounted) return;

    setState(() => _unlockingEntryAd = false);
    await _refreshTournamentPass();
    if (!mounted) return;

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (isEn ? 'Ticket unlocked! You can start a duel.' : '¡Ticket desbloqueado! Ya puedes iniciar un duelo.')
            : (isEn ? 'No ad available right now. Try again later.' : 'No hay anuncio disponible ahora. Intenta más tarde.')),
        backgroundColor: ok ? Colors.green : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _startDuel() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }

    final crushA = _crushAController.text.trim();
    final crushB = _crushBController.text.trim();
    if (crushA.toLowerCase() == crushB.toLowerCase()) {
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.duelSameNameError),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final canStart = await TournamentService.instance.canStartTournament();
    if (!mounted) return;
    if (!canStart) {
      HapticFeedback.lightImpact();
      _showNoEntriesDialog();
      return;
    }

    final consumed = await TournamentService.instance.consumeTournamentEntry();
    if (!consumed) {
      _showNoEntriesDialog();
      return;
    }

    await _refreshTournamentPass();

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    final userName = _userNameController.text.trim();

    // Generate dimensions for both pairings
    final dimsA = CrushService.instance.generateDimensions(userName, crushA);
    final dimsB = CrushService.instance.generateDimensions(userName, crushB);
    final totalA = CrushService.instance.generateCompatibilityScore(userName, crushA);
    final totalB = CrushService.instance.generateCompatibilityScore(userName, crushB);

    final dimensionKeys = ['emotional', 'passion', 'intellectual', 'destiny'];
    final rounds = dimensionKeys.map((key) => DuelRound(
      dimensionKey: key,
      scoreA: dimsA[key]!,
      scoreB: dimsB[key]!,
    )).toList();

    // Check for 2-2 tie → add 5th tiebreaker round ("Destino Final")
    int winsA = rounds.where((r) => r.winner == 0).length;
    int winsB = rounds.where((r) => r.winner == 1).length;
    if (winsA == winsB) {
      // Tiebreaker uses the overall compatibility scores
      rounds.add(DuelRound(
        dimensionKey: 'tiebreaker',
        scoreA: totalA,
        scoreB: totalB,
      ));
    }

    final result = DuelResult(
      userName: userName,
      crushA: crushA,
      crushB: crushB,
      rounds: rounds,
      totalA: totalA,
      totalB: totalB,
    );

    // Record scan for streak
    await MonetizationService.instance.recordScan();
    await ScannerEconomyService.instance.rewardScan(isCelebrity: false);
    await ScannerEconomyService.instance.recordHighScore(
      totalA > totalB ? totalA : totalB,
    );

    AudioService.instance.playTransition();
    AdMobService.instance.trackUserAction();

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DuelBattleScreen(result: result),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
      _refreshTournamentPass();
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
          isEn ? 'No duel tickets left today' : 'Sin tickets de duelo por hoy',
          style: TextStyle(color: ThemeService.instance.textColor),
        ),
        content: Text(
          isEn
              ? 'Watch a rewarded ad to unlock +1 ticket, or upgrade to Premium for unlimited duels.'
              : 'Mira un anuncio con recompensa para desbloquear +1 ticket, o hazte Premium para duelos ilimitados.',
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
          if (!mounted) return;
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res == CoinSpendResult.success
                    ? (isEn ? 'Purchased +1 ticket.' : 'Compraste +1 ticket.')
                    : (isEn ? 'Not enough coins.' : 'No tienes suficientes coins.'),
              ),
              backgroundColor: res == CoinSpendResult.success ? Colors.green : Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }

        Future<void> buyBundle() async {
          final res = await TournamentService.instance.buyTournamentTicketBundle3();
          await _refreshTournamentPass();
          if (!mounted) return;
          if (!ctx.mounted) return;
          Navigator.pop(ctx);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                res == CoinSpendResult.success
                    ? (isEn ? 'Bundle purchased (+3 tickets).' : 'Bundle comprado (+3 tickets).')
                    : (isEn ? 'Not enough coins.' : 'No tienes suficientes coins.'),
              ),
              backgroundColor: res == CoinSpendResult.success ? Colors.green : Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                  isEn ? '+1 Duel Ticket' : '+1 Ticket de Duelo',
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
                  isEn ? '+3 Duel Tickets' : '+3 Tickets de Duelo',
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
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Fun facts array
    String _getFunFact() {
      final facts = [
        loc.duelFunFact1,
        loc.duelFunFact2,
        loc.duelFunFact3,
        loc.duelFunFact4,
        loc.duelFunFact5,
      ];
      return facts[_funFactIndex % facts.length];
    }

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: ThemeService.instance.cardColor.withOpacity(0.72),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: ThemeService.instance.borderColor.withOpacity(0.9)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: ThemeService.instance.textColor, size: 20),
                        ),
                        Expanded(
                          child: Text(
                            loc.duelTitle,
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: ThemeService.instance.textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 42),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ── Hero Header ────────────────────────────────
                        Text(
                          loc.duelHeadline,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: ThemeService.instance.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                        const SizedBox(height: 6),
                        Text(
                          loc.duelDescription,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: ThemeService.instance.subtitleColor,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 150.ms),
                        const SizedBox(height: 20),

                        // ── How it works ───────────────────────────────
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.help_outline_rounded, color: ThemeService.instance.primaryColor, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    loc.duelHowToPlayTitle,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _fg,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildStep('1️⃣', loc.duelStep1),
                              const SizedBox(height: 8),
                              _buildStep('2️⃣', loc.duelStep2),
                              const SizedBox(height: 8),
                              _buildStep('3️⃣', loc.duelStep3),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                        const SizedBox(height: 16),

                        // ── The 4 Dimensions ──────────────────────────
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: Colors.amber, size: 22),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loc.duelDimExplainTitle,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _fg,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              _buildDimensionRow(loc.duelDimEmotional, loc.duelDimEmotionalDesc, Colors.pink.shade300),
                              const SizedBox(height: 10),
                              _buildDimensionRow(loc.duelDimPassion, loc.duelDimPassionDesc, Colors.deepOrange.shade400),
                              const SizedBox(height: 10),
                              _buildDimensionRow(loc.duelDimIntellectual, loc.duelDimIntellectualDesc, Colors.blue.shade400),
                              const SizedBox(height: 10),
                              _buildDimensionRow(loc.duelDimDestiny, loc.duelDimDestinyDesc, Colors.purple.shade300),
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Text('⚡', style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        loc.duelTiebreakerNote,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

                        const SizedBox(height: 20),

                        // ── Fun Fact Chip ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.pink.shade400.withOpacity(0.15),
                                Colors.purple.shade400.withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.pink.shade200.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Text('💡', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.duelFunFact,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.pink.shade300,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _getFunFact(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: ThemeService.instance.subtitleColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms),

                        const SizedBox(height: 24),

                        // ── Duel Arena (Form) ─────────────────────────
                        _sectionCard(
                          child: Column(
                            children: [
                              Text(
                                '⚔️',
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),

                              // Your name
                              CustomTextField(
                                hintText: loc.duelYourName,
                                icon: Icons.person,
                                controller: _userNameController,
                              ),

                              const SizedBox(height: 18),

                              // Crush A
                              CustomTextField(
                                hintText: loc.duelCrushA,
                                icon: Icons.favorite,
                                controller: _crushAController,
                              ).animate().fadeIn(delay: 500.ms),

                              const SizedBox(height: 10),

                              // VS separator — more dramatic
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.red.shade600, Colors.orange.shade600],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '⚔️ VS ⚔️',
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ).animate().scale(delay: 600.ms, duration: 600.ms, curve: Curves.elasticOut),

                              const SizedBox(height: 10),

                              // Crush B
                              CustomTextField(
                                hintText: loc.duelCrushB,
                                icon: Icons.favorite_border,
                                controller: _crushBController,
                              ).animate().fadeIn(delay: 600.ms),

                              const SizedBox(height: 22),

                              // Start duel button
                              GradientButton(
                                text: _isLoading ? loc.duelLoading : loc.duelStart,
                                onPressed: _startDuel,
                                isLoading: _isLoading,
                                icon: _isLoading ? null : Icons.bolt,
                                backgroundColor: Colors.red,
                              ).animate().fadeIn(delay: 700.ms),
                            ],
                          ),
                        ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),

                        const SizedBox(height: 24),

                        // ── Daily Pass Card ──────────────────────────────
                        _sectionCard(
                          child: _loadingPass
                              ? const Center(child: CircularProgressIndicator())
                              : _buildDailyPassCard(Localizations.localeOf(context).languageCode == 'en'),
                        ),

                        const SizedBox(height: 16),

                        // ── Weekly Missions ──────────────────────────────
                        _sectionCard(
                          child: _loadingMissions
                              ? const Center(child: CircularProgressIndicator())
                              : _buildWeeklyMissionsCard(Localizations.localeOf(context).languageCode == 'en'),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Banner ad
                if (_bannerAd != null && _isBannerAdReady && !MonetizationService.instance.isPremium)
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
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────────────

  Color get _fg => ThemeService.instance.textColor;
  Color get _fgSub => ThemeService.instance.subtitleColor;
  Color get _card => ThemeService.instance.cardColor;

  Widget _buildStep(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: _fgSub,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionRow(String name, String description, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _fg,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: _fgSub,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
              isEn ? 'Daily Duel Pass' : 'Pase Diario del Duelo',
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
            _miniStatChip('🎫', isEn ? 'Tickets left' : 'Tickets hoy', remainingText),
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
        Row(
          children: [
            Icon(Icons.flag, color: ThemeService.instance.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              isEn ? 'Weekly Missions' : 'Misiones Semanales',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _fg,
              ),
            ),
          ],
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
}
