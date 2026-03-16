import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import '../models/duel.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';
import '../services/admob_service.dart';
import '../services/monetization_service.dart';
import '../widgets/custom_widgets.dart';

class DuelBattleScreen extends StatefulWidget {
  final DuelResult result;
  const DuelBattleScreen({super.key, required this.result});

  @override
  State<DuelBattleScreen> createState() => _DuelBattleScreenState();
}

/// Phases of the battle flow
enum _Phase { intro, countdown, round, suspense, roundResult, finalReveal, finalResult }

class _DuelBattleScreenState extends State<DuelBattleScreen> with TickerProviderStateMixin {
  _Phase _phase = _Phase.intro;
  int _currentRound = 0;
  int _scoreA = 0;
  int _scoreB = 0;
  int _countdownValue = 3;

  // Bar animation controllers
  late AnimationController _barAController;
  late AnimationController _barBController;
  late Animation<double> _barAAnimation;
  late Animation<double> _barBAnimation;

  // Fade/scale controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _revealController;

  // Suspense blink
  bool _suspenseBlink = false;
  Timer? _blinkTimer;
  Timer? _phaseTimer;

  int get _totalRounds => widget.result.rounds.length;

  static const _dimensionIcons = {
    'emotional': Icons.favorite,
    'passion': Icons.whatshot,
    'intellectual': Icons.psychology,
    'destiny': Icons.auto_awesome,
    'tiebreaker': Icons.bolt,
  };

  static const _dimensionColors = {
    'emotional': Color(0xFFE91E63),
    'passion': Color(0xFFFF5722),
    'intellectual': Color(0xFF2196F3),
    'destiny': Color(0xFF9C27B0),
    'tiebreaker': Color(0xFFFF9800),
  };

  @override
  void initState() {
    super.initState();
    _barAController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _barBController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _barAAnimation = _makeTween(0);
    _barBAnimation = _makeTween(0);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _revealController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    // Start the intro
    _phaseTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) _startCountdown();
    });
  }

  Animation<double> _makeTween(double end) {
    return Tween<double>(begin: 0, end: end)
        .animate(CurvedAnimation(parent: _barAController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _barAController.dispose();
    _barBController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    _blinkTimer?.cancel();
    _phaseTimer?.cancel();
    super.dispose();
  }

  // ── Flow control ─────────────────────────────────────────────────────

  void _startCountdown() {
    setState(() {
      _phase = _Phase.countdown;
      _countdownValue = 3;
    });
    HapticFeedback.lightImpact();
    AudioService.instance.playHeartbeat();

    _phaseTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() => _countdownValue--);
      HapticFeedback.lightImpact();
      if (_countdownValue <= 0) {
        timer.cancel();
        _startRound();
      }
    });
  }

  void _startRound() {
    _fadeController.reset();
    _barAController.reset();
    _barBController.reset();

    final round = widget.result.rounds[_currentRound];

    _barAAnimation = Tween<double>(begin: 0, end: round.scoreA / 100.0)
        .animate(CurvedAnimation(parent: _barAController, curve: Curves.easeOutCubic));
    _barBAnimation = Tween<double>(begin: 0, end: round.scoreB / 100.0)
        .animate(CurvedAnimation(parent: _barBController, curve: Curves.easeOutCubic));

    setState(() => _phase = _Phase.round);
    _fadeController.forward();

    // Bar A starts after a dramatic pause
    _phaseTimer = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _barAController.forward();
    });

    // Bar B starts even later to stagger
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      _barBController.forward();
    });

    // After both bars finish → suspense phase
    _barBController.addStatusListener(_onBarsComplete);
  }

  void _onBarsComplete(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _barBController.removeStatusListener(_onBarsComplete);
    if (!mounted) return;

    // Enter suspense: "¿Quién gana?" blinks for ~2s
    setState(() {
      _phase = _Phase.suspense;
      _suspenseBlink = true;
    });
    HapticFeedback.mediumImpact();
    AudioService.instance.playHeartbeat();

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 350), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _suspenseBlink = !_suspenseBlink);
    });

    _phaseTimer = Timer(const Duration(milliseconds: 2200), () {
      _blinkTimer?.cancel();
      if (!mounted) return;
      _revealRoundWinner();
    });
  }

  void _revealRoundWinner() {
    final round = widget.result.rounds[_currentRound];
    setState(() {
      _phase = _Phase.roundResult;
      if (round.winner == 0) _scoreA++;
      if (round.winner == 1) _scoreB++;
    });

    HapticFeedback.heavyImpact();
    AudioService.instance.playMagicWhoosh();

    // Stay on result for 2.5s then advance
    _phaseTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      _currentRound++;
      if (_currentRound < _totalRounds) {
        _startRound();
      } else {
        _goToFinalReveal();
      }
    });
  }

  void _goToFinalReveal() {
    _revealController.reset();
    setState(() => _phase = _Phase.finalReveal);
    HapticFeedback.heavyImpact();
    AudioService.instance.playHeartbeat();

    _revealController.forward();

    // After the dramatic reveal animation → show full results
    _phaseTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      setState(() => _phase = _Phase.finalResult);
      HapticFeedback.heavyImpact();
      AudioService.instance.playCelebration();
    });
  }

  // ── Build ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Score bar (always visible) ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ThemeService.instance.cardColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ThemeService.instance.borderColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          r.crushA,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.red.shade400),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: ThemeService.instance.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_scoreA - $_scoreB',
                          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w900, color: ThemeService.instance.textColor),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          r.crushB,
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.blue.shade400),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Round indicator dots ───────────────────────────────
              if (_phase != _Phase.intro && _phase != _Phase.countdown)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalRounds, (i) {
                      final isActive = i == _currentRound && _phase != _Phase.finalReveal && _phase != _Phase.finalResult;
                      final isDone = i < _currentRound || _phase == _Phase.finalReveal || _phase == _Phase.finalResult;
                      final round = widget.result.rounds[i];
                      final color = _dimensionColors[round.dimensionKey] ?? Colors.purple;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: isDone
                              ? color
                              : isActive
                                  ? color.withOpacity(0.6)
                                  : ThemeService.instance.surfaceColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: isActive ? Border.all(color: color, width: 2) : null,
                        ),
                      );
                    }),
                  ),
                ),

              // ── Main content ───────────────────────────────────────
              Expanded(child: _buildPhase()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhase() {
    final loc = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    switch (_phase) {
      case _Phase.intro:
        return _buildIntro(isEn);
      case _Phase.countdown:
        return _buildCountdown();
      case _Phase.round:
      case _Phase.suspense:
      case _Phase.roundResult:
        return _buildRoundView(loc, isEn);
      case _Phase.finalReveal:
        return _buildFinalReveal(isEn);
      case _Phase.finalResult:
        return _buildFinalResult(loc, isEn);
    }
  }

  // ── Phase: Intro ──────────────────────────────────────────────────

  Widget _buildIntro(bool isEn) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚔️', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 20),
          Text(
            isEn ? 'LOVE DUEL' : 'DUELO DE AMOR',
            style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: ThemeService.instance.textColor, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Text(
            '${widget.result.crushA}  vs  ${widget.result.crushB}',
            style: GoogleFonts.poppins(fontSize: 17, color: ThemeService.instance.subtitleColor, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isEn ? '$_totalRounds rounds to decide the winner' : '$_totalRounds asaltos para decidir el ganador',
            style: GoogleFonts.poppins(fontSize: 13, color: ThemeService.instance.subtitleColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  // ── Phase: Countdown ──────────────────────────────────────────────

  Widget _buildCountdown() {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
        child: Text(
          '$_countdownValue',
          key: ValueKey(_countdownValue),
          style: GoogleFonts.poppins(
            fontSize: 96,
            fontWeight: FontWeight.w900,
            color: _countdownValue == 1 ? Colors.red : ThemeService.instance.textColor,
          ),
        ),
      ),
    );
  }

  // ── Phase: Round (bars filling) + Suspense + RoundResult ──────────

  Widget _buildRoundView(AppLocalizations loc, bool isEn) {
    if (_currentRound >= _totalRounds) return const SizedBox.shrink();
    final round = widget.result.rounds[_currentRound];
    final dimKey = round.dimensionKey;
    final icon = _dimensionIcons[dimKey] ?? Icons.stars;
    final color = _dimensionColors[dimKey] ?? Colors.purple;
    final dimName = _getDimensionName(dimKey, loc);
    final isTiebreaker = dimKey == 'tiebreaker';
    final roundNumber = _currentRound + 1;

    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Round header badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.5), width: isTiebreaker ? 2 : 1),
              ),
              child: Column(
                children: [
                  if (isTiebreaker) ...[
                    Text(
                      isEn ? '⚡ TIEBREAKER ⚡' : '⚡ DESEMPATE ⚡',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.orange, letterSpacing: 1),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${isEn ? "Round" : "Asalto"} $roundNumber: $dimName',
                        style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700, color: color),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Crush A bar
            _buildBar(
              name: widget.result.crushA,
              controller: _barAController,
              animation: _barAAnimation,
              score: round.scoreA,
              color: Colors.red.shade400,
              showWinner: _phase == _Phase.roundResult && round.winner == 0,
            ),

            const SizedBox(height: 28),

            // Crush B bar
            _buildBar(
              name: widget.result.crushB,
              controller: _barBController,
              animation: _barBAnimation,
              score: round.scoreB,
              color: Colors.blue.shade400,
              showWinner: _phase == _Phase.roundResult && round.winner == 1,
            ),

            const SizedBox(height: 36),

            // Suspense text (blinking "¿Quién gana?")
            if (_phase == _Phase.suspense)
              AnimatedOpacity(
                opacity: _suspenseBlink ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isEn ? '🤔 Who wins...?' : '🤔 ¿Quién gana...?',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: ThemeService.instance.textColor),
                ),
              ),

            // Round winner announcement
            if (_phase == _Phase.roundResult)
              _buildRoundWinnerBanner(round, isEn, color),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundWinnerBanner(DuelRound round, bool isEn, Color dimColor) {
    final a = widget.result.crushA;
    final b = widget.result.crushB;
    String text;
    Color bannerColor;
    String emoji;

    if (round.winner == 0) {
      text = isEn ? '$a wins!' : '¡$a gana!';
      bannerColor = Colors.red.shade400;
      emoji = '🔴';
    } else if (round.winner == 1) {
      text = isEn ? '$b wins!' : '¡$b gana!';
      bannerColor = Colors.blue.shade400;
      emoji = '🔵';
    } else {
      text = isEn ? 'Tie!' : '¡Empate!';
      bannerColor = Colors.amber;
      emoji = '🤝';
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bannerColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bannerColor.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: bannerColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            // Show updated score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeService.instance.surfaceColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_scoreA - $_scoreB',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w900, color: ThemeService.instance.textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar({
    required String name,
    required AnimationController controller,
    required Animation<double> animation,
    required int score,
    required Color color,
    required bool showWinner,
  }) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final value = animation.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ThemeService.instance.textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: showWinner ? color : ThemeService.instance.textColor,
                  ),
                ),
                if (showWinner) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 22),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 26,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ThemeService.instance.surfaceColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(13),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Phase: Final Reveal (dramatic tease) ──────────────────────────

  Widget _buildFinalReveal(bool isEn) {
    final r = widget.result;
    final winner = r.overallWinner;

    return Center(
      child: AnimatedBuilder(
        animation: _revealController,
        builder: (context, child) {
          final t = _revealController.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulsing question mark → trophy
              Transform.scale(
                scale: 0.8 + (t * 0.4),
                child: Opacity(
                  opacity: (t * 2).clamp(0.0, 1.0),
                  child: Text(
                    t < 0.6 ? '❓' : (winner >= 0 ? '🏆' : '🤝'),
                    style: TextStyle(fontSize: 80 + (t * 20)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (t < 0.6)
                ScaleTransition(
                  scale: _pulseController,
                  child: Text(
                    isEn ? 'And the winner is...' : 'Y el ganador es...',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ThemeService.instance.textColor,
                    ),
                  ),
                ),
              if (t >= 0.6)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Text(
                    winner >= 0
                        ? '🎉 ${r.winnerName}! 🎉'
                        : (isEn ? '🤝 Perfect Tie! 🤝' : '🤝 ¡Empate Perfecto! 🤝'),
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: winner == 0 ? Colors.red.shade400 : (winner == 1 ? Colors.blue.shade400 : Colors.amber),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Phase: Final Result Screen ────────────────────────────────────

  Widget _buildFinalResult(AppLocalizations loc, bool isEn) {
    final r = widget.result;
    final winner = r.overallWinner;
    final winnerName = r.winnerName;
    final winnerColor = winner == 0 ? Colors.red.shade400 : (winner == 1 ? Colors.blue.shade400 : Colors.amber);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Trophy + Winner name
          Text(winner >= 0 ? '🏆' : '🤝', style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            winner >= 0
                ? (isEn
                    ? '$winnerName wins the duel!'
                    : '¡$winnerName gana el duelo!')
                : (isEn ? 'Perfect tie!' : '¡Empate perfecto!'),
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: ThemeService.instance.textColor),
            textAlign: TextAlign.center,
          ),

          // Score badge
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: winnerColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: winnerColor.withOpacity(0.4)),
            ),
            child: Text(
              isEn ? 'Final Score: $_scoreA - $_scoreB' : 'Marcador Final: $_scoreA - $_scoreB',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: winnerColor),
            ),
          ),

          const SizedBox(height: 8),

          // Fun closing message
          Text(
            _getClosingMessage(r, isEn),
            style: GoogleFonts.poppins(fontSize: 14, color: ThemeService.instance.subtitleColor, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── Section: Round-by-Round breakdown ─────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeService.instance.cardColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ThemeService.instance.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEn ? '📋 Round-by-Round' : '📋 Asalto por Asalto',
                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: ThemeService.instance.textColor),
                ),
                const SizedBox(height: 12),
                // Table header
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const SizedBox(width: 8),
                    Expanded(child: Text(isEn ? 'Dimension' : 'Dimensión', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: ThemeService.instance.subtitleColor))),
                    SizedBox(
                      width: 60,
                      child: Text(r.crushA, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red.shade400), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Text(r.crushB, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.blue.shade400), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const Divider(height: 16),
                // Round rows
                ...List.generate(r.rounds.length, (i) {
                  final round = r.rounds[i];
                  final dimKey = round.dimensionKey;
                  final color = _dimensionColors[dimKey] ?? Colors.purple;
                  final icon = _dimensionIcons[dimKey] ?? Icons.stars;
                  final dimName = _getDimensionName(dimKey, loc);
                  final isTiebreaker = dimKey == 'tiebreaker';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isTiebreaker ? Colors.orange.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: isTiebreaker ? Border.all(color: Colors.orange.withOpacity(0.3)) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dimName, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeService.instance.textColor)),
                              if (isTiebreaker)
                                Text(isEn ? 'Tiebreaker' : 'Desempate', style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: round.winner == 0 ? Colors.red.shade400.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${round.scoreA}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: round.winner == 0 ? FontWeight.w800 : FontWeight.w500,
                              color: round.winner == 0 ? Colors.red.shade400 : ThemeService.instance.subtitleColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                            color: round.winner == 1 ? Colors.blue.shade400.withOpacity(0.15) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${round.scoreB}%',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: round.winner == 1 ? FontWeight.w800 : FontWeight.w500,
                              color: round.winner == 1 ? Colors.blue.shade400 : ThemeService.instance.subtitleColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 24,
                          child: round.winner >= 0
                              ? Icon(Icons.emoji_events, size: 16, color: round.winner == 0 ? Colors.red.shade400 : Colors.blue.shade400)
                              : const Icon(Icons.drag_handle, size: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Total compatibility comparison ────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                ThemeService.instance.cardColor.withOpacity(0.9),
                ThemeService.instance.surfaceColor.withOpacity(0.8),
              ]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeService.instance.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Text(
                  isEn ? 'Overall Compatibility' : 'Compatibilidad Total',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeService.instance.subtitleColor),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _totalColumn(r.crushA, r.totalA, Colors.red.shade400),
                    Text('VS', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: ThemeService.instance.subtitleColor)),
                    _totalColumn(r.crushB, r.totalB, Colors.blue.shade400),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: loc.duelShare,
                  onPressed: _shareResult,
                  icon: Icons.share,
                  backgroundColor: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  text: loc.duelPlayAgain,
                  onPressed: () => Navigator.pop(context),
                  icon: Icons.replay,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: () {
              _showExitInterstitial();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home, color: ThemeService.instance.subtitleColor),
            label: Text(loc.duelHome, style: GoogleFonts.poppins(color: ThemeService.instance.subtitleColor)),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _getDimensionName(String dimKey, AppLocalizations loc) {
    switch (dimKey) {
      case 'emotional': return loc.duelDimEmotional;
      case 'passion': return loc.duelDimPassion;
      case 'intellectual': return loc.duelDimIntellectual;
      case 'destiny': return loc.duelDimDestiny;
      case 'tiebreaker': return Localizations.localeOf(context).languageCode == 'en' ? 'Final Destiny ⚡' : 'Destino Final ⚡';
      default: return dimKey;
    }
  }

  Widget _totalColumn(String name, int total, Color color) {
    return Column(
      children: [
        Text(name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('$total%', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  String _getClosingMessage(DuelResult r, bool isEn) {
    if (r.overallWinner == -1) {
      return isEn ? 'Your heart is perfectly divided... time to scan more! 😏' : 'Tu corazón está perfectamente dividido... ¡hora de escanear más! 😏';
    }
    final diff = (r.winsA - r.winsB).abs();
    if (diff >= 3) {
      return isEn ? 'A total domination! Your heart already knows. 💯' : '¡Dominio total! Tu corazón ya lo sabe. 💯';
    }
    if (diff == 2) {
      return isEn ? 'Clear winner, but the other one put up a fight! ⚡' : '¡Ganador claro, pero el otro dio pelea! ⚡';
    }
    return isEn ? 'So close! Your heart is torn... 💔' : '¡Qué reñido! Tu corazón está dividido... 💔';
  }

  void _shareResult() {
    final r = widget.result;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final text = isEn
        ? '⚔️ Love Duel: ${r.crushA} vs ${r.crushB}\n🏆 ${r.winnerName.isEmpty ? "Tie!" : "${r.winnerName} wins $_scoreA-$_scoreB!"}\n❤️ ${r.crushA}: ${r.totalA}% | ${r.crushB}: ${r.totalB}%\n\nTry it on Scanner Crush!'
        : '⚔️ Duelo de Amor: ${r.crushA} vs ${r.crushB}\n🏆 ${r.winnerName.isEmpty ? "¡Empate!" : "¡${r.winnerName} gana $_scoreA-$_scoreB!"}\n❤️ ${r.crushA}: ${r.totalA}% | ${r.crushB}: ${r.totalB}%\n\n¡Pruébalo en Scanner Crush!';
    Share.share(text);
  }

  void _showExitInterstitial() {
    if (!MonetizationService.instance.isPremium) {
      AdMobService.instance.showInterstitialAd();
    }
  }
}

/// Small wrapper to use AnimationController as listenable builder
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({super.key, required this.animation, required this.builder, this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: animation,
      builder: (context, child) => builder(context, child),
      child: child,
    );
  }
}
