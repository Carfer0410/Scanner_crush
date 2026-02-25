import 'package:shared_preferences/shared_preferences.dart';
import 'admob_service.dart';
import 'analytics_service.dart';
import 'monetization_service.dart';
import 'secure_time_service.dart';
import 'global_economy_service.dart';

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

  static const int _coinAdReward = 12;
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
      streakDays: prefs.getInt('scanner_streak_days') ?? 0,
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
    final now = SecureTimeService.instance.getSecureDate();

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

    final streakDate = prefs.getString('scanner_streak_date');
    int streak = prefs.getInt('scanner_streak_days') ?? 0;
    bool streakUpdatedToday = false;
    if (streakDate != today) {
      final last = streakDate == null ? null : DateTime.tryParse(streakDate);
      if (last != null && now.difference(last).inDays == 1) {
        streak += 1;
      } else {
        streak = 1;
      }
      streakUpdatedToday = true;
      await prefs.setString('scanner_streak_date', today);
      await prefs.setInt('scanner_streak_days', streak);
    }

    final isPremium = await MonetizationService.instance.isPremiumAsync();
    int earned = isPremium ? _baseCoinPerScanPremium : _baseCoinPerScanFree;
    if (firstScanToday) {
      earned += _firstScanDayBonus;
    }
    if (streakUpdatedToday && streak > 0 && streak % _streakBonusEveryDays == 0) {
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

  Future<List<ScanDailyMission>> getDailyMissions() async {
    final prefs = await _p;
    final today = _today();
    final personalDate = prefs.getString('scanner_personal_date');
    final celebrityDate = prefs.getString('scanner_celebrity_date');
    final shareDate = prefs.getString('scanner_share_date');

    final personalCount = personalDate == today ? (prefs.getInt('scanner_personal_count') ?? 0) : 0;
    final celebrityCount = celebrityDate == today ? (prefs.getInt('scanner_celebrity_count') ?? 0) : 0;
    final shareCount = shareDate == today ? (prefs.getInt('scanner_share_count') ?? 0) : 0;

    return <ScanDailyMission>[
      ScanDailyMission(
        id: 'scanner_personal_3',
        titleEn: 'Do 3 personal scans',
        titleEs: 'Haz 3 escaneos personales',
        target: 3,
        progress: personalCount,
        rewardCoins: 5,
        claimed: prefs.getBool('scanner_mission_${today}_scanner_personal_3') ?? false,
      ),
      ScanDailyMission(
        id: 'scanner_celebrity_2',
        titleEn: 'Do 2 celebrity scans',
        titleEs: 'Haz 2 escaneos de celebridades',
        target: 2,
        progress: celebrityCount,
        rewardCoins: 5,
        claimed: prefs.getBool('scanner_mission_${today}_scanner_celebrity_2') ?? false,
      ),
      ScanDailyMission(
        id: 'scanner_share_1',
        titleEn: 'Share 1 result',
        titleEs: 'Comparte 1 resultado',
        target: 1,
        progress: shareCount,
        rewardCoins: 4,
        claimed: prefs.getBool('scanner_mission_${today}_scanner_share_1') ?? false,
      ),
    ];
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
