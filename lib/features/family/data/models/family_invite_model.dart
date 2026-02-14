import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Status of a family invite
enum InviteStatus {
  pending('PENDING', 'Pending'),
  accepted('ACCEPTED', 'Accepted'),
  expired('EXPIRED', 'Expired'),
  cancelled('CANCELLED', 'Cancelled');

  const InviteStatus(this.value, this.label);
  final String value;
  final String label;
}

/// Family invite model representing an invitation to join a family
class FamilyInviteModel extends Equatable {
  const FamilyInviteModel({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedById,
    required this.invitedByName,
    required this.createdAt,
    required this.expiresAt,
    this.token,
    this.familyId,
    this.familyName,
  });

  factory FamilyInviteModel.fromJson(Map<String, dynamic> json) {
    return FamilyInviteModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.value == json['role'],
        orElse: () => UserRole.member,
      ),
      status: InviteStatus.values.firstWhere(
        (e) => e.value == json['status'],
        orElse: () => InviteStatus.pending,
      ),
      invitedById: json['invitedById'] as String,
      invitedByName: json['invitedByName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      token: json['token'] as String?,
      familyId: json['familyId'] as String?,
      familyName: json['familyName'] as String?,
    );
  }

  /// Unique identifier for this invite
  final String id;

  /// Email address of the invitee
  final String email;

  /// Role that will be assigned to the invitee
  final UserRole role;

  /// Current status of the invite
  final InviteStatus status;

  /// User ID of the person who sent the invite
  final String invitedById;

  /// Name of the person who sent the invite
  final String invitedByName;

  /// When the invite was created
  final DateTime createdAt;

  /// When the invite expires
  final DateTime expiresAt;

  /// Token used to accept the invite (only visible to invitee)
  final String? token;

  /// ID of the family being invited to
  final String? familyId;

  /// Name of the family being invited to
  final String? familyName;

  /// Check if the invite is still pending
  bool get isPending => status == InviteStatus.pending;

  /// Check if the invite has been accepted
  bool get isAccepted => status == InviteStatus.accepted;

  /// Check if the invite has expired (by status or date)
  bool get isExpired =>
      status == InviteStatus.expired || DateTime.now().isAfter(expiresAt);

  /// Check if the invite has been cancelled
  bool get isValid => isPending && !isExpired;

  /// Get the remaining time until the invite expires

  /// Check if the invite is still valid and can be accepted

  /// Get the remaining time until the invite expires
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.value,
      'status': status.value,
      'invitedById': invitedById,
      'invitedByName': invitedByName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'token': token,
      'familyId': familyId,
      'familyName': familyName,
    };
  }

  FamilyInviteModel copyWith({
    String? id,
    String? email,
    UserRole? role,
    InviteStatus? status,
    String? invitedById,
    String? invitedByName,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? token,
    String? familyId,
    String? familyName,
  }) {
    return FamilyInviteModel(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      invitedById: invitedById ?? this.invitedById,
      invitedByName: invitedByName ?? this.invitedByName,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      token: token ?? this.token,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        status,
        invitedById,
        invitedByName,
        createdAt,
        expiresAt,
        token,
        familyId,
        familyName,
      ];
}
