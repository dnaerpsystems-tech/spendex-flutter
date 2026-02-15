import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/paywall_service.dart';
import '../../data/models/subscription_models.dart';
import '../../domain/repositories/subscription_repository.dart';

/// Provider for the PaywallService
final paywallServiceProvider = Provider<PaywallService>((ref) {
  return PaywallService(getIt<SubscriptionRepository>());
});

/// State for paywall checks
class PaywallState {
  const PaywallState({
    this.isLoading = true,
    this.currentPlan = 'free',
    this.usage,
    this.subscription,
    this.isOnTrial = false,
    this.trialDaysRemaining = 0,
    this.error,
  });
  final bool isLoading;
  final SubscriptionPlan currentPlan;
  final UsageModel? usage;
  final SubscriptionModel? subscription;
  final bool isOnTrial;
  final int trialDaysRemaining;
  final String? error;

  PaywallState copyWith({
    bool? isLoading,
    SubscriptionPlan? currentPlan,
    UsageModel? usage,
    SubscriptionModel? subscription,
    bool? isOnTrial,
    int? trialDaysRemaining,
    String? error,
  }) {
    return PaywallState(
      isLoading: isLoading ?? this.isLoading,
      currentPlan: currentPlan ?? this.currentPlan,
      usage: usage ?? this.usage,
      subscription: subscription ?? this.subscription,
      isOnTrial: isOnTrial ?? this.isOnTrial,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      error: error,
    );
  }
}

/// Notifier for paywall state
class PaywallNotifier extends StateNotifier<PaywallState> {
  PaywallNotifier(this._service) : super(const PaywallState()) {
    _init();
  }

  final PaywallService _service;

  Future<void> _init() async {
    await refresh();
  }

  /// Refreshes the paywall state
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);

    try {
      await _service.refreshCache();

      final currentPlan = await _service.getCurrentPlan();
      final usage = await _service.getUsage();
      final subscription = await _service.getSubscription();
      final isOnTrial = await _service.isOnTrial();
      final trialDaysRemaining = await _service.getTrialDaysRemaining();

      state = state.copyWith(
        isLoading: false,
        currentPlan: currentPlan,
        usage: usage,
        subscription: subscription,
        isOnTrial: isOnTrial,
        trialDaysRemaining: trialDaysRemaining,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Checks if a feature is available
  Future<FeatureGateResult> checkFeature(GatedFeature feature) async {
    return _service.checkFeature(feature);
  }

  /// Checks if user can add more of a count-based resource
  Future<FeatureGateResult> canAddMore(GatedFeature feature) async {
    return _service.canAddMore(feature);
  }

  /// Clears the cache and refreshes
  Future<void> clearCacheAndRefresh() async {
    _service.clearCache();
    await refresh();
  }
}

/// Provider for paywall state
final paywallProvider = StateNotifierProvider<PaywallNotifier, PaywallState>((ref) {
  final service = ref.watch(paywallServiceProvider);
  return PaywallNotifier(service);
});

/// Provider to check a specific feature
final featureGateProvider =
    FutureProvider.family<FeatureGateResult, GatedFeature>((ref, feature) async {
  final service = ref.watch(paywallServiceProvider);
  return service.checkFeature(feature);
});

/// Provider to check if user can add accounts
final canAddAccountProvider = FutureProvider<FeatureGateResult>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  return service.canAddMore(GatedFeature.unlimitedAccounts);
});

/// Provider to check if user can add budgets
final canAddBudgetProvider = FutureProvider<FeatureGateResult>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  return service.canAddMore(GatedFeature.unlimitedBudgets);
});

/// Provider to check if user can add goals
final canAddGoalProvider = FutureProvider<FeatureGateResult>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  return service.canAddMore(GatedFeature.unlimitedGoals);
});

/// Provider to check if AI insights are available
final aiInsightsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  final result = await service.checkFeature(GatedFeature.aiInsights);
  return result.isAllowed;
});

/// Provider to check if advanced analytics are available
final advancedAnalyticsAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  final result = await service.checkFeature(GatedFeature.advancedAnalytics);
  return result.isAllowed;
});

/// Provider to check if family sharing is available
final familySharingAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(paywallServiceProvider);
  final result = await service.checkFeature(GatedFeature.familySharing);
  return result.isAllowed;
});
