import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/accounts/data/datasources/accounts_remote_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/budgets/data/datasources/budgets_remote_datasource.dart';
import '../../features/budgets/data/repositories/budgets_repository_impl.dart';
import '../../features/budgets/domain/repositories/budgets_repository.dart';
import '../../features/categories/data/datasources/categories_remote_datasource.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/family/data/datasources/family_remote_datasource.dart';
import '../../features/family/data/repositories/family_repository_impl.dart';
import '../../features/family/domain/repositories/family_repository.dart';
import '../../features/goals/data/datasources/goals_remote_datasource.dart';
import '../../features/goals/data/repositories/goals_repository_impl.dart';
import '../../features/goals/domain/repositories/goals_repository.dart';
import '../../features/insights/data/datasources/insights_remote_datasource.dart';
import '../../features/insights/data/repositories/insights_repository_impl.dart';
import '../../features/insights/domain/repositories/insights_repository.dart';
import '../../features/investments/data/datasources/investments_remote_datasource.dart';
import '../../features/investments/data/repositories/investments_repository_impl.dart';
import '../../features/investments/domain/repositories/investments_repository.dart';
import '../../features/loans/data/datasources/loans_remote_datasource.dart';
import '../../features/loans/data/repositories/loans_repository_impl.dart';
import '../../features/loans/domain/repositories/loans_repository.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/subscription/data/datasources/subscription_remote_datasource.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/transactions/data/datasources/transactions_remote_datasource.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';
import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External Dependencies
  await _registerExternalDependencies();

  // Core
  _registerCore();

  // Data Sources
  _registerDataSources();

  // Repositories
  _registerRepositories();
}

Future<void> _registerExternalDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // FlutterSecureStorage
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // Connectivity
  getIt.registerSingleton<Connectivity>(Connectivity());

  // Hive Boxes
  final settingsBox = await Hive.openBox('settings');
  getIt.registerSingleton<Box>(settingsBox, instanceName: 'settingsBox');

  final cacheBox = await Hive.openBox('cache');
  getIt.registerSingleton<Box>(cacheBox, instanceName: 'cacheBox');
}

void _registerCore() {
  // Secure Storage Service
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt<FlutterSecureStorage>()),
  );

  // Local Storage Service
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(
      getIt<SharedPreferences>(),
      getIt<Box>(instanceName: 'settingsBox'),
      getIt<Box>(instanceName: 'cacheBox'),
    ),
  );

  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.spendex.in/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
  getIt.registerSingleton<Dio>(dio);

  // Auth Interceptor
  getIt.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(
      getIt<SecureStorageService>(),
      getIt<Dio>(),
    ),
  );

  // Add interceptor to Dio
  dio.interceptors.add(getIt<AuthInterceptor>());

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>()),
  );
}

void _registerDataSources() {
  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Accounts
  getIt.registerLazySingleton<AccountsRemoteDataSource>(
    () => AccountsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Transactions
  getIt.registerLazySingleton<TransactionsRemoteDataSource>(
    () => TransactionsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Categories
  getIt.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Budgets
  getIt.registerLazySingleton<BudgetsRemoteDataSource>(
    () => BudgetsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Goals
  getIt.registerLazySingleton<GoalsRemoteDataSource>(
    () => GoalsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Loans
  getIt.registerLazySingleton<LoansRemoteDataSource>(
    () => LoansRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Investments
  getIt.registerLazySingleton<InvestmentsRemoteDataSource>(
    () => InvestmentsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Insights
  getIt.registerLazySingleton<InsightsRemoteDataSource>(
    () => InsightsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Subscription
  getIt.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Family
  getIt.registerLazySingleton<FamilyRemoteDataSource>(
    () => FamilyRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Notifications
  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(getIt<ApiClient>()),
  );
}

void _registerRepositories() {
  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<SecureStorageService>(),
    ),
  );

  // Accounts
  getIt.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(getIt<AccountsRemoteDataSource>()),
  );

  // Transactions
  getIt.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(getIt<TransactionsRemoteDataSource>()),
  );

  // Categories
  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(getIt<CategoriesRemoteDataSource>()),
  );

  // Budgets
  getIt.registerLazySingleton<BudgetsRepository>(
    () => BudgetsRepositoryImpl(getIt<BudgetsRemoteDataSource>()),
  );

  // Goals
  getIt.registerLazySingleton<GoalsRepository>(
    () => GoalsRepositoryImpl(getIt<GoalsRemoteDataSource>()),
  );

  // Loans
  getIt.registerLazySingleton<LoansRepository>(
    () => LoansRepositoryImpl(getIt<LoansRemoteDataSource>()),
  );

  // Investments
  getIt.registerLazySingleton<InvestmentsRepository>(
    () => InvestmentsRepositoryImpl(getIt<InvestmentsRemoteDataSource>()),
  );

  // Insights
  getIt.registerLazySingleton<InsightsRepository>(
    () => InsightsRepositoryImpl(getIt<InsightsRemoteDataSource>()),
  );

  // Subscription
  getIt.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(getIt<SubscriptionRemoteDataSource>()),
  );

  // Family
  getIt.registerLazySingleton<FamilyRepository>(
    () => FamilyRepositoryImpl(getIt<FamilyRemoteDataSource>()),
  );

  // Notifications
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<NotificationsRemoteDataSource>()),
  );
}
