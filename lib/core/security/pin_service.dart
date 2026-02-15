import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract interface for PIN authentication service.
///
/// Provides methods for setting, verifying, and managing PIN-based
/// authentication with security features like lockout after failed attempts.
abstract class PinService {
  /// Check if a PIN has been set by the user.
  Future<bool> isPinSet();

  /// Set a new PIN for the user.
  ///
  /// [pin] - The PIN to set (4-6 digits).
  /// The PIN is hashed using SHA-256 before storage.
  Future<void> setPin(String pin);

  /// Verify the entered PIN against the stored PIN.
  ///
  /// [pin] - The PIN to verify.
  /// Returns true if the PIN is correct, false otherwise.
  /// Increments failed attempts counter on incorrect PIN.
  Future<bool> verifyPin(String pin);

  /// Clear the stored PIN and reset all related data.
  Future<void> clearPin();

  /// Get the current number of failed PIN attempts.
  Future<int> getFailedAttempts();

  /// Increment the failed attempts counter.
  ///
  /// Automatically triggers lockout when max attempts reached.
  Future<void> incrementFailedAttempts();

  /// Reset the failed attempts counter to zero.
  Future<void> resetFailedAttempts();

  /// Check if the user is currently locked out.
  Future<bool> isLocked();

  /// Get the remaining lockout duration.
  ///
  /// Returns null if not locked.
  Future<Duration?> getLockDuration();

  /// Get the lockout end time.
  ///
  /// Returns null if not locked.
  Future<DateTime?> getLockoutEndTime();
}

/// Implementation of [PinService] using Flutter Secure Storage.
///
/// Security features:
/// - SHA-256 hashing for PIN storage
/// - Maximum 5 failed attempts before lockout
/// - 30-minute lockout duration
/// - Secure storage using platform keychain/keystore
class PinServiceImpl implements PinService {
  /// Creates a new PinServiceImpl instance.
  ///
  /// [_storage] - The secure storage instance to use.
  PinServiceImpl(this._storage);

  final FlutterSecureStorage _storage;

  /// Storage key for the hashed PIN.
  static const String _pinHashKey = 'spendex_pin_hash';

  /// Storage key for the PIN salt.
  static const String _pinSaltKey = 'spendex_pin_salt';

  /// Storage key for failed attempts count.
  static const String _failedAttemptsKey = 'spendex_pin_failed_attempts';

  /// Storage key for lockout end time.
  static const String _lockUntilKey = 'spendex_pin_lock_until';

  /// Maximum number of failed attempts before lockout.
  static const int maxAttempts = 5;

  /// Duration of the lockout period.
  static const Duration lockDuration = Duration(minutes: 30);

  /// Hash a PIN with a salt using SHA-256.
  ///
  /// [pin] - The PIN to hash.
  /// [salt] - The salt to use (generates new if not provided).
  /// Returns a map containing the hash and salt.
  Map<String, String> _hashPin(String pin, {String? salt}) {
    final useSalt = salt ?? _generateSalt();
    final saltedPin = '$useSalt$pin';
    final bytes = utf8.encode(saltedPin);
    final hash = sha256.convert(bytes).toString();
    return {'hash': hash, 'salt': useSalt};
  }

  /// Generate a random salt for PIN hashing.
  String _generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final random = now.toString();
    return sha256.convert(utf8.encode(random)).toString().substring(0, 16);
  }

  @override
  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  @override
  Future<void> setPin(String pin) async {
    // Validate PIN format
    if (pin.length < 4 || pin.length > 6) {
      throw ArgumentError('PIN must be 4-6 digits');
    }

    if (RegExp(r'^\d+$').hasMatch(pin) == false) {
      throw ArgumentError('PIN must contain only digits');
    }

    // Hash the PIN with a new salt
    final result = _hashPin(pin);

    // Store both hash and salt
    await Future.wait([
      _storage.write(key: _pinHashKey, value: result['hash']),
      _storage.write(key: _pinSaltKey, value: result['salt']),
    ]);

    // Reset failed attempts when setting new PIN
    await resetFailedAttempts();
  }

  @override
  Future<bool> verifyPin(String pin) async {
    // Check if locked out first
    if (await isLocked()) {
      return false;
    }

    // Get stored hash and salt
    final storedHash = await _storage.read(key: _pinHashKey);
    final storedSalt = await _storage.read(key: _pinSaltKey);

    if (storedHash == null || storedSalt == null) {
      return false;
    }

    // Hash the input PIN with the stored salt
    final result = _hashPin(pin, salt: storedSalt);

    if (result['hash'] == storedHash) {
      // Correct PIN - reset failed attempts
      await resetFailedAttempts();
      return true;
    } else {
      // Incorrect PIN - increment failed attempts
      await incrementFailedAttempts();
      return false;
    }
  }

  @override
  Future<void> clearPin() async {
    await Future.wait([
      _storage.delete(key: _pinHashKey),
      _storage.delete(key: _pinSaltKey),
      resetFailedAttempts(),
    ]);
  }

  @override
  Future<int> getFailedAttempts() async {
    final value = await _storage.read(key: _failedAttemptsKey);
    return value != null ? int.tryParse(value) ?? 0 : 0;
  }

  @override
  Future<void> incrementFailedAttempts() async {
    final current = await getFailedAttempts();
    final newCount = current + 1;

    await _storage.write(
      key: _failedAttemptsKey,
      value: newCount.toString(),
    );

    // Check if we should trigger lockout
    if (newCount >= maxAttempts) {
      final lockUntil = DateTime.now().add(lockDuration);
      await _storage.write(
        key: _lockUntilKey,
        value: lockUntil.toIso8601String(),
      );
    }
  }

  @override
  Future<void> resetFailedAttempts() async {
    await Future.wait([
      _storage.delete(key: _failedAttemptsKey),
      _storage.delete(key: _lockUntilKey),
    ]);
  }

  @override
  Future<bool> isLocked() async {
    final lockUntilStr = await _storage.read(key: _lockUntilKey);
    if (lockUntilStr == null) {
      return false;
    }

    final lockUntil = DateTime.tryParse(lockUntilStr);
    if (lockUntil == null) {
      return false;
    }

    if (DateTime.now().isAfter(lockUntil)) {
      // Lock has expired - reset
      await resetFailedAttempts();
      return false;
    }

    return true;
  }

  @override
  Future<Duration?> getLockDuration() async {
    final lockUntilStr = await _storage.read(key: _lockUntilKey);
    if (lockUntilStr == null) {
      return null;
    }

    final lockUntil = DateTime.tryParse(lockUntilStr);
    if (lockUntil == null) {
      return null;
    }

    final remaining = lockUntil.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  @override
  Future<DateTime?> getLockoutEndTime() async {
    final lockUntilStr = await _storage.read(key: _lockUntilKey);
    if (lockUntilStr == null) {
      return null;
    }

    final lockUntil = DateTime.tryParse(lockUntilStr);
    if (lockUntil == null) {
      return null;
    }

    if (DateTime.now().isAfter(lockUntil)) {
      return null;
    }

    return lockUntil;
  }
}
