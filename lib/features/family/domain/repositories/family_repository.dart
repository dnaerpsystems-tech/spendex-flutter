import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/family_models.dart';

/// Family Repository Interface
/// Defines the contract for family data operations
abstract class FamilyRepository {
  /// Get current user's family info
  Future<Either<Failure, FamilyModel>> getFamily();

  /// Create a new family
  Future<Either<Failure, FamilyModel>> createFamily(CreateFamilyRequest request);

  /// Update family info
  Future<Either<Failure, FamilyModel>> updateFamily(UpdateFamilyRequest request);

  /// Get family members
  Future<Either<Failure, List<FamilyMemberModel>>> getMembers();

  /// Update member role
  Future<Either<Failure, FamilyMemberModel>> updateMemberRole(
    String memberId,
    UserRole role,
  );

  /// Remove member from family
  Future<Either<Failure, void>> removeMember(String memberId);

  /// Send invite to join family
  Future<Either<Failure, FamilyInviteModel>> sendInvite(SendInviteRequest request);

  /// Cancel a pending invite
  Future<Either<Failure, void>> cancelInvite(String inviteId);

  /// Accept an invite (for invitee)
  Future<Either<Failure, FamilyModel>> acceptInvite(String token);

  /// Get pending invites
  Future<Either<Failure, List<FamilyInviteModel>>> getPendingInvites();

  /// Leave the current family
  Future<Either<Failure, void>> leaveFamily();

  /// Transfer ownership to another member
  Future<Either<Failure, void>> transferOwnership(String newOwnerId);
}
