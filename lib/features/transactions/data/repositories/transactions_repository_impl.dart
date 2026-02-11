import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';
import '../models/transaction_model.dart';

/// Transactions Repository Implementation
class TransactionsRepositoryImpl implements TransactionsRepository {
  TransactionsRepositoryImpl(this._remoteDataSource);
  final TransactionsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, PaginatedResponse<TransactionModel>>> getTransactions({
    TransactionFilter? filter,
    int? page,
    int? limit,
  }) {
    return _remoteDataSource.getTransactions(
      filter: filter,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Either<Failure, TransactionStats>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _remoteDataSource.getTransactionStats(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _remoteDataSource.getDailyTotals(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Either<Failure, TransactionModel>> getTransactionById(String id) {
    return _remoteDataSource.getTransactionById(id);
  }

  @override
  Future<Either<Failure, TransactionModel>> createTransaction(
    CreateTransactionRequest request,
  ) {
    return _remoteDataSource.createTransaction(request);
  }

  @override
  Future<Either<Failure, TransactionModel>> updateTransaction(
    String id,
    CreateTransactionRequest request,
  ) {
    return _remoteDataSource.updateTransaction(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) {
    return _remoteDataSource.deleteTransaction(id);
  }
}
