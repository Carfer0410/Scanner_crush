import 'dart:math';
import '../models/tournament.dart';
import 'crush_service.dart';

class TournamentService {
  static final TournamentService _instance = TournamentService._internal();
  static TournamentService get instance => _instance;
  TournamentService._internal();

  final Random _random = Random();

  /// Creates a new tournament with shuffled participants
  Tournament createTournament({
    required String userName,
    required List<TournamentParticipant> participants,
    required TournamentFormat format,
  }) {
    // Shuffle participants for random bracket placement
    final shuffled = List<TournamentParticipant>.from(participants)..shuffle(_random);

    final tournament = Tournament(
      userName: userName,
      format: format,
      participants: shuffled,
      status: TournamentStatus.inProgress,
    );

    // Generate the first round of matches
    _generateFirstRound(tournament);

    return tournament;
  }

  /// Generate first round bracket pairings
  void _generateFirstRound(Tournament tournament) {
    final participants = tournament.participants;
    final firstRoundMatches = <TournamentMatch>[];

    for (int i = 0; i < participants.length; i += 2) {
      firstRoundMatches.add(TournamentMatch(
        participant1: participants[i],
        participant2: participants[i + 1],
        roundNumber: 0,
        matchIndex: i ~/ 2,
      ));
    }

    tournament.rounds = [firstRoundMatches];
    tournament.currentRound = 0;
    tournament.currentMatchInRound = 0;
  }

  /// Play a match: calculate compatibility of each participant with the user
  /// The one with higher compatibility wins
  TournamentMatch playMatch(Tournament tournament, String userName) {
    final match = tournament.currentMatch!;

    // Generate compatibility percentages using the same algorithm as CrushService
    match.percentage1 = _generateCompatibilityPercentage(
      userName,
      match.participant1.name,
    );
    match.percentage2 = _generateCompatibilityPercentage(
      userName,
      match.participant2.name,
    );

    // Determine winner — higher percentage wins
    // If tie, add small random factor
    if (match.percentage1 == match.percentage2) {
      // Tiebreaker: random slight advantage
      if (_random.nextBool()) {
        match.percentage1 += 1;
      } else {
        match.percentage2 += 1;
      }
    }

    if (match.percentage1 > match.percentage2) {
      match.winner = match.participant1;
      match.participant2.isEliminated = true;
    } else {
      match.winner = match.participant2;
      match.participant1.isEliminated = true;
    }

    match.isPlayed = true;

    // Advance to next match or next round
    _advanceAfterMatch(tournament);

    return match;
  }

  /// Advance tournament state after a match
  void _advanceAfterMatch(Tournament tournament) {
    final currentRoundMatches = tournament.rounds[tournament.currentRound];

    // Check if all matches in current round are played
    if (currentRoundMatches.every((m) => m.isPlayed)) {
      // Current round is complete
      final winners = currentRoundMatches.map((m) => m.winner!).toList();

      if (winners.length == 1) {
        // Tournament is over — we have a champion
        tournament.champion = winners.first;
        // Runner-up: the loser of the final
        final finalMatch = currentRoundMatches.first;
        tournament.runnerUp = finalMatch.winner == finalMatch.participant1
            ? finalMatch.participant2
            : finalMatch.participant1;
        // Third place: find the losers of the semi-finals
        if (tournament.rounds.length >= 2) {
          final semiRound = tournament.rounds[tournament.rounds.length - 2];
          // Get the semi-final losers
          final semiLosers = semiRound.map((m) {
            return m.winner == m.participant1 ? m.participant2 : m.participant1;
          }).toList();
          // Third place is the semi-final loser with highest percentage
          if (semiLosers.isNotEmpty) {
            // Pick the one who had the higher percentage in their semi-final match
            int bestPct = 0;
            TournamentParticipant? best;
            for (int i = 0; i < semiLosers.length; i++) {
              final loser = semiLosers[i];
              final match = semiRound[i];
              final pct = match.participant1 == loser
                  ? match.percentage1
                  : match.percentage2;
              if (pct > bestPct || best == null) {
                bestPct = pct;
                best = loser;
              }
            }
            tournament.thirdPlace = best;
          }
        } else {
          // Format of 4: semi-losers
          tournament.thirdPlace = null;
        }

        tournament.status = TournamentStatus.completed;
      } else {
        // Generate next round with winners
        _generateNextRound(tournament, winners);
      }
    } else {
      // Move to next unplayed match in current round
      tournament.currentMatchInRound++;
    }
  }

  /// Generate next round from winners of previous round
  void _generateNextRound(
    Tournament tournament,
    List<TournamentParticipant> winners,
  ) {
    final nextRoundNumber = tournament.rounds.length;
    final nextRoundMatches = <TournamentMatch>[];

    for (int i = 0; i < winners.length; i += 2) {
      nextRoundMatches.add(TournamentMatch(
        participant1: winners[i],
        participant2: winners[i + 1],
        roundNumber: nextRoundNumber,
        matchIndex: i ~/ 2,
      ));
    }

    tournament.rounds.add(nextRoundMatches);
    tournament.currentRound = nextRoundNumber;
    tournament.currentMatchInRound = 0;
  }

  /// Revive an eliminated participant.
  /// The revived player replaces the winner who beat them in the next round,
  /// keeping bracket integrity intact.
  bool reviveParticipant(Tournament tournament, TournamentParticipant participant) {
    if (!participant.isEliminated || participant.isRevived) return false;
    if (tournament.isComplete) return false;

    // 1) Find the match where this participant lost
    TournamentMatch? lostMatch;
    for (final round in tournament.rounds) {
      for (final m in round) {
        if (m.isPlayed &&
            m.winner != null &&
            (m.participant1 == participant || m.participant2 == participant) &&
            m.winner != participant) {
          lostMatch = m;
        }
      }
    }
    if (lostMatch == null) return false;

    // 2) The one who beat them
    final beater = lostMatch.winner!;

    // 3) Look for 'beater' in an upcoming (unplayed) match and replace them
    for (int r = lostMatch.roundNumber + 1; r < tournament.rounds.length; r++) {
      final roundMatches = tournament.rounds[r];
      for (int i = 0; i < roundMatches.length; i++) {
        final m = roundMatches[i];
        if (m.isPlayed) continue;
        if (m.participant1 == beater || m.participant2 == beater) {
          // Swap beater → revived participant
          roundMatches[i] = TournamentMatch(
            participant1: m.participant1 == beater ? participant : m.participant1,
            participant2: m.participant2 == beater ? participant : m.participant2,
            roundNumber: m.roundNumber,
            matchIndex: m.matchIndex,
          );
          participant.isEliminated = false;
          participant.isRevived = true;
          beater.isEliminated = true;
          // Prevent the newly-eliminated participant (the beater) from being
          // immediately eligible for another revive — mark as "revived"
          // so `getEliminatedParticipants` will exclude them.
          beater.isRevived = true;
          return true;
        }
      }
    }

    // 4) If 'beater' hasn't advanced to the next round yet (round not generated),
    //    do a direct swap: undo the match result so the revived player becomes
    //    the winner of that match instead.
    if (lostMatch.roundNumber == tournament.currentRound ||
        lostMatch.roundNumber == tournament.currentRound - 1) {
      lostMatch.winner = participant;
      participant.isEliminated = false;
      participant.isRevived = true;
      beater.isEliminated = true;
      beater.isRevived = true;
      return true;
    }

    return false;
  }

  /// Get recently eliminated participants that could be revived
  List<TournamentParticipant> getEliminatedParticipants(Tournament tournament) {
    return tournament.participants
        .where((p) => p.isEliminated && !p.isRevived)
        .toList();
  }

  /// Get round name for display
  String getRoundName(Tournament tournament, int roundIndex, {bool isEn = false}) {
    final totalRounds = tournament.totalRounds;
    final roundsFromEnd = totalRounds - roundIndex;

    switch (roundsFromEnd) {
      case 1:
        return isEn ? '🏆 Grand Final' : '🏆 Gran Final';
      case 2:
        return isEn ? '⚡ Semi-Finals' : '⚡ Semifinales';
      case 3:
        return isEn ? '🔥 Quarter-Finals' : '🔥 Cuartos de Final';
      case 4:
        return isEn ? '💫 Round of 16' : '💫 Octavos de Final';
      default:
        return isEn ? 'Round ${roundIndex + 1}' : 'Ronda ${roundIndex + 1}';
    }
  }

  /// Get some random celebrities to suggest adding
  List<String> getRandomCelebrities(int count) {
    final celebrities = CrushService.instance.getCelebrityNames();
    celebrities.shuffle(_random);
    return celebrities.take(count).toList();
  }

  // ---------------------------------------------------------------------------
  // Same algorithm used by CrushService for consistency
  // ---------------------------------------------------------------------------
  int _generateCompatibilityPercentage(String name1, String name2) {
    final sorted = [name1.toLowerCase(), name2.toLowerCase()]..sort();
    final combined = sorted.join();
    var hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = ((hash << 5) - hash + combined.codeUnitAt(i)) & 0xffffffff;
    }
    final positiveHash = hash.abs();
    final percentage = 30 + (positiveHash % 71);
    return percentage.clamp(30, 100);
  }
}
