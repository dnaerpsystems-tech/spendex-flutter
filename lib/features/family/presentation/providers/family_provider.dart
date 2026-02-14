import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/family_models.dart';
import '../../domain/repositories/family_repository.dart';

/// Family State
/// Manages the complete state for family/multi-user feature
class FamilyState extends Equatable {
  const FamilyState({
    this.family,
    this.members = const [],
    this.pendingInvites = const [],
    this.currentUserMember,
    this.isLoading = false,
    this.isMembersLoading = false,
    this.isInvitesLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isSendingInvite = false,
    this.isAcceptingInvite = false,
    this.isRemovingMember = false,
    this.isLeavingFamily = false,
    this.isTransferringOwnership = false,
    this.error,
    this.successMessage,
  });

  const FamilyState.initial()
      : family = null,
        members = const [],
        pendingInvites = const [],
        currentUserMember = null,
        isLoading = false,
        isMembersLoading = false,
        isInvitesLoading = false,
        isCreating = false,
        isUpdating = false,
        isSendingInvite = false,
        isAcceptingInvite = false,
        isRemovingMember = false,
        isLeavingFamily = false,
        isTransferringOwnership = false,
        error = null,
        successMessage = null;

  /// Current family (null if user is not part of any family)
  final FamilyModel? family;

  /// List of family members
  final List<FamilyMemberModel> members;

  /// List of pending invites
  final List<FamilyInviteModel> pendingInvites;

  /// Current user's member record in the family
  final FamilyMemberModel? currentUserMember;

  /// Loading states
  final bool isLoading;
  final bool isMembersLoading;
  final bool isInvitesLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isSendingInvite;
  final bool isAcceptingInvite;
  final bool isRemovingMember;
  final bool isLeavingFamily;
  final bool isTransferringOwnership;

  /// Error message
  final String? error;

  /// Success message for feedback
  final String? successMessage;

  /// Check if user has a family
  bool get hasFamily => family != null;

  /// Check if current user is the owner
  bool get isOwner => currentUserMember?.isOwner ?? false;

  /// Check if current user is an admin
  bool get isAdmin => currentUserMember?.isAdmin ?? false;

  /// Check if current user can manage members
  bool get canManageMembers => currentUserMember?.canManageMembers ?? false;

  /// Check if current user can edit family data
  bool get canEdit => currentUserMember?.canEdit ?? false;

  /// Get members excluding current user
  List<FamilyMemberModel> get otherMembers {
    if (currentUserMember == null) return members;
    return members.where((m) => m.id != currentUserMember!.id).toList();
  }

  /// Get admin members
  List<FamilyMemberModel> get adminMembers {
    return members.where((m) => m.isAdmin).toList();
  }

  /// Get non-admin members
  List<FamilyMemberModel> get regularMembers {
    return members.where((m) => !m.isAdmin).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress =>
      isCreating ||
      isUpdating ||
      isSendingInvite ||
      isAcceptingInvite ||
      isRemovingMember ||
      isLeavingFamily ||
      isTransferringOwnership;

  FamilyState copyWith({
    FamilyModel? family,
    List<FamilyMemberModel>? members,
    List<FamilyInviteModel>? pendingInvites,
    FamilyMemberModel? currentUserMember,
    bool? isLoading,
    bool? isMembersLoading,
    bool? isInvitesLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isSendingInvite,
    bool? isAcceptingInvite,
    bool? isRemovingMember,
    bool? isLeavingFamily,
    bool? isTransferringOwnership,
    String? error,
    String? successMessage,
    bool clearFamily = false,
    bool clearError = false,
    bool clearSuccessMessage = false,
    bool clearCurrentUserMember = false,
  }) {
    return FamilyState(
      family: clearFamily ? null : (family ?? this.family),
      members: members ?? this.members,
      pendingInvites: pendingInvites ?? this.pendingInvites,
      currentUserMember: clearCurrentUserMember
          ? null
          : (currentUserMember ?? this.currentUserMember),
      isLoading: isLoading ?? this.isLoading,
      isMembersLoading: isMembersLoading ?? this.isMembersLoading,
      isInvitesLoading: isInvitesLoading ?? this.isInvitesLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isSendingInvite: isSendingInvite ?? this.isSendingInvite,
      isAcceptingInvite: isAcceptingInvite ?? this.isAcceptingInvite,
      isRemovingMember: isRemovingMember ?? this.isRemovingMember,
      isLeavingFamily: isLeavingFamily ?? this.isLeavingFamily,
      isTransferringOwnership:
          isTransferringOwnership ?? this.isTransferringOwnership,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        family,
        members,
        pendingInvites,
        currentUserMember,
        isLoading,
        isMembersLoading,
        isInvitesLoading,
        isCreating,
        isUpdating,
        isSendingInvite,
        isAcceptingInvite,
        isRemovingMember,
        isLeavingFamily,
        isTransferringOwnership,
        error,
        successMessage,
      ];
}

/// Family State Notifier
/// Handles all family-related operations and state management
class FamilyNotifier extends StateNotifier<FamilyState> {
  FamilyNotifier(this._repository) : super(const FamilyState.initial());

  final FamilyRepository _repository;

  /// Load family data (family info, members, and invites)
  Future<void> loadFamily() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getFamily();

    result.fold(
      (failure) {
        if (failure.code == 'FAMILY_NOT_FOUND' || failure.code == 'NOT_FOUND') {
          state = state.copyWith(
            isLoading: false,
            clearFamily: true,
            members: [],
            pendingInvites: [],
            clearCurrentUserMember: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        }
      },
      (family) {
        state = state.copyWith(
          isLoading: false,
          family: family,
          members: family.members ?? [],
          pendingInvites: family.pendingInvites ?? [],
        );
        if (family.members == null) {
          loadMembers();
        } else {
          _setCurrentUserMember(family.members ?? []);
        }
        if (family.pendingInvites == null) {
          loadPendingInvites();
        }
      },
    );
  }

  /// Load family members
  Future<void> loadMembers() async {
    if (state.isMembersLoading || state.family == null) return;

    state = state.copyWith(isMembersLoading: true);

    final result = await _repository.getMembers();

    result.fold(
      (failure) {
        state = state.copyWith(
          isMembersLoading: false,
          error: failure.message,
        );
      },
      (members) {
        state = state.copyWith(
          isMembersLoading: false,
          members: members,
        );
        _setCurrentUserMember(members);
      },
    );
  }

  /// Load pending invites
  Future<void> loadPendingInvites() async {
    if (state.isInvitesLoading || state.family == null) return;

    state = state.copyWith(isInvitesLoading: true);

    final result = await _repository.getPendingInvites();

    result.fold(
      (failure) {
        state = state.copyWith(
          isInvitesLoading: false,
          error: failure.message,
        );
      },
      (invites) {
        state = state.copyWith(
          isInvitesLoading: false,
          pendingInvites: invites,
        );
      },
    );
  }

  /// Create a new family
  Future<FamilyModel?> createFamily(CreateFamilyRequest request) async {
    if (state.isCreating) return null;

    if (request.name.trim().isEmpty) {
      state = state.copyWith(error: 'Family name is required');
      return null;
    }

    if (request.name.length < 2) {
      state = state.copyWith(error: 'Family name must be at least 2 characters');
      return null;
    }

    if (request.name.length > 50) {
      state = state.copyWith(error: 'Family name cannot exceed 50 characters');
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createFamily(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (family) {
        state = state.copyWith(
          isCreating: false,
          family: family,
          successMessage: 'Family created successfully',
        );
        loadMembers();
        return family;
      },
    );
  }

  /// Update family info
  Future<FamilyModel?> updateFamily(UpdateFamilyRequest request) async {
    if (state.isUpdating || state.family == null) return null;

    if (request.name != null) {
      if (request.name!.trim().isEmpty) {
        state = state.copyWith(error: 'Family name cannot be empty');
        return null;
      }
      if (request.name!.length < 2) {
        state = state.copyWith(error: 'Family name must be at least 2 characters');
        return null;
      }
      if (request.name!.length > 50) {
        state = state.copyWith(error: 'Family name cannot exceed 50 characters');
        return null;
      }
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateFamily(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (family) {
        state = state.copyWith(
          isUpdating: false,
          family: family,
          successMessage: 'Family updated successfully',
        );
        return family;
      },
    );
  }

  /// Send invite to join family
  Future<FamilyInviteModel?> sendInvite(SendInviteRequest request) async {
    if (state.isSendingInvite || state.family == null) return null;

    if (request.email.trim().isEmpty) {
      state = state.copyWith(error: 'Email address is required');
      return null;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (emailRegex.hasMatch(request.email) == false) {
      state = state.copyWith(error: 'Please enter a valid email address');
      return null;
    }

    final existingMember = state.members
        .where((m) => m.email.toLowerCase() == request.email.toLowerCase())
        .firstOrNull;
    if (existingMember != null) {
      state = state.copyWith(error: 'This person is already a family member');
      return null;
    }

    final existingInvite = state.pendingInvites
        .where((i) =>
            i.email.toLowerCase() == request.email.toLowerCase() && i.isPending)
        .firstOrNull;
    if (existingInvite != null) {
      state = state.copyWith(error: 'An invite has already been sent to this email');
      return null;
    }

    state = state.copyWith(isSendingInvite: true, clearError: true);

    final result = await _repository.sendInvite(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSendingInvite: false,
          error: failure.message,
        );
        return null;
      },
      (invite) {
        state = state.copyWith(
          isSendingInvite: false,
          pendingInvites: [...state.pendingInvites, invite],
          successMessage: 'Invite sent to ${request.email}',
        );
        return invite;
      },
    );
  }

  /// Cancel a pending invite
  Future<bool> cancelInvite(String inviteId) async {
    if (state.family == null) return false;

    state = state.copyWith(clearError: true);

    final result = await _repository.cancelInvite(inviteId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) {
        final updatedInvites =
            state.pendingInvites.where((i) => i.id != inviteId).toList();
        state = state.copyWith(
          pendingInvites: updatedInvites,
          successMessage: 'Invite cancelled',
        );
        return true;
      },
    );
  }

  /// Accept an invite to join a family
  Future<FamilyModel?> acceptInvite(String token) async {
    if (state.isAcceptingInvite) return null;

    if (token.trim().isEmpty) {
      state = state.copyWith(error: 'Invalid invite token');
      return null;
    }

    state = state.copyWith(isAcceptingInvite: true, clearError: true);

    final result = await _repository.acceptInvite(token);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isAcceptingInvite: false,
          error: failure.message,
        );
        return null;
      },
      (family) {
        state = state.copyWith(
          isAcceptingInvite: false,
          family: family,
          successMessage: 'Welcome to ${family.name}',
        );
        loadFamily();
        return family;
      },
    );
  }

  /// Update a member's role
  Future<FamilyMemberModel?> updateMemberRole(
    String memberId,
    UserRole role,
  ) async {
    if (state.family == null || state.canManageMembers == false) return null;

    final member = state.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) {
      state = state.copyWith(error: 'Member not found');
      return null;
    }

    if (member.isOwner) {
      state = state.copyWith(
        error: 'Cannot change owner role. Transfer ownership instead.',
      );
      return null;
    }

    if (role == UserRole.owner) {
      state = state.copyWith(
        error: 'Use transfer ownership to make someone the owner',
      );
      return null;
    }

    state = state.copyWith(clearError: true);

    final result = await _repository.updateMemberRole(memberId, role);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
      (updatedMember) {
        final updatedMembers = state.members.map((m) {
          return m.id == memberId ? updatedMember : m;
        }).toList();

        state = state.copyWith(
          members: updatedMembers,
          successMessage: '${updatedMember.name} role updated to ${role.label}',
        );
        return updatedMember;
      },
    );
  }

  /// Remove a member from the family
  Future<bool> removeMember(String memberId) async {
    if (state.isRemovingMember || state.family == null || state.canManageMembers == false) {
      return false;
    }

    final member = state.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) {
      state = state.copyWith(error: 'Member not found');
      return false;
    }

    if (member.isOwner) {
      state = state.copyWith(error: 'Cannot remove the owner');
      return false;
    }

    if (member.id == state.currentUserMember?.id) {
      state = state.copyWith(error: 'Use Leave Family to remove yourself');
      return false;
    }

    state = state.copyWith(isRemovingMember: true, clearError: true);

    final result = await _repository.removeMember(memberId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRemovingMember: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedMembers =
            state.members.where((m) => m.id != memberId).toList();
        final updatedFamily = state.family?.copyWith(
          memberCount: updatedMembers.length,
        );

        state = state.copyWith(
          isRemovingMember: false,
          members: updatedMembers,
          family: updatedFamily,
          successMessage: '${member.name} has been removed from the family',
        );
        return true;
      },
    );
  }

  /// Leave the current family
  Future<bool> leaveFamily() async {
    if (state.isLeavingFamily || state.family == null) return false;

    if (state.isOwner) {
      state = state.copyWith(
        error: 'Transfer ownership before leaving the family',
      );
      return false;
    }

    state = state.copyWith(isLeavingFamily: true, clearError: true);

    final result = await _repository.leaveFamily();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLeavingFamily: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = const FamilyState.initial().copyWith(
          successMessage: 'You have left the family',
        );
        return true;
      },
    );
  }

  /// Transfer ownership to another member
  Future<bool> transferOwnership(String newOwnerId) async {
    if (state.isTransferringOwnership || state.family == null || state.isOwner == false) {
      return false;
    }

    final newOwner = state.members.where((m) => m.id == newOwnerId).firstOrNull;
    if (newOwner == null) {
      state = state.copyWith(error: 'Member not found');
      return false;
    }

    if (newOwner.isOwner) {
      state = state.copyWith(error: 'This member is already the owner');
      return false;
    }

    state = state.copyWith(isTransferringOwnership: true, clearError: true);

    final result = await _repository.transferOwnership(newOwnerId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isTransferringOwnership: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isTransferringOwnership: false,
          successMessage: 'Ownership transferred to ${newOwner.name}',
        );
        loadFamily();
        return true;
      },
    );
  }

  void _setCurrentUserMember(List<FamilyMemberModel> members) {
    if (members.isNotEmpty) {
      state = state.copyWith(currentUserMember: members.first);
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }

  Future<void> refresh() async {
    await loadFamily();
  }

  void reset() {
    state = const FamilyState.initial();
  }
}

/// Family State Provider
final familyStateProvider =
    StateNotifierProvider.autoDispose<FamilyNotifier, FamilyState>((ref) {
  return FamilyNotifier(getIt<FamilyRepository>());
});

/// Family Provider
final familyProvider = Provider<FamilyModel?>((ref) {
  return ref.watch(familyStateProvider).family;
});

/// Family Members Provider
final familyMembersProvider = Provider<List<FamilyMemberModel>>((ref) {
  return ref.watch(familyStateProvider).members;
});

/// Pending Invites Provider
final pendingInvitesProvider = Provider<List<FamilyInviteModel>>((ref) {
  return ref.watch(familyStateProvider).pendingInvites;
});

/// Has Family Provider
final hasFamilyProvider = Provider<bool>((ref) {
  return ref.watch(familyStateProvider).hasFamily;
});

/// Is Family Owner Provider
final isFamilyOwnerProvider = Provider<bool>((ref) {
  return ref.watch(familyStateProvider).isOwner;
});

/// Can Manage Members Provider
final canManageMembersProvider = Provider<bool>((ref) {
  return ref.watch(familyStateProvider).canManageMembers;
});

/// Family Loading Provider
final familyLoadingProvider = Provider<bool>((ref) {
  return ref.watch(familyStateProvider).isLoading;
});

/// Family Error Provider
final familyErrorProvider = Provider<String?>((ref) {
  return ref.watch(familyStateProvider).error;
});

/// Family Operation In Progress Provider
final familyOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(familyStateProvider).isOperationInProgress;
});
