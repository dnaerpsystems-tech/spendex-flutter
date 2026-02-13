import 'package:spendex/core/constants/api_endpoints.dart';
import 'package:spendex/core/network/api_client.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_config.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_result.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';

/// Remote data source for duplicate detection API operations
abstract class DuplicateDetectionRemoteDataSource {
  /// Check for duplicates via API
  Future<DuplicateDetectionResult> checkDuplicates({
    required List<ParsedTransactionModel> transactions,
    DuplicateDetectionConfig? config,
  });

  /// Submit resolutions and import transactions
  Future<bool> submitResolutions({
    required String importId,
    required Map<String, DuplicateResolutionAction> resolutions,
    required List<ParsedTransactionModel> uniqueTransactions,
  });

  /// Get duplicate detection statistics
  Future<DuplicateDetectionStats> getStats({
    String? importId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Implementation of duplicate detection remote data source
class DuplicateDetectionRemoteDataSourceImpl
    implements DuplicateDetectionRemoteDataSource {
  DuplicateDetectionRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<DuplicateDetectionResult> checkDuplicates({
    required List<ParsedTransactionModel> transactions,
    DuplicateDetectionConfig? config,
  }) async {
    final requestData = {
      'transactions': transactions.map((t) => t.toJson()).toList(),
      if (config != null) 'config': config.toJson(),
    };

    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.duplicateCheck,
      data: requestData,
      fromJson: (json) => json! as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      DuplicateDetectionResult.fromJson,
    );
  }

  @override
  Future<bool> submitResolutions({
    required String importId,
    required Map<String, DuplicateResolutionAction> resolutions,
    required List<ParsedTransactionModel> uniqueTransactions,
  }) async {
    final requestData = {
      'importId': importId,
      'resolutions': resolutions.map(
        (key, value) => MapEntry(key, value.name),
      ),
      'uniqueTransactions': uniqueTransactions.map((t) => t.toJson()).toList(),
    };

    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.duplicateResolve,
      data: requestData,
      fromJson: (json) => json! as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      (data) => data['success'] as bool? ?? false,
    );
  }

  @override
  Future<DuplicateDetectionStats> getStats({
    String? importId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};

    if (importId != null) {
      queryParams['importId'] = importId;
    }
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.duplicateStats,
      queryParameters: queryParams,
      fromJson: (json) => json! as Map<String, dynamic>,
    );

    return result.fold(
      (failure) => throw Exception(failure.message),
      DuplicateDetectionStats.fromJson,
    );
  }
}
