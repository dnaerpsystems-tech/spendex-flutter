import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Local Storage Service for non-sensitive data
class LocalStorageService {
  LocalStorageService(this._prefs, this._settingsBox, this._cacheBox);

  final SharedPreferences _prefs;
  final Box<String> _settingsBox;
  final Box<String> _cacheBox;

  // ============ Settings ============

  /// Get theme mode
  String getTheme() {
    return _prefs.getString(AppConstants.themeKey) ?? 'system';
  }

  /// Set theme mode
  Future<void> setTheme(String theme) async {
    await _prefs.setString(AppConstants.themeKey, theme);
  }

  /// Get language
  String getLanguage() {
    return _prefs.getString(AppConstants.languageKey) ?? 'en';
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await _prefs.setString(AppConstants.languageKey, language);
  }

  /// Check if onboarding is completed
  bool isOnboardingCompleted() {
    return _prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  /// Set onboarding completed
  Future<void> setOnboardingCompleted({required bool completed}) async {
    await _prefs.setBool(AppConstants.onboardingKey, completed);
  }

  /// Check if biometric is enabled
  bool isBiometricEnabled() {
    return _prefs.getBool(AppConstants.biometricEnabledKey) ?? false;
  }

  /// Set biometric enabled
  Future<void> setBiometricEnabled({required bool enabled}) async {
    await _prefs.setBool(AppConstants.biometricEnabledKey, enabled);
  }

  /// Check if PIN is enabled
  bool isPinEnabled() {
    return _prefs.getBool(AppConstants.pinEnabledKey) ?? false;
  }

  /// Set PIN enabled
  Future<void> setPinEnabled({required bool enabled}) async {
    await _prefs.setBool(AppConstants.pinEnabledKey, enabled);
  }

  /// Get last sync timestamp
  DateTime? getLastSync() {
    final timestamp = _prefs.getString(AppConstants.lastSyncKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Set last sync timestamp
  Future<void> setLastSync(DateTime timestamp) async {
    await _prefs.setString(AppConstants.lastSyncKey, timestamp.toIso8601String());
  }

  // ============ User Data Cache ============

  /// Save user data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _settingsBox.put(AppConstants.userKey, jsonEncode(user));
  }

  /// Get user data
  Map<String, dynamic>? getUser() {
    final userData = _settingsBox.get(AppConstants.userKey);
    if (userData != null) {
      return jsonDecode(userData) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear user data
  Future<void> clearUser() async {
    await _settingsBox.delete(AppConstants.userKey);
  }

  // ============ Cache Operations ============

  /// Save to cache with expiry
  Future<void> cache(
    String key,
    Object data, {
    Duration expiry = const Duration(hours: 1),
  }) async {
    final cacheData = {
      'data': data,
      'expiry': DateTime.now().add(expiry).toIso8601String(),
    };
    await _cacheBox.put(key, jsonEncode(cacheData));
  }

  /// Get from cache
  T? getCache<T>(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) {
      return null;
    }

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiry = DateTime.parse(cacheData['expiry'] as String);

      if (DateTime.now().isAfter(expiry)) {
        _cacheBox.delete(key);
        return null;
      }

      return cacheData['data'] as T;
    } catch (e) {
      _cacheBox.delete(key);
      return null;
    }
  }

  /// Check if cache exists and is valid
  bool isCacheValid(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) {
      return false;
    }

    try {
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final expiry = DateTime.parse(cacheData['expiry'] as String);
      return DateTime.now().isBefore(expiry);
    } catch (e) {
      return false;
    }
  }

  /// Clear specific cache
  Future<void> clearCache(String key) async {
    await _cacheBox.delete(key);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _cacheBox.clear();
  }

  // ============ Generic Operations ============

  /// Save string
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get string
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save bool
  Future<void> saveBool(String key, {required bool value}) async {
    await _prefs.setBool(key, value);
  }

  /// Get bool
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save int
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Get int
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Remove key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await Future.wait([
      _prefs.clear(),
      _settingsBox.clear(),
      _cacheBox.clear(),
    ]);
  }
}
