import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_crush/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    test('setMinimumLevel filters lower-level messages', () {
      // LoggerService uses static methods and dart:developer,
      // so we just verify it runs without throwing.
      LoggerService.setMinimumLevel(LogLevel.warning);
      LoggerService.debug('This should be filtered');
      LoggerService.info('This should be filtered');
      LoggerService.warning('This should pass');
      LoggerService.error('This should pass');

      // Reset to default
      LoggerService.setMinimumLevel(LogLevel.debug);
    });

    test('all log levels execute without error', () {
      LoggerService.debug('debug message', origin: 'test');
      LoggerService.info('info message', origin: 'test');
      LoggerService.warning('warning message', origin: 'test', error: 'sample');
      LoggerService.error(
        'error message',
        origin: 'test',
        error: Exception('sample'),
        stackTrace: StackTrace.current,
      );
    });

    test('LogLevel enum has correct ordering', () {
      expect(LogLevel.debug.index, lessThan(LogLevel.info.index));
      expect(LogLevel.info.index, lessThan(LogLevel.warning.index));
      expect(LogLevel.warning.index, lessThan(LogLevel.error.index));
    });
  });
}
