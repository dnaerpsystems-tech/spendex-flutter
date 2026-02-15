import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/accounts_repository.dart';
import '../datasources/accounts_remote_datasource.dart';
import '../models/account_model.dart';

/// Accounts Repository Implementation
class AccountsRepositoryImpl implements AccountsRepository {
  AccountsRepositoryImpl(this._remoteDataSource);
  final AccountsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() {
    return _remoteDataSource.getAccounts();
  }

  @override
  Future<Either<Failure, AccountsSummary>> getAccountsSummary() {
    return _remoteDataSource.getAccountsSummary();
  }

  @override
  Future<Either<Failure, AccountModel>> getAccountById(String id) {
    return _remoteDataSource.getAccountById(id);
  }

  @override
  Future<Either<Failure, AccountModel>> createAccount(CreateAccountRequest request) {
    return _remoteDataSource.createAccount(request);
  }

  @override
  Future<Either<Failure, AccountModel>> updateAccount(
    String id,
    CreateAccountRequest request,
  ) {
    return _remoteDataSource.updateAccount(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) {
    return _remoteDataSource.deleteAccount(id);
  }

  @override
  Future<Either<Failure, void>> transferBetweenAccounts(TransferRequest request) {
    return _remoteDataSource.transferBetweenAccounts(request);
  }
}
