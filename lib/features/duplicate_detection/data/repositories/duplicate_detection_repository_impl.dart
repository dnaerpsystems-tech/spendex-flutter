import 'package:dartz/dartz.dart';
import 'package:spendex/core/errors/failures.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/data/datasources/duplicate_detection_remote_datasource.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_config.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_result.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';
import 'package:spendex/features/duplicate_detection/domain/repositories/duplicate_detection_repository.dart';

/// Implementation of duplicate detection repository
class DuplicateDetectionRepositoryImpl implements DuplicateDetectionRepository {
  DuplicateDetectionRepositoryImpl(this._remoteDataSource);

  final DuplicateDetectionRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DuplicateDetectionResult>> detectDuplicates({
    required List<ParsedTransactionModel> transactions,
    DuplicateDetectionConfig? config,
  }) async {
    try {
      final result = await _remoteDataSource.checkDuplicates(
        transactions: transactions,
        config: config,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> resolveDuplicates({
    required String importId,
    required Map<String, DuplicateResolutionAction> resolutions,
    required List<ParsedTransactionModel> uniqueTransactions,
  }) async {
    try {
      final result = await _remoteDataSource.submitResolutions(
        importId: importId,
        resolutions: resolutions,
        uniqueTransactions: uniqueTransactions,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, DuplicateDetectionStats>> getStats({
    String? importId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await _remoteDataSource.getStats(
        importId: importId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on Exception catch (e) {
      return Left(_handleException(e));
    }
  }

  /// Handle exceptions and convert to appropriate Failure types
  Failure _handleException(Exception e) {
    final errorMessage = e.toString();

    // Network errors
    if (errorMessage.contains('SocketException') ||
        errorMessage.contains('No internet') ||
        errorMessage.contains('Failed host lookup')) {
      return const NetworkFailure(
        'No internet connection. Please check your network and try again.',
      );
    }

    // Server errors
    if (errorMessage.contains('500') ||
        errorMessage.contains('Server error') ||
        errorMessage.contains('Internal server error')) {
      return const ServerFailure(
        'Server error occurred. Please try again later.',
        code: 'SERVER_ERROR',
      );
    }

    // Authentication errors
    if (errorMessage.contains('401') ||
        errorMessage.contains('Unauthorized') ||
        errorMessage.contains('UNAUTHORIZED')) {
      return const AuthFailure(
        'Your session has expired. Please login again.',
        code: 'UNAUTHORIZED',
      );
    }

    // Validation errors
    if (errorMessage.contains('400') ||
        errorMessage.contains('Bad request') ||
        errorMessage.contains('VALIDATION_ERROR')) {
      return ValidationFailure(
        'Invalid request: $errorMessage',
        code: 'VALIDATION_ERROR',
      );
    }

    // Timeout errors
    if (errorMessage.contains('timeout') || errorMessage.contains('Timeout')) {
      return const NetworkFailure(
        'Request timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }

    // Default to unexpected failure
    return UnexpectedFailure(
      'An unexpected error occurred: $errorMessage',
    );
  }
}
