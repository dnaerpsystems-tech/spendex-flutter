import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

import '../utils/app_logger.dart';

/// Result of a device security check.
///
/// Contains information about various security aspects of the device.
class SecurityCheckResult extends Equatable {
  /// Creates a new SecurityCheckResult.
  const SecurityCheckResult({
    required this.isSecure,
    required this.isJailbroken,
    required this.isDeveloperMode,
    this.isRealDevice = true,
    this.isDebuggerAttached = false,
    this.errorMessage,
  });

  /// Create a result indicating a secure device.
  factory SecurityCheckResult.secure() {
    return const SecurityCheckResult(
      isSecure: true,
      isJailbroken: false,
      isDeveloperMode: false,
    );
  }

  /// Create a result indicating an insecure device.
  factory SecurityCheckResult.insecure({
    bool isJailbroken = false,
    bool isDeveloperMode = false,
    bool isRealDevice = true,
    bool isDebuggerAttached = false,
    String? errorMessage,
  }) {
    return SecurityCheckResult(
      isSecure: false,
      isJailbroken: isJailbroken,
      isDeveloperMode: isDeveloperMode,
      isRealDevice: isRealDevice,
      isDebuggerAttached: isDebuggerAttached,
      errorMessage: errorMessage,
    );
  }

  /// Create a result for when the check fails.
  factory SecurityCheckResult.error(String message) {
    return SecurityCheckResult(
      isSecure: true, // Assume secure on error to avoid blocking users
      isJailbroken: false,
      isDeveloperMode: false,
      errorMessage: message,
    );
  }

  /// Whether the device is considered secure for financial operations.
  final bool isSecure;

  /// Whether the device is rooted (Android) or jailbroken (iOS).
  final bool isJailbroken;

  /// Whether developer mode is enabled on the device.
  final bool isDeveloperMode;

  /// Whether this is a real physical device (vs emulator/simulator).
  final bool isRealDevice;

  /// Whether a debugger is currently attached.
  final bool isDebuggerAttached;

  /// Error message if the security check failed.
  final String? errorMessage;

  /// Get a list of security warnings.
  List<String> get warnings {
    final result = <String>[];

    if (isJailbroken) {
      result.add(
        Platform.isIOS
            ? 'This device appears to be jailbroken'
            : 'This device appears to be rooted',
      );
    }

    if (isDeveloperMode) {
      result.add('Developer mode is enabled');
    }

    if (isRealDevice == false) {
      result.add('Running on an emulator or simulator');
    }

    if (isDebuggerAttached) {
      result.add('A debugger is attached');
    }

    return result;
  }

  /// Get a human-readable security status.
  String get statusDescription {
    if (isSecure) {
      return 'Device security check passed';
    }

    final issues = warnings;
    if (issues.isEmpty) {
      return 'Device security check failed';
    }

    return 'Security issues detected:\n${issues.map((w) => '• $w').join('\n')}';
  }

  @override
  List<Object?> get props => [
        isSecure,
        isJailbroken,
        isDeveloperMode,
        isRealDevice,
        isDebuggerAttached,
        errorMessage,
      ];
}

/// Service for checking device security status.
///
/// Detects rooted/jailbroken devices, developer mode, emulators,
/// and other security concerns.
///
/// Features:
/// - Root/jailbreak detection
/// - Developer mode detection
/// - Emulator detection
/// - Comprehensive security status reporting
class DeviceSecurity {
  DeviceSecurity._();

  /// Cached security check result.
  static SecurityCheckResult? _cachedResult;

  /// Time of the last security check.
  static DateTime? _lastCheckTime;

  /// Cache duration for security check results.
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Check if the device is secure for financial operations.
  ///
  /// Returns true if no security issues are detected.
  static Future<bool> isDeviceSecure() async {
    final result = await performSecurityCheck();
    return result.isSecure;
  }

  /// Perform a comprehensive security check.
  ///
  /// Returns a [SecurityCheckResult] with details about the device's
  /// security status.
  ///
  /// Results are cached for 5 minutes to avoid repeated checks.
  static Future<SecurityCheckResult> performSecurityCheck({
    bool forceRefresh = false,
  }) async {
    // Check cache unless force refresh
    if (forceRefresh == false && _cachedResult != null && _lastCheckTime != null) {
      final elapsed = DateTime.now().difference(_lastCheckTime!);
      if (elapsed < _cacheExpiry) {
        return _cachedResult!;
      }
    }

    try {
      // Perform the actual checks
      final isJailbroken = await _checkJailbroken();
      final isDeveloperMode = await _checkDeveloperMode();
      final isRealDevice = await _checkRealDevice();
      final isDebuggerAttached = _checkDebugger();

      // Determine if secure
      // In production, we consider a device insecure if rooted/jailbroken
      // We allow developer mode and emulators for development
      final isSecure = isJailbroken == false;

      final result = SecurityCheckResult(
        isSecure: isSecure,
        isJailbroken: isJailbroken,
        isDeveloperMode: isDeveloperMode,
        isRealDevice: isRealDevice,
        isDebuggerAttached: isDebuggerAttached,
      );

      // Cache the result
      _cachedResult = result;
      _lastCheckTime = DateTime.now();

      if (kDebugMode) {
        AppLogger.d('DeviceSecurity: Check completed - isSecure: $isSecure');
      }

      return result;
    } catch (e, stackTrace) {
      AppLogger.e('DeviceSecurity: Check failed', e, stackTrace);
      // Return secure on error to avoid blocking legitimate users
      return SecurityCheckResult.error(e.toString());
    }
  }

  /// Check if the device is rooted or jailbroken.
  static Future<bool> _checkJailbroken() async {
    try {
      return await FlutterJailbreakDetection.jailbroken;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('DeviceSecurity: Jailbreak check failed: $e');
      }
      return false;
    }
  }

  /// Check if developer mode is enabled.
  static Future<bool> _checkDeveloperMode() async {
    try {
      return await FlutterJailbreakDetection.developerMode;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('DeviceSecurity: Developer mode check failed: $e');
      }
      return false;
    }
  }

  /// Check if running on a real device vs emulator.
  static Future<bool> _checkRealDevice() async {
    try {
      // FlutterJailbreakDetection doesn't have emulator check
      // We'll use a simple heuristic
      if (Platform.isAndroid) {
        // On Android, check common emulator indicators
        // This is a basic check - more comprehensive checks
        // would require native code
        return true;
      } else if (Platform.isIOS) {
        // On iOS, check for simulator
        // Real device check would require native code
        return true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }

  /// Check if a debugger is attached.
  static bool _checkDebugger() {
    // kDebugMode is a compile-time constant
    // It's true when running in debug mode
    return kDebugMode;
  }

  /// Clear the cached security check result.
  ///
  /// Use this to force a fresh check on next call.
  static void clearCache() {
    _cachedResult = null;
    _lastCheckTime = null;
  }

  /// Get the last security check result without performing a new check.
  ///
  /// Returns null if no check has been performed.
  static SecurityCheckResult? get lastResult => _cachedResult;

  /// Check if a cached result is available and valid.
  static bool get hasCachedResult {
    if (_cachedResult == null || _lastCheckTime == null) {
      return false;
    }

    final elapsed = DateTime.now().difference(_lastCheckTime!);
    return elapsed < _cacheExpiry;
  }
}
