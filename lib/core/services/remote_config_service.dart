import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Remote Config service for feature flags and dynamic configuration
class RemoteConfigService {
  RemoteConfigService._();

  static FirebaseRemoteConfig? _remoteConfig;
  static bool _initialized = false;

  static FirebaseRemoteConfig get instance {
    _remoteConfig ??= FirebaseRemoteConfig.instance;
    return _remoteConfig!;
  }

  /// Initialize Remote Config with defaults
  static Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
      await instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
        ),
      );

      // Set default values
      await instance.setDefaults(_defaults);

      // Fetch and activate
      await instance.fetchAndActivate();

      _initialized = true;
      AppLogger.d('RemoteConfigService: Initialized successfully');
    } catch (e, stack) {
      AppLogger.e('RemoteConfigService: Failed to initialize', e, stack);
    }
  }

  /// Default values for remote config
  static const Map<String, dynamic> _defaults = {
    // Feature flags
    'feature_voice_input': true,
    'feature_receipt_scan': true,
    'feature_bank_import': true,
    'feature_family_sharing': true,
    'feature_insights': true,
    'feature_investments': true,
    'feature_loans': true,

    // App config
    'min_app_version': '1.0.0',
    'force_update_enabled': false,
    'maintenance_mode': false,
    'maintenance_message': 'We are currently performing maintenance. Please try again later.',

    // Limits
    'free_transaction_limit': 50,
    'free_account_limit': 2,
    'free_budget_limit': 3,

    // UI Config
    'show_ads': false,
    'onboarding_enabled': true,
    'review_prompt_enabled': true,

    // Backend
    'api_timeout_seconds': 30,
  };

  // ============================================================
  // Feature Flags
  // ============================================================

  static bool get featureVoiceInput => instance.getBool('feature_voice_input');
  static bool get featureReceiptScan => instance.getBool('feature_receipt_scan');
  static bool get featureBankImport => instance.getBool('feature_bank_import');
  static bool get featureFamilySharing => instance.getBool('feature_family_sharing');
  static bool get featureInsights => instance.getBool('feature_insights');
  static bool get featureInvestments => instance.getBool('feature_investments');
  static bool get featureLoans => instance.getBool('feature_loans');

  // ============================================================
  // App Config
  // ============================================================

  static String get minAppVersion => instance.getString('min_app_version');
  static bool get forceUpdateEnabled => instance.getBool('force_update_enabled');
  static bool get maintenanceMode => instance.getBool('maintenance_mode');
  static String get maintenanceMessage => instance.getString('maintenance_message');

  // ============================================================
  // Limits
  // ============================================================

  static int get freeTransactionLimit => instance.getInt('free_transaction_limit');
  static int get freeAccountLimit => instance.getInt('free_account_limit');
  static int get freeBudgetLimit => instance.getInt('free_budget_limit');

  // ============================================================
  // UI Config
  // ============================================================

  static bool get showAds => instance.getBool('show_ads');
  static bool get onboardingEnabled => instance.getBool('onboarding_enabled');
  static bool get reviewPromptEnabled => instance.getBool('review_prompt_enabled');

  // ============================================================
  // Backend Config
  // ============================================================

  static int get apiTimeoutSeconds => instance.getInt('api_timeout_seconds');

  /// Refresh config from server
  static Future<void> refresh() async {
    try {
      final activated = await instance.fetchAndActivate();
      AppLogger.d('RemoteConfigService: Config refreshed, activated: $activated');
    } catch (e) {
      AppLogger.e('RemoteConfigService: Failed to refresh', e);
    }
  }

  /// Get a custom string value
  static String getString(String key) => instance.getString(key);

  /// Get a custom bool value
  static bool getBool(String key) => instance.getBool(key);

  /// Get a custom int value
  static int getInt(String key) => instance.getInt(key);

  /// Get a custom double value
  static double getDouble(String key) => instance.getDouble(key);
}
