import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../errors/failures.dart';
import '../models/models.dart';
import '../services/cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

/// Custom failure for conflict-related errors
class ConflictFailure extends Failure {
  const ConflictFailure(this.conflict) : super('Sync conflict detected');

  final SyncConflict conflict;

  @override
  List<Object?> get props => [conflict, message, code];
}

/// Mixin that provides offline-first capabilities to repositories
mixin OfflineRepositoryMixin<T> {
  /// The cache service for local storage
  CacheService get cacheService;

  /// The sync service for managing mutations
  SyncService get syncService;

  /// The connectivity service for checking online status
  ConnectivityService get connectivityService;

  /// Entity type identifier (e.g., 'transaction', 'account')
  String get entityType;

  /// Box name for caching this entity type
  String get boxName;

  /// Convert entity to JSON for caching
  Map<String, dynamic> toJson(T entity);

  /// Convert JSON to entity
  T fromJson(Map<String, dynamic> json);

  /// Get entity ID from entity
  String getId(T entity);

  /// Get updated timestamp from entity
  DateTime getUpdatedAt(T entity);

  final _uuid = const Uuid();

  /// Get an entity, preferring cache but falling back to API
  Future<Either<Failure, T>> getWithCache(
    String id,
    Future<Either<Failure, T>> Function() fetchFromApi,
  ) async {
    // Try to get from cache first
    final cached = await cacheService.getJson(boxName, id);

    // Check if we're online
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      // Return cached data if offline
      if (cached != null) {
        return Right(fromJson(cached));
      }
      return const Left(CacheFailure('Data not available offline'));
    }

    // Try to fetch from API
    final result = await fetchFromApi();

    return result.fold(
      (failure) {
        // API failed, return cached data if available
        if (cached != null) {
          return Right(fromJson(cached));
        }
        return Left(failure);
      },
      (entity) async {
        // Cache the fresh data
        await _cacheEntity(entity);
        return Right(entity);
      },
    );
  }

  /// Get all entities, preferring cache but syncing with API when online
  Future<Either<Failure, List<T>>> getAllWithCache(
    Future<Either<Failure, List<T>>> Function() fetchFromApi,
  ) async {
    // Check if we're online
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      // Return all cached data if offline
      final cached = await cacheService.getAllJson(boxName);
      if (cached.isNotEmpty) {
        return Right(cached.map(fromJson).toList());
      }
      return const Left(CacheFailure('No cached data available'));
    }

    // Try to fetch from API
    final result = await fetchFromApi();

    return result.fold(
      (failure) async {
        // API failed, return cached data if available
        final cached = await cacheService.getAllJson(boxName);
        if (cached.isNotEmpty) {
          return Right(cached.map(fromJson).toList());
        }
        return Left(failure);
      },
      (entities) async {
        // Cache all fresh data
        await _cacheEntities(entities);
        return Right(entities);
      },
    );
  }

  /// Create an entity with offline support
  Future<Either<Failure, T>> createWithSync(
    T entity,
    Future<Either<Failure, T>> Function() createOnApi,
  ) async {
    final entityId = getId(entity);

    // Check if we're online
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      // Store locally and queue for sync
      await _cacheEntity(entity);
      await cacheService.setSyncStatus(boxName, entityId, SyncStatus.pendingUpload);

      await syncService.queueMutation(
        PendingMutation(
          id: _uuid.v4(),
          entityType: entityType,
          entityId: entityId,
          operation: SyncOperation.create,
          data: toJson(entity),
          createdAt: DateTime.now(),
        ),
      );

      return Right(entity);
    }

    // Try to create on API
    final result = await createOnApi();

    return result.fold(
      (failure) async {
        // API failed, store locally and queue for sync
        await _cacheEntity(entity);
        await cacheService.setSyncStatus(boxName, entityId, SyncStatus.pendingUpload);

        await syncService.queueMutation(
          PendingMutation(
            id: _uuid.v4(),
            entityType: entityType,
            entityId: entityId,
            operation: SyncOperation.create,
            data: toJson(entity),
            createdAt: DateTime.now(),
          ),
        );

        // Return the local entity as if it succeeded
        return Right(entity);
      },
      (serverEntity) async {
        // Cache the server response
        await _cacheEntity(serverEntity);
        await cacheService.setSyncStatus(boxName, getId(serverEntity), SyncStatus.synced);
        return Right(serverEntity);
      },
    );
  }

  /// Update an entity with offline support
  Future<Either<Failure, T>> updateWithSync(
    T entity,
    Future<Either<Failure, T>> Function() updateOnApi,
  ) async {
    final entityId = getId(entity);

    // Check if we're online
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      // Store locally and queue for sync
      await _cacheEntity(entity);
      await cacheService.setSyncStatus(boxName, entityId, SyncStatus.pendingUpload);

      await syncService.queueMutation(
        PendingMutation(
          id: _uuid.v4(),
          entityType: entityType,
          entityId: entityId,
          operation: SyncOperation.update,
          data: toJson(entity),
          createdAt: DateTime.now(),
        ),
      );

      return Right(entity);
    }

    // Try to update on API
    final result = await updateOnApi();

    return result.fold(
      (failure) async {
        // Check if it's a conflict
        if (failure is ConflictFailure) {
          await cacheService.setSyncStatus(boxName, entityId, SyncStatus.conflict);
          return Left(failure);
        }

        // API failed, store locally and queue for sync
        await _cacheEntity(entity);
        await cacheService.setSyncStatus(boxName, entityId, SyncStatus.pendingUpload);

        await syncService.queueMutation(
          PendingMutation(
            id: _uuid.v4(),
            entityType: entityType,
            entityId: entityId,
            operation: SyncOperation.update,
            data: toJson(entity),
            createdAt: DateTime.now(),
          ),
        );

        return Right(entity);
      },
      (serverEntity) async {
        // Cache the server response
        await _cacheEntity(serverEntity);
        await cacheService.setSyncStatus(boxName, getId(serverEntity), SyncStatus.synced);
        return Right(serverEntity);
      },
    );
  }

  /// Delete an entity with offline support
  Future<Either<Failure, void>> deleteWithSync(
    String id,
    Future<Either<Failure, void>> Function() deleteOnApi,
  ) async {
    // Get entity data before deletion for potential rollback
    final cachedEntity = await cacheService.getJson(boxName, id);

    // Check if we're online
    final isOnline = await connectivityService.isOnline;

    if (!isOnline) {
      // Mark as deleted locally and queue for sync
      await cacheService.delete(boxName, id);

      await syncService.queueMutation(
        PendingMutation(
          id: _uuid.v4(),
          entityType: entityType,
          entityId: id,
          operation: SyncOperation.delete,
          data: cachedEntity ?? {},
          createdAt: DateTime.now(),
        ),
      );

      return const Right(null);
    }

    // Try to delete on API
    final result = await deleteOnApi();

    return result.fold(
      (failure) async {
        // API failed, keep locally but queue for sync
        await syncService.queueMutation(
          PendingMutation(
            id: _uuid.v4(),
            entityType: entityType,
            entityId: id,
            operation: SyncOperation.delete,
            data: cachedEntity ?? {},
            createdAt: DateTime.now(),
          ),
        );

        // Still delete locally
        await cacheService.delete(boxName, id);

        return const Right(null);
      },
      (_) async {
        // Delete from cache
        await cacheService.delete(boxName, id);
        return const Right(null);
      },
    );
  }

  /// Cache a single entity
  Future<void> _cacheEntity(T entity) async {
    final id = getId(entity);
    final json = toJson(entity);
    await cacheService.putJson(boxName, id, json);
  }

  /// Cache multiple entities
  Future<void> _cacheEntities(List<T> entities) async {
    for (final entity in entities) {
      await _cacheEntity(entity);
    }
  }

  /// Get all entities that need syncing
  Future<List<T>> getPendingEntities() async {
    final pendingKeys = await cacheService.getKeysBySyncStatus(
      boxName,
      SyncStatus.pendingUpload,
    );

    final entities = <T>[];
    for (final key in pendingKeys) {
      final json = await cacheService.getJson(boxName, key);
      if (json != null) {
        entities.add(fromJson(json));
      }
    }

    return entities;
  }

  /// Check if an entity is cached
  Future<bool> isCached(String id) async {
    return cacheService.containsKey(boxName, id);
  }

  /// Get sync status for an entity
  Future<SyncStatus?> getEntitySyncStatus(String id) async {
    return cacheService.getSyncStatus(boxName, id);
  }

  /// Clear all cached entities
  Future<void> clearCache() async {
    await cacheService.clear(boxName);
  }
}
