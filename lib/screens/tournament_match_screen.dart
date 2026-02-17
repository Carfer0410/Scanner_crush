import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/theme_service.dart';
import '../services/audio_service.dart';

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
  late Animation<double> _pct1Animation;
  late Animation<double> _pct2Animation;

  bool _showVS = false;
  bool _showPercentages = false;
  bool _showWinner = false;
  TournamentMatch? _playedMatch;

  @override
  void initState() {
    super.initState();

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

    _pct1Animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    _pct2Animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _percentageController, curve: Curves.easeOutBack),
    );

    _startMatchSequence();
  }

  void _startMatchSequence() async {
    // Step 1: Show VS animation
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showVS = true);
    _vsController.forward();
    HapticFeedback.mediumImpact();

    // Step 2: Play the match
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    
    _playedMatch = TournamentService.instance.playMatch(
      widget.tournament,
      widget.tournament.userName,
    );

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

    // Step 4: Reveal winner
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _showWinner = true);
    _winnerController.forward();
    HapticFeedback.heavyImpact();
    AudioService.instance.playCompatibilityResult(_playedMatch!.winner == _playedMatch!.participant1 
        ? _playedMatch!.percentage1 
        : _playedMatch!.percentage2);

    // Step 5: Wait and callback
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    widget.onMatchComplete();
  }

  @override
  void dispose() {
    _vsController.dispose();
    _percentageController.dispose();
    _winnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.tournament.currentMatch ?? _playedMatch;
    if (match == null) return const SizedBox.shrink();

    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final roundName = TournamentService.instance.getRoundName(
      widget.tournament,
      match.roundNumber,
      isEn: isEn,
    );

    return Scaffold(
      backgroundColor: Colors.black,
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

          SafeArea(
            child: Column(
              children: [
                // Round header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    roundName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ),

                const Spacer(),

                // Participant 1
                _buildParticipantCard(
                  match.participant1,
                  _pct1Animation,
                  isWinner: _showWinner &&
                      _playedMatch?.winner == match.participant1,
                  isLoser: _showWinner &&
                      _playedMatch?.winner != match.participant1,
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
                  match.participant2,
                  _pct2Animation,
                  isWinner: _showWinner &&
                      _playedMatch?.winner == match.participant2,
                  isLoser: _showWinner &&
                      _playedMatch?.winner != match.participant2,
                  slideFrom: const Offset(1, 0),
                ),

                const Spacer(),

                // Winner announcement
                if (_showWinner && _playedMatch != null)
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _winnerController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade600,
                            Colors.orange.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              '${_playedMatch!.winner!.name} ${isEn ? "wins!" : "¡gana!"}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text('🎉', style: TextStyle(fontSize: 28)),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
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
