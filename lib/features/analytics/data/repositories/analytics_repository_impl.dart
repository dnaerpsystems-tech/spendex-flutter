import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_remote_datasource.dart';
import '../models/analytics_summary_model.dart';
import '../models/category_breakdown_model.dart';
import '../models/daily_stats_model.dart';
import '../models/monthly_stats_model.dart';
import '../models/net_worth_model.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._remoteDataSource);

  final AnalyticsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AnalyticsSummaryModel>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) => _remoteDataSource.getAnalyticsSummary(startDate: startDate, endDate: endDate);

  @override
  Future<Either<Failure, CategoryBreakdownResponse>> getIncomeBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) => _remoteDataSource.getIncomeBreakdown(startDate: startDate, endDate: endDate);

  @override
  Future<Either<Failure, CategoryBreakdownResponse>> getExpenseBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) => _remoteDataSource.getExpenseBreakdown(startDate: startDate, endDate: endDate);

  @override
  Future<Either<Failure, DailyStatsResponse>> getDailyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) => _remoteDataSource.getDailyStats(startDate: startDate, endDate: endDate);

  @override
  Future<Either<Failure, MonthlyStatsResponse>> getMonthlyStats({int? months}) =>
      _remoteDataSource.getMonthlyStats(months: months);

  @override
  Future<Either<Failure, NetWorthResponse>> getNetWorthHistory({int? months}) =>
      _remoteDataSource.getNetWorthHistory(months: months);

  @override
  Future<Either<Failure, String>> exportAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  }) => _remoteDataSource.exportAnalytics(startDate: startDate, endDate: endDate, format: format);
}
