import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/goals_repository.dart';
import '../datasources/goals_remote_datasource.dart';
import '../models/goal_model.dart';

/// Goals Repository Implementation
class GoalsRepositoryImpl implements GoalsRepository {

  GoalsRepositoryImpl(this._remoteDataSource);
  final GoalsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<GoalModel>>> getGoals() {
    return _remoteDataSource.getGoals();
  }

  @override
  Future<Either<Failure, GoalsSummary>> getGoalsSummary() {
    return _remoteDataSource.getGoalsSummary();
  }

  @override
  Future<Either<Failure, GoalModel>> getGoalById(String id) {
    return _remoteDataSource.getGoalById(id);
  }

  @override
  Future<Either<Failure, GoalModel>> createGoal(CreateGoalRequest request) {
    return _remoteDataSource.createGoal(request);
  }

  @override
  Future<Either<Failure, GoalModel>> updateGoal(String id, CreateGoalRequest request) {
    return _remoteDataSource.updateGoal(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteGoal(String id) {
    return _remoteDataSource.deleteGoal(id);
  }

  @override
  Future<Either<Failure, GoalModel>> addContribution(String id, int amount, String? notes) {
    return _remoteDataSource.addContribution(id, amount, notes);
  }
}
