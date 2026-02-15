import 'package:equatable/equatable.dart';

/// Analytics Summary Model
/// Contains overall financial summary for a given date range
class AnalyticsSummaryModel extends Equatable {
  const AnalyticsSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.transactionCount,
    required this.averageDailySpend,
    required this.startDate,
    required this.endDate,
    this.previousPeriodIncome,
    this.previousPeriodExpense,
    this.incomeGrowth,
    this.expenseGrowth,
  });

  factory AnalyticsSummaryModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummaryModel(
      totalIncome: (json['totalIncome'] as num?)?.toInt() ?? 0,
      totalExpense: (json['totalExpense'] as num?)?.toInt() ?? 0,
      netSavings: (json['netSavings'] as num?)?.toInt() ?? 0,
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      averageDailySpend: (json['averageDailySpend'] as num?)?.toInt() ?? 0,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      previousPeriodIncome: (json['previousPeriodIncome'] as num?)?.toInt(),
      previousPeriodExpense: (json['previousPeriodExpense'] as num?)?.toInt(),
      incomeGrowth: (json['incomeGrowth'] as num?)?.toDouble(),
      expenseGrowth: (json['expenseGrowth'] as num?)?.toDouble(),
    );
  }

  /// Total income in paise
  final int totalIncome;

  /// Total expense in paise
  final int totalExpense;

  /// Net savings (income - expense) in paise
  final int netSavings;

  /// Savings rate as percentage (0-100)
  final double savingsRate;

  /// Total number of transactions
  final int transactionCount;

  /// Average daily spending in paise
  final int averageDailySpend;

  /// Start date of the analytics period
  final DateTime startDate;

  /// End date of the analytics period
  final DateTime endDate;

  /// Previous period income for comparison (optional)
  final int? previousPeriodIncome;

  /// Previous period expense for comparison (optional)
  final int? previousPeriodExpense;

  /// Income growth percentage compared to previous period
  final double? incomeGrowth;

  /// Expense growth percentage compared to previous period
  final double? expenseGrowth;

  // Rupee conversions
  double get totalIncomeInRupees => totalIncome / 100;
  double get totalExpenseInRupees => totalExpense / 100;
  double get netSavingsInRupees => netSavings / 100;
  double get averageDailySpendInRupees => averageDailySpend / 100;
  double? get previousPeriodIncomeInRupees =>
      previousPeriodIncome != null ? previousPeriodIncome! / 100 : null;
  double? get previousPeriodExpenseInRupees =>
      previousPeriodExpense != null ? previousPeriodExpense! / 100 : null;

  /// Check if savings rate is positive
  bool get isPositiveSavings => savingsRate > 0;

  /// Check if income grew compared to previous period
  bool get hasIncomeGrowth => incomeGrowth != null && incomeGrowth! > 0;

  /// Check if expense reduced compared to previous period
  bool get hasExpenseReduction => expenseGrowth != null && expenseGrowth! < 0;

  Map<String, dynamic> toJson() {
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netSavings': netSavings,
      'savingsRate': savingsRate,
      'transactionCount': transactionCount,
      'averageDailySpend': averageDailySpend,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      if (previousPeriodIncome != null) 'previousPeriodIncome': previousPeriodIncome,
      if (previousPeriodExpense != null) 'previousPeriodExpense': previousPeriodExpense,
      if (incomeGrowth != null) 'incomeGrowth': incomeGrowth,
      if (expenseGrowth != null) 'expenseGrowth': expenseGrowth,
    };
  }

  AnalyticsSummaryModel copyWith({
    int? totalIncome,
    int? totalExpense,
    int? netSavings,
    double? savingsRate,
    int? transactionCount,
    int? averageDailySpend,
    DateTime? startDate,
    DateTime? endDate,
    int? previousPeriodIncome,
    int? previousPeriodExpense,
    double? incomeGrowth,
    double? expenseGrowth,
  }) {
    return AnalyticsSummaryModel(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netSavings: netSavings ?? this.netSavings,
      savingsRate: savingsRate ?? this.savingsRate,
      transactionCount: transactionCount ?? this.transactionCount,
      averageDailySpend: averageDailySpend ?? this.averageDailySpend,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      previousPeriodIncome: previousPeriodIncome ?? this.previousPeriodIncome,
      previousPeriodExpense: previousPeriodExpense ?? this.previousPeriodExpense,
      incomeGrowth: incomeGrowth ?? this.incomeGrowth,
      expenseGrowth: expenseGrowth ?? this.expenseGrowth,
    );
  }

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netSavings,
        savingsRate,
        transactionCount,
        averageDailySpend,
        startDate,
        endDate,
        previousPeriodIncome,
        previousPeriodExpense,
        incomeGrowth,
        expenseGrowth,
      ];
}
