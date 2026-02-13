import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../config/environment.dart';

/// Centralized logging utility for Spendex
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    level: kDebugMode ? Level.debug : Level.warning,
  );

  /// Log debug message
  static void d(String message, [dynamic data]) {
    if (EnvironmentConfig.enableLogging) {
      if (data != null) {
        _logger.d('$message: $data');
      } else {
        _logger.d(message);
      }
    }
  }

  /// Log info message
  static void i(String message, [dynamic data]) {
    if (EnvironmentConfig.enableLogging) {
      if (data != null) {
        _logger.i('$message: $data');
      } else {
        _logger.i(message);
      }
    }
  }

  /// Log warning message
  static void w(String message, [dynamic data]) {
    if (data != null) {
      _logger.w('$message: $data');
    } else {
      _logger.w(message);
    }
  }

  /// Log error message
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log verbose message (for detailed debugging)
  static void v(String message, [dynamic data]) {
    if (EnvironmentConfig.enableLogging) {
      if (data != null) {
        _logger.t('$message: $data');
      } else {
        _logger.t(message);
      }
    }
  }

  /// Log API request
  static void apiRequest(String method, String url, [dynamic body]) {
    if (EnvironmentConfig.enableLogging) {
      _logger.d('API Request: $method $url', error: body);
    }
  }

  /// Log API response
  static void apiResponse(String url, int statusCode, [dynamic body]) {
    if (EnvironmentConfig.enableLogging) {
      _logger.d('API Response [$statusCode]: $url');
    }
  }

  /// Log navigation event
  static void navigation(String route) {
    if (EnvironmentConfig.enableLogging) {
      _logger.d('Navigation: $route');
    }
  }
}
