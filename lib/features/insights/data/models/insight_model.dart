import 'package:equatable/equatable.dart';

/// Enum representing different types of insights
enum InsightType {
  spendingPattern,
  savingsOpportunity,
  billPrediction,
  anomalyDetection,
  budgetRecommendation,
  goalAchievability,
  loanInsight,
  categoryTrend,
  merchantAnalysis,
  cashFlowForecast;

  /// Convert enum to string for JSON serialization
  String toJson() => name;

  /// Convert string to enum for JSON deserialization
  static InsightType fromJson(String json) {
    return InsightType.values.firstWhere(
      (type) => type.name == json,
      orElse: () => InsightType.spendingPattern,
    );
  }
}

/// Enum representing insight priority levels
enum InsightPriority {
  high,
  medium,
  low;

  /// Convert enum to string for JSON serialization
  String toJson() => name;

  /// Convert string to enum for JSON deserialization
  static InsightPriority fromJson(String json) {
    return InsightPriority.values.firstWhere(
      (priority) => priority.name == json,
      orElse: () => InsightPriority.medium,
    );
  }
}

/// Enum representing different action types for insights
enum InsightActionType {
  viewTransactions,
  setBudget,
  setGoal,
  viewCategory,
  viewMerchant,
  viewAccount,
  viewLoan,
  none;

  /// Convert enum to string for JSON serialization
  String toJson() => name;

  /// Convert string to enum for JSON deserialization
  static InsightActionType fromJson(String json) {
    return InsightActionType.values.firstWhere(
      (action) => action.name == json,
      orElse: () => InsightActionType.none,
    );
  }
}

/// Model class representing an insight
class InsightModel extends Equatable {

  const InsightModel({
    required this.id,
    required this.type,
    required this.title, required this.description, required this.priority, required this.actionType, required this.createdAt, this.category,
    this.actionData,
    this.validUntil,
    this.isRead = false,
    this.isDismissed = false,
    this.metadata,
  });

  /// Create InsightModel from JSON
  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'] as String? ?? '',
      type: InsightType.fromJson(json['type'] as String? ?? 'spendingPattern'),
      category: json['category'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: InsightPriority.fromJson(
        json['priority'] as String? ?? 'medium',
      ),
      actionType: InsightActionType.fromJson(
        json['action_type'] as String? ?? 'none',
      ),
      actionData: json['action_data'] as Map<String, dynamic>?,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      isRead: json['is_read'] as bool? ?? false,
      isDismissed: json['is_dismissed'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
  /// Unique identifier for the insight
  final String id;

  /// Type of the insight
  final InsightType type;

  /// Category associated with the insight (optional)
  final String? category;

  /// Title of the insight
  final String title;

  /// Detailed description of the insight
  final String description;

  /// Priority level of the insight
  final InsightPriority priority;

  /// Type of action that can be performed on the insight
  final InsightActionType actionType;

  /// Additional data for the action (e.g., category ID, merchant ID)
  final Map<String, dynamic>? actionData;

  /// Date until which the insight is valid
  final DateTime? validUntil;

  /// Whether the insight has been read by the user
  final bool isRead;

  /// Whether the insight has been dismissed by the user
  final bool isDismissed;

  /// Additional metadata for the insight
  final Map<String, dynamic>? metadata;

  /// Timestamp when the insight was created
  final DateTime createdAt;

  /// Convert InsightModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toJson(),
      'category': category,
      'title': title,
      'description': description,
      'priority': priority.toJson(),
      'action_type': actionType.toJson(),
      'action_data': actionData,
      'valid_until': validUntil?.toIso8601String(),
      'is_read': isRead,
      'is_dismissed': isDismissed,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy of InsightModel with updated fields
  InsightModel copyWith({
    String? id,
    InsightType? type,
    String? category,
    String? title,
    String? description,
    InsightPriority? priority,
    InsightActionType? actionType,
    Map<String, dynamic>? actionData,
    DateTime? validUntil,
    bool? isRead,
    bool? isDismissed,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return InsightModel(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      validUntil: validUntil ?? this.validUntil,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if the insight is currently valid (not expired and not dismissed)
  bool get isValid {
    if (isDismissed) return false;
    if (validUntil == null) return true;
    return DateTime.now().isBefore(validUntil!);
  }

  /// Check if the insight has expired
  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// Check if the insight is active (valid and not read)
  bool get isActive {
    return isValid && !isRead;
  }

  /// Get the number of days remaining until the insight expires
  int? get daysRemaining {
    if (validUntil == null) return null;
    final now = DateTime.now();
    if (now.isAfter(validUntil!)) return 0;
    return validUntil!.difference(now).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        title,
        description,
        priority,
        actionType,
        actionData,
        validUntil,
        isRead,
        isDismissed,
        metadata,
        createdAt,
      ];

  @override
  bool get stringify => true;
}

/// Request model for creating a new insight
class CreateInsightRequest extends Equatable {

  const CreateInsightRequest({
    required this.type,
    required this.title, required this.description, this.category,
    this.priority = InsightPriority.medium,
    this.actionType = InsightActionType.none,
    this.actionData,
    this.validUntil,
    this.metadata,
  });

  /// Create CreateInsightRequest from JSON
  factory CreateInsightRequest.fromJson(Map<String, dynamic> json) {
    return CreateInsightRequest(
      type: InsightType.fromJson(json['type'] as String? ?? 'spendingPattern'),
      category: json['category'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      priority: InsightPriority.fromJson(
        json['priority'] as String? ?? 'medium',
      ),
      actionType: InsightActionType.fromJson(
        json['action_type'] as String? ?? 'none',
      ),
      actionData: json['action_data'] as Map<String, dynamic>?,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  /// Type of the insight
  final InsightType type;

  /// Category associated with the insight (optional)
  final String? category;

  /// Title of the insight
  final String title;

  /// Detailed description of the insight
  final String description;

  /// Priority level of the insight
  final InsightPriority priority;

  /// Type of action that can be performed on the insight
  final InsightActionType actionType;

  /// Additional data for the action
  final Map<String, dynamic>? actionData;

  /// Date until which the insight is valid
  final DateTime? validUntil;

  /// Additional metadata for the insight
  final Map<String, dynamic>? metadata;

  /// Convert CreateInsightRequest to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.toJson(),
      'category': category,
      'title': title,
      'description': description,
      'priority': priority.toJson(),
      'action_type': actionType.toJson(),
      'action_data': actionData,
      'valid_until': validUntil?.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        type,
        category,
        title,
        description,
        priority,
        actionType,
        actionData,
        validUntil,
        metadata,
      ];

  @override
  bool get stringify => true;
}

/// Request model for updating an existing insight
class UpdateInsightRequest extends Equatable {

  const UpdateInsightRequest({
    required this.id,
    this.type,
    this.category,
    this.title,
    this.description,
    this.priority,
    this.actionType,
    this.actionData,
    this.validUntil,
    this.isRead,
    this.isDismissed,
    this.metadata,
  });

  /// Create UpdateInsightRequest from JSON
  factory UpdateInsightRequest.fromJson(Map<String, dynamic> json) {
    return UpdateInsightRequest(
      id: json['id'] as String? ?? '',
      type: json['type'] != null
          ? InsightType.fromJson(json['type'] as String)
          : null,
      category: json['category'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      priority: json['priority'] != null
          ? InsightPriority.fromJson(json['priority'] as String)
          : null,
      actionType: json['action_type'] != null
          ? InsightActionType.fromJson(json['action_type'] as String)
          : null,
      actionData: json['action_data'] as Map<String, dynamic>?,
      validUntil: json['valid_until'] != null
          ? DateTime.parse(json['valid_until'] as String)
          : null,
      isRead: json['is_read'] as bool?,
      isDismissed: json['is_dismissed'] as bool?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  /// Insight ID to update
  final String id;

  /// Updated type of the insight (optional)
  final InsightType? type;

  /// Updated category (optional)
  final String? category;

  /// Updated title (optional)
  final String? title;

  /// Updated description (optional)
  final String? description;

  /// Updated priority (optional)
  final InsightPriority? priority;

  /// Updated action type (optional)
  final InsightActionType? actionType;

  /// Updated action data (optional)
  final Map<String, dynamic>? actionData;

  /// Updated validity date (optional)
  final DateTime? validUntil;

  /// Updated read status (optional)
  final bool? isRead;

  /// Updated dismissed status (optional)
  final bool? isDismissed;

  /// Updated metadata (optional)
  final Map<String, dynamic>? metadata;

  /// Convert UpdateInsightRequest to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'id': id};

    if (type != null) json['type'] = type!.toJson();
    if (category != null) json['category'] = category;
    if (title != null) json['title'] = title;
    if (description != null) json['description'] = description;
    if (priority != null) json['priority'] = priority!.toJson();
    if (actionType != null) json['action_type'] = actionType!.toJson();
    if (actionData != null) json['action_data'] = actionData;
    if (validUntil != null) json['valid_until'] = validUntil!.toIso8601String();
    if (isRead != null) json['is_read'] = isRead;
    if (isDismissed != null) json['is_dismissed'] = isDismissed;
    if (metadata != null) json['metadata'] = metadata;

    return json;
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        title,
        description,
        priority,
        actionType,
        actionData,
        validUntil,
        isRead,
        isDismissed,
        metadata,
      ];

  @override
  bool get stringify => true;
}
