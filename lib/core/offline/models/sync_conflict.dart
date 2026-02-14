import 'package:equatable/equatable.dart';

/// Represents a sync conflict between local and server data
class SyncConflict extends Equatable {
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.serverData,
    required this.localModifiedAt,
    required this.serverModifiedAt,
    this.conflictingFields = const [],
  });

  /// Create from JSON
  factory SyncConflict.fromJson(Map<String, dynamic> json) {
    return SyncConflict(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      localData: Map<String, dynamic>.from(json['localData'] as Map),
      serverData: Map<String, dynamic>.from(json['serverData'] as Map),
      localModifiedAt: DateTime.parse(json['localModifiedAt'] as String),
      serverModifiedAt: DateTime.parse(json['serverModifiedAt'] as String),
      conflictingFields: (json['conflictingFields'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Entity type (e.g., 'transaction', 'account', etc.)
  final String entityType;

  /// ID of the conflicting entity
  final String entityId;

  /// Local version of the data
  final Map<String, dynamic> localData;

  /// Server version of the data
  final Map<String, dynamic> serverData;

  /// When local version was modified
  final DateTime localModifiedAt;

  /// When server version was modified
  final DateTime serverModifiedAt;

  /// List of fields that have conflicts
  final List<String> conflictingFields;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'entityType': entityType,
      'entityId': entityId,
      'localData': localData,
      'serverData': serverData,
      'localModifiedAt': localModifiedAt.toIso8601String(),
      'serverModifiedAt': serverModifiedAt.toIso8601String(),
      'conflictingFields': conflictingFields,
    };
  }

  /// Check if local is newer
  bool get isLocalNewer => localModifiedAt.isAfter(serverModifiedAt);

  /// Check if server is newer
  bool get isServerNewer => serverModifiedAt.isAfter(localModifiedAt);

  /// Get time difference between versions
  Duration get timeDifference {
    return localModifiedAt.difference(serverModifiedAt).abs();
  }

  /// Get a merged version of data (server-wins for conflicting fields)
  Map<String, dynamic> getMergedData({bool preferServer = true}) {
    final merged = Map<String, dynamic>.from(localData);
    if (preferServer) {
      merged.addAll(serverData);
    }
    return merged;
  }

  @override
  List<Object?> get props => [
        entityType,
        entityId,
        localData,
        serverData,
        localModifiedAt,
        serverModifiedAt,
        conflictingFields,
      ];
}
