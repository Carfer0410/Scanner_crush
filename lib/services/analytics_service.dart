import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/crush_result.dart';
import 'monetization_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  static AnalyticsService get instance => _instance;

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // 📊 ANÁLISIS DE COMPATIBILIDAD PREMIUM

  // Obtener estadísticas generales
  Future<CompatibilityStats> getCompatibilityStats() async {
    if (!MonetizationService.instance.isPremium) {
      throw Exception('Analytics requires Premium subscription');
    }

    final allResults = await _getAllResults();
    
    if (allResults.isEmpty) {
      return CompatibilityStats.empty();
    }

    final totalScans = allResults.length;
    final rawAverage = allResults
        .map((r) => r.percentage)
        .reduce((a, b) => a + b) / totalScans;
    
    // Validar que el resultado no sea NaN o Infinity
    final averageCompatibility = rawAverage.isNaN || rawAverage.isInfinite 
        ? 0.0 
        : rawAverage;

    final highestCompatibility = allResults
        .map((r) => r.percentage)
        .reduce((a, b) => a > b ? a : b);

    final lowestCompatibility = allResults
        .map((r) => r.percentage)
        .reduce((a, b) => a < b ? a : b);

    // Análisis por categorías
    final celebrityScans = allResults.where((r) => r.isCelebrity).length;
    final personalScans = allResults.where((r) => !r.isCelebrity).length;

    final celebrityAvg = allResults.where((r) => r.isCelebrity).isEmpty
        ? 0.0
        : () {
            final rawAvg = allResults
                .where((r) => r.isCelebrity)
                .map((r) => r.percentage)
                .reduce((a, b) => a + b) / celebrityScans;
            return rawAvg.isNaN || rawAvg.isInfinite ? 0.0 : rawAvg;
          }();

    final personalAvg = allResults.where((r) => !r.isCelebrity).isEmpty
        ? 0.0
        : () {
            final rawAvg = allResults
                .where((r) => !r.isCelebrity)
                .map((r) => r.percentage)
                .reduce((a, b) => a + b) / personalScans;
            return rawAvg.isNaN || rawAvg.isInfinite ? 0.0 : rawAvg;
          }();

    return CompatibilityStats(
      totalScans: totalScans,
      averageCompatibility: averageCompatibility,
      highestCompatibility: highestCompatibility,
      lowestCompatibility: lowestCompatibility,
      celebrityScans: celebrityScans,
      personalScans: personalScans,
      celebrityAverage: celebrityAvg,
      personalAverage: personalAvg,
      trendData: await _getTrendData(allResults),
      topMatches: await _getTopMatches(allResults),
      monthlyData: await _getMonthlyData(allResults),
    );
  }

  // Obtener datos de tendencia (últimos 30 días)
  Future<List<TrendPoint>> _getTrendData(List<CrushResult> results) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentResults = results
        .where((r) => r.timestamp.isAfter(thirtyDaysAgo))
        .toList();

    // Agrupar por día
    final dailyData = <String, List<int>>{};
    
    for (final result in recentResults) {
      final dayKey = '${result.timestamp.year}-${result.timestamp.month}-${result.timestamp.day}';
      dailyData[dayKey] ??= [];
      dailyData[dayKey]!.add(result.percentage);
    }

    final trendPoints = <TrendPoint>[];
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayKey = '${date.year}-${date.month}-${date.day}';
      final dayResults = dailyData[dayKey] ?? [];
      
      final average = dayResults.isEmpty 
          ? 0.0 
          : dayResults.reduce((a, b) => a + b) / dayResults.length;
      
      trendPoints.add(TrendPoint(
        date: date,
        average: average,
        count: dayResults.length,
      ));
    }

    return trendPoints;
  }

  // Obtener mejores matches
  Future<List<CrushResult>> _getTopMatches(List<CrushResult> results) async {
    results.sort((a, b) => b.percentage.compareTo(a.percentage));
    return results.take(10).toList();
  }

  // Obtener datos mensuales
  Future<List<MonthlyData>> _getMonthlyData(List<CrushResult> results) async {
    final monthlyMap = <String, List<int>>{};
    
    for (final result in results) {
      final monthKey = '${result.timestamp.year}-${result.timestamp.month}';
      monthlyMap[monthKey] ??= [];
      monthlyMap[monthKey]!.add(result.percentage);
    }

    final monthlyData = <MonthlyData>[];
    
    for (final entry in monthlyMap.entries) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final percentages = entry.value;
      
      // Validación para evitar división por zero
      if (percentages.isEmpty) continue;
      
      final average = percentages.reduce((a, b) => a + b) / percentages.length;
      
      monthlyData.add(MonthlyData(
        year: year,
        month: month,
        average: average,
        count: percentages.length,
        monthName: _getMonthName(month),
      ));
    }

    monthlyData.sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });

    return monthlyData.take(12).toList();
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  // Obtener todos los resultados guardados
  Future<List<CrushResult>> _getAllResults() async {
    final prefs = await this.prefs;
    final keys = prefs.getKeys().where((key) => key.startsWith('result_'));
    
    final results = <CrushResult>[];
    
    for (final key in keys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final json = jsonDecode(jsonString);
          
          // Validar que los datos críticos existen
          if (json is Map<String, dynamic> &&
              json['crushName'] != null && 
              json['percentage'] != null && 
              json['timestamp'] != null) {
            
            final result = CrushResult.fromJson(json);
            
            // Validar rangos de datos
            if (result.percentage >= 0 && 
                result.percentage <= 100 &&
                result.crushName.trim().isNotEmpty) {
              results.add(result);
            }
          }
        } catch (e) {
          // Log error but continue processing other results
          debugPrint('Error parsing result $key: $e');
        }
      }
    }

    // Ordenar por timestamp descendente
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return results;
  }

  // Obtener insights personalizados
  Future<List<PersonalInsight>> getPersonalInsights() async {
    if (!MonetizationService.instance.isPremium) {
      throw Exception('Personal Insights require Premium subscription');
    }

    final stats = await getCompatibilityStats();
    final insights = <PersonalInsight>[];

    // Solo generar insights de compatibilidad si hay datos suficientes
    if (stats.totalScans >= 3) {
      // Insight de compatibilidad promedio
      if (stats.averageCompatibility >= 80) {
        insights.add(PersonalInsight(
          icon: '🔥',
          title: 'Master del Amor',
          description: 'Tu compatibilidad promedio es excepcional (${stats.averageCompatibility.toInt()}%). ¡Tienes un don natural para el amor!',
          type: InsightType.positive,
        ));
      } else if (stats.averageCompatibility >= 60) {
        insights.add(PersonalInsight(
          icon: '💫',
          title: 'Buen Radar Amoroso',
          description: 'Tu compatibilidad promedio es sólida (${stats.averageCompatibility.toInt()}%). Confías en tus instintos.',
          type: InsightType.neutral,
        ));
      } else {
        insights.add(PersonalInsight(
          icon: '🌱',
          title: 'Explorador del Amor',
          description: 'Estás explorando diferentes tipos de conexiones. ¡Cada escaneo te acerca más a tu match perfecto!',
          type: InsightType.motivational,
        ));
      }
    }

    // Insight de preferencias (solo con datos suficientes)
    if (stats.totalScans >= 5) {
      if (stats.celebrityScans > stats.personalScans) {
        insights.add(PersonalInsight(
          icon: '⭐',
          title: 'Celebrity Crusher',
          description: 'Prefieres las celebridades (${((stats.celebrityScans / stats.totalScans) * 100).toInt()}% de tus escaneos). ¡Te gustan los estándares altos!',
          type: InsightType.fun,
        ));
      } else if (stats.personalScans > 0) {
        insights.add(PersonalInsight(
          icon: '💝',
          title: 'Romántico Auténtico',
          description: 'Prefieres conexiones reales (${((stats.personalScans / stats.totalScans) * 100).toInt()}% de tus escaneos). El amor verdadero te llama.',
          type: InsightType.positive,
        ));
      }
    }

    // Insight de frecuencia
    if (stats.totalScans >= 50) {
      insights.add(PersonalInsight(
        icon: '🏆',
        title: 'Experto en Compatibilidad',
        description: 'Con ${stats.totalScans} escaneos, eres todo un experto. Tu experiencia es invaluable.',
        type: InsightType.achievement,
      ));
    } else if (stats.totalScans >= 20) {
      insights.add(PersonalInsight(
        icon: '📈',
        title: 'Usuario Dedicado',
        description: 'Ya llevas ${stats.totalScans} escaneos. ¡Tu dedicación al amor es admirable!',
        type: InsightType.positive,
      ));
    } else if (stats.totalScans >= 5) {
      insights.add(PersonalInsight(
        icon: '🌟',
        title: 'Explorador Comprometido',
        description: 'Con ${stats.totalScans} escaneos, estás construyendo un perfil sólido. ¡Sigue así!',
        type: InsightType.motivational,
      ));
    } else if (stats.totalScans >= 1) {
      insights.add(PersonalInsight(
        icon: '🚀',
        title: 'Nuevo Aventurero',
        description: 'Has comenzado tu viaje de descubrimiento amoroso. ¡Cada escaneo revela algo nuevo!',
        type: InsightType.motivational,
      ));
    }

    return insights;
  }

  // Predicciones basadas en patrones
  Future<List<LovePrediction>> getLovePredictions() async {
    if (!MonetizationService.instance.isPremium) {
      throw Exception('Love Predictions require Premium subscription');
    }

    final stats = await getCompatibilityStats();
    final predictions = <LovePrediction>[];

    // Verificar que hay suficientes datos reales para tendencias
    final realDataPoints = stats.trendData.where((t) => t.count > 0).length;
    
    // Predicción basada en tendencia (requiere al menos 10 escaneos en 7+ días diferentes)
    if (stats.totalScans >= 10 && realDataPoints >= 7) {
      final recentData = stats.trendData
          .takeLast(7)
          .where((t) => t.count > 0)
          .toList();
      
      final olderData = stats.trendData
          .take(7)
          .where((t) => t.count > 0)
          .toList();

      // Verificar que hay datos suficientes para calcular promedios
      if (recentData.isEmpty || olderData.isEmpty) {
        // No hacer predicciones de tendencia si no hay datos suficientes
        // Continuar con otros tipos de predicciones
      } else {
        final recentAvg = recentData
            .map((t) => t.average)
            .fold(0.0, (a, b) => a + b) / recentData.length;
        
        final olderAvg = olderData
            .map((t) => t.average)
            .fold(0.0, (a, b) => a + b) / olderData.length;

        if (recentAvg > olderAvg + 5) {
          predictions.add(LovePrediction(
            icon: '📈',
            title: 'Amor en Ascenso',
            description: 'Tu compatibilidad ha mejorado últimamente. Las próximas semanas serán prometedoras para el amor.',
            confidence: 85,
            timeframe: 'Próximas 2 semanas',
          ));
        } else if (recentAvg < olderAvg - 5) {
          predictions.add(LovePrediction(
            icon: '🔄',
            title: 'Tiempo de Reflexión',
            description: 'Es un buen momento para reflexionar sobre qué buscas en el amor. La claridad traerá mejores conexiones.',
            confidence: 70,
            timeframe: 'Próximo mes',
          ));
        } else {
          predictions.add(LovePrediction(
            icon: '💫',
            title: 'Amor Estable',
            description: 'Tu compatibilidad se mantiene consistente. Es un buen momento para consolidar conexiones.',
            confidence: 75,
            timeframe: 'Próximas 3 semanas',
          ));
        }
      }
    } else if (stats.totalScans >= 5 && stats.totalScans < 10) {
      // Predicciones para usuarios con pocos datos
      predictions.add(LovePrediction(
        icon: '🌱',
        title: 'Descubriendo Tu Patrón',
        description: 'Estás construyendo tu perfil amoroso. Cada escaneo nos ayuda a entender mejor tus preferencias.',
        confidence: 60,
        timeframe: 'Próximas semanas',
      ));
    } else if (stats.totalScans >= 1 && stats.totalScans < 5) {
      // Predicciones para usuarios muy nuevos
      predictions.add(LovePrediction(
        icon: '✨',
        title: 'Inicio de Tu Viaje',
        description: 'Has comenzado tu exploración amorosa. ¡Sigue escaneando para descubrir patrones fascinantes!',
        confidence: 50,
        timeframe: 'A medida que explores',
      ));
    }

    // Predicción basada en patrones de compatibilidad (requiere datos suficientes)
    if (stats.totalScans >= 3 && stats.averageCompatibility >= 75) {
      predictions.add(LovePrediction(
        icon: '💕',
        title: 'Match Perfecto Cerca',
        description: 'Tu alta compatibilidad promedio (${stats.averageCompatibility.toInt()}%) sugiere que tu match perfecto está muy cerca. Mantén los ojos abiertos.',
        confidence: 90,
        timeframe: 'Próximos 3 meses',
      ));
    } else if (stats.totalScans >= 3 && stats.averageCompatibility >= 60) {
      predictions.add(LovePrediction(
        icon: '🎯',
        title: 'Buen Camino Amoroso',
        description: 'Tu compatibilidad promedio (${stats.averageCompatibility.toInt()}%) muestra que tienes buen criterio. Confía en tus instintos.',
        confidence: 75,
        timeframe: 'Próximos 2 meses',
      ));
    }

    // Si no hay predicciones y el usuario tiene al menos 1 escaneo, dar una predicción motivacional
    if (predictions.isEmpty && stats.totalScans >= 1) {
      predictions.add(LovePrediction(
        icon: '🔮',
        title: 'El Amor Te Espera',
        description: 'Cada escaneo te acerca más a entender el amor. ¡Sigue explorando y descubriendo tu camino!',
        confidence: 65,
        timeframe: 'En tu viaje amoroso',
      ));
    }

    return predictions;
  }
}

// 📊 Clases de datos para analytics

class CompatibilityStats {
  final int totalScans;
  final double averageCompatibility;
  final int highestCompatibility;
  final int lowestCompatibility;
  final int celebrityScans;
  final int personalScans;
  final double celebrityAverage;
  final double personalAverage;
  final List<TrendPoint> trendData;
  final List<CrushResult> topMatches;
  final List<MonthlyData> monthlyData;

  CompatibilityStats({
    required this.totalScans,
    required this.averageCompatibility,
    required this.highestCompatibility,
    required this.lowestCompatibility,
    required this.celebrityScans,
    required this.personalScans,
    required this.celebrityAverage,
    required this.personalAverage,
    required this.trendData,
    required this.topMatches,
    required this.monthlyData,
  });

  factory CompatibilityStats.empty() {
    return CompatibilityStats(
      totalScans: 0,
      averageCompatibility: 0.0,
      highestCompatibility: 0,
      lowestCompatibility: 0,
      celebrityScans: 0,
      personalScans: 0,
      celebrityAverage: 0.0,
      personalAverage: 0.0,
      trendData: [],
      topMatches: [],
      monthlyData: [],
    );
  }
}

class TrendPoint {
  final DateTime date;
  final double average;
  final int count;

  TrendPoint({
    required this.date,
    required this.average,
    required this.count,
  });
}

class MonthlyData {
  final int year;
  final int month;
  final double average;
  final int count;
  final String monthName;

  MonthlyData({
    required this.year,
    required this.month,
    required this.average,
    required this.count,
    required this.monthName,
  });
}

class PersonalInsight {
  final String icon;
  final String title;
  final String description;
  final InsightType type;

  PersonalInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.type,
  });
}

enum InsightType {
  positive,
  neutral,
  motivational,
  fun,
  achievement,
}

class LovePrediction {
  final String icon;
  final String title;
  final String description;
  final int confidence;
  final String timeframe;

  LovePrediction({
    required this.icon,
    required this.title,
    required this.description,
    required this.confidence,
    required this.timeframe,
  });
}

// Extension para takeLast
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
