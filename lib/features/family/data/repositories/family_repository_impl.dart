import 'package:dartz/dartz.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/family_repository.dart';
import '../datasources/family_remote_datasource.dart';
import '../models/family_models.dart';

/// Family Repository Implementation
class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._remoteDataSource);

  final FamilyRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, FamilyModel>> getFamily() {
    return _remoteDataSource.getFamily();
  }

  @override
  Future<Either<Failure, FamilyModel>> createFamily(CreateFamilyRequest request) {
    return _remoteDataSource.createFamily(request);
  }

  @override
  Future<Either<Failure, FamilyModel>> updateFamily(UpdateFamilyRequest request) {
    return _remoteDataSource.updateFamily(request);
  }

  @override
  Future<Either<Failure, List<FamilyMemberModel>>> getMembers() {
    return _remoteDataSource.getMembers();
  }

  @override
  Future<Either<Failure, FamilyMemberModel>> updateMemberRole(
    String memberId,
    UserRole role,
  ) {
    return _remoteDataSource.updateMemberRole(memberId, role);
  }

  @override
  Future<Either<Failure, void>> removeMember(String memberId) {
    return _remoteDataSource.removeMember(memberId);
  }

  @override
  Future<Either<Failure, FamilyInviteModel>> sendInvite(SendInviteRequest request) {
    return _remoteDataSource.sendInvite(request);
  }

  @override
  Future<Either<Failure, void>> cancelInvite(String inviteId) {
    return _remoteDataSource.cancelInvite(inviteId);
  }

  @override
  Future<Either<Failure, FamilyModel>> acceptInvite(String token) {
    return _remoteDataSource.acceptInvite(token);
  }

  @override
  Future<Either<Failure, List<FamilyInviteModel>>> getPendingInvites() {
    return _remoteDataSource.getPendingInvites();
  }

  @override
  Future<Either<Failure, void>> leaveFamily() {
    return _remoteDataSource.leaveFamily();
  }

  @override
  Future<Either<Failure, void>> transferOwnership(String newOwnerId) {
    return _remoteDataSource.transferOwnership(newOwnerId);
  }
}
