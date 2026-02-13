import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// Abstract interface for biometric authentication service.
///
/// Provides methods for checking biometric availability, enabling/disabling
/// biometric authentication, and performing biometric authentication.
abstract class BiometricService {
  /// Check if biometric authentication is available on the device.
  ///
  /// Returns true if the device has biometric hardware and at least one
  /// biometric (fingerprint, face, etc.) is enrolled.
  Future<bool> isBiometricAvailable();

  /// Check if biometric authentication is enabled for this app.
  ///
  /// Returns true if the user has enabled biometric authentication in settings.
  Future<bool> isBiometricEnabled();

  /// Enable biometric authentication for this app.
  ///
  /// Stores the biometric enabled state in secure storage.
  Future<void> enableBiometric();

  /// Disable biometric authentication for this app.
  ///
  /// Removes the biometric enabled state from secure storage.
  Future<void> disableBiometric();

  /// Authenticate using biometrics.
  ///
  /// [reason] - The message to display to the user explaining why
  /// authentication is needed.
  /// Returns true if authentication was successful, false otherwise.
  Future<bool> authenticateWithBiometric({String reason = 'Authenticate to continue'});

  /// Get available biometric types on the device.
  ///
  /// Returns a list of [BiometricType] available on the device.
  Future<List<BiometricType>> getAvailableBiometrics();
}

/// Implementation of [BiometricService] using local_auth package.
///
/// This service manages biometric authentication for the Spendex app:
/// - Checks device biometric availability
/// - Manages biometric enabled state in secure storage
/// - Performs biometric authentication using the local_auth plugin
///
/// Security features:
/// - Biometric enabled state stored in secure storage (platform keychain/keystore)
/// - Uses stickyAuth to handle system dialog interruptions
/// - Supports fingerprint, face recognition, and iris scanning
class BiometricServiceImpl implements BiometricService {
  /// Creates a new BiometricServiceImpl instance.
  ///
  /// [_storage] - The secure storage instance for storing biometric state.
  BiometricServiceImpl(this._storage);

  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Storage key for biometric enabled state.
  static const String _biometricEnabledKey = 'spendex_biometric_enabled';

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      // Check if device supports biometrics
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (canCheckBiometrics == false || isDeviceSupported == false) {
        return false;
      }

      // Check if at least one biometric is enrolled
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      // If we can't check biometrics, assume unavailable
      return false;
    }
  }

  @override
  Future<bool> isBiometricEnabled() async {
    try {
      // First check if biometric is even available
      final isAvailable = await isBiometricAvailable();
      if (isAvailable == false) {
        return false;
      }

      // Check if user has enabled biometric authentication
      final enabledValue = await _storage.read(key: _biometricEnabledKey);
      return enabledValue == 'true';
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> enableBiometric() async {
    // Verify biometric is available before enabling
    final isAvailable = await isBiometricAvailable();
    if (isAvailable == false) {
      throw Exception('Biometric authentication is not available on this device');
    }

    // Verify the user can authenticate before enabling
    final authenticated = await authenticateWithBiometric(
      reason: 'Verify your identity to enable biometric authentication',
    );
    if (authenticated == false) {
      throw Exception('Biometric verification failed');
    }

    // Store the enabled state
    await _storage.write(key: _biometricEnabledKey, value: 'true');
  }

  @override
  Future<void> disableBiometric() async {
    await _storage.delete(key: _biometricEnabledKey);
  }

  @override
  Future<bool> authenticateWithBiometric({
    String reason = 'Authenticate to continue',
  }) async {
    try {
      // Check availability first
      final isAvailable = await isBiometricAvailable();
      if (isAvailable == false) {
        return false;
      }

      // Perform authentication
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return authenticated;
    } catch (e) {
      // Authentication failed or was cancelled
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
