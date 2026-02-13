import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../transactions/data/models/transaction_model.dart';

/// Dashboard Repository Interface
/// Defines the contract for dashboard data operations
abstract class DashboardRepository {
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
