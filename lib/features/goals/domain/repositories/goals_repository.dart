import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/goal_model.dart';

/// Repository interface for Goals feature.
///
/// Defines all operations for managing savings goals including CRUD operations,
/// contributions, and summary statistics.
abstract class GoalsRepository {
  /// Retrieves all goals for the current user.
  Future<Either<Failure, List<GoalModel>>> getGoals();

  /// Retrieves summary statistics for all goals.
  Future<Either<Failure, GoalsSummary>> getGoalsSummary();

  /// Retrieves a specific goal by ID.
  Future<Either<Failure, GoalModel>> getGoalById(String id);

  /// Creates a new savings goal.
  Future<Either<Failure, GoalModel>> createGoal(CreateGoalRequest request);

  /// Updates an existing goal.
  Future<Either<Failure, GoalModel>> updateGoal(
    String id,
    CreateGoalRequest request,
  );

  /// Deletes a goal permanently.
  Future<Either<Failure, void>> deleteGoal(String id);

  /// Adds a contribution to a goal.
  Future<Either<Failure, GoalModel>> addContribution(
    String id,
    int amount,
    String? notes,
  );
}
