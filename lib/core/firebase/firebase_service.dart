import "dart:io" show Platform;

import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "../utils/app_logger.dart";

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Check if Firebase is supported on this platform
  static bool get isSupported {
    if (kIsWeb) return true;
    // Firebase is not fully supported on Windows/Linux/macOS desktop
    // Only iOS, Android, and Web are fully supported
    return Platform.isIOS || Platform.isAndroid;
  }

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    // Skip Firebase on unsupported platforms (Windows, Linux, macOS)
    if (!isSupported) {
      AppLogger.d("FirebaseService: Skipping Firebase on unsupported platform");
      _initialized = true; // Mark as initialized to prevent retry
      return;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
      if (kDebugMode) {
        AppLogger.d("FirebaseService: Firebase initialized successfully");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        AppLogger.e("FirebaseService: Failed to initialize Firebase", e, stack);
      }
      rethrow;
    }
  }
}
