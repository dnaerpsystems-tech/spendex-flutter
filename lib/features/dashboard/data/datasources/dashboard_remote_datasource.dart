import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../transactions/data/models/transaction_model.dart';

/// Dashboard Remote DataSource Interface
abstract class DashboardRemoteDataSource {
  /// Get accounts summary (totals, net worth, etc.)
  Future<Either<Failure, AccountsSummary>> getAccountsSummary();

  /// Get monthly transaction stats for a date range
  Future<Either<Failure, TransactionStats>> getMonthlyStats({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get recent transactions
  Future<Either<Failure, List<TransactionModel>>> getRecentTransactions({
    int limit = 5,
  });

  /// Get active budgets
  Future<Either<Failure, List<BudgetModel>>> getActiveBudgets();
}

/// Dashboard Remote DataSource Implementation
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, AccountsSummary>> getAccountsSummary() async {
    return _apiClient.get<AccountsSummary>(
      ApiEndpoints.accountsSummary,
      fromJson: (json) => AccountsSummary.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, TransactionStats>> getMonthlyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queryParams = <String, dynamic>{
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };

    return _apiClient.get<TransactionStats>(
      ApiEndpoints.transactionsStats,
      queryParameters: queryParams,
      fromJson: (json) => TransactionStats.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getRecentTransactions({
    int limit = 5,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit.toString(),
    };

    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.transactions,
      queryParameters: queryParams,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          final items = (data['data'] as List?)
                  ?.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];
          return Right(items);
        }
        if (data is List) {
          final transactions =
              data.map((json) => TransactionModel.fromJson(json as Map<String, dynamic>)).toList();
          return Right(transactions);
        }
        return const Right([]);
      },
    );
  }

  @override
  Future<Either<Failure, List<BudgetModel>>> getActiveBudgets() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.budgets,
    );

    return result.fold(
      Left.new,
      (data) {
        final budgets = data
            .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
            .where((budget) => budget.isActive)
            .toList();
        return Right(budgets);
      },
    );
  }
}
