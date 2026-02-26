import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de tiempo seguro que previene manipulación de fechas del sistema
class SecureTimeService {
  static final SecureTimeService _instance = SecureTimeService._internal();
  factory SecureTimeService() => _instance;
  SecureTimeService._internal();

  static SecureTimeService get instance => _instance;

  SharedPreferences? _prefs;
  DateTime? _lastKnownServerTime;
  DateTime? _lastLocalTime;
  Duration? _timeOffset;
  bool _isInitialized = false;
  DateTime? _appStartTime; // Para detectar manipulaciones extremas
  int _manipulationDetections = 0;

  // URLs de servidores de tiempo confiables (con fallbacks)
  final List<String> _timeServers = [
    'https://worldtimeapi.org/api/timezone/UTC',
    'https://timeapi.io/api/Time/current/coordinate?latitude=0&longitude=0',
    'https://timeapi.io/api/Time/current/zone?timeZone=UTC',
  ];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _appStartTime = DateTime.now(); // Marcar inicio de la app
    await _loadStoredTimeData();
    
    // Resetear contador de manipulaciones cada reinicio de la app
    _manipulationDetections = 0;
    
    await _syncWithServer();
    _isInitialized = true;
    
    // Verificar sincronización cada hora
    _startPeriodicSync();
  }

  /// Carga los datos de tiempo almacenados previamente
  Future<void> _loadStoredTimeData() async {
    final lastServerTimeString = _prefs?.getString('last_server_time');
    final lastLocalTimeString = _prefs?.getString('last_local_time');
    final offsetSeconds = _prefs?.getInt('time_offset_seconds');

    if (lastServerTimeString != null && lastLocalTimeString != null && offsetSeconds != null) {
      _lastKnownServerTime = DateTime.tryParse(lastServerTimeString);
      _lastLocalTime = DateTime.tryParse(lastLocalTimeString);
      _timeOffset = Duration(seconds: offsetSeconds);
    }
  }

  /// Guarda los datos de tiempo para persistencia
  Future<void> _saveTimeData() async {
    if (_lastKnownServerTime != null && _lastLocalTime != null && _timeOffset != null) {
      await _prefs?.setString('last_server_time', _lastKnownServerTime!.toIso8601String());
      await _prefs?.setString('last_local_time', _lastLocalTime!.toIso8601String());
      await _prefs?.setInt('time_offset_seconds', _timeOffset!.inSeconds);
    }
  }

  /// Sincroniza con servidor de tiempo externo
  Future<bool> _syncWithServer() async {
    for (final serverUrl in _timeServers) {
      try {
        final serverTime = await _fetchTimeFromServer(serverUrl);
        if (serverTime != null) {
          final localTime = DateTime.now();
          _lastKnownServerTime = serverTime;
          _lastLocalTime = localTime;
          _timeOffset = serverTime.difference(localTime);
          await _saveTimeData();
          return true;
        }
      } catch (e) {
        continue;
      }
    }
    return false;
  }

  /// Obtiene tiempo de un servidor específico
  Future<DateTime?> _fetchTimeFromServer(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Diferentes formatos según el API
        String? timeString;
        if (url.contains('worldtimeapi.org')) {
          timeString = data['utc_datetime'];
        } else if (url.contains('timeapi.io')) {
          timeString = data['dateTime'];
        }

        if (timeString != null) {
          return DateTime.parse(timeString).toUtc();
        }
      }
    } catch (e) {
      // Error silenciado para producción
    }
    return null;
  }

  /// Inicia sincronización periódica cada hora
  void _startPeriodicSync() {
    Future.delayed(const Duration(hours: 1), () async {
      await _syncWithServer();
      _startPeriodicSync(); // Reiniciar el ciclo
    });
  }

  /// Obtiene el tiempo real seguro (no manipulable por el usuario)
  DateTime getSecureTime() {
    if (!_isInitialized) {
      return DateTime.now();
    }

    final currentLocalTime = DateTime.now();

    // Si no tenemos datos de servidor, usar tiempo base hasta sincronización
    if (_lastKnownServerTime == null || _lastLocalTime == null || _timeOffset == null) {
      // Inicializar de forma asíncrona en segundo plano
      _syncWithServer().then((_) => _saveTimeData());
      
      // Usar tiempo conservador basado en el tiempo de inicio de la app
      if (_appStartTime != null) {
        final elapsedSinceStart = currentLocalTime.difference(_appStartTime!);
        // Limitar el tiempo transcurrido a máximo 24 horas desde el inicio
        final safeElapsed = Duration(
          milliseconds: elapsedSinceStart.inMilliseconds.clamp(0, 24 * 60 * 60 * 1000),
        );
        return _appStartTime!.add(safeElapsed);
      }

      return currentLocalTime;
    }

    // DETECCIÓN PRINCIPAL DE MANIPULACIÓN
    final timeSinceLastCheck = currentLocalTime.difference(_lastLocalTime!);
    
    // 1. Detectar saltos de tiempo imposibles (más de 1 hora hacia adelante o hacia atrás)
    if (timeSinceLastCheck.abs() > const Duration(hours: 1)) {
      _manipulationDetections++;
      
      // Usar tiempo conservador: último tiempo conocido + tiempo limitado
      final conservativeElapsed = Duration(
        minutes: timeSinceLastCheck.inMinutes.clamp(-60, 60) // Max ±1 hora
      );
      final conservativeTime = _lastKnownServerTime!.add(conservativeElapsed);
      
      // Actualizar referencias con tiempo conservador
      _lastLocalTime = currentLocalTime;
      _lastKnownServerTime = conservativeTime;
      
      // Iniciar resincronización urgente
      _syncWithServer().then((_) => _saveTimeData());
      
      return conservativeTime;
    }
    
    // 2. Verificar coherencia con el tiempo de inicio de la app
    if (_appStartTime != null) {
      final totalElapsedSinceStart = currentLocalTime.difference(_appStartTime!);
      
      // Si el tiempo calculado es muy diferente al esperado desde el inicio
      if (totalElapsedSinceStart.abs() > const Duration(hours: 2)) {
        _manipulationDetections++;
        
        // Usar tiempo conservador anclado al último valor válido disponible.
        final baseline = _lastKnownServerTime ?? _appStartTime ?? currentLocalTime;
        final safeTime = baseline.add(
          Duration(minutes: totalElapsedSinceStart.inMinutes.clamp(0, 120)),
        );
        
        _lastLocalTime = currentLocalTime;
        _lastKnownServerTime = safeTime;
        
        return safeTime;
      }
    }

    // 3. Tiempo normal - actualizar y devolver
    final secureTime = currentLocalTime.add(_timeOffset!);
    
    // Actualizar referencias para próximas verificaciones
    _lastLocalTime = currentLocalTime;
    _lastKnownServerTime = secureTime;
    
    // Guardar datos periódicamente
    if (currentLocalTime.millisecondsSinceEpoch % 60000 < 100) { // Cada ~1 minuto
      _saveTimeData();
    }
    
    return secureTime;
  }

  /// Verifica si han pasado X días desde una fecha dada de forma segura
  bool hasSecureDaysPassed(DateTime referenceDate, int days) {
    final secureNow = getSecureTime();
    final daysPassed = secureNow.difference(referenceDate).inDays;
    return daysPassed >= days;
  }

  /// Obtiene la fecha segura sin tiempo (solo año, mes, día)
  DateTime getSecureDate() {
    final secureTime = getSecureTime();
    return DateTime(secureTime.year, secureTime.month, secureTime.day);
  }

  /// Verifica si dos fechas son del mismo día (de forma segura)
  bool isSameSecureDay(DateTime date1, DateTime date2) {
    final secureDate1 = DateTime(date1.year, date1.month, date1.day);
    final secureDate2 = DateTime(date2.year, date2.month, date2.day);
    return secureDate1.isAtSameMomentAs(secureDate2);
  }

  /// Obtiene los días transcurridos desde una fecha de forma segura
  int getSecureDaysSince(DateTime referenceDate) {
    final secureNow = getSecureTime();
    return secureNow.difference(referenceDate).inDays;
  }

  /// Fuerza una nueva sincronización (no destructiva: preserva datos si falla)
  Future<bool> forceSyncNow() async {
    // Guardar backup del estado actual por si la sincronización falla
    final backupServerTime = _lastKnownServerTime;
    final backupLocalTime = _lastLocalTime;
    final backupOffset = _timeOffset;
    
    final success = await _syncWithServer();
    if (success) {
      await _saveTimeData();
    } else {
      // Restaurar estado anterior si la sincronización falló
      _lastKnownServerTime = backupServerTime;
      _lastLocalTime = backupLocalTime;
      _timeOffset = backupOffset;
    }
    
    return success;
  }

  /// Información de debug sobre el estado del servicio
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'lastKnownServerTime': _lastKnownServerTime?.toIso8601String(),
      'lastLocalTime': _lastLocalTime?.toIso8601String(),
      'timeOffset': _timeOffset?.toString(),
      'currentSecureTime': getSecureTime().toIso8601String(),
      'currentLocalTime': DateTime.now().toIso8601String(),
      'appStartTime': _appStartTime?.toIso8601String(),
      'manipulationDetections': _manipulationDetections,
    };
  }
}
