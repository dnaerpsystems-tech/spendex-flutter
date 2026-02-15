import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/aa_consent_model.dart';
import '../models/parsed_transaction_model.dart';

abstract class AccountAggregatorRemoteDataSource {
  Future<Either<Failure, AccountAggregatorConsentModel>> initiateConsent(
    List<String> accountIds,
    DateTimeRange dateRange,
  );

  Future<Either<Failure, AccountAggregatorConsentModel>> getConsentStatus(
    String consentId,
  );

  Future<Either<Failure, List<ParsedTransactionModel>>> fetchAccountData(
    String consentId,
  );

  Future<Either<Failure, bool>> revokeConsent(String consentId);

  Future<Either<Failure, List<String>>> getLinkedAccounts();

  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  );
}

class AccountAggregatorRemoteDataSourceImpl implements AccountAggregatorRemoteDataSource {
  AccountAggregatorRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, AccountAggregatorConsentModel>> initiateConsent(
    List<String> accountIds,
    DateTimeRange dateRange,
  ) async {
    return _apiClient.post<AccountAggregatorConsentModel>(
      '/aa/consent/initiate',
      data: {
        'accountIds': accountIds,
        'startDate': dateRange.start.toIso8601String(),
        'endDate': dateRange.end.toIso8601String(),
      },
      fromJson: (json) => AccountAggregatorConsentModel.fromJson(
        json! as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<Failure, AccountAggregatorConsentModel>> getConsentStatus(
    String consentId,
  ) async {
    return _apiClient.get<AccountAggregatorConsentModel>(
      '/aa/consent/$consentId/status',
      fromJson: (json) => AccountAggregatorConsentModel.fromJson(
        json! as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ParsedTransactionModel>>> fetchAccountData(
    String consentId,
  ) async {
    return _apiClient.post<List<ParsedTransactionModel>>(
      '/aa/data/fetch',
      data: {'consentId': consentId},
      fromJson: (json) {
        final list = json! as List<dynamic>;
        return list
            .map(
              (e) => ParsedTransactionModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> revokeConsent(String consentId) async {
    return _apiClient.post<bool>(
      '/aa/consent/$consentId/revoke',
      fromJson: (json) {
        if (json is bool) {
          return json;
        }
        if (json is Map<String, dynamic>) {
          return json['success'] as bool? ?? false;
        }
        return true;
      },
    );
  }

  @override
  Future<Either<Failure, List<String>>> getLinkedAccounts() async {
    return _apiClient.get<List<String>>(
      '/aa/accounts',
      fromJson: (json) {
        if (json is List<dynamic>) {
          return json.map((e) => e.toString()).toList();
        }
        return [];
      },
    );
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  ) async {
    return _apiClient.post<int>(
      '/transactions/bulk-import',
      data: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'source': 'aa',
      },
      fromJson: (json) {
        if (json is int) {
          return json;
        }
        if (json is Map<String, dynamic>) {
          return (json['count'] as num?)?.toInt() ?? 0;
        }
        return 0;
      },
    );
  }
}
