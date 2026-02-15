import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

class FirebaseService {
  FirebaseService._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
      if (kDebugMode) {
        AppLogger.d('FirebaseService: Firebase initialized successfully');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        AppLogger.e('FirebaseService: Failed to initialize Firebase', e, stack);
      }
      rethrow;
    }
  }
}
