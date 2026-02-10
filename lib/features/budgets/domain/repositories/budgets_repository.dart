import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/budget_model.dart';

/// Budgets Repository Interface
/// Defines the contract for budgets data operations
abstract class BudgetsRepository {
  /// Get all budgets for the current user
  Future<Either<Failure, List<BudgetModel>>> getBudgets();

  /// Get budgets summary (totals, overall progress, etc.)
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
