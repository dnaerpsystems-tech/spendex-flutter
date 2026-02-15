import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/deletion_models.dart';
import '../models/device_session_model.dart';
import '../models/security_log_model.dart';

/// Remote data source for settings and profile operations
abstract class SettingsRemoteDataSource {
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

  /// Check if user has active subscription before account deletion
  Future<Either<Failure, ActiveSubscriptionInfo>> checkActiveSubscription();

  /// Verify password for account deletion
  Future<Either<Failure, VerifyPasswordResponse>> verifyPassword(String password);

  /// Delete user account permanently
  Future<Either<Failure, void>> deleteAccount(DeleteAccountRequest request);
}

/// Implementation of settings remote data source
class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  SettingsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<DeviceSessionModel>>> getDeviceSessions() async {
    return _apiClient.get<List<DeviceSessionModel>>(
      '/user/sessions',
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) => DeviceSessionModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return <DeviceSessionModel>[];
      },
    );
  }

  @override
  Future<Either<Failure, void>> revokeDeviceSession(String sessionId) async {
    return _apiClient.delete<void>(
      '/user/sessions/$sessionId',
    );
  }

  @override
  Future<Either<Failure, void>> revokeAllDeviceSessions() async {
    return _apiClient.delete<void>(
      '/user/sessions/all',
    );
  }

  @override
  Future<Either<Failure, List<SecurityLogModel>>> getSecurityLogs({
    int page = 1,
    int limit = 20,
  }) async {
    return _apiClient.get<List<SecurityLogModel>>(
      '/user/security-logs',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
      fromJson: (data) {
        if (data is List) {
          return data
              .map((json) => SecurityLogModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return <SecurityLogModel>[];
      },
    );
  }

  @override
  Future<Either<Failure, String>> uploadProfilePhoto(File photoFile) async {
    return _apiClient.uploadFile<String>(
      '/user/profile/photo',
      file: photoFile,
      fieldName: 'photo',
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return data['photoUrl'] as String? ?? '';
        }
        return '';
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteProfilePhoto() async {
    return _apiClient.delete<void>(
      '/user/profile/photo',
    );
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name;
    }
    if (phone != null) {
      data['phone'] = phone;
    }
    if (photoUrl != null) {
      data['photoUrl'] = photoUrl;
    }

    return _apiClient.patch<void>(
      '/user/profile',
      data: data,
    );
  }

  @override
  Future<Either<Failure, void>> updateSecuritySettings({
    bool? pinEnabled,
    bool? biometricEnabled,
    String? autoLockDuration,
  }) async {
    final data = <String, dynamic>{};
    if (pinEnabled != null) {
      data['pinEnabled'] = pinEnabled;
    }
    if (biometricEnabled != null) {
      data['biometricEnabled'] = biometricEnabled;
    }
    if (autoLockDuration != null) {
      data['autoLockDuration'] = autoLockDuration;
    }

    return _apiClient.patch<void>(
      '/user/security-settings',
      data: data,
    );
  }

  @override
  Future<Either<Failure, String>> enableTwoFactor() async {
    return _apiClient.post<String>(
      '/user/2fa/enable',
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return data['qrCode'] as String? ?? '';
        }
        return '';
      },
    );
  }

  @override
  Future<Either<Failure, void>> verifyTwoFactor(String code) async {
    return _apiClient.post<void>(
      '/user/2fa/verify',
      data: {'code': code},
    );
  }

  @override
  Future<Either<Failure, void>> disableTwoFactor(String code) async {
    return _apiClient.post<void>(
      '/user/2fa/disable',
      data: {'code': code},
    );
  }

  @override
  Future<Either<Failure, ActiveSubscriptionInfo>> checkActiveSubscription() async {
    return _apiClient.get<ActiveSubscriptionInfo>(
      ApiEndpoints.checkSubscription,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          return ActiveSubscriptionInfo.fromJson(data);
        }
        return ActiveSubscriptionInfo.none;
      },
    );
  }

  @override
  Future<Either<Failure, VerifyPasswordResponse>> verifyPassword(String password) async {
    return _apiClient.post<VerifyPasswordResponse>(
      ApiEndpoints.verifyPassword,
      data: VerifyPasswordRequest(password: password).toJson(),
      fromJson: (data) { if (data is Map<String, dynamic>) { return VerifyPasswordResponse.fromJson(data); } return const VerifyPasswordResponse(verified: false); },
    );
  }

  @override
  Future<Either<Failure, void>> deleteAccount(DeleteAccountRequest request) async {
    return _apiClient.delete<void>(
      ApiEndpoints.deleteAccount,
      data: request.toJson(),
    );
  }
}
