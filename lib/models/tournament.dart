enum TournamentFormat { four, eight, sixteen }

enum TournamentStatus { setup, inProgress, completed }

class TournamentParticipant {
  final String name;
  final bool isCelebrity;
  bool isEliminated;
  bool isRevived;

  TournamentParticipant({
    required this.name,
    this.isCelebrity = false,
    this.isEliminated = false,
    this.isRevived = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'isCelebrity': isCelebrity,
    'isEliminated': isEliminated,
    'isRevived': isRevived,
  };

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    return TournamentParticipant(
      name: json['name'] as String? ?? '',
      isCelebrity: json['isCelebrity'] as bool? ?? false,
      isEliminated: json['isEliminated'] as bool? ?? false,
      isRevived: json['isRevived'] as bool? ?? false,
    );
  }
}

class TournamentMatch {
  final TournamentParticipant participant1;
  final TournamentParticipant participant2;
  TournamentParticipant? winner;
  int percentage1;
  int percentage2;
  final int roundNumber;
  final int matchIndex;
  bool isPlayed;

  TournamentMatch({
    required this.participant1,
    required this.participant2,
    this.winner,
    this.percentage1 = 0,
    this.percentage2 = 0,
    required this.roundNumber,
    required this.matchIndex,
    this.isPlayed = false,
  });

  Map<String, dynamic> toJson() => {
    'participant1': participant1.toJson(),
    'participant2': participant2.toJson(),
    'winner': winner?.toJson(),
    'percentage1': percentage1,
    'percentage2': percentage2,
    'roundNumber': roundNumber,
    'matchIndex': matchIndex,
    'isPlayed': isPlayed,
  };
}

class Tournament {
  final String userName;
  final TournamentFormat format;
  List<TournamentParticipant> participants;
  List<List<TournamentMatch>> rounds; // rounds[0] = first round matches, etc.
  int currentRound;
  int currentMatchInRound;
  TournamentStatus status;
  TournamentParticipant? champion;   // 🥇
  TournamentParticipant? runnerUp;   // 🥈
  TournamentParticipant? thirdPlace; // 🥉
  final DateTime createdAt;

  Tournament({
    required this.userName,
    required this.format,
    required this.participants,
    List<List<TournamentMatch>>? rounds,
    this.currentRound = 0,
    this.currentMatchInRound = 0,
    this.status = TournamentStatus.setup,
    this.champion,
    this.runnerUp,
    this.thirdPlace,
    DateTime? createdAt,
  })  : rounds = rounds ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get participantCount {
    switch (format) {
      case TournamentFormat.four:
        return 4;
      case TournamentFormat.eight:
        return 8;
      case TournamentFormat.sixteen:
        return 16;
    }
  }

  int get totalRounds {
    switch (format) {
      case TournamentFormat.four:
        return 2; // Semi + Final
      case TournamentFormat.eight:
        return 3; // Quarter + Semi + Final
      case TournamentFormat.sixteen:
        return 4; // Round of 16 + Quarter + Semi + Final
    }
  }

  bool get isComplete => status == TournamentStatus.completed;

  TournamentMatch? get currentMatch {
    if (currentRound >= rounds.length) return null;
    final roundMatches = rounds[currentRound];
    if (currentMatchInRound >= roundMatches.length) return null;
    return roundMatches[currentMatchInRound];
  }

  bool get isCurrentRoundComplete {
    if (currentRound >= rounds.length) return true;
    return rounds[currentRound].every((m) => m.isPlayed);
  }

  int get totalMatchesPlayed {
    int count = 0;
    for (final round in rounds) {
      for (final match in round) {
        if (match.isPlayed) count++;
      }
    }
    return count;
  }

  int get totalMatches {
    int count = 0;
    for (final round in rounds) {
      count += round.length;
    }
    return count;
  }

  /// Share text for the tournament podium
  String getShareText({String languageCode = 'es'}) {
    final isEn = languageCode == 'en';
    final buffer = StringBuffer();

    buffer.writeln(isEn ? '🏆 LOVE TOURNAMENT RESULTS! 🏆' : '🏆 ¡RESULTADOS DEL TORNEO DEL AMOR! 🏆');
    buffer.writeln();
    if (champion != null) {
      buffer.writeln('🥇 ${champion!.name}');
    }
    if (runnerUp != null) {
      buffer.writeln('🥈 ${runnerUp!.name}');
    }
    if (thirdPlace != null) {
      buffer.writeln('🥉 ${thirdPlace!.name}');
    }
    buffer.writeln();
    buffer.writeln(isEn
        ? 'Who is YOUR ultimate crush? 👀'
        : '¿Quién es TU crush definitivo? 👀');
    buffer.writeln(isEn
        ? 'Download: Crush Scanner 💕'
        : 'Descárgalo: Escáner de Crush 💕');
    buffer.writeln();
    buffer.writeln('#LoveTournament #CrushScanner #Crush #Love');

    return buffer.toString();
  }
}
