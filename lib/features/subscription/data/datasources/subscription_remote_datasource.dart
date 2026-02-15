import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/subscription_models.dart';

/// Subscription Remote DataSource Interface
///
/// Defines the contract for subscription-related API operations.
/// Handles plan retrieval, subscription management, payments, and invoices.
abstract class SubscriptionRemoteDataSource {
  /// Get available subscription plans
  ///
  /// Returns a list of all available plans with their features and pricing.
  Future<Either<Failure, PlansResponse>> getPlans();

  /// Get the current user's subscription
  ///
  /// Returns the active subscription details including plan info and status.
  Future<Either<Failure, SubscriptionModel>> getCurrentSubscription();

  /// Get current usage statistics
  ///
  /// Returns the user's current usage against their plan limits.
  Future<Either<Failure, UsageModel>> getUsage();

  /// Create a checkout session for new subscription
  ///
  /// Initiates the payment flow for subscribing to a plan.
  Future<Either<Failure, CheckoutResponse>> createCheckout(
    CheckoutRequest request,
  );

  /// Verify a completed payment
  ///
  /// Verifies the Razorpay payment signature and activates the subscription.
  Future<Either<Failure, SubscriptionModel>> verifyPayment(
    PaymentVerificationRequest request,
  );

  /// Upgrade the current subscription
  ///
  /// Upgrades to a higher tier plan with immediate billing.
  Future<Either<Failure, CheckoutResponse>> upgradeSubscription({
    required String planId,
    required BillingCycle billingCycle,
  });

  /// Downgrade the current subscription
  ///
  /// Downgrades to a lower tier plan effective at the next billing cycle.
  Future<Either<Failure, SubscriptionModel>> downgradeSubscription({
    required String planId,
  });

  /// Cancel the current subscription
  ///
  /// Cancels the subscription either immediately or at period end.
  Future<Either<Failure, SubscriptionModel>> cancelSubscription(
    CancelSubscriptionRequest request,
  );

  /// Resume a cancelled subscription
  ///
  /// Reactivates a subscription that was set to cancel at period end.
  Future<Either<Failure, SubscriptionModel>> resumeSubscription();

  /// Get paginated invoice history
  ///
  /// Returns a list of invoices for the user's subscription.
  Future<Either<Failure, InvoicesResponse>> getInvoices({
    int page = 1,
    int limit = 20,
  });

  /// Download an invoice PDF
  ///
  /// Returns the download URL for a specific invoice.
  Future<Either<Failure, String>> downloadInvoice(String invoiceId);

  /// Create a UPI payment intent
  ///
  /// Initiates a UPI payment flow for subscription.
  Future<Either<Failure, UpiCreateResponse>> createUpiPayment(
    UpiCreateRequest request,
  );

  /// Verify a UPI payment
  ///
  /// Checks the status of a UPI payment and activates subscription if successful.
  Future<Either<Failure, SubscriptionModel>> verifyUpiPayment(
    String transactionId,
  );

  /// Get saved payment methods
  ///
  /// Returns a list of payment methods saved by the user.
  Future<Either<Failure, PaymentMethodsResponse>> getPaymentMethods();

  /// Set a payment method as default
  ///
  /// Marks the specified payment method as the default for future payments.
  Future<Either<Failure, void>> setDefaultPaymentMethod(String paymentMethodId);

  /// Check payment status
  ///
  /// Checks the current status of a payment transaction.
  Future<Either<Failure, String>> checkPaymentStatus(String transactionId);
}

/// Subscription Remote DataSource Implementation
///
/// Implements the [SubscriptionRemoteDataSource] interface using [ApiClient]
/// for making HTTP requests to the backend API.
class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  /// Creates a new [SubscriptionRemoteDataSourceImpl] with the given [ApiClient].
  SubscriptionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, PlansResponse>> getPlans() async {
    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.subscriptionPlans,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(PlansResponse.fromJson(data));
        }
        if (data is List) {
          return Right(
            PlansResponse(
              plans: data.map((e) => PlanModel.fromJson(e as Map<String, dynamic>)).toList(),
            ),
          );
        }
        return const Right(PlansResponse(plans: []));
      },
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> getCurrentSubscription() async {
    return _apiClient.get<SubscriptionModel>(
      ApiEndpoints.subscriptionCurrent,
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, UsageModel>> getUsage() async {
    return _apiClient.get<UsageModel>(
      ApiEndpoints.subscriptionUsage,
      fromJson: (json) => UsageModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, CheckoutResponse>> createCheckout(
    CheckoutRequest request,
  ) async {
    return _apiClient.post<CheckoutResponse>(
      ApiEndpoints.subscriptionCheckout,
      data: request.toJson(),
      fromJson: (json) => CheckoutResponse.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> verifyPayment(
    PaymentVerificationRequest request,
  ) async {
    return _apiClient.post<SubscriptionModel>(
      ApiEndpoints.subscriptionVerifyPayment,
      data: request.toJson(),
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, CheckoutResponse>> upgradeSubscription({
    required String planId,
    required BillingCycle billingCycle,
  }) async {
    return _apiClient.post<CheckoutResponse>(
      ApiEndpoints.subscriptionUpgrade,
      data: {
        'planId': planId,
        'billingCycle': billingCycle.value,
      },
      fromJson: (json) => CheckoutResponse.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> downgradeSubscription({
    required String planId,
  }) async {
    return _apiClient.post<SubscriptionModel>(
      ApiEndpoints.subscriptionDowngrade,
      data: {'planId': planId},
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> cancelSubscription(
    CancelSubscriptionRequest request,
  ) async {
    return _apiClient.post<SubscriptionModel>(
      ApiEndpoints.subscriptionCancel,
      data: request.toJson(),
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> resumeSubscription() async {
    return _apiClient.post<SubscriptionModel>(
      ApiEndpoints.subscriptionResume,
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, InvoicesResponse>> getInvoices({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.subscriptionInvoices,
      queryParameters: queryParams,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(InvoicesResponse.fromJson(data));
        }
        if (data is List) {
          return Right(
            InvoicesResponse(
              invoices: data.map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>)).toList(),
              total: data.length,
              page: page,
              pageSize: limit,
              totalPages: 1,
            ),
          );
        }
        return const Right(
          InvoicesResponse(
            invoices: [],
            total: 0,
            page: 1,
            pageSize: 20,
            totalPages: 0,
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, String>> downloadInvoice(String invoiceId) async {
    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.subscriptionInvoiceDownload(invoiceId),
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          final downloadUrl = data['downloadUrl'] as String?;
          if (downloadUrl != null) {
            return Right(downloadUrl);
          }
          final url = data['url'] as String?;
          if (url != null) {
            return Right(url);
          }
        }
        if (data is String) {
          return Right(data);
        }
        return const Left(
          ServerFailure(
            'Failed to get invoice download URL',
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, UpiCreateResponse>> createUpiPayment(
    UpiCreateRequest request,
  ) async {
    return _apiClient.post<UpiCreateResponse>(
      ApiEndpoints.subscriptionUpiCreate,
      data: request.toJson(),
      fromJson: (json) => UpiCreateResponse.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> verifyUpiPayment(
    String transactionId,
  ) async {
    return _apiClient.post<SubscriptionModel>(
      ApiEndpoints.subscriptionUpiVerify,
      data: {'transactionId': transactionId},
      fromJson: (json) => SubscriptionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, PaymentMethodsResponse>> getPaymentMethods() async {
    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.utilsPaymentMethods,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(PaymentMethodsResponse.fromJson(data));
        }
        if (data is List) {
          return Right(
            PaymentMethodsResponse(
              paymentMethods: data
                  .map(
                    (e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
            ),
          );
        }
        return const Right(PaymentMethodsResponse(paymentMethods: []));
      },
    );
  }

  @override
  Future<Either<Failure, void>> setDefaultPaymentMethod(
    String paymentMethodId,
  ) async {
    return _apiClient.put<void>(
      '${ApiEndpoints.utilsPaymentMethods}/$paymentMethodId/default',
    );
  }

  @override
  Future<Either<Failure, String>> checkPaymentStatus(
    String transactionId,
  ) async {
    final result = await _apiClient.get<dynamic>(
      '${ApiEndpoints.subscriptionPayments}/$transactionId/status',
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(data['status'] as String? ?? 'UNKNOWN');
        }
        if (data is String) {
          return Right(data);
        }
        return const Right('UNKNOWN');
      },
    );
  }
}
