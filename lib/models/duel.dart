/// Represents a single round in a Love Duel.
class DuelRound {
  final String dimensionKey; // emotional, passion, intellectual, destiny
  final int scoreA;
  final int scoreB;

  const DuelRound({
    required this.dimensionKey,
    required this.scoreA,
    required this.scoreB,
  });

  /// Which contender won this round: 0 = A, 1 = B, -1 = tie.
  int get winner => scoreA > scoreB ? 0 : (scoreB > scoreA ? 1 : -1);
}

/// Full result of a Love Duel between two crushes.
class DuelResult {
  final String userName;
  final String crushA;
  final String crushB;
  final List<DuelRound> rounds;
  final int totalA; // overall compatibility A
  final int totalB; // overall compatibility B

  const DuelResult({
    required this.userName,
    required this.crushA,
    required this.crushB,
    required this.rounds,
    required this.totalA,
    required this.totalB,
  });

  int get winsA => rounds.where((r) => r.winner == 0).length;
  int get winsB => rounds.where((r) => r.winner == 1).length;

  /// Overall winner: 0 = crushA, 1 = crushB, -1 = tie.
  int get overallWinner {
    if (winsA > winsB) return 0;
    if (winsB > winsA) return 1;
    // Tie-breaker: higher total compatibility
    if (totalA > totalB) return 0;
    if (totalB > totalA) return 1;
    return -1;
  }

  String get winnerName => overallWinner == 0 ? crushA : (overallWinner == 1 ? crushB : '');
}
