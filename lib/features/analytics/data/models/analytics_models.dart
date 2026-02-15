import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Analytics Summary Model
class AnalyticsSummary extends Equatable {
  const AnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.transactionCount,
    required this.averageDailySpend,
    required this.highestExpenseCategory,
    required this.highestExpenseAmount,
    this.previousPeriodIncome,
    this.previousPeriodExpense,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalIncome: _parseDouble(json['totalIncome']),
      totalExpense: _parseDouble(json['totalExpense']),
      netSavings: _parseDouble(json['netSavings']),
      savingsRate: _parseDouble(json['savingsRate']),
      transactionCount: json['transactionCount'] as int? ?? 0,
      averageDailySpend: _parseDouble(json['averageDailySpend']),
      highestExpenseCategory: json['highestExpenseCategory'] as String? ?? '',
      highestExpenseAmount: _parseDouble(json['highestExpenseAmount']),
      previousPeriodIncome:
          json['previousPeriodIncome'] != null ? _parseDouble(json['previousPeriodIncome']) : null,
      previousPeriodExpense: json['previousPeriodExpense'] != null
          ? _parseDouble(json['previousPeriodExpense'])
          : null,
    );
  }

  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate;
  final int transactionCount;
  final double averageDailySpend;
  final String highestExpenseCategory;
  final double highestExpenseAmount;
  final double? previousPeriodIncome;
  final double? previousPeriodExpense;

  double? get incomeChangePercent {
    if (previousPeriodIncome == null || previousPeriodIncome == 0) {
      return null;
    }
    return ((totalIncome - previousPeriodIncome!) / previousPeriodIncome!) * 100;
  }

  double? get expenseChangePercent {
    if (previousPeriodExpense == null || previousPeriodExpense == 0) {
      return null;
    }
    return ((totalExpense - previousPeriodExpense!) / previousPeriodExpense!) * 100;
  }

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netSavings,
        savingsRate,
        transactionCount,
        averageDailySpend,
        highestExpenseCategory,
        highestExpenseAmount,
        previousPeriodIncome,
        previousPeriodExpense,
      ];
}

/// Category Breakdown Model
class CategoryBreakdown extends Equatable {
  const CategoryBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    required this.color,
    this.icon,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: json['categoryId'] as String? ?? json['id'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? json['name'] as String? ?? 'Unknown',
      amount: _parseDouble(json['amount']),
      percentage: _parseDouble(json['percentage']),
      transactionCount: json['transactionCount'] as int? ?? json['count'] as int? ?? 0,
      color: _parseColor(json['color']),
      icon: json['icon'] as String?,
    );
  }

  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;
  final Color color;
  final String? icon;

  @override
  List<Object?> get props =>
      [categoryId, categoryName, amount, percentage, transactionCount, color, icon];
}

/// Daily Stats Model
class DailyStats extends Equatable {
  const DailyStats({
    required this.date,
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      income: _parseDouble(json['income']),
      expense: _parseDouble(json['expense']),
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  final DateTime date;
  final double income;
  final double expense;
  final int transactionCount;

  double get netAmount => income - expense;

  @override
  List<Object?> get props => [date, income, expense, transactionCount];
}

/// Monthly Stats Model
class MonthlyStats extends Equatable {
  const MonthlyStats({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  factory MonthlyStats.fromJson(Map<String, dynamic> json) {
    return MonthlyStats(
      year: json['year'] as int,
      month: json['month'] as int,
      income: _parseDouble(json['income']),
      expense: _parseDouble(json['expense']),
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  final int year;
  final int month;
  final double income;
  final double expense;
  final int transactionCount;

  double get netAmount => income - expense;
  double get savingsRate => income > 0 ? (netAmount / income) * 100 : 0;

  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  DateTime get dateTime => DateTime(year, month);

  @override
  List<Object?> get props => [year, month, income, expense, transactionCount];
}

/// Net Worth Point Model
class NetWorthPoint extends Equatable {
  const NetWorthPoint({
    required this.date,
    required this.assets,
    required this.liabilities,
  });

  factory NetWorthPoint.fromJson(Map<String, dynamic> json) {
    return NetWorthPoint(
      date: DateTime.parse(json['date'] as String),
      assets: _parseDouble(json['assets']),
      liabilities: _parseDouble(json['liabilities']),
    );
  }

  final DateTime date;
  final double assets;
  final double liabilities;

  double get netWorth => assets - liabilities;

  @override
  List<Object?> get props => [date, assets, liabilities];
}

/// Date Range Preset Enum
enum DateRangePreset {
  thisWeek('This Week'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  last3Months('Last 3 Months'),
  last6Months('Last 6 Months'),
  thisYear('This Year'),
  lastYear('Last Year'),
  allTime('All Time'),
  custom('Custom');

  const DateRangePreset(this.label);
  final String label;

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case DateRangePreset.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: startOfWeek, end: today);
      case DateRangePreset.thisMonth:
        final startOfMonth = DateTime(now.year, now.month);
        return DateTimeRange(start: startOfMonth, end: today);
      case DateRangePreset.lastMonth:
        final startOfLastMonth = DateTime(now.year, now.month - 1);
        final endOfLastMonth = DateTime(now.year, now.month, 0);
        return DateTimeRange(start: startOfLastMonth, end: endOfLastMonth);
      case DateRangePreset.last3Months:
        final start = DateTime(now.year, now.month - 2);
        return DateTimeRange(start: start, end: today);
      case DateRangePreset.last6Months:
        final start = DateTime(now.year, now.month - 5);
        return DateTimeRange(start: start, end: today);
      case DateRangePreset.thisYear:
        final startOfYear = DateTime(now.year);
        return DateTimeRange(start: startOfYear, end: today);
      case DateRangePreset.lastYear:
        final startOfLastYear = DateTime(now.year - 1);
        final endOfLastYear = DateTime(now.year - 1, 12, 31);
        return DateTimeRange(start: startOfLastYear, end: endOfLastYear);
      case DateRangePreset.allTime:
        final veryOldDate = DateTime(2000);
        return DateTimeRange(start: veryOldDate, end: today);
      case DateRangePreset.custom:
        final startOfMonth = DateTime(now.year, now.month);
        return DateTimeRange(start: startOfMonth, end: today);
    }
  }
}

double _parseDouble(value) {
  if (value == null) {
    return 0;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0;
}

Color _parseColor(value) {
  if (value == null) {
    return const Color(0xFF10B981);
  }
  if (value is Color) {
    return value;
  }
  if (value is String) {
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
  }
  return const Color(0xFF10B981);
}
