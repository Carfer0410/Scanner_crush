import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        print('⚠️ Datos corruptos detectados: promedio=$average%, total=$total, escaneos=$scans');
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
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    final index = dayOfYear % 7; // Usando 7 horóscopos diferentes
    return {'index': index}; // Devolvemos solo el índice
  }

  // Obtener horóscopo localizado del día
  Map<String, dynamic> getTodayLoveHoroscopeLocalized(BuildContext context) {
    final today = DateTime.now();
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

  // Racha de días consecutivos
  int getCurrentStreak() {
    if (_prefs == null) return 0;
    final streak = _prefs!.getInt('love_streak') ?? 0;
    // Validar que la racha sea razonable (máximo 365 días)
    if (streak < 0 || streak > 365) {
      print('⚠️ getCurrentStreak: Valor corrupto detectado: $streak. Reiniciando a 0.');
      // Reiniciar valor corrupto
      _prefs!.setInt('love_streak', 0);
      return 0;
    }
    return streak;
  }

  Future<void> updateStreak() async {
    final prefs = await this.prefs;
    final lastUsed = prefs.getString('last_used_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastUsed == null) {
      // Primera vez
      await prefs.setInt('love_streak', 1);
      await prefs.setString('last_used_date', today);
    } else if (lastUsed != today) {
      final lastUsedDate = DateTime.parse(lastUsed);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastUsedDate).inDays;

      if (difference == 1) {
        // Día consecutivo
        final currentStreak = getCurrentStreak();
        await prefs.setInt('love_streak', currentStreak + 1);
      } else if (difference > 1) {
        // Se rompió la racha
        await prefs.setInt('love_streak', 1);
      }
      await prefs.setString('last_used_date', today);
    }
    
    // Sincronizar con la UI si hay un StreakService disponible
    // await StreakService.instance.syncWithDailyLoveService();
  }

  // Estadísticas de uso con validación
  int getTotalScans() {
    if (_prefs == null) return 0;
    final scans = _prefs!.getInt('total_scans') ?? 0;
    // Validar que el número de escaneos sea razonable (máximo 10,000)
    if (scans < 0 || scans > 10000) {
      print('⚠️ getTotalScans: Valor corrupto detectado: $scans. Reiniciando a 0.');
      // Reiniciar valor corrupto
      _prefs!.setInt('total_scans', 0);
      return 0;
    }
    return scans;
  }

  Future<void> incrementTotalScans() async {
    final prefs = await this.prefs;
    final current = getTotalScans();
    await prefs.setInt('total_scans', current + 1);
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
    print('⚠️ Estadísticas de compatibilidad corruptas detectadas - reseteadas');
  }

  Future<void> addCompatibilityScore(double score) async {
    // Validación: solo aceptar porcentajes válidos (0-100)
    if (score < 0.0 || score > 100.0) {
      print('⚠️ Puntuación de compatibilidad inválida: $score% - ignorada');
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
    print('📊 Logros - Streak: $streak, Total Scans: $totalScans, Avg: $avgCompatibility%');

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
    final streak = _prefs!.getInt('love_streak') ?? 0;
    final totalScans = _prefs!.getInt('total_scans') ?? 0;
    final scores = _prefs!.getStringList('compatibility_scores') ?? [];
    
    // Validar racha
    if (streak < 0 || streak > 365) {
      print('⚠️ Validación: Racha corrupta ($streak). Reiniciando.');
      _prefs!.setInt('love_streak', 0);
      needsRepair = true;
    }
    
    // Validar total de escaneos
    if (totalScans < 0 || totalScans > 10000) {
      print('⚠️ Validación: Total de escaneos corrupto ($totalScans). Reiniciando.');
      _prefs!.setInt('total_scans', 0);
      needsRepair = true;
    }
    
    // Validar consistencia entre escaneos y puntuaciones
    if (totalScans > 0 && scores.isEmpty) {
      print('⚠️ Validación: Inconsistencia detectada. $totalScans escaneos pero sin puntuaciones.');
      _prefs!.setInt('total_scans', 0);
      needsRepair = true;
    }
    
    // Validar que el número de puntuaciones no exceda el total de escaneos
    if (scores.length > totalScans && totalScans > 0) {
      print('⚠️ Validación: Más puntuaciones (${scores.length}) que escaneos ($totalScans).');
      // Mantener solo las últimas puntuaciones hasta el total de escaneos
      final validScores = scores.take(totalScans).toList();
      _prefs!.setStringList('compatibility_scores', validScores);
      needsRepair = true;
    }
    
    if (needsRepair) {
      print('✅ Validación completa: Datos reparados automáticamente.');
    }
  }
}
