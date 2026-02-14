import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';
import '../models/subscription_models.dart';

/// Subscription Repository Implementation
///
/// Implements [SubscriptionRepository] by delegating to the remote data source.
/// This class acts as a bridge between the domain layer and the data layer.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  /// Creates a new [SubscriptionRepositoryImpl] with the given data source.
  SubscriptionRepositoryImpl(this._remoteDataSource);

  final SubscriptionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, PlansResponse>> getPlans() {
    return _remoteDataSource.getPlans();
  }

  @override
  Future<Either<Failure, SubscriptionModel>> getCurrentSubscription() {
    return _remoteDataSource.getCurrentSubscription();
  }

  @override
  Future<Either<Failure, UsageModel>> getUsage() {
    return _remoteDataSource.getUsage();
  }

  @override
  Future<Either<Failure, CheckoutResponse>> createCheckout(
    CheckoutRequest request,
  ) {
    return _remoteDataSource.createCheckout(request);
  }

  @override
  Future<Either<Failure, SubscriptionModel>> verifyPayment(
    PaymentVerificationRequest request,
  ) {
    return _remoteDataSource.verifyPayment(request);
  }

  @override
  Future<Either<Failure, CheckoutResponse>> upgradeSubscription({
    required String planId,
    required BillingCycle billingCycle,
  }) {
    return _remoteDataSource.upgradeSubscription(
      planId: planId,
      billingCycle: billingCycle,
    );
  }

  @override
  Future<Either<Failure, SubscriptionModel>> downgradeSubscription({
    required String planId,
  }) {
    return _remoteDataSource.downgradeSubscription(planId: planId);
  }

  @override
  Future<Either<Failure, SubscriptionModel>> cancelSubscription(
    CancelSubscriptionRequest request,
  ) {
    return _remoteDataSource.cancelSubscription(request);
  }

  @override
  Future<Either<Failure, SubscriptionModel>> resumeSubscription() {
    return _remoteDataSource.resumeSubscription();
  }

  @override
  Future<Either<Failure, InvoicesResponse>> getInvoices({
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getInvoices(page: page, limit: limit);
  }

  @override
  Future<Either<Failure, String>> downloadInvoice(String invoiceId) {
    return _remoteDataSource.downloadInvoice(invoiceId);
  }

  @override
  Future<Either<Failure, UpiCreateResponse>> createUpiPayment(
    UpiCreateRequest request,
  ) {
    return _remoteDataSource.createUpiPayment(request);
  }

  @override
  Future<Either<Failure, SubscriptionModel>> verifyUpiPayment(
    String transactionId,
  ) {
    return _remoteDataSource.verifyUpiPayment(transactionId);
  }

  @override
  Future<Either<Failure, PaymentMethodsResponse>> getPaymentMethods() {
    return _remoteDataSource.getPaymentMethods();
  }
}
