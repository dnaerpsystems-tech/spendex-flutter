import 'package:equatable/equatable.dart';

/// Notification type enum
enum NotificationType {
  transaction('transaction', 'Transaction'),
  budget('budget', 'Budget'),
  goal('goal', 'Goal'),
  family('family', 'Family'),
  loan('loan', 'Loan'),
  investment('investment', 'Investment'),
  system('system', 'System'),
  reminder('reminder', 'Reminder'),
  alert('alert', 'Alert');

  const NotificationType(this.value, this.label);
  final String value;
  final String label;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.system,
    );
  }
}

/// Notification priority enum
enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const NotificationPriority(this.value);
  final String value;

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

/// Notification action for deep linking
enum NotificationAction {
  openTransaction('open_transaction'),
  openBudget('open_budget'),
  openGoal('open_goal'),
  openFamily('open_family'),
  openLoan('open_loan'),
  openInvestment('open_investment'),
  openAccount('open_account'),
  openSettings('open_settings'),
  openInsights('open_insights'),
  none('none');

  const NotificationAction(this.value);
  final String value;

  static NotificationAction fromString(String value) {
    return NotificationAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationAction.none,
    );
  }
}

/// Notification model
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.isRead,
    required this.createdAt,
    this.action,
    this.actionData,
    this.imageUrl,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String? ?? 'system'),
      priority: NotificationPriority.fromString(json['priority'] as String? ?? 'normal'),
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      action:
          json['action'] != null ? NotificationAction.fromString(json['action'] as String) : null,
      actionData: json['actionData'] as Map<String, dynamic>?,
      imageUrl: json['imageUrl'] as String?,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
    );
  }

  /// Unique identifier
  final String id;

  /// Notification title
  final String title;

  /// Notification body/message
  final String body;

  /// Type of notification
  final NotificationType type;

  /// Priority level
  final NotificationPriority priority;

  /// Whether notification has been read
  final bool isRead;

  /// When the notification was created
  final DateTime createdAt;

  /// Deep link action
  final NotificationAction? action;

  /// Data for the action (e.g., transaction ID)
  final Map<String, dynamic>? actionData;

  /// Optional image URL
  final String? imageUrl;

  /// When the notification was read
  final DateTime? readAt;

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Check if notification is high priority
  bool get isHighPriority =>
      priority == NotificationPriority.high || priority == NotificationPriority.urgent;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.value,
      'priority': priority.value,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'action': action?.value,
      'actionData': actionData,
      'imageUrl': imageUrl,
      'readAt': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? createdAt,
    NotificationAction? action,
    Map<String, dynamic>? actionData,
    String? imageUrl,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      action: action ?? this.action,
      actionData: actionData ?? this.actionData,
      imageUrl: imageUrl ?? this.imageUrl,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        priority,
        isRead,
        createdAt,
        action,
        actionData,
        imageUrl,
        readAt,
      ];
}

/// Unread count response
class UnreadCountResponse extends Equatable {
  const UnreadCountResponse({
    required this.count,
    this.byType,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    Map<NotificationType, int>? byType;
    if (json['byType'] != null) {
      byType = {};
      (json['byType'] as Map<String, dynamic>).forEach((key, value) {
        byType![NotificationType.fromString(key)] = (value as num).toInt();
      });
    }

    return UnreadCountResponse(
      count: (json['count'] as num?)?.toInt() ?? 0,
      byType: byType,
    );
  }

  /// Total unread count
  final int count;

  /// Unread count by type
  final Map<NotificationType, int>? byType;

  @override
  List<Object?> get props => [count, byType];
}

/// Request to register push notification token
class RegisterPushTokenRequest {
  const RegisterPushTokenRequest({
    required this.token,
    required this.platform,
    this.deviceId,
    this.deviceName,
  });

  /// FCM or APNs token
  final String token;

  /// Platform (android, ios, web)
  final String platform;

  /// Unique device identifier
  final String? deviceId;

  /// Human readable device name
  final String? deviceName;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'platform': platform,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceName != null) 'deviceName': deviceName,
    };
  }
}

/// Paginated notifications response
class NotificationsResponse extends Equatable {
  const NotificationsResponse({
    required this.notifications,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['notifications'] as List? ?? json['data'] as List? ?? [])
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  /// List of notifications
  final List<NotificationModel> notifications;

  /// Total number of notifications
  final int total;

  /// Current page
  final int page;

  /// Page size
  final int pageSize;

  /// Whether there are more notifications to load
  final bool hasMore;

  @override
  List<Object?> get props => [notifications, total, page, pageSize, hasMore];
}
