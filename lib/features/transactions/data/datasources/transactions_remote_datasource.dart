import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/transaction_model.dart';

/// Transactions Remote DataSource Interface
abstract class TransactionsRemoteDataSource {
  Future<Either<Failure, PaginatedResponse<TransactionModel>>> getTransactions({
    TransactionFilter? filter,
    int? page,
    int? limit,
  });
  Future<Either<Failure, TransactionStats>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, TransactionModel>> getTransactionById(String id);
  Future<Either<Failure, TransactionModel>> createTransaction(CreateTransactionRequest request);
  Future<Either<Failure, TransactionModel>> updateTransaction(String id, CreateTransactionRequest request);
  Future<Either<Failure, void>> deleteTransaction(String id);
}

/// Transactions Remote DataSource Implementation
class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  TransactionsRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, PaginatedResponse<TransactionModel>>> getTransactions({
    TransactionFilter? filter,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{
      if (page != null) 'page': page.toString(),
      if (limit != null) 'limit': limit.toString(),
      ...?filter?.toQueryParams(),
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
              .toList() ?? [];
          final meta = data['meta'] as Map<String, dynamic>?;
          return Right(PaginatedResponse<TransactionModel>(
            data: items,
            page: meta?['page'] as int? ?? 1,
            limit: meta?['limit'] as int? ?? 20,
            total: meta?['total'] as int? ?? items.length,
            totalPages: meta?['totalPages'] as int? ?? 1,
          ));
        }
        return Right(PaginatedResponse<TransactionModel>(
          data: [],
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
        ));
      },
    );
  }

  @override
  Future<Either<Failure, TransactionStats>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    return _apiClient.get<TransactionStats>(
      ApiEndpoints.transactionsStats,
      queryParameters: queryParams,
      fromJson: (json) => TransactionStats.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<DailyTotal>>> getDailyTotals({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate.toIso8601String(),
    };

    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.transactionsDaily,
      queryParameters: queryParams,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is List) {
          return Right(data.map((e) => DailyTotal.fromJson(e as Map<String, dynamic>)).toList());
        }
        if (data is Map<String, dynamic> && data['data'] is List) {
          return Right((data['data'] as List).map((e) => DailyTotal.fromJson(e as Map<String, dynamic>)).toList());
        }
        return const Right([]);
      },
    );
  }

  @override
  Future<Either<Failure, TransactionModel>> getTransactionById(String id) async {
    return _apiClient.get<TransactionModel>(
      ApiEndpoints.transactionById(id),
      fromJson: (json) => TransactionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, TransactionModel>> createTransaction(CreateTransactionRequest request) async {
    return _apiClient.post<TransactionModel>(
      ApiEndpoints.transactions,
      data: request.toJson(),
      fromJson: (json) => TransactionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, TransactionModel>> updateTransaction(String id, CreateTransactionRequest request) async {
    return _apiClient.put<TransactionModel>(
      ApiEndpoints.transactionById(id),
      data: request.toJson(),
      fromJson: (json) => TransactionModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    final result = await _apiClient.delete(ApiEndpoints.transactionById(id));
    return result.fold(Left.new, (_) => const Right(null));
  }
}
