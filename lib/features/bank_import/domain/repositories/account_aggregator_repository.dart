import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/aa_consent_model.dart';
import '../../data/models/parsed_transaction_model.dart';

abstract class AccountAggregatorRepository {
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
