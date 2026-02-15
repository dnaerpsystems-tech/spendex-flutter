import 'package:equatable/equatable.dart';

/// Request to verify password before account deletion
class VerifyPasswordRequest {
  const VerifyPasswordRequest({required this.password});
  
  final String password;
  
  Map<String, dynamic> toJson() => {'password': password};
}

/// Response from password verification
class VerifyPasswordResponse extends Equatable {
  const VerifyPasswordResponse({
    required this.verified,
    this.verificationToken,
    this.expiresAt,
  });
  
  factory VerifyPasswordResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPasswordResponse(
      verified: json['verified'] as bool? ?? false,
      verificationToken: json['verificationToken'] as String?,
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt'] as String) 
          : null,
    );
  }
  
  final bool verified;
  final String? verificationToken;
  final DateTime? expiresAt;
  
  @override
  List<Object?> get props => [verified, verificationToken, expiresAt];
}

/// Request for account deletion (after password verification)
class DeleteAccountRequest {
  const DeleteAccountRequest({
    required this.verificationToken,
    required this.confirmationText,
    this.cancelSubscription = true,
    this.reason,
  });

  final String verificationToken;
  final String confirmationText;
  final bool cancelSubscription;
  final String? reason;

  Map<String, dynamic> toJson() => {
        'verificationToken': verificationToken,
        'confirmationText': confirmationText,
        'cancelSubscription': cancelSubscription,
        if (reason != null) 'reason': reason,
      };
}


/// Response from account deletion request
class DeleteAccountResponse extends Equatable {
  const DeleteAccountResponse({
    required this.success,
    this.message,
    this.scheduledDeletionDate,
    this.canRecover = true,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      scheduledDeletionDate: json['scheduled_deletion_date'] != null
          ? DateTime.parse(json['scheduled_deletion_date'] as String)
          : null,
      canRecover: json['can_recover'] as bool? ?? true,
    );
  }

  final bool success;
  final String? message;
  final DateTime? scheduledDeletionDate;
  final bool canRecover;

  @override
  List<Object?> get props => [success, message, scheduledDeletionDate, canRecover];

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

  String get formattedAmount {
    if (amountPaid == null) {
      return 'N/A';
    }
    return '₹${amountPaid!.toStringAsFixed(2)}';
  }

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
  verifyingPassword,
  confirming,
  deleting,
  success,
  error,
}

extension DeletionStateExtension on DeletionState {
  bool get isLoading =>
      this == DeletionState.checkingSubscription ||
      this == DeletionState.verifyingPassword ||
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
      case DeletionState.verifyingPassword:
        return 'Verifying your identity...';
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

/// Deletion reason options
enum DeletionReason {
  notUseful('Not useful for me'),
  tooExpensive('Too expensive'),
  foundBetter('Found a better alternative'),
  privacyConcerns('Privacy concerns'),
  technicalIssues('Technical issues'),
  other('Other');

  const DeletionReason(this.label);
  final String label;
}
