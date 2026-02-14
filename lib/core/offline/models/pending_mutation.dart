import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'sync_status.dart';

part 'pending_mutation.g.dart';

/// Represents a pending mutation that needs to be synced with the server
@HiveType(typeId: 100)
class PendingMutation extends Equatable {
  const PendingMutation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
    this.lastAttemptAt,
  });

  /// Create from JSON
  factory PendingMutation.fromJson(Map<String, dynamic> json) {
    return PendingMutation(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      operation: SyncOperationExtension.fromValue(json['operation'] as String),
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
    );
  }

  /// Unique identifier for this mutation
  @HiveField(0)
  final String id;

  /// Entity type (e.g., 'transaction', 'account', 'budget', etc.)
  @HiveField(1)
  final String entityType;

  /// ID of the entity being mutated
  @HiveField(2)
  final String entityId;

  /// Type of operation (create, update, delete)
  @HiveField(3)
  final SyncOperation operation;

  /// Data payload for the mutation
  @HiveField(4)
  final Map<String, dynamic> data;

  /// When this mutation was created
  @HiveField(5)
  final DateTime createdAt;

  /// Number of retry attempts
  @HiveField(6)
  final int retryCount;

  /// Error message from last failed attempt
  @HiveField(7)
  final String? errorMessage;

  /// When the last sync attempt was made
  @HiveField(8)
  final DateTime? lastAttemptAt;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation.value,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PendingMutation copyWith({
    String? id,
    String? entityType,
    String? entityId,
    SyncOperation? operation,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    int? retryCount,
    String? errorMessage,
    DateTime? lastAttemptAt,
  }) {
    return PendingMutation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
    );
  }

  /// Check if max retries exceeded
  bool get hasExceededMaxRetries => retryCount >= 5;

  @override
  List<Object?> get props => [
        id,
        entityType,
        entityId,
        operation,
        data,
        createdAt,
        retryCount,
        errorMessage,
        lastAttemptAt,
      ];
}
