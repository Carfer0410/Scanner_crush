import 'package:shared_preferences/shared_preferences.dart';

class GlobalEconomyService {
  static final GlobalEconomyService _instance = GlobalEconomyService._internal();
  static GlobalEconomyService get instance => _instance;
  GlobalEconomyService._internal();

  static const String _coinsKey = 'global_coins_balance';
  static const String _migrationKey = 'global_coins_migrated_v1';

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _ensureMigrated();
  }

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _ensureMigrated() async {
    final prefs = await _p;
    if (prefs.getBool(_migrationKey) ?? false) return;

    final legacyTournament = prefs.getInt('tournament_coins') ?? 0;
    final legacyScanner = prefs.getInt('scanner_coins') ?? 0;
    final currentGlobal = prefs.getInt(_coinsKey) ?? 0;
    final migratedTotal = currentGlobal + legacyTournament + legacyScanner;

    await prefs.setInt(_coinsKey, migratedTotal);
    await prefs.setInt('tournament_coins', 0);
    await prefs.setInt('scanner_coins', 0);
    await prefs.setBool(_migrationKey, true);
  }

  Future<int> getCoins() async {
    await _ensureMigrated();
    final prefs = await _p;
    return prefs.getInt(_coinsKey) ?? 0;
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    await _ensureMigrated();
    final prefs = await _p;
    final current = prefs.getInt(_coinsKey) ?? 0;
    await prefs.setInt(_coinsKey, current + amount);
  }

  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return false;
    await _ensureMigrated();
    final prefs = await _p;
    final current = prefs.getInt(_coinsKey) ?? 0;
    if (current < amount) return false;
    await prefs.setInt(_coinsKey, current - amount);
    return true;
  }
}
