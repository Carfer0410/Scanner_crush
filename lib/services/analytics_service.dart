import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/crush_result.dart';
import 'monetization_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    if (!await MonetizationService.instance.isPremiumWithGrace()) {
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
  Future<List<PersonalInsight>> getPersonalInsights(AppLocalizations loc) async {
    if (!await MonetizationService.instance.isPremiumWithGrace()) {
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
          title: loc.insightMasterLove,
          description: '⭐ Your average compatibility is exceptional (${stats.averageCompatibility.toInt()}%). You have a natural gift for love!',
          type: InsightType.positive,
        ));
      } else if (stats.averageCompatibility >= 60) {
        insights.add(PersonalInsight(
          icon: '💫',
          title: loc.insightGoodRadar,
          description: 'Your average compatibility is solid (${stats.averageCompatibility.toInt()}%). You trust your instincts.',
          type: InsightType.neutral,
        ));
      } else {
        insights.add(PersonalInsight(
          icon: '🌱',
          title: loc.insightExplorerLove,
          description: loc.insightExplorerLoveDesc,
          type: InsightType.motivational,
        ));
      }
    }

    // Insight de preferencias (solo con datos suficientes)
    if (stats.totalScans >= 5) {
      if (stats.celebrityScans > stats.personalScans) {
        insights.add(PersonalInsight(
          icon: '⭐',
          title: loc.insightCelebrityCrusher,
          description: 'You prefer celebrities (${((stats.celebrityScans / stats.totalScans) * 100).toInt()}% of your scans). You like high standards!',
          type: InsightType.fun,
        ));
      } else if (stats.personalScans > 0) {
        insights.add(PersonalInsight(
          icon: '💝',
          title: loc.insightTrueRomantic,
          description: 'You prefer real connections (${((stats.personalScans / stats.totalScans) * 100).toInt()}% of your scans). True love calls you.',
          type: InsightType.positive,
        ));
      }
    }

    // Insight de frecuencia
    if (stats.totalScans >= 50) {
      insights.add(PersonalInsight(
        icon: '🏆',
        title: loc.insightExpert,
  description: 'With ${stats.totalScans} scans, you are an expert. Your experience is invaluable.',
        type: InsightType.achievement,
      ));
    } else if (stats.totalScans >= 20) {
      insights.add(PersonalInsight(
        icon: '📈',
        title: loc.insightDedicatedUser,
  description: 'You already have ${stats.totalScans} scans. Your dedication to love is admirable!',
        type: InsightType.positive,
      ));
    } else if (stats.totalScans >= 5) {
      insights.add(PersonalInsight(
        icon: '🌟',
        title: loc.insightCommittedExplorer,
  description: 'With ${stats.totalScans} scans, you are building a solid profile. Keep it up!',
        type: InsightType.motivational,
      ));
    } else if (stats.totalScans >= 1) {
      insights.add(PersonalInsight(
        icon: '🚀',
        title: loc.insightNewAdventurer,
        description: loc.insightNewAdventurerDesc,
        type: InsightType.motivational,
      ));
    }

    return insights;
  }

  // Predicciones basadas en patrones
  Future<List<LovePrediction>> getLovePredictions(AppLocalizations loc) async {
    if (!await MonetizationService.instance.isPremiumWithGrace()) {
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
            title: loc.predictionLoveRising,
            description: loc.predictionLoveRisingDesc,
            confidence: 85,
            timeframe: loc.predictionTimeframeNext2Weeks,
          ));
        } else if (recentAvg < olderAvg - 5) {
          predictions.add(LovePrediction(
            icon: '🔄',
            title: loc.predictionTimeReflection,
            description: loc.predictionTimeReflectionDesc,
            confidence: 70,
            timeframe: loc.predictionTimeframeNextMonth,
          ));
        } else {
          predictions.add(LovePrediction(
            icon: '💫',
            title: loc.predictionStableLove,
            description: loc.predictionStableLoveDesc,
            confidence: 75,
            timeframe: loc.predictionTimeframeNext3Weeks,
          ));
        }
      }
    } else if (stats.totalScans >= 5 && stats.totalScans < 10) {
      // Predicciones para usuarios con pocos datos
      predictions.add(LovePrediction(
        icon: '🌱',
        title: loc.predictionDiscoveringPattern,
        description: loc.predictionDiscoveringPatternDesc,
        confidence: 60,
        timeframe: loc.predictionTimeframeNextWeeks,
      ));
    } else if (stats.totalScans >= 1 && stats.totalScans < 5) {
      // Predicciones para usuarios muy nuevos
      predictions.add(LovePrediction(
        icon: '✨',
        title: loc.predictionJourneyStart,
        description: loc.predictionJourneyStartDesc,
        confidence: 50,
        timeframe: loc.predictionTimeframeAsYouExplore,
      ));
    }

    // Predicción basada en patrones de compatibilidad (requiere datos suficientes)
    if (stats.totalScans >= 3 && stats.averageCompatibility >= 75) {
      predictions.add(LovePrediction(
        icon: '💕',
        title: loc.predictionPerfectMatchNear,
        description: 'Your high average compatibility (${stats.averageCompatibility.toInt()}%) suggests your perfect match is very close. Keep your eyes open.',
        confidence: 90,
        timeframe: loc.predictionTimeframeNext3Months,
      ));
    } else if (stats.totalScans >= 3 && stats.averageCompatibility >= 60) {
      predictions.add(LovePrediction(
        icon: '🎯',
        title: loc.predictionGoodLovePath,
        description: 'Your average compatibility (${stats.averageCompatibility.toInt()}%) shows you have good judgment. Trust your instincts.',
        confidence: 75,
        timeframe: loc.predictionTimeframeNext2Months,
      ));
    }

    // Si no hay predicciones y el usuario tiene al menos 1 escaneo, dar una predicción motivacional
    if (predictions.isEmpty && stats.totalScans >= 1) {
      predictions.add(LovePrediction(
        icon: '🔮',
        title: loc.predictionLoveAwaits,
        description: loc.predictionLoveAwaitsDesc,
        confidence: 65,
        timeframe: loc.predictionTimeframeLoveJourney,
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
