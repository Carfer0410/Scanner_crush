import 'package:shared_preferences/shared_preferences.dart';
import 'admob_service.dart';
import 'analytics_service.dart';
import 'monetization_service.dart';
import 'secure_time_service.dart';
import 'global_economy_service.dart';
import 'streak_service.dart';

enum ScannerCoinSpendResult {
  success,
  insufficientCoins,
  dailyLimitReached,
  premiumNotNeeded,
}

class ScanDailyMission {
  final String id;
  final String titleEn;
  final String titleEs;
  final int target;
  final int progress;
  final int rewardCoins;
  final bool claimed;

  const ScanDailyMission({
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

class ScannerEconomySnapshot {
  final int coins;
  final int streakDays;
  final int adCoinClaimsToday;
  final int scanPackBuysToday;
  final int nextScanPackCost;
  final int remainingScanPackBuys;

  const ScannerEconomySnapshot({
    required this.coins,
    required this.streakDays,
    required this.adCoinClaimsToday,
    required this.scanPackBuysToday,
    required this.nextScanPackCost,
    required this.remainingScanPackBuys,
  });
}

class ScannerEconomyService {
  static final ScannerEconomyService _instance = ScannerEconomyService._internal();
  static ScannerEconomyService get instance => _instance;
  ScannerEconomyService._internal();

  static const int _baseCoinPerScanFree = 1;
  static const int _baseCoinPerScanPremium = 2;
  static const int _firstScanDayBonus = 2;
  static const int _streakBonusEveryDays = 5;
  static const int _streakBonusCoins = 5;

  static const int _coinAdReward = 30;
  static const int _maxCoinAdsPerDay = 2;

  static const List<int> _scanPackCostsByBuyOrder = <int>[60, 90];
  static const int _scanPackScans = 2;
  static const int _maxScanPacksPerDay = 2;

  SharedPreferences? _prefs;

  int get scanPackCost => _scanPackCostsByBuyOrder.first;
  int get scanPackScans => _scanPackScans;
  int get coinAdReward => _coinAdReward;
  int get maxCoinAdsPerDay => _maxCoinAdsPerDay;
  int get maxScanPacksPerDay => _maxScanPacksPerDay;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  String _today() => SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
  Future<int> getCoins() async {
    return GlobalEconomyService.instance.getCoins();
  }

  Future<ScannerEconomySnapshot> getSnapshot() async {
    final prefs = await _p;
    final today = _today();
    final adDate = prefs.getString('scanner_coin_ad_date');
    final packDate = prefs.getString('scanner_scan_pack_date');
    final scanPackBuysToday = packDate == today ? (prefs.getInt('scanner_scan_pack_count') ?? 0) : 0;
    return ScannerEconomySnapshot(
      coins: await GlobalEconomyService.instance.getCoins(),
      streakDays: StreakService.instance.currentStreak,
      adCoinClaimsToday: adDate == today ? (prefs.getInt('scanner_coin_ad_count') ?? 0) : 0,
      scanPackBuysToday: scanPackBuysToday,
      nextScanPackCost: _scanPackCostForBuyIndex(scanPackBuysToday),
      remainingScanPackBuys: (_maxScanPacksPerDay - scanPackBuysToday).clamp(0, _maxScanPacksPerDay),
    );
  }

  int _scanPackCostForBuyIndex(int buyIndex) {
    if (buyIndex <= 0) return _scanPackCostsByBuyOrder.first;
    if (buyIndex >= _scanPackCostsByBuyOrder.length) {
      return _scanPackCostsByBuyOrder.last;
    }
    return _scanPackCostsByBuyOrder[buyIndex];
  }

  Future<int> getCurrentScanPackCost() async {
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_scan_pack_date');
    final buys = date == today ? (prefs.getInt('scanner_scan_pack_count') ?? 0) : 0;
    return _scanPackCostForBuyIndex(buys);
  }

  Future<int> getRemainingScanPackBuysToday() async {
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_scan_pack_date');
    final buys = date == today ? (prefs.getInt('scanner_scan_pack_count') ?? 0) : 0;
    return (_maxScanPacksPerDay - buys).clamp(0, _maxScanPacksPerDay);
  }

  Future<int> rewardScan({required bool isCelebrity}) async {
    final prefs = await _p;
    final today = _today();

    final scansDate = prefs.getString('scanner_scans_date');
    final scansToday = scansDate == today ? (prefs.getInt('scanner_scans_today') ?? 0) : 0;
    final firstScanToday = scansToday == 0;

    await prefs.setString('scanner_scans_date', today);
    await prefs.setInt('scanner_scans_today', scansToday + 1);

    if (isCelebrity) {
      final cDate = prefs.getString('scanner_celebrity_date');
      final cCount = cDate == today ? (prefs.getInt('scanner_celebrity_count') ?? 0) : 0;
      await prefs.setString('scanner_celebrity_date', today);
      await prefs.setInt('scanner_celebrity_count', cCount + 1);
    } else {
      final pDate = prefs.getString('scanner_personal_date');
      final pCount = pDate == today ? (prefs.getInt('scanner_personal_count') ?? 0) : 0;
      await prefs.setString('scanner_personal_date', today);
      await prefs.setInt('scanner_personal_count', pCount + 1);
    }

    final streak = StreakService.instance.currentStreak;

    final isPremium = await MonetizationService.instance.isPremiumAsync();
    int earned = isPremium ? _baseCoinPerScanPremium : _baseCoinPerScanFree;
    if (firstScanToday) {
      earned += _firstScanDayBonus;
    }
    if (firstScanToday && streak > 0 && streak % _streakBonusEveryDays == 0) {
      earned += _streakBonusCoins;
    }

    await GlobalEconomyService.instance.addCoins(earned);

    await AnalyticsService.instance.trackEvent(
      'scanner_coin_reward',
      params: {
        'earned': earned,
        'is_celebrity': isCelebrity,
        'first_today': firstScanToday,
        'streak_days': streak,
      },
    );

    return earned;
  }

  Future<void> recordShareAction() async {
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_share_date');
    final current = date == today ? (prefs.getInt('scanner_share_count') ?? 0) : 0;
    await prefs.setString('scanner_share_date', today);
    await prefs.setInt('scanner_share_count', current + 1);
    await AnalyticsService.instance.trackEvent('scanner_share_recorded');
  }

  Future<void> recordHighScore(int percentage) async {
    if (percentage < 85) return;
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_highscore_date');
    final current = date == today ? (prefs.getInt('scanner_highscore_count') ?? 0) : 0;
    await prefs.setString('scanner_highscore_date', today);
    await prefs.setInt('scanner_highscore_count', current + 1);
  }

  Future<void> recordTournamentForMission() async {
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_mission_tournament_date');
    final current = date == today ? (prefs.getInt('scanner_mission_tournament_count') ?? 0) : 0;
    await prefs.setString('scanner_mission_tournament_date', today);
    await prefs.setInt('scanner_mission_tournament_count', current + 1);
  }

  // ── Mission pool ──────────────────────────────────────────────

  /// All possible daily missions. 3 are selected each day via date-hash.
  static const List<_MissionTemplate> _missionPool = [
    // ── Personal scans ──
    _MissionTemplate(id: 'personal_1', titleEn: 'Do 1 personal scan', titleEs: 'Haz 1 escaneo personal', target: 1, reward: 2, counter: _Counter.personal),
    _MissionTemplate(id: 'personal_3', titleEn: 'Do 3 personal scans', titleEs: 'Haz 3 escaneos personales', target: 3, reward: 5, counter: _Counter.personal),
    _MissionTemplate(id: 'personal_5', titleEn: 'Do 5 personal scans', titleEs: 'Haz 5 escaneos personales', target: 5, reward: 8, counter: _Counter.personal),
    // ── Celebrity scans ──
    _MissionTemplate(id: 'celebrity_1', titleEn: 'Do 1 celebrity scan', titleEs: 'Haz 1 escaneo de celebridad', target: 1, reward: 2, counter: _Counter.celebrity),
    _MissionTemplate(id: 'celebrity_2', titleEn: 'Do 2 celebrity scans', titleEs: 'Haz 2 escaneos de celebridades', target: 2, reward: 5, counter: _Counter.celebrity),
    _MissionTemplate(id: 'celebrity_4', titleEn: 'Do 4 celebrity scans', titleEs: 'Haz 4 escaneos de celebridades', target: 4, reward: 8, counter: _Counter.celebrity),
    // ── Total scans (any type) ──
    _MissionTemplate(id: 'total_3', titleEn: 'Do 3 scans (any type)', titleEs: 'Haz 3 escaneos (cualquier tipo)', target: 3, reward: 3, counter: _Counter.total),
    _MissionTemplate(id: 'total_5', titleEn: 'Do 5 scans (any type)', titleEs: 'Haz 5 escaneos (cualquier tipo)', target: 5, reward: 6, counter: _Counter.total),
    _MissionTemplate(id: 'total_7', titleEn: 'Do 7 scans (any type)', titleEs: 'Haz 7 escaneos (cualquier tipo)', target: 7, reward: 10, counter: _Counter.total),
    // ── Shares ──
    _MissionTemplate(id: 'share_1', titleEn: 'Share 1 result', titleEs: 'Comparte 1 resultado', target: 1, reward: 4, counter: _Counter.share),
    _MissionTemplate(id: 'share_2', titleEn: 'Share 2 results', titleEs: 'Comparte 2 resultados', target: 2, reward: 7, counter: _Counter.share),
    // ── Tournaments ──
    _MissionTemplate(id: 'tournament_1', titleEn: 'Complete 1 tournament', titleEs: 'Completa 1 torneo', target: 1, reward: 6, counter: _Counter.tournament),
    _MissionTemplate(id: 'tournament_2', titleEn: 'Complete 2 tournaments', titleEs: 'Completa 2 torneos', target: 2, reward: 10, counter: _Counter.tournament),
    // ── High scores ──
    _MissionTemplate(id: 'highscore_1', titleEn: 'Get a result of 85%+', titleEs: 'Obtén un resultado de 85%+', target: 1, reward: 5, counter: _Counter.highscore),
    _MissionTemplate(id: 'highscore_2', titleEn: 'Get 2 results of 85%+', titleEs: 'Obtén 2 resultados de 85%+', target: 2, reward: 8, counter: _Counter.highscore),
    // ── Mixed combos ──
    _MissionTemplate(id: 'mix_both', titleEn: '1 personal + 1 celebrity scan', titleEs: '1 escaneo personal + 1 de celebridad', target: 2, reward: 4, counter: _Counter.mixBoth),
    _MissionTemplate(id: 'mix_scan_share', titleEn: '2 scans + 1 share', titleEs: '2 escaneos + 1 compartido', target: 3, reward: 5, counter: _Counter.mixScanShare),
    _MissionTemplate(id: 'explorer', titleEn: '1 scan + 1 share + 1 tournament', titleEs: '1 escaneo + 1 compartido + 1 torneo', target: 3, reward: 8, counter: _Counter.explorer),
  ];

  /// Deterministic daily selection: pick 3 missions from pool using date hash.
  List<int> _dailyMissionIndices() {
    final today = _today();
    // Simple hash from date string
    int hash = 0;
    for (int i = 0; i < today.length; i++) {
      hash = (hash * 31 + today.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final poolSize = _missionPool.length;
    final indices = <int>{};
    int attempt = 0;
    while (indices.length < 3 && attempt < 100) {
      final idx = ((hash + attempt * 7 + attempt * attempt * 13) & 0x7FFFFFFF) % poolSize;
      indices.add(idx);
      attempt++;
    }
    return indices.toList()..sort();
  }

  int _counterValue(SharedPreferences prefs, String today, _Counter counter,
      {required int personalCount,
      required int celebrityCount,
      required int shareCount,
      required int totalScans,
      required int tournamentCount,
      required int highscoreCount}) {
    switch (counter) {
      case _Counter.personal:
        return personalCount;
      case _Counter.celebrity:
        return celebrityCount;
      case _Counter.total:
        return totalScans;
      case _Counter.share:
        return shareCount;
      case _Counter.tournament:
        return tournamentCount;
      case _Counter.highscore:
        return highscoreCount;
      case _Counter.mixBoth:
        return personalCount.clamp(0, 1) + celebrityCount.clamp(0, 1);
      case _Counter.mixScanShare:
        return totalScans.clamp(0, 2) + shareCount.clamp(0, 1);
      case _Counter.explorer:
        return totalScans.clamp(0, 1) + shareCount.clamp(0, 1) + tournamentCount.clamp(0, 1);
    }
  }

  Future<List<ScanDailyMission>> getDailyMissions() async {
    final prefs = await _p;
    final today = _today();

    // Read all counters once
    final personalCount = prefs.getString('scanner_personal_date') == today ? (prefs.getInt('scanner_personal_count') ?? 0) : 0;
    final celebrityCount = prefs.getString('scanner_celebrity_date') == today ? (prefs.getInt('scanner_celebrity_count') ?? 0) : 0;
    final shareCount = prefs.getString('scanner_share_date') == today ? (prefs.getInt('scanner_share_count') ?? 0) : 0;
    final totalScans = prefs.getString('scanner_scans_date') == today ? (prefs.getInt('scanner_scans_today') ?? 0) : 0;
    final tournamentCount = prefs.getString('scanner_mission_tournament_date') == today ? (prefs.getInt('scanner_mission_tournament_count') ?? 0) : 0;
    final highscoreCount = prefs.getString('scanner_highscore_date') == today ? (prefs.getInt('scanner_highscore_count') ?? 0) : 0;

    final indices = _dailyMissionIndices();

    return indices.map((i) {
      final t = _missionPool[i];
      return ScanDailyMission(
        id: t.id,
        titleEn: t.titleEn,
        titleEs: t.titleEs,
        target: t.target,
        progress: _counterValue(prefs, today, t.counter,
            personalCount: personalCount,
            celebrityCount: celebrityCount,
            shareCount: shareCount,
            totalScans: totalScans,
            tournamentCount: tournamentCount,
            highscoreCount: highscoreCount),
        rewardCoins: t.reward,
        claimed: prefs.getBool('scanner_mission_${today}_${t.id}') ?? false,
      );
    }).toList();
  }

  Future<int> claimMission(String missionId) async {
    final prefs = await _p;
    final today = _today();
    final missions = await getDailyMissions();
    final mission = missions.cast<ScanDailyMission?>().firstWhere(
      (m) => m?.id == missionId,
      orElse: () => null,
    );
    if (mission == null || !mission.completed || mission.claimed) return 0;

    await prefs.setBool('scanner_mission_${today}_${mission.id}', true);
    await GlobalEconomyService.instance.addCoins(mission.rewardCoins);
    await AnalyticsService.instance.trackEvent(
      'scanner_mission_claimed',
      params: {'mission_id': mission.id, 'reward': mission.rewardCoins},
    );
    return mission.rewardCoins;
  }

  Future<bool> canWatchAdForCoins() async {
    if (await MonetizationService.instance.isPremiumAsync()) return false;
    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_coin_ad_date');
    final count = date == today ? (prefs.getInt('scanner_coin_ad_count') ?? 0) : 0;
    return count < _maxCoinAdsPerDay;
  }

  Future<bool> watchAdForCoins() async {
    if (!await canWatchAdForCoins()) return false;
    final prefs = await _p;
    final today = _today();
    bool earned = false;

    final adShown = await AdMobService.instance.showRewardedAd(
      onUserEarnedReward: (ad, reward) async {
        final date = prefs.getString('scanner_coin_ad_date');
        final count = date == today ? (prefs.getInt('scanner_coin_ad_count') ?? 0) : 0;
        final newCount = (count + 1).clamp(0, _maxCoinAdsPerDay);
        await prefs.setString('scanner_coin_ad_date', today);
        await prefs.setInt('scanner_coin_ad_count', newCount);
        await GlobalEconomyService.instance.addCoins(_coinAdReward);
        earned = true;
      },
    );

    if (adShown && earned) {
      await AnalyticsService.instance.trackEvent('scanner_coin_ad_rewarded');
      return true;
    }
    return false;
  }

  Future<ScannerCoinSpendResult> buyExtraScansWithCoins() async {
    if (await MonetizationService.instance.isPremiumAsync()) {
      return ScannerCoinSpendResult.premiumNotNeeded;
    }

    final prefs = await _p;
    final today = _today();
    final date = prefs.getString('scanner_scan_pack_date');
    final buys = date == today ? (prefs.getInt('scanner_scan_pack_count') ?? 0) : 0;
    if (buys >= _maxScanPacksPerDay) {
      return ScannerCoinSpendResult.dailyLimitReached;
    }

    final cost = _scanPackCostForBuyIndex(buys);
    final coins = await GlobalEconomyService.instance.getCoins();
    if (coins < cost) {
      return ScannerCoinSpendResult.insufficientCoins;
    }

    final spent = await GlobalEconomyService.instance.spendCoins(cost);
    if (!spent) return ScannerCoinSpendResult.insufficientCoins;
    await prefs.setString('scanner_scan_pack_date', today);
    await prefs.setInt('scanner_scan_pack_count', buys + 1);
    await MonetizationService.instance.grantCoinExtraScans(_scanPackScans);

    await AnalyticsService.instance.trackEvent(
      'scanner_buy_scan_pack',
      params: {'cost': cost, 'scans': _scanPackScans, 'buy_index': buys + 1},
    );

    return ScannerCoinSpendResult.success;
  }
}

enum _Counter { personal, celebrity, total, share, tournament, highscore, mixBoth, mixScanShare, explorer }

class _MissionTemplate {
  final String id;
  final String titleEn;
  final String titleEs;
  final int target;
  final int reward;
  final _Counter counter;

  const _MissionTemplate({
    required this.id,
    required this.titleEn,
    required this.titleEs,
    required this.target,
    required this.reward,
    required this.counter,
  });
}
