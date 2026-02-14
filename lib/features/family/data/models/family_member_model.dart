import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Family member model representing a member of a family group
class FamilyMemberModel extends Equatable {
  const FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
    this.avatarUrl,
    this.lastActiveAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.value == json['role'],
        orElse: () => UserRole.member,
      ),
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
    );
  }

  /// Unique identifier for this family membership
  final String id;

  /// The user ID of the member
  final String userId;

  /// Display name of the member
  final String name;

  /// Email address of the member
  final String email;

  /// Role of the member within the family
  final UserRole role;

  /// Avatar URL of the member (optional)
  final String? avatarUrl;

  /// When the member joined the family
  final DateTime joinedAt;

  /// Last time the member was active (optional)
  final DateTime? lastActiveAt;

  /// Check if this member is the owner
  bool get isOwner => role == UserRole.owner;

  /// Check if this member is an admin (owner or admin role)
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;

  /// Check if this member can manage other members
  bool get canManageMembers => isAdmin;

  /// Check if this member has view-only access
  bool get canViewOnly => role == UserRole.viewer;

  /// Check if this member can edit data
  bool get canEdit => role != UserRole.viewer;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.value,
      'avatarUrl': avatarUrl,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
    };
  }

  FamilyMemberModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    UserRole? role,
    String? avatarUrl,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        email,
        role,
        avatarUrl,
        joinedAt,
        lastActiveAt,
      ];
}
