import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Secure Storage Service for sensitive data
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  /// Save access and refresh tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return _storage.read(key: AppConstants.accessTokenKey);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  /// Save PIN
  Future<void> savePin(String pin) async {
    await _storage.write(key: AppConstants.pinKey, value: pin);
  }

  /// Get PIN
  Future<String?> getPin() async {
    return _storage.read(key: AppConstants.pinKey);
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }

  /// Delete PIN
  Future<void> deletePin() async {
    await _storage.delete(key: AppConstants.pinKey);
  }

  /// Save biometric credential ID
  Future<void> saveBiometricCredentialId(String credentialId) async {
    await _storage.write(key: 'biometric_credential_id', value: credentialId);
  }

  /// Get biometric credential ID
  Future<String?> getBiometricCredentialId() async {
    return _storage.read(key: 'biometric_credential_id');
  }

  /// Delete biometric credential ID
  Future<void> deleteBiometricCredentialId() async {
    await _storage.delete(key: 'biometric_credential_id');
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Save arbitrary key-value pair
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read arbitrary key
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  /// Delete arbitrary key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }
}
