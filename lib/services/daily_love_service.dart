import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';
import 'secure_time_service.dart';
import 'streak_service.dart';

import 'logger_service.dart';
class DailyLoveService {
  static final DailyLoveService _instance = DailyLoveService._internal();
  factory DailyLoveService() => _instance;
  DailyLoveService._internal();

  static DailyLoveService get instance => _instance;

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      
      // Validar y corregir datos corruptos al inicializar
      await _validateAndFixCorruptedData();
    } catch (e) {
      // Remove print and use debugPrint for development
      _isInitialized = false;
      rethrow;
    }
  }

  /// Valida y corrige datos corruptos en las estadísticas
  Future<void> _validateAndFixCorruptedData() async {
    if (_prefs == null) return;
    
    final total = _prefs!.getDouble('total_compatibility') ?? 0.0;
    final scans = getTotalScans();
    
    // Si hay escaneos pero el promedio es imposible, resetear compatibilidades
    if (scans > 0 && total > 0) {
      final average = total / scans;
      if (average > 100.0) {
        LoggerService.warning('Datos corruptos detectados: promedio=$average%, total=$total, escaneos=$scans', origin: 'DailyLoveService');
        await _resetCompatibilityStats();
      }
    }
  }

  Future<SharedPreferences> get prefs async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // Obtener horóscopo del día
  Map<String, dynamic> getTodayLoveHoroscope() {
    final today = SecureTimeService.instance.getSecureTime();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % 7; // Usando 7 horóscopos diferentes
    return {'index': index}; // Devolvemos solo el índice
  }

  // Obtener horóscopo localizado del día
  Map<String, dynamic> getTodayLoveHoroscopeLocalized(BuildContext context) {
    final today = SecureTimeService.instance.getSecureTime();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % 7; // 7 horóscopos diferentes
    final l10n = AppLocalizations.of(context);

    switch (index) {
      case 0:
        return {
          'title': l10n?.magneticConnection ?? '',
          'message': l10n?.magneticConnectionMessage ?? '',
          'advice': l10n?.magneticConnectionAdvice ?? '',
          'color': 0xFFE91E63,
        };
      case 1:
        return {
          'title': l10n?.dayOfRevelations ?? '',
          'message': l10n?.dayOfRevelationsMessage ?? '',
          'advice': l10n?.dayOfRevelationsAdvice ?? '',
          'color': 0xFF9C27B0,
        };
      case 2:
        return {
          'title': l10n?.romanceInTheAir ?? '',
          'message': l10n?.romanceInTheAirMessage ?? '',
          'advice': l10n?.romanceInTheAirAdvice ?? '',
          'color': 0xFFD32F2F,
        };
      case 3:
        return {
          'title': l10n?.destinyAligned ?? '',
          'message': l10n?.destinyAlignedMessage ?? '',
          'advice': l10n?.destinyAlignedAdvice ?? '',
          'color': 0xFF673AB7,
        };
      case 4:
        return {
          'title': l10n?.butterfliesInStomach ?? '',
          'message': l10n?.butterfliesInStomachMessage ?? '',
          'advice': l10n?.butterfliesInStomachAdvice ?? '',
          'color': 0xFFE91E63,
        };
      case 5:
        return {
          'title': l10n?.burningPassion ?? '',
          'message': l10n?.burningPassionMessage ?? '',
          'advice': l10n?.burningPassionAdvice ?? '',
          'color': 0xFFBF360C,
        };
      case 6:
      default:
        return {
          'title': l10n?.authenticLove ?? '',
          'message': l10n?.authenticLoveMessage ?? '',
          'advice': l10n?.authenticLoveAdvice ?? '',
          'color': 0xFF3F51B5,
        };
    }
  }

  // Racha de días consecutivos – delegates to StreakService (single source of truth)
  int getCurrentStreak() {
    return StreakService.instance.currentStreak;
  }

  Future<void> updateStreak() async {
    // No-op: streak is managed exclusively by StreakService.recordAppVisit()
    // which is called from the app lifecycle in main.dart.
  }

  // Estadísticas de uso con validación
  int getTotalScans() {
    // Delegate to StreakService as single source of truth
    return StreakService.instance.totalScans;
  }

  Future<void> incrementTotalScans() async {
    final prefs = await this.prefs;
    final current = prefs.getInt('total_scans') ?? 0;
    await prefs.setInt('total_scans', current + 1);
    // Sync StreakService in-memory value
    await StreakService.instance.syncWithDailyLoveService();
  }

  // Compatibilidad promedio
  double getAverageCompatibility() {
    if (_prefs == null) return 0.0;
    final total = _prefs!.getDouble('total_compatibility') ?? 0.0;
    final scans = getTotalScans();
    
    // Validación: si no hay escaneos, promedio es 0
    if (scans <= 0) return 0.0;
    
    final average = total / scans;
    
    // Validación: el promedio nunca debe ser mayor a 100% o menor a 0%
    if (average > 100.0) {
      // Datos corruptos - resetear las estadísticas de compatibilidad
      _resetCompatibilityStats();
      return 0.0;
    }
    
    if (average < 0.0) {
      return 0.0;
    }
    
    return average;
  }

  // Método para resetear estadísticas corruptas
  Future<void> _resetCompatibilityStats() async {
    final prefs = await this.prefs;
    await prefs.setDouble('total_compatibility', 0.0);
    LoggerService.warning('Estadísticas de compatibilidad corruptas detectadas - reseteadas', origin: 'DailyLoveService');
  }

  Future<void> addCompatibilityScore(double score) async {
    // Validación: solo aceptar porcentajes válidos (0-100)
    if (score < 0.0 || score > 100.0) {
      LoggerService.warning('Puntuación de compatibilidad inválida: $score% - ignorada', origin: 'DailyLoveService');
      return;
    }
    
    final prefs = await this.prefs;
    final current = prefs.getDouble('total_compatibility') ?? 0.0;
    await prefs.setDouble('total_compatibility', current + score);
  }

  // Consejos personalizados basados en estadísticas
  String getPersonalizedTip() {
    final streak = getCurrentStreak();
    final avgCompatibility = getAverageCompatibility();
    final totalScans = getTotalScans();

    if (streak >= 7) {
      return "🔥 ¡Increíble racha de $streak días! Tu energía amorosa está en su punto máximo.";
    } else if (avgCompatibility >= 80) {
      return "⭐ Tu compatibilidad promedio es excelente (${avgCompatibility.toInt()}%). ¡Tienes buen ojo para el amor!";
    } else if (totalScans >= 10) {
      return "💡 Con $totalScans escaneos realizados, tu experiencia amorosa está creciendo. ¡Sigue explorando!";
    } else if (avgCompatibility >= 60) {
      return "💫 Tu compatibilidad promedio es buena. Confía en tus instintos amorosos.";
    } else {
      return "🌱 Cada escaneo te acerca más a encontrar tu conexión perfecta. ¡No te rindas!";
    }
  }

  // Consejos personalizados localizados
  String getPersonalizedTipLocalized(BuildContext context) {
    final streak = getCurrentStreak();
    final avgCompatibility = getAverageCompatibility();
    final totalScans = getTotalScans();
    final l10n = AppLocalizations.of(context);
    // Fallback to default tip if localization is unavailable
    if (l10n == null) return getPersonalizedTip();

    if (streak >= 7) {
      return l10n.personalizedTipStreak(streak);
    } else if (avgCompatibility >= 80) {
      return l10n.personalizedTipCompatibility(avgCompatibility.toInt());
    } else if (totalScans >= 10) {
      return l10n.personalizedTipScans(totalScans);
    } else if (avgCompatibility >= 60) {
      return l10n.personalizedTipGoodCompatibility;
    } else {
      return l10n.personalizedTipEncouragement;
    }
  }

  // Logros desbloqueados con validación completa
  List<Map<String, dynamic>> getUnlockedAchievements() {
    // Primero validar y reparar datos corruptos
    _validateAllData();
    
    final achievements = <Map<String, dynamic>>[];
    final streak = getCurrentStreak();
    final totalScans = getTotalScans();
    final avgCompatibility = getAverageCompatibility();

    // Log para debugging
    LoggerService.debug('Logros - Streak: $streak, Total Scans: $totalScans, Avg: $avgCompatibility%', origin: 'DailyLoveService');

    if (streak >= 3) {
      achievements.add({
        'title': '🔥 Racha de Fuego',
        'description': '$streak días consecutivos',
        'icon': '🔥',
      });
    }

    if (totalScans >= 5) {
      achievements.add({
        'title': '🎯 Explorador del Amor',
        'description': '$totalScans escaneos realizados',
        'icon': '🎯',
      });
    }

    if (avgCompatibility >= 75) {
      achievements.add({
        'title': '⭐ Maestro de la Compatibilidad',
        'description': '${avgCompatibility.toInt()}% promedio',
        'icon': '⭐',
      });
    }

    if (totalScans >= 20) {
      achievements.add({
        'title': '👑 Gurú del Romance',
        'description': 'Experto en el amor',
        'icon': '👑',
      });
    }

    return achievements;
  }

  // Logros desbloqueados localizados con validación
  List<Map<String, dynamic>> getUnlockedAchievementsLocalized(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context);
    // Fallback to default achievements if localization unavailable
    if (l10n == null) return getUnlockedAchievements();
    
    // Primero validar y reparar datos corruptos
    _validateAllData();
    
    final achievements = <Map<String, dynamic>>[];
    final streak = getCurrentStreak();
    final totalScans = getTotalScans();
    final avgCompatibility = getAverageCompatibility();

    if (streak >= 3) {
      achievements.add({
        'title': l10n.fireStreak,
        'description': l10n.fireStreakDescription(streak),
        'icon': '🔥',
      });
    }

    if (totalScans >= 5) {
      achievements.add({
        'title': l10n.loveExplorer,
        'description': l10n.loveExplorerDescription(totalScans),
        'icon': '🎯',
      });
    }

    if (avgCompatibility >= 75) {
      achievements.add({
        'title': l10n.compatibilityMaster,
        'description': l10n.compatibilityMasterDescription(
          avgCompatibility.toInt(),
        ),
        'icon': '⭐',
      });
    }

    if (totalScans >= 20) {
      achievements.add({
        'title': l10n.romanceGuru,
        'description': l10n.romanceGuruDescription,
        'icon': '👑',
      });
    }

    return achievements;
  }

  // Validación completa de todos los datos del sistema
  void _validateAllData() {
    if (_prefs == null) return;
    
    bool needsRepair = false;
    // Streak is owned by StreakService – do NOT read/write 'love_streak' here.
    final totalScans = _prefs!.getInt('total_scans') ?? 0;
    final totalCompatibility = _prefs!.getDouble('total_compatibility') ?? 0.0;
    
    // Validar total de escaneos
    if (totalScans < 0 || totalScans > 10000) {
      LoggerService.warning('Validación: Total de escaneos corrupto ($totalScans). Reiniciando.', origin: 'DailyLoveService');
      _prefs!.setInt('total_scans', 0);
      needsRepair = true;
    }
    
    // Validar consistencia: si hay compatibilidad guardada pero 0 escaneos,
    // solo limpiar la compatibilidad (no resetear escaneos)
    if (totalScans == 0 && totalCompatibility > 0) {
      LoggerService.warning('Validación: Compatibilidad huérfana sin escaneos. Limpiando.', origin: 'DailyLoveService');
      _prefs!.setDouble('total_compatibility', 0.0);
      needsRepair = true;
    }
    
    // Validar que el promedio no sea imposible (>100%)
    if (totalScans > 0 && totalCompatibility / totalScans > 100.0) {
      LoggerService.warning('Validación: Promedio imposible. Reseteando compatibilidad.', origin: 'DailyLoveService');
      _prefs!.setDouble('total_compatibility', 0.0);
      needsRepair = true;
    }
    
    if (needsRepair) {
      LoggerService.info('Validación completa: Datos reparados automáticamente.', origin: 'DailyLoveService');
    }
  }
}

