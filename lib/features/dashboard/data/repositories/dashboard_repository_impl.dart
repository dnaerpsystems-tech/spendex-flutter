import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Dashboard Repository Implementation
class DashboardRepositoryImpl implements DashboardRepository {

  DashboardRepositoryImpl(this._remoteDataSource);
  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AccountsSummary>> getAccountsSummary() {
    return _remoteDataSource.getAccountsSummary();
  }

  @override
  Future<Either<Failure, TransactionStats>> getMonthlyStats({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _remoteDataSource.getMonthlyStats(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getRecentTransactions({
    int limit = 5,
  }) {
    return _remoteDataSource.getRecentTransactions(limit: limit);
  }

  @override
  Future<Either<Failure, List<BudgetModel>>> getActiveBudgets() {
    return _remoteDataSource.getActiveBudgets();
  }
}
