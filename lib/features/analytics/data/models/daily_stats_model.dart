import 'package:equatable/equatable.dart';

class DailyStatsModel extends Equatable {
  const DailyStatsModel({
    required this.date,
    required this.income,
    required this.expense,
    required this.transactionCount,
  });

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) {
    return DailyStatsModel(
      date: DateTime.parse(json['date'] as String),
      income: (json['income'] as num).toInt(),
      expense: (json['expense'] as num).toInt(),
      transactionCount: (json['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  final DateTime date;
  final int income;
  final int expense;
  final int transactionCount;

  double get incomeInRupees => income / 100;
  double get expenseInRupees => expense / 100;
  int get netFlow => income - expense;
  double get netFlowInRupees => netFlow / 100;

  @override
  List<Object?> get props => [date, income, expense, transactionCount];
}

class DailyStatsResponse extends Equatable {
  const DailyStatsResponse({
    required this.stats,
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory DailyStatsResponse.fromJson(Map<String, dynamic> json) {
    return DailyStatsResponse(
      stats: (json['stats'] as List<dynamic>)
          .map((e) => DailyStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalIncome: (json['totalIncome'] as num).toInt(),
      totalExpense: (json['totalExpense'] as num).toInt(),
    );
  }

  final List<DailyStatsModel> stats;
  final DateTime startDate;
  final DateTime endDate;
  final int totalIncome;
  final int totalExpense;

  @override
  List<Object?> get props => [stats, startDate, endDate, totalIncome, totalExpense];
}
