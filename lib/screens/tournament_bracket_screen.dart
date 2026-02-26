import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/theme_service.dart';
import '../services/admob_service.dart';
import '../services/monetization_service.dart';
import '../services/analytics_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'tournament_match_screen.dart';
import 'tournament_result_screen.dart';

class TournamentBracketScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentBracketScreen({super.key, required this.tournament});

  @override
  State<TournamentBracketScreen> createState() =>
      _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> {
  BannerAd? _bannerAd;
  bool _showingMatch = false;
  final Random _random = Random();

  // Battle hype phrases for the "Next Match" area
  static const List<String> _hypePhrasesEs = [
    'âš”ï¸ Â¡El siguiente duelo del amor espera!',
    'ðŸ”¥ Â¡PrepÃ¡rate para la batalla!',
    'ðŸ’˜ Â¿QuiÃ©n conquistarÃ¡ el corazÃ³n?',
    'âš¡ Â¡Los corazones se aceleran!',
    'ðŸŒŸ Â¡El destino estÃ¡ por decidirse!',
    'ðŸ’« Â¡Que empiece la magia!',
    'ðŸ‘‘ Â¡Solo uno puede avanzar!',
    'ðŸŽ¯ Â¡El amor estÃ¡ en juego!',
  ];

  static const List<String> _hypePhrasesEn = [
    'âš”ï¸ The next love duel awaits!',
    'ðŸ”¥ Get ready for battle!',
    'ðŸ’˜ Who will conquer the heart?',
    'âš¡ Hearts are racing!',
    'ðŸŒŸ Destiny is about to decide!',
    'ðŸ’« Let the magic begin!',
    'ðŸ‘‘ Only one can advance!',
    'ðŸŽ¯ Love is on the line!',
  ];

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    AdMobService.instance.trackUserAction();
    AnalyticsService.instance.trackEvent('tournament_bracket_opened');
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _playNextMatch() async {
    if (widget.tournament.isComplete) {
      _navigateToResults();
      return;
    }

    if (widget.tournament.currentMatch == null) {
      return;
    }

    setState(() => _showingMatch = true);
    await AnalyticsService.instance.trackEvent('tournament_match_started');
    if (!mounted) return;

    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return TournamentMatchScreen(
            tournament: widget.tournament,
            onMatchComplete: () {
              Navigator.pop(context);
            },
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );

    setState(() => _showingMatch = false);

    // Check if round just completed â€” show interstitial between rounds
    if (widget.tournament.isCurrentRoundComplete &&
        !widget.tournament.isComplete) {
      _tryShowInterstitialBetweenRounds();
    }

    // Check if tournament is complete
    if (widget.tournament.isComplete) {
      await AnalyticsService.instance.trackEvent('tournament_completed_navigation');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) _navigateToResults();
    }
  }

  void _tryShowInterstitialBetweenRounds() async {
    if (await MonetizationService.instance.isPremiumAsync()) return;
    if (await AdMobService.instance.shouldShowInterstitialAd()) {
      await AdMobService.instance.showInterstitialAd();
    }
  }

  void _offerRevive() async {
    final eliminated =
        TournamentService.instance.getEliminatedParticipants(widget.tournament);
    if (eliminated.isEmpty) return;

    final loc = AppLocalizations.of(context)!;

    final selected = await showModalBottomSheet<TournamentParticipant>(
      context: context,
      backgroundColor: ThemeService.instance.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.tournamentReviveTitle,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.tournamentReviveDescription,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ThemeService.instance.subtitleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ...eliminated.map((p) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: ThemeService.instance.primaryColor.withOpacity(0.2),
                      child: Text(
                        p.isCelebrity ? 'â­' : 'ðŸ’•',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: GoogleFonts.poppins(
                        color: ThemeService.instance.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.replay,
                      color: ThemeService.instance.primaryColor,
                    ),
                    onTap: () => Navigator.pop(ctx, p),
                  )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      await AnalyticsService.instance.trackEvent('tournament_revive_candidate_selected');
      await _showReviveOptions(selected, loc);
    }
  }

  Future<void> _showReviveOptions(
    TournamentParticipant selected,
    AppLocalizations loc,
  ) async {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final isPremium = await MonetizationService.instance.isPremiumAsync();
    final pass = await TournamentService.instance.getPassState();
    if (!mounted) return;

    final option = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ThemeService.instance.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEn ? 'Revive ${selected.name}' : 'Revivir a ${selected.name}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemeService.instance.textColor,
                ),
              ),
              const SizedBox(height: 12),
              if (isPremium)
                ListTile(
                  leading: const Text('ðŸ‘‘'),
                  title: Text(isEn ? 'Premium Instant Revive' : 'Revive InstantÃ¡neo Premium'),
                  onTap: () => Navigator.pop(ctx, 'premium'),
                ),
              ListTile(
                leading: const Text('ðŸª™'),
                title: Text(isEn ? 'Use coins' : 'Usar coins'),
                subtitle: Text('${TournamentService.instance.reviveCoinCost} coins (balance: ${pass.coins})'),
                onTap: () => Navigator.pop(ctx, 'coins'),
              ),
              ListTile(
                leading: const Text('ðŸŽ¬'),
                title: Text(isEn ? 'Watch rewarded ad' : 'Ver anuncio con recompensa'),
                onTap: () => Navigator.pop(ctx, 'ad'),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(isEn ? 'Cancel' : 'Cancelar'),
                onTap: () => Navigator.pop(ctx, 'cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (option == null || option == 'cancel' || !mounted) return;
    if (option == 'premium' && isPremium) {
      final success = TournamentService.instance.reviveParticipant(widget.tournament, selected);
      await AnalyticsService.instance.trackEvent(
        'tournament_revive_premium',
        params: {'success': success},
      );
      if (!mounted) return;
      if (success) {
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'ðŸ’« ${selected.name} ${loc.tournamentRevived}'
              : (isEn ? 'Revive unavailable.' : 'Revive no disponible.')),
          backgroundColor: success ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (option == 'coins') {
      final result = await TournamentService.instance.reviveWithCoins(widget.tournament, selected);
      await AnalyticsService.instance.trackEvent(
        'tournament_revive_coins',
        params: {'result': result.name},
      );
      if (!mounted) return;
      if (result == CoinSpendResult.success) {
        setState(() {});
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result == CoinSpendResult.success
                ? 'ðŸ’« ${selected.name} ${loc.tournamentRevived}'
                : result == CoinSpendResult.insufficientCoins
                    ? (isEn ? 'Not enough coins.' : 'No tienes suficientes coins.')
                    : (isEn ? 'Revive unavailable right now.' : 'Revive no disponible ahora.'),
          ),
          backgroundColor: result == CoinSpendResult.success ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // option == ad
    final adShown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        final success = TournamentService.instance.reviveParticipant(
          widget.tournament,
          selected,
        );
        AnalyticsService.instance.trackEvent(
          'tournament_revive_ad_reward',
          params: {'success': success},
        );
        if (success && mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ðŸ’« ${selected.name} ${loc.tournamentRevived}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      onAdDismissed: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEn ? 'Reward not earned. Revive cancelled.' : 'No se obtuvo recompensa. Revive cancelado.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
    );

    await AnalyticsService.instance.trackEvent(
      'tournament_revive_ad_attempt',
      params: {'adShown': adShown},
    );

    if (!adShown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEn ? 'Ad not available. Try again later.' : 'Anuncio no disponible, intÃ©ntalo mÃ¡s tarde.'),
          backgroundColor: Colors.grey.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TournamentResultScreen(tournament: widget.tournament),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final tournament = widget.tournament;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor.withOpacity(0.76),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ThemeService.instance.borderColor.withOpacity(0.9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _confirmExit(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: ThemeService.instance.textColor,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        loc.tournamentBracket,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ThemeService.instance.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Revive button (only show if there are eliminated participants)
                    if (TournamentService.instance
                        .getEliminatedParticipants(tournament)
                        .isNotEmpty && !tournament.isComplete)
                      SizedBox(
                        height: 34,
                        child: ElevatedButton.icon(
                          onPressed: _offerRevive,
                          icon: const Text('ðŸ’«', style: TextStyle(fontSize: 16)),
                          label: Text(
                            Localizations.localeOf(context).languageCode == 'en'
                                ? 'Revive'
                                : 'Revivir',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 4,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                  ),
                ),
              ),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${loc.tournamentMatchesPlayed}: ${tournament.totalMatchesPlayed}/${tournament.totalMatches}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: ThemeService.instance.subtitleColor,
                          ),
                        ),
                        if (!tournament.isComplete)
                          Text(
                            TournamentService.instance.getRoundName(
                              tournament,
                              tournament.currentRound,
                              isEn: isEn,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: ThemeService.instance.primaryColor,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: tournament.totalMatches > 0
                            ? tournament.totalMatchesPlayed /
                                tournament.totalMatches
                            : 0,
                        backgroundColor:
                            ThemeService.instance.subtitleColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ThemeService.instance.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bracket visualization
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Build each round
                      ...List.generate(tournament.rounds.length, (roundIdx) {
                        final roundMatches = tournament.rounds[roundIdx];
                        final roundName = TournamentService.instance
                            .getRoundName(tournament, roundIdx, isEn: isEn);
                        final isCurrent = roundIdx == tournament.currentRound;

                        return Column(
                          children: [
                            // Round header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: isCurrent
                                    ? LinearGradient(colors: [
                                        ThemeService.instance.primaryColor
                                            .withOpacity(0.2),
                                        ThemeService.instance.secondaryColor
                                            .withOpacity(0.2),
                                      ])
                                    : null,
                                color: isCurrent
                                    ? null
                                    : ThemeService.instance.cardColor
                                        .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                roundName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent
                                      ? ThemeService.instance.primaryColor
                                      : ThemeService.instance.subtitleColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            // Matches in this round
                            ...roundMatches.map((match) =>
                                _buildMatchCard(match, isCurrent, isEn)),

                            const SizedBox(height: 16),

                            // Connector arrow
                            if (roundIdx < tournament.rounds.length - 1)
                              Icon(
                                Icons.keyboard_double_arrow_down,
                                color: ThemeService.instance.subtitleColor
                                    .withOpacity(0.5),
                                size: 28,
                              ),
                            const SizedBox(height: 8),
                          ],
                        ).animate().fadeIn(delay: (roundIdx * 200).ms);
                      }),

                      // Next match button with hype
                      if (!tournament.isComplete &&
                          tournament.currentMatch != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              // Hype phrase
                              Builder(
                                builder: (context) {
                                  final phrases = isEn ? _hypePhrasesEn : _hypePhrasesEs;
                                  return Text(
                                    phrases[_random.nextInt(phrases.length)],
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeService.instance.primaryColor,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ).animate(
                                onPlay: (c) => c.repeat(reverse: true),
                              ).fadeIn().then().shimmer(duration: 2.seconds, color: ThemeService.instance.primaryColor.withOpacity(0.3)),
                              const SizedBox(height: 8),
                              // Preview: who's next
                              Text(
                                '${tournament.currentMatch!.participant1.name}  âš”ï¸  ${tournament.currentMatch!.participant2.name}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeService.instance.subtitleColor,
                                ),
                                textAlign: TextAlign.center,
                              ).animate().fadeIn(delay: 200.ms),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _showingMatch ? null : _playNextMatch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        ThemeService.instance.primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: ThemeService.instance.primaryColor
                                        .withOpacity(0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('âš”ï¸',
                                          style: TextStyle(fontSize: 22)),
                                      const SizedBox(width: 10),
                                      Text(
                                        loc.tournamentNextMatch,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate(
                                  onPlay: (c) => c.repeat(reverse: true),
                                ).shimmer(
                                  duration: 2.seconds,
                                  color: Colors.white24,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildMatchCard(TournamentMatch match, bool isCurrentRound, bool isEn) {
    final isUpcoming = !match.isPlayed && isCurrentRound;
    final isNext = isUpcoming &&
        match.matchIndex == widget.tournament.currentMatchInRound;
    
    // Determine if match was close (within 10 percentage points)
    final isCloseMatch = match.isPlayed && 
        (match.percentage1 - match.percentage2).abs() <= 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isNext
            ? ThemeService.instance.primaryColor.withOpacity(0.1)
            : ThemeService.instance.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(
                color: ThemeService.instance.primaryColor.withOpacity(0.5),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Close match badge
          if (isCloseMatch)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isEn ? 'ðŸ”¥ Close match!' : 'ðŸ”¥ Â¡Duelo reÃ±ido!',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ),
          _buildMatchParticipantRow(
            match.participant1,
            match.isPlayed ? match.percentage1 : null,
            isWinner: match.isPlayed && match.winner == match.participant1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Divider(
                    color: ThemeService.instance.subtitleColor.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    match.isPlayed ? 'âœ“' : 'VS',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: match.isPlayed
                          ? Colors.green
                          : ThemeService.instance.subtitleColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: ThemeService.instance.subtitleColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
          _buildMatchParticipantRow(
            match.participant2,
            match.isPlayed ? match.percentage2 : null,
            isWinner: match.isPlayed && match.winner == match.participant2,
          ),
          // Dominant victory indicator
          if (match.isPlayed && (match.percentage1 - match.percentage2).abs() > 25)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                isEn ? 'âš¡ Dominant victory!' : 'âš¡ Â¡Victoria aplastante!',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ThemeService.instance.primaryColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchParticipantRow(
    TournamentParticipant participant,
    int? percentage, {
    bool isWinner = false,
  }) {
    return Row(
      children: [
        Text(
          participant.isCelebrity ? 'â­' : 'ðŸ’•',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            participant.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
              color: isWinner
                  ? ThemeService.instance.primaryColor
                  : (participant.isEliminated
                      ? ThemeService.instance.subtitleColor
                      : ThemeService.instance.textColor),
              decoration:
                  participant.isEliminated ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (participant.isRevived)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ðŸ’«',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        if (percentage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner
                  ? Colors.green.withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$percentage%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isWinner ? Colors.green : ThemeService.instance.subtitleColor,
              ),
            ),
          ),
        if (isWinner) ...[
          const SizedBox(width: 6),
          const Text('ðŸ‘‘', style: TextStyle(fontSize: 16)),
        ],
      ],
    );
  }

  void _confirmExit() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeService.instance.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          loc.tournamentExitTitle,
          style: TextStyle(color: ThemeService.instance.textColor),
        ),
        content: Text(
          loc.tournamentExitMessage,
          style: TextStyle(color: ThemeService.instance.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Go back
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.tournamentExit),
          ),
        ],
      ),
    );
  }
}

