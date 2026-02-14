import 'package:equatable/equatable.dart';
import 'sync_conflict.dart';

/// Result of a sync operation
class SyncResult extends Equatable {
  const SyncResult({
    required this.uploaded,
    required this.downloaded,
    required this.conflictCount,
    required this.errors,
    required this.duration,
    required this.syncedAt,
    this.conflicts = const [],
    this.errorMessages = const [],
  });

  /// Create a successful empty sync result
  factory SyncResult.empty() {
    return SyncResult(
      uploaded: 0,
      downloaded: 0,
      conflictCount: 0,
      errors: 0,
      duration: Duration.zero,
      syncedAt: DateTime.now(),
    );
  }

  /// Create a failed sync result
  factory SyncResult.failed(String errorMessage) {
    return SyncResult(
      uploaded: 0,
      downloaded: 0,
      conflictCount: 0,
      errors: 1,
      duration: Duration.zero,
      syncedAt: DateTime.now(),
      errorMessages: [errorMessage],
    );
  }

  /// Create from JSON
  factory SyncResult.fromJson(Map<String, dynamic> json) {
    return SyncResult(
      uploaded: json['uploaded'] as int,
      downloaded: json['downloaded'] as int,
      conflictCount: json['conflictCount'] as int,
      errors: json['errors'] as int,
      duration: Duration(milliseconds: json['durationMs'] as int),
      syncedAt: DateTime.parse(json['syncedAt'] as String),
      conflicts: (json['conflicts'] as List<dynamic>?)
              ?.map((e) => SyncConflict.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      errorMessages: (json['errorMessages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Number of entities uploaded to server
  final int uploaded;

  /// Number of entities downloaded from server
  final int downloaded;

  /// Number of conflicts detected
  final int conflictCount;

  /// Number of errors encountered
  final int errors;

  /// Duration of the sync operation
  final Duration duration;

  /// When the sync completed
  final DateTime syncedAt;

  /// List of conflicts that need resolution
  final List<SyncConflict> conflicts;

  /// List of error messages
  final List<String> errorMessages;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uploaded': uploaded,
      'downloaded': downloaded,
      'conflictCount': conflictCount,
      'errors': errors,
      'durationMs': duration.inMilliseconds,
      'syncedAt': syncedAt.toIso8601String(),
      'conflicts': conflicts.map((e) => e.toJson()).toList(),
      'errorMessages': errorMessages,
    };
  }

  /// Check if sync was successful
  bool get isSuccessful => errors == 0 && conflictCount == 0;

  /// Check if there were any changes
  bool get hasChanges => uploaded > 0 || downloaded > 0;

  /// Total entities synced
  int get totalSynced => uploaded + downloaded;

  /// Combine with another result
  SyncResult combine(SyncResult other) {
    return SyncResult(
      uploaded: uploaded + other.uploaded,
      downloaded: downloaded + other.downloaded,
      conflictCount: conflictCount + other.conflictCount,
      errors: errors + other.errors,
      duration: duration + other.duration,
      syncedAt: other.syncedAt,
      conflicts: [...conflicts, ...other.conflicts],
      errorMessages: [...errorMessages, ...other.errorMessages],
    );
  }

  @override
  List<Object?> get props => [
        uploaded,
        downloaded,
        conflictCount,
        errors,
        duration,
        syncedAt,
        conflicts,
        errorMessages,
      ];
}

/// Progress of an ongoing sync operation
class SyncProgress extends Equatable {
  const SyncProgress({
    required this.phase,
    required this.current,
    required this.total,
    this.entityType,
    this.message,
  });

  /// Current sync phase
  final SyncPhase phase;

  /// Current progress count
  final int current;

  /// Total items to process
  final int total;

  /// Entity type being synced
  final String? entityType;

  /// Optional progress message
  final String? message;

  /// Progress percentage (0-100)
  double get percentage => total > 0 ? (current / total) * 100 : 0;

  /// Check if complete
  bool get isComplete => current >= total && phase == SyncPhase.complete;

  @override
  List<Object?> get props => [phase, current, total, entityType, message];
}

/// Phases of the sync process
enum SyncPhase {
  /// Starting sync
  starting,
  
  /// Uploading local changes
  uploading,
  
  /// Downloading server changes
  downloading,
  
  /// Resolving conflicts
  resolvingConflicts,
  
  /// Finalizing sync
  finalizing,
  
  /// Sync complete
  complete,
  
  /// Sync failed
  failed,
}

/// Extension for SyncPhase
extension SyncPhaseExtension on SyncPhase {
  String get label {
    switch (this) {
      case SyncPhase.starting:
        return 'Starting sync...';
      case SyncPhase.uploading:
        return 'Uploading changes...';
      case SyncPhase.downloading:
        return 'Downloading updates...';
      case SyncPhase.resolvingConflicts:
        return 'Resolving conflicts...';
      case SyncPhase.finalizing:
        return 'Finalizing...';
      case SyncPhase.complete:
        return 'Sync complete';
      case SyncPhase.failed:
        return 'Sync failed';
    }
  }
}
