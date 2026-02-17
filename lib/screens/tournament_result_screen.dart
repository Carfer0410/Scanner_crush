import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:share_plus/share_plus.dart';
import '../models/tournament.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import '../services/admob_service.dart';
import '../services/monetization_service.dart';
import '../widgets/custom_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TournamentResultScreen extends StatefulWidget {
  final Tournament tournament;

  const TournamentResultScreen({super.key, required this.tournament});

  @override
  State<TournamentResultScreen> createState() => _TournamentResultScreenState();
}

class _TournamentResultScreenState extends State<TournamentResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _podiumController;
  late AnimationController _confettiController;
  BannerAd? _bannerAd;
  late String _coronationPhrase;
  final Random _random = Random();

  static const List<String> _coronationPhrasesEs = [
    '¡El amor ha hablado! {name} se lleva la corona del corazón de {user} 👑',
    '¡Después de una batalla épica, {name} reina en el corazón de {user}! 💘',
    '¡Todos lucharon, pero el destino eligió a {name} para {user}! ✨',
    '¡Se escucharon los latidos y {name} conquistó a {user}! 💓',
    '¡El universo conspiró y {name} conquistó el corazón de {user}! 🌟',
    '¡De entre todos los crushes, {name} es el/la elegido/a de {user}! 🔥',
    '¡El corazón de {user} no miente! {name} es el crush definitivo 💕',
  ];

  static const List<String> _coronationPhrasesEn = [
    'Love has spoken! {name} takes the crown of {user}\'s heart 👑',
    'After an epic battle, {name} reigns in {user}\'s heart! 💘',
    'Everyone fought, but destiny chose {name} for {user}! ✨',
    'The heartbeats were heard and {name} conquered {user}! 💓',
    'The universe conspired and {name} conquered {user}\'s heart! 🌟',
    'Among all crushes, {name} is {user}\'s chosen one! 🔥',
    '{user}\'s heart never lies! {name} is the ultimate crush 💕',
  ];

  @override
  void initState() {
    super.initState();

    _podiumController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Generate coronation phrase
    _coronationPhrase = '';

    Future.delayed(const Duration(milliseconds: 500), () {
      _podiumController.forward();
      HapticFeedback.heavyImpact();
      AudioService.instance.playCompatibilityResult(95);
    });

    Future.delayed(const Duration(seconds: 1), () {
      _confettiController.repeat();
    });

    _loadBannerAd();
    AdMobService.instance.trackUserAction();
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
    _podiumController.dispose();
    _confettiController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _shareResults() async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      await Share.share(widget.tournament.getShareText(languageCode: langCode));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.shareError),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final tournament = widget.tournament;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Close button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Pop until we reach the welcome screen
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ThemeService.instance.textColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Trophy animation
                      const Text('🏆', style: TextStyle(fontSize: 80))
                          .animate()
                          .scale(
                            duration: 1.seconds,
                            curve: Curves.elasticOut,
                          )
                          .then()
                          .shake(
                            delay: 500.ms,
                            duration: 500.ms,
                          ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        loc.tournamentComplete,
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ThemeService.instance.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms),

                      const SizedBox(height: 12),

                      // Epic coronation message
                      Builder(
                        builder: (context) {
                          if (_coronationPhrase.isEmpty && tournament.champion != null) {
                            final isEn = Localizations.localeOf(context).languageCode == 'en';
                            final phrases = isEn ? _coronationPhrasesEn : _coronationPhrasesEs;
                            _coronationPhrase = phrases[_random.nextInt(phrases.length)]
                                .replaceAll('{name}', tournament.champion!.name)
                                .replaceAll('{user}', tournament.userName);
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ThemeService.instance.primaryColor.withOpacity(0.15),
                                  ThemeService.instance.secondaryColor.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: ThemeService.instance.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _coronationPhrase.isNotEmpty
                                  ? _coronationPhrase
                                  : loc.tournamentResultSubtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ThemeService.instance.textColor,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 32),

                      // Podium
                      _buildPodium(tournament),

                      const SizedBox(height: 32),

                      // Match summary
                      _buildMatchSummary(tournament),

                      const SizedBox(height: 24),

                      // Share button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _shareResults,
                          icon: const Icon(Icons.share, size: 22),
                          label: Text(
                            loc.tournamentShare,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeService.instance.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: ThemeService.instance.primaryColor
                                .withOpacity(0.4),
                          ),
                        ).animate().scale(delay: 1.5.seconds, duration: 500.ms),
                      ),

                      const SizedBox(height: 16),

                      // Play again button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.popUntil(context, (route) => route.isFirst);
                          },
                          icon: const Icon(Icons.replay),
                          label: Text(
                            loc.tournamentPlayAgain,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeService.instance.primaryColor,
                            side: BorderSide(
                              color: ThemeService.instance.primaryColor,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ).animate().fadeIn(delay: 1.8.seconds),
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

  Widget _buildPodium(Tournament tournament) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 🥈 Second place (left, shorter)
        Expanded(
          child: _buildPodiumPlace(
            participant: tournament.runnerUp,
            emoji: '🥈',
            label: '2nd',
            height: 120,
            color: Colors.grey.shade400,
            delay: 800,
          ),
        ),

        const SizedBox(width: 8),

        // 🥇 First place (center, tallest)
        Expanded(
          child: _buildPodiumPlace(
            participant: tournament.champion,
            emoji: '🥇',
            label: '1st',
            height: 160,
            color: Colors.amber,
            delay: 400,
            isChampion: true,
          ),
        ),

        const SizedBox(width: 8),

        // 🥉 Third place (right, shortest)
        Expanded(
          child: _buildPodiumPlace(
            participant: tournament.thirdPlace,
            emoji: '🥉',
            label: '3rd',
            height: 90,
            color: Colors.brown.shade400,
            delay: 1200,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumPlace({
    required TournamentParticipant? participant,
    required String emoji,
    required String label,
    required double height,
    required Color color,
    required int delay,
    bool isChampion = false,
  }) {
    if (participant == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Medal
        Text(
          emoji,
          style: TextStyle(fontSize: isChampion ? 50 : 36),
        ).animate().scale(
              delay: delay.ms,
              duration: 600.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 8),

        // Name
        Text(
          participant.name,
          style: GoogleFonts.poppins(
            fontSize: isChampion ? 16 : 13,
            fontWeight: FontWeight.bold,
            color: ThemeService.instance.textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: (delay + 200).ms),

        if (participant.isCelebrity)
          Text(
            '⭐',
            style: const TextStyle(fontSize: 14),
          ),

        const SizedBox(height: 8),

        // Podium block
        AnimatedContainer(
          duration: Duration(milliseconds: 800 + delay),
          curve: Curves.easeOutBack,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.4),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: isChampion ? 24 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ).animate().slideY(
              begin: 1,
              end: 0,
              delay: delay.ms,
              duration: 800.ms,
              curve: Curves.easeOutBack,
            ),
      ],
    );
  }

  Widget _buildMatchSummary(Tournament tournament) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeService.instance.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.tournamentSummary,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
          const SizedBox(height: 12),

          // Stats
          _buildStatRow(
            '⚔️',
            loc.tournamentTotalMatches,
            '${tournament.totalMatchesPlayed}',
          ),
          _buildStatRow(
            '👥',
            loc.tournamentParticipantsCount,
            '${tournament.participantCount}',
          ),
          _buildStatRow(
            '🔄',
            loc.tournamentRoundsPlayed,
            '${tournament.rounds.length}',
          ),

          const SizedBox(height: 12),

          // Final match details
          if (tournament.rounds.isNotEmpty) ...[
            Divider(color: ThemeService.instance.subtitleColor.withOpacity(0.2)),
            const SizedBox(height: 8),
            Text(
              loc.tournamentFinalMatch,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ThemeService.instance.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            _buildFinalMatchDetail(tournament),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 1.seconds);
  }

  Widget _buildStatRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: ThemeService.instance.subtitleColor,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemeService.instance.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalMatchDetail(Tournament tournament) {
    final finalRound = tournament.rounds.last;
    if (finalRound.isEmpty) return const SizedBox.shrink();

    final finalMatch = finalRound.first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeService.instance.primaryColor.withOpacity(0.1),
            ThemeService.instance.secondaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      finalMatch.participant1.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: finalMatch.winner == finalMatch.participant1
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: ThemeService.instance.textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${finalMatch.percentage1}%',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: finalMatch.winner == finalMatch.participant1
                            ? Colors.green
                            : ThemeService.instance.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'VS',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemeService.instance.subtitleColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      finalMatch.participant2.name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: finalMatch.winner == finalMatch.participant2
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: ThemeService.instance.textColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${finalMatch.percentage2}%',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: finalMatch.winner == finalMatch.participant2
                            ? Colors.green
                            : ThemeService.instance.subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
