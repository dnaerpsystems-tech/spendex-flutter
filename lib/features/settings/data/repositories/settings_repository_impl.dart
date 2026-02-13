import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/device_session_model.dart';
import '../models/security_log_model.dart';

/// Implementation of SettingsRepository
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._remoteDataSource);

  final SettingsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<DeviceSessionModel>>> getDeviceSessions() {
    return _remoteDataSource.getDeviceSessions();
  }

  @override
  Future<Either<Failure, void>> revokeDeviceSession(String sessionId) {
    return _remoteDataSource.revokeDeviceSession(sessionId);
  }

  @override
  Future<Either<Failure, void>> revokeAllDeviceSessions() {
    return _remoteDataSource.revokeAllDeviceSessions();
  }

  @override
  Future<Either<Failure, List<SecurityLogModel>>> getSecurityLogs({
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getSecurityLogs(page: page, limit: limit);
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(File photoFile) {
    return _remoteDataSource.uploadProfilePhoto(photoFile);
  }

  @override
  Future<Either<Failure, void>> deleteProfilePhoto() {
    return _remoteDataSource.deleteProfilePhoto();
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) {
    return _remoteDataSource.updateProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<Either<Failure, void>> updateSecuritySettings({
    bool? pinEnabled,
    bool? biometricEnabled,
    String? autoLockDuration,
  }) {
    return _remoteDataSource.updateSecuritySettings(
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled,
      autoLockDuration: autoLockDuration,
    );
  }

  @override
  Future<Either<Failure, String>> enableTwoFactor() {
    return _remoteDataSource.enableTwoFactor();
  }

  @override
  Future<Either<Failure, void>> verifyTwoFactor(String code) {
    return _remoteDataSource.verifyTwoFactor(code);
  }

  @override
  Future<Either<Failure, void>> disableTwoFactor(String code) {
    return _remoteDataSource.disableTwoFactor(code);
  }
}
