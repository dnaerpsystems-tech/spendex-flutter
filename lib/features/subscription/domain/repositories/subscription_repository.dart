import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/subscription_models.dart';

/// Subscription Repository Interface
///
/// Defines the contract for subscription data operations.
/// This abstraction allows for easy testing and different implementations.
abstract class SubscriptionRepository {
  /// Get available subscription plans
  Future<Either<Failure, PlansResponse>> getPlans();

  /// Get the current user's subscription
  Future<Either<Failure, SubscriptionModel>> getCurrentSubscription();

  /// Get current usage statistics
  Future<Either<Failure, UsageModel>> getUsage();

  /// Create a checkout session for new subscription
  Future<Either<Failure, CheckoutResponse>> createCheckout(
    CheckoutRequest request,
  );

  /// Verify a completed payment
  Future<Either<Failure, SubscriptionModel>> verifyPayment(
    PaymentVerificationRequest request,
  );

  /// Upgrade the current subscription
  Future<Either<Failure, CheckoutResponse>> upgradeSubscription({
    required String planId,
    required BillingCycle billingCycle,
  });

  /// Downgrade the current subscription
  Future<Either<Failure, SubscriptionModel>> downgradeSubscription({
    required String planId,
  });

  /// Cancel the current subscription
  Future<Either<Failure, SubscriptionModel>> cancelSubscription(
    CancelSubscriptionRequest request,
  );

  /// Resume a cancelled subscription
  Future<Either<Failure, SubscriptionModel>> resumeSubscription();

  /// Get paginated invoice history
  Future<Either<Failure, InvoicesResponse>> getInvoices({
    int page = 1,
    int limit = 20,
  });

  /// Download an invoice PDF
  Future<Either<Failure, String>> downloadInvoice(String invoiceId);

  /// Create a UPI payment intent
  Future<Either<Failure, UpiCreateResponse>> createUpiPayment(
    UpiCreateRequest request,
  );

  /// Verify a UPI payment
  Future<Either<Failure, SubscriptionModel>> verifyUpiPayment(
    String transactionId,
  );

  /// Get saved payment methods
  Future<Either<Failure, PaymentMethodsResponse>> getPaymentMethods();
}
