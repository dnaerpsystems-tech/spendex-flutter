import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/account_model.dart';

/// Accounts Remote DataSource Interface
abstract class AccountsRemoteDataSource {
  /// Get all accounts
  Future<Either<Failure, List<AccountModel>>> getAccounts();

  /// Get accounts summary
  Future<Either<Failure, AccountsSummary>> getAccountsSummary();

  /// Get account by ID
  Future<Either<Failure, AccountModel>> getAccountById(String id);

  /// Create account
  Future<Either<Failure, AccountModel>> createAccount(CreateAccountRequest request);

  /// Update account
  Future<Either<Failure, AccountModel>> updateAccount(String id, CreateAccountRequest request);

  /// Delete account
  Future<Either<Failure, void>> deleteAccount(String id);

  /// Transfer between accounts
  Future<Either<Failure, void>> transferBetweenAccounts(TransferRequest request);
}

/// Accounts Remote DataSource Implementation
class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {

  AccountsRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<AccountModel>>> getAccounts() async {
    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.accounts,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is List) {
          final accounts = data
              .map((json) => AccountModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return Right(accounts);
        }
        return const Right([]);
      },
    );
  }

  @override
  Future<Either<Failure, AccountsSummary>> getAccountsSummary() async {
    return _apiClient.get<AccountsSummary>(
      ApiEndpoints.accountsSummary,
      fromJson: (json) => AccountsSummary.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, AccountModel>> getAccountById(String id) async {
    return _apiClient.get<AccountModel>(
      ApiEndpoints.accountById(id),
      fromJson: (json) => AccountModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, AccountModel>> createAccount(CreateAccountRequest request) async {
    return _apiClient.post<AccountModel>(
      ApiEndpoints.accounts,
      data: request.toJson(),
      fromJson: (json) => AccountModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, AccountModel>> updateAccount(
    String id,
    CreateAccountRequest request,
  ) async {
    return _apiClient.put<AccountModel>(
      ApiEndpoints.accountById(id),
      data: request.toJson(),
      fromJson: (json) => AccountModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String id) async {
    final result = await _apiClient.delete(
      ApiEndpoints.accountById(id),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> transferBetweenAccounts(TransferRequest request) async {
    final result = await _apiClient.post(
      ApiEndpoints.accountsTransfer,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }
}
