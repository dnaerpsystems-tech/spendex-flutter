import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/budget_model.dart';

/// Budgets Remote Data Source Interface
abstract class BudgetsRemoteDataSource {
  /// Get all budgets
  Future<Either<Failure, List<BudgetModel>>> getBudgets();

  /// Get budgets summary
  Future<Either<Failure, BudgetsSummary>> getBudgetsSummary();

  /// Get a specific budget by ID
  Future<Either<Failure, BudgetModel>> getBudgetById(String id);

  /// Create a new budget
  Future<Either<Failure, BudgetModel>> createBudget(CreateBudgetRequest request);

  /// Update an existing budget
  Future<Either<Failure, BudgetModel>> updateBudget(String id, CreateBudgetRequest request);

  /// Delete a budget
  Future<Either<Failure, void>> deleteBudget(String id);
}

/// Budgets Remote Data Source Implementation
class BudgetsRemoteDataSourceImpl implements BudgetsRemoteDataSource {
  final ApiClient _apiClient;

  BudgetsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Either<Failure, List<BudgetModel>>> getBudgets() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.budgets,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final budgets = (data as List<dynamic>)
            .map((json) => BudgetModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(budgets);
      },
    );
  }

  @override
  Future<Either<Failure, BudgetsSummary>> getBudgetsSummary() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.budgetsSummary,
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final summary = BudgetsSummary.fromJson(data as Map<String, dynamic>);
        return Right(summary);
      },
    );
  }

  @override
  Future<Either<Failure, BudgetModel>> getBudgetById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.budgetById(id),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final budget = BudgetModel.fromJson(data as Map<String, dynamic>);
        return Right(budget);
      },
    );
  }

  @override
  Future<Either<Failure, BudgetModel>> createBudget(CreateBudgetRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.budgets,
      data: request.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final budget = BudgetModel.fromJson(data as Map<String, dynamic>);
        return Right(budget);
      },
    );
  }

  @override
  Future<Either<Failure, BudgetModel>> updateBudget(String id, CreateBudgetRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.budgetById(id),
      data: request.toJson(),
    );

    return result.fold(
      (failure) => Left(failure),
      (data) {
        final budget = BudgetModel.fromJson(data as Map<String, dynamic>);
        return Right(budget);
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.budgetById(id),
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => const Right(null),
    );
  }
}
