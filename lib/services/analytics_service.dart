import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'logger_service.dart';
import '../models/crush_result.dart';
import 'monetization_service.dart';
import 'secure_time_service.dart';
import 'package:scanner_crush/generated/l10n/app_localizations.dart';

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

  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? params,
  }) async {
    final p = await prefs;
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    final counterKey = 'event_${today}_$eventName';
    final count = p.getInt(counterKey) ?? 0;
    await p.setInt(counterKey, count + 1);

    final recentKey = 'event_recent_$today';
    final raw = p.getStringList(recentKey) ?? <String>[];
    final payload = jsonEncode({
      'name': eventName,
      'ts': SecureTimeService.instance.getSecureTime().toIso8601String(),
      if (params != null) 'params': params,
    });
    raw.add(payload);
    if (raw.length > 60) {
      raw.removeRange(0, raw.length - 60);
    }
    await p.setStringList(recentKey, raw);
  }

  Future<Map<String, int>> getEventCountsToday({String? prefix}) async {
    final p = await prefs;
    final today = SecureTimeService.instance.getSecureDate().toIso8601String().split('T')[0];
    final eventPrefix = 'event_${today}_';
    final result = <String, int>{};

    for (final key in p.getKeys()) {
      if (!key.startsWith(eventPrefix)) continue;
      final eventName = key.substring(eventPrefix.length);
      if (prefix != null && !eventName.startsWith(prefix)) continue;
      result[eventName] = p.getInt(key) ?? 0;
    }

    return result;
  }

  // 📊 ANÁLISIS DE COMPATIBILIDAD

  // Obtener estadísticas generales (disponible para todos los usuarios)
  Future<CompatibilityStats> getCompatibilityStats() async {

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
      advancedMetrics: _calculateAdvancedMetrics(allResults),
    );
  }

  AdvancedLoveMetrics _calculateAdvancedMetrics(List<CrushResult> results) {
    if (results.isEmpty) {
      return AdvancedLoveMetrics.empty();
    }

    final total = results.length;
    final uniqueCrushes = results
        .map((r) => r.crushName.trim().toLowerCase())
        .where((n) => n.isNotEmpty)
        .toSet()
        .length;

    final repeatScanRate = total == 0
        ? 0.0
        : ((total - uniqueCrushes).clamp(0, total)) / total;

    final avg = results.map((r) => r.percentage).reduce((a, b) => a + b) / total;
    final variance = results
            .map((r) => (r.percentage - avg) * (r.percentage - avg))
            .reduce((a, b) => a + b) /
        total;
    final volatility = variance.sqrtClamped();

    final consistencyScore = (100 - (volatility * 1.6)).clamp(25, 98).toDouble();

    final emotionalAvg = results.map((r) => r.emotionalScore).reduce((a, b) => a + b) / total;
    final passionAvg = results.map((r) => r.passionScore).reduce((a, b) => a + b) / total;
    final intellectualAvg = results.map((r) => r.intellectualScore).reduce((a, b) => a + b) / total;
    final destinyAvg = results.map((r) => r.destinyScore).reduce((a, b) => a + b) / total;

    final sortedByDate = [...results]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final recentSlice = sortedByDate.length <= 7
        ? sortedByDate
        : sortedByDate.sublist(sortedByDate.length - 7);
    final olderSlice = sortedByDate.length <= 14
        ? sortedByDate.take((sortedByDate.length / 2).floor()).toList()
        : sortedByDate.sublist(sortedByDate.length - 14, sortedByDate.length - 7);

    final recentAvg = recentSlice.isEmpty
        ? avg
        : recentSlice.map((r) => r.percentage).reduce((a, b) => a + b) / recentSlice.length;
    final olderAvg = olderSlice.isEmpty
        ? avg
        : olderSlice.map((r) => r.percentage).reduce((a, b) => a + b) / olderSlice.length;
    final momentum = (recentAvg - olderAvg).toDouble();

    final eliteMatches = results.where((r) => r.percentage >= 85).length;
    final lowMatches = results.where((r) => r.percentage <= 45).length;
    final celebrityRate = total == 0
        ? 0.0
        : results.where((r) => r.isCelebrity).length / total;

    final hourCounter = <int, int>{};
    for (final r in results) {
      hourCounter[r.timestamp.hour] = (hourCounter[r.timestamp.hour] ?? 0) + 1;
    }
    final bestHour = hourCounter.entries.isEmpty
        ? 20
        : hourCounter.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return AdvancedLoveMetrics(
      uniqueCrushes: uniqueCrushes,
      repeatScanRate: repeatScanRate,
      consistencyScore: consistencyScore,
      volatility: volatility,
      momentum: momentum,
      emotionalAvg: emotionalAvg,
      passionAvg: passionAvg,
      intellectualAvg: intellectualAvg,
      destinyAvg: destinyAvg,
      eliteMatches: eliteMatches,
      lowMatches: lowMatches,
      celebrityRate: celebrityRate,
      peakHour: bestHour,
    );
  }

  // Obtener datos de tendencia (últimos 30 días)
  Future<List<TrendPoint>> _getTrendData(List<CrushResult> results) async {
    final now = SecureTimeService.instance.getSecureTime();
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
          LoggerService.warning('Error parsing result $key: $e', origin: 'AnalyticsService');
        }
      }
    }

    // Ordenar por timestamp descendente
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return results;
  }

  // Obtener insights personalizados (premium o desbloqueado por ad)
  Future<List<PersonalInsight>> getPersonalInsights(AppLocalizations loc, {bool bypassPremiumCheck = false}) async {
    if (!bypassPremiumCheck && !await MonetizationService.instance.isPremiumAsync()) {
      throw Exception('Personal Insights require Premium subscription');
    }

    final stats = await getCompatibilityStats();
    final advanced = stats.advancedMetrics;
    final insights = <PersonalInsight>[];

    // Solo generar insights de compatibilidad si hay datos suficientes
    if (stats.totalScans >= 3) {
      // Insight de compatibilidad promedio
      if (stats.averageCompatibility >= 80) {
        insights.add(PersonalInsight(
          icon: '🔥',
          title: loc.insightMasterLove,
          description: loc.insightMasterLoveDesc(stats.averageCompatibility.toInt()),
          type: InsightType.positive,
        ));
      } else if (stats.averageCompatibility >= 60) {
        insights.add(PersonalInsight(
          icon: '💫',
          title: loc.insightGoodRadar,
          description: loc.insightGoodRadarDesc(stats.averageCompatibility.toInt()),
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
          description: loc.insightCelebrityCrusherDesc(((stats.celebrityScans / stats.totalScans) * 100).toInt()),
          type: InsightType.fun,
        ));
      } else if (stats.personalScans > 0) {
        insights.add(PersonalInsight(
          icon: '💝',
          title: loc.insightTrueRomantic,
          description: loc.insightTrueRomanticDesc(((stats.personalScans / stats.totalScans) * 100).toInt()),
          type: InsightType.positive,
        ));
      }
    }

    // Insight de frecuencia
    if (stats.totalScans >= 50) {
      insights.add(PersonalInsight(
        icon: '🏆',
        title: loc.insightExpert,
        description: loc.insightExpertDesc(stats.totalScans),
        type: InsightType.achievement,
      ));
    } else if (stats.totalScans >= 20) {
      insights.add(PersonalInsight(
        icon: '📈',
        title: loc.insightDedicatedUser,
        description: loc.insightDedicatedUserDesc(stats.totalScans),
        type: InsightType.positive,
      ));
    } else if (stats.totalScans >= 5) {
      insights.add(PersonalInsight(
        icon: '🌟',
        title: loc.insightCommittedExplorer,
        description: loc.insightCommittedExplorerDesc(stats.totalScans),
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

    final isEn = loc.localeName.toLowerCase().startsWith('en');

    if (stats.totalScans >= 8) {
      final dominantDimension = <String, double>{
        (isEn ? 'Emotional' : 'Emocional'): advanced.emotionalAvg,
        (isEn ? 'Passion' : 'Pasión'): advanced.passionAvg,
        (isEn ? 'Intellectual' : 'Intelectual'): advanced.intellectualAvg,
        (isEn ? 'Destiny' : 'Destino'): advanced.destinyAvg,
      }.entries.reduce((a, b) => a.value >= b.value ? a : b);

      insights.add(PersonalInsight(
        icon: '🧬',
        title: isEn ? 'Your dominant dimension' : 'Tu dimensión dominante',
        description: isEn
            ? 'Your strongest pattern is ${dominantDimension.key} (${dominantDimension.value.toInt()}%). Use it as your romantic advantage.'
            : 'Tu patrón más fuerte es ${dominantDimension.key} (${dominantDimension.value.toInt()}%). Úsalo como ventaja romántica.',
        type: InsightType.positive,
      ));
    }

    if (stats.totalScans >= 10) {
      if (advanced.consistencyScore >= 72) {
        insights.add(PersonalInsight(
          icon: '🎯',
          title: isEn ? 'Consistent love radar' : 'Radar amoroso consistente',
          description: isEn
              ? 'Your consistency index is ${advanced.consistencyScore.toInt()}%. You are making very coherent romantic choices.'
              : 'Tu índice de consistencia es ${advanced.consistencyScore.toInt()}%. Estás tomando decisiones románticas muy coherentes.',
          type: InsightType.achievement,
        ));
      } else {
        insights.add(PersonalInsight(
          icon: '🧪',
          title: isEn ? 'Exploration phase' : 'Fase de exploración',
          description: isEn
              ? 'Consistency ${advanced.consistencyScore.toInt()}%: you are still testing different profiles. Great stage to discover your type.'
              : 'Consistencia ${advanced.consistencyScore.toInt()}%: todavía estás probando perfiles distintos. Es una gran etapa para descubrir tu tipo.',
          type: InsightType.fun,
        ));
      }
    }

    if (stats.totalScans >= 12 && advanced.momentum.abs() >= 2) {
      insights.add(PersonalInsight(
        icon: advanced.momentum > 0 ? '📈' : '📉',
        title: advanced.momentum > 0
            ? (isEn ? 'Compatibility momentum up' : 'Momentum de compatibilidad al alza')
            : (isEn ? 'Compatibility momentum down' : 'Momentum de compatibilidad a la baja'),
        description: advanced.momentum > 0
            ? (isEn
                ? 'Your recent compatibility improved by +${advanced.momentum.toStringAsFixed(1)} points vs previous period.'
                : 'Tu compatibilidad reciente mejoró +${advanced.momentum.toStringAsFixed(1)} puntos frente al período anterior.')
            : (isEn
                ? 'Your recent compatibility dropped ${advanced.momentum.abs().toStringAsFixed(1)} points. Time to recalibrate your choices.'
                : 'Tu compatibilidad reciente bajó ${advanced.momentum.abs().toStringAsFixed(1)} puntos. Es momento de recalibrar tus elecciones.'),
        type: advanced.momentum > 0 ? InsightType.positive : InsightType.motivational,
      ));
    }

    return insights;
  }

  // Predicciones basadas en patrones (premium o desbloqueado por ad)
  Future<List<LovePrediction>> getLovePredictions(AppLocalizations loc, {bool bypassPremiumCheck = false}) async {
    if (!bypassPremiumCheck && !await MonetizationService.instance.isPremiumAsync()) {
      throw Exception('Love Predictions require Premium subscription');
    }

    final stats = await getCompatibilityStats();
    final advanced = stats.advancedMetrics;
    final predictions = <LovePrediction>[];

    final isEn = loc.localeName.toLowerCase().startsWith('en');

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
        description: loc.predictionGoodLovePathDesc(stats.averageCompatibility.toInt()),
        confidence: 75,
        timeframe: loc.predictionTimeframeNext2Months,
      ));
    }

    if (stats.totalScans >= 10) {
      final dominant = <String, double>{
        (isEn ? 'Emotional' : 'Emocional'): advanced.emotionalAvg,
        (isEn ? 'Passion' : 'Pasión'): advanced.passionAvg,
        (isEn ? 'Intellectual' : 'Intelectual'): advanced.intellectualAvg,
        (isEn ? 'Destiny' : 'Destino'): advanced.destinyAvg,
      }.entries.reduce((a, b) => a.value >= b.value ? a : b);

      predictions.add(LovePrediction(
        icon: '🧭',
        title: isEn ? 'Strategic dimension focus' : 'Enfoque estratégico por dimensión',
        description: isEn
            ? 'In the next 30 days, prioritize profiles strong in ${dominant.key} (${dominant.value.toInt()}%) to maximize high-compatibility matches.'
            : 'En los próximos 30 días, prioriza perfiles fuertes en ${dominant.key} (${dominant.value.toInt()}%) para maximizar matches de alta compatibilidad.',
        confidence: (70 + (advanced.consistencyScore / 5)).clamp(65, 93).toInt(),
        timeframe: isEn ? 'Next 30 days' : 'Próximos 30 días',
      ));
    }

    if (stats.totalScans >= 14) {
      predictions.add(LovePrediction(
        icon: '⏰',
        title: isEn ? 'Best time to scan' : 'Mejor hora para escanear',
        description: isEn
            ? 'Your strongest activity window is around ${_formatHourWindow(advanced.peakHour)}. Scanning there may improve engagement and outcomes.'
            : 'Tu ventana de actividad más fuerte es alrededor de ${_formatHourWindow(advanced.peakHour)}. Escanear ahí puede mejorar engagement y resultados.',
        confidence: 68,
        timeframe: loc.predictionTimeframeNext2Weeks,
      ));
    }

    if (stats.totalScans >= 15) {
      final eliteRate = stats.totalScans == 0 ? 0 : (advanced.eliteMatches * 100 / stats.totalScans).round();
      predictions.add(LovePrediction(
        icon: '🏅',
        title: isEn ? 'Elite match probability' : 'Probabilidad de match élite',
        description: isEn
            ? 'Based on your history, your elite-match probability is around $eliteRate%. Keep quality scans to increase it.'
            : 'Según tu historial, tu probabilidad de match élite ronda el $eliteRate%. Mantén escaneos de calidad para subirla.',
        confidence: (60 + eliteRate / 2).clamp(62, 91).toInt(),
        timeframe: loc.predictionTimeframeNextMonth,
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

  String _formatHourWindow(int hour) {
    final start = hour.clamp(0, 23);
    final end = ((start + 2) % 24);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(start)}:00 - ${two(end)}:00';
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
  final AdvancedLoveMetrics advancedMetrics;

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
    required this.advancedMetrics,
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
      advancedMetrics: AdvancedLoveMetrics.empty(),
    );
  }
}

class AdvancedLoveMetrics {
  final int uniqueCrushes;
  final double repeatScanRate;
  final double consistencyScore;
  final double volatility;
  final double momentum;
  final double emotionalAvg;
  final double passionAvg;
  final double intellectualAvg;
  final double destinyAvg;
  final int eliteMatches;
  final int lowMatches;
  final double celebrityRate;
  final int peakHour;

  AdvancedLoveMetrics({
    required this.uniqueCrushes,
    required this.repeatScanRate,
    required this.consistencyScore,
    required this.volatility,
    required this.momentum,
    required this.emotionalAvg,
    required this.passionAvg,
    required this.intellectualAvg,
    required this.destinyAvg,
    required this.eliteMatches,
    required this.lowMatches,
    required this.celebrityRate,
    required this.peakHour,
  });

  factory AdvancedLoveMetrics.empty() => AdvancedLoveMetrics(
        uniqueCrushes: 0,
        repeatScanRate: 0,
        consistencyScore: 0,
        volatility: 0,
        momentum: 0,
        emotionalAvg: 0,
        passionAvg: 0,
        intellectualAvg: 0,
        destinyAvg: 0,
        eliteMatches: 0,
        lowMatches: 0,
        celebrityRate: 0,
        peakHour: 20,
      );
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

extension _DoubleSqrtClamp on double {
  double sqrtClamped() {
    if (isNaN || isInfinite || this < 0) return 0;
    double x = this;
    double guess = x / 2.0;
    if (guess == 0) return 0;
    for (int i = 0; i < 8; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}

