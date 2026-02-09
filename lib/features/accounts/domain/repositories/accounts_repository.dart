import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/account_model.dart';

/// Accounts Repository Interface
/// Defines the contract for accounts data operations
abstract class AccountsRepository {
  /// Get all accounts for the current user
  Future<Either<Failure, List<AccountModel>>> getAccounts();

  /// Get accounts summary (totals, net worth, etc.)
  Future<Either<Failure, AccountsSummary>> getAccountsSummary();

  /// Get a specific account by ID
  Future<Either<Failure, AccountModel>> getAccountById(String id);

  /// Create a new account
  Future<Either<Failure, AccountModel>> createAccount(CreateAccountRequest request);

  /// Update an existing account
  Future<Either<Failure, AccountModel>> updateAccount(String id, CreateAccountRequest request);

  /// Delete an account
  Future<Either<Failure, void>> deleteAccount(String id);

  /// Transfer money between accounts
  Future<Either<Failure, void>> transferBetweenAccounts(TransferRequest request);
}
