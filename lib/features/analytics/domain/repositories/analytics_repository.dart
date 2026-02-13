import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/analytics_summary_model.dart';
import '../../data/models/category_breakdown_model.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/monthly_stats_model.dart';
import '../../data/models/net_worth_model.dart';

abstract class AnalyticsRepository {
  Future<Either<Failure, AnalyticsSummaryModel>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, CategoryBreakdownResponse>> getIncomeBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, CategoryBreakdownResponse>> getExpenseBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, DailyStatsResponse>> getDailyStats({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, MonthlyStatsResponse>> getMonthlyStats({int? months});

  Future<Either<Failure, NetWorthResponse>> getNetWorthHistory({int? months});

  Future<Either<Failure, String>> exportAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  });
}
