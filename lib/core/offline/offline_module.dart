import 'package:hive_flutter/hive_flutter.dart';

import 'adapters/adapters.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';

/// Offline module initialization
class OfflineModule {
  OfflineModule._();

  static bool _isInitialized = false;
  static CacheServiceImpl? _cacheService;
  static ConnectivityServiceImpl? _connectivityService;
  static SyncServiceImpl? _syncService;

  /// Initialize the offline module
  ///
  /// This should be called once during app startup, after Hive is initialized.
  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Register Hive adapters
    await _registerAdapters();

    // Initialize services
    _cacheService = CacheServiceImpl();
    await _cacheService!.initialize();

    _connectivityService = ConnectivityServiceImpl();

    _syncService = SyncServiceImpl(
      cacheService: _cacheService!,
      connectivityService: _connectivityService!,
    );
    await _syncService!.initialize();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  static Future<void> _registerAdapters() async {
    // Entity model adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AccountModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(GoalModelAdapter());
    }

    // Enum adapters
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(AccountTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(BudgetPeriodAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(CategoryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(GoalStatusAdapter());
    }

    // Sync adapters
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(PendingMutationAdapter());
    }
    if (!Hive.isAdapterRegistered(101)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(103)) {
      Hive.registerAdapter(SyncStatusAdapter());
    }
  }

  /// Get the cache service instance
  static CacheService get cacheService {
    if (!_isInitialized || _cacheService == null) {
      throw StateError('OfflineModule not initialized. Call initialize() first.');
    }
    return _cacheService!;
  }

  /// Get the connectivity service instance
  static ConnectivityService get connectivityService {
    if (!_isInitialized || _connectivityService == null) {
      throw StateError('OfflineModule not initialized. Call initialize() first.');
    }
    return _connectivityService!;
  }

  /// Get the sync service instance
  static SyncService get syncService {
    if (!_isInitialized || _syncService == null) {
      throw StateError('OfflineModule not initialized. Call initialize() first.');
    }
    return _syncService!;
  }

  /// Check if the module is initialized
  static bool get isInitialized => _isInitialized;

  /// Dispose all resources
  static Future<void> dispose() async {
    _syncService?.dispose();
    _connectivityService?.dispose();
    await _cacheService?.close();

    _syncService = null;
    _connectivityService = null;
    _cacheService = null;
    _isInitialized = false;
  }
}
