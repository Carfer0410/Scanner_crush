import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Niveles de log para clasificar mensajes
enum LogLevel { debug, info, warning, error }

/// Servicio centralizado de logging para Scanner Crush.
///
/// Reemplaza todos los `print()` del proyecto con un logger
/// estructurado que:
/// - Solo imprime en modo debug (kDebugMode)
/// - Clasifica por niveles (debug, info, warning, error)
/// - Usa `dart:developer` log para integración con DevTools
/// - Incluye nombre de origen para rastrear dónde se genera el mensaje
class LoggerService {
  LoggerService._();

  static LogLevel _minimumLevel = LogLevel.debug;

  /// Ajusta el nivel mínimo de logging (útil para producción).
  static void setMinimumLevel(LogLevel level) {
    _minimumLevel = level;
  }

  // ── Métodos públicos ──────────────────────────────────────

  /// Log de nivel debug – info de desarrollo, nunca visible en producción.
  static void debug(String message, {String? origin}) {
    _log(LogLevel.debug, message, origin: origin);
  }

  /// Log de nivel info – flujo normal de la app.
  static void info(String message, {String? origin}) {
    _log(LogLevel.info, message, origin: origin);
  }

  /// Log de nivel warning – algo inesperado pero no fatal.
  static void warning(String message, {String? origin, Object? error}) {
    _log(LogLevel.warning, message, origin: origin, error: error);
  }

  /// Log de nivel error – fallo que requiere atención.
  static void error(
    String message, {
    String? origin,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      origin: origin,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // ── Internals ─────────────────────────────────────────────

  static void _log(
    LogLevel level,
    String message, {
    String? origin,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minimumLevel.index) return;

    // En release no loguear nada salvo errores críticos
    if (!kDebugMode && level != LogLevel.error) return;

    final emoji = _emoji(level);
    final tag = origin != null ? '[$origin] ' : '';
    final errorSuffix = error != null ? ' | error=$error' : '';
    final formatted = '$emoji $tag$message$errorSuffix';

    if (kDebugMode) {
      developer.log(
        formatted,
        name: 'ScannerCrush',
        level: _devLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  static String _emoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return '✅';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  static int _devLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
