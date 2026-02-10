import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// Forgot Password Screen
///
/// A professional forgot password screen with:
/// - Animated entrance (fade + slide up)
/// - Pulsing lock icon animation
/// - Email validation with debouncing
/// - Animated transition to success state
/// - Resend code timer functionality
/// - Open email app integration
/// - Navigation to OTP verification screen
/// - Comprehensive error handling
/// - Email masking for privacy
/// - Keyboard handling and scroll management
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();

  // State
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _canResend = false;
  int _resendCooldown = 30;
  String? _errorMessage;
  bool _hasInteracted = false;

  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _iconPulseController;
  late AnimationController _successController;
  late AnimationController _shakeController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconPulseAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _checkmarkAnimation;

  // Timers
  Timer? _resendTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();

    // Start entrance animation
    _entranceController.forward();

    // Request focus after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  /// Initialize all animation controllers and animations
  void _initAnimations() {
    // Entrance animation controller
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Icon pulse animation
    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _iconPulseController,
        curve: Curves.easeInOut,
      ),
    );

    _iconPulseController.repeat(reverse: true);

    // Success animation controller
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _successScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut,
      ),
    );

    _successOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
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
  }

  /// Setup input listeners
  void _setupListeners() {
    _emailController.addListener(_onEmailChanged);
  }

  /// Handle email input changes with debouncing
  void _onEmailChanged() {
    // Clear error when user starts typing
    if (_errorMessage != null && _hasInteracted) {
      setState(() {
        _errorMessage = null;
      });
    }

    // Debounce validation
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_hasInteracted && mounted) {
        _formKey.currentState?.validate();
      }
    });
  }

  /// Start the resend cooldown timer
  void _startResendTimer() {
    _resendCooldown = 30;
    _canResend = false;
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _emailFocusNode.dispose();
    _resendTimer?.cancel();
    _debounceTimer?.cancel();
    _entranceController.dispose();
    _iconPulseController.dispose();
    _successController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Validate email address
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    value = value.trim();
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Mask email for privacy display (e.g., u***r@example.com)
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '$name***@$domain';
    }

    final visibleStart = name.substring(0, 1);
    final visibleEnd = name.length > 3 ? name.substring(name.length - 1) : '';

    return '$visibleStart***$visibleEnd@$domain';
  }

  /// Format remaining seconds as mm:ss
  String get _formattedCooldown {
    final minutes = _resendCooldown ~/ 60;
    final seconds = _resendCooldown % 60;
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '${seconds}s';
  }

  /// Shake form on error
  void _shakeForm() {
    HapticFeedback.heavyImpact();
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    // Mark as interacted for validation display
    setState(() {
      _hasInteracted = true;
    });

    // Clear any previous auth error
    ref.read(authStateProvider.notifier).clearError();

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      _shakeForm();
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final success =
          await ref.read(authStateProvider.notifier).forgotPassword(email);

      if (!mounted) return;

      if (success) {
        // Transition to success state
        await _transitionToSuccess();
      } else {
        // Handle error from auth state
        final authError = ref.read(authStateProvider).error;
        _handleError(authError ?? 'Failed to send reset code. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _handleError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle error states with appropriate UI feedback
  void _handleError(String message) {
    HapticFeedback.heavyImpact();

    // Determine error type for specific handling
    final lowerMessage = message.toLowerCase();
    String displayMessage = message;

    if (lowerMessage.contains('not found') || lowerMessage.contains('no account')) {
      displayMessage = 'No account found with this email address';
    } else if (lowerMessage.contains('rate') ||
        lowerMessage.contains('too many') ||
        lowerMessage.contains('limit')) {
      // Extract remaining time if available, otherwise show generic message
      displayMessage = 'Too many attempts. Please try again later.';
    } else if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('internet')) {
      displayMessage = 'Connection failed. Please check your internet connection.';
    }

    setState(() {
      _errorMessage = displayMessage;
      _isLoading = false;
    });

    _shakeForm();
  }

  /// Transition to success view with animation
  Future<void> _transitionToSuccess() async {
    HapticFeedback.mediumImpact();

    // Stop pulse animation
    _iconPulseController.stop();

    setState(() {
      _isSuccess = true;
    });

    // Start resend timer
    _startResendTimer();

    // Play success animation
    await _successController.forward();
  }

  /// Handle resend code action
  Future<void> _handleResend() async {
    if (!_canResend || _isLoading) return;

    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final success =
          await ref.read(authStateProvider.notifier).forgotPassword(email);

      if (!mounted) return;

      if (success) {
        // Reset timer
        _startResendTimer();

        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Reset code sent successfully'),
                ),
              ],
            ),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );

        HapticFeedback.mediumImpact();
      } else {
        final authError = ref.read(authStateProvider).error;
        _handleError(authError ?? 'Failed to resend code. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _handleError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Navigate to OTP verification screen
  void _navigateToOtpScreen() {
    HapticFeedback.lightImpact();
    final email = _emailController.text.trim();
    context.push(
      '${AppRoutes.otpVerification}?email=${Uri.encodeComponent(email)}&purpose=password_reset',
    );
  }

  /// Navigate back to login screen
  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    context.go(AppRoutes.login);
  }

  /// Open email app
  Future<void> _openEmailApp() async {
    HapticFeedback.lightImpact();

    try {
      final Uri emailUri = Uri(scheme: 'mailto');
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Try alternative approach for different platforms
        final Uri gmailUri = Uri.parse('googlegmail://');
        final Uri mailUri = Uri.parse('message://');

        if (await canLaunchUrl(gmailUri)) {
          await launchUrl(gmailUri);
        } else if (await canLaunchUrl(mailUri)) {
          await launchUrl(mailUri);
        } else {
          _showEmailAppError();
        }
      }
    } catch (e) {
      _showEmailAppError();
    }
  }

  /// Show error when email app cannot be opened
  void _showEmailAppError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Could not open email app'),
            ),
          ],
        ),
        backgroundColor: SpendexColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Handle back navigation
  Future<bool> _onWillPop() async {
    if (_isLoading) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isLoading,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor:
              isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
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
              onPressed: _isLoading ? null : () => context.pop(),
            ),
          ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _isSuccess
                      ? _buildSuccessView(isDark)
                      : _buildFormView(isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the form view
  Widget _buildFormView(bool isDark) {
    return SingleChildScrollView(
      key: const ValueKey('form_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shakeOffset = math.sin(_shakeAnimation.value * math.pi * 4) * 8;
          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: child,
          );
        },
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Animated Icon
              _buildAnimatedIcon(isDark, isSuccess: false),

              const SizedBox(height: 32),

              // Title
              Text(
                'Forgot Password?',
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'No worries! Enter your email and we\'ll send you a reset code.',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Email Field
              _buildEmailField(isDark),

              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null) ...[
                _buildErrorMessage(isDark),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 8),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 24),

              // Back to Login Link
              _buildBackToLoginLink(isDark),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the success view
  Widget _buildSuccessView(bool isDark) {
    final maskedEmail = _maskEmail(_emailController.text.trim());

    return SingleChildScrollView(
      key: const ValueKey('success_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Animated Success Icon
          _buildAnimatedIcon(isDark, isSuccess: true),

          const SizedBox(height: 32),

          // Title
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Text(
              'Check Your Email',
              style: SpendexTheme.displayLarge.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Email sent message
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Text(
              'We\'ve sent a 6-digit verification code to',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 8),

          // Masked email
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                maskedEmail,
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Helper text
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Didn\'t receive it? Check your spam folder or try resending.',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextTertiary
                      : SpendexColors.lightTextTertiary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Open Email App Button
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: AuthPrimaryButton(
              text: 'Open Email App',
              icon: Iconsax.directbox_default,
              onPressed: _openEmailApp,
              isLoading: false,
              isEnabled: !_isLoading,
            ),
          ),

          const SizedBox(height: 16),

          // Enter Code Manually Button
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: AuthOutlinedButton(
              text: 'Enter Code Manually',
              icon: Iconsax.keyboard,
              onPressed: _navigateToOtpScreen,
              isLoading: false,
              isEnabled: !_isLoading,
            ),
          ),

          const SizedBox(height: 32),

          // Resend Section
          _buildResendSection(isDark),

          const SizedBox(height: 24),

          // Back to Login Link
          _buildBackToLoginLink(isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Build animated icon (lock or success checkmark)
  Widget _buildAnimatedIcon(bool isDark, {required bool isSuccess}) {
    return AnimatedBuilder(
      animation: isSuccess ? _successScaleAnimation : _iconPulseAnimation,
      builder: (context, child) {
        final scale = isSuccess
            ? _successScaleAnimation.value
            : _iconPulseAnimation.value;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: isSuccess
              ? SpendexColors.incomeGradient
              : SpendexColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isSuccess ? SpendexColors.income : SpendexColors.primary)
                  .withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isSuccess
                ? AnimatedBuilder(
                    animation: _checkmarkAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _checkmarkAnimation.value,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Iconsax.tick_circle5,
                      key: ValueKey('success_icon'),
                      size: 48,
                      color: Colors.white,
                    ),
                  )
                : const Icon(
                    Iconsax.lock,
                    key: ValueKey('lock_icon'),
                    size: 48,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthEmailField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          validator: _validateEmail,
          onChanged: (_) {
            _hasInteracted = true;
          },
          onFieldSubmitted: (_) => _handleSubmit(),
          autofocus: false, // We handle focus manually
        ),
      ],
    );
  }

  /// Build error message widget
  Widget _buildErrorMessage(bool isDark) {
    final lowerMessage = _errorMessage?.toLowerCase() ?? '';
    final isRateLimited = lowerMessage.contains('too many') ||
        lowerMessage.contains('rate') ||
        lowerMessage.contains('limit');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isRateLimited ? SpendexColors.warning : SpendexColors.expense)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isRateLimited ? SpendexColors.warning : SpendexColors.expense)
                .withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRateLimited ? Iconsax.timer_1 : Iconsax.warning_2,
              color: isRateLimited ? SpendexColors.warning : SpendexColors.expense,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isRateLimited
                      ? SpendexColors.warning
                      : SpendexColors.expense,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _errorMessage = null;
                });
              },
              child: Icon(
                Iconsax.close_circle,
                color: (isRateLimited
                        ? SpendexColors.warning
                        : SpendexColors.expense)
                    .withOpacity(0.7),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build submit button
  Widget _buildSubmitButton() {
    return AuthPrimaryButton(
      text: 'Send Reset Code',
      icon: Iconsax.send_2,
      onPressed: _handleSubmit,
      isLoading: _isLoading,
      isEnabled: !_isLoading,
    );
  }

  /// Build resend section with timer
  Widget _buildResendSection(bool isDark) {
    return FadeTransition(
      opacity: _successOpacityAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Didn\'t receive the code? ',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          if (_isLoading)
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
                color: SpendexColors.primary.withOpacity(0.1),
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
                    _formattedCooldown,
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
      ),
    );
  }

  /// Build back to login link
  Widget _buildBackToLoginLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        AuthTextButton(
          text: 'Sign In',
          onPressed: _navigateToLogin,
          isEnabled: !_isLoading,
        ),
      ],
    );
  }
}
