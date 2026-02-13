import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/security/security_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/pin_input.dart';

/// PIN Entry/Lock Screen with biometric authentication and failed attempts tracking.
///
/// Features:
/// - 4-digit PIN entry with verification using PinService
/// - Biometric authentication (fingerprint/face) using BiometricService
/// - Failed attempts tracking via PinService (max 5 attempts)
/// - Auto-lockout for 30 minutes after 5 failed attempts
/// - Countdown timer during lockout period
/// - User avatar and info display
/// - Forgot PIN option (requires logout)
/// - Screenshot prevention
/// - Material 3 design with dark mode support
class PinEntryScreen extends ConsumerStatefulWidget {
  const PinEntryScreen({super.key});

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _pinInputKey = GlobalKey<PinInputState>();

  // Services from DI
  late final PinService _pinService;
  late final BiometricService _biometricService;

  // ignore: unused_field
  String _enteredPin = '';
  String? _errorMessage;
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockoutEndTime;
  String _remainingTime = '';
  Timer? _countdownTimer;
  bool _isBiometricLoading = false;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // Get services from DI
    _pinService = getIt<PinService>();
    _biometricService = getIt<BiometricService>();
    _initializeScreen();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _enteredPin = '';
    super.dispose();
  }

  Future<void> _initializeScreen() async {
    await _loadFailedAttempts();
    await _checkLockoutStatus();
    await _checkBiometricAvailability();
  }

  Future<void> _loadFailedAttempts() async {
    try {
      final attempts = await _pinService.getFailedAttempts();
      if (mounted) {
        setState(() {
          _failedAttempts = attempts;
        });
      }
    } catch (e) {
      // Ignore errors loading failed attempts
    }
  }

  Future<void> _checkLockoutStatus() async {
    try {
      final isLocked = await _pinService.isLocked();
      if (isLocked) {
        final lockoutEndTime = await _pinService.getLockoutEndTime();
        if (mounted) {
          setState(() {
            _isLocked = true;
            _lockoutEndTime = lockoutEndTime;
          });
          _startCountdownTimer();
        }
      } else {
        if (mounted) {
          setState(() {
            _isLocked = false;
            _lockoutEndTime = null;
            _failedAttempts = 0;
          });
        }
      }
    } catch (e) {
      // Ignore errors checking lockout
    }
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lockoutEndTime == null) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final difference = _lockoutEndTime!.difference(now);

      if (difference.isNegative || difference.inSeconds <= 0) {
        timer.cancel();
        _clearLockout();
      } else {
        if (mounted) {
          setState(() {
            final minutes = difference.inMinutes;
            final seconds = difference.inSeconds % 60;
            _remainingTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          });
        }
      }
    });
  }

  Future<void> _clearLockout() async {
    try {
      await _pinService.resetFailedAttempts();
      if (mounted) {
        setState(() {
          _isLocked = false;
          _lockoutEndTime = null;
          _failedAttempts = 0;
        });
      }
    } catch (e) {
      // Ignore errors clearing lockout
    }
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (mounted) {
        setState(() {
          _isBiometricAvailable = isAvailable;
          _isBiometricEnabled = isEnabled;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isBiometricAvailable = false;
          _isBiometricEnabled = false;
        });
      }
    }
  }

  Future<void> _verifyPin(String pin) async {
    if (_isLocked) return;

    try {
      final isValid = await _pinService.verifyPin(pin);

      if (isValid) {
        _enteredPin = '';
        // Refresh the PIN auth state provider
        ref.read(pinAuthStateProvider.notifier).refresh();
        if (mounted) {
          context.go('/home');
        }
      } else {
        // PIN was incorrect - get updated state from service
        final failedAttempts = await _pinService.getFailedAttempts();
        final isLocked = await _pinService.isLocked();

        if (isLocked) {
          final lockoutEndTime = await _pinService.getLockoutEndTime();
          if (mounted) {
            setState(() {
              _isLocked = true;
              _lockoutEndTime = lockoutEndTime;
              _failedAttempts = failedAttempts;
              _errorMessage = null;
            });
            _startCountdownTimer();
          }
        } else {
          final remainingAttempts = PinAuthState.maxAttempts - failedAttempts;
          if (mounted) {
            setState(() {
              _failedAttempts = failedAttempts;
              _errorMessage = 'Incorrect PIN. $remainingAttempts ${remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining.';
            });
            _pinInputKey.currentState?.showError();
            _pinInputKey.currentState?.clear();
          }
        }
        _enteredPin = '';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to verify PIN. Please try again.';
        });
        _pinInputKey.currentState?.showError();
        _pinInputKey.currentState?.clear();
      }
      _enteredPin = '';
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isLocked) return;

    setState(() {
      _isBiometricLoading = true;
      _errorMessage = null;
    });

    try {
      final authenticated = await _biometricService.authenticateWithBiometric(
        reason: 'Unlock Spendex',
      );

      if (authenticated) {
        // Reset failed attempts on successful biometric auth
        await _pinService.resetFailedAttempts();
        ref.read(pinAuthStateProvider.notifier).resetFailedAttempts();

        if (mounted) {
          context.go('/home');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Biometric authentication failed';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Biometric authentication error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBiometricLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPinDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Forgot Your PIN?',
          style: SpendexTheme.headlineMedium,
        ),
        content: Text(
          'To reset your PIN, you need to logout and login again.',
          style: SpendexTheme.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: SpendexTheme.titleMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      body: SafeArea(
        child: _isLocked ? _buildLockoutScreen() : _buildPinEntryScreen(authState, isDark),
      ),
    );
  }

  Widget _buildPinEntryScreen(AuthState authState, bool isDark) {
    // Show biometric button only if available AND enabled
    final showBiometric = _isBiometricAvailable && _isBiometricEnabled;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: SpendexTheme.spacing4xl),
            _buildLogo(),
            const SizedBox(height: SpendexTheme.spacing3xl),
            _buildUserInfo(authState, isDark),
            const SizedBox(height: SpendexTheme.spacing4xl),
            _buildTitle(isDark),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildSubtitle(isDark),
            const SizedBox(height: SpendexTheme.spacing3xl),
            _buildPinInput(),
            if (_errorMessage != null) ...[
              const SizedBox(height: SpendexTheme.spacingLg),
              _buildErrorMessage(_errorMessage!, isDark),
            ],
            if (_failedAttempts > 0 && _failedAttempts < PinAuthState.maxAttempts) ...[
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildAttemptsIndicator(isDark),
            ],
            const SizedBox(height: SpendexTheme.spacing4xl),
            if (showBiometric) ...[
              _buildBiometricButton(isDark),
              const SizedBox(height: SpendexTheme.spacing2xl),
            ],
            _buildForgotPinButton(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Iconsax.wallet_3,
        size: 64,
        color: Colors.white,
      ),
    );
  }

  Widget _buildUserInfo(AuthState authState, bool isDark) {
    final user = authState.user;
    if (user == null) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SpendexColors.primaryGradient,
            border: Border.all(
              color: SpendexColors.primary.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: SpendexTheme.displayLarge.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Text(
          user.name,
          style: SpendexTheme.headlineMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(bool isDark) {
    return Text(
      'Enter PIN to Unlock',
      style: SpendexTheme.headlineMedium.copyWith(
        fontSize: 24,
        color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      'Enter your 4-digit PIN',
      style: SpendexTheme.bodyMedium.copyWith(
        color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPinInput() {
    return PinInput(
      key: _pinInputKey,
      autoFocus: _isLocked == false,
      onCompleted: (pin) {
        setState(() {
          _enteredPin = pin;
        });
        _verifyPin(pin);
      },
      onChanged: (pin) {
        if (_errorMessage != null) {
          setState(() {
            _errorMessage = null;
          });
        }
      },
    );
  }

  Widget _buildErrorMessage(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
        vertical: SpendexTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.warning_2,
            color: SpendexColors.expense,
            size: 20,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Flexible(
            child: Text(
              message,
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptsIndicator(bool isDark) {
    final remainingAttempts = PinAuthState.maxAttempts - _failedAttempts;
    final isWarning = remainingAttempts <= 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(PinAuthState.maxAttempts, (index) {
        final isFailed = index < _failedAttempts;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFailed
                ? (isWarning ? SpendexColors.expense : SpendexColors.warning)
                : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          ),
        );
      }),
    );
  }

  Widget _buildBiometricButton(bool isDark) {
    return GestureDetector(
      onTap: _isBiometricLoading ? null : _authenticateWithBiometric,
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        decoration: BoxDecoration(
          color: isDark
              ? SpendexColors.darkSurface
              : SpendexColors.lightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            width: 2,
          ),
        ),
        child: _isBiometricLoading
            ? SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SpendexColors.primary,
                ),
              )
            : Icon(
                Iconsax.finger_scan,
                size: 32,
                color: SpendexColors.primary,
              ),
      ),
    );
  }

  Widget _buildForgotPinButton(bool isDark) {
    return TextButton(
      onPressed: _showForgotPinDialog,
      child: Text(
        'Forgot PIN?',
        style: SpendexTheme.bodyMedium.copyWith(
          color: SpendexColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLockoutScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.lock,
                size: 60,
                color: SpendexColors.expense,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            Text(
              'Account Locked',
              style: SpendexTheme.headlineMedium.copyWith(
                fontSize: 24,
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'Too many failed attempts.\nPlease wait before trying again.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpendexTheme.spacing3xl),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacing2xl,
                vertical: SpendexTheme.spacingLg,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.timer_1,
                    color: SpendexColors.expense,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Text(
                    _remainingTime.isNotEmpty ? _remainingTime : '30:00',
                    style: SpendexTheme.headlineMedium.copyWith(
                      fontSize: 32,
                      color: SpendexColors.expense,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpendexTheme.spacing4xl),
            _buildForgotPinButton(isDark),
          ],
        ),
      ),
    );
  }
}
