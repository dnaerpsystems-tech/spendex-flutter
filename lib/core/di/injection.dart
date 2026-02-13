import '../config/environment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/accounts/data/datasources/accounts_remote_datasource.dart';
import '../../features/accounts/data/repositories/accounts_repository_impl.dart';
import '../../features/accounts/domain/repositories/accounts_repository.dart';
import '../../features/analytics/data/datasources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/bank_import/data/datasources/account_aggregator_remote_datasource.dart';
import '../../features/bank_import/data/datasources/india_utils_remote_datasource.dart';
import '../../features/bank_import/data/datasources/pdf_import_remote_datasource.dart';
import '../../features/bank_import/data/datasources/sms_parser_local_datasource.dart';
import '../../features/bank_import/data/datasources/sms_parser_remote_datasource.dart';
import '../../features/bank_import/data/repositories/account_aggregator_repository_impl.dart';
import '../../features/bank_import/data/repositories/india_utils_repository_impl.dart';
import '../../features/bank_import/data/repositories/pdf_import_repository_impl.dart';
import '../../features/bank_import/data/repositories/sms_parser_repository_impl.dart';
import '../../features/bank_import/domain/repositories/account_aggregator_repository.dart';
import '../../features/bank_import/domain/repositories/india_utils_repository.dart';
import '../../features/bank_import/domain/repositories/pdf_import_repository.dart';
import '../../features/bank_import/domain/repositories/sms_parser_repository.dart';
import '../../features/budgets/data/datasources/budgets_remote_datasource.dart';
import '../../features/budgets/data/repositories/budgets_repository_impl.dart';
import '../../features/budgets/domain/repositories/budgets_repository.dart';
import '../../features/categories/data/datasources/categories_remote_datasource.dart';
import '../../features/categories/data/repositories/categories_repository_impl.dart';
import '../../features/categories/domain/repositories/categories_repository.dart';
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/duplicate_detection/data/datasources/duplicate_detection_remote_datasource.dart';
import '../../features/duplicate_detection/data/repositories/duplicate_detection_repository_impl.dart';
import '../../features/duplicate_detection/domain/repositories/duplicate_detection_repository.dart';
import '../../features/email_parser/data/datasources/email_local_datasource.dart';
import '../../features/email_parser/data/datasources/email_remote_datasource.dart';
import '../../features/email_parser/data/repositories/email_parser_repository_impl.dart';
import '../../features/email_parser/domain/repositories/email_parser_repository.dart';
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
import '../../features/settings/data/datasources/settings_remote_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/transactions/data/datasources/transactions_remote_datasource.dart';
import '../../features/transactions/data/repositories/transactions_repository_impl.dart';
import '../../features/transactions/domain/repositories/transactions_repository.dart';

import '../network/api_client.dart';
import '../network/api_interceptor.dart';
import '../network/ssl_pinning.dart';
import '../security/auto_lock_service.dart';
import '../security/pin_service.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External Dependencies
  await _registerExternalDependencies();

  // Core
  _registerCore();

  // Security Services
  _registerSecurityServices();

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
  getIt
    ..registerSingleton<FlutterSecureStorage>(secureStorage)

    // Connectivity
    ..registerSingleton<Connectivity>(Connectivity());

  // Hive Boxes
  final settingsBox = await Hive.openBox<String>('settings');
  getIt.registerSingleton<Box<String>>(settingsBox, instanceName: 'settingsBox');

  final cacheBox = await Hive.openBox<String>('cache');
  getIt.registerSingleton<Box<String>>(cacheBox, instanceName: 'cacheBox');
}

void _registerCore() {
  // Secure Storage Service
  getIt
    ..registerLazySingleton<SecureStorageService>(
      () => SecureStorageService(getIt<FlutterSecureStorage>()),
    )

    // Local Storage Service
    ..registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(
        getIt<SharedPreferences>(),
        getIt<Box<String>>(instanceName: 'settingsBox'),
        getIt<Box<String>>(instanceName: 'cacheBox'),
      ),
    );

  // Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
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

  // Apply SSL Certificate Pinning
  SslPinning.configure(dio);

  // Auth Interceptor - must be added BEFORE LogInterceptor
  // so auth headers appear in logs and are sent with requests
  final authInterceptor = AuthInterceptor(
    getIt<SecureStorageService>(),
    dio,
  );
  getIt.registerSingleton<AuthInterceptor>(authInterceptor);

  dio.interceptors.addAll([
    authInterceptor,
    LogInterceptor(responseBody: true, requestBody: true),
  ]);

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(getIt<Dio>()),
  );
}

/// Register security services (PIN, Auto-Lock).
void _registerSecurityServices() {
  // PIN Service - uses FlutterSecureStorage for secure PIN hash storage
  getIt.registerLazySingleton<PinService>(
    () => PinServiceImpl(getIt<FlutterSecureStorage>()),
  );

  // Auto-Lock Service - uses SharedPreferences for timeout settings
  getIt.registerLazySingleton<AutoLockService>(
    () => AutoLockServiceImpl(getIt<SharedPreferences>()),
  );
}

void _registerDataSources() {
  // Auth
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Accounts
    ..registerLazySingleton<AccountsRemoteDataSource>(
      () => AccountsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Categories
    ..registerLazySingleton<CategoriesRemoteDataSource>(
      () => CategoriesRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Budgets
    ..registerLazySingleton<BudgetsRemoteDataSource>(
      () => BudgetsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Goals
    ..registerLazySingleton<GoalsRemoteDataSource>(
      () => GoalsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Investments
    ..registerLazySingleton<InvestmentsRemoteDataSource>(
      () => InvestmentsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Loans
    ..registerLazySingleton<LoansRemoteDataSource>(
      () => LoansRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Transactions
    ..registerLazySingleton<TransactionsRemoteDataSource>(
      () => TransactionsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Dashboard
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Settings
    ..registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Bank Import - PDF Import
    ..registerLazySingleton<PdfImportRemoteDataSource>(
      () => PdfImportRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Bank Import - SMS Parser
    ..registerLazySingleton<SmsParserRemoteDataSource>(
      () => SmsParserRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<SmsParserLocalDataSource>(
      () => SmsParserLocalDataSourceImpl(getIt<SecureStorageService>()),
    )

    // Bank Import - Account Aggregator
    ..registerLazySingleton<AccountAggregatorRemoteDataSource>(
      () => AccountAggregatorRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Bank Import - India Utils
    ..registerLazySingleton<IndiaUtilsRemoteDataSource>(
      () => IndiaUtilsRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Email Parser
    ..registerLazySingleton<EmailRemoteDataSource>(
      () => EmailRemoteDataSourceImpl(getIt<ApiClient>()),
    )
    ..registerLazySingleton<EmailLocalDataSource>(
      () => EmailLocalDataSourceImpl(getIt<SecureStorageService>()),
    )

    // Duplicate Detection
    ..registerLazySingleton<DuplicateDetectionRemoteDataSource>(
      () => DuplicateDetectionRemoteDataSourceImpl(getIt<ApiClient>()),
    )

    // Insights
    ..registerLazySingleton<InsightsRemoteDataSource>(
      () => InsightsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
    )

    // Analytics
    ..registerLazySingleton<AnalyticsRemoteDataSource>(
      () => AnalyticsRemoteDataSourceImpl(getIt<ApiClient>()),
    );
}

void _registerRepositories() {
  // Auth
  getIt
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<SecureStorageService>(),
      ),
    )

    // Accounts
    ..registerLazySingleton<AccountsRepository>(
      () => AccountsRepositoryImpl(getIt<AccountsRemoteDataSource>()),
    )

    // Categories
    ..registerLazySingleton<CategoriesRepository>(
      () => CategoriesRepositoryImpl(getIt<CategoriesRemoteDataSource>()),
    )

    // Budgets
    ..registerLazySingleton<BudgetsRepository>(
      () => BudgetsRepositoryImpl(getIt<BudgetsRemoteDataSource>()),
    )

    // Goals
    ..registerLazySingleton<GoalsRepository>(
      () => GoalsRepositoryImpl(getIt<GoalsRemoteDataSource>()),
    )

    // Investments
    ..registerLazySingleton<InvestmentsRepository>(
      () => InvestmentsRepositoryImpl(getIt<InvestmentsRemoteDataSource>()),
    )

    // Loans
    ..registerLazySingleton<LoansRepository>(
      () => LoansRepositoryImpl(getIt<LoansRemoteDataSource>()),
    )

    // Transactions
    ..registerLazySingleton<TransactionsRepository>(
      () => TransactionsRepositoryImpl(getIt<TransactionsRemoteDataSource>()),
    )

    // Dashboard
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
    )

    // Settings
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(getIt<SettingsRemoteDataSource>()),
    )

    // Bank Import - PDF Import
    ..registerLazySingleton<PdfImportRepository>(
      () => PdfImportRepositoryImpl(getIt<PdfImportRemoteDataSource>()),
    )

    // Bank Import - SMS Parser
    ..registerLazySingleton<SmsParserRepository>(
      () => SmsParserRepositoryImpl(
        getIt<SmsParserRemoteDataSource>(),
        getIt<SmsParserLocalDataSource>(),
      ),
    )

    // Bank Import - Account Aggregator
    ..registerLazySingleton<AccountAggregatorRepository>(
      () => AccountAggregatorRepositoryImpl(
        getIt<AccountAggregatorRemoteDataSource>(),
      ),
    )

    // Bank Import - India Utils
    ..registerLazySingleton<IndiaUtilsRepository>(
      () => IndiaUtilsRepositoryImpl(getIt<IndiaUtilsRemoteDataSource>()),
    )

    // Email Parser
    ..registerLazySingleton<EmailParserRepository>(
      () => EmailParserRepositoryImpl(
        getIt<EmailRemoteDataSource>(),
        getIt<EmailLocalDataSource>(),
      ),
    )

    // Duplicate Detection
    ..registerLazySingleton<DuplicateDetectionRepository>(
      () => DuplicateDetectionRepositoryImpl(
        getIt<DuplicateDetectionRemoteDataSource>(),
      ),
    )

    // Insights
    ..registerLazySingleton<InsightsRepository>(
      () => InsightsRepositoryImpl(getIt<InsightsRemoteDataSource>()),
    )

    // Analytics
    ..registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(getIt<AnalyticsRemoteDataSource>()),
    );
}
