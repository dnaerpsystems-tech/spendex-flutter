import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/insights_repository.dart';
import '../datasources/insights_remote_datasource.dart';
import '../models/insight_model.dart';

class InsightsRepositoryImpl implements InsightsRepository {

  InsightsRepositoryImpl(this._dataSource);
  final InsightsRemoteDataSource _dataSource;

  @override
  Future<Either<Failure, List<InsightModel>>> getAll() {
    return _dataSource.getAll();
  }

  @override
  Future<Either<Failure, List<InsightModel>>> getDashboardInsights() {
    return _dataSource.getDashboardInsights();
  }

  @override
  Future<Either<Failure, InsightModel>> getById(String id) {
    return _dataSource.getById(id);
  }

  @override
  Future<Either<Failure, List<InsightModel>>> generateInsights(
      CreateInsightRequest request,) {
    return _dataSource.generateInsights(request.toJson());
  }

  @override
  Future<Either<Failure, InsightModel>> markAsRead(String id) {
    return _dataSource.markAsRead(id);
  }

  @override
  Future<Either<Failure, bool>> dismiss(String id) async {
    final result = await _dataSource.dismiss(id);
    return result.fold(
      Left.new,
      (insight) => const Right(true),
    );
  }
}
