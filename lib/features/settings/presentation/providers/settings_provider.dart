import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/device_session_model.dart';
import '../../data/models/security_log_model.dart';
import '../../domain/repositories/settings_repository.dart';

/// State for settings feature
class SettingsState extends Equatable {
  const SettingsState({
    this.deviceSessions = const [],
    this.securityLogs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<DeviceSessionModel> deviceSessions;
  final List<SecurityLogModel> securityLogs;
  final bool isLoading;
  final String? errorMessage;

  SettingsState copyWith({
    List<DeviceSessionModel>? deviceSessions,
    List<SecurityLogModel>? securityLogs,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      deviceSessions: deviceSessions ?? this.deviceSessions,
      securityLogs: securityLogs ?? this.securityLogs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        deviceSessions,
        securityLogs,
        isLoading,
        errorMessage,
      ];
}

/// Notifier for settings state management
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  /// Load all device sessions
  Future<void> loadDeviceSessions() async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getDeviceSessions();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (sessions) => state = state.copyWith(
        deviceSessions: sessions,
        isLoading: false,
      ),
    );
  }

  /// Revoke a specific device session
  Future<bool> revokeDeviceSession(String sessionId) async {
    final result = await _repository.revokeDeviceSession(sessionId);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // Remove from local state
        final updatedSessions = state.deviceSessions
            .where((session) => session.id != sessionId)
            .toList();
        state = state.copyWith(deviceSessions: updatedSessions);
        return true;
      },
    );
  }

  /// Revoke all device sessions except current
  Future<bool> revokeAllDeviceSessions() async {
    final result = await _repository.revokeAllDeviceSessions();

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) {
        // Keep only current session
        final updatedSessions = state.deviceSessions
            .where((session) => session.isCurrent)
            .toList();
        state = state.copyWith(deviceSessions: updatedSessions);
        return true;
      },
    );
  }

  /// Load security logs
  Future<void> loadSecurityLogs({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getSecurityLogs(page: page, limit: limit);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (logs) => state = state.copyWith(
        securityLogs: logs,
        isLoading: false,
      ),
    );
  }

  /// Upload profile photo
  Future<String?> uploadProfilePhoto(File photoFile) async {
    final result = await _repository.uploadProfilePhoto(photoFile);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (photoUrl) => photoUrl,
    );
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    final result = await _repository.deleteProfilePhoto();

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Update profile information
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    final result = await _repository.updateProfile(
      name: name,
      phone: phone,
      photoUrl: photoUrl,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Update security settings
  Future<bool> updateSecuritySettings({
    bool? pinEnabled,
    bool? biometricEnabled,
    String? autoLockDuration,
  }) async {
    final result = await _repository.updateSecuritySettings(
      pinEnabled: pinEnabled,
      biometricEnabled: biometricEnabled,
      autoLockDuration: autoLockDuration,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Enable two-factor authentication
  Future<String?> enableTwoFactor() async {
    final result = await _repository.enableTwoFactor();

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return null;
      },
      (qrCode) => qrCode,
    );
  }

  /// Verify and activate two-factor authentication
  Future<bool> verifyTwoFactor(String code) async {
    final result = await _repository.verifyTwoFactor(code);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Disable two-factor authentication
  Future<bool> disableTwoFactor(String code) async {
    final result = await _repository.disableTwoFactor(code);

    return result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for settings state
final settingsStateProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(getIt<SettingsRepository>());
});

/// Provider for device sessions
final deviceSessionsProvider = Provider<List<DeviceSessionModel>>((ref) {
  return ref.watch(settingsStateProvider).deviceSessions;
});

/// Provider for current device session
final currentDeviceSessionProvider = Provider<DeviceSessionModel?>((ref) {
  final sessions = ref.watch(deviceSessionsProvider);
  try {
    return sessions.firstWhere((session) => session.isCurrent);
  } catch (e) {
    return null;
  }
});

/// Provider for other device sessions (excluding current)
final otherDeviceSessionsProvider = Provider<List<DeviceSessionModel>>((ref) {
  return ref
      .watch(deviceSessionsProvider)
      .where((session) => !session.isCurrent)
      .toList();
});

/// Provider for security logs
final securityLogsProvider = Provider<List<SecurityLogModel>>((ref) {
  return ref.watch(settingsStateProvider).securityLogs;
});

/// Provider for settings loading state
final settingsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(settingsStateProvider).isLoading;
});

/// Provider for settings error message
final settingsErrorProvider = Provider<String?>((ref) {
  return ref.watch(settingsStateProvider).errorMessage;
});
