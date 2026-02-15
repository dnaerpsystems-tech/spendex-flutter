import 'sync_status.dart';

/// Wrapper for cached entities with sync metadata
class CachedEntity<T> {
  CachedEntity({
    required this.id,
    required this.data,
    required this.syncStatus,
    required this.cachedAt,
    this.modifiedAt,
    this.serverUpdatedAt,
    this.version = 1,
  });

  /// Create from JSON
  factory CachedEntity.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return CachedEntity<T>(
      id: json['id'] as String,
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      syncStatus: SyncStatusExtension.fromValue(json['syncStatus'] as String),
      cachedAt: DateTime.parse(json['cachedAt'] as String),
      modifiedAt: json['modifiedAt'] != null ? DateTime.parse(json['modifiedAt'] as String) : null,
      serverUpdatedAt: json['serverUpdatedAt'] != null
          ? DateTime.parse(json['serverUpdatedAt'] as String)
          : null,
      version: json['version'] as int? ?? 1,
    );
  }

  /// Entity ID
  final String id;

  /// The actual entity data
  final T data;

  /// Current sync status
  SyncStatus syncStatus;

  /// When this entity was cached
  final DateTime cachedAt;

  /// When this entity was last modified locally
  DateTime? modifiedAt;

  /// When this entity was last updated on server
  DateTime? serverUpdatedAt;

  /// Version number for optimistic locking
  int version;

  /// Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'id': id,
      'data': toJsonT(data),
      'syncStatus': syncStatus.value,
      'cachedAt': cachedAt.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
      'serverUpdatedAt': serverUpdatedAt?.toIso8601String(),
      'version': version,
    };
  }

  /// Create a copy with updated sync status
  CachedEntity<T> withSyncStatus(SyncStatus status) {
    return CachedEntity<T>(
      id: id,
      data: data,
      syncStatus: status,
      cachedAt: cachedAt,
      modifiedAt: modifiedAt,
      serverUpdatedAt: serverUpdatedAt,
      version: version,
    );
  }

  /// Mark as modified locally
  CachedEntity<T> markAsModified() {
    return CachedEntity<T>(
      id: id,
      data: data,
      syncStatus: SyncStatus.pendingUpload,
      cachedAt: cachedAt,
      modifiedAt: DateTime.now(),
      serverUpdatedAt: serverUpdatedAt,
      version: version + 1,
    );
  }

  /// Mark as synced
  CachedEntity<T> markAsSynced(DateTime serverTime) {
    return CachedEntity<T>(
      id: id,
      data: data,
      syncStatus: SyncStatus.synced,
      cachedAt: cachedAt,
      modifiedAt: modifiedAt,
      serverUpdatedAt: serverTime,
      version: version,
    );
  }

  /// Check if needs sync
  bool get needsSync => syncStatus == SyncStatus.pendingUpload;

  /// Check if has conflict
  bool get hasConflict => syncStatus == SyncStatus.conflict;

  /// Check if is stale (cached more than 1 hour ago)
  bool get isStale {
    return DateTime.now().difference(cachedAt).inHours > 1;
  }
}
