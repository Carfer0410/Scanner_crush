import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'secure_time_service.dart';

/// Global daily streak service for the whole app.
///
/// The streak increments at most once per calendar day, when the user
/// opens the app or performs any activity. Scans are tracked separately
/// for stats but do NOT affect the streak count.
class StreakService extends ChangeNotifier {
  StreakService._();

  static StreakService? _instance;
  static StreakService get instance => _instance ??= StreakService._();

  static const String _streakCountKey = 'love_streak';
  static const String _lastActiveDateKey = 'last_used_date';
  static const String _totalScansKey = 'total_scans';
  static const String _bestStreakKey = 'best_streak';
  static const String _recoveriesUsedKey = 'love_streak_recoveries_used';
  static const String _pendingRecoveryTargetKey = 'love_streak_pending_recovery_target';
  static const String _pendingRecoveryDateKey = 'love_streak_pending_recovery_date';
  static const int _maxRecoveries = 3;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  /// Completer to serialize _ensureInitialized so it runs exactly once.
  Completer<void>? _initCompleter;

  /// Completer to serialize recordAppVisit so concurrent calls
  /// wait for the first one instead of running in parallel.
  Completer<StreakUpdate>? _visitInProgress;

  /// Session-level flag: once a visit has been recorded in this app session,
  /// no further streak changes are allowed until the next calendar day OR
  /// a new app session.  This does NOT depend on _todayKey() which can
  /// shift when SecureTimeService finishes syncing.
  bool _visitRecordedThisSession = false;

  int _currentStreak = 0;
  DateTime? _lastActiveDate;
  int _totalScans = 0;
  int _bestStreak = 0;
  int _recoveriesUsed = 0;
  int? _pendingRecoveryTarget;
  String? _pendingRecoveryDate;

  int get currentStreak => _currentStreak;
  DateTime? get lastScanDate => _lastActiveDate;
  int get totalScans => _totalScans;
  int get bestStreak => _bestStreak;
  int get recoveriesUsed => _recoveriesUsed;
  int get recoveriesRemaining => (_maxRecoveries - _recoveriesUsed).clamp(0, _maxRecoveries);
  int get pendingRecoveryTarget => _pendingRecoveryTarget ?? 0;

  bool get canRecoverStreak {
    if (_pendingRecoveryTarget == null) {
      return false;
    }
    if (recoveriesRemaining <= 0) {
      return false;
    }
    if (_lastActiveDate == null) {
      return false;
    }
    // Recovery is available as long as there is a pending target
    // and the user still has recoveries left.
    return _pendingRecoveryTarget! > _currentStreak;
  }

  Future<void> initialize() async {
    await _ensureInitialized();
  }

  /// Serialized initialization – only the first caller executes the work;
  /// subsequent callers await the same Completer.
  Future<void> _ensureInitialized() async {
    if (_isInitialized && _prefs != null) {
      return;
    }

    // If another call is already initializing, wait for it.
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadData();
      _isInitialized = true;
      _initCompleter!.complete();
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<void> _loadData() async {
    final prefs = _prefs!;
    _currentStreak = prefs.getInt(_streakCountKey) ?? 0;
    _totalScans = prefs.getInt(_totalScansKey) ?? 0;
    _bestStreak = prefs.getInt(_bestStreakKey) ?? 0;
    _recoveriesUsed = prefs.getInt(_recoveriesUsedKey) ?? 0;
    _pendingRecoveryTarget = prefs.getInt(_pendingRecoveryTargetKey);
    _pendingRecoveryDate = prefs.getString(_pendingRecoveryDateKey);

    final lastActiveDateString = prefs.getString(_lastActiveDateKey);
    if (lastActiveDateString != null) {
      try {
        _lastActiveDate = DateTime.parse(lastActiveDateString);
      } catch (_) {
        _lastActiveDate = null;
      }
    }

    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
      await prefs.setInt(_bestStreakKey, _bestStreak);
    }

    if (_currentStreak < 0) {
      _currentStreak = 0;
    }
    if (_bestStreak < 0) {
      _bestStreak = 0;
    }
    if (_recoveriesUsed < 0 || _recoveriesUsed > _maxRecoveries) {
      _recoveriesUsed = 0;
    }
    if (_lastActiveDate == null && _currentStreak == 0) {
      _pendingRecoveryTarget = null;
      _pendingRecoveryDate = null;
    }
    if (_pendingRecoveryTarget != null && _pendingRecoveryTarget! <= 1) {
      _pendingRecoveryTarget = null;
      _pendingRecoveryDate = null;
    }
    if (_pendingRecoveryDate != null) {
      final parsedPendingDate = DateTime.tryParse(_pendingRecoveryDate!);
      if (parsedPendingDate == null) {
        _pendingRecoveryTarget = null;
        _pendingRecoveryDate = null;
      }
    }

    // If the streak was already recorded today, set the session guard
    if (_lastActiveDate != null && _formatDate(_lastActiveDate!) == _todayKey()) {
      _visitRecordedThisSession = true;
    }

    await _expirePendingRecoveryIfNeeded();
  }

  Future<void> _saveData() async {
    final prefs = _prefs!;
    await prefs.setInt(_streakCountKey, _currentStreak);
    await prefs.setInt(_totalScansKey, _totalScans);
    await prefs.setInt(_bestStreakKey, _bestStreak);
    await prefs.setInt(_recoveriesUsedKey, _recoveriesUsed);

    if (_lastActiveDate != null) {
      await prefs.setString(_lastActiveDateKey, _formatDate(_lastActiveDate!));
    } else {
      await prefs.remove(_lastActiveDateKey);
    }

    if (_pendingRecoveryTarget != null) {
      await prefs.setInt(_pendingRecoveryTargetKey, _pendingRecoveryTarget!);
    } else {
      await prefs.remove(_pendingRecoveryTargetKey);
    }

    if (_pendingRecoveryDate != null) {
      await prefs.setString(_pendingRecoveryDateKey, _pendingRecoveryDate!);
    } else {
      await prefs.remove(_pendingRecoveryDateKey);
    }

    notifyListeners();
  }

  String _todayKey() => _formatDate(SecureTimeService.instance.getSecureDate());

  String _formatDate(DateTime date) =>
      DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];

  /// Pending recovery no longer expires by date — it persists until
  /// the user either recovers or exhausts all recovery attempts.
  Future<void> _expirePendingRecoveryIfNeeded() async {
    // Nothing to expire
  }

  Future<StreakUpdate> checkManipulation() async {
    await _ensureInitialized();
    final debugInfo = SecureTimeService.instance.getDebugInfo();
    final manipulationCount = debugInfo['manipulationDetections'] ?? 0;

    if (manipulationCount > 3) {
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: false,
        manipulationDetected: true,
        recoveriesRemaining: recoveriesRemaining,
      );
    }

    return StreakUpdate(
      newStreak: _currentStreak,
      isNewRecord: false,
      streakMaintained: true,
      manipulationDetected: false,
      recoveriesRemaining: recoveriesRemaining,
      recoveryAvailable: canRecoverStreak,
    );
  }

  /// Called when the user opens the app or resumes it.
  /// This is the ONLY method that can increment the streak.
  /// The streak increments at most once per calendar day.
  ///
  /// Serialized: concurrent callers await the same future so
  /// the logic never runs in parallel.
  Future<StreakUpdate> recordAppVisit() async {
    // If a visit is already being processed, return its result.
    if (_visitInProgress != null) {
      return _visitInProgress!.future;
    }
    _visitInProgress = Completer<StreakUpdate>();
    try {
      final result = await _doRecordAppVisit();
      _visitInProgress!.complete(result);
      return result;
    } catch (e, st) {
      _visitInProgress!.completeError(e, st);
      rethrow;
    } finally {
      _visitInProgress = null;
    }
  }

  Future<StreakUpdate> _doRecordAppVisit() async {
    await _ensureInitialized();
    await _expirePendingRecoveryIfNeeded();

    final todayKey = _todayKey();

    // Si cambió el día, liberar el guard de sesión para permitir
    // registrar la visita diaria correctamente al reanudar la app.
    if (_visitRecordedThisSession &&
        _lastActiveDate != null &&
        _formatDate(_lastActiveDate!) != todayKey) {
      _visitRecordedThisSession = false;
    }

    final debugInfo = SecureTimeService.instance.getDebugInfo();
    final manipulationCount = debugInfo['manipulationDetections'] ?? 0;
    if (manipulationCount > 3) {
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: false,
        manipulationDetected: true,
        recoveriesRemaining: recoveriesRemaining,
      );
    }

    // ── Session guard: once recorded this session, never touch streak again ──
    if (_visitRecordedThisSession) {
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: true,
        alreadyScannedToday: true,
        recoveriesRemaining: recoveriesRemaining,
        recoveryAvailable: canRecoverStreak,
      );
    }

    final today = SecureTimeService.instance.getSecureDate();

    // ── First ever visit ──
    if (_lastActiveDate == null) {
      _currentStreak = 1;
      _lastActiveDate = today;
      _visitRecordedThisSession = true;
      _bestStreak = _bestStreak < 1 ? 1 : _bestStreak;
      _pendingRecoveryTarget = null;
      _pendingRecoveryDate = null;
      await _saveData();
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: true,
        streakMaintained: false,
        isFirstScan: true,
        recoveriesRemaining: recoveriesRemaining,
      );
    }

    // ── Already recorded today (persisted check) ──
    if (_formatDate(_lastActiveDate!) == todayKey) {
      _visitRecordedThisSession = true;
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: true,
        alreadyScannedToday: true,
        recoveriesRemaining: recoveriesRemaining,
        recoveryAvailable: canRecoverStreak,
      );
    }

    // ── Consecutive day (difference == 1) → increment ──
    final lastActiveDay = DateTime(
      _lastActiveDate!.year,
      _lastActiveDate!.month,
      _lastActiveDate!.day,
    );
    final difference = today.difference(lastActiveDay).inDays;

    if (difference == 1) {
      _currentStreak = _currentStreak <= 0 ? 1 : _currentStreak + 1;
      _lastActiveDate = today;
      _visitRecordedThisSession = true;

      // Keep pending recovery alive — it auto-expires when current
      // streak surpasses the target (canRecoverStreak handles that).

      final isNewRecord = _currentStreak > _bestStreak;
      if (isNewRecord) {
        _bestStreak = _currentStreak;
      }

      await _saveData();
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: isNewRecord,
        streakMaintained: true,
        recoveriesRemaining: recoveriesRemaining,
        recoveryAvailable: canRecoverStreak,
      );
    }

    // ── Missed more than 1 day → streak broken, reset to 1 ──
    final previousStreak = _currentStreak;
    _currentStreak = 1;
    _lastActiveDate = today;
    _visitRecordedThisSession = true;

    if (recoveriesRemaining > 0 && previousStreak > 0) {
      // Keep the highest recovery target if one already exists.
      final newTarget = previousStreak;
      if (_pendingRecoveryTarget == null || newTarget > _pendingRecoveryTarget!) {
        _pendingRecoveryTarget = newTarget;
      }
      _pendingRecoveryDate = todayKey;
    } else {
      // No recoveries left → full reset.
      _pendingRecoveryTarget = null;
      _pendingRecoveryDate = null;
      _recoveriesUsed = 0;
    }

    await _saveData();
    return StreakUpdate(
      newStreak: _currentStreak,
      isNewRecord: false,
      streakMaintained: false,
      streakBroken: true,
      recoveriesRemaining: recoveriesRemaining,
      recoveryAvailable: canRecoverStreak,
      recoveryTarget: _pendingRecoveryTarget,
    );
  }

  /// Called after each scan. Only refreshes the scan counter from
  /// SharedPreferences (the actual increment is done by CrushService
  /// via DailyLoveService.incrementTotalScans).
  /// Does NOT affect the daily streak.
  Future<StreakUpdate> recordScan() async {
    await _ensureInitialized();

    // Reload total scans from SharedPreferences (written by DailyLoveService)
    _totalScans = _prefs!.getInt(_totalScansKey) ?? _totalScans;
    notifyListeners();

    // Return current state without modifying the streak
    return StreakUpdate(
      newStreak: _currentStreak,
      isNewRecord: false,
      streakMaintained: _visitRecordedThisSession,
      alreadyScannedToday: _visitRecordedThisSession,
      recoveriesRemaining: recoveriesRemaining,
      recoveryAvailable: canRecoverStreak,
    );
  }

  Future<StreakRecoveryResult> recoverStreak() async {
    await _ensureInitialized();
    await _expirePendingRecoveryIfNeeded();

    if (!canRecoverStreak || _pendingRecoveryTarget == null) {
      return StreakRecoveryResult(
        success: false,
        streak: _currentStreak,
        recoveriesRemaining: recoveriesRemaining,
      );
    }

    _currentStreak = _pendingRecoveryTarget!;
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
    }
    _recoveriesUsed++;
    _pendingRecoveryTarget = null;
    _pendingRecoveryDate = null;

    await _saveData();
    return StreakRecoveryResult(
      success: true,
      streak: _currentStreak,
      recoveriesRemaining: recoveriesRemaining,
    );
  }

  bool hasScannedToday() {
    if (_lastActiveDate == null) return false;
    return _formatDate(_lastActiveDate!) == _todayKey();
  }

  int getDaysWithoutScanning() {
    if (_lastActiveDate == null) return 0;
    final today = SecureTimeService.instance.getSecureDate();
    final lastActiveDay = DateTime(
      _lastActiveDate!.year,
      _lastActiveDate!.month,
      _lastActiveDate!.day,
    );
    return today.difference(lastActiveDay).inDays;
  }

  bool isStreakAtRisk() {
    if (_lastActiveDate == null || _currentStreak == 0) return false;
    final daysWithoutActivity = getDaysWithoutScanning();
    return daysWithoutActivity >= 1 && !hasScannedToday();
  }

  String getMotivationalMessage(String languageCode) {
    if (canRecoverStreak) {
      return languageCode == 'en'
          ? 'You missed a day, but you can still recover your streak!'
          : '¡Perdiste un día, pero aún puedes recuperar tu racha!';
    }

    if (languageCode == 'en') {
      if (_currentStreak == 0) return 'Start your love streak today! 💕';
      if (_currentStreak < 3) return 'Keep it up! You are building momentum! 🔥';
      if (_currentStreak < 7) return 'Amazing streak! Do not break it now! ⭐';
      if (_currentStreak < 14) return 'You are on fire! $_currentStreak days strong! 🚀';
      if (_currentStreak < 30) return 'Incredible! $_currentStreak days of love energy! 💎';
      return 'Legendary! $_currentStreak days streak! You are a true love expert! 👑';
    }

    if (_currentStreak == 0) return '¡Comienza tu racha de amor hoy! 💕';
    if (_currentStreak < 3) return '¡Sigue así! ¡Estás ganando impulso! 🔥';
    if (_currentStreak < 7) return '¡Increíble racha! ¡No la rompas ahora! ⭐';
    if (_currentStreak < 14) return '¡Estás en llamas! ¡$_currentStreak días seguidos! 🚀';
    if (_currentStreak < 30) return '¡Increíble! ¡$_currentStreak días de energía amorosa! 💎';
    return '¡Legendario! ¡$_currentStreak días de racha! ¡Eres un experto del amor! 👑';
  }

  Future<void> resetAllData() async {
    await _ensureInitialized();
    _currentStreak = 0;
    _lastActiveDate = null;
    _totalScans = 0;
    _bestStreak = 0;
    _recoveriesUsed = 0;
    _pendingRecoveryTarget = null;
    _pendingRecoveryDate = null;
    _visitRecordedThisSession = false;
    await _saveData();
  }

  Future<void> syncWithDailyLoveService() async {
    await _ensureInitialized();
    await _loadData();
    notifyListeners();
  }
}

class StreakUpdate {
  final int newStreak;
  final bool isNewRecord;
  final bool streakMaintained;
  final bool streakBroken;
  final bool alreadyScannedToday;
  final bool isFirstScan;
  final bool manipulationDetected;
  final bool recoveryAvailable;
  final int recoveriesRemaining;
  final int? recoveryTarget;

  StreakUpdate({
    required this.newStreak,
    required this.isNewRecord,
    required this.streakMaintained,
    this.streakBroken = false,
    this.alreadyScannedToday = false,
    this.isFirstScan = false,
    this.manipulationDetected = false,
    this.recoveryAvailable = false,
    this.recoveriesRemaining = 0,
    this.recoveryTarget,
  });

  String getFeedbackMessage(String languageCode) {
    if (languageCode == 'en') {
      if (manipulationDetected) return 'Time manipulation detected. Activity blocked for security.';
      if (isFirstScan) return 'Welcome! Your streak starts today.';
      if (alreadyScannedToday) return 'Today is already counted. Come back tomorrow to keep your streak.';
      if (streakBroken && recoveryAvailable) {
        return 'You missed a day, but you can still recover your streak today.';
      }
      if (streakBroken) return 'Your streak restarted. Use the app today to begin again.';
      if (isNewRecord) return 'New record! $newStreak days in a row.';
      if (streakMaintained) return 'Your streak is now $newStreak days.';
      return 'Keep going. You are on a $newStreak-day streak.';
    }

    if (manipulationDetected) return 'Se detectó manipulación de tiempo. Actividad bloqueada por seguridad.';
    if (isFirstScan) return '¡Bienvenido! Tu racha empieza hoy.';
    if (alreadyScannedToday) return 'Hoy ya cuenta para tu racha. Vuelve mañana para mantenerla.';
    if (streakBroken && recoveryAvailable) {
      return 'Perdiste un día, pero todavía puedes recuperar tu racha hoy.';
    }
    if (streakBroken) return 'Tu racha se reinició. Usa la app hoy para comenzar otra vez.';
    if (isNewRecord) return '¡Nuevo récord! $newStreak días seguidos.';
    if (streakMaintained) return 'Tu racha ahora es de $newStreak días.';
    return 'Sigue así. Llevas $newStreak días de racha.';
  }
}

class StreakRecoveryResult {
  final bool success;
  final int streak;
  final int recoveriesRemaining;

  const StreakRecoveryResult({
    required this.success,
    required this.streak,
    required this.recoveriesRemaining,
  });
}
