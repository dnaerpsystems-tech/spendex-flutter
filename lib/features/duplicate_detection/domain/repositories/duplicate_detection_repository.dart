import 'package:dartz/dartz.dart';
import 'package:spendex/core/errors/failures.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_config.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_result.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';

/// Repository interface for duplicate detection operations
abstract class DuplicateDetectionRepository {
  /// Detect potential duplicates for a list of transactions
  ///
  /// Checks the provided [transactions] against existing transactions in the database
  /// and returns matches that exceed the confidence threshold.
  ///
  /// Parameters:
  /// - [transactions]: List of imported transactions to check for duplicates
  /// - [config]: Optional configuration for detection algorithm
  ///
  /// Returns:
  /// - [DuplicateDetectionResult] containing unique transactions and duplicate matches
  /// - [Failure] if the detection process fails
  Future<Either<Failure, DuplicateDetectionResult>> detectDuplicates({
    required List<ParsedTransactionModel> transactions,
    DuplicateDetectionConfig? config,
  });

  /// Resolve duplicates and import transactions
  ///
  /// Submits user's resolution decisions for detected duplicates and imports
  /// transactions according to those decisions.
  ///
  /// Parameters:
  /// - [importId]: Unique identifier for this import batch
  /// - [resolutions]: Map of duplicate match ID to resolution action
  /// - [uniqueTransactions]: List of transactions with no duplicates to import
  ///
  /// Returns:
  /// - [bool] true if resolutions were successfully applied and transactions imported
  /// - [Failure] if the resolution process fails
  Future<Either<Failure, bool>> resolveDuplicates({
    required String importId,
    required Map<String, DuplicateResolutionAction> resolutions,
    required List<ParsedTransactionModel> uniqueTransactions,
  });

  /// Get duplicate detection statistics
  ///
  /// Retrieves statistics about duplicate detection for a specific import or time period.
  ///
  /// Parameters:
  /// - [importId]: Optional import ID to get stats for a specific import
  /// - [startDate]: Optional start date for time-based stats
  /// - [endDate]: Optional end date for time-based stats
  ///
  /// Returns:
  /// - [DuplicateDetectionStats] containing statistics
  /// - [Failure] if the request fails
  Future<Either<Failure, DuplicateDetectionStats>> getStats({
    String? importId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
