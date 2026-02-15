import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';
import 'analytics_events.dart';

/// Firebase Analytics service for tracking user behavior
class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics get instance {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics!;
  }

  static FirebaseAnalyticsObserver get observer {
    _observer ??= FirebaseAnalyticsObserver(analytics: instance);
    return _observer!;
  }

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (kDebugMode) {
      AppLogger.d('Analytics: Screen view - $screenName');
      return;
    }

    await instance.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Log custom event
  static Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (kDebugMode) {
      AppLogger.d('Analytics: Event - $name, params: $parameters');
      return;
    }

    // Filter out null values to match Firebase Analytics requirements
    final filteredParameters = parameters
        ?.map(
          (key, value) => MapEntry(key, value ?? ''),
        )
        .cast<String, Object>();

    await instance.logEvent(
      name: name,
      parameters: filteredParameters,
    );
  }

  /// Set user ID for analytics
  static Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      AppLogger.d('Analytics: Set user ID - $userId');
      return;
    }

    await instance.setUserId(id: userId);
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (kDebugMode) {
      AppLogger.d('Analytics: Set user property - $name: $value');
      return;
    }

    await instance.setUserProperty(name: name, value: value);
  }

  // ============================================================
  // Pre-defined Event Methods
  // ============================================================

  /// Log login event
  static Future<void> logLogin({String? method}) async {
    await logEvent(
      name: AnalyticsEvents.eventLogin,
      parameters: {
        'method': method ?? 'email',
      },
    );
  }

  /// Log signup event
  static Future<void> logSignUp({String? method}) async {
    await logEvent(
      name: AnalyticsEvents.eventSignUp,
      parameters: {
        'method': method ?? 'email',
      },
    );
  }

  /// Log transaction created
  static Future<void> logTransactionCreated({
    required String type,
    required double amount,
    required String category,
    String? paymentMethod,
  }) async {
    await logEvent(
      name: AnalyticsEvents.eventTransactionCreated,
      parameters: {
        'type': type,
        'amount': amount,
        'category': category,
        'payment_method': paymentMethod,
      },
    );
  }

  /// Log budget created
  static Future<void> logBudgetCreated({
    required String category,
    required double amount,
    required String period,
  }) async {
    await logEvent(
      name: AnalyticsEvents.eventBudgetCreated,
      parameters: {
        'category': category,
        'amount': amount,
        'period': period,
      },
    );
  }

  /// Log goal created
  static Future<void> logGoalCreated({
    required String name,
    required double targetAmount,
  }) async {
    await logEvent(
      name: AnalyticsEvents.eventGoalCreated,
      parameters: {
        'goal_name': name,
        'target_amount': targetAmount,
      },
    );
  }

  /// Log subscription purchase
  static Future<void> logSubscriptionPurchase({
    required String planId,
    required String planName,
    required double amount,
    required String currency,
  }) async {
    await instance.logPurchase(
      currency: currency,
      value: amount,
      items: [
        AnalyticsEventItem(
          itemId: planId,
          itemName: planName,
          itemCategory: 'subscription',
        ),
      ],
    );
  }

  /// Log feature used
  static Future<void> logFeatureUsed({
    required String featureName,
    Map<String, Object?>? additionalParams,
  }) async {
    await logEvent(
      name: AnalyticsEvents.eventFeatureUsed,
      parameters: {
        'feature_name': featureName,
        ...?additionalParams,
      },
    );
  }

  /// Log error
  static Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screenName,
  }) async {
    await logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage.substring(0, errorMessage.length.clamp(0, 100)),
        'screen_name': screenName,
      },
    );
  }
}
