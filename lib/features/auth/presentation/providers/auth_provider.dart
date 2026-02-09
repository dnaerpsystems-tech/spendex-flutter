import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';

/// Auth State
class AuthState extends Equatable {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  const AuthState.initial()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null;

  const AuthState.loading()
      : isLoading = true,
        isAuthenticated = false,
        user = null,
        error = null;

  AuthState.authenticated(UserModel user)
      : isLoading = false,
        isAuthenticated = true,
        user = user,
        error = null;

  const AuthState.unauthenticated()
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = null;

  AuthState.error(String error)
      : isLoading = false,
        isAuthenticated = false,
        user = null,
        error = error;

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isAuthenticated, user, error];
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;

  AuthNotifier(this._authRepository, this._secureStorage)
      : super(const AuthState.initial());

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
  }

  /// Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.login(email, password);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (authResponse) {
        state = AuthState.authenticated(authResponse.user);
        return true;
      },
    );
  }

  /// Register
  Future<bool> register(String email, String password, String name, String? phone) async {
    state = state.copyWith(isLoading: true, error: null);

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

  /// Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _authRepository.verifyOtp(email, otp);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (authResponse) {
        state = AuthState.authenticated(authResponse.user);
        return true;
      },
    );
  }

  /// Forgot Password
  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

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
    state = state.copyWith(isLoading: true, error: null);

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
    state = const AuthState.unauthenticated();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

/// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
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
