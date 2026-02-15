import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/goal_model.dart';

/// Goals Remote Data Source Interface
abstract class GoalsRemoteDataSource {
  /// Get all goals
  Future<Either<Failure, List<GoalModel>>> getGoals();

  /// Get goals summary
  Future<Either<Failure, GoalsSummary>> getGoalsSummary();

  /// Get a specific goal by ID
  Future<Either<Failure, GoalModel>> getGoalById(String id);

  /// Create a new goal
  Future<Either<Failure, GoalModel>> createGoal(CreateGoalRequest request);

  /// Update an existing goal
  Future<Either<Failure, GoalModel>> updateGoal(String id, CreateGoalRequest request);

  /// Delete a goal
  Future<Either<Failure, void>> deleteGoal(String id);

  /// Add contribution to a goal
  Future<Either<Failure, GoalModel>> addContribution(String id, int amount, String? notes);
}

/// Goals Remote Data Source Implementation
class GoalsRemoteDataSourceImpl implements GoalsRemoteDataSource {
  GoalsRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<GoalModel>>> getGoals() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.goals,
    );

    return result.fold(
      Left.new,
      (data) {
        final goals = data.map((json) => GoalModel.fromJson(json as Map<String, dynamic>)).toList();
        return Right(goals);
      },
    );
  }

  @override
  Future<Either<Failure, GoalsSummary>> getGoalsSummary() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goalsSummary,
    );

    return result.fold(
      Left.new,
      (data) {
        final summary = GoalsSummary.fromJson(data);
        return Right(summary);
      },
    );
  }

  @override
  Future<Either<Failure, GoalModel>> getGoalById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.goalById(id),
    );

    return result.fold(
      Left.new,
      (data) {
        final goal = GoalModel.fromJson(data);
        return Right(goal);
      },
    );
  }

  @override
  Future<Either<Failure, GoalModel>> createGoal(CreateGoalRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.goals,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final goal = GoalModel.fromJson(data);
        return Right(goal);
      },
    );
  }

  @override
  Future<Either<Failure, GoalModel>> updateGoal(String id, CreateGoalRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.goalById(id),
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final goal = GoalModel.fromJson(data);
        return Right(goal);
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.goalById(id),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, GoalModel>> addContribution(String id, int amount, String? notes) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.goalContributions(id),
      data: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
    );

    return result.fold(
      Left.new,
      (data) {
        final goal = GoalModel.fromJson(data);
        return Right(goal);
      },
    );
  }
}
