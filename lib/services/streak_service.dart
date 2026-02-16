import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_time_service.dart';

/// Servicio para manejar las rachas diarias de escaneos
/// Daily streak service for scan tracking
class StreakService extends ChangeNotifier {
  static StreakService? _instance;
  static StreakService get instance => _instance ??= StreakService._();
  StreakService._();

  late SharedPreferences _prefs;

  // Claves para SharedPreferences (sincronizadas con DailyLoveService)
  static const String _streakCountKey = 'love_streak'; // Cambiado para sincronizar
  static const String _lastScanDateKey = 'last_used_date'; // Cambiado para sincronizar
  static const String _totalScansKey = 'total_scans';
  static const String _bestStreakKey = 'best_streak';

  int _currentStreak = 0;
  DateTime? _lastScanDate;
  int _totalScans = 0;
  int _bestStreak = 0;

  // Getters
  int get currentStreak => _currentStreak;
  DateTime? get lastScanDate => _lastScanDate;
  int get totalScans => _totalScans;
  int get bestStreak => _bestStreak;

  /// Inicializar el servicio
  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadData();
  }

  /// Cargar datos guardados
  /// Load saved data
  Future<void> _loadData() async {
    _currentStreak = _prefs.getInt(_streakCountKey) ?? 0;
    _totalScans = _prefs.getInt(_totalScansKey) ?? 0;
    _bestStreak = _prefs.getInt(_bestStreakKey) ?? 0;
    
    // Usar el mismo formato que DailyLoveService (string date format)
    final lastScanDateString = _prefs.getString(_lastScanDateKey);
    if (lastScanDateString != null) {
      try {
        _lastScanDate = DateTime.parse(lastScanDateString);
      } catch (e) {
        _lastScanDate = null;
      }
    }
    
    // Verificar integridad: la mejor racha nunca debe ser menor que la racha actual
    if (_currentStreak > _bestStreak) {
      _bestStreak = _currentStreak;
      await _prefs.setInt(_bestStreakKey, _bestStreak);
    }
  }

  /// Guardar datos
  /// Save data
  Future<void> _saveData() async {
    await _prefs.setInt(_streakCountKey, _currentStreak);
    await _prefs.setInt(_totalScansKey, _totalScans);
    await _prefs.setInt(_bestStreakKey, _bestStreak);
    
    // Usar el mismo formato que DailyLoveService (string date format)
    if (_lastScanDate != null) {
      final dateString = _lastScanDate!.toIso8601String().split('T')[0];
      await _prefs.setString(_lastScanDateKey, dateString);
    }
    
    // Notificar a los listeners que los datos han cambiado
    notifyListeners();
  }

  /// Actualizar la racha cuando el usuario hace un escaneo
  /// Update streak when user performs a scan
  Future<StreakUpdate> recordScan() async {
    // VERIFICACIÓN DE SEGURIDAD EXTRA: Forzar sincronización antes del escaneo
    final secureTimeService = SecureTimeService.instance;
    await secureTimeService.forceSyncNow(); // Asegurar tiempo actual
    
    final now = secureTimeService.getSecureTime();
    final today = DateTime(now.year, now.month, now.day);
    
    // Verificación adicional: Si han detectado manipulaciones recientemente, rechazar
    final debugInfo = secureTimeService.getDebugInfo();
    final manipulationCount = debugInfo['manipulationDetections'] ?? 0;
    
    if (manipulationCount > 3) {
      // Demasiadas manipulaciones detectadas - rechazar escaneo
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: false,
        manipulationDetected: true,
      );
    }
    
    // Incrementar total de escaneos
    _totalScans++;
    
    // Si es el primer escaneo
    if (_lastScanDate == null) {
      _currentStreak = 1;
      _lastScanDate = today;
      _bestStreak = 1;
      await _saveData();
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: true,
        streakMaintained: false,
        isFirstScan: true,
      );
    }

    final lastScanDay = DateTime(
      _lastScanDate!.year,
      _lastScanDate!.month,
      _lastScanDate!.day,
    );

    // Si ya escaneó hoy
    if (lastScanDay.isAtSameMomentAs(today)) {
      await _saveData();
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: false,
        streakMaintained: true,
        alreadyScannedToday: true,
      );
    }

    // Si fue ayer (continúa la racha)
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastScanDay.isAtSameMomentAs(yesterday)) {
      _currentStreak++;
      _lastScanDate = today;
      
      final isNewRecord = _currentStreak > _bestStreak;
      // Asegurar que la mejor racha siempre sea al menos igual a la racha actual
      if (_currentStreak >= _bestStreak) {
        _bestStreak = _currentStreak;
      }
      
      await _saveData();
      return StreakUpdate(
        newStreak: _currentStreak,
        isNewRecord: isNewRecord,
        streakMaintained: true,
      );
    }

    // La racha se rompió (más de un día sin escanear)
    _currentStreak = 1;
    _lastScanDate = today;
    await _saveData();
    
    return StreakUpdate(
      newStreak: _currentStreak,
      isNewRecord: false,
      streakMaintained: false,
      streakBroken: true,
    );
  }

  /// Verificar si el usuario escaneó hoy
  /// Check if user scanned today
  bool hasScannedToday() {
    if (_lastScanDate == null) return false;
    
    final now = SecureTimeService.instance.getSecureTime();
    final today = DateTime(now.year, now.month, now.day);
    final lastScanDay = DateTime(
      _lastScanDate!.year,
      _lastScanDate!.month,
      _lastScanDate!.day,
    );
    
    return lastScanDay.isAtSameMomentAs(today);
  }

  /// Obtener días sin escanear
  /// Get days without scanning
  int getDaysWithoutScanning() {
    if (_lastScanDate == null) return 0;
    
    final now = SecureTimeService.instance.getSecureTime();
    final today = DateTime(now.year, now.month, now.day);
    final lastScanDay = DateTime(
      _lastScanDate!.year,
      _lastScanDate!.month,
      _lastScanDate!.day,
    );
    
    return today.difference(lastScanDay).inDays;
  }

  /// Verificar si la racha está en riesgo (más de 12 horas sin escanear)
  /// Check if streak is at risk (more than 12 hours without scanning)
  bool isStreakAtRisk() {
    if (_lastScanDate == null) return false;
    if (_currentStreak == 0) return false;
    
    final now = SecureTimeService.instance.getSecureTime();
    final hoursSinceLastScan = now.difference(_lastScanDate!).inHours;
    
    return hoursSinceLastScan >= 12;
  }

  /// Obtener mensaje motivacional basado en la racha
  /// Get motivational message based on streak
  String getMotivationalMessage(String languageCode) {
    if (languageCode == 'en') {
      if (_currentStreak == 0) return "Start your love streak today! 💕";
      if (_currentStreak < 3) return "Keep it up! You're building momentum! 🔥";
      if (_currentStreak < 7) return "Amazing streak! Don't break it now! ⭐";
      if (_currentStreak < 14) return "You're on fire! ${_currentStreak} days strong! 🚀";
      if (_currentStreak < 30) return "Incredible! ${_currentStreak} days of love scanning! 💎";
      return "Legendary! ${_currentStreak} days streak! You're a true love expert! 👑";
    } else {
      if (_currentStreak == 0) return "¡Comienza tu racha de amor hoy! 💕";
      if (_currentStreak < 3) return "¡Sigue así! ¡Estás ganando impulso! 🔥";
      if (_currentStreak < 7) return "¡Increíble racha! ¡No la rompas ahora! ⭐";
      if (_currentStreak < 14) return "¡Estás en llamas! ¡${_currentStreak} días seguidos! 🚀";
      if (_currentStreak < 30) return "¡Increíble! ¡${_currentStreak} días escaneando amor! 💎";
      return "¡Legendario! ¡${_currentStreak} días de racha! ¡Eres un experto del amor! 👑";
    }
  }

  /// Reiniciar todos los datos (para testing)
  /// Reset all data (for testing)
  Future<void> resetAllData() async {
    _currentStreak = 0;
    _lastScanDate = null;
    _totalScans = 0;
    _bestStreak = 0;
    await _saveData(); // _saveData() ya incluye notifyListeners()
  }

  /// Sincronizar con los datos actualizados por DailyLoveService
  /// Sync with data updated by DailyLoveService
  Future<void> syncWithDailyLoveService() async {
    await _loadData();
    notifyListeners();
  }
}

/// Clase para representar el resultado de una actualización de racha
/// Class to represent streak update result
class StreakUpdate {
  final int newStreak;
  final bool isNewRecord;
  final bool streakMaintained;
  final bool streakBroken;
  final bool alreadyScannedToday;
  final bool isFirstScan;
  final bool manipulationDetected;

  StreakUpdate({
    required this.newStreak,
    required this.isNewRecord,
    required this.streakMaintained,
    this.streakBroken = false,
    this.alreadyScannedToday = false,
    this.isFirstScan = false,
    this.manipulationDetected = false,
  });

  /// Obtener mensaje de feedback al usuario
  /// Get user feedback message
  String getFeedbackMessage(String languageCode) {
    if (languageCode == 'en') {
      if (manipulationDetected) return "⚠️ Time manipulation detected! Scan blocked for security.";
      if (isFirstScan) return "🎉 Welcome! Your love journey begins now!";
      if (alreadyScannedToday) return "✨ Already scanned today! Keep that streak alive tomorrow!";
      if (streakBroken) return "💔 Streak broken, but you're back! New streak: $newStreak day";
      if (isNewRecord) return "🏆 NEW RECORD! $newStreak days streak! You're unstoppable!";
      if (streakMaintained) return "🔥 Streak continues! $newStreak days of love scanning!";
      return "Keep going! $newStreak days strong!";
    } else {
      if (manipulationDetected) return "⚠️ ¡Manipulación de tiempo detectada! Escaneo bloqueado por seguridad.";
      if (isFirstScan) return "🎉 ¡Bienvenido! ¡Tu aventura de amor comienza ahora!";
      if (alreadyScannedToday) return "✨ ¡Ya escaneaste hoy! ¡Mantén la racha viva mañana!";
      if (streakBroken) return "💔 Racha rota, ¡pero regresaste! Nueva racha: $newStreak día";
      if (isNewRecord) return "🏆 ¡NUEVO RÉCORD! ¡$newStreak días de racha! ¡Eres imparable!";
      if (streakMaintained) return "🔥 ¡La racha continúa! ¡$newStreak días escaneando amor!";
      return "¡Sigue así! ¡$newStreak días fuerte!";
    }
  }
}
