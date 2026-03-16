import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_service.dart';
import 'secure_time_service.dart';

/// Manages temporary premium theme access via rewarded ads.
///
/// This service is NOT a separate theme system. All theme definitions
/// live in [AppTheme] and are applied through [ThemeService].
/// PremiumThemeService only controls *temporary access* (watch-ad → 3 hours)
/// and handles expiration cleanup.
class PremiumThemeService {
  static final PremiumThemeService _instance = PremiumThemeService._internal();
  factory PremiumThemeService() => _instance;
  PremiumThemeService._internal();

  static PremiumThemeService get instance => _instance;

  SharedPreferences? _prefs;
  static const Duration _firstAdUnlockDuration = Duration(hours: 3);
  static const Duration _repeatAdUnlockDuration = Duration(hours: 3);
  static const int _maxAdUnlocksPerDay = 3;

  /// Map of temporary access: {themeTypeName: expiryIsoString}
  Map<String, String> _tempPremiumThemes = {};

  /// Notifier that ticks whenever temp-access data changes.
  final ValueNotifier<int> tempAccessNotifier = ValueNotifier<int>(0);

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTempPremiumThemes();
    _startExpirationTimer();
  }

  // ---------------------------------------------------------------------------
  // Temporary access management
  // ---------------------------------------------------------------------------

  String _todayKey() =>
      SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];

  Future<int> getRemainingAdThemeUnlocksToday() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final today = _todayKey();
    final date = prefs.getString('theme_ad_unlock_date');
    final used = date == today ? (prefs.getInt('theme_ad_unlock_count') ?? 0) : 0;
    return (_maxAdUnlocksPerDay - used).clamp(0, _maxAdUnlocksPerDay);
  }

  Future<bool> canWatchAdForThemeUnlock() async {
    final remaining = await getRemainingAdThemeUnlocksToday();
    return remaining > 0;
  }

  Future<Duration> getAdUnlockDurationForTheme(String themeId) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final everUnlocked = prefs.getBool('theme_ad_unlocked_once_$themeId') ?? false;
    return everUnlocked ? _repeatAdUnlockDuration : _firstAdUnlockDuration;
  }

  /// Grants temporary access to a premium theme after watching an ad.
  /// First unlock per theme: 3h. Re-unlocks: 3h.
  /// Returns false if daily ad-unlock limit has been reached.
  Future<bool> grantTemporaryAccessToTheme(String themeId) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final today = _todayKey();
    final date = prefs.getString('theme_ad_unlock_date');
    final used = date == today ? (prefs.getInt('theme_ad_unlock_count') ?? 0) : 0;
    if (used >= _maxAdUnlocksPerDay) return false;

    final duration = await getAdUnlockDurationForTheme(themeId);
    final expiry = SecureTimeService.instance.getSecureTime().add(duration);
    _tempPremiumThemes[themeId] = expiry.toIso8601String();
    await prefs.setBool('theme_ad_unlocked_once_$themeId', true);
    await prefs.setString('theme_ad_unlock_date', today);
    await prefs.setInt('theme_ad_unlock_count', (used + 1).clamp(0, _maxAdUnlocksPerDay));
    await _saveTempPremiumThemes();
    tempAccessNotifier.value++;
    return true;
  }

  /// Debug helper – grant access with a custom expiry duration.
  Future<void> grantDebugAccess(String themeId, DateTime expiry) async {
    final secureNow = SecureTimeService.instance.getSecureTime();
    final secureExpiry = secureNow.add(expiry.difference(secureNow));
    _tempPremiumThemes[themeId] = secureExpiry.toIso8601String();
    await _saveTempPremiumThemes();
    tempAccessNotifier.value++;
  }

  /// Returns `true` if the user currently has unexpired temporary access.
  bool hasTemporaryAccessToTheme(String themeId) {
    final expiryString = _tempPremiumThemes[themeId];
    if (expiryString == null) return false;
    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return false;
    if (SecureTimeService.instance.getSecureTime().isAfter(expiry)) {
      _tempPremiumThemes.remove(themeId);
      _saveTempPremiumThemes();
      tempAccessNotifier.value++;
      return false;
    }
    return true;
  }

  /// Hours remaining for a given theme's temporary access (clamped 0–24).
  int getTemporaryHoursRemainingForTheme(String themeId) {
    final expiryString = _tempPremiumThemes[themeId];
    if (expiryString == null) return 0;
    final expiry = DateTime.tryParse(expiryString);
    if (expiry == null) return 0;
    final remaining = expiry
        .difference(SecureTimeService.instance.getSecureTime())
        .inHours;
    return remaining.clamp(0, 24);
  }

  // ---------------------------------------------------------------------------
  // Expiration handling
  // ---------------------------------------------------------------------------

  /// Checks all temporary accesses and cleans up expired ones.
  /// If the *current* theme's access expired, falls back to classic.
  Future<void> checkAndHandleExpiredPremium() async {
    final now = SecureTimeService.instance.getSecureTime();
    final currentTheme = ThemeService.instance.currentTheme.name;

    // If the active theme lost its temp access, revert to classic.
    final expiryString = _tempPremiumThemes[currentTheme];
    if (expiryString != null) {
      final expiry = DateTime.tryParse(expiryString);
      if (expiry != null && expiry.isBefore(now)) {
        _tempPremiumThemes.remove(currentTheme);
        await _saveTempPremiumThemes();
        await ThemeService.instance.setThemeByName('classic');
        tempAccessNotifier.value++;
      }
    }

    // Sweep all other expired entries.
    final expired = <String>[];
    _tempPremiumThemes.forEach((themeId, iso) {
      final expiry = DateTime.tryParse(iso);
      if (expiry != null && expiry.isBefore(now)) {
        expired.add(themeId);
      }
    });
    for (final id in expired) {
      _tempPremiumThemes.remove(id);
    }
    if (expired.isNotEmpty) {
      await _saveTempPremiumThemes();
      tempAccessNotifier.value++;
    }
  }

  // ---------------------------------------------------------------------------
  // Persistence helpers
  // ---------------------------------------------------------------------------

  void _loadTempPremiumThemes() {
    final raw = _prefs?.getString('temp_premium_themes');
    if (raw != null && raw.isNotEmpty) {
      try {
        final entries = (raw.split(';')..removeWhere((e) => e.isEmpty))
            .map((e) {
          final parts = e.split(':');
          if (parts.length >= 2) {
            // Rejoin to handle ISO dates that contain ':'
            return MapEntry(parts[0], parts.sublist(1).join(':'));
          }
          return null;
        }).whereType<MapEntry<String, String>>();
        _tempPremiumThemes = Map<String, String>.fromEntries(entries);
      } catch (_) {
        _tempPremiumThemes = {};
      }
    }
  }

  Future<void> _saveTempPremiumThemes() async {
    final str = _tempPremiumThemes.entries
        .map((e) => '${e.key}:${e.value}')
        .join(';');
    await _prefs?.setString('temp_premium_themes', str);
  }

  void _startExpirationTimer() {
    Future.delayed(const Duration(minutes: 5), () async {
      await checkAndHandleExpiredPremium();
      _startExpirationTimer();
    });
  }
}
