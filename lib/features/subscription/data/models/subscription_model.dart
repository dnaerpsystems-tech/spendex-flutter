import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import 'payment_model.dart';
import 'plan_model.dart';

/// Subscription Model
///
/// Represents a user's subscription to a plan with status tracking,
/// billing period information, and payment details.
class SubscriptionModel extends Equatable {
  const SubscriptionModel({
    required this.id,
    required this.planId,
    required this.userId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
    this.trialEnd,
    this.cancelAtPeriodEnd = false,
    this.cancelledAt,
    this.paymentMethod,
  });

  /// Creates a [SubscriptionModel] instance from JSON.
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      planId: json['planId'] as String,
      userId: json['userId'] as String,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      plan: json['plan'] != null
          ? PlanModel.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
      currentPeriodStart: DateTime.parse(json['currentPeriodStart'] as String),
      currentPeriodEnd: DateTime.parse(json['currentPeriodEnd'] as String),
      trialEnd: json['trialEnd'] != null
          ? DateTime.parse(json['trialEnd'] as String)
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethodModel.fromJson(
              json['paymentMethod'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Unique identifier for the subscription
  final String id;

  /// ID of the subscribed plan
  final String planId;

  /// Plan details (optional, populated when included in response)
  final PlanModel? plan;

  /// ID of the user who owns this subscription
  final String userId;

  /// Current status of the subscription
  final SubscriptionStatus status;

  /// Start date of the current billing period
  final DateTime currentPeriodStart;

  /// End date of the current billing period
  final DateTime currentPeriodEnd;

  /// End date of the trial period (null if no trial)
  final DateTime? trialEnd;

  /// Whether the subscription will be cancelled at period end
  final bool cancelAtPeriodEnd;

  /// Date when the subscription was cancelled (null if not cancelled)
  final DateTime? cancelledAt;

  /// Payment method used for this subscription
  final PaymentMethodModel? paymentMethod;

  /// When the subscription was created
  final DateTime createdAt;

  /// When the subscription was last updated
  final DateTime updatedAt;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'userId': userId,
      'status': status.value,
      if (plan != null) 'plan': plan!.toJson(),
      'currentPeriodStart': currentPeriodStart.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd.toIso8601String(),
      if (trialEnd != null) 'trialEnd': trialEnd!.toIso8601String(),
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.toIso8601String(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy with modified fields.
  SubscriptionModel copyWith({
    String? id,
    String? planId,
    PlanModel? plan,
    String? userId,
    SubscriptionStatus? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? trialEnd,
    bool? cancelAtPeriodEnd,
    DateTime? cancelledAt,
    PaymentMethodModel? paymentMethod,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      plan: plan ?? this.plan,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      trialEnd: trialEnd ?? this.trialEnd,
      cancelAtPeriodEnd: cancelAtPeriodEnd ?? this.cancelAtPeriodEnd,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if subscription is currently active
  bool get isActive => status == SubscriptionStatus.active;

  /// Check if subscription is in trial period
  bool get isTrialing => status == SubscriptionStatus.trialing;

  /// Check if subscription has been cancelled
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  /// Check if subscription is past due (payment failed)
  bool get isPastDue => status == SubscriptionStatus.pastDue;

  /// Check if subscription is expired
  bool get isExpired => status == SubscriptionStatus.expired;

  /// Check if subscription is paused
  bool get isPaused => status == SubscriptionStatus.paused;

  /// Check if subscription is valid (active or trialing)
  bool get isValid => isActive || isTrialing;

  /// Get the number of days remaining in the current period
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(currentPeriodEnd)) return 0;
    return currentPeriodEnd.difference(now).inDays;
  }

  /// Get the number of days remaining in trial
  int get trialDaysRemaining {
    if (trialEnd == null) return 0;
    final now = DateTime.now();
    if (now.isAfter(trialEnd!)) return 0;
    return trialEnd!.difference(now).inDays;
  }

  /// Check if trial is ending soon (less than 3 days)
  bool get isTrialEnding {
    if (!isTrialing || trialEnd == null) return false;
    return trialDaysRemaining <= 3 && trialDaysRemaining > 0;
  }

  /// Check if subscription is ending soon (less than 7 days)
  bool get isEndingSoon {
    if (cancelAtPeriodEnd) return daysRemaining <= 7;
    return false;
  }

  /// Check if the subscription will renew
  bool get willRenew => isValid && !cancelAtPeriodEnd;

  /// Get percentage of current period completed
  double get periodProgressPercentage {
    final totalDays =
        currentPeriodEnd.difference(currentPeriodStart).inDays;
    final daysUsed =
        DateTime.now().difference(currentPeriodStart).inDays;
    if (totalDays <= 0) return 0;
    return (daysUsed / totalDays * 100).clamp(0, 100);
  }

  /// Get a human-readable status message
  String get statusMessage {
    switch (status) {
      case SubscriptionStatus.trialing:
        return 'Trial ends in $trialDaysRemaining days';
      case SubscriptionStatus.active:
        if (cancelAtPeriodEnd) {
          return 'Cancels in $daysRemaining days';
        }
        return 'Renews in $daysRemaining days';
      case SubscriptionStatus.pastDue:
        return 'Payment failed';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.paused:
        return 'Paused';
    }
  }

  @override
  List<Object?> get props => [
        id,
        planId,
        plan,
        userId,
        status,
        currentPeriodStart,
        currentPeriodEnd,
        trialEnd,
        cancelAtPeriodEnd,
        cancelledAt,
        paymentMethod,
        createdAt,
        updatedAt,
      ];
}

/// Subscription Response Model
///
/// Represents the API response for subscription operations.
class SubscriptionResponse extends Equatable {
  const SubscriptionResponse({
    required this.subscription,
    this.message,
  });

  /// Creates a [SubscriptionResponse] instance from JSON.
  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      subscription: SubscriptionModel.fromJson(
        json['subscription'] as Map<String, dynamic>,
      ),
      message: json['message'] as String?,
    );
  }

  /// The subscription data
  final SubscriptionModel subscription;

  /// Optional message from the server
  final String? message;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'subscription': subscription.toJson(),
      if (message != null) 'message': message,
    };
  }

  @override
  List<Object?> get props => [subscription, message];
}

/// Cancel Subscription Request
class CancelSubscriptionRequest {
  const CancelSubscriptionRequest({
    required this.cancelAtPeriodEnd,
    this.reason,
    this.feedback,
  });

  /// Whether to cancel immediately or at period end
  final bool cancelAtPeriodEnd;

  /// Reason for cancellation
  final String? reason;

  /// Additional feedback
  final String? feedback;

  Map<String, dynamic> toJson() {
    return {
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      if (reason != null) 'reason': reason,
      if (feedback != null) 'feedback': feedback,
    };
  }
}
