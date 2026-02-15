import 'package:equatable/equatable.dart';

class MonthlyStatsModel extends Equatable {
  const MonthlyStatsModel({
    required this.year,
    required this.month,
    required this.income,
    required this.expense,
    required this.transactionCount,
    this.monthName,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      income: (json['income'] as num).toInt(),
      expense: (json['expense'] as num).toInt(),
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
      monthName: json['monthName'] as String?,
    );
  }

  final int year;
  final int month;
  final int income;
  final int expense;
  final int transactionCount;
  final String? monthName;

  double get incomeInRupees => income / 100;
  double get expenseInRupees => expense / 100;
  int get netFlow => income - expense;
  double get netFlowInRupees => netFlow / 100;

  String get label {
    if (monthName != null) {
      return monthName!;
    }
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
    return '${months[month - 1]} $year';
  }

  String get shortLabel {
    const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [year, month, income, expense, transactionCount, monthName];
}

class MonthlyStatsResponse extends Equatable {
  const MonthlyStatsResponse({
    required this.stats,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory MonthlyStatsResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsResponse(
      stats: (json['stats'] as List<dynamic>)
          .map((e) => MonthlyStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalIncome: (json['totalIncome'] as num).toInt(),
      totalExpense: (json['totalExpense'] as num).toInt(),
    );
  }

  final List<MonthlyStatsModel> stats;
  final int totalIncome;
  final int totalExpense;

  @override
  List<Object?> get props => [stats, totalIncome, totalExpense];
}
