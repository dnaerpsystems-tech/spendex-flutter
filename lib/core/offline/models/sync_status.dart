/// Sync status for cached entities
enum SyncStatus {
  /// Entity is synced with server
  synced,

  /// Entity has local changes waiting to upload
  pendingUpload,

  /// Entity has server changes waiting to download
  pendingDownload,

  /// Entity has conflicting changes
  conflict,

  /// Sync failed with error
  error,
}

/// Sync operation types
enum SyncOperation {
  /// Create new entity
  create,

  /// Update existing entity
  update,

  /// Delete entity
  delete,
}

/// Extension for SyncStatus
extension SyncStatusExtension on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'SYNCED';
      case SyncStatus.pendingUpload:
        return 'PENDING_UPLOAD';
      case SyncStatus.pendingDownload:
        return 'PENDING_DOWNLOAD';
      case SyncStatus.conflict:
        return 'CONFLICT';
      case SyncStatus.error:
        return 'ERROR';
    }
  }

  static SyncStatus fromValue(String value) {
    switch (value) {
      case 'SYNCED':
        return SyncStatus.synced;
      case 'PENDING_UPLOAD':
        return SyncStatus.pendingUpload;
      case 'PENDING_DOWNLOAD':
        return SyncStatus.pendingDownload;
      case 'CONFLICT':
        return SyncStatus.conflict;
      case 'ERROR':
        return SyncStatus.error;
      default:
        return SyncStatus.synced;
    }
  }
}

/// Extension for SyncOperation
extension SyncOperationExtension on SyncOperation {
  String get value {
    switch (this) {
      case SyncOperation.create:
        return 'CREATE';
      case SyncOperation.update:
        return 'UPDATE';
      case SyncOperation.delete:
        return 'DELETE';
    }
  }

  static SyncOperation fromValue(String value) {
    switch (value) {
      case 'CREATE':
        return SyncOperation.create;
      case 'UPDATE':
        return SyncOperation.update;
      case 'DELETE':
        return SyncOperation.delete;
      default:
        return SyncOperation.update;
    }
  }
}
