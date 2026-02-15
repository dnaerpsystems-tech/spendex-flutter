import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';

/// Conflict resolution strategies
enum ConflictResolution {
  /// Keep local version
  keepLocal,

  /// Keep server version
  keepServer,

  /// Merge both versions (server wins for conflicting fields)
  merge,
}

/// Abstract interface for sync operations
abstract class SyncService {
  /// Initialize the sync service
  Future<void> initialize();

  /// Stream of sync progress updates
  Stream<SyncProgress> get syncProgress;

  /// Sync all pending changes
  Future<SyncResult> syncAll();

  /// Sync a specific entity type
  Future<SyncResult> syncEntityType(String entityType);

  /// Queue a mutation for sync
  Future<void> queueMutation(PendingMutation mutation);

  /// Get all pending mutations
  Future<List<PendingMutation>> getPendingMutations();

  /// Get pending mutations for a specific entity type
  Future<List<PendingMutation>> getPendingMutationsForType(String entityType);

  /// Resolve a sync conflict
  Future<void> resolveConflict(String entityId, ConflictResolution resolution);

  /// Clear all pending mutations
  Future<void> clearPendingMutations();

  /// Remove a specific mutation
  Future<void> removeMutation(String mutationId);

  /// Check if currently syncing
  bool get isSyncing;

  /// Get last sync time
  DateTime? get lastSyncTime;

  /// Get pending mutations count
  int get pendingCount;

  /// Dispose resources
  void dispose();
}

/// Implementation of SyncService
class SyncServiceImpl implements SyncService {
  SyncServiceImpl({
    required this.cacheService,
    required this.connectivityService,
  });

  final CacheService cacheService;
  final ConnectivityService connectivityService;

  Box<String>? _mutationsBox;
  Box<String>? _metadataBox;

  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  List<PendingMutation> _pendingMutations = [];

  // Sync handlers for different entity types
  final Map<String, Future<SyncResult> Function(List<PendingMutation>)> _syncHandlers = {};

  @override
  Future<void> initialize() async {
    _mutationsBox = await Hive.openBox<String>('pending_mutations_box');
    _metadataBox = await Hive.openBox<String>('sync_metadata_box');

    // Load last sync time
    final lastSyncStr = _metadataBox?.get('last_sync_time');
    if (lastSyncStr != null) {
      _lastSyncTime = DateTime.tryParse(lastSyncStr);
    }

    // Load pending mutations
    await _loadPendingMutations();

    // Listen for connectivity changes to trigger sync
    connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline && _pendingMutations.isNotEmpty) {
        syncAll();
      }
    });
  }

  Future<void> _loadPendingMutations() async {
    _pendingMutations = [];
    for (final key in _mutationsBox?.keys ?? []) {
      final jsonStr = _mutationsBox?.get(key.toString());
      if (jsonStr != null) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          _pendingMutations.add(PendingMutation.fromJson(json));
        } catch (_) {
          // Skip invalid entries
        }
      }
    }
    // Sort by creation time
    _pendingMutations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Stream<SyncProgress> get syncProgress => _syncProgressController.stream;

  @override
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult.empty();
    }

    final isOnline = await connectivityService.isOnline;
    if (!isOnline) {
      return SyncResult.failed('No internet connection');
    }

    _isSyncing = true;
    final startTime = DateTime.now();
    var result = SyncResult.empty();

    try {
      _emitProgress(SyncPhase.starting, 0, _pendingMutations.length);

      // Group mutations by entity type
      final mutationsByType = <String, List<PendingMutation>>{};
      for (final mutation in _pendingMutations) {
        mutationsByType.putIfAbsent(mutation.entityType, () => []).add(mutation);
      }

      // Process each entity type
      var processed = 0;
      for (final entry in mutationsByType.entries) {
        _emitProgress(
          SyncPhase.uploading,
          processed,
          _pendingMutations.length,
          entityType: entry.key,
        );

        final typeResult = await _syncMutations(entry.key, entry.value);
        result = result.combine(typeResult);
        processed += entry.value.length;
      }

      // Download latest data
      _emitProgress(SyncPhase.downloading, 0, 1);
      // Note: Download logic would be implemented per entity type

      // Handle conflicts
      if (result.conflicts.isNotEmpty) {
        _emitProgress(SyncPhase.resolvingConflicts, 0, result.conflicts.length);
      }

      // Finalize
      _emitProgress(SyncPhase.finalizing, 0, 1);

      _lastSyncTime = DateTime.now();
      await _metadataBox?.put('last_sync_time', _lastSyncTime!.toIso8601String());

      final duration = DateTime.now().difference(startTime);
      result = SyncResult(
        uploaded: result.uploaded,
        downloaded: result.downloaded,
        conflictCount: result.conflictCount,
        errors: result.errors,
        duration: duration,
        syncedAt: _lastSyncTime!,
        conflicts: result.conflicts,
        errorMessages: result.errorMessages,
      );

      _emitProgress(SyncPhase.complete, result.totalSynced, result.totalSynced);
    } catch (e) {
      result = SyncResult.failed(e.toString());
      _emitProgress(SyncPhase.failed, 0, 0, message: e.toString());
    } finally {
      _isSyncing = false;
    }

    return result;
  }

  Future<SyncResult> _syncMutations(String entityType, List<PendingMutation> mutations) async {
    var uploaded = 0;
    var errors = 0;
    final errorMessages = <String>[];

    for (final mutation in mutations) {
      try {
        // Check if a custom handler exists for this entity type
        final handler = _syncHandlers[entityType];
        if (handler != null) {
          await handler([mutation]);
        }

        // Remove successful mutation
        await removeMutation(mutation.id);
        uploaded++;
      } catch (e) {
        // Update mutation with error
        final updatedMutation = mutation.copyWith(
          retryCount: mutation.retryCount + 1,
          errorMessage: e.toString(),
          lastAttemptAt: DateTime.now(),
        );
        await _saveMutation(updatedMutation);
        errors++;
        errorMessages.add('${mutation.entityType}/${mutation.entityId}: $e');
      }
    }

    return SyncResult(
      uploaded: uploaded,
      downloaded: 0,
      conflictCount: 0,
      errors: errors,
      duration: Duration.zero,
      syncedAt: DateTime.now(),
      errorMessages: errorMessages,
    );
  }

  @override
  Future<SyncResult> syncEntityType(String entityType) async {
    final mutations = _pendingMutations.where((m) => m.entityType == entityType).toList();

    if (mutations.isEmpty) {
      return SyncResult.empty();
    }

    return _syncMutations(entityType, mutations);
  }

  @override
  Future<void> queueMutation(PendingMutation mutation) async {
    await _saveMutation(mutation);
    _pendingMutations.add(mutation);

    // Try to sync immediately if online
    final isOnline = await connectivityService.isOnline;
    if (isOnline) {
      unawaited(syncAll());
    }
  }

  Future<void> _saveMutation(PendingMutation mutation) async {
    await _mutationsBox?.put(mutation.id, jsonEncode(mutation.toJson()));
  }

  @override
  Future<List<PendingMutation>> getPendingMutations() async {
    return List.unmodifiable(_pendingMutations);
  }

  @override
  Future<List<PendingMutation>> getPendingMutationsForType(String entityType) async {
    return _pendingMutations.where((m) => m.entityType == entityType).toList();
  }

  @override
  Future<void> resolveConflict(String entityId, ConflictResolution resolution) async {
    // Find the mutation with conflict
    final index = _pendingMutations.indexWhere((m) => m.entityId == entityId);
    if (index == -1) {
      return;
    }

    final mutation = _pendingMutations[index];

    switch (resolution) {
      case ConflictResolution.keepLocal:
        // Force push local version
        final updatedMutation = mutation.copyWith(
          retryCount: 0,
        );
        await _saveMutation(updatedMutation);
        _pendingMutations[index] = updatedMutation;
        break;

      case ConflictResolution.keepServer:
        // Discard local changes
        await removeMutation(mutation.id);
        // Fetch server version
        // Note: This would need to be implemented per entity type
        break;

      case ConflictResolution.merge:
        // Merge strategy - typically handled by specific merge logic
        break;
    }
  }

  @override
  Future<void> clearPendingMutations() async {
    await _mutationsBox?.clear();
    _pendingMutations.clear();
  }

  @override
  Future<void> removeMutation(String mutationId) async {
    await _mutationsBox?.delete(mutationId);
    _pendingMutations.removeWhere((m) => m.id == mutationId);
  }

  @override
  bool get isSyncing => _isSyncing;

  @override
  DateTime? get lastSyncTime => _lastSyncTime;

  @override
  int get pendingCount => _pendingMutations.length;

  void _emitProgress(
    SyncPhase phase,
    int current,
    int total, {
    String? entityType,
    String? message,
  }) {
    _syncProgressController.add(
      SyncProgress(
        phase: phase,
        current: current,
        total: total,
        entityType: entityType,
        message: message,
      ),
    );
  }

  /// Register a sync handler for an entity type
  void registerSyncHandler(
    String entityType,
    Future<SyncResult> Function(List<PendingMutation>) handler,
  ) {
    _syncHandlers[entityType] = handler;
  }

  @override
  void dispose() {
    _syncProgressController.close();
  }
}
