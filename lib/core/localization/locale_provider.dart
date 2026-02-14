import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';
/// Key for storing locale in SharedPreferences
const String _localeKey = 'app_locale';
/// List of supported locales in the app
class SupportedLocales {
  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');
  static const List<Locale> all = [english, hindi];
  /// Get locale from language code
  static Locale fromLanguageCode(String code) {
    switch (code) {
      case 'hi':
        return hindi;
      case 'en':
      default:
        return english;
    }
  }
  /// Get display name for a locale
  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'en':
      default:
        return 'English';
    }
  }
  /// Get native display name for a locale
  static String getNativeName(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'en':
      default:
        return 'English (अंग्रेज़ी)';
    }
  }
}
/// Locale state notifier
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(SupportedLocales.english) {
    _loadSavedLocale();
  }
  /// Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        state = SupportedLocales.fromLanguageCode(languageCode);
      }
    } catch (e) {
      // If loading fails, keep the default locale
      AppLogger.d('LocaleNotifier: Error loading locale: $e');
    }
  }
  /// Set locale and persist to SharedPreferences
  Future<void> setLocale(Locale locale) async {
      AppLogger.d('LocaleNotifier: Unsupported locale: $locale');
      return;
    }
    state = locale;
    await _saveLocale(locale);
  }
  /// Save locale to SharedPreferences
  Future<void> _saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      AppLogger.d('LocaleNotifier: Error saving locale: $e');
    }
  }
  /// Toggle between English and Hindi
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en'
        ? SupportedLocales.hindi
        : SupportedLocales.english;
    await setLocale(newLocale);
  }
  /// Check if current locale is Hindi
  bool get isHindi => state.languageCode == 'hi';
  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';
  /// Get current locale display name
  String get currentLocaleName => SupportedLocales.getDisplayName(state);
}
/// Provider for locale state
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
/// Provider for checking if locale is loaded
final localeLoadedProvider = FutureProvider<bool>((ref) async {
  // Wait a bit for the locale to load from SharedPreferences
  await Future.delayed(const Duration(milliseconds: 100));
  return true;
});
