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
  InsightsRemoteDataSourceImpl({
    required ApiClient apiClient,
  }) : _apiClient = apiClient;
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<InsightModel>>> getAll() async {
    try {
      final result = await _apiClient.get('/insights');

      return result.fold(
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as List<dynamic>;
            final insights =
                data.map((json) => InsightModel.fromJson(json as Map<String, dynamic>)).toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insights: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch insights: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<InsightModel>>> getDashboardInsights() async {
    try {
      final result = await _apiClient.get('/insights/dashboard');

      return result.fold(
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as List<dynamic>;
            final insights =
                data.map((json) => InsightModel.fromJson(json as Map<String, dynamic>)).toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse dashboard insights: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch dashboard insights: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> getById(String id) async {
    try {
      final result = await _apiClient.get('/insights/$id');

      return result.fold(
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to fetch insight: $e'),
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
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as List<dynamic>;
            final insights =
                data.map((json) => InsightModel.fromJson(json as Map<String, dynamic>)).toList();
            return Right(insights);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse generated insights: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to generate insights: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> markAsRead(String id) async {
    try {
      final result = await _apiClient.post('/insights/$id/read');

      return result.fold(
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark insight as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, InsightModel>> dismiss(String id) async {
    try {
      final result = await _apiClient.post('/insights/$id/dismiss');

      return result.fold(
        Left.new,
        (response) {
          try {
            final data = (response as Map<String, dynamic>)['data'] as Map<String, dynamic>;
            final insight = InsightModel.fromJson(data);
            return Right(insight);
          } catch (e) {
            return Left(
              ServerFailure('Failed to parse insight: $e'),
            );
          }
        },
      );
    } catch (e) {
      return Left(
        ServerFailure('Failed to dismiss insight: $e'),
      );
    }
  }
}
