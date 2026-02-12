import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth State
class AuthState extends Equatable {
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isBiometricAvailable = false,
    this.isBiometricEnabled = false,
    this.isBiometricLoading = false,
  });

  const AuthState.initial()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false;

  const AuthState.loading()
      : isLoading = true,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false;

  const AuthState.authenticated(this.user)
      : isLoading = false,
        isAuthenticated = true,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false;

  const AuthState.unauthenticated()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false;

  const AuthState.error(this.error)
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false;

  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final bool isBiometricLoading;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    bool? isBiometricLoading,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricLoading: isBiometricLoading ?? this.isBiometricLoading,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isAuthenticated,
        user,
        error,
        isBiometricAvailable,
        isBiometricEnabled,
        isBiometricLoading,
      ];
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository, this._secureStorage)
      : super(const AuthState.initial());

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check authentication status
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();

    final isAuthenticated = await _secureStorage.isAuthenticated();

    if (isAuthenticated) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => state = const AuthState.unauthenticated(),
        (user) => state = AuthState.authenticated(user),
      );
    } else {
      state = const AuthState.unauthenticated();
    }

    // Check biometric availability after auth status
    await checkBiometricAvailability();
  }

  /// Check if biometric authentication is available on device
  Future<void> checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      final isDeviceSupported = await _localAuth.isDeviceSupported().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      final isAvailable = canCheck && isDeviceSupported;

      // Check if biometric is enabled in storage
      final isEnabled = await _authRepository.isBiometricEnabled();

      state = state.copyWith(
        isBiometricAvailable: isAvailable,
        isBiometricEnabled: isEnabled,
      );
    } on PlatformException {
      state = state.copyWith(
        isBiometricAvailable: false,
        isBiometricEnabled: false,
      );
    } catch (e) {
      // Handle any other errors (timeout, etc.)
      state = state.copyWith(
        isBiometricAvailable: false,
        isBiometricEnabled: false,
      );
    }
  }

  /// Authenticate with device biometrics (fingerprint/face)
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Spendex',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  /// Login with biometric authentication
  Future<bool> loginWithBiometric() async {
    state = state.copyWith(isBiometricLoading: true);

    try {
      // First, authenticate with device biometrics
      final isAuthenticated = await authenticateWithBiometrics();

      if (!isAuthenticated) {
        state = state.copyWith(
          isBiometricLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }

      // Get biometric login options from server
      final optionsResult = await _authRepository.getBiometricLoginOptions();

      return await optionsResult.fold(
        (failure) {
          state = state.copyWith(
            isBiometricLoading: false,
            error: failure.message,
          );
          return false;
        },
        (options) async {
          // Create credential payload with device verification
          final credential = {
            'challenge': options['challenge'],
            'deviceVerified': true,
            'timestamp': DateTime.now().toIso8601String(),
          };

          // Login with biometric credential
          final loginResult = await _authRepository.loginWithBiometric(credential);

          return loginResult.fold(
            (failure) {
              state = state.copyWith(
                isBiometricLoading: false,
                error: failure.message,
              );
              return false;
            },
            (authResponse) {
              state = AuthState(
                isAuthenticated: true,
                user: authResponse.user,
                isBiometricAvailable: state.isBiometricAvailable,
                isBiometricEnabled: state.isBiometricEnabled,
              );
              return true;
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isBiometricLoading: false,
        error: 'Biometric authentication error: $e',
      );
      return false;
    }
  }

  /// Register biometric credential
  Future<bool> registerBiometric() async {
    state = state.copyWith(isBiometricLoading: true);

    try {
      // First, authenticate with device biometrics
      final isAuthenticated = await authenticateWithBiometrics();

      if (!isAuthenticated) {
        state = state.copyWith(
          isBiometricLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }

      // Get biometric register options from server
      final optionsResult = await _authRepository.getBiometricRegisterOptions();

      return await optionsResult.fold(
        (failure) {
          state = state.copyWith(
            isBiometricLoading: false,
            error: failure.message,
          );
          return false;
        },
        (options) async {
          // Create credential payload with device verification
          final credential = {
            'challenge': options['challenge'],
            'deviceVerified': true,
            'deviceName': await _getDeviceName(),
            'timestamp': DateTime.now().toIso8601String(),
          };

          // Register biometric credential
          final registerResult = await _authRepository.registerBiometric(credential);

          return registerResult.fold(
            (failure) {
              state = state.copyWith(
                isBiometricLoading: false,
                error: failure.message,
              );
              return false;
            },
            (success) {
              state = state.copyWith(
                isBiometricLoading: false,
                isBiometricEnabled: success,
              );
              return success;
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isBiometricLoading: false,
        error: 'Biometric registration error: $e',
      );
      return false;
    }
  }

  /// Get biometric credentials
  Future<List<Map<String, dynamic>>> getBiometricCredentials() async {
    final result = await _authRepository.getBiometricCredentials();
    return result.fold(
      (failure) => [],
      (credentials) => credentials,
    );
  }

  /// Delete biometric credential
  Future<bool> deleteBiometricCredential(String id) async {
    final result = await _authRepository.deleteBiometricCredential(id);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) async {
        // Check if there are remaining credentials
        final credentials = await getBiometricCredentials();
        state = state.copyWith(
          isBiometricEnabled: credentials.isNotEmpty,
        );
        return success;
      },
    );
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _authRepository.setBiometricEnabled(enabled: false);
    state = state.copyWith(isBiometricEnabled: false);
  }

  /// Get device name for biometric registration
  Future<String> _getDeviceName() async {
    return 'Spendex Mobile Device';
  }

  /// Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.login(email, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (authResponse) {
        state = AuthState(
          isAuthenticated: true,
          user: authResponse.user,
          isBiometricAvailable: state.isBiometricAvailable,
          isBiometricEnabled: state.isBiometricEnabled,
        );
        return true;
      },
    );
  }

  /// Register
  Future<bool> register(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    state = state.copyWith(isLoading: true);

    final result =
        await _authRepository.register(email, password, name, phone);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.verifyOtp(email, otp);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (authResponse) {
        state = AuthState(
          isAuthenticated: true,
          user: authResponse.user,
          isBiometricAvailable: state.isBiometricAvailable,
          isBiometricEnabled: state.isBiometricEnabled,
        );
        return true;
      },
    );
  }

  /// Forgot Password
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.forgotPassword(email);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Reset Password
  Future<bool> resetPassword(String token, String password) async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepository.resetPassword(token, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState(
      isBiometricAvailable: state.isBiometricAvailable,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }

  /// Update user
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

/// Auth State Provider
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getIt<AuthRepository>(),
    getIt<SecureStorageService>(),
  );
});

/// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

/// Is Authenticated Provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// Biometric Available Provider
final biometricAvailableProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isBiometricAvailable;
});

/// Biometric Enabled Provider
final biometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isBiometricEnabled;
});

/// Biometric Loading Provider
final biometricLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isBiometricLoading;
});
