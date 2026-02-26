import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tournament.dart';
import 'crush_service.dart';
import 'admob_service.dart';
import 'monetization_service.dart';
import 'secure_time_service.dart';
import 'logger_service.dart';
import 'global_economy_service.dart';

enum CoinSpendResult { success, insufficientCoins, actionNotAvailable }

class TournamentPassState {
  final bool isPremium;
  final int remainingEntriesToday;
  final int adTicketsRemainingToday;
  final int coins;
  final int streakDays;

  const TournamentPassState({
    required this.isPremium,
    required this.remainingEntriesToday,
    required this.adTicketsRemainingToday,
    required this.coins,
    required this.streakDays,
  });
}

class WeeklyMission {
  final String id;
  final String titleEn;
  final String titleEs;
  final int target;
  final int progress;
  final int rewardCoins;
  final bool claimed;

  const WeeklyMission({
    required this.id,
    required this.titleEn,
    required this.titleEs,
    required this.target,
    required this.progress,
    required this.rewardCoins,
    required this.claimed,
  });

  bool get completed => progress >= target;
}

class TournamentCompletionReward {
  final int coinsEarned;
  final int streakDays;
  final bool firstCompletionToday;

  const TournamentCompletionReward({
    required this.coinsEarned,
    required this.streakDays,
    required this.firstCompletionToday,
  });
}

class TournamentService {
  static final TournamentService _instance = TournamentService._internal();
  static TournamentService get instance => _instance;
  TournamentService._internal();

  final Random _random = Random();
  SharedPreferences? _prefs;

  static const int _dailyFreeEntries = int.fromEnvironment(
    'AB_TOURNAMENT_DAILY_FREE_ENTRIES',
    defaultValue: 2,
  );
  static const int _maxAdEntriesPerDay = int.fromEnvironment(
    'AB_TOURNAMENT_MAX_AD_ENTRIES_PER_DAY',
    defaultValue: 3,
  );
  static const int _baseCoinReward = int.fromEnvironment(
    'AB_TOURNAMENT_BASE_COIN_REWARD',
    defaultValue: 12,
  );
  static const int _firstDailyCompletionBonus = int.fromEnvironment(
    'AB_TOURNAMENT_FIRST_DAILY_COMPLETION_BONUS',
    defaultValue: 20,
  );
  static const int _ticketCoinCost = int.fromEnvironment(
    'AB_TOURNAMENT_TICKET_COIN_COST',
    defaultValue: 28,
  );
  static const int _reviveCoinCost = int.fromEnvironment(
    'AB_TOURNAMENT_REVIVE_COIN_COST',
    defaultValue: 35,
  );
  static const int _bundleDiscount = int.fromEnvironment(
    'AB_TOURNAMENT_BUNDLE3_DISCOUNT',
    defaultValue: 8,
  );

  int get ticketCoinCost => _ticketCoinCost;
  int get reviveCoinCost => _reviveCoinCost;

  Map<String, int> getEconomyConfig() {
    return {
      'daily_free_entries': _dailyFreeEntries,
      'max_ad_entries_per_day': _maxAdEntriesPerDay,
      'base_coin_reward': _baseCoinReward,
      'first_daily_completion_bonus': _firstDailyCompletionBonus,
      'ticket_coin_cost': _ticketCoinCost,
      'revive_coin_cost': _reviveCoinCost,
      'bundle3_discount': _bundleDiscount,
    };
  }

  Future<SharedPreferences> get _safePrefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _todayKey() =>
      SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];

  String _weekKey() {
    final d = SecureTimeService.instance.getSecureDate().toUtc();
    final firstDay = DateTime.utc(d.year, 1, 1);
    final daysOffset = d.difference(firstDay).inDays;
    final week = ((daysOffset + firstDay.weekday - 1) ~/ 7) + 1;
    return '${d.year}-W$week';
  }

  int _weeklyCounter(SharedPreferences prefs, String counterId) {
    return prefs.getInt('tournament_weekly_${_weekKey()}_$counterId') ?? 0;
  }

  Future<void> _incrementWeeklyCounter(String counterId, {int by = 1}) async {
    final prefs = await _safePrefs;
    final key = 'tournament_weekly_${_weekKey()}_$counterId';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + by);
  }

  int _formatCoinBonus(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.four:
        return 4;
      case TournamentFormat.eight:
        return 8;
      case TournamentFormat.sixteen:
        return 14;
    }
  }

  Future<TournamentPassState> getPassState() async {
    final prefs = await _safePrefs;
    final isPremium = await MonetizationService.instance.isPremiumAsync();
    final today = _todayKey();

    final entriesDate = prefs.getString('tournament_entries_date');
    final entriesUsed = entriesDate == today ? (prefs.getInt('tournament_entries_used') ?? 0) : 0;

    final adDate = prefs.getString('tournament_ad_entries_date');
    final adEarned = adDate == today ? (prefs.getInt('tournament_ad_entries_earned') ?? 0) : 0;
    final shopDate = prefs.getString('tournament_shop_tickets_date');
    final shopTickets = shopDate == today ? (prefs.getInt('tournament_shop_tickets_today') ?? 0) : 0;

    final coins = await GlobalEconomyService.instance.getCoins();
    final streak = prefs.getInt('tournament_daily_streak') ?? 0;

    if (isPremium) {
      return TournamentPassState(
        isPremium: true,
        remainingEntriesToday: -1,
        adTicketsRemainingToday: 0,
        coins: coins,
        streakDays: streak,
      );
    }

    final available = _dailyFreeEntries + adEarned + shopTickets;
    final remaining = (available - entriesUsed).clamp(0, available);
    final adRemaining = (_maxAdEntriesPerDay - adEarned).clamp(0, _maxAdEntriesPerDay);

    return TournamentPassState(
      isPremium: false,
      remainingEntriesToday: remaining,
      adTicketsRemainingToday: adRemaining,
      coins: coins,
      streakDays: streak,
    );
  }

  Future<bool> canStartTournament() async {
    final state = await getPassState();
    return state.isPremium || state.remainingEntriesToday > 0;
  }

  Future<bool> consumeTournamentEntry() async {
    final prefs = await _safePrefs;
    final state = await getPassState();
    if (!state.isPremium && state.remainingEntriesToday <= 0) return false;

    if (state.isPremium) return true;

    final today = _todayKey();
    await prefs.setString('tournament_entries_date', today);
    final current = prefs.getInt('tournament_entries_used') ?? 0;
    await prefs.setInt('tournament_entries_used', current + 1);
    return true;
  }

  Future<bool> watchAdForExtraTournamentEntry() async {
    final prefs = await _safePrefs;
    final state = await getPassState();
    if (state.isPremium) return false;
    if (state.adTicketsRemainingToday <= 0) return false;

    final shown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        final today = _todayKey();
        final adDate = prefs.getString('tournament_ad_entries_date');
        final current = adDate == today ? (prefs.getInt('tournament_ad_entries_earned') ?? 0) : 0;
        final next = (current + 1).clamp(0, _maxAdEntriesPerDay);
        await prefs.setString('tournament_ad_entries_date', today);
        await prefs.setInt('tournament_ad_entries_earned', next);
        await _incrementWeeklyCounter('ads_tickets_watched');
      },
    );

    return shown;
  }

  Future<TournamentCompletionReward> recordTournamentCompletion(
    Tournament tournament,
  ) async {
    final prefs = await _safePrefs;
    final today = _todayKey();

    final completionDate = prefs.getString('tournament_completion_date');
    final completionsToday = completionDate == today ? (prefs.getInt('tournament_completions_today') ?? 0) : 0;
    final firstToday = completionsToday == 0;

    final streakDate = prefs.getString('tournament_streak_date');
    int streak = prefs.getInt('tournament_daily_streak') ?? 0;
    if (streakDate != today) {
      if (streakDate == null) {
        streak = 1;
      } else {
        final last = DateTime.tryParse(streakDate);
        final now = SecureTimeService.instance.getSecureDate();
        if (last != null && now.difference(last).inDays == 1) {
          streak += 1;
        } else {
          streak = 1;
        }
      }
      await prefs.setString('tournament_streak_date', today);
      await prefs.setInt('tournament_daily_streak', streak);
    }

    final streakBonus = (streak > 0 && streak % 3 == 0) ? 15 : 0;
    final coinsEarned = _baseCoinReward +
        _formatCoinBonus(tournament.format) +
        (firstToday ? _firstDailyCompletionBonus : 0) +
        streakBonus;

    await GlobalEconomyService.instance.addCoins(coinsEarned);
    await prefs.setString('tournament_completion_date', today);
    await prefs.setInt('tournament_completions_today', completionsToday + 1);
    await prefs.setInt(
      'tournament_total_completions',
      (prefs.getInt('tournament_total_completions') ?? 0) + 1,
    );
    await _incrementWeeklyCounter('tournaments_completed');
    if (tournament.format == TournamentFormat.sixteen) {
      await _incrementWeeklyCounter('sixteen_completed');
    }

    LoggerService.info(
      'Tournament reward granted: +$coinsEarned coins (streak=$streak, firstToday=$firstToday)',
      origin: 'TournamentService',
    );

    return TournamentCompletionReward(
      coinsEarned: coinsEarned,
      streakDays: streak,
      firstCompletionToday: firstToday,
    );
  }

  Future<List<WeeklyMission>> getWeeklyMissions() async {
    final prefs = await _safePrefs;
    final weekKey = _weekKey();

    final missions = <WeeklyMission>[
      WeeklyMission(
        id: 'play_5',
        titleEn: 'Complete 5 tournaments',
        titleEs: 'Completa 5 torneos',
        target: 5,
        progress: _weeklyCounter(prefs, 'tournaments_completed'),
        rewardCoins: 60,
        claimed: prefs.getBool('tournament_weekly_${weekKey}_claimed_play_5') ?? false,
      ),
      WeeklyMission(
        id: 'ads_3',
        titleEn: 'Watch 3 ticket ads',
        titleEs: 'Mira 3 anuncios de ticket',
        target: 3,
        progress: _weeklyCounter(prefs, 'ads_tickets_watched'),
        rewardCoins: 40,
        claimed: prefs.getBool('tournament_weekly_${weekKey}_claimed_ads_3') ?? false,
      ),
      WeeklyMission(
        id: 'format_16',
        titleEn: 'Finish 1 tournament (16 players)',
        titleEs: 'Termina 1 torneo de 16',
        target: 1,
        progress: _weeklyCounter(prefs, 'sixteen_completed'),
        rewardCoins: 90,
        claimed: prefs.getBool('tournament_weekly_${weekKey}_claimed_format_16') ?? false,
      ),
    ];

    return missions;
  }

  Future<int> claimWeeklyMission(String missionId) async {
    final prefs = await _safePrefs;
    final missions = await getWeeklyMissions();
    final mission = missions.cast<WeeklyMission?>().firstWhere(
      (m) => m?.id == missionId,
      orElse: () => null,
    );
    if (mission == null || !mission.completed || mission.claimed) return 0;

    final weekKey = _weekKey();
    await prefs.setBool('tournament_weekly_${weekKey}_claimed_${mission.id}', true);
    await GlobalEconomyService.instance.addCoins(mission.rewardCoins);
    return mission.rewardCoins;
  }

  Future<CoinSpendResult> buyTournamentTicketsWithCoins({int quantity = 1}) async {
    if (quantity < 1) return CoinSpendResult.actionNotAvailable;
    final prefs = await _safePrefs;

    final totalCost = _ticketCoinCost * quantity;
    final coins = await GlobalEconomyService.instance.getCoins();
    if (coins < totalCost) return CoinSpendResult.insufficientCoins;

    final today = _todayKey();
    final date = prefs.getString('tournament_shop_tickets_date');
    final current = date == today ? (prefs.getInt('tournament_shop_tickets_today') ?? 0) : 0;

    final spent = await GlobalEconomyService.instance.spendCoins(totalCost);
    if (!spent) return CoinSpendResult.insufficientCoins;
    await prefs.setString('tournament_shop_tickets_date', today);
    await prefs.setInt('tournament_shop_tickets_today', current + quantity);
    return CoinSpendResult.success;
  }

  Future<CoinSpendResult> buyTournamentTicketBundle3() async {
    final prefs = await _safePrefs;
    final bundleCost = (_ticketCoinCost * 3) - _bundleDiscount;
    final coins = await GlobalEconomyService.instance.getCoins();
    if (coins < bundleCost) return CoinSpendResult.insufficientCoins;

    final today = _todayKey();
    final date = prefs.getString('tournament_shop_tickets_date');
    final current = date == today ? (prefs.getInt('tournament_shop_tickets_today') ?? 0) : 0;

    final spent = await GlobalEconomyService.instance.spendCoins(bundleCost);
    if (!spent) return CoinSpendResult.insufficientCoins;
    await prefs.setString('tournament_shop_tickets_date', today);
    await prefs.setInt('tournament_shop_tickets_today', current + 3);
    return CoinSpendResult.success;
  }

  Future<CoinSpendResult> reviveWithCoins(
    Tournament tournament,
    TournamentParticipant participant,
  ) async {
    if (tournament.isComplete || !participant.isEliminated || participant.isRevived) {
      return CoinSpendResult.actionNotAvailable;
    }

    final coins = await GlobalEconomyService.instance.getCoins();
    if (coins < _reviveCoinCost) return CoinSpendResult.insufficientCoins;

    final ok = reviveParticipant(tournament, participant);
    if (!ok) return CoinSpendResult.actionNotAvailable;

    final spent = await GlobalEconomyService.instance.spendCoins(_reviveCoinCost);
    if (!spent) return CoinSpendResult.insufficientCoins;
    return CoinSpendResult.success;
  }

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
