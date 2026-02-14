import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/family_models.dart';

/// Family Remote DataSource Interface
/// Defines the contract for family-related API operations
abstract class FamilyRemoteDataSource {
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

/// Family Remote DataSource Implementation
class FamilyRemoteDataSourceImpl implements FamilyRemoteDataSource {
  FamilyRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, FamilyModel>> getFamily() async {
    return _apiClient.get<FamilyModel>(
      ApiEndpoints.family,
      fromJson: (json) => FamilyModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, FamilyModel>> createFamily(
    CreateFamilyRequest request,
  ) async {
    return _apiClient.post<FamilyModel>(
      ApiEndpoints.family,
      data: request.toJson(),
      fromJson: (json) => FamilyModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, FamilyModel>> updateFamily(
    UpdateFamilyRequest request,
  ) async {
    return _apiClient.put<FamilyModel>(
      ApiEndpoints.family,
      data: request.toJson(),
      fromJson: (json) => FamilyModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<FamilyMemberModel>>> getMembers() async {
    final result = await _apiClient.get<dynamic>(
      '${ApiEndpoints.family}/members',
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is List) {
          final members = data
              .map((json) => FamilyMemberModel.fromJson(json! as Map<String, dynamic>))
              .toList();
          return Right(members);
        }
        return const Right([]);
      },
    );
  }

  @override
  Future<Either<Failure, FamilyMemberModel>> updateMemberRole(
    String memberId,
    UserRole role,
  ) async {
    return _apiClient.put<FamilyMemberModel>(
      ApiEndpoints.familyMember(memberId),
      data: UpdateMemberRoleRequest(role: role.value).toJson(),
      fromJson: (json) => FamilyMemberModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> removeMember(String memberId) async {
    final result = await _apiClient.delete(
      ApiEndpoints.familyMember(memberId),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, FamilyInviteModel>> sendInvite(
    SendInviteRequest request,
  ) async {
    return _apiClient.post<FamilyInviteModel>(
      ApiEndpoints.familyInvite,
      data: request.toJson(),
      fromJson: (json) => FamilyInviteModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> cancelInvite(String inviteId) async {
    final result = await _apiClient.delete(
      ApiEndpoints.familyCancelInvite(inviteId),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, FamilyModel>> acceptInvite(String token) async {
    return _apiClient.post<FamilyModel>(
      ApiEndpoints.familyAcceptInvite(token),
      fromJson: (json) => FamilyModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, List<FamilyInviteModel>>> getPendingInvites() async {
    final result = await _apiClient.get<dynamic>(
      '${ApiEndpoints.familyInvite}s',
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is List) {
          final invites = data
              .map((json) => FamilyInviteModel.fromJson(json! as Map<String, dynamic>))
              .toList();
          return Right(invites);
        }
        return const Right([]);
      },
    );
  }

  @override
  Future<Either<Failure, void>> leaveFamily() async {
    final result = await _apiClient.post(
      ApiEndpoints.familyLeave,
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> transferOwnership(String newOwnerId) async {
    final result = await _apiClient.post(
      ApiEndpoints.familyTransferOwnership,
      data: TransferOwnershipRequest(newOwnerId: newOwnerId).toJson(),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }
}
