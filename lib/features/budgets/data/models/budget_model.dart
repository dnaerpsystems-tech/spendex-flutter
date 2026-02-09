import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../categories/data/models/category_model.dart';

/// Budget Model
class BudgetModel extends Equatable {
  final String id;
  final String name;
  final int amount; // in paise
  final int spent; // in paise
  final int remaining; // in paise
  final double percentage;
  final String? categoryId;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int alertThreshold;
  final bool isActive;
  final bool rollover;
  final CategoryModel? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BudgetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.spent,
    required this.remaining,
    required this.percentage,
    this.categoryId,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 80,
    this.isActive = true,
    this.rollover = false,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int,
      spent: json['spent'] as int,
      remaining: json['remaining'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      categoryId: json['categoryId'] as String?,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.value == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      alertThreshold: json['alertThreshold'] as int? ?? 80,
      isActive: json['isActive'] as bool? ?? true,
      rollover: json['rollover'] as bool? ?? false,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'remaining': remaining,
      'percentage': percentage,
      'categoryId': categoryId,
      'period': period.value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertThreshold': alertThreshold,
      'isActive': isActive,
      'rollover': rollover,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BudgetModel copyWith({
    String? id,
    String? name,
    int? amount,
    int? spent,
    int? remaining,
    double? percentage,
    String? categoryId,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    int? alertThreshold,
    bool? isActive,
    bool? rollover,
    CategoryModel? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      remaining: remaining ?? this.remaining,
      percentage: percentage ?? this.percentage,
      categoryId: categoryId ?? this.categoryId,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isActive: isActive ?? this.isActive,
      rollover: rollover ?? this.rollover,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get amountInRupees => amount / 100;
  double get spentInRupees => spent / 100;
  double get remainingInRupees => remaining / 100;

  bool get isOverBudget => spent > amount;
  bool get isNearLimit => percentage >= alertThreshold;

  BudgetStatus get status {
    if (percentage >= 100) return BudgetStatus.exceeded;
    if (percentage >= alertThreshold) return BudgetStatus.warning;
    return BudgetStatus.onTrack;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        spent,
        remaining,
        percentage,
        categoryId,
        period,
        startDate,
        endDate,
        alertThreshold,
        isActive,
        rollover,
        createdAt,
        updatedAt,
      ];
}

/// Budget Status
enum BudgetStatus {
  onTrack,
  warning,
  exceeded,
}

/// Budgets Summary
class BudgetsSummary extends Equatable {
  final int totalBudget;
  final int totalSpent;
  final int totalRemaining;
  final int budgetCount;
  final int overBudgetCount;

  const BudgetsSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.budgetCount,
    required this.overBudgetCount,
  });

  factory BudgetsSummary.fromJson(Map<String, dynamic> json) {
    return BudgetsSummary(
      totalBudget: json['totalBudget'] as int,
      totalSpent: json['totalSpent'] as int,
      totalRemaining: json['totalRemaining'] as int,
      budgetCount: json['budgetCount'] as int,
      overBudgetCount: json['overBudgetCount'] as int,
    );
  }

  double get totalBudgetInRupees => totalBudget / 100;
  double get totalSpentInRupees => totalSpent / 100;
  double get totalRemainingInRupees => totalRemaining / 100;
  double get overallPercentage =>
      totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

  @override
  List<Object?> get props => [
        totalBudget,
        totalSpent,
        totalRemaining,
        budgetCount,
        overBudgetCount,
      ];
}

/// Create Budget Request
class CreateBudgetRequest {
  final String name;
  final int amount;
  final String? categoryId;
  final BudgetPeriod period;
  final int? alertThreshold;
  final bool? rollover;

  const CreateBudgetRequest({
    required this.name,
    required this.amount,
    this.categoryId,
    required this.period,
    this.alertThreshold,
    this.rollover,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      if (categoryId != null) 'categoryId': categoryId,
      'period': period.value,
      if (alertThreshold != null) 'alertThreshold': alertThreshold,
      if (rollover != null) 'rollover': rollover,
    };
  }
}
