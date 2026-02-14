import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/subscription_models.dart';
import '../../domain/repositories/subscription_repository.dart';

// ============================================================================
// SUBSCRIPTION STATE
// ============================================================================

/// Subscription State
///
/// Manages the complete state for subscription management feature including
/// plans, current subscription, usage tracking, invoices, and payment methods.
class SubscriptionState extends Equatable {
  const SubscriptionState({
    this.plans = const [],
    this.currentSubscription,
    this.usage,
    this.invoices = const [],
    this.paymentMethods = const [],
    this.checkoutSession,
    this.upiSession,
    this.isLoadingPlans = false,
    this.isLoadingSubscription = false,
    this.isLoadingUsage = false,
    this.isLoadingInvoices = false,
    this.isLoadingPaymentMethods = false,
    this.isCheckingOut = false,
    this.isVerifyingPayment = false,
    this.isUpgrading = false,
    this.isDowngrading = false,
    this.isCancelling = false,
    this.isResuming = false,
    this.selectedPlan,
    this.selectedBillingCycle = BillingCycle.monthly,
    this.invoicesPage = 1,
    this.hasMoreInvoices = false,
    this.error,
    this.successMessage,
  });

  /// Initial state constructor
  const SubscriptionState.initial()
      : plans = const [],
        currentSubscription = null,
        usage = null,
        invoices = const [],
        paymentMethods = const [],
        checkoutSession = null,
        upiSession = null,
        isLoadingPlans = false,
        isLoadingSubscription = false,
        isLoadingUsage = false,
        isLoadingInvoices = false,
        isLoadingPaymentMethods = false,
        isCheckingOut = false,
        isVerifyingPayment = false,
        isUpgrading = false,
        isDowngrading = false,
        isCancelling = false,
        isResuming = false,
        selectedPlan = null,
        selectedBillingCycle = BillingCycle.monthly,
        invoicesPage = 1,
        hasMoreInvoices = false,
        error = null,
        successMessage = null;

  // ==================== Core Data ====================

  /// Available subscription plans
  final List<PlanModel> plans;

  /// Current user subscription (null if on free plan or no subscription)
  final SubscriptionModel? currentSubscription;

  /// Current usage statistics against plan limits
  final UsageModel? usage;

  /// List of invoices (paginated)
  final List<InvoiceModel> invoices;

  /// Saved payment methods
  final List<PaymentMethodModel> paymentMethods;

  /// Active checkout session for payment
  final CheckoutResponse? checkoutSession;

  /// Active UPI payment session
  final UpiCreateResponse? upiSession;

  // ==================== Loading States ====================

  /// Loading state for fetching plans
  final bool isLoadingPlans;

  /// Loading state for fetching current subscription
  final bool isLoadingSubscription;

  /// Loading state for fetching usage data
  final bool isLoadingUsage;

  /// Loading state for fetching invoices
  final bool isLoadingInvoices;

  /// Loading state for fetching payment methods
  final bool isLoadingPaymentMethods;

  /// Loading state for checkout session creation
  final bool isCheckingOut;

  /// Loading state for payment verification
  final bool isVerifyingPayment;

  /// Loading state for upgrade operation
  final bool isUpgrading;

  /// Loading state for downgrade operation
  final bool isDowngrading;

  /// Loading state for cancellation operation
  final bool isCancelling;

  /// Loading state for resume operation
  final bool isResuming;

  // ==================== Selection State ====================

  /// Currently selected plan for checkout/upgrade
  final PlanModel? selectedPlan;

  /// Selected billing cycle for checkout/upgrade
  final BillingCycle selectedBillingCycle;

  // ==================== Pagination ====================

  /// Current invoices page number
  final int invoicesPage;

  /// Whether there are more invoices to load
  final bool hasMoreInvoices;

  // ==================== Messages ====================

  /// Error message (null if no error)
  final String? error;

  /// Success message for user feedback
  final String? successMessage;

  // ==================== Helper Getters ====================

  /// Check if user has an active subscription
  bool get hasActiveSubscription {
    if (currentSubscription == null) return false;
    return currentSubscription!.isActive || currentSubscription!.isTrialing;
  }

  /// Check if user is on the free plan
  bool get isOnFreePlan {
    if (currentSubscription == null) return true;
    return currentSubscription!.plan?.isFree ?? true;
  }

  /// Check if user is on a trial period
  bool get isOnTrial {
    if (currentSubscription == null) return false;
    return currentSubscription!.isTrialing;
  }

  /// Check if user can upgrade their subscription
  bool get canUpgrade {
    if (currentSubscription == null) return true;
    if (hasActiveSubscription == false) return true;
    if (selectedPlan == null) return false;

    final currentPlan = currentSubscription!.plan;
    if (currentPlan == null) return true;

    // Can upgrade if selected plan price is higher
    return selectedPlan!.monthlyEquivalentPrice > currentPlan.monthlyEquivalentPrice;
  }

  /// Check if user can downgrade their subscription
  bool get canDowngrade {
    if (currentSubscription == null) return false;
    if (hasActiveSubscription == false) return false;
    if (selectedPlan == null) return false;

    final currentPlan = currentSubscription!.plan;
    if (currentPlan == null) return false;

    // Can downgrade if selected plan price is lower but not free
    return selectedPlan!.monthlyEquivalentPrice < currentPlan.monthlyEquivalentPrice &&
           selectedPlan!.isFree == false;
  }

  /// Check if user can cancel their subscription
  bool get canCancel {
    if (currentSubscription == null) return false;
    if (hasActiveSubscription == false) return false;
    if (currentSubscription!.cancelAtPeriodEnd) return false;
    return true;
  }

  /// Check if user can resume a cancelled subscription
  bool get canResume {
    if (currentSubscription == null) return false;
    return currentSubscription!.cancelAtPeriodEnd &&
           currentSubscription!.isValid;
  }

  /// Get current plan name
  String get currentPlanName {
    if (currentSubscription?.plan != null) {
      return currentSubscription!.plan!.name;
    }
    return 'Free';
  }

  /// Get subscription status text for display
  String get subscriptionStatusText {
    if (currentSubscription == null) return 'No subscription';
    return currentSubscription!.statusMessage;
  }

  /// Check if any loading operation is in progress
  bool get isLoading =>
      isLoadingPlans ||
      isLoadingSubscription ||
      isLoadingUsage ||
      isLoadingInvoices ||
      isLoadingPaymentMethods;

  /// Check if any operation is in progress
  bool get isOperationInProgress =>
      isCheckingOut ||
      isVerifyingPayment ||
      isUpgrading ||
      isDowngrading ||
      isCancelling ||
      isResuming;

  /// Get the default payment method
  PaymentMethodModel? get defaultPaymentMethod {
    try {
      return paymentMethods.firstWhere((m) => m.isDefault);
    } catch (_) {
      return paymentMethods.isNotEmpty ? paymentMethods.first : null;
    }
  }

  /// Calculate price difference for upgrade
  int get upgradePriceDifference {
    if (selectedPlan == null || currentSubscription?.plan == null) return 0;
    return selectedPlan!.price - currentSubscription!.plan!.price;
  }

  /// Calculate prorated amount for upgrade (remaining days)
  double get proratedUpgradeAmount {
    if (currentSubscription == null || selectedPlan == null) return 0;
    final daysRemaining = currentSubscription!.daysRemaining;
    final dailyRate = upgradePriceDifference / 30;
    return (dailyRate * daysRemaining) / 100;
  }

  /// Create a copy with modified fields
  SubscriptionState copyWith({
    List<PlanModel>? plans,
    SubscriptionModel? currentSubscription,
    UsageModel? usage,
    List<InvoiceModel>? invoices,
    List<PaymentMethodModel>? paymentMethods,
    CheckoutResponse? checkoutSession,
    UpiCreateResponse? upiSession,
    bool? isLoadingPlans,
    bool? isLoadingSubscription,
    bool? isLoadingUsage,
    bool? isLoadingInvoices,
    bool? isLoadingPaymentMethods,
    bool? isCheckingOut,
    bool? isVerifyingPayment,
    bool? isUpgrading,
    bool? isDowngrading,
    bool? isCancelling,
    bool? isResuming,
    PlanModel? selectedPlan,
    BillingCycle? selectedBillingCycle,
    int? invoicesPage,
    bool? hasMoreInvoices,
    String? error,
    String? successMessage,
    bool clearCurrentSubscription = false,
    bool clearCheckoutSession = false,
    bool clearUpiSession = false,
    bool clearSelectedPlan = false,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return SubscriptionState(
      plans: plans ?? this.plans,
      currentSubscription: clearCurrentSubscription
          ? null
          : (currentSubscription ?? this.currentSubscription),
      usage: usage ?? this.usage,
      invoices: invoices ?? this.invoices,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      checkoutSession: clearCheckoutSession
          ? null
          : (checkoutSession ?? this.checkoutSession),
      upiSession: clearUpiSession ? null : (upiSession ?? this.upiSession),
      isLoadingPlans: isLoadingPlans ?? this.isLoadingPlans,
      isLoadingSubscription:
          isLoadingSubscription ?? this.isLoadingSubscription,
      isLoadingUsage: isLoadingUsage ?? this.isLoadingUsage,
      isLoadingInvoices: isLoadingInvoices ?? this.isLoadingInvoices,
      isLoadingPaymentMethods:
          isLoadingPaymentMethods ?? this.isLoadingPaymentMethods,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      isVerifyingPayment: isVerifyingPayment ?? this.isVerifyingPayment,
      isUpgrading: isUpgrading ?? this.isUpgrading,
      isDowngrading: isDowngrading ?? this.isDowngrading,
      isCancelling: isCancelling ?? this.isCancelling,
      isResuming: isResuming ?? this.isResuming,
      selectedPlan:
          clearSelectedPlan ? null : (selectedPlan ?? this.selectedPlan),
      selectedBillingCycle: selectedBillingCycle ?? this.selectedBillingCycle,
      invoicesPage: invoicesPage ?? this.invoicesPage,
      hasMoreInvoices: hasMoreInvoices ?? this.hasMoreInvoices,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        plans,
        currentSubscription,
        usage,
        invoices,
        paymentMethods,
        checkoutSession,
        upiSession,
        isLoadingPlans,
        isLoadingSubscription,
        isLoadingUsage,
        isLoadingInvoices,
        isLoadingPaymentMethods,
        isCheckingOut,
        isVerifyingPayment,
        isUpgrading,
        isDowngrading,
        isCancelling,
        isResuming,
        selectedPlan,
        selectedBillingCycle,
        invoicesPage,
        hasMoreInvoices,
        error,
        successMessage,
      ];
}

// ============================================================================
// SUBSCRIPTION NOTIFIER
// ============================================================================

/// Subscription State Notifier
///
/// Handles all subscription-related operations and state management including
/// plan selection, checkout, payment verification, upgrades, downgrades,
/// cancellations, and invoice management.
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this._repository)
      : super(const SubscriptionState.initial());

  final SubscriptionRepository _repository;

  // ==================== Data Loading Methods ====================

  /// Load available subscription plans
  ///
  /// Fetches all available subscription plans from the API.
  /// Sets [isLoadingPlans] to true during the operation.
  Future<void> loadPlans() async {
    if (state.isLoadingPlans) return;

    state = state.copyWith(isLoadingPlans: true, clearError: true);

    final result = await _repository.getPlans();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPlans: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isLoadingPlans: false,
          plans: response.plans,
        );
      },
    );
  }

  /// Load current subscription
  ///
  /// Fetches the current user's subscription details.
  /// Returns null subscription if user has no active subscription.
  Future<void> loadSubscription() async {
    if (state.isLoadingSubscription) return;

    state = state.copyWith(isLoadingSubscription: true, clearError: true);

    final result = await _repository.getCurrentSubscription();

    result.fold(
      (failure) {
        // No subscription is a valid state, not an error
        if (failure.code == 'NOT_FOUND' ||
            failure.code == 'SUBSCRIPTION_NOT_FOUND') {
          state = state.copyWith(
            isLoadingSubscription: false,
            clearCurrentSubscription: true,
          );
        } else {
          state = state.copyWith(
            isLoadingSubscription: false,
            error: failure.message,
          );
        }
      },
      (subscription) {
        state = state.copyWith(
          isLoadingSubscription: false,
          currentSubscription: subscription,
        );
      },
    );
  }

  /// Load current usage statistics
  ///
  /// Fetches the user's current feature usage against their plan limits.
  Future<void> loadUsage() async {
    if (state.isLoadingUsage) return;

    state = state.copyWith(isLoadingUsage: true, clearError: true);

    final result = await _repository.getUsage();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingUsage: false,
          error: failure.message,
        );
      },
      (usage) {
        state = state.copyWith(
          isLoadingUsage: false,
          usage: usage,
        );
      },
    );
  }

  /// Load invoices with pagination support
  ///
  /// Fetches the user's invoice history with pagination.
  /// Set [refresh] to true to reload from the first page.
  Future<void> loadInvoices({bool refresh = false}) async {
    if (state.isLoadingInvoices) return;

    final page = refresh ? 1 : state.invoicesPage;

    state = state.copyWith(
      isLoadingInvoices: true,
      clearError: true,
      invoicesPage: page,
    );

    final result = await _repository.getInvoices(page: page);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingInvoices: false,
          error: failure.message,
        );
      },
      (response) {
        final newInvoices = refresh
            ? response.invoices
            : [...state.invoices, ...response.invoices];

        state = state.copyWith(
          isLoadingInvoices: false,
          invoices: newInvoices,
          invoicesPage: response.page,
          hasMoreInvoices: response.hasMorePages,
        );
      },
    );
  }

  /// Load saved payment methods
  ///
  /// Fetches all saved payment methods for the user.
  Future<void> loadPaymentMethods() async {
    if (state.isLoadingPaymentMethods) return;

    state = state.copyWith(isLoadingPaymentMethods: true, clearError: true);

    final result = await _repository.getPaymentMethods();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingPaymentMethods: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isLoadingPaymentMethods: false,
          paymentMethods: response.paymentMethods,
        );
      },
    );
  }

  // ==================== Plan Selection Methods ====================

  /// Select a plan for checkout or upgrade
  ///
  /// Sets the [selectedPlan] in state for subsequent checkout/upgrade operations.
  void selectPlan(PlanModel plan) {
    state = state.copyWith(
      selectedPlan: plan,
      clearError: true,
      clearSuccessMessage: true,
    );
  }

  /// Change the selected billing cycle
  ///
  /// Updates the [selectedBillingCycle] for checkout/upgrade operations.
  void selectBillingCycle(BillingCycle cycle) {
    state = state.copyWith(
      selectedBillingCycle: cycle,
      clearError: true,
    );
  }

  // ==================== Checkout & Payment Methods ====================

  /// Start checkout process for a new subscription
  ///
  /// Creates a checkout session for the selected plan and payment method.
  /// Returns [CheckoutResponse] on success containing payment details.
  ///
  /// Validates:
  /// - A plan is selected
  /// - Selected plan is not free
  Future<CheckoutResponse?> startCheckout(PaymentMethodType paymentMethod) async {
    if (state.isCheckingOut) return null;

    // Validate plan selection
    if (state.selectedPlan == null) {
      state = state.copyWith(error: 'Please select a plan first');
      return null;
    }

    if (state.selectedPlan!.isFree) {
      state = state.copyWith(error: 'Cannot checkout for a free plan');
      return null;
    }

    state = state.copyWith(
      isCheckingOut: true,
      clearError: true,
      clearCheckoutSession: true,
    );

    final request = CheckoutRequest(
      planId: state.selectedPlan!.id,
      billingCycle: state.selectedBillingCycle.value,
      paymentMethodType: paymentMethod.value,
    );

    final result = await _repository.createCheckout(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingOut: false,
          error: failure.message,
        );
        return null;
      },
      (response) {
        state = state.copyWith(
          isCheckingOut: false,
          checkoutSession: response,
        );
        return response;
      },
    );
  }

  /// Verify a completed payment
  ///
  /// Verifies the payment with Razorpay signature validation.
  /// Returns true on successful verification, false otherwise.
  ///
  /// On success:
  /// - Updates current subscription
  /// - Clears checkout session and selected plan
  /// - Sets success message
  Future<bool> verifyPayment(PaymentVerificationRequest request) async {
    if (state.isVerifyingPayment) return false;

    state = state.copyWith(isVerifyingPayment: true, clearError: true);

    final result = await _repository.verifyPayment(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isVerifyingPayment: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          isVerifyingPayment: false,
          currentSubscription: subscription,
          clearCheckoutSession: true,
          clearSelectedPlan: true,
          successMessage: 'Payment successful! Welcome to ${subscription.plan?.name ?? "Premium"}',
        );
        return true;
      },
    );
  }

  /// Create a UPI payment intent
  ///
  /// Creates a UPI payment request for the current checkout session.
  /// Returns [UpiCreateResponse] with QR code and intent URL.
  ///
  /// Validates:
  /// - VPA is not empty
  /// - VPA contains @ symbol
  /// - Checkout session exists
  Future<UpiCreateResponse?> createUpiPayment(String vpa) async {
    if (state.isCheckingOut) return null;

    if (vpa.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a valid UPI ID');
      return null;
    }

    // Basic UPI ID validation
    if (vpa.contains('@') == false) {
      state = state.copyWith(error: 'Invalid UPI ID format');
      return null;
    }

    if (state.checkoutSession == null) {
      state = state.copyWith(error: 'Please start checkout first');
      return null;
    }

    state = state.copyWith(isCheckingOut: true, clearError: true);

    final request = UpiCreateRequest(
      orderId: state.checkoutSession!.orderId,
      vpa: vpa.trim(),
    );

    final result = await _repository.createUpiPayment(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCheckingOut: false,
          error: failure.message,
        );
        return null;
      },
      (response) {
        state = state.copyWith(
          isCheckingOut: false,
          upiSession: response,
        );
        return response;
      },
    );
  }

  /// Verify a UPI payment
  ///
  /// Verifies UPI payment using the transaction ID.
  /// Returns true on successful verification, false otherwise.
  Future<bool> verifyUpiPayment(String transactionId) async {
    if (state.isVerifyingPayment) return false;

    if (transactionId.trim().isEmpty) {
      state = state.copyWith(error: 'Invalid transaction ID');
      return false;
    }

    state = state.copyWith(isVerifyingPayment: true, clearError: true);

    final result = await _repository.verifyUpiPayment(transactionId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isVerifyingPayment: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          isVerifyingPayment: false,
          currentSubscription: subscription,
          clearCheckoutSession: true,
          clearUpiSession: true,
          clearSelectedPlan: true,
          successMessage: 'Payment successful! Welcome to ${subscription.plan?.name ?? "Premium"}',
        );
        return true;
      },
    );
  }

  // ==================== Subscription Management Methods ====================

  /// Upgrade to the selected plan
  ///
  /// Initiates an upgrade to the currently selected plan.
  /// Returns [CheckoutResponse] for payment processing.
  ///
  /// Validates:
  /// - A plan is selected
  /// - User can upgrade (selected plan is higher tier)
  /// - Not already on the selected plan
  Future<CheckoutResponse?> upgradeSubscription() async {
    if (state.isUpgrading) return null;

    // Validate plan selection
    if (state.selectedPlan == null) {
      state = state.copyWith(error: 'Please select a plan to upgrade');
      return null;
    }

    // Validate upgrade eligibility
    if (state.canUpgrade == false) {
      state = state.copyWith(
        error: 'Cannot upgrade to a lower or same tier plan',
      );
      return null;
    }

    // Check if already on the same plan
    if (state.currentSubscription?.planId == state.selectedPlan!.id) {
      state = state.copyWith(error: 'You are already on this plan');
      return null;
    }

    state = state.copyWith(isUpgrading: true, clearError: true);

    final result = await _repository.upgradeSubscription(
      planId: state.selectedPlan!.id,
      billingCycle: state.selectedBillingCycle,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpgrading: false,
          error: failure.message,
        );
        return null;
      },
      (response) {
        state = state.copyWith(
          isUpgrading: false,
          checkoutSession: response,
        );
        return response;
      },
    );
  }

  /// Downgrade to a specific plan
  ///
  /// Schedules a downgrade to the specified plan at the end of current period.
  /// Returns true on success, false otherwise.
  ///
  /// Validates:
  /// - Plan ID is valid
  /// - Target plan exists
  /// - User has active subscription
  /// - Target plan is lower tier
  Future<bool> downgradeSubscription(String planId) async {
    if (state.isDowngrading) return false;

    if (planId.isEmpty) {
      state = state.copyWith(error: 'Invalid plan ID');
      return false;
    }

    // Find the target plan
    final targetPlan = state.plans.where((p) => p.id == planId).firstOrNull;
    if (targetPlan == null) {
      state = state.copyWith(error: 'Plan not found');
      return false;
    }

    // Validate downgrade eligibility
    if (state.currentSubscription == null) {
      state = state.copyWith(error: 'No active subscription to downgrade');
      return false;
    }

    final currentPlan = state.currentSubscription!.plan;
    if (currentPlan != null &&
        targetPlan.monthlyEquivalentPrice >= currentPlan.monthlyEquivalentPrice) {
      state = state.copyWith(
        error: 'Cannot downgrade to a higher or same tier plan',
      );
      return false;
    }

    state = state.copyWith(isDowngrading: true, clearError: true);

    final result = await _repository.downgradeSubscription(planId: planId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDowngrading: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          isDowngrading: false,
          currentSubscription: subscription,
          successMessage:
              'Your subscription will be downgraded at the end of the current billing period',
        );
        return true;
      },
    );
  }

  /// Cancel the current subscription
  ///
  /// Cancels the user's subscription either immediately or at period end.
  ///
  /// Parameters:
  /// - [immediate]: If true, cancels immediately; otherwise at period end
  /// - [reason]: Optional cancellation reason for feedback
  /// - [isFamilyOwner]: Pass true if user is a family owner (prevents cancellation)
  ///
  /// Returns true on success, false otherwise.
  ///
  /// Business Logic:
  /// - Family owners cannot cancel (must transfer ownership first)
  /// - Validates active subscription exists
  /// - Checks if subscription is not already scheduled for cancellation
  Future<bool> cancelSubscription({
    bool immediate = false,
    String? reason,
    bool isFamilyOwner = false,
  }) async {
    if (state.isCancelling) return false;

    // Validate cancellation eligibility
    if (state.canCancel == false) {
      state = state.copyWith(
        error: 'No active subscription to cancel',
      );
      return false;
    }

    // Prevent family owners from cancelling (they must transfer ownership first)
    if (isFamilyOwner) {
      state = state.copyWith(
        error: 'Family owners cannot cancel subscription. Please transfer ownership first or remove all family members.',
      );
      return false;
    }

    state = state.copyWith(isCancelling: true, clearError: true);

    final request = CancelSubscriptionRequest(
      cancelAtPeriodEnd: immediate == false,
      reason: reason,
    );

    final result = await _repository.cancelSubscription(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCancelling: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        final message = immediate
            ? 'Your subscription has been cancelled'
            : 'Your subscription will be cancelled on ${_formatDate(subscription.currentPeriodEnd)}';

        state = state.copyWith(
          isCancelling: false,
          currentSubscription: subscription,
          successMessage: message,
        );
        return true;
      },
    );
  }

  /// Resume a cancelled subscription
  ///
  /// Resumes a subscription that was scheduled for cancellation at period end.
  /// Returns true on success, false otherwise.
  ///
  /// Validates:
  /// - Subscription exists
  /// - Subscription is scheduled for cancellation
  /// - Subscription is still valid (not yet expired)
  Future<bool> resumeSubscription() async {
    if (state.isResuming) return false;

    // Validate resume eligibility
    if (state.canResume == false) {
      state = state.copyWith(
        error: 'Cannot resume subscription',
      );
      return false;
    }

    state = state.copyWith(isResuming: true, clearError: true);

    final result = await _repository.resumeSubscription();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isResuming: false,
          error: failure.message,
        );
        return false;
      },
      (subscription) {
        state = state.copyWith(
          isResuming: false,
          currentSubscription: subscription,
          successMessage: 'Your subscription has been resumed',
        );
        return true;
      },
    );
  }

  // ==================== Invoice Methods ====================

  /// Download an invoice
  ///
  /// Fetches the download URL for a specific invoice.
  /// Returns the download URL on success, null on failure.
  Future<String?> downloadInvoice(String invoiceId) async {
    if (invoiceId.isEmpty) {
      state = state.copyWith(error: 'Invalid invoice ID');
      return null;
    }

    final result = await _repository.downloadInvoice(invoiceId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (url) => url,
    );
  }

  /// Load next page of invoices
  ///
  /// Fetches the next page of invoices if available.
  /// Does nothing if already loading or no more pages.
  Future<void> loadMoreInvoices() async {
    if (state.hasMoreInvoices == false || state.isLoadingInvoices) return;

    state = state.copyWith(invoicesPage: state.invoicesPage + 1);
    await loadInvoices();
  }

  // ==================== Utility Methods ====================

  /// Refresh all subscription data
  ///
  /// Reloads plans, subscription, usage, payment methods, and invoices.
  /// Use this for pull-to-refresh functionality.
  Future<void> refresh() async {
    await Future.wait([
      loadPlans(),
      loadSubscription(),
      loadUsage(),
      loadPaymentMethods(),
    ]);
    await loadInvoices(refresh: true);
  }

  /// Clear error message
  ///
  /// Removes the current error from state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  ///
  /// Removes the current success message from state.
  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }

  /// Reset state to initial
  ///
  /// Clears all subscription data and resets to initial state.
  /// Use this when user logs out.
  void reset() {
    state = const SubscriptionState.initial();
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ============================================================================
// RIVERPOD PROVIDERS
// ============================================================================

/// Main subscription state provider
///
/// Provides access to the complete subscription state and notifier.
/// Use this for full state access and mutations.
///
/// Example:
/// ```dart
/// final notifier = ref.read(subscriptionStateProvider.notifier);
/// await notifier.loadPlans();
/// ```
final subscriptionStateProvider =
    StateNotifierProvider.autoDispose<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(getIt<SubscriptionRepository>());
});

/// Available plans provider
///
/// Provides a reactive list of available subscription plans.
final plansProvider = Provider<List<PlanModel>>((ref) {
  return ref.watch(subscriptionStateProvider).plans;
});

/// Current subscription provider
///
/// Provides the user's current subscription (null if none).
final currentSubscriptionProvider = Provider<SubscriptionModel?>((ref) {
  return ref.watch(subscriptionStateProvider).currentSubscription;
});

/// Usage statistics provider
///
/// Provides the user's current usage data against plan limits.
final usageProvider = Provider<UsageModel?>((ref) {
  return ref.watch(subscriptionStateProvider).usage;
});

/// Invoices provider
///
/// Provides the list of user's invoices.
final invoicesProvider = Provider<List<InvoiceModel>>((ref) {
  return ref.watch(subscriptionStateProvider).invoices;
});

/// Payment methods provider
///
/// Provides the list of saved payment methods.
final paymentMethodsProvider = Provider<List<PaymentMethodModel>>((ref) {
  return ref.watch(subscriptionStateProvider).paymentMethods;
});

/// Subscription active status provider
///
/// Returns true if user has an active (non-free) subscription.
final isSubscriptionActiveProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).hasActiveSubscription;
});

/// Can upgrade provider
///
/// Returns true if user can upgrade their subscription to selected plan.
final canUpgradeProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).canUpgrade;
});

/// Subscription status provider
///
/// Provides a human-readable subscription status text.
final subscriptionStatusProvider = Provider<String>((ref) {
  return ref.watch(subscriptionStateProvider).subscriptionStatusText;
});

/// Is on free plan provider
///
/// Returns true if user is on the free plan.
final isOnFreePlanProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).isOnFreePlan;
});

/// Is on trial provider
///
/// Returns true if user is currently on a trial period.
final isOnTrialProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).isOnTrial;
});

/// Current plan name provider
///
/// Provides the name of the current plan (defaults to 'Free').
final currentPlanNameProvider = Provider<String>((ref) {
  return ref.watch(subscriptionStateProvider).currentPlanName;
});

/// Subscription loading provider
///
/// Returns true if any subscription data is currently loading.
final subscriptionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).isLoading;
});

/// Subscription error provider
///
/// Provides the current error message (null if no error).
final subscriptionErrorProvider = Provider<String?>((ref) {
  return ref.watch(subscriptionStateProvider).error;
});

/// Subscription operation in progress provider
///
/// Returns true if any subscription operation is in progress
/// (checkout, upgrade, downgrade, cancel, etc.).
final subscriptionOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).isOperationInProgress;
});

/// Selected plan provider
///
/// Provides the currently selected plan for checkout/upgrade.
final selectedPlanProvider = Provider<PlanModel?>((ref) {
  return ref.watch(subscriptionStateProvider).selectedPlan;
});

/// Selected billing cycle provider
///
/// Provides the currently selected billing cycle.
final selectedBillingCycleProvider = Provider<BillingCycle>((ref) {
  return ref.watch(subscriptionStateProvider).selectedBillingCycle;
});

/// Default payment method provider
///
/// Provides the default payment method (or first available).
final defaultPaymentMethodProvider = Provider<PaymentMethodModel?>((ref) {
  return ref.watch(subscriptionStateProvider).defaultPaymentMethod;
});

/// Can cancel subscription provider
///
/// Returns true if user can cancel their subscription.
final canCancelSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).canCancel;
});

/// Can resume subscription provider
///
/// Returns true if user can resume their cancelled subscription.
final canResumeSubscriptionProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).canResume;
});
