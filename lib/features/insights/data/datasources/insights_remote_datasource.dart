import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/insight_model.dart';

/// Abstract class defining the contract for insights remote data source
abstract class InsightsRemoteDataSource {
  /// Fetches all insights
  Future<Either<Failure, List<InsightModel>>> getAll();

  /// Fetches dashboard insights
  Future<Either<Failure, List<InsightModel>>> getDashboardInsights();

  /// Fetches a specific insight by ID
  Future<Either<Failure, InsightModel>> getById(String id);

  /// Generates new insights based on the request
  Future<Either<Failure, List<InsightModel>>> generateInsights(
    Map<String, dynamic> request,
  );

  /// Marks an insight as read
  Future<Either<Failure, InsightModel>> markAsRead(String id);

  /// Dismisses an insight
  Future<Either<Failure, InsightModel>> dismiss(String id);
}

/// Implementation of [InsightsRemoteDataSource] using API client
class InsightsRemoteDataSourceImpl implements InsightsRemoteDataSource {
  final ApiClient _apiClient;

  InsightsRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<Either<Failure, List<InsightModel>>> getAll() async {
    try {
      final result = await _apiClient.get('/insights');

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final List<dynamic> data = response['data'] as List<dynamic>;
            final insights = data
                .map((json) => InsightModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insights: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch insights: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InsightModel>>> getDashboardInsights() async {
    try {
      final result = await _apiClient.get('/insights/dashboard');

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final List<dynamic> data = response['data'] as List<dynamic>;
            final insights = data
                .map((json) => InsightModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse dashboard insights: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch dashboard insights: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> getById(String id) async {
    try {
      final result = await _apiClient.get('/insights/$id');

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final data = response['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch insight: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InsightModel>>> generateInsights(
    Map<String, dynamic> request,
  ) async {
    try {
      final result = await _apiClient.post(
        '/insights/generate',
        data: request,
      );

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final List<dynamic> data = response['data'] as List<dynamic>;
            final insights = data
                .map((json) => InsightModel.fromJson(json as Map<String, dynamic>))
                .toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse generated insights: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to generate insights: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> markAsRead(String id) async {
    try {
      final result = await _apiClient.post('/insights/$id/read');

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final data = response['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark insight as read: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> dismiss(String id) async {
    try {
      final result = await _apiClient.post('/insights/$id/dismiss');

      return result.fold(
        (failure) => Left(failure),
        (response) {
          try {
            final data = response['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: ${e.toString()}'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to dismiss insight: ${e.toString()}'),
      );
    }
  }
}
