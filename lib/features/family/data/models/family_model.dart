import 'package:equatable/equatable.dart';

import 'family_invite_model.dart';
import 'family_member_model.dart';

/// Family/Tenant model representing a family group
class FamilyModel extends Equatable {
  const FamilyModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.memberCount,
    required this.createdAt,
    this.description,
    this.avatarUrl,
    this.members,
    this.pendingInvites,
    this.updatedAt,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String? ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      description: json['description'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      members: json['members'] != null
          ? (json['members'] as List)
              .map((e) => FamilyMemberModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pendingInvites: json['pendingInvites'] != null
          ? (json['pendingInvites'] as List)
              .map((e) => FamilyInviteModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Unique identifier for the family
  final String id;

  /// Display name of the family
  final String name;

  /// User ID of the family owner
  final String ownerId;

  /// Display name of the family owner
  final String ownerName;

  /// Total number of members in the family
  final int memberCount;

  /// Optional description of the family
  final String? description;

  /// Avatar URL for the family (optional)
  final String? avatarUrl;

  /// When the family was created
  final DateTime createdAt;

  /// When the family was last updated
  final DateTime? updatedAt;

  /// List of family members (optional, may be loaded separately)
  final List<FamilyMemberModel>? members;

  /// List of pending invites (optional, may be loaded separately)
  final List<FamilyInviteModel>? pendingInvites;

  /// Check if there's only one member (the owner)
  bool get isSingleMember => memberCount == 1;

  /// Check if there are pending invites
  bool get hasPendingInvites => pendingInvites != null && pendingInvites!.isNotEmpty;

  /// Get the number of pending invites
  int get pendingInviteCount => pendingInvites?.length ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'memberCount': memberCount,
      'description': description,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'members': members?.map((e) => e.toJson()).toList(),
      'pendingInvites': pendingInvites?.map((e) => e.toJson()).toList(),
    };
  }

  FamilyModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerName,
    int? memberCount,
    String? description,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<FamilyMemberModel>? members,
    List<FamilyInviteModel>? pendingInvites,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      memberCount: memberCount ?? this.memberCount,
      description: description ?? this.description,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      pendingInvites: pendingInvites ?? this.pendingInvites,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        ownerId,
        ownerName,
        memberCount,
        description,
        avatarUrl,
        createdAt,
        updatedAt,
        members,
        pendingInvites,
      ];
}

/// Request model for creating a new family
class CreateFamilyRequest {
  const CreateFamilyRequest({
    required this.name,
    this.description,
  });

  final String name;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

/// Request model for updating a family
class UpdateFamilyRequest {
  const UpdateFamilyRequest({
    this.name,
    this.description,
    this.avatarUrl,
  });

  final String? name;
  final String? description;
  final String? avatarUrl;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

/// Request model for sending an invite
class SendInviteRequest {
  const SendInviteRequest({
    required this.email,
    required this.role,
  });

  final String email;
  final String role;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
    };
  }
}

/// Request model for updating a member's role
class UpdateMemberRoleRequest {
  const UpdateMemberRoleRequest({
    required this.role,
  });

  final String role;

  Map<String, dynamic> toJson() {
    return {
      'role': role,
    };
  }
}

/// Request model for transferring ownership
class TransferOwnershipRequest {
  const TransferOwnershipRequest({
    required this.newOwnerId,
  });

  final String newOwnerId;

  Map<String, dynamic> toJson() {
    return {
      'newOwnerId': newOwnerId,
    };
  }
}
