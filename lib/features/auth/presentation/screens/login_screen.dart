import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/secure_storage.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/biometric_button.dart';

/// Login Form Data
class _LoginFormData {
  String email = '';
  String password = '';
  bool rememberMe = false;
}

/// Login Screen
///
/// A professional login screen with:
/// - Animated logo with scale and fade
/// - Smooth form field animations on mount
/// - Shake animation on error
/// - Remember me with persistent storage
/// - Biometric login button that actually works
/// - Loading overlay during login
/// - Error display with icon and dismiss
/// - Keyboard handling
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _formData = _LoginFormData();

  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRememberedEmail();
    _checkBiometricAvailability();
  }

  void _initAnimations() {
    // Main entrance animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1, curve: Curves.easeOut),
      ),
    );

    // Shake animation for errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Start entrance animation
    _animationController.forward();
  }

  Future<void> _loadRememberedEmail() async {
    final secureStorage = getIt<SecureStorageService>();
    final rememberedEmail = await secureStorage.read('remembered_email');

    if (rememberedEmail != null && rememberedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = rememberedEmail;
        _formData.email = rememberedEmail;
        _formData.rememberMe = true;
        _isInitialized = true;
      });
    } else {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _checkBiometricAvailability() async {
    await ref.read(authStateProvider.notifier).checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Validate email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Shake the form on error
  void _shakeForm() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
    HapticFeedback.heavyImpact();
  }

  /// Handle login
  Future<void> _handleLogin() async {
    // Clear previous error
    ref.read(authStateProvider.notifier).clearError();

    if (!(_formKey.currentState?.validate() ?? false)) {
      _shakeForm();
      return;
    }

    // Save email if remember me is checked
    final secureStorage = getIt<SecureStorageService>();
    if (_formData.rememberMe) {
      await secureStorage.save('remembered_email', _emailController.text.trim());
    } else {
      await secureStorage.delete('remembered_email');
    }

    final success = await ref.read(authStateProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    } else {
      _shakeForm();
    }
  }

  /// Handle biometric login
  Future<void> _handleBiometricLogin() async {
    ref.read(authStateProvider.notifier).clearError();

    final success = await ref.read(authStateProvider.notifier).loginWithBiometric();

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  /// Clear error on input change
  void _onInputChanged(String value) {
    if (ref.read(authStateProvider).error != null) {
      ref.read(authStateProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor:
          isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final sineValue = math.sin(_shakeAnimation.value * math.pi * 4);
                return Transform.translate(
                  offset: Offset(sineValue * 10, 0),
                  child: child,
                );
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: keyboardVisible ? 20 : 40),

                          // Header with Logo
                          if (!keyboardVisible)
                            const Center(
                              child: AuthHeader(
                                title: 'Welcome Back',
                                subtitle: 'Sign in to continue managing your finances',
                              ),
                            ),

                          if (keyboardVisible)
                            Center(
                              child: Text(
                                'Sign In',
                                style: SpendexTheme.headlineMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextPrimary
                                      : SpendexColors.lightTextPrimary,
                                ),
                              ),
                            ),

                          SizedBox(height: keyboardVisible ? 24 : 48),

                          // Email Field
                          AuthEmailField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            validator: _validateEmail,
                            onChanged: (value) {
                              _formData.email = value;
                              _onInputChanged(value);
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocusNode);
                            },
                            autofocus: !_isInitialized,
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          AuthPasswordField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            validator: _validatePassword,
                            onChanged: (value) {
                              _formData.password = value;
                              _onInputChanged(value);
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),

                          const SizedBox(height: 16),

                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Remember Me
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _formData.rememberMe = !_formData.rememberMe;
                                  });
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: Checkbox(
                                        value: _formData.rememberMe,
                                        onChanged: (value) {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _formData.rememberMe = value ?? false;
                                          });
                                        },
                                        activeColor: SpendexColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember me',
                                      style: SpendexTheme.bodyMedium.copyWith(
                                        color: isDark
                                            ? SpendexColors.darkTextSecondary
                                            : SpendexColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Forgot Password
                              AuthTextButton(
                                text: 'Forgot Password?',
                                onPressed: () => context.push(AppRoutes.forgotPassword),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Error Message
                          _buildErrorMessage(authState, isDark),

                          // Login Button
                          AuthPrimaryButton(
                            text: 'Sign In',
                            onPressed: _handleLogin,
                            isLoading: authState.isLoading,
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          const AuthDivider(),

                          const SizedBox(height: 24),

                          // Biometric Login Button
                          if (authState.isBiometricAvailable && authState.isBiometricEnabled)
                            Column(
                              children: [
                                BiometricLoginButton(
                                  onPressed: _handleBiometricLogin,
                                  isLoading: authState.isBiometricLoading,
                                  isAvailable: authState.isBiometricAvailable,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Social Login Buttons (Placeholder)
                          Row(
                            children: [
                              Expanded(
                                child: AuthSocialButton(
                                  text: 'Google',
                                  icon: Icons.g_mobiledata_rounded,
                                  onPressed: () {
                                    // TODO(spendex): Implement Google login.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Google login coming soon'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  height: 48,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AuthSocialButton(
                                  text: 'Apple',
                                  icon: Icons.apple,
                                  onPressed: () {
                                    // TODO(spendex): Implement Apple login.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Apple login coming soon'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  height: 48,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Register Link
                          AuthFooter(
                            text: "Don't have an account? ",
                            linkText: 'Sign Up',
                            onLinkPressed: () => context.push(AppRoutes.register),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Loading Overlay
            if (authState.isLoading)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build error message widget
  Widget _buildErrorMessage(AuthState authState, bool isDark) {
    if (authState.error == null) {
      return const SizedBox.shrink();
    }

    // Check for rate limiting
    final isRateLimited = authState.error!.toLowerCase().contains('rate') ||
        authState.error!.toLowerCase().contains('too many');

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
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: (isRateLimited ? SpendexColors.warning : SpendexColors.expense)
              .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isRateLimited ? SpendexColors.warning : SpendexColors.expense)
                .withValues(alpha: 0.3),
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
                authState.error!,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isRateLimited ? SpendexColors.warning : SpendexColors.expense,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(authStateProvider.notifier).clearError();
              },
              child: Icon(
                Iconsax.close_circle,
                color: (isRateLimited ? SpendexColors.warning : SpendexColors.expense)
                    .withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
