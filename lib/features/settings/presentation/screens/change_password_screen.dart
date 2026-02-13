import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/password_strength_indicator.dart';

/// Change Password Screen
///
/// Allows users to change their account password with:
/// - Current password verification
/// - New password with strength validation
/// - Password confirmation
/// - Real-time password strength indicator
/// - Comprehensive validation rules
///
/// Features:
/// - Form validation with security requirements
/// - Password strength indicator with visual feedback
/// - Password visibility toggle for all fields
/// - Loading states during API calls
/// - Success/error feedback with SnackBars
/// - Material 3 design with dark mode support
/// - Option to logout after successful password change for security
///
/// Security Requirements:
/// - Minimum 8 characters
/// - At least one uppercase letter
/// - At least one lowercase letter
/// - At least one number
/// - At least one special character
/// - New password must differ from current password
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) {
      return false;
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return false;
    }
    if (!password.contains(RegExp('[a-z]'))) {
      return false;
    }
    if (!password.contains(RegExp('[0-9]'))) {
      return false;
    }
    if (!password.contains(RegExp(r'[@$!%*?&#^()_+=\-\[\]{}|\\:";,.<>~`]'))) {
      return false;
    }
    return true;
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }

    if (!value.contains(RegExp('[A-Z]'))) {
      return 'Must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp('[a-z]'))) {
      return 'Must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp('[0-9]'))) {
      return 'Must contain at least one number';
    }

    if (!value.contains(RegExp(r'[@$!%*?&#^()_+=\-\[\]{}|\\:";,.<>~`]'))) {
      return 'Must contain at least one special character';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  void _toggleCurrentPasswordVisibility() {
    setState(() {
      _obscureCurrentPassword = !_obscureCurrentPassword;
    });
  }

  void _toggleNewPasswordVisibility() {
    setState(() {
      _obscureNewPassword = !_obscureNewPassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newPassword = _newPasswordController.text;

    if (!_isPasswordStrong(newPassword)) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password does not meet security requirements',
          ),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.changePassword(
        _currentPasswordController.text,
        newPassword,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );

        await _showLogoutDialog();
      } else {
        final error = ref.read(authStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to change password'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Iconsax.shield_tick5,
          color: SpendexColors.income,
          size: 48,
        ),
        title: const Text('Password Changed'),
        content: const Text(
          'For security reasons, we recommend logging out and signing in again with your new password.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay Logged In'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    if (shouldLogout ?? false) {
      await ref.read(authStateProvider.notifier).logout();
      if (!mounted) {
        return;
      }
      context.go('/login');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(theme),
              const SizedBox(height: SpendexTheme.spacing2xl),
              _buildCurrentPasswordField(theme),
              const SizedBox(height: SpendexTheme.spacingLg),
              _buildNewPasswordField(theme),
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: SpendexTheme.spacingLg),
              _buildConfirmPasswordField(theme),
              const SizedBox(height: SpendexTheme.spacing3xl),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: SpendexColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingMd),
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: const Icon(
              Iconsax.shield_tick,
              color: SpendexColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Security',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a strong password to keep your account secure',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Password',
          style: SpendexTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        TextFormField(
          controller: _currentPasswordController,
          obscureText: _obscureCurrentPassword,
          validator: _validateCurrentPassword,
          decoration: InputDecoration(
            hintText: 'Enter your current password',
            prefixIcon: const Icon(Iconsax.lock_1),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword ? Iconsax.eye : Iconsax.eye_slash,
              ),
              onPressed: _toggleCurrentPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: SpendexTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          validator: _validateNewPassword,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Enter your new password',
            prefixIcon: const Icon(Iconsax.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Iconsax.eye : Iconsax.eye_slash,
              ),
              onPressed: _toggleNewPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return PasswordStrengthIndicator(
      password: _newPasswordController.text,
    );
  }

  Widget _buildConfirmPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm New Password',
          style: SpendexTheme.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: _validateConfirmPassword,
          decoration: InputDecoration(
            hintText: 'Re-enter your new password',
            prefixIcon: const Icon(Iconsax.lock_1),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Iconsax.eye : Iconsax.eye_slash,
              ),
              onPressed: _toggleConfirmPasswordVisibility,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return FilledButton(
      onPressed: _isLoading ? null : _changePassword,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
