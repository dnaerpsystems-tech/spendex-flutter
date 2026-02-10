import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/budgets_repository.dart';
import '../datasources/budgets_remote_datasource.dart';
import '../models/budget_model.dart';

/// Budgets Repository Implementation
class BudgetsRepositoryImpl implements BudgetsRepository {
  final BudgetsRemoteDataSource _remoteDataSource;

  BudgetsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<BudgetModel>>> getBudgets() {
    return _remoteDataSource.getBudgets();
  }

  @override
  Future<Either<Failure, BudgetsSummary>> getBudgetsSummary() {
    return _remoteDataSource.getBudgetsSummary();
  }

  @override
  Future<Either<Failure, BudgetModel>> getBudgetById(String id) {
    return _remoteDataSource.getBudgetById(id);
  }

  @override
  Future<Either<Failure, BudgetModel>> createBudget(CreateBudgetRequest request) {
    return _remoteDataSource.createBudget(request);
  }

  @override
  Future<Either<Failure, BudgetModel>> updateBudget(String id, CreateBudgetRequest request) {
    return _remoteDataSource.updateBudget(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String id) {
    return _remoteDataSource.deleteBudget(id);
  }
}
