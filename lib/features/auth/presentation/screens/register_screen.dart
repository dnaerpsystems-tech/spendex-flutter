import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/password_strength_indicator.dart';
import '../widgets/social_auth_icon_buttons.dart';

/// Registration Screen
///
/// A professional registration screen with:
/// - Staggered field animations
/// - Real-time password strength indicator
/// - Form validation
/// - Terms & Conditions bottom sheet
/// - Progress step indicator
/// - Back button with confirmation
/// Debouncer utility class for rate-limiting validation calls
class _Debouncer {

  _Debouncer({required this.delay});
  final Duration delay;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with TickerProviderStateMixin {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus Nodes
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isFormDirty = false;
  String _currentPassword = '';
  String _currentConfirmPassword = '';

  // Debouncer for validation
  final _validationDebouncer = _Debouncer(delay: const Duration(milliseconds: 300));

  // Animation Controllers
  late AnimationController _staggerController;
  late AnimationController _shakeController;
  late AnimationController _pulseController;
  late Animation<double> _shakeAnimation;

  // Staggered Animations
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    // Analytics screen view
    AnalyticsService.logScreenView(screenName: AnalyticsEvents.screenSignUp);
    _initAnimations();
    _setupListeners();
    _staggerController.forward();
  }

  void _initAnimations() {
    // Stagger animation controller
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Shake animation for errors
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    // Pulse animation for valid form
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Create staggered animations for 8 elements
    const itemCount = 8;
    _fadeAnimations = List.generate(itemCount, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(itemCount, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            start.clamp(0.0, 1.0),
            end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  void _setupListeners() {
    // Track form dirty state
    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _passwordController.addListener(() {
      _onFormChanged();
      setState(() {
        _currentPassword = _passwordController.text;
      });
    });
    _confirmPasswordController.addListener(() {
      _onFormChanged();
      setState(() {
        _currentConfirmPassword = _confirmPasswordController.text;
      });
    });
  }

  void _onFormChanged() {
    if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
    // Clear error when user starts typing (debounced)
    _validationDebouncer.run(() {
      if (ref.read(authStateProvider).error != null) {
        ref.read(authStateProvider.notifier).clearError();
      }
      // Trigger form validation
      _formKey.currentState?.validate();
    });
    // Also clear immediately without debounce
    if (ref.read(authStateProvider).error != null) {
      ref.read(authStateProvider.notifier).clearError();
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    // Dispose focus nodes
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    // Dispose animation controllers
    _staggerController.dispose();
    _shakeController.dispose();
    _pulseController.dispose();

    _validationDebouncer.dispose();
    super.dispose();
  }

  // Validation Methods
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Name must be less than 100 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (!AppConstants.phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!PasswordValidator.isAcceptable(value)) {
      return 'Password does not meet requirements';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _validateName(_nameController.text) == null &&
        _validateEmail(_emailController.text) == null &&
        _validatePhone(_phoneController.text) == null &&
        _validatePassword(_passwordController.text) == null &&
        _validateConfirmPassword(_confirmPasswordController.text) == null &&
        _acceptTerms;
  }

  Future<bool> _onWillPop() async {
    if (!_isFormDirty) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: SpendexColors.expense),
            ),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  void _showTermsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => DecoratedBox(
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Terms & Privacy Policy',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Iconsax.close_circle,
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermsSection(
                        'Terms of Service',
                        'Last updated: January 2024',
                        [
                          'By using Spendex, you agree to these terms and conditions.',
                          'You must be at least 18 years old to use this app.',
                          'You are responsible for maintaining the confidentiality of your account.',
                          'You agree not to use the app for any illegal or unauthorized purpose.',
                          'We reserve the right to modify or terminate the service at any time.',
                          'Your use of the app is at your sole risk.',
                        ],
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      _buildTermsSection(
                        'Privacy Policy',
                        'Your privacy matters to us',
                        [
                          'We collect personal information you provide directly to us.',
                          'We use your information to provide and improve our services.',
                          'We do not sell your personal information to third parties.',
                          'We use industry-standard security measures to protect your data.',
                          'You can request deletion of your account and data at any time.',
                          'We may update this policy from time to time.',
                        ],
                        isDark,
                      ),
                      const SizedBox(height: 24),
                      _buildTermsSection(
                        'Data Collection',
                        'What we collect',
                        [
                          'Account information (name, email, phone)',
                          'Financial data you enter (transactions, accounts, budgets)',
                          'Usage analytics to improve the app',
                          'Device information for security purposes',
                        ],
                        isDark,
                      ),
                      const SizedBox(height: 32),
                      // Accept Button
                      AuthPrimaryButton(
                        text: 'I Understand',
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _acceptTerms = true;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(
    String title,
    String subtitle,
    List<String> items,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SpendexTheme.titleMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: SpendexColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) => _shakeController.reset());
    HapticFeedback.mediumImpact();
  }

  Future<void> _handleRegister() async {
    // Check terms first
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Iconsax.warning_2, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please accept the terms and conditions'),
              ),
            ],
          ),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      _triggerShakeAnimation();
      return;
    }

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      _triggerShakeAnimation();
      return;
    }

    // Perform registration
    final success = await ref.read(authStateProvider.notifier).register(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        );

    if (success && mounted) {
      // Analytics: Track registration complete
      AnalyticsService.logSignUp(method: 'email');
      // Navigate to OTP verification
      await context.push(
        '${AppRoutes.otpVerification}?email=${Uri.encodeComponent(_emailController.text.trim())}&purpose=verification',
      );
    } else if (mounted) {
      _triggerShakeAnimation();
    }
  }

  /// Handle social sign-up
  Future<void> _handleSocialSignUp(SocialAuthProviderType provider) async {
    ref.read(authStateProvider.notifier).clearError();
    
    var success = false;
    switch (provider) {
      case SocialAuthProviderType.google:
        success = await ref.read(authStateProvider.notifier).signInWithGoogle();
        break;
      case SocialAuthProviderType.apple:
        success = await ref.read(authStateProvider.notifier).signInWithApple();
        break;
      case SocialAuthProviderType.facebook:
        success = await ref.read(authStateProvider.notifier).signInWithFacebook();
        break;
    }

    if (success && mounted) {
      context.go(AppRoutes.home);
    } else if (!success && mounted) {
      _triggerShakeAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isFormDirty,
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
        backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
            onPressed: () async {
              if (_isFormDirty) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeAnimation.value *
                          ((_shakeController.value * 10).toInt().isEven ? 1 : -1),
                      0,
                    ),
                    child: child,
                  );
                },
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress Indicator
                      _buildStaggeredChild(
                        index: 0,
                        child: _buildProgressIndicator(isDark),
                      ),

                      const SizedBox(height: 24),

                      // Header
                      _buildStaggeredChild(
                        index: 0,
                        child: const AuthHeader(
                          title: 'Create Account',
                          subtitle: 'Start managing your finances today',
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Name Field
                      _buildStaggeredChild(
                        index: 1,
                        child: AuthTextField(
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Iconsax.user,
                          keyboardType: TextInputType.name,
                          validator: _validateName,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_emailFocusNode);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      _buildStaggeredChild(
                        index: 2,
                        child: AuthTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: Iconsax.sms,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_phoneFocusNode);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Phone Field
                      _buildStaggeredChild(
                        index: 3,
                        child: _buildPhoneField(isDark),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      _buildStaggeredChild(
                        index: 4,
                        child: _buildPasswordField(isDark),
                      ),

                      // Password Strength Indicator
                      if (_currentPassword.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        PasswordStrengthIndicator(
                          password: _currentPassword,
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildStaggeredChild(
                        index: 5,
                        child: _buildConfirmPasswordField(isDark),
                      ),

                      // Password Match Indicator
                      if (_currentConfirmPassword.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PasswordMatchIndicator(
                          password: _currentPassword,
                          confirmPassword: _currentConfirmPassword,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Terms and Conditions
                      _buildStaggeredChild(
                        index: 6,
                        child: _buildTermsCheckbox(isDark),
                      ),

                      const SizedBox(height: 24),

                      // Error Message
                      if (authState.error != null) _buildErrorMessage(authState.error!, isDark),

                      // Register Button
                      _buildStaggeredChild(
                        index: 7,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale = _isFormValid && !authState.isLoading
                                ? 1.0 + (_pulseController.value * 0.02)
                                : 1.0;
                            return Transform.scale(
                              scale: scale,
                              child: AuthPrimaryButton(
                                text: 'Create Account',
                                isLoading: authState.isLoading,
                                isEnabled: !authState.isLoading,
                                onPressed: _handleRegister,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Social Sign-Up Section
                      _buildStaggeredChild(
                        index: 7,
                        child: SocialAuthSection(
                          dividerText: 'Or sign up with',
                          onGooglePressed: authState.isSocialLoading
                              ? null
                              : () => _handleSocialSignUp(SocialAuthProviderType.google),
                          onApplePressed: authState.isSocialLoading
                              ? null
                              : () => _handleSocialSignUp(SocialAuthProviderType.apple),
                          onFacebookPressed: authState.isSocialLoading
                              ? null
                              : () => _handleSocialSignUp(SocialAuthProviderType.facebook),
                          isGoogleLoading: authState.loadingSocialProvider == SocialAuthProviderType.google,
                          isAppleLoading: authState.loadingSocialProvider == SocialAuthProviderType.apple,
                          isFacebookLoading: authState.loadingSocialProvider == SocialAuthProviderType.facebook,
                          showApple: ref.watch(isAppleSignInAvailableProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Login Link
                      _buildStaggeredChild(
                        index: 8,
                        child: AuthFooter(
                          text: 'Already have an account? ',
                          linkText: 'Sign In',
                          onLinkPressed: () => context.pop(),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredChild({required int index, required Widget child}) {
    final safeIndex = index.clamp(0, _fadeAnimations.length - 1);
    return FadeTransition(
      opacity: _fadeAnimations[safeIndex],
      child: SlideTransition(
        position: _slideAnimations[safeIndex],
        child: child,
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Row(
      children: [
        Text(
          'Step 1 of 2',
          style: SpendexTheme.labelMedium.copyWith(
            color: SpendexColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: SpendexColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Phone (Optional)',
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          focusNode: _phoneFocusNode,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: 'Enter your mobile number',
            prefixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.call,
                    color:
                        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? SpendexColors.darkBorder.withValues(alpha: 0.5)
                          : SpendexColors.lightBorder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '+91',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 24,
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(),
          ),
          validator: _validatePhone,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Password',
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Create a strong password',
            prefixIcon: Icon(
              Iconsax.lock,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
          validator: _validatePassword,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Confirm Password',
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            prefixIcon: Icon(
              Iconsax.lock,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Iconsax.eye_slash : Iconsax.eye,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
                HapticFeedback.selectionClick();
              },
            ),
          ),
          validator: _validateConfirmPassword,
          onFieldSubmitted: (_) => _handleRegister(),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
              HapticFeedback.selectionClick();
            },
            activeColor: SpendexColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.primary,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _showTermsSheet,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.primary,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = _showTermsSheet,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpendexColors.expense.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.warning_2,
            color: SpendexColors.expense,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Iconsax.close_circle,
              color: SpendexColors.expense,
              size: 20,
            ),
            onPressed: () {
              ref.read(authStateProvider.notifier).clearError();
            },
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
