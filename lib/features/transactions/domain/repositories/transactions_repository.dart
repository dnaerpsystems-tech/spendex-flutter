import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../data/models/transaction_model.dart';

/// Transactions Repository Interface
/// Defines the contract for transactions data operations
abstract class TransactionsRepository {
  /// Get paginated list of transactions with optional filters
  ///
  /// [filter] - Optional filters to apply (type, account, category, date range, etc.)
  /// [page] - Page number for pagination (1-indexed)
  /// [limit] - Number of transactions per page
  ///
  /// Returns a [PaginatedResponse] containing the list of transactions
  /// and pagination metadata (total, totalPages, hasMore)
  Future<Either<Failure, PaginatedResponse<TransactionModel>>> getTransactions({
    TransactionFilter? filter,
    int? page,
    int? limit,
  });

  /// Get transaction statistics for a given date range
  ///
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  ///
  /// Returns [TransactionStats] containing total income, expense,
  /// net amount, transaction count, and savings rate
  Future<Either<Failure, TransactionStats>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get daily transaction totals for charts and visualizations
  ///
  /// [startDate] - Start of the date range (inclusive)
  /// [endDate] - End of the date range (inclusive)
  ///
  /// Returns a list of [DailyTotal] containing income, expense,
  /// and net amounts for each day in the range
  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get a specific transaction by ID
  ///
  /// [id] - The unique identifier of the transaction
  ///
  /// Returns the [TransactionModel] with full details including
  /// related account and category information
  Future<Either<Failure, TransactionModel>> getTransactionById(String id);

  /// Create a new transaction
  ///
  /// [request] - The transaction details including type, amount,
  /// account, category, and optional metadata
  ///
  /// Returns the created [TransactionModel] with server-generated
  /// fields like id, createdAt, and updatedAt
  Future<Either<Failure, TransactionModel>> createTransaction(
    CreateTransactionRequest request,
  );

  /// Update an existing transaction
  ///
  /// [id] - The unique identifier of the transaction to update
  /// [request] - The updated transaction details
  ///
  /// Returns the updated [TransactionModel] with new values
  /// and updated timestamps
  Future<Either<Failure, TransactionModel>> updateTransaction(
    String id,
    CreateTransactionRequest request,
  );

  /// Delete a transaction
  ///
  /// [id] - The unique identifier of the transaction to delete
  ///
  /// Returns void on success, or a [Failure] if the transaction
  /// cannot be deleted (not found, permission denied, etc.)
  Future<Either<Failure, void>> deleteTransaction(String id);
}
