import 'package:equatable/equatable.dart';

/// Request model for account deletion
class DeleteAccountRequest {
  const DeleteAccountRequest({
    required this.password,
    required this.confirmationText,
    this.cancelSubscription = true,
  });

  final String password;
  final String confirmationText;
  final bool cancelSubscription;

  Map<String, dynamic> toJson() => {
        'password': password,
        'confirmationText': confirmationText,
        'cancelSubscription': cancelSubscription,
      };
}

/// Model for active subscription information
class ActiveSubscriptionInfo extends Equatable {
  const ActiveSubscriptionInfo({
    required this.hasActiveSubscription,
    this.planName,
    this.expiryDate,
    this.amountPaid,
    this.billingCycle,
    this.subscriptionId,
    this.status,
  });

  factory ActiveSubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return ActiveSubscriptionInfo(
      hasActiveSubscription: json['hasActiveSubscription'] as bool? ?? false,
      planName: json['planName'] as String?,
      expiryDate: json['expiryDate'] as String?,
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      billingCycle: json['billingCycle'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      status: json['status'] as String?,
    );
  }

  /// No active subscription placeholder
  static const ActiveSubscriptionInfo none = ActiveSubscriptionInfo(
    hasActiveSubscription: false,
  );

  final bool hasActiveSubscription;
  final String? planName;
  final String? expiryDate;
  final double? amountPaid;
  final String? billingCycle;
  final String? subscriptionId;
  final String? status;

  /// Get formatted amount with currency
  String get formattedAmount {
    if (amountPaid == null) return 'N/A';
    return '₹${amountPaid!.toStringAsFixed(2)}';
  }

  /// Get formatted billing cycle
  String get formattedBillingCycle {
    switch (billingCycle?.toLowerCase()) {
      case 'monthly':
        return 'Monthly';
      case 'yearly':
      case 'annual':
        return 'Yearly';
      case 'quarterly':
        return 'Quarterly';
      default:
        return billingCycle ?? 'N/A';
    }
  }

  @override
  List<Object?> get props => [
        hasActiveSubscription,
        planName,
        expiryDate,
        amountPaid,
        billingCycle,
        subscriptionId,
        status,
      ];
}

/// Deletion state enum for UI
enum DeletionState {
  idle,
  checkingSubscription,
  confirming,
  deleting,
  success,
  error,
}

/// Extension for DeletionState
extension DeletionStateExtension on DeletionState {
  bool get isLoading =>
      this == DeletionState.checkingSubscription ||
      this == DeletionState.deleting;

  bool get isIdle => this == DeletionState.idle;

  bool get isSuccess => this == DeletionState.success;

  bool get isError => this == DeletionState.error;

  String get message {
    switch (this) {
      case DeletionState.idle:
        return 'Ready';
      case DeletionState.checkingSubscription:
        return 'Checking subscription status...';
      case DeletionState.confirming:
        return 'Waiting for confirmation...';
      case DeletionState.deleting:
        return 'Deleting your account...';
      case DeletionState.success:
        return 'Account deleted successfully';
      case DeletionState.error:
        return 'Failed to delete account';
    }
  }
}
