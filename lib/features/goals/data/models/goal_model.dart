import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Goal Model
class GoalModel extends Equatable {
  final String id;
  final String name;
  final int targetAmount; // in paise
  final int currentAmount; // in paise
  final double progress;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final GoalStatus status;
  final int? monthlyRequired; // in paise
  final String? linkedAccountId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.progress,
    this.targetDate,
    this.icon,
    this.color,
    required this.status,
    this.monthlyRequired,
    this.linkedAccountId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      targetAmount: json['targetAmount'] as int,
      currentAmount: json['currentAmount'] as int,
      progress: (json['progress'] as num).toDouble(),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      status: GoalStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => GoalStatus.active,
      ),
      monthlyRequired: json['monthlyRequired'] as int?,
      linkedAccountId: json['linkedAccountId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'progress': progress,
      'targetDate': targetDate?.toIso8601String(),
      'icon': icon,
      'color': color,
      'status': status.value,
      'monthlyRequired': monthlyRequired,
      'linkedAccountId': linkedAccountId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  GoalModel copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    double? progress,
    DateTime? targetDate,
    String? icon,
    String? color,
    GoalStatus? status,
    int? monthlyRequired,
    String? linkedAccountId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      progress: progress ?? this.progress,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      status: status ?? this.status,
      monthlyRequired: monthlyRequired ?? this.monthlyRequired,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get targetAmountInRupees => targetAmount / 100;
  double get currentAmountInRupees => currentAmount / 100;
  double get remainingInRupees => (targetAmount - currentAmount) / 100;
  double? get monthlyRequiredInRupees =>
      monthlyRequired != null ? monthlyRequired! / 100 : null;

  bool get isCompleted => status == GoalStatus.completed;
  bool get isActive => status == GoalStatus.active;

  int? get daysRemaining {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        targetAmount,
        currentAmount,
        progress,
        targetDate,
        icon,
        color,
        status,
        monthlyRequired,
        linkedAccountId,
        createdAt,
        updatedAt,
      ];
}

/// Goal Contribution
class GoalContribution extends Equatable {
  final String id;
  final String goalId;
  final int amount;
  final String? note;
  final DateTime date;
  final DateTime createdAt;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: json['amount'] as int,
      note: json['note'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  double get amountInRupees => amount / 100;

  @override
  List<Object?> get props => [id, goalId, amount, note, date, createdAt];
}

/// Goals Summary
class GoalsSummary extends Equatable {
  final int totalTarget;
  final int totalSaved;
  final int totalRemaining;
  final int goalCount;
  final int completedCount;

  const GoalsSummary({
    required this.totalTarget,
    required this.totalSaved,
    required this.totalRemaining,
    required this.goalCount,
    required this.completedCount,
  });

  factory GoalsSummary.fromJson(Map<String, dynamic> json) {
    return GoalsSummary(
      totalTarget: json['totalTarget'] as int,
      totalSaved: json['totalSaved'] as int,
      totalRemaining: json['totalRemaining'] as int,
      goalCount: json['goalCount'] as int,
      completedCount: json['completedCount'] as int,
    );
  }

  double get totalTargetInRupees => totalTarget / 100;
  double get totalSavedInRupees => totalSaved / 100;
  double get totalRemainingInRupees => totalRemaining / 100;
  double get overallProgress =>
      totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

  @override
  List<Object?> get props => [
        totalTarget,
        totalSaved,
        totalRemaining,
        goalCount,
        completedCount,
      ];
}

/// Create Goal Request
class CreateGoalRequest {
  final String name;
  final int targetAmount;
  final DateTime? targetDate;
  final String? icon;
  final String? color;
  final String? linkedAccountId;

  const CreateGoalRequest({
    required this.name,
    required this.targetAmount,
    this.targetDate,
    this.icon,
    this.color,
    this.linkedAccountId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetAmount': targetAmount,
      if (targetDate != null) 'targetDate': targetDate!.toIso8601String(),
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (linkedAccountId != null) 'linkedAccountId': linkedAccountId,
    };
  }
}

/// Add Contribution Request
class AddContributionRequest {
  final int amount;
  final String? note;
  final DateTime? date;

  const AddContributionRequest({
    required this.amount,
    this.note,
    this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      if (note != null) 'note': note,
      if (date != null) 'date': date!.toIso8601String(),
    };
  }
}
