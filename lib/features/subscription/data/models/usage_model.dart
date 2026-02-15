import 'package:equatable/equatable.dart';

import 'plan_model.dart';

/// Usage Model
///
/// Tracks the user's current usage against their plan limits.
/// Used to show usage meters and enforce feature limits.
class UsageModel extends Equatable {
  const UsageModel({
    required this.transactionsUsed,
    required this.accountsUsed,
    required this.budgetsUsed,
    required this.goalsUsed,
    required this.familyMembersUsed,
    required this.aiInsightsUsed,
    required this.limits,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Creates a [UsageModel] instance from JSON.
  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      transactionsUsed: json['transactionsUsed'] as int? ?? 0,
      accountsUsed: json['accountsUsed'] as int? ?? 0,
      budgetsUsed: json['budgetsUsed'] as int? ?? 0,
      goalsUsed: json['goalsUsed'] as int? ?? 0,
      familyMembersUsed: json['familyMembersUsed'] as int? ?? 0,
      aiInsightsUsed: json['aiInsightsUsed'] as int? ?? 0,
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : const PlanLimits(
              transactions: 50,
              accounts: 2,
              budgets: 3,
              goals: 2,
              familyMembers: 0,
              aiInsights: 5,
            ),
      periodStart: json['periodStart'] != null
          ? DateTime.parse(json['periodStart'] as String)
          : DateTime.now(),
      periodEnd: json['periodEnd'] != null
          ? DateTime.parse(json['periodEnd'] as String)
          : DateTime.now().add(const Duration(days: 30)),
    );
  }

  /// Number of transactions used this period
  final int transactionsUsed;

  /// Number of accounts created
  final int accountsUsed;

  /// Number of budgets created
  final int budgetsUsed;

  /// Number of goals created
  final int goalsUsed;

  /// Number of family members added
  final int familyMembersUsed;

  /// Number of AI insights used this period
  final int aiInsightsUsed;

  /// Plan limits for comparison
  final PlanLimits limits;

  /// Start of the current usage period
  final DateTime periodStart;

  /// End of the current usage period
  final DateTime periodEnd;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'transactionsUsed': transactionsUsed,
      'accountsUsed': accountsUsed,
      'budgetsUsed': budgetsUsed,
      'goalsUsed': goalsUsed,
      'familyMembersUsed': familyMembersUsed,
      'aiInsightsUsed': aiInsightsUsed,
      'limits': limits.toJson(),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  /// Creates a copy with modified fields.
  UsageModel copyWith({
    int? transactionsUsed,
    int? accountsUsed,
    int? budgetsUsed,
    int? goalsUsed,
    int? familyMembersUsed,
    int? aiInsightsUsed,
    PlanLimits? limits,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return UsageModel(
      transactionsUsed: transactionsUsed ?? this.transactionsUsed,
      accountsUsed: accountsUsed ?? this.accountsUsed,
      budgetsUsed: budgetsUsed ?? this.budgetsUsed,
      goalsUsed: goalsUsed ?? this.goalsUsed,
      familyMembersUsed: familyMembersUsed ?? this.familyMembersUsed,
      aiInsightsUsed: aiInsightsUsed ?? this.aiInsightsUsed,
      limits: limits ?? this.limits,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  // ==================== Percentage Used Calculations ====================

  /// Get transactions usage percentage (0-100)
  double get transactionsPercentageUsed {
    if (limits.hasUnlimitedTransactions) {
      return 0;
    }
    if (limits.transactions <= 0) {
      return 100;
    }
    return (transactionsUsed / limits.transactions * 100).clamp(0, 100);
  }

  /// Get accounts usage percentage (0-100)
  double get accountsPercentageUsed {
    if (limits.hasUnlimitedAccounts) {
      return 0;
    }
    if (limits.accounts <= 0) {
      return 100;
    }
    return (accountsUsed / limits.accounts * 100).clamp(0, 100);
  }

  /// Get budgets usage percentage (0-100)
  double get budgetsPercentageUsed {
    if (limits.hasUnlimitedBudgets) {
      return 0;
    }
    if (limits.budgets <= 0) {
      return 100;
    }
    return (budgetsUsed / limits.budgets * 100).clamp(0, 100);
  }

  /// Get goals usage percentage (0-100)
  double get goalsPercentageUsed {
    if (limits.hasUnlimitedGoals) {
      return 0;
    }
    if (limits.goals <= 0) {
      return 100;
    }
    return (goalsUsed / limits.goals * 100).clamp(0, 100);
  }

  /// Get family members usage percentage (0-100)
  double get familyMembersPercentageUsed {
    if (limits.hasUnlimitedFamilyMembers) {
      return 0;
    }
    if (limits.familyMembers <= 0) {
      return 100;
    }
    return (familyMembersUsed / limits.familyMembers * 100).clamp(0, 100);
  }

  /// Get AI insights usage percentage (0-100)
  double get aiInsightsPercentageUsed {
    if (limits.hasUnlimitedAiInsights) {
      return 0;
    }
    if (limits.aiInsights <= 0) {
      return 100;
    }
    return (aiInsightsUsed / limits.aiInsights * 100).clamp(0, 100);
  }

  // ==================== Near Limit Checks (>80%) ====================

  /// Check if transactions are near limit (>80%)
  bool get isTransactionsNearLimit => transactionsPercentageUsed >= 80;

  /// Check if accounts are near limit (>80%)
  bool get isAccountsNearLimit => accountsPercentageUsed >= 80;

  /// Check if budgets are near limit (>80%)
  bool get isBudgetsNearLimit => budgetsPercentageUsed >= 80;

  /// Check if goals are near limit (>80%)
  bool get isGoalsNearLimit => goalsPercentageUsed >= 80;

  /// Check if family members are near limit (>80%)
  bool get isFamilyMembersNearLimit => familyMembersPercentageUsed >= 80;

  /// Check if AI insights are near limit (>80%)
  bool get isAiInsightsNearLimit => aiInsightsPercentageUsed >= 80;

  /// Check if any feature is near limit
  bool get hasAnyNearLimit =>
      isTransactionsNearLimit ||
      isAccountsNearLimit ||
      isBudgetsNearLimit ||
      isGoalsNearLimit ||
      isFamilyMembersNearLimit ||
      isAiInsightsNearLimit;

  // ==================== At Limit Checks (100%) ====================

  /// Check if transactions are at limit
  bool get isTransactionsAtLimit {
    if (limits.hasUnlimitedTransactions) {
      return false;
    }
    return transactionsUsed >= limits.transactions;
  }

  /// Check if accounts are at limit
  bool get isAccountsAtLimit {
    if (limits.hasUnlimitedAccounts) {
      return false;
    }
    return accountsUsed >= limits.accounts;
  }

  /// Check if budgets are at limit
  bool get isBudgetsAtLimit {
    if (limits.hasUnlimitedBudgets) {
      return false;
    }
    return budgetsUsed >= limits.budgets;
  }

  /// Check if goals are at limit
  bool get isGoalsAtLimit {
    if (limits.hasUnlimitedGoals) {
      return false;
    }
    return goalsUsed >= limits.goals;
  }

  /// Check if family members are at limit
  bool get isFamilyMembersAtLimit {
    if (limits.hasUnlimitedFamilyMembers) {
      return false;
    }
    return familyMembersUsed >= limits.familyMembers;
  }

  /// Check if AI insights are at limit
  bool get isAiInsightsAtLimit {
    if (limits.hasUnlimitedAiInsights) {
      return false;
    }
    return aiInsightsUsed >= limits.aiInsights;
  }

  /// Check if any feature is at limit
  bool get hasAnyAtLimit =>
      isTransactionsAtLimit ||
      isAccountsAtLimit ||
      isBudgetsAtLimit ||
      isGoalsAtLimit ||
      isFamilyMembersAtLimit ||
      isAiInsightsAtLimit;

  // ==================== Remaining Calculations ====================

  /// Get remaining transactions
  int get transactionsRemaining {
    if (limits.hasUnlimitedTransactions) {
      return -1;
    }
    return (limits.transactions - transactionsUsed).clamp(0, limits.transactions);
  }

  /// Get remaining accounts
  int get accountsRemaining {
    if (limits.hasUnlimitedAccounts) {
      return -1;
    }
    return (limits.accounts - accountsUsed).clamp(0, limits.accounts);
  }

  /// Get remaining budgets
  int get budgetsRemaining {
    if (limits.hasUnlimitedBudgets) {
      return -1;
    }
    return (limits.budgets - budgetsUsed).clamp(0, limits.budgets);
  }

  /// Get remaining goals
  int get goalsRemaining {
    if (limits.hasUnlimitedGoals) {
      return -1;
    }
    return (limits.goals - goalsUsed).clamp(0, limits.goals);
  }

  /// Get remaining family members
  int get familyMembersRemaining {
    if (limits.hasUnlimitedFamilyMembers) {
      return -1;
    }
    return (limits.familyMembers - familyMembersUsed).clamp(0, limits.familyMembers);
  }

  /// Get remaining AI insights
  int get aiInsightsRemaining {
    if (limits.hasUnlimitedAiInsights) {
      return -1;
    }
    return (limits.aiInsights - aiInsightsUsed).clamp(0, limits.aiInsights);
  }

  /// Get days remaining in current period
  int get daysRemainingInPeriod {
    final now = DateTime.now();
    if (now.isAfter(periodEnd)) {
      return 0;
    }
    return periodEnd.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
        transactionsUsed,
        accountsUsed,
        budgetsUsed,
        goalsUsed,
        familyMembersUsed,
        aiInsightsUsed,
        limits,
        periodStart,
        periodEnd,
      ];
}
