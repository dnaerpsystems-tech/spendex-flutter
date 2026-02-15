import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Ticket category types
enum TicketCategory {
  bugReport,
  featureRequest,
  billingIssue,
  accountSecurity,
  generalQuestion;

  String get label {
    switch (this) {
      case TicketCategory.bugReport:
        return 'Bug Report';
      case TicketCategory.featureRequest:
        return 'Feature Request';
      case TicketCategory.billingIssue:
        return 'Billing Issue';
      case TicketCategory.accountSecurity:
        return 'Account & Security';
      case TicketCategory.generalQuestion:
        return 'General Question';
    }
  }

  String get emoji {
    switch (this) {
      case TicketCategory.bugReport:
        return '🐛';
      case TicketCategory.featureRequest:
        return '✨';
      case TicketCategory.billingIssue:
        return '💳';
      case TicketCategory.accountSecurity:
        return '🔐';
      case TicketCategory.generalQuestion:
        return '❓';
    }
  }

  Color get color {
    switch (this) {
      case TicketCategory.bugReport:
        return const Color(0xFFF44336); // Red
      case TicketCategory.featureRequest:
        return const Color(0xFF6C5CE7); // Purple
      case TicketCategory.billingIssue:
        return const Color(0xFFFF9800); // Orange
      case TicketCategory.accountSecurity:
        return const Color(0xFF4CAF50); // Green
      case TicketCategory.generalQuestion:
        return const Color(0xFF2196F3); // Blue
    }
  }
}

/// Ticket priority levels
enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    switch (this) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low:
        return const Color(0xFF4CAF50);
      case TicketPriority.medium:
        return const Color(0xFFFFC107);
      case TicketPriority.high:
        return const Color(0xFFFF9800);
      case TicketPriority.urgent:
        return const Color(0xFFF44336);
    }
  }

  IconData get icon {
    switch (this) {
      case TicketPriority.low:
        return Iconsax.arrow_down_1;
      case TicketPriority.medium:
        return Iconsax.minus;
      case TicketPriority.high:
        return Iconsax.arrow_up_2;
      case TicketPriority.urgent:
        return Iconsax.danger;
    }
  }
}

/// Ticket status types
enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed;

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return const Color(0xFF2196F3); // Blue
      case TicketStatus.inProgress:
        return const Color(0xFFFF9800); // Orange
      case TicketStatus.resolved:
        return const Color(0xFF4CAF50); // Green
      case TicketStatus.closed:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

/// Message in a ticket thread
class TicketMessage extends Equatable {
  const TicketMessage({
    required this.id,
    required this.content,
    required this.isFromSupport,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      isFromSupport: json['isFromSupport'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  final String id;
  final String content;
  final bool isFromSupport;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isFromSupport': isFromSupport,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, content, isFromSupport, createdAt];
}

/// Support ticket model
class Ticket extends Equatable {
  const Ticket({
    required this.id,
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
    this.userEmail,
    this.userName,
    this.deviceInfo,
    this.appVersion,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      category: TicketCategory.values.firstWhere(
        (c) => c.name == (json['category'] as String?),
        orElse: () => TicketCategory.generalQuestion,
      ),
      priority: TicketPriority.values.firstWhere(
        (p) => p.name == (json['priority'] as String?),
        orElse: () => TicketPriority.medium,
      ),
      status: TicketStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => TicketStatus.open,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      deviceInfo: json['deviceInfo'] as String?,
      appVersion: json['appVersion'] as String?,
    );
  }

  final String id;
  final String subject;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<TicketMessage> messages;
  final String? userEmail;
  final String? userName;
  final String? deviceInfo;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'description': description,
        'category': category.name,
        'priority': priority.name,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        if (userEmail != null) 'userEmail': userEmail,
        if (userName != null) 'userName': userName,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (appVersion != null) 'appVersion': appVersion,
      };

  Ticket copyWith({
    String? id,
    String? subject,
    String? description,
    TicketCategory? category,
    TicketPriority? priority,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TicketMessage>? messages,
    String? userEmail,
    String? userName,
    String? deviceInfo,
    String? appVersion,
  }) {
    return Ticket(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subject,
        description,
        category,
        priority,
        status,
        createdAt,
        updatedAt,
        messages,
        userEmail,
        userName,
        deviceInfo,
        appVersion,
      ];
}

/// Request model for creating a ticket
class CreateTicketRequest {
  const CreateTicketRequest({
    required this.subject,
    required this.description,
    required this.category,
    required this.priority,
    this.deviceInfo,
    this.appVersion,
  });

  final String subject;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final String? deviceInfo;
  final String? appVersion;

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'description': description,
        'category': category.name,
        'priority': priority.name,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
        if (appVersion != null) 'appVersion': appVersion,
      };
}
