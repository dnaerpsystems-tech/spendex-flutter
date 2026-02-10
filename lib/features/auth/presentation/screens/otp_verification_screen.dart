import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pinput/pinput.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

/// OTP Verification Screen
///
/// A professional OTP verification screen with:
/// - 6-digit OTP input using Pinput
/// - Auto-submit functionality
/// - Resend timer with max attempts
/// - Animations (entrance, shake, success, pulse)
/// - Error handling with visual feedback
/// - Navigation based on purpose (verification/password_reset)
class OtpVerificationScreen extends ConsumerStatefulWidget { // "verification" or "password_reset"
  const OtpVerificationScreen({
    required this.email,
    required this.purpose,
    super.key,
  });

  final String email;
  final String purpose;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  // Timer
  Timer? _resendTimer;
  int _remainingSeconds = 60;
  int _resendAttempts = 0;
  static const int _maxResendAttempts = 3;

  // State
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _hasError = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _shakeController;
  late AnimationController _successController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startResendTimer();
    _focusNode.requestFocus();
  }

  void _initAnimations() {
    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 1, curve: Curves.easeOutCubic),
      ),
    );

    // Shake animation for errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _shakeController,
        curve: Curves.elasticIn,
      ),
    );

    // Success animation
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _successScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut,
      ),
    );

    _successOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _entranceController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startResendTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _resendTimer?.cancel();
    _entranceController.dispose();
    _shakeController.dispose();
    _successController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Format remaining seconds as mm:ss
  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Handle OTP completion - called when all 6 digits are entered
  Future<void> _onOtpCompleted(String otp) async {
    if (otp.length != 6 || _isVerifying || _isSuccess) {
      return;
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Wait briefly to let user see the entered code
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    await _verifyOtp(otp);
  }

  /// Verify OTP with backend
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isVerifying = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(authStateProvider.notifier).verifyOtp(
            widget.email,
            otp,
          );

      if (!mounted) {
        return;
      }

      if (success) {
        await _handleVerificationSuccess();
      } else {
        await _handleVerificationError(
          ref.read(authStateProvider).error ?? 'Invalid OTP. Please try again.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      await _handleVerificationError('An error occurred. Please try again.');
    }
  }

  /// Handle successful verification
  Future<void> _handleVerificationSuccess() async {
    setState(() {
      _isVerifying = false;
      _isSuccess = true;
    });

    // Haptic success feedback
    HapticFeedback.heavyImpact();

    // Play success animation
    await _successController.forward();

    // Wait a moment to show success state
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    // Navigate based on purpose
    if (widget.purpose == 'verification') {
      // Account verified, go to home
      context.go(AppRoutes.home);
    } else if (widget.purpose == 'password_reset') {
      // OTP verified for password reset, go to reset password screen
      context.pushReplacement(
        '${AppRoutes.resetPassword}?email=${Uri.encodeComponent(widget.email)}&token=${_otpController.text}',
      );
    }
  }

  /// Handle verification error
  Future<void> _handleVerificationError(String message) async {
    // Haptic error feedback
    HapticFeedback.heavyImpact();

    setState(() {
      _isVerifying = false;
      _hasError = true;
      _errorMessage = message;
    });

    // Play shake animation
    await _shakeController.forward();
    _shakeController.reset();

    // Clear the OTP input after shake
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _otpController.clear();
      _focusNode.requestFocus();
    }

    // Check if OTP expired
    if (message.toLowerCase().contains('expired')) {
      // Auto-trigger resend if possible
      if (_canResend && _resendAttempts < _maxResendAttempts) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          await _handleResend();
        }
      }
    }
  }

  /// Handle resend OTP
  Future<void> _handleResend() async {
    if (!_canResend || _isResending || _resendAttempts >= _maxResendAttempts) {
      return;
    }

    setState(() {
      _isResending = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.sendOtp(widget.email, widget.purpose);

      if (!mounted) {
        return;
      }

      result.fold(
        (failure) {
          setState(() {
            _isResending = false;
            _hasError = true;
            _errorMessage = failure.message;
          });

          // Check if rate limited
          if (failure.message.toLowerCase().contains('rate') ||
              failure.message.toLowerCase().contains('limit') ||
              failure.message.toLowerCase().contains('too many')) {
            setState(() {
              _canResend = false;
              _remainingSeconds = 120; // Longer wait for rate limiting
            });
            _startResendTimer();
          }
        },
        (_) {
          setState(() {
            _isResending = false;
            _resendAttempts++;
          });

          // Restart timer
          _startResendTimer();

          // Show success snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Verification code sent successfully'),
                  ),
                ],
              ),
              backgroundColor: SpendexColors.income,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Haptic feedback
          HapticFeedback.mediumImpact();
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isResending = false;
        _hasError = true;
        _errorMessage = 'Failed to resend code. Please try again.';
      });
    }
  }

  /// Handle back button press
  Future<bool> _onWillPop() async {
    if (_isVerifying) {
      return false;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? SpendexColors.darkSurface
              : SpendexColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Cancel Verification?',
            style: SpendexTheme.headlineMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'You will need to request a new verification code.',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Stay',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Cancel',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.expense,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// Handle change email action
  void _handleChangeEmail() {
    HapticFeedback.lightImpact();
    context.pop();
  }

  /// Handle contact support action
  void _handleContactSupport() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Iconsax.message_question, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text('Please contact support@spendex.app for assistance'),
            ),
          ],
        ),
        backgroundColor: SpendexColors.transfer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? SpendexColors.darkBackground
            : SpendexColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Animated Icon
                    _buildAnimatedIcon(isDark),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      widget.purpose == 'password_reset'
                          ? 'Reset Password'
                          : 'Verify Your Email',
                      style: SpendexTheme.displayLarge.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextPrimary
                            : SpendexColors.lightTextPrimary,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'We\'ve sent a 6-digit verification code to',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // Email
                    Text(
                      widget.email,
                      style: SpendexTheme.titleMedium.copyWith(
                        color: SpendexColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // OTP Input
                    _buildOtpInput(isDark, screenWidth),

                    const SizedBox(height: 16),

                    // Status Message
                    _buildStatusMessage(isDark),

                    const SizedBox(height: 24),

                    // Error Message
                    if (_hasError && _errorMessage != null) ...[
                      _buildErrorMessage(isDark),
                      const SizedBox(height: 16),
                    ],

                    // Resend Section
                    _buildResendSection(isDark),

                    const SizedBox(height: 40),

                    // Verify Button
                    _buildVerifyButton(),

                    const SizedBox(height: 16),

                    // Change Email Button
                    _buildChangeEmailButton(isDark),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build animated email/lock icon
  Widget _buildAnimatedIcon(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: _isSuccess
                  ? SpendexColors.incomeGradient
                  : SpendexColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isSuccess
                          ? SpendexColors.income
                          : SpendexColors.primary)
                      .withValues(alpha:0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isSuccess
                    ? ScaleTransition(
                        scale: _successScaleAnimation,
                        child: FadeTransition(
                          opacity: _successOpacityAnimation,
                          child: const Icon(
                            Iconsax.tick_circle5,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Icon(
                        widget.purpose == 'password_reset'
                            ? Iconsax.lock
                            : Iconsax.sms_tracking,
                        size: 48,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build OTP input field using Pinput
  Widget _buildOtpInput(bool isDark, double screenWidth) {
    // Calculate pin width based on screen size
    final pinWidth = ((screenWidth - 48 - 50) / 6).clamp(40.0, 56.0);
    final pinHeight = pinWidth * 1.1;

    final defaultPinTheme = PinTheme(
      width: pinWidth,
      height: pinHeight,
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isDark
            ? SpendexColors.darkTextPrimary
            : SpendexColors.lightTextPrimary,
      ),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpendexColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha:0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SpendexColors.primary,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpendexColors.primary),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SpendexColors.expense,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpendexColors.expense, width: 2),
      ),
    );

    final successPinTheme = defaultPinTheme.copyWith(
      textStyle: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: SpendexColors.income,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.income.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpendexColors.income, width: 2),
      ),
    );

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Pinput(
        controller: _otpController,
        focusNode: _focusNode,
        length: 6,
        autofocus: true,
        hapticFeedbackType: HapticFeedbackType.lightImpact,
        defaultPinTheme: _isSuccess
            ? successPinTheme
            : (_hasError ? errorPinTheme : defaultPinTheme),
        focusedPinTheme: focusedPinTheme,
        submittedPinTheme: _isSuccess
            ? successPinTheme
            : (_hasError ? errorPinTheme : submittedPinTheme),
        errorPinTheme: errorPinTheme,
        enabled: !_isVerifying && !_isSuccess,
        pinputAutovalidateMode: PinputAutovalidateMode.disabled,
        cursor: Container(
          width: 2,
          height: 24,
          decoration: BoxDecoration(
            color: SpendexColors.primary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        onCompleted: _onOtpCompleted,
        onChanged: (value) {
          // Clear error state when user starts typing
          if (_hasError && value.isNotEmpty) {
            setState(() {
              _hasError = false;
              _errorMessage = null;
            });
          }
        },
      ),
    );
  }

  /// Build status message (verifying, success, etc.)
  Widget _buildStatusMessage(bool isDark) {
    if (_isSuccess) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.tick_circle5,
            color: SpendexColors.income,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Verification successful!',
            style: SpendexTheme.bodyMedium.copyWith(
              color: SpendexColors.income,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (_isVerifying) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Verifying...',
            style: SpendexTheme.bodyMedium.copyWith(
              color: SpendexColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      'Enter the 6-digit code',
      style: SpendexTheme.bodyMedium.copyWith(
        color: isDark
            ? SpendexColors.darkTextTertiary
            : SpendexColors.lightTextTertiary,
      ),
    );
  }

  /// Build error message widget
  Widget _buildErrorMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpendexColors.expense.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconsax.warning_2,
            color: SpendexColors.expense,
            size: 20,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              _errorMessage!,
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build resend section
  Widget _buildResendSection(bool isDark) {
    // Check if max attempts reached
    if (_resendAttempts >= _maxResendAttempts) {
      return Column(
        children: [
          Text(
            'Maximum resend attempts reached',
            style: SpendexTheme.bodyMedium.copyWith(
              color: SpendexColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _handleContactSupport,
            icon: const Icon(
              Iconsax.message_question,
              size: 18,
              color: SpendexColors.primary,
            ),
            label: Text(
              'Contact Support',
              style: SpendexTheme.titleMedium.copyWith(
                color: SpendexColors.primary,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        if (_isResending)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.primary),
            ),
          )
        else if (_canResend)
          TextButton(
            onPressed: _handleResend,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Resend Code',
              style: SpendexTheme.titleMedium.copyWith(
                color: SpendexColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.timer_1,
                  size: 14,
                  color: SpendexColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formattedTime,
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.primary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Build verify button
  Widget _buildVerifyButton() {
    final isEnabled = _otpController.text.length == 6 &&
        !_isVerifying &&
        !_isSuccess;

    return AuthPrimaryButton(
      text: _isSuccess ? 'Verified!' : 'Verify Code',
      onPressed: isEnabled
          ? () => _verifyOtp(_otpController.text)
          : null,
      isLoading: _isVerifying,
      isEnabled: isEnabled,
      icon: _isSuccess ? Iconsax.tick_circle5 : Iconsax.shield_tick,
    );
  }

  /// Build change email button
  Widget _buildChangeEmailButton(bool isDark) {
    if (_isVerifying || _isSuccess) {
      return const SizedBox.shrink();
    }

    return TextButton(
      onPressed: _handleChangeEmail,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        'Change Email Address',
        style: SpendexTheme.bodyMedium.copyWith(
          color: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
          decoration: TextDecoration.underline,
          decorationColor: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
        ),
      ),
    );
  }
}
