import '../../features/subscription/data/models/subscription_models.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../constants/app_constants.dart';

/// Type alias for subscription plan identifiers
typedef SubscriptionPlan = String;

/// Extension to provide enum-like properties for SubscriptionPlan
extension SubscriptionPlanExtension on SubscriptionPlan {
  /// Get the display name for the plan
  String get name {
    switch (this) {
      case PaywallService.planFree:
        return 'Free';
      case PaywallService.planPro:
        return 'Pro';
      case PaywallService.planPremium:
        return 'Premium';
      default:
        return 'Free';
    }
  }

  /// Check if this is the free plan
  bool get isFree => this == PaywallService.planFree;

  /// Check if this is the pro plan
  bool get isPro => this == PaywallService.planPro;

  /// Check if this is the premium plan
  bool get isPremium => this == PaywallService.planPremium;
}

/// Feature types that can be gated behind a subscription.
enum GatedFeature {
  /// Unlimited accounts (Free: 2, Pro: 10, Premium: Unlimited)
  unlimitedAccounts,

  /// Unlimited budgets (Free: 3, Pro: 10, Premium: Unlimited)
  unlimitedBudgets,

  /// Unlimited goals (Free: 2, Pro: 5, Premium: Unlimited)
  unlimitedGoals,

  /// Advanced analytics (Pro+)
  advancedAnalytics,

  /// AI-powered insights (Pro+)
  aiInsights,

  /// Receipt scanning (Pro+)
  receiptScanning,

  /// Voice input (Pro+)
  voiceInput,

  /// Bank import via Account Aggregator (Pro+)
  accountAggregator,

  /// Email parsing (Pro+)
  emailParsing,

  /// Family sharing (Premium only)
  familySharing,

  /// Investment tracking (Pro+)
  investmentTracking,

  /// Loan tracking (Pro+)
  loanTracking,

  /// Export to PDF/CSV (Pro+)
  exportReports,

  /// Priority support (Premium only)
  prioritySupport,

  /// Tax reports (Premium only)
  taxReports,
}

/// Result of checking a feature gate.
class FeatureGateResult {
  const FeatureGateResult({
    required this.isAllowed,
    this.currentCount,
    this.limit,
    this.requiredPlan,
    this.message,
  });

  /// Whether the feature is allowed.
  final bool isAllowed;

  /// The current count if this is a count-based feature.
  final int? currentCount;

  /// The limit for this feature.
  final int? limit;

  /// The required plan to access this feature (plan ID like 'plan_pro').
  final String? requiredPlan;

  /// Message to show if blocked.
  final String? message;

  /// Returns true if the user has reached their limit.
  bool get isAtLimit => limit != null && currentCount != null && currentCount! >= limit!;

  /// Returns the remaining count for count-based features.
  int? get remaining => limit != null && currentCount != null ? limit! - currentCount! : null;
}

/// Service for checking subscription-based feature gates.
///
/// This service determines which features a user can access based on
/// their current subscription plan and usage.
class PaywallService {
  /// Creates a new [PaywallService].
  PaywallService(this._repository);

  final SubscriptionRepository _repository;

  // Cache for current subscription and usage
  SubscriptionModel? _cachedSubscription;
  UsageModel? _cachedUsage;
  DateTime? _cacheTime;

  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Plan ID constants
  static const String planFree = 'plan_free';
  static const String planPro = 'plan_pro';
  static const String planPremium = 'plan_premium';

  /// Gets the limits for each plan.
  static const Map<String, Map<String, int>> planLimits = {
    planFree: {
      'accounts': 2,
      'budgets': 3,
      'goals': 2,
      'transactions_per_month': 100,
    },
    planPro: {
      'accounts': 10,
      'budgets': 10,
      'goals': 5,
      'transactions_per_month': 1000,
    },
    planPremium: {
      'accounts': -1, // Unlimited
      'budgets': -1,
      'goals': -1,
      'transactions_per_month': -1,
    },
  };

  /// Features available for each plan.
  static const Map<String, Set<GatedFeature>> planFeatures = {
    planFree: {},
    planPro: {
      GatedFeature.advancedAnalytics,
      GatedFeature.aiInsights,
      GatedFeature.receiptScanning,
      GatedFeature.voiceInput,
      GatedFeature.accountAggregator,
      GatedFeature.emailParsing,
      GatedFeature.investmentTracking,
      GatedFeature.loanTracking,
      GatedFeature.exportReports,
    },
    planPremium: {
      GatedFeature.advancedAnalytics,
      GatedFeature.aiInsights,
      GatedFeature.receiptScanning,
      GatedFeature.voiceInput,
      GatedFeature.accountAggregator,
      GatedFeature.emailParsing,
      GatedFeature.investmentTracking,
      GatedFeature.loanTracking,
      GatedFeature.exportReports,
      GatedFeature.familySharing,
      GatedFeature.prioritySupport,
      GatedFeature.taxReports,
    },
  };

  /// Refreshes the subscription and usage cache.
  Future<void> refreshCache() async {
    final subscriptionResult = await _repository.getCurrentSubscription();
    subscriptionResult.fold(
      (failure) => null,
      (subscription) => _cachedSubscription = subscription,
    );

    final usageResult = await _repository.getUsage();
    usageResult.fold(
      (failure) => null,
      (usage) => _cachedUsage = usage,
    );

    _cacheTime = DateTime.now();
  }

  /// Gets the cached subscription, refreshing if expired.
  Future<SubscriptionModel?> _getSubscription() async {
    if (_shouldRefreshCache()) {
      await refreshCache();
    }
    return _cachedSubscription;
  }

  /// Gets the cached usage, refreshing if expired.
  Future<UsageModel?> _getUsage() async {
    if (_shouldRefreshCache()) {
      await refreshCache();
    }
    return _cachedUsage;
  }

  bool _shouldRefreshCache() {
    if (_cacheTime == null) {
      return true;
    }
    return DateTime.now().difference(_cacheTime!) > _cacheExpiry;
  }

  /// Gets the current subscription plan ID.
  Future<String> getCurrentPlan() async {
    final subscription = await _getSubscription();
    return subscription?.planId ?? planFree;
  }

  /// Checks if a feature is available for the current subscription.
  Future<FeatureGateResult> checkFeature(GatedFeature feature) async {
    final plan = await getCurrentPlan();
    final usage = await _getUsage();

    // Check if feature is included in plan
    final allowedFeatures = planFeatures[plan] ?? {};
    final isFeatureAllowed = allowedFeatures.contains(feature);

    // Handle count-based features
    switch (feature) {
      case GatedFeature.unlimitedAccounts:
        return _checkCountFeature(
          plan: plan,
          key: 'accounts',
          currentCount: usage?.accountsUsed ?? 0,
        );
      case GatedFeature.unlimitedBudgets:
        return _checkCountFeature(
          plan: plan,
          key: 'budgets',
          currentCount: usage?.budgetsUsed ?? 0,
        );
      case GatedFeature.unlimitedGoals:
        return _checkCountFeature(
          plan: plan,
          key: 'goals',
          currentCount: usage?.goalsUsed ?? 0,
        );
      default:
        return FeatureGateResult(
          isAllowed: isFeatureAllowed,
          requiredPlan: _getRequiredPlan(feature),
          message: isFeatureAllowed
              ? null
              : "Upgrade to ${_getRequiredPlan(feature) ?? "Pro"} to access this feature",
        );
    }
  }

  FeatureGateResult _checkCountFeature({
    required String plan,
    required String key,
    required int currentCount,
  }) {
    final limits = planLimits[plan] ?? {};
    final limit = limits[key] ?? 0;

    // -1 means unlimited
    if (limit == -1) {
      return FeatureGateResult(
        isAllowed: true,
        currentCount: currentCount,
      );
    }

    final isAtLimit = currentCount >= limit;
    return FeatureGateResult(
      isAllowed: !isAtLimit,
      currentCount: currentCount,
      limit: limit,
      requiredPlan: isAtLimit ? _getNextPlan(plan) : null,
      message:
          isAtLimit ? 'You have reached your limit of $limit $key. Upgrade to add more.' : null,
    );
  }

  /// Checks if the user can add more of a count-based resource.
  Future<FeatureGateResult> canAddMore(GatedFeature feature) async {
    return checkFeature(feature);
  }

  /// Gets the required plan for a feature.
  String? _getRequiredPlan(GatedFeature feature) {
    if (planFeatures[planPro]?.contains(feature) ?? false) {
      return planPro;
    }
    if (planFeatures[planPremium]?.contains(feature) ?? false) {
      return planPremium;
    }
    return null;
  }

  /// Gets the next higher plan.
  String _getNextPlan(String current) {
    switch (current) {
      case planFree:
        return planPro;
      case planPro:
        return planPremium;
      case planPremium:
        return planPremium;
      default:
        return planPro;
    }
  }

  /// Checks if the user is on a trial.
  Future<bool> isOnTrial() async {
    final subscription = await _getSubscription();
    return subscription?.status == SubscriptionStatus.trialing;
  }

  /// Gets the trial days remaining.
  Future<int> getTrialDaysRemaining() async {
    final subscription = await _getSubscription();
    if (subscription?.status != SubscriptionStatus.trialing) {
      return 0;
    }
    if (subscription?.trialEnd == null) {
      return 0;
    }

    final remaining = subscription!.trialEnd!.difference(DateTime.now());
    return remaining.inDays;
  }

  /// Gets the current usage.
  Future<UsageModel?> getUsage() => _getUsage();

  /// Gets the current subscription.
  Future<SubscriptionModel?> getSubscription() => _getSubscription();

  /// Clears the cache.
  void clearCache() {
    _cachedSubscription = null;
    _cachedUsage = null;
    _cacheTime = null;
  }
}
