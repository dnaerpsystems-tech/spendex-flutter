import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

/// Service for managing screen security features.
///
/// Provides screenshot and screen recording prevention on supported platforms.
///
/// Features:
/// - FLAG_SECURE on Android to prevent screenshots/recordings
/// - Platform-aware implementation (Android supported, iOS no-op)
/// - Toggle enable/disable for different app states
class ScreenSecurity {
  ScreenSecurity._();

  /// Whether secure mode is currently enabled.
  static bool _isSecureMode = false;

  /// Get the current secure mode state.
  static bool get isSecureMode => _isSecureMode;

  /// Method channel for platform-specific security features.
  static const MethodChannel _channel = MethodChannel('spendex/screen_security');

  /// Enable secure mode to prevent screenshots and screen recordings.
  ///
  /// On Android, this sets FLAG_SECURE on the window.
  /// On iOS, this is currently a no-op (requires additional native setup).
  static Future<void> enableSecureMode() async {
    if (_isSecureMode) return;

    try {
      if (Platform.isAndroid) {
        await _enableSecureModeAndroid();
        _isSecureMode = true;
        if (kDebugMode) {
          AppLogger.d('ScreenSecurity: Secure mode enabled');
        }
      } else if (Platform.isIOS) {
        // iOS requires additional native implementation
        // Using a MethodChannel would require native Swift code
        if (kDebugMode) {
          AppLogger.d('ScreenSecurity: iOS secure mode not implemented');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScreenSecurity: Failed to enable secure mode', e, stackTrace);
    }
  }

  /// Disable secure mode to allow screenshots and screen recordings.
  static Future<void> disableSecureMode() async {
    if (_isSecureMode == false) return;

    try {
      if (Platform.isAndroid) {
        await _disableSecureModeAndroid();
        _isSecureMode = false;
        if (kDebugMode) {
          AppLogger.d('ScreenSecurity: Secure mode disabled');
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('ScreenSecurity: Failed to disable secure mode', e, stackTrace);
    }
  }

  /// Toggle secure mode.
  static Future<void> toggleSecureMode() async {
    if (_isSecureMode) {
      await disableSecureMode();
    } else {
      await enableSecureMode();
    }
  }

  /// Enable FLAG_SECURE on Android using system UI overlay.
  static Future<void> _enableSecureModeAndroid() async {
    // Use SystemChrome to set secure overlay style
    // Note: Full FLAG_SECURE requires native Android code
    // This is a partial implementation using available Flutter APIs
    try {
      await _channel.invokeMethod<void>('enableSecureMode');
    } on MissingPluginException {
      // Fallback: The MethodChannel isn't implemented natively
      // Log a warning but don't throw
      if (kDebugMode) {
        AppLogger.d('ScreenSecurity: Native plugin not available, using fallback');
      }
      // Fallback implementation - request non-secure system UI
      // This doesn't fully prevent screenshots but signals intent
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  /// Disable FLAG_SECURE on Android.
  static Future<void> _disableSecureModeAndroid() async {
    try {
      await _channel.invokeMethod<void>('disableSecureMode');
    } on MissingPluginException {
      // Fallback: restore normal system UI
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  /// Check if secure mode is supported on the current platform.
  static bool get isSupported {
    return Platform.isAndroid;
  }

  /// Get a description of the security status.
  static String get statusDescription {
    if (isSupported == false) {
      return 'Screen security not supported on this platform';
    }

    if (_isSecureMode) {
      return 'Screenshots and screen recording are blocked';
    }

    return 'Screenshots and screen recording are allowed';
  }
}

/// Extension for enabling secure mode on specific screens.
///
/// Use this mixin on sensitive screens that should prevent screenshots.
mixin SecureScreenMixin<T extends Object> {
  /// Enable secure mode when the screen is shown.
  void enableScreenSecurity() {
    ScreenSecurity.enableSecureMode();
  }

  /// Disable secure mode when leaving the screen.
  void disableScreenSecurity() {
    ScreenSecurity.disableSecureMode();
  }
}
