import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/injection.dart';
import 'auto_lock_service.dart';
import 'device_security.dart';
import 'pin_service.dart';

/// Provider for the PIN service.
///
/// Returns the singleton instance from GetIt.
final pinServiceProvider = Provider<PinService>((ref) {
  return getIt<PinService>();
});

/// Provider for the auto-lock service.
///
/// Returns the singleton instance from GetIt.
final autoLockServiceProvider = Provider<AutoLockService>((ref) {
  return getIt<AutoLockService>();
});

/// State class for PIN authentication.
class PinAuthState {
  const PinAuthState({
    this.isPinSet = false,
    this.isLocked = false,
    this.failedAttempts = 0,
    this.lockoutEndTime,
    this.isLoading = false,
    this.error,
  });

  /// Whether a PIN has been set.
  final bool isPinSet;

  /// Whether the user is currently locked out.
  final bool isLocked;

  /// Number of failed PIN attempts.
  final int failedAttempts;

  /// When the lockout ends (if locked).
  final DateTime? lockoutEndTime;

  /// Whether a PIN operation is in progress.
  final bool isLoading;

  /// Error message from the last operation.
  final String? error;

  /// Maximum allowed failed attempts.
  static const int maxAttempts = 5;

  /// Remaining attempts before lockout.
  int get remainingAttempts => maxAttempts - failedAttempts;

  /// Whether the user is close to lockout.
  bool get isNearLockout => failedAttempts >= (maxAttempts - 2);

  /// Copy with updated values.
  PinAuthState copyWith({
    bool? isPinSet,
    bool? isLocked,
    int? failedAttempts,
    DateTime? lockoutEndTime,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearLockout = false,
  }) {
    return PinAuthState(
      isPinSet: isPinSet ?? this.isPinSet,
      isLocked: isLocked ?? this.isLocked,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutEndTime:
          clearLockout ? null : (lockoutEndTime ?? this.lockoutEndTime),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for PIN authentication state.
class PinAuthNotifier extends StateNotifier<PinAuthState> {
  PinAuthNotifier(this._pinService) : super(const PinAuthState()) {
    _initialize();
  }

  final PinService _pinService;

  /// Initialize the PIN auth state.
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isPinSet = await _pinService.isPinSet();
      final isLocked = await _pinService.isLocked();
      final failedAttempts = await _pinService.getFailedAttempts();
      final lockoutEndTime = await _pinService.getLockoutEndTime();

      state = PinAuthState(
        isPinSet: isPinSet,
        isLocked: isLocked,
        failedAttempts: failedAttempts,
        lockoutEndTime: lockoutEndTime,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load PIN state: $e',
      );
    }
  }

  /// Refresh the PIN auth state.
  Future<void> refresh() async {
    await _initialize();
  }

  /// Set a new PIN.
  Future<bool> setPin(String pin) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _pinService.setPin(pin);
      state = state.copyWith(
        isPinSet: true,
        isLoading: false,
        failedAttempts: 0,
        clearLockout: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify the entered PIN.
  Future<bool> verifyPin(String pin) async {
    if (state.isLocked) {
      state = state.copyWith(
        error: 'Account is locked. Please wait.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final isValid = await _pinService.verifyPin(pin);

      if (isValid) {
        state = state.copyWith(
          isLoading: false,
          failedAttempts: 0,
          clearLockout: true,
        );
        return true;
      } else {
        final failedAttempts = await _pinService.getFailedAttempts();
        final isLocked = await _pinService.isLocked();
        final lockoutEndTime = await _pinService.getLockoutEndTime();

        state = state.copyWith(
          isLoading: false,
          failedAttempts: failedAttempts,
          isLocked: isLocked,
          lockoutEndTime: lockoutEndTime,
          error: isLocked
              ? 'Too many failed attempts. Account locked.'
              : 'Incorrect PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to verify PIN: $e',
      );
      return false;
    }
  }

  /// Clear the PIN.
  Future<void> clearPin() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _pinService.clearPin();
      state = const PinAuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to clear PIN: $e',
      );
    }
  }

  /// Clear the error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Check if still locked and update state.
  Future<void> checkLockStatus() async {
    final isLocked = await _pinService.isLocked();
    if (isLocked == false && state.isLocked) {
      // Lockout has expired
      state = state.copyWith(
        isLocked: false,
        failedAttempts: 0,
        clearLockout: true,
      );
    } else if (isLocked) {
      final lockoutEndTime = await _pinService.getLockoutEndTime();
      state = state.copyWith(
        isLocked: true,
        lockoutEndTime: lockoutEndTime,
      );
    }
  }
}

/// Provider for PIN authentication state.
final pinAuthStateProvider =
    StateNotifierProvider<PinAuthNotifier, PinAuthState>((ref) {
  final pinService = ref.watch(pinServiceProvider);
  return PinAuthNotifier(pinService);
});

/// Provider for device security check.
///
/// Performs an async security check and returns the result.
final deviceSecurityCheckProvider =
    FutureProvider<SecurityCheckResult>((ref) async {
  return DeviceSecurity.performSecurityCheck();
});

/// Provider for device security status (convenience boolean).
final isDeviceSecureProvider = FutureProvider<bool>((ref) async {
  final result = await ref.watch(deviceSecurityCheckProvider.future);
  return result.isSecure;
});

/// State class for combined security status.
class SecurityState {
  const SecurityState({
    this.pinAuthState = const PinAuthState(),
    this.deviceSecurityResult,
    this.autoLockEnabled = true,
    this.autoLockTimeout = const Duration(minutes: 5),
  });

  /// PIN authentication state.
  final PinAuthState pinAuthState;

  /// Device security check result.
  final SecurityCheckResult? deviceSecurityResult;

  /// Whether auto-lock is enabled.
  final bool autoLockEnabled;

  /// Auto-lock timeout duration.
  final Duration autoLockTimeout;

  /// Whether the app should show PIN entry screen.
  bool get requiresAuth => pinAuthState.isPinSet;

  /// Whether all security checks pass.
  bool get isFullySecure {
    if (deviceSecurityResult == null) return true;
    return deviceSecurityResult!.isSecure;
  }

  /// Copy with updated values.
  SecurityState copyWith({
    PinAuthState? pinAuthState,
    SecurityCheckResult? deviceSecurityResult,
    bool? autoLockEnabled,
    Duration? autoLockTimeout,
  }) {
    return SecurityState(
      pinAuthState: pinAuthState ?? this.pinAuthState,
      deviceSecurityResult: deviceSecurityResult ?? this.deviceSecurityResult,
      autoLockEnabled: autoLockEnabled ?? this.autoLockEnabled,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    );
  }
}

/// Provider for combined security state.
final securityStateProvider = Provider<SecurityState>((ref) {
  final pinAuthState = ref.watch(pinAuthStateProvider);
  final deviceSecurityAsync = ref.watch(deviceSecurityCheckProvider);
  final autoLockService = ref.watch(autoLockServiceProvider);

  return SecurityState(
    pinAuthState: pinAuthState,
    deviceSecurityResult: deviceSecurityAsync.valueOrNull,
    autoLockEnabled: autoLockService.isEnabled,
    autoLockTimeout: autoLockService.timeout,
  );
});
