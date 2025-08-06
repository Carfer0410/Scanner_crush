import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../generated/l10n/app_localizations.dart';

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
    } catch (e) {
      // Remove print and use debugPrint for development
      _isInitialized = false;
      rethrow;
    }
  }

  Future<SharedPreferences> get prefs async {
    if (!_isInitialized || _prefs == null) {
      await initialize();
    }
    return _prefs!;
  }

  // Lista de horóscopos del amor
  final List<Map<String, dynamic>> _loveHoroscopes = [
    {
      'title': '💘 Conexión Magnética',
      'message':
          'Hoy las energías del amor están especialmente fuertes. Es el momento perfecto para descubrir nuevas conexiones.',
      'advice': 'Mantén tu corazón abierto a las sorpresas del amor.',
      'color': 0xFFE91E63,
    },
    {
      'title': '✨ Día de Revelaciones',
      'message':
          'Los secretos del corazón están listos para ser revelados. Alguien especial podría confesarte algo importante.',
      'advice': 'Presta atención a las señales sutiles de quien te rodea.',
      'color': 0xFF9C27B0,
    },
    {
      'title': '🌹 Romance en el Aire',
      'message':
          'El universo conspira para crear momentos románticos. Tu crush podría estar pensando en ti más de lo que imaginas.',
      'advice': 'Sé valiente y da el primer paso.',
      'color': 0xFFD32F2F,
    },
    {
      'title': '💫 Destino Alineado',
      'message':
          'Las estrellas se alinean para favorecer encuentros casuales que pueden cambiar tu vida amorosa.',
      'advice': 'Sal de tu zona de confort y socializa más.',
      'color': 0xFF673AB7,
    },
    {
      'title': '🦋 Mariposas en el Estómago',
      'message':
          'Hoy sentirás esas mariposas especiales. Tu intuición amorosa está en su punto más alto.',
      'advice': 'Confía en tus instintos del corazón.',
      'color': 0xFFE91E63,
    },
    {
      'title': '🔥 Pasión Ardiente',
      'message':
          'La energía romántica está al máximo. Es un día perfecto para expresar tus sentimientos.',
      'advice': 'No reprimas tus emociones, déjalas fluir.',
      'color': 0xFFBF360C,
    },
    {
      'title': '💎 Amor Auténtico',
      'message':
          'Hoy puedes reconocer el amor verdadero. Las conexiones superficiales se desvanecen.',
      'advice': 'Busca la profundidad en tus relaciones.',
      'color': 0xFF3F51B5,
    },
  ];

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
    final l10n = AppLocalizations.of(context)!;
    
    switch (index) {
      case 0:
        return {
          'title': l10n.magneticConnection,
          'message': l10n.magneticConnectionMessage,
          'advice': l10n.magneticConnectionAdvice,
          'color': 0xFFE91E63,
        };
      case 1:
        return {
          'title': l10n.dayOfRevelations,
          'message': l10n.dayOfRevelationsMessage,
          'advice': l10n.dayOfRevelationsAdvice,
          'color': 0xFF9C27B0,
        };
      case 2:
        return {
          'title': l10n.romanceInTheAir,
          'message': l10n.romanceInTheAirMessage,
          'advice': l10n.romanceInTheAirAdvice,
          'color': 0xFFD32F2F,
        };
      case 3:
        return {
          'title': l10n.destinyAligned,
          'message': l10n.destinyAlignedMessage,
          'advice': l10n.destinyAlignedAdvice,
          'color': 0xFF673AB7,
        };
      case 4:
        return {
          'title': l10n.butterfliesInStomach,
          'message': l10n.butterfliesInStomachMessage,
          'advice': l10n.butterfliesInStomachAdvice,
          'color': 0xFFE91E63,
        };
      case 5:
        return {
          'title': l10n.burningPassion,
          'message': l10n.burningPassionMessage,
          'advice': l10n.burningPassionAdvice,
          'color': 0xFFBF360C,
        };
      case 6:
      default:
        return {
          'title': l10n.authenticLove,
          'message': l10n.authenticLoveMessage,
          'advice': l10n.authenticLoveAdvice,
          'color': 0xFF3F51B5,
        };
    }
  }

  // Racha de días consecutivos
  int getCurrentStreak() {
    if (_prefs == null) return 0;
    return _prefs!.getInt('love_streak') ?? 0;
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
  }

  // Estadísticas de uso
  int getTotalScans() {
    if (_prefs == null) return 0;
    return _prefs!.getInt('total_scans') ?? 0;
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
    return scans > 0 ? total / scans : 0.0;
  }

  Future<void> addCompatibilityScore(double score) async {
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
    final l10n = AppLocalizations.of(context)!;

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

  // Logros desbloqueados
  List<Map<String, dynamic>> getUnlockedAchievements() {
    final achievements = <Map<String, dynamic>>[];
    final streak = getCurrentStreak();
    final totalScans = getTotalScans();
    final avgCompatibility = getAverageCompatibility();

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

  // Logros desbloqueados localizados
  List<Map<String, dynamic>> getUnlockedAchievementsLocalized(BuildContext context) {
    final achievements = <Map<String, dynamic>>[];
    final streak = getCurrentStreak();
    final totalScans = getTotalScans();
    final avgCompatibility = getAverageCompatibility();
    final l10n = AppLocalizations.of(context)!;

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
        'description': l10n.compatibilityMasterDescription(avgCompatibility.toInt()),
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
}
