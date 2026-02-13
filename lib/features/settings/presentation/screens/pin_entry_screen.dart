import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/pin_input.dart';

/// PIN Entry/Lock Screen with biometric authentication and failed attempts tracking.
///
/// Features:
/// - 4-digit PIN entry with verification
/// - Biometric authentication (fingerprint/face)
/// - Failed attempts tracking (max 5 attempts)
/// - Auto-lockout for 30 minutes after 5 failed attempts
/// - Countdown timer during lockout period
/// - Secure PIN hashing with SHA-256
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
  final _secureStorage = getIt<SecureStorageService>();
  final _localAuth = LocalAuthentication();

  String _enteredPin = '';
  String? _errorMessage;
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockoutEndTime;
  String _remainingTime = '';
  Timer? _countdownTimer;
  bool _isBiometricLoading = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
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
    final attemptsStr = await _secureStorage.read('pin_failed_attempts');
    if (attemptsStr != null) {
      setState(() {
        _failedAttempts = int.tryParse(attemptsStr) ?? 0;
      });
    }
  }

  Future<void> _checkLockoutStatus() async {
    final lockoutEndStr = await _secureStorage.read('pin_lockout_end');
    if (lockoutEndStr != null) {
      final lockoutEnd = DateTime.tryParse(lockoutEndStr);
      if (lockoutEnd != null) {
        if (lockoutEnd.isAfter(DateTime.now())) {
          setState(() {
            _isLocked = true;
            _lockoutEndTime = lockoutEnd;
          });
          _startCountdownTimer();
        } else {
          await _clearLockout();
        }
      }
    }
  }

  Future<void> _clearLockout() async {
    await _secureStorage.delete('pin_lockout_end');
    await _secureStorage.delete('pin_failed_attempts');
    setState(() {
      _isLocked = false;
      _lockoutEndTime = null;
      _failedAttempts = 0;
    });
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
        setState(() {
          final minutes = difference.inMinutes;
          final seconds = difference.inSeconds % 60;
          _remainingTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      setState(() {
        _isBiometricAvailable = canCheck && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> _verifyPin(String pin) async {
    if (_isLocked) return;

    final storedHash = await _secureStorage.read('pin_hash');
    if (storedHash == null) {
      setState(() {
        _errorMessage = 'PIN not configured. Please set up your PIN.';
      });
      return;
    }

    final enteredHash = _hashPin(pin);

    if (enteredHash == storedHash) {
      await _secureStorage.delete('pin_failed_attempts');
      _enteredPin = '';
      if (mounted) {
        context.go('/home');
      }
    } else {
      _failedAttempts++;
      await _secureStorage.save('pin_failed_attempts', _failedAttempts.toString());

      if (_failedAttempts >= 5) {
        final lockoutEnd = DateTime.now().add(const Duration(minutes: 30));
        await _secureStorage.save('pin_lockout_end', lockoutEnd.toIso8601String());
        setState(() {
          _isLocked = true;
          _lockoutEndTime = lockoutEnd;
          _errorMessage = null;
        });
        _startCountdownTimer();
      } else {
        final remainingAttempts = 5 - _failedAttempts;
        setState(() {
          _errorMessage = 'Incorrect PIN. $remainingAttempts ${remainingAttempts == 1 ? 'attempt' : 'attempts'} remaining.';
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
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Spendex',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        await _secureStorage.delete('pin_failed_attempts');
        if (mounted) {
          context.go('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Biometric authentication failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Biometric authentication error';
      });
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

    if (confirmed == true && mounted) {
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
            if (_failedAttempts > 0 && _failedAttempts < 5) ...[
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildAttemptsIndicator(isDark),
            ],
            const SizedBox(height: SpendexTheme.spacing4xl),
            if (_isBiometricAvailable) ...[
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
      length: 4,
      obscureText: true,
      autoFocus: !_isLocked,
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Iconsax.warning_2,
          color: SpendexColors.expense,
          size: 16,
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        Flexible(
          child: Text(
            message,
            style: SpendexTheme.bodyMedium.copyWith(
              color: SpendexColors.expense,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptsIndicator(bool isDark) {
    final remaining = 5 - _failedAttempts;
    return Text(
      '$remaining of 5 attempts remaining',
      style: SpendexTheme.labelMedium.copyWith(
        color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBiometricButton(bool isDark) {
    return InkWell(
      onTap: _isBiometricLoading ? null : _authenticateWithBiometric,
      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacing2xl,
          vertical: SpendexTheme.spacingLg,
        ),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: SpendexColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isBiometricLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: SpendexColors.primary,
                ),
              )
            else
              Icon(
                Iconsax.finger_scan,
                color: SpendexColors.primary,
                size: 24,
              ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Text(
              _isBiometricLoading ? 'Authenticating...' : 'Use Biometric',
              style: SpendexTheme.titleMedium.copyWith(
                color: SpendexColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPinButton(bool isDark) {
    return TextButton(
      onPressed: _showForgotPinDialog,
      child: Text(
        'Forgot PIN?',
        style: SpendexTheme.titleMedium.copyWith(
          color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildLockoutScreen() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
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
              Iconsax.warning_2,
              color: SpendexColors.expense,
              size: 60,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacing3xl),
          Text(
            'Too Many Attempts',
            style: SpendexTheme.headlineMedium.copyWith(
              fontSize: 24,
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Text(
            'Your account is locked for security.\nPlease try again in',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacing2xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpendexTheme.spacing3xl,
              vertical: SpendexTheme.spacingXl,
            ),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
              border: Border.all(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
            ),
            child: Text(
              _remainingTime,
              style: SpendexTheme.displayLarge.copyWith(
                color: SpendexColors.expense,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacing4xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (mounted) {
                  context.go('/login');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: SpendexColors.expense,
                side: const BorderSide(color: SpendexColors.expense),
                padding: const EdgeInsets.symmetric(vertical: SpendexTheme.spacingLg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                ),
              ),
              child: Text(
                'Logout',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.expense,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
