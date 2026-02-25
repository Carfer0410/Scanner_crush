import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import '../services/monetization_service.dart';
import '../services/admob_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TournamentMatchScreen extends StatefulWidget {
  final Tournament tournament;
  final VoidCallback onMatchComplete;

  const TournamentMatchScreen({
    super.key,
    required this.tournament,
    required this.onMatchComplete,
  });

  @override
  State<TournamentMatchScreen> createState() => _TournamentMatchScreenState();
}

class _TournamentMatchScreenState extends State<TournamentMatchScreen>
    with TickerProviderStateMixin {
  late AnimationController _vsController;
  late AnimationController _percentageController;
  late AnimationController _winnerController;
  late AnimationController _countdownController;
  late Animation<double> _pct1Animation;
  late Animation<double> _pct2Animation;

  bool _showCountdown = false;
  int _countdownValue = 3;
  bool _showVS = false;
  bool _showPercentages = false;
  bool _showWinner = false;
  bool _showFloatingEmojis = false;
  TournamentMatch? _playedMatch;
  late TournamentMatch _currentMatch;
  late String _winnerPhrase;
  final Random _random = Random();

  // Floating emoji particles for winner celebration
  final List<_FloatingEmoji> _floatingEmojis = [];

  // Banner ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Victory phrases — epic battle language
  static const List<String> _victoryPhrasesEs = [
    '💘 ¡{name} conquista el corazón de {user}!',
    '⚡ ¡{name} arrasa para ganar el amor de {user}!',
    '🔥 ¡{name} se impone por el corazón de {user}!',
    '👑 ¡{name} lucha y gana por {user}!',
    '💫 ¡{name} demuestra ser imparable por {user}!',
    '🌟 ¡Nadie pudo vencer a {name} por el amor de {user}!',
    '⚔️ ¡{name} triunfa en el duelo por {user}!',
    '🏆 ¡Victoria aplastante de {name} por el corazón de {user}!',
    '💪 ¡{name} se impone para ganar el corazón de {user}!',
    '🎯 ¡{name} da en el blanco del amor de {user}!',
    '✨ ¡El destino elige a {name} para {user}!',
    '💎 ¡{name} brilla más que nadie por {user}!',
  ];

  static const List<String> _victoryPhrasesEn = [
    '💘 {name} conquers {user}\'s heart!',
    '⚡ {name} dominates the arena for {user}!',
    '🔥 {name} fights and wins {user}\'s love!',
    '👑 {name} rules the battlefield for {user}!',
    '💫 {name} proves unstoppable for {user}\'s heart!',
    '🌟 Nobody can defeat {name} for {user}\'s love!',
    '⚔️ {name} triumphs in the duel for {user}!',
    '🏆 A crushing victory for {name} to win {user}\'s heart!',
    '💪 {name} prevails for the love of {user}!',
    '🎯 {name} hits the bullseye of {user}\'s heart!',
    '✨ Destiny chooses {name} for {user}!',
    '💎 {name} outshines everyone for {user}\'s love!',
  ];

  // Final round specific phrases — more dramatic
  static const List<String> _finalVictoryPhrasesEs = [
    '👑🔥 ¡{name} se corona campeón/a del corazón de {user}!',
    '🏆💘 ¡{name} gana la gran final por el amor de {user}!',
    '⚡👑 ¡{name} conquista el trono del corazón de {user}!',
    '🌟🏆 ¡{name} es el crush definitivo de {user}!',
    '💎✨ ¡{name} reina supremo/a en el corazón de {user}!',
    '🔥💫 ¡Nadie pudo detener a {name}! ¡El corazón de {user} tiene dueño/a!',
  ];

  static const List<String> _finalVictoryPhrasesEn = [
    '👑🔥 {name} is crowned champion of {user}\'s heart!',
    '🏆💘 {name} wins the grand final for {user}\'s love!',
    '⚡👑 {name} conquers the throne of {user}\'s heart!',
    '🌟🏆 {name} is {user}\'s ultimate crush!',
    '💎✨ {name} reigns supreme in {user}\'s heart!',
    '🔥💫 Nobody could stop {name}! {user}\'s heart has a champion!',
  ];

  // Pre-battle hype phrases
  static const List<String> _battleCryEs = [
    '¡Que comience el duelo! ⚔️',
    '¡A luchar por el amor! 💘',
    '¡Corazones listos! 💕',
    '¡Que se decida el destino! ✨',
  ];

  static const List<String> _battleCryEn = [
    'Let the duel begin! ⚔️',
    'Fight for love! 💘',
    'Hearts ready! 💕',
    'Let destiny decide! ✨',
  ];

  @override
  void initState() {
    super.initState();

    // CRITICAL: Capture the match reference NOW, before playMatch() advances
    // currentMatchInRound. After playMatch, tournament.currentMatch will point
    // to the NEXT match, causing different names to appear mid-animation.
    _currentMatch = widget.tournament.currentMatch!;
    _winnerPhrase = '';

    _vsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _percentageController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _winnerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pct1Animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    _pct2Animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    _loadBannerAd();
    _startMatchSequence();
  }

  String _getVictoryPhrase(String winnerName, String userName, bool isFinal, bool isEn) {
    final List<String> phrases;
    if (isFinal) {
      phrases = isEn ? _finalVictoryPhrasesEn : _finalVictoryPhrasesEs;
    } else {
      phrases = isEn ? _victoryPhrasesEn : _victoryPhrasesEs;
    }
    return phrases[_random.nextInt(phrases.length)]
        .replaceAll('{name}', winnerName)
        .replaceAll('{user}', userName);
  }

  void _generateFloatingEmojis() {
    final emojis = ['💕', '❤️', '✨', '💫', '🌟', '💘', '💖', '⭐', '🔥', '👑'];
    _floatingEmojis.clear();
    for (int i = 0; i < 18; i++) {
      _floatingEmojis.add(_FloatingEmoji(
        emoji: emojis[_random.nextInt(emojis.length)],
        startX: _random.nextDouble(),
        delay: _random.nextInt(1200),
        duration: 1500 + _random.nextInt(1500),
        size: 16.0 + _random.nextInt(18),
      ));
    }
  }

  void _startMatchSequence() async {
    // Step 0: Dramatic countdown 3...2...1...
    setState(() => _showCountdown = true);
    for (int i = 3; i >= 1; i--) {
      if (!mounted) return;
      setState(() => _countdownValue = i);
      _countdownController.forward(from: 0);
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 700));
    }
    if (!mounted) return;
    setState(() => _showCountdown = false);

    // Step 1: Show VS animation with battle cry
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    setState(() => _showVS = true);
    _vsController.forward();
    HapticFeedback.mediumImpact();

    // Step 2: Play the match
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    
    _playedMatch = TournamentService.instance.playMatch(
      widget.tournament,
      widget.tournament.userName,
    );

    // Determine if this is a final match
    final isFinal = _currentMatch.roundNumber == widget.tournament.totalRounds - 1;
    final isEn = mounted ? Localizations.localeOf(context).languageCode == 'en' : false;
    _winnerPhrase = _getVictoryPhrase(_playedMatch!.winner!.name, widget.tournament.userName, isFinal, isEn);

    // Step 3: Animate percentages
    _pct1Animation = Tween<double>(
      begin: 0,
      end: _playedMatch!.percentage1.toDouble(),
    ).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );
    _pct2Animation = Tween<double>(
      begin: 0,
      end: _playedMatch!.percentage2.toDouble(),
    ).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    setState(() => _showPercentages = true);
    _percentageController.forward();
    HapticFeedback.selectionClick();

    // Step 4: Reveal winner with floating emojis
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    _generateFloatingEmojis();
    setState(() {
      _showWinner = true;
      _showFloatingEmojis = true;
    });
    _winnerController.forward();
    HapticFeedback.heavyImpact();
    AudioService.instance.playCompatibilityResult(_playedMatch!.winner == _playedMatch!.participant1 
        ? _playedMatch!.percentage1 
        : _playedMatch!.percentage2);

    // Extra haptic buzz for dramatic effect
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    HapticFeedback.mediumImpact();

    // Step 5: Wait and callback
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    widget.onMatchComplete();
  }

  void _loadBannerAd() async {
    if (!await MonetizationService.instance.isPremiumAsync()) {
      _bannerAd = AdMobService.instance.createBannerAd();
      _bannerAd?.load().then((_) {
        if (mounted) {
          setState(() {
            _isBannerAdReady = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _vsController.dispose();
    _percentageController.dispose();
    _winnerController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use _currentMatch (captured in initState before playMatch advances
    // the tournament state). Never use widget.tournament.currentMatch here.

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final roundName = TournamentService.instance.getRoundName(
      widget.tournament,
      _currentMatch.roundNumber,
      isEn: isEn,
    );
    final battleCry = isEn
        ? _battleCryEn[_random.nextInt(_battleCryEn.length)]
        : _battleCryEs[_random.nextInt(_battleCryEs.length)];

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: (_bannerAd != null && _isBannerAdReady)
          ? Container(
              alignment: Alignment.center,
              color: Colors.black,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      body: Stack(
        children: [
          // Dramatic gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _showWinner
                    ? [
                        ThemeService.instance.primaryColor.withOpacity(0.8),
                        ThemeService.instance.secondaryColor.withOpacity(0.8),
                      ]
                    : [
                        Colors.black87,
                        ThemeService.instance.primaryColor.withOpacity(0.3),
                        Colors.black87,
                      ],
              ),
            ),
          ),

          // Floating emojis celebration
          if (_showFloatingEmojis)
            ..._floatingEmojis.map((emoji) => _buildFloatingEmoji(emoji)),

          SafeArea(
            child: Column(
              children: [
                // Round header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          roundName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        if (_showVS && !_showWinner)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              battleCry,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber.withOpacity(0.8),
                                fontStyle: FontStyle.italic,
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
                          ),
                      ],
                    ),
                  ),
                ),

                // Countdown overlay
                if (_showCountdown)
                  Expanded(
                    child: Center(
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _countdownController,
                          curve: Curves.elasticOut,
                        ),
                        child: Text(
                          '$_countdownValue',
                          style: GoogleFonts.poppins(
                            fontSize: 120,
                            fontWeight: FontWeight.w900,
                            color: _countdownValue == 1
                                ? Colors.red
                                : _countdownValue == 2
                                    ? Colors.orange
                                    : Colors.amber,
                            shadows: [
                              Shadow(
                                color: (_countdownValue == 1
                                        ? Colors.red
                                        : _countdownValue == 2
                                            ? Colors.orange
                                            : Colors.amber)
                                    .withOpacity(0.6),
                                blurRadius: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                if (!_showCountdown) ...[
                  const Spacer(),

                  // Participant 1
                  _buildParticipantCard(
                    _currentMatch.participant1,
                    _pct1Animation,
                    isWinner: _showWinner &&
                        _playedMatch?.winner == _currentMatch.participant1,
                    isLoser: _showWinner &&
                        _playedMatch?.winner != _currentMatch.participant1,
                    slideFrom: const Offset(-1, 0),
                  ),

                  // VS
                  if (_showVS)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: _vsController,
                          curve: Curves.elasticOut,
                        ),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.orange.shade600,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'VS',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 120),

                  // Participant 2
                  _buildParticipantCard(
                    _currentMatch.participant2,
                    _pct2Animation,
                    isWinner: _showWinner &&
                        _playedMatch?.winner == _currentMatch.participant2,
                    isLoser: _showWinner &&
                        _playedMatch?.winner != _currentMatch.participant2,
                    slideFrom: const Offset(1, 0),
                  ),

                  const Spacer(),

                  // Winner announcement — EPIC phrase
                  if (_showWinner && _playedMatch != null)
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _winnerController,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade700,
                              Colors.orange.shade600,
                              Colors.deepOrange.shade500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _winnerPhrase,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingEmoji(_FloatingEmoji emoji) {
    return Positioned(
      left: emoji.startX * MediaQuery.of(context).size.width,
      bottom: 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: emoji.duration),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(
              sin(value * 3.14 * 2) * 30,
              -value * MediaQuery.of(context).size.height * 0.9,
            ),
            child: Opacity(
              opacity: (1 - value).clamp(0.0, 1.0),
              child: Text(
                emoji.emoji,
                style: TextStyle(fontSize: emoji.size),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: emoji.delay));
  }

  Widget _buildParticipantCard(
    TournamentParticipant participant,
    Animation<double> percentageAnim, {
    required bool isWinner,
    required bool isLoser,
    required Offset slideFrom,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isLoser ? 0.4 : 1.0,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 500),
        scale: isWinner ? 1.1 : (isLoser ? 0.9 : 1.0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isWinner
                ? Colors.amber.shade900.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWinner
                  ? Colors.amber.withOpacity(0.6)
                  : Colors.white.withOpacity(0.2),
              width: isWinner ? 2 : 1,
            ),
            boxShadow: isWinner
                ? [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Avatar / emoji
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: participant.isCelebrity
                      ? Colors.amber.withOpacity(0.3)
                      : ThemeService.instance.primaryColor.withOpacity(0.3),
                ),
                child: Center(
                  child: Text(
                    participant.isCelebrity ? '⭐' : '💕',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (participant.isCelebrity)
                      Text(
                        '⭐ Celebrity',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                    if (participant.isRevived)
                      Text(
                        '💫 Revived',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
              ),
              // Percentage
              if (_showPercentages)
                AnimatedBuilder(
                  animation: percentageAnim,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getPercentageColor(percentageAnim.value.toInt())
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${percentageAnim.value.toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              if (isWinner)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: const Text('👑', style: TextStyle(fontSize: 24))
                      .animate()
                      .scale(
                        delay: 200.ms,
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                ),
            ],
          ),
        ).animate().slideX(
              begin: slideFrom.dx,
              end: 0,
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 45) return Colors.orange;
    return Colors.red;
  }
}

/// Data model for floating celebration emojis
class _FloatingEmoji {
  final String emoji;
  final double startX;
  final int delay;
  final int duration;
  final double size;

  _FloatingEmoji({
    required this.emoji,
    required this.startX,
    required this.delay,
    required this.duration,
    required this.size,
  });
}
