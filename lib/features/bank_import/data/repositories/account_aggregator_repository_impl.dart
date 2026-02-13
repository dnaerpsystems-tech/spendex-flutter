import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/account_aggregator_repository.dart';
import '../datasources/account_aggregator_remote_datasource.dart';
import '../models/aa_consent_model.dart';
import '../models/parsed_transaction_model.dart';

class AccountAggregatorRepositoryImpl implements AccountAggregatorRepository {

  AccountAggregatorRepositoryImpl(this._remoteDataSource);
  final AccountAggregatorRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, AccountAggregatorConsentModel>> initiateConsent(
    List<String> accountIds,
    DateTimeRange dateRange,
  ) async {
    try {
      return await _remoteDataSource.initiateConsent(accountIds, dateRange);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AccountAggregatorConsentModel>> getConsentStatus(
    String consentId,
  ) async {
    try {
      return await _remoteDataSource.getConsentStatus(consentId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParsedTransactionModel>>> fetchAccountData(
    String consentId,
  ) async {
    try {
      return await _remoteDataSource.fetchAccountData(consentId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> revokeConsent(String consentId) async {
    try {
      return await _remoteDataSource.revokeConsent(consentId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getLinkedAccounts() async {
    try {
      return await _remoteDataSource.getLinkedAccounts();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  ) async {
    try {
      return await _remoteDataSource.bulkImportTransactions(transactions);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
