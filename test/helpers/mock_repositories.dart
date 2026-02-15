import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendex/core/constants/app_constants.dart';
import 'package:spendex/core/errors/failures.dart';
import 'package:spendex/core/network/api_client.dart';
import 'package:spendex/features/accounts/data/models/account_model.dart';
import 'package:spendex/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:spendex/features/auth/data/models/user_model.dart';
import 'package:spendex/features/auth/domain/repositories/auth_repository.dart';
import 'package:spendex/features/subscription/data/models/subscription_model.dart';
import 'package:spendex/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:spendex/features/transactions/data/models/transaction_model.dart';
import 'package:spendex/features/transactions/domain/repositories/transactions_repository.dart';

// ===========================================================================
// Mock Repository Implementations
// ===========================================================================

/// Fully mocked AuthRepository with configurable responses
class MockAuthRepositoryImpl extends Mock implements AuthRepository {}

/// Fully mocked AccountsRepository with configurable responses
class MockAccountsRepositoryImpl extends Mock implements AccountsRepository {}

/// Fully mocked TransactionsRepository with configurable responses
class MockTransactionRepositoryImpl extends Mock implements TransactionsRepository {}

/// Fully mocked SubscriptionRepository with configurable responses
class MockSubscriptionRepositoryImpl extends Mock implements SubscriptionRepository {}

// ===========================================================================
// Repository Setup Helpers
// ===========================================================================

/// Setup AuthRepository mock for login success
void setupAuthLoginSuccess(
  MockAuthRepositoryImpl mock, {
  required String email,
  required String password,
  required AuthResponse response,
}) {
  when(() => mock.login(email, password)).thenAnswer((_) async => Right(response));
}

/// Setup AuthRepository mock for login failure
void setupAuthLoginFailure(
  MockAuthRepositoryImpl mock, {
  required String email,
  required String password,
  required Failure failure,
}) {
  when(() => mock.login(email, password)).thenAnswer((_) async => Left(failure));
}

/// Setup AuthRepository mock for getCurrentUser success
void setupGetCurrentUserSuccess(
  MockAuthRepositoryImpl mock,
  UserModel user,
) {
  when(() => mock.getCurrentUser()).thenAnswer((_) async => Right(user));
}

/// Setup AuthRepository mock for getCurrentUser failure
void setupGetCurrentUserFailure(
  MockAuthRepositoryImpl mock,
  Failure failure,
) {
  when(() => mock.getCurrentUser()).thenAnswer((_) async => Left(failure));
}

/// Setup AccountsRepository mock for getAccounts success
void setupGetAccountsSuccess(
  MockAccountsRepositoryImpl mock,
  List<AccountModel> accounts,
) {
  when(() => mock.getAccounts()).thenAnswer((_) async => Right(accounts));
}

/// Setup AccountsRepository mock for getAccounts failure
void setupGetAccountsFailure(
  MockAccountsRepositoryImpl mock,
  Failure failure,
) {
  when(() => mock.getAccounts()).thenAnswer((_) async => Left(failure));
}

/// Setup TransactionRepository mock for getTransactions success
void setupGetTransactionsSuccess(
  MockTransactionRepositoryImpl mock,
  List<TransactionModel> transactions, {
  Map<String, dynamic>? params,
}) {
  when(() => mock.getTransactions(
        filter: any(named: 'filter'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),).thenAnswer((_) async => Right(PaginatedResponse<TransactionModel>(
        data: transactions,
        total: transactions.length,
        page: 1,
        limit: transactions.length,
        totalPages: 1,
      ),),);
}

/// Setup TransactionRepository mock for getTransactions failure
void setupGetTransactionsFailure(
  MockTransactionRepositoryImpl mock,
  Failure failure,
) {
  when(() => mock.getTransactions(
        filter: any(named: 'filter'),
        page: any(named: 'page'),
        limit: any(named: 'limit'),
      ),).thenAnswer((_) async => Left(failure));
}

/// Setup SubscriptionRepository mock for getCurrentSubscription success
void setupGetSubscriptionSuccess(
  MockSubscriptionRepositoryImpl mock,
  SubscriptionModel subscription,
) {
  when(() => mock.getCurrentSubscription()).thenAnswer((_) async => Right(subscription));
}

/// Setup SubscriptionRepository mock for getCurrentSubscription failure
void setupGetSubscriptionFailure(
  MockSubscriptionRepositoryImpl mock,
  Failure failure,
) {
  when(() => mock.getCurrentSubscription()).thenAnswer((_) async => Left(failure));
}

// ===========================================================================
// Test Data Factories
// ===========================================================================

/// Factory for creating test UserModel
UserModel createTestUser({
  String id = 'user_123',
  String email = 'test@example.com',
  String name = 'Test User',
  String? phone,
  UserRole role = UserRole.member,
  UserStatus status = UserStatus.active,
  UserPreferences? preferences,
  String tenantId = 'tenant_123',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return UserModel(
    id: id,
    email: email,
    name: name,
    phone: phone,
    role: role,
    status: status,
    preferences: preferences ?? const UserPreferences(),
    tenantId: tenantId,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

/// Factory for creating test AuthResponse
AuthResponse createTestAuthResponse({
  String accessToken = 'test_access_token',
  String? refreshToken = 'test_refresh_token',
  UserModel? user,
}) {
  return AuthResponse(
    accessToken: accessToken,
    refreshToken: refreshToken,
    user: user ?? createTestUser(),
  );
}

/// Factory for creating test AccountModel
AccountModel createTestAccount({
  String id = 'acc_123',
  String name = 'Test Account',
  AccountType type = AccountType.savings,
  int balance = 100000,
  String? bankName,
  String? accountNumber,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return AccountModel(
    id: id,
    name: name,
    type: type,
    balance: balance,
    bankName: bankName,
    accountNumber: accountNumber,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

/// Factory for creating test TransactionModel
TransactionModel createTestTransaction({
  String id = 'txn_123',
  int amount = 15000,
  TransactionType type = TransactionType.expense,
  String? categoryId,
  String? accountId,
  String? description,
  DateTime? date,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return TransactionModel(
    id: id,
    amount: amount,
    type: type,
    categoryId: categoryId ?? 'cat_123',
    accountId: accountId ?? 'acc_123',
    description: description ?? 'Test transaction',
    date: date ?? now,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

// ===========================================================================
// Fallback Value Registration
// ===========================================================================

/// Register all repository-related fallback values
void registerRepositoryFallbacks() {
  // Register DateTime fallback
  registerFallbackValue(DateTime.now());
  
  // Register common parameter types
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(<String>[]);
}
