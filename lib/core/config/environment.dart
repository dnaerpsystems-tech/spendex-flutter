import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration for Spendex
enum Environment { development, staging, production }

/// Environment configuration class
class EnvironmentConfig {
  EnvironmentConfig._();

  static Environment current = Environment.production;

  /// Get the API base URL based on current environment
  static String get apiBaseUrl {
    switch (current) {
      case Environment.development:
        return 'https://dev-api.spendex.in/api/v1';
      case Environment.staging:
        return 'https://staging-api.spendex.in/api/v1';
      case Environment.production:
        return 'https://api.spendex.in/api/v1';
    }
  }

  /// Whether logging is enabled
  static bool get enableLogging => current != Environment.production;

  /// Whether Crashlytics is enabled
  static bool get enableCrashlytics => current == Environment.production;

  /// Whether analytics is enabled
  static bool get enableAnalytics => current == Environment.production;

  /// App name based on environment
  static String get appName {
    switch (current) {
      case Environment.development:
        return 'Spendex Dev';
      case Environment.staging:
        return 'Spendex Staging';
      case Environment.production:
        return 'Spendex';
    }
  }

  /// Razorpay API key based on environment
  static String get razorpayKey {
    return dotenv.maybeGet('RAZORPAY_KEY') ?? 'rzp_test_default_key';
  }

  /// Initialize environment from dotenv or string
  /// If no argument provided, reads from .env file
  static void initialize([String? env]) {
    final envString = env ?? dotenv.maybeGet('ENVIRONMENT') ?? 'production';
    switch (envString.toLowerCase()) {
      case 'development':
      case 'dev':
        current = Environment.development;
        break;
      case 'staging':
      case 'stg':
        current = Environment.staging;
        break;
      case 'production':
      case 'prod':
      default:
        current = Environment.production;
        break;
    }
  }
}
