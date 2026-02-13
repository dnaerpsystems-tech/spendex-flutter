import 'dart:async';

import 'package:flutter/services.dart';

/// Platform channel for native SMS operations on Android
///
/// This service provides native SMS reading capabilities through platform channels.
/// Requires Android platform to be added to the Flutter project.
///
/// Setup instructions:
/// 1. Add Android platform: `flutter create --platforms=android .`
/// 2. Add SMS permissions to AndroidManifest.xml:
///    ```xml
///    <uses-permission android:name="android.permission.READ_SMS" />
///    <uses-permission android:name="android.permission.RECEIVE_SMS" />
///    ```
/// 3. Implement MainActivity.kt platform channel handler
class SmsPlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.spendex/sms');

  /// Check if SMS reading is supported on this platform
  /// Returns true on Android, false on other platforms
  Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } on PlatformException catch (_) {
      // Platform not implemented, return false
      return false;
    } on MissingPluginException catch (_) {
      // Plugin not registered, return false
      return false;
    }
  }

  /// Read SMS messages from device inbox
  ///
  /// Parameters:
  /// - [startDate]: Filter messages from this date
  /// - [endDate]: Filter messages until this date
  /// - [addresses]: Filter messages from specific sender addresses (optional)
  ///
  /// Returns list of SMS messages as Map with keys:
  /// - id: String - SMS message ID
  /// - address: String - Sender phone number/name
  /// - body: String - SMS message content
  /// - date: int - Timestamp in milliseconds
  /// - read: bool - Whether message was read
  Future<List<Map<String, dynamic>>> readSmsMessages({
    required DateTime startDate,
    required DateTime endDate,
    List<String>? addresses,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'readSmsMessages',
        {
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
          'addresses': addresses,
        },
      );

      if (result == null) return [];

      return result
          .cast<Map<dynamic, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    } on PlatformException catch (e) {
      throw SmsPlatformException(
        'Failed to read SMS messages: ${e.message}',
        code: e.code,
      );
    } on MissingPluginException catch (_) {
      throw const SmsPlatformException(
        'SMS platform channel not implemented. '
        'Please add Android platform to the project.',
      );
    }
  }

  /// Request SMS read permission
  /// Returns true if permission granted, false otherwise
  Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SmsPlatformException(
        'Failed to request SMS permission: ${e.message}',
        code: e.code,
      );
    } on MissingPluginException catch (_) {
      throw const SmsPlatformException(
        'SMS platform channel not implemented. '
        'Please add Android platform to the project.',
      );
    }
  }

  /// Check if SMS read permission is granted
  Future<bool> hasPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SmsPlatformException(
        'Failed to check SMS permission: ${e.message}',
        code: e.code,
      );
    } on MissingPluginException catch (_) {
      // Platform not implemented, return false
      return false;
    }
  }
}

/// Exception thrown when SMS platform channel operations fail
class SmsPlatformException implements Exception {
  const SmsPlatformException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'SmsPlatformException: $message${code != null ? ' (code: $code)' : ''}';
}
