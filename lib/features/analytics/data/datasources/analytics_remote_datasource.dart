import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/analytics_summary_model.dart';
import '../models/category_breakdown_model.dart';
import '../models/daily_stats_model.dart';
import '../models/monthly_stats_model.dart';
import '../models/net_worth_model.dart';

abstract class AnalyticsRemoteDataSource {
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

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  AnalyticsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  @override
  Future<Either<Failure, AnalyticsSummaryModel>> getAnalyticsSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsOverview,
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
      },
    );
    return result.fold(Left.new, (data) => Right(AnalyticsSummaryModel.fromJson(data)));
  }

  @override
  Future<Either<Failure, CategoryBreakdownResponse>> getIncomeBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsCategoryBreakdown,
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'type': 'income',
      },
    );
    return result.fold(Left.new, (data) => Right(CategoryBreakdownResponse.fromJson(data)));
  }

  @override
  Future<Either<Failure, CategoryBreakdownResponse>> getExpenseBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsCategoryBreakdown,
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'type': 'expense',
      },
    );
    return result.fold(Left.new, (data) => Right(CategoryBreakdownResponse.fromJson(data)));
  }

  @override
  Future<Either<Failure, DailyStatsResponse>> getDailyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsDailyStats,
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
      },
    );
    return result.fold(Left.new, (data) => Right(DailyStatsResponse.fromJson(data)));
  }

  @override
  Future<Either<Failure, MonthlyStatsResponse>> getMonthlyStats({int? months}) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsMonthlyStats,
      queryParameters: {if (months != null) 'months': months},
    );
    return result.fold(Left.new, (data) => Right(MonthlyStatsResponse.fromJson(data)));
  }

  @override
  Future<Either<Failure, NetWorthResponse>> getNetWorthHistory({int? months}) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsNetWorth,
      queryParameters: {if (months != null) 'months': months},
    );
    return result.fold(Left.new, (data) => Right(NetWorthResponse.fromJson(data)));
  }

  @override
  Future<Either<Failure, String>> exportAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    required String format,
  }) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.analyticsExport,
      queryParameters: {
        'startDate': _formatDate(startDate),
        'endDate': _formatDate(endDate),
        'format': format,
      },
    );
    return result.fold(Left.new, (data) => Right(data['downloadUrl'] as String));
  }
}
