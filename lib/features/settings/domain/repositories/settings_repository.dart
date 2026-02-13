import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/device_session_model.dart';
import '../../data/models/security_log_model.dart';

/// Repository interface for settings and profile management
abstract class SettingsRepository {
  /// Get all active device sessions
  Future<Either<Failure, List<DeviceSessionModel>>> getDeviceSessions();

  /// Revoke a specific device session
  Future<Either<Failure, void>> revokeDeviceSession(String sessionId);

  /// Revoke all device sessions except current
  Future<Either<Failure, void>> revokeAllDeviceSessions();

  /// Get security activity logs
  Future<Either<Failure, List<SecurityLogModel>>> getSecurityLogs({
    int page = 1,
    int limit = 20,
  });

  /// Upload profile photo
  Future<Either<Failure, String>> uploadProfilePhoto(File photoFile);

  /// Delete profile photo
  Future<Either<Failure, void>> deleteProfilePhoto();

  /// Update profile information
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  });

  /// Update security settings
  Future<Either<Failure, void>> updateSecuritySettings({
    bool? pinEnabled,
    bool? biometricEnabled,
    String? autoLockDuration,
  });

  /// Enable two-factor authentication
  Future<Either<Failure, String>> enableTwoFactor();

  /// Verify and activate two-factor authentication
  Future<Either<Failure, void>> verifyTwoFactor(String code);

  /// Disable two-factor authentication
  Future<Either<Failure, void>> disableTwoFactor(String code);
}
