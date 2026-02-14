import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../models/models.dart';
import '../../di/injection.dart';

/// Provider for CacheService
final cacheServiceProvider = Provider<CacheService>((ref) {
  return getIt<CacheService>();
});

/// Provider for ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return getIt<ConnectivityService>();
});

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  return getIt<SyncService>();
});

/// Stream provider for connectivity state
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.onConnectivityChanged;
});

/// Provider for current online status
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isOnline;
});

/// Stream provider for sync progress
final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.syncProgress;
});

/// Provider for sync status
final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  return SyncStatusNotifier(syncService, connectivityService);
});

/// Provider for pending mutations count
final pendingMutationsCountProvider = Provider<int>((ref) {
  final syncState = ref.watch(syncStatusProvider);
  return syncState.pendingCount;
});

/// Provider for last sync time
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.lastSyncTime;
});

/// Sync state for UI
class SyncState {
  const SyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSyncTime,
    this.lastResult,
    this.progress,
    this.error,
  });

  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final DateTime? lastSyncTime;
  final SyncResult? lastResult;
  final SyncProgress? progress;
  final String? error;

  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSyncTime,
    SyncResult? lastResult,
    SyncProgress? progress,
    String? error,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastResult: lastResult ?? this.lastResult,
      progress: progress ?? this.progress,
      error: error ?? this.error,
    );
  }
}

/// State notifier for sync status
class SyncStatusNotifier extends StateNotifier<SyncState> {
  SyncStatusNotifier(this._syncService, this._connectivityService)
      : super(const SyncState()) {
    _initialize();
  }

  final SyncService _syncService;
  final ConnectivityService _connectivityService;

  void _initialize() {
    // Listen to connectivity changes
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      state = state.copyWith(isOnline: isOnline);
      if (isOnline && state.pendingCount > 0) {
        syncAll();
      }
    });

    // Listen to sync progress
    _syncService.syncProgress.listen((progress) {
      state = state.copyWith(
        progress: progress,
        isSyncing: progress.phase != SyncPhase.complete &&
                   progress.phase != SyncPhase.failed,
      );
    });

    // Initialize state
    _updateState();
  }

  Future<void> _updateState() async {
    final isOnline = await _connectivityService.isOnline;
    final pendingMutations = await _syncService.getPendingMutations();

    state = state.copyWith(
      isOnline: isOnline,
      pendingCount: pendingMutations.length,
      lastSyncTime: _syncService.lastSyncTime,
      isSyncing: _syncService.isSyncing,
    );
  }

  /// Trigger a full sync
  Future<SyncResult> syncAll() async {
    if (state.isSyncing) {
      return SyncResult.empty();
    }

    state = state.copyWith(isSyncing: true, error: null);

    try {
      final result = await _syncService.syncAll();

      state = state.copyWith(
        isSyncing: false,
        lastResult: result,
        lastSyncTime: result.syncedAt,
        pendingCount: _syncService.pendingCount,
        error: result.isSuccessful ? null : result.errorMessages.firstOrNull,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
      return SyncResult.failed(e.toString());
    }
  }

  /// Queue a new mutation
  Future<void> queueMutation(PendingMutation mutation) async {
    await _syncService.queueMutation(mutation);
    state = state.copyWith(pendingCount: _syncService.pendingCount);
  }

  /// Clear all pending mutations
  Future<void> clearPendingMutations() async {
    await _syncService.clearPendingMutations();
    state = state.copyWith(pendingCount: 0);
  }

  /// Resolve a conflict
  Future<void> resolveConflict(String entityId, ConflictResolution resolution) async {
    await _syncService.resolveConflict(entityId, resolution);
    await _updateState();
  }
}
