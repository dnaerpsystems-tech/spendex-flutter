import "dart:async";
import "dart:io" show Platform;
import "dart:isolate";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart";
import "../config/environment.dart";
import "../utils/app_logger.dart";
import "firebase_service.dart";

class CrashlyticsService {
  CrashlyticsService._();

  static FirebaseCrashlytics? _instance;

  static FirebaseCrashlytics? get instance {
    if (!FirebaseService.isSupported) return null;
    _instance ??= FirebaseCrashlytics.instance;
    return _instance;
  }

  static Future<void> initialize() async {
    // Skip on unsupported platforms
    if (!FirebaseService.isSupported) {
      AppLogger.d("CrashlyticsService: Skipped on unsupported platform");
      return;
    }

    // Disable in debug mode
    if (kDebugMode) {
      await instance?.setCrashlyticsCollectionEnabled(false);
      AppLogger.d("CrashlyticsService: Disabled in debug mode");
      return;
    }

    // Enable in production
    if (EnvironmentConfig.enableCrashlytics) {
      await instance?.setCrashlyticsCollectionEnabled(true);
      AppLogger.d("CrashlyticsService: Enabled for production");
    }
  }

  static void setupErrorHandlers() {
    // Flutter framework errors
    FlutterError.onError = (details) {
      if (kDebugMode) {
        FlutterError.presentError(details);
        AppLogger.e("FlutterError", details.exception, details.stack);
      } else if (FirebaseService.isSupported) {
        instance?.recordFlutterFatalError(details);
      }
    };

    // Async errors not caught by Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        AppLogger.e("PlatformDispatcher error", error, stack);
      } else if (FirebaseService.isSupported) {
        instance?.recordError(error, stack, fatal: true);
      }
      return true;
    };

    // Isolate errors
    Isolate.current.addErrorListener(
      RawReceivePort((pair) async {
        final errorAndStacktrace = pair as List<dynamic>;
        final error = errorAndStacktrace.first;
        final stack = StackTrace.fromString(errorAndStacktrace.last.toString());
        if (!kDebugMode && FirebaseService.isSupported) {
          await instance?.recordError(error, stack, fatal: true);
        }
      }).sendPort,
    );
  }

  static Future<void> recordError(
    Object exception,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (kDebugMode) {
      AppLogger.e("CrashlyticsService: $reason", exception, stack);
      return;
    }

    if (!FirebaseService.isSupported) return;

    await instance?.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  static Future<void> log(String message) async {
    if (!kDebugMode && FirebaseService.isSupported) {
      await instance?.log(message);
    }
  }

  static Future<void> setUserIdentifier(String userId) async {
    if (!kDebugMode && FirebaseService.isSupported) {
      await instance?.setUserIdentifier(userId);
    }
  }

  static Future<void> setCustomKey(String key, Object value) async {
    if (!kDebugMode && FirebaseService.isSupported) {
      await instance?.setCustomKey(key, value);
    }
  }
}
