import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/social_auth_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/connectivity_checker.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Social auth provider type for loading state
enum SocialAuthProviderType { google, apple, facebook }

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
    this.isSocialLoading = false,
    this.loadingSocialProvider,
  });

  const AuthState.initial()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false,
        isSocialLoading = false,
        loadingSocialProvider = null;

  const AuthState.loading()
      : isLoading = true,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false,
        isSocialLoading = false,
        loadingSocialProvider = null;

  const AuthState.authenticated(this.user)
      : isLoading = false,
        isAuthenticated = true,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false,
        isSocialLoading = false,
        loadingSocialProvider = null;

  const AuthState.unauthenticated()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false,
        isSocialLoading = false,
        loadingSocialProvider = null;

  const AuthState.error(this.error)
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        isBiometricAvailable = false,
        isBiometricEnabled = false,
        isBiometricLoading = false,
        isSocialLoading = false,
        loadingSocialProvider = null;

  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;
  final bool isBiometricLoading;
  final bool isSocialLoading;
  final SocialAuthProviderType? loadingSocialProvider;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
    bool? isBiometricLoading,
    bool? isSocialLoading,
    SocialAuthProviderType? loadingSocialProvider,
    bool clearLoadingProvider = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricLoading: isBiometricLoading ?? this.isBiometricLoading,
      isSocialLoading: isSocialLoading ?? this.isSocialLoading,
      loadingSocialProvider: clearLoadingProvider
          ? null
          : (loadingSocialProvider ?? this.loadingSocialProvider),
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
        isSocialLoading,
        loadingSocialProvider,
      ];
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository, this._secureStorage)
      : super(const AuthState.initial()) {
    _socialAuthService = getIt<SocialAuthService>();
  }

  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  late final SocialAuthService _socialAuthService;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    final isAuth = await _secureStorage.isAuthenticated();
    if (isAuth) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => state = const AuthState.unauthenticated(),
        (user) => state = AuthState.authenticated(user),
      );
    } else {
      state = const AuthState.unauthenticated();
    }
    await checkBiometricAvailability();
  }

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
      state = state.copyWith(
        isBiometricAvailable: false,
        isBiometricEnabled: false,
      );
    }
  }

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

  Future<bool> loginWithBiometric() async {
    state = state.copyWith(isBiometricLoading: true);
    try {
      final authenticated = await authenticateWithBiometrics();
      if (authenticated == false) {
        state = state.copyWith(
          isBiometricLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }
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
          final credential = {
            'challenge': options['challenge'],
            'deviceVerified': true,
            'timestamp': DateTime.now().toIso8601String(),
          };
          final loginResult =
              await _authRepository.loginWithBiometric(credential);
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

  Future<bool> registerBiometric() async {
    state = state.copyWith(isBiometricLoading: true);
    try {
      final authenticated = await authenticateWithBiometrics();
      if (authenticated == false) {
        state = state.copyWith(
          isBiometricLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }
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
          final credential = {
            'challenge': options['challenge'],
            'deviceVerified': true,
            'deviceName': await _getDeviceName(),
            'timestamp': DateTime.now().toIso8601String(),
          };
          final registerResult =
              await _authRepository.registerBiometric(credential);
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

  Future<List<Map<String, dynamic>>> getBiometricCredentials() async {
    final result = await _authRepository.getBiometricCredentials();
    return result.fold(
      (failure) => [],
      (credentials) => credentials,
    );
  }

  Future<bool> deleteBiometricCredential(String id) async {
    final result = await _authRepository.deleteBiometricCredential(id);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (success) async {
        final credentials = await getBiometricCredentials();
        state = state.copyWith(
          isBiometricEnabled: credentials.isNotEmpty,
        );
        return success;
      },
    );
  }

  Future<void> disableBiometric() async {
    await _authRepository.setBiometricEnabled(enabled: false);
    state = state.copyWith(isBiometricEnabled: false);
  }

  Future<String> _getDeviceName() async {
    return 'Spendex Mobile Device';
  }

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

  Future<bool> signInWithGoogle() async {
    // Check connectivity first
    if (!await ConnectivityChecker.hasConnection()) {
      state = state.copyWith(
        error:
            'No internet connection. Please check your network and try again.',
        isSocialLoading: false,
      );
      return false;
    }

    state = state.copyWith(
      isSocialLoading: true,
      loadingSocialProvider: SocialAuthProviderType.google,
      error: null,
    );

    final credentialsResult = await _socialAuthService.signInWithGoogle();
    return await credentialsResult.fold(
      (failure) {
        state = state.copyWith(
          isSocialLoading: false,
          error: failure.message,
          clearLoadingProvider: true,
        );
        return false;
      },
      (credentials) async {
        final result =
            await _authRepository.signInWithSocial(credentials.toJson());
        return result.fold(
          (failure) {
            state = state.copyWith(
              isSocialLoading: false,
              error: failure.message,
              clearLoadingProvider: true,
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
  }

  Future<bool> signInWithApple() async {
    if (_socialAuthService.isAppleSignInAvailable == false) {
      state = state.copyWith(
        error: 'Apple Sign-In is only available on iOS and macOS',
      );
      return false;
    }

    // Check connectivity first
    if (!await ConnectivityChecker.hasConnection()) {
      state = state.copyWith(
        error:
            'No internet connection. Please check your network and try again.',
        isSocialLoading: false,
      );
      return false;
    }

    state = state.copyWith(
      isSocialLoading: true,
      loadingSocialProvider: SocialAuthProviderType.apple,
      error: null,
    );

    final credentialsResult = await _socialAuthService.signInWithApple();
    return await credentialsResult.fold(
      (failure) {
        state = state.copyWith(
          isSocialLoading: false,
          error: failure.message,
          clearLoadingProvider: true,
        );
        return false;
      },
      (credentials) async {
        final result =
            await _authRepository.signInWithSocial(credentials.toJson());
        return result.fold(
          (failure) {
            state = state.copyWith(
              isSocialLoading: false,
              error: failure.message,
              clearLoadingProvider: true,
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
  }

  Future<bool> signInWithFacebook() async {
    // Check connectivity first
    if (!await ConnectivityChecker.hasConnection()) {
      state = state.copyWith(
        error:
            'No internet connection. Please check your network and try again.',
        isSocialLoading: false,
      );
      return false;
    }

    state = state.copyWith(
      isSocialLoading: true,
      loadingSocialProvider: SocialAuthProviderType.facebook,
      error: null,
    );

    final credentialsResult = await _socialAuthService.signInWithFacebook();
    return await credentialsResult.fold(
      (failure) {
        state = state.copyWith(
          isSocialLoading: false,
          error: failure.message,
          clearLoadingProvider: true,
        );
        return false;
      },
      (credentials) async {
        final result =
            await _authRepository.signInWithSocial(credentials.toJson());
        return result.fold(
          (failure) {
            state = state.copyWith(
              isSocialLoading: false,
              error: failure.message,
              clearLoadingProvider: true,
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
  }

  bool get isAppleSignInAvailable => _socialAuthService.isAppleSignInAvailable;

  Future<bool> register(
    String email,
    String password,
    String name,
    String? phone,
  ) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.register(email, password, name, phone);
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

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    state = state.copyWith(isLoading: true);
    final result =
        await _authRepository.changePassword(currentPassword, newPassword);
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

  Future<bool> updatePreferences(UserPreferences preferences) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.updatePreferences(preferences);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(isLoading: false, user: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Clear all secure storage first
      await _secureStorage.clearAll();

      // Sign out from social providers
      await _socialAuthService.signOutAll();

      // Clear any cached user data
      await _clearLocalUserData();

      // Call backend logout
      final result = await _authRepository.logout();

      result.fold(
        (failure) {
          // Even if backend fails, we've cleared local data - consider logged out
          AppLogger.w('Backend logout failed: ${failure.message}');
          state = const AuthState.unauthenticated();
        },
        (_) {
          state = const AuthState.unauthenticated();
        },
      );
    } catch (e) {
      AppLogger.e('Logout error: $e');
      // Force logout even on error
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> _clearLocalUserData() async {
    try {
      // Clear shared preferences user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user');
      await prefs.remove('last_sync');
      await prefs.remove('remember_email');
    } catch (e) {
      AppLogger.w('Failed to clear local user data: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }

  Future<void> refreshUser() async {
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (user) => state = state.copyWith(user: user),
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    getIt<AuthRepository>(),
    getIt<SecureStorageService>(),
  );
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});

final isBiometricAvailableProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isBiometricAvailable;
});

final isBiometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isBiometricEnabled;
});

final isSocialLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isSocialLoading;
});

final loadingSocialProviderProvider = Provider<SocialAuthProviderType?>((ref) {
  return ref.watch(authStateProvider).loadingSocialProvider;
});

final isAppleSignInAvailableProvider = Provider<bool>((ref) {
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
});
