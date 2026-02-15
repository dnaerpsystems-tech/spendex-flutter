import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_indicator.dart';

/// Reset Password Screen
///
/// A professional password reset screen with:
/// - Animated entrance (fade + slide up)
/// - Password strength indicator with real-time validation
/// - Password match indicator
/// - Animated shield/lock icon with pulse effect
/// - Form shake animation on errors
/// - Success state with animated checkmark
/// - Auto-redirect countdown to login
/// - Comprehensive error handling
/// - Security features (prevent paste on confirm, clear on error)
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    required this.token,
    this.email,
    super.key,
  });

  final String? email;
  final String token;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen>
    with TickerProviderStateMixin {
  // Form
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // State
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  int _redirectCountdown = 5;
  bool _hasInteracted = false;

  // Animation Controllers
  late AnimationController _entranceController;
  late AnimationController _iconController;
  late AnimationController _successController;
  late AnimationController _shakeController;
  late AnimationController _checkmarkController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconPulseAnimation;
  late Animation<double> _successScaleAnimation;
  late Animation<double> _successOpacityAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _checkmarkAnimation;

  // Timers
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _setupListeners();

    // Validate token on mount
    if (widget.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInvalidToken();
      });
    }

    // Start entrance animation
    _entranceController.forward();

    // Auto-focus password field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFocusNode.requestFocus();
    });
  }

  /// Initialize all animation controllers and animations
  void _initAnimations() {
    // Entrance animation controller
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
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Icon pulse animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _iconPulseAnimation = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: Curves.easeInOut,
      ),
    );

    _iconController.repeat(reverse: true);

    // Success animation controller
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

    // Checkmark animation
    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkmarkAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _checkmarkController,
        curve: const Interval(0.3, 1, curve: Curves.easeOutBack),
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
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  /// Handle password input changes
  void _onPasswordChanged() {
    if (_errorMessage != null && _hasInteracted) {
      setState(() {
        _errorMessage = null;
      });
    }
    setState(() {});
  }

  /// Handle confirm password input changes
  void _onConfirmPasswordChanged() {
    if (_errorMessage != null && _hasInteracted) {
      setState(() {
        _errorMessage = null;
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _redirectTimer?.cancel();
    _entranceController.dispose();
    _iconController.dispose();
    _successController.dispose();
    _shakeController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  /// Handle invalid token on mount
  void _handleInvalidToken() {
    setState(() {
      _errorMessage = 'Invalid reset link. Please request a new one.';
    });
    _shakeForm();
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!PasswordValidator.isAcceptable(value)) {
      return 'Password must be at least fair strength';
    }
    return null;
  }

  /// Validate confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
    // Mark as interacted
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
      final success = await ref.read(authStateProvider.notifier).resetPassword(
            widget.token,
            _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      if (success) {
        await _transitionToSuccess();
      } else {
        final authError = ref.read(authStateProvider).error;
        _handleError(authError ?? 'Failed to reset password. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        _handleError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted && !_isSuccess) {
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
    var displayMessage = message;
    var shouldNavigateBack = false;

    if (lowerMessage.contains('expired') || lowerMessage.contains('invalid token')) {
      displayMessage = 'Reset link has expired. Please request a new one.';
      shouldNavigateBack = true;
    } else if (lowerMessage.contains('invalid') || lowerMessage.contains('not found')) {
      displayMessage = 'Invalid reset link. Please try again.';
    } else if (lowerMessage.contains('same') || lowerMessage.contains('old password')) {
      displayMessage = 'New password cannot be the same as your old password.';
    } else if (lowerMessage.contains('network') ||
        lowerMessage.contains('connection') ||
        lowerMessage.contains('internet')) {
      displayMessage = 'Connection failed. Please check your internet connection.';
    }

    setState(() {
      _errorMessage = displayMessage;
      _isLoading = false;
    });

    // Clear password fields on error
    _passwordController.clear();
    _confirmPasswordController.clear();
    _passwordFocusNode.requestFocus();

    _shakeForm();

    // Navigate back if token is expired/invalid
    if (shouldNavigateBack) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          context.go(AppRoutes.forgotPassword);
        }
      });
    }
  }

  /// Transition to success view with animation
  Future<void> _transitionToSuccess() async {
    unawaited(HapticFeedback.mediumImpact());

    // Stop pulse animation
    _iconController.stop();

    setState(() {
      _isSuccess = true;
      _isLoading = false;
    });

    // Play success animation
    await _successController.forward();
    await _checkmarkController.forward();

    // Start redirect countdown
    _startRedirectTimer();
  }

  /// Start auto-redirect timer
  void _startRedirectTimer() {
    _redirectTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_redirectCountdown > 1) {
        setState(() {
          _redirectCountdown--;
        });
      } else {
        timer.cancel();
        _navigateToLogin();
      }
    });
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    context.go(AppRoutes.login);
  }

  /// Handle back button press
  Future<bool> _onWillPop() async {
    if (_isLoading) {
      return false;
    }

    if (_isSuccess) {
      _navigateToLogin();
      return false;
    }

    // Check if form is dirty
    if (_passwordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
      final result = await _showExitConfirmation();
      return result ?? false;
    }

    return true;
  }

  /// Show exit confirmation dialog
  Future<bool?> _showExitConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Discard Changes?',
            style: SpendexTheme.headlineMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to leave?',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
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
                'Leave',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.expense,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.go(AppRoutes.login);
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
          appBar: _isSuccess
              ? null
              : AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Iconsax.arrow_left,
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () async {
                            final shouldPop = await _onWillPop();
                            if (shouldPop && context.mounted) {
                              context.go(AppRoutes.login);
                            }
                          },
                  ),
                ),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
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
                  child: _isSuccess ? _buildSuccessView(isDark) : _buildFormView(isDark),
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
            children: [
              const SizedBox(height: 20),

              // Animated Icon
              _buildAnimatedIcon(isDark, isSuccess: false),

              const SizedBox(height: 32),

              // Title
              Text(
                'Create New Password',
                style: SpendexTheme.displayLarge.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your new password must be different from previously used passwords.',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Show email if available
              if (widget.email != null && widget.email!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.email!,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Password Field
              _buildPasswordField(isDark),

              const SizedBox(height: 12),

              // Password Strength Indicator
              _buildPasswordStrength(),

              const SizedBox(height: 24),

              // Confirm Password Field
              _buildConfirmPasswordField(isDark),

              const SizedBox(height: 12),

              // Password Match Indicator
              _buildPasswordMatch(),

              const SizedBox(height: 24),

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
    return SingleChildScrollView(
      key: const ValueKey('success_view'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 80),

          // Animated Success Icon
          _buildAnimatedIcon(isDark, isSuccess: true),

          const SizedBox(height: 40),

          // Title
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Text(
              'Password Reset Successfully!',
              style: SpendexTheme.displayLarge.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Success message
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Your password has been reset successfully. You can now log in with your new password.',
                style: SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Continue to Login Button
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: AuthPrimaryButton(
              text: 'Continue to Login',
              icon: Iconsax.login,
              onPressed: _navigateToLogin,
            ),
          ),

          const SizedBox(height: 24),

          // Redirect countdown
          FadeTransition(
            opacity: _successOpacityAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.timer_1,
                    size: 16,
                    color: SpendexColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Redirecting in ${_redirectCountdown}s...',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Build animated icon (shield/lock or success checkmark)
  Widget _buildAnimatedIcon(bool isDark, {required bool isSuccess}) {
    return AnimatedBuilder(
      animation: isSuccess ? _successScaleAnimation : _iconPulseAnimation,
      builder: (context, child) {
        final scale = isSuccess ? _successScaleAnimation.value : _iconPulseAnimation.value;
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
          gradient: isSuccess ? SpendexColors.incomeGradient : SpendexColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (isSuccess ? SpendexColors.income : SpendexColors.primary).withValues(alpha: 0.3),
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
                    Iconsax.shield_tick,
                    key: ValueKey('shield_icon'),
                    size: 48,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  /// Build password input field
  Widget _buildPasswordField(bool isDark) {
    return AuthPasswordField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      labelText: 'New Password',
      hintText: 'Enter your new password',
      textInputAction: TextInputAction.next,
      enabled: !_isLoading,
      validator: _validatePassword,
      onChanged: (_) {
        _hasInteracted = true;
      },
      onFieldSubmitted: (_) {
        _confirmPasswordFocusNode.requestFocus();
      },
    );
  }

  /// Build confirm password input field
  Widget _buildConfirmPasswordField(bool isDark) {
    return AuthPasswordField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      labelText: 'Confirm Password',
      hintText: 'Confirm your new password',
      enabled: !_isLoading,
      enableInteractiveSelection: false,
      validator: _validateConfirmPassword,
      onChanged: (_) {
        _hasInteracted = true;
      },
      onFieldSubmitted: (_) => _handleSubmit(),
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrength() {
    return PasswordStrengthIndicator(
      password: _passwordController.text,
      padding: const EdgeInsets.only(top: 4),
    );
  }

  /// Build password match indicator
  Widget _buildPasswordMatch() {
    return PasswordMatchIndicator(
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  /// Build error message widget
  Widget _buildErrorMessage(bool isDark) {
    final lowerMessage = _errorMessage?.toLowerCase() ?? '';
    final isExpired = lowerMessage.contains('expired');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
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
          color: SpendexColors.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SpendexColors.expense.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpired ? Iconsax.timer_1 : Iconsax.warning_2,
              color: SpendexColors.expense,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _errorMessage!,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: SpendexColors.expense,
                    ),
                  ),
                  if (isExpired) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Redirecting to forgot password...',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.expense.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!isExpired)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                child: Icon(
                  Iconsax.close_circle,
                  color: SpendexColors.expense.withValues(alpha: 0.7),
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
    final isEnabled = !_isLoading &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;

    return AuthPrimaryButton(
      text: 'Reset Password',
      icon: Iconsax.shield_tick,
      onPressed: _handleSubmit,
      isLoading: _isLoading,
      isEnabled: isEnabled,
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
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          ),
        ),
        AuthTextButton(
          text: 'Sign In',
          onPressed: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              context.go(AppRoutes.login);
            }
          },
          isEnabled: !_isLoading,
        ),
      ],
    );
  }
}
