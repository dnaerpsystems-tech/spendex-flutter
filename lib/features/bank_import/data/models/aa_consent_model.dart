import 'package:equatable/equatable.dart';

enum ConsentStatus {
  pending,
  active,
  paused,
  revoked,
  expired,
}

class AccountAggregatorConsentModel extends Equatable {
  const AccountAggregatorConsentModel({
    required this.consentId,
    required this.status,
    required this.accountIds,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.expiresAt,
  });

  factory AccountAggregatorConsentModel.fromJson(Map<String, dynamic> json) {
    return AccountAggregatorConsentModel(
      consentId: json['consentId'] as String,
      status: ConsentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConsentStatus.pending,
      ),
      accountIds: (json['accountIds'] as List<dynamic>).map((e) => e as String).toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
  final String consentId;
  final ConsentStatus status;
  final List<String> accountIds;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime expiresAt;

  Map<String, dynamic> toJson() {
    return {
      'consentId': consentId,
      'status': status.name,
      'accountIds': accountIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  AccountAggregatorConsentModel copyWith({
    String? consentId,
    ConsentStatus? status,
    List<String>? accountIds,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return AccountAggregatorConsentModel(
      consentId: consentId ?? this.consentId,
      status: status ?? this.status,
      accountIds: accountIds ?? this.accountIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  bool get isActive => status == ConsentStatus.active;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => isActive && !isExpired;

  @override
  List<Object?> get props => [
        consentId,
        status,
        accountIds,
        startDate,
        endDate,
        createdAt,
        expiresAt,
      ];
}
