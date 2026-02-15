import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/deletion_models.dart';
import '../providers/settings_provider.dart';

/// Delete Account Screen
///
/// A multi-step account deletion flow with:
/// - Step 1: Warning page with consequences
/// - Step 2: Subscription info (if any)
/// - Step 3: Password input for verification
/// - Step 4: Type "DELETE" confirmation
/// - Success handling with logout
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final PageController _pageController = PageController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _cancelSubscription = true;
  DeletionReason? _selectedReason;
  bool _isPasswordValid = false;
  bool _isConfirmValid = false;

  @override
  void initState() {
    super.initState();
    // Check for active subscription when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsStateProvider.notifier).checkActiveSubscription();
    });

    _passwordController.addListener(_onPasswordChanged);
    _confirmController.addListener(_onConfirmChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _confirmController.removeListener(_onConfirmChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final isValid = _validatePassword(_passwordController.text) == null;
    if (isValid != _isPasswordValid) {
      setState(() {
        _isPasswordValid = isValid;
      });
    }
  }

  void _onConfirmChanged() {
    final isValid = _confirmController.text == 'DELETE';
    if (isValid != _isConfirmValid) {
      setState(() {
        _isConfirmValid = isValid;
      });
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _nextStep() {
    // Clear any previous errors when moving to next step
    ref.read(settingsStateProvider.notifier).clearDeletionError();

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    // Clear any previous errors when moving to previous step
    ref.read(settingsStateProvider.notifier).clearDeletionError();

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _verifyPassword() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_isPasswordValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(settingsStateProvider.notifier).verifyPasswordForDeletion(
          _passwordController.text,
        );

    if (success && mounted) {
      _nextStep();
    }
  }

  Future<bool> _showFinalConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Iconsax.danger,
                  color: SpendexColors.expense,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text('Final Confirmation'),
              ],
            ),
            content: const Text(
              'This action CANNOT be undone. Your account and all data will be permanently deleted.\n\nAre you absolutely sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.expense,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete Forever'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleDeleteAccount() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_confirmController.text != 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type DELETE to confirm'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show final confirmation dialog
    final confirmed = await _showFinalConfirmationDialog();
    if (!confirmed) return;

    final success = await ref.read(settingsStateProvider.notifier).deleteAccount(
          _confirmController.text,
          reason: _selectedReason?.label,
        );

    if (success && mounted) {
      // Logout and navigate to login
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _previousStep();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Delete Account'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: _previousStep,
          ),
        ),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(isDark),

            // Error Banner
            if (settingsState.deletionError != null)
              _buildErrorBanner(settingsState.deletionError!),

            // Content
            Expanded(
              child: settingsState.deletionState == DeletionState.deleting
                  ? _buildLoadingState('Deleting your account...')
                  : settingsState.deletionState == DeletionState.verifyingPassword
                      ? _buildLoadingState('Verifying your identity...')
                      : settingsState.deletionState == DeletionState.checkingSubscription
                          ? _buildLoadingState('Checking subscription status...')
                          : PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildWarningStep(isDark),
                                _buildSubscriptionStep(isDark, settingsState.subscriptionInfo),
                                _buildPasswordStep(isDark, settingsState),
                                _buildConfirmationStep(isDark, settingsState),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? SpendexColors.expense
                    : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: SpendexColors.expense.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpendexColors.expense.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.warning_2,
            color: SpendexColors.expense,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: SpendexTheme.bodySmall.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Iconsax.close_circle,
              color: SpendexColors.expense,
              size: 20,
            ),
            onPressed: () {
              ref.read(settingsStateProvider.notifier).clearDeletionError();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.expense),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: SpendexTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: SpendexTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildWarningStep(bool isDark) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Warning Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.danger,
                color: SpendexColors.expense,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              'Delete Your Account?',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'This action cannot be undone',
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Consequences
          Text(
            'What happens when you delete your account:',
            style: SpendexTheme.titleMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildConsequenceItem(
            icon: Iconsax.trash,
            title: 'All data will be deleted',
            description: 'Your transactions, accounts, budgets, goals, and all financial data will be permanently removed.',
            isDark: isDark,
          ),
          _buildConsequenceItem(
            icon: Iconsax.card_remove,
            title: 'Subscriptions cancelled',
            description: 'Any active subscriptions will be cancelled and you will lose premium features.',
            isDark: isDark,
          ),
          _buildConsequenceItem(
            icon: Iconsax.people,
            title: 'Family sharing removed',
            description: 'You will be removed from any family sharing groups.',
            isDark: isDark,
          ),
          _buildConsequenceItem(
            icon: Iconsax.cloud_cross,
            title: 'No recovery possible',
            description: 'After 30 days, your data cannot be recovered.',
            isDark: isDark,
          ),

          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('I Understand, Continue'),
            ),
          ),
          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: SpendexTheme.titleMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequenceItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SpendexColors.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: SpendexColors.expense,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SpendexTheme.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: SpendexTheme.bodySmall.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStep(bool isDark, ActiveSubscriptionInfo? subscriptionInfo) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    final hasSubscription = subscriptionInfo?.hasActiveSubscription ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: hasSubscription
                    ? SpendexColors.warning.withValues(alpha: 0.1)
                    : SpendexColors.income.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSubscription ? Iconsax.card : Iconsax.tick_circle,
                color: hasSubscription ? SpendexColors.warning : SpendexColors.income,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              hasSubscription ? 'Active Subscription Found' : 'No Active Subscription',
              style: SpendexTheme.headlineSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (hasSubscription) ...[
            Center(
              child: Text(
                'Your subscription will be affected',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.warning,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Subscription Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Plan',
                    style: SpendexTheme.labelSmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subscriptionInfo?.planName ?? 'Unknown',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Billing',
                              style: SpendexTheme.labelSmall.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subscriptionInfo?.formattedBillingCycle ?? 'N/A',
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount',
                              style: SpendexTheme.labelSmall.copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subscriptionInfo?.formattedAmount ?? 'N/A',
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (subscriptionInfo?.expiryDate != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Expires: ${subscriptionInfo!.expiryDate}',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Subscription Toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cancel Subscription',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Automatically cancel your subscription when account is deleted',
                          style: SpendexTheme.bodySmall.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _cancelSubscription,
                    onChanged: (value) {
                      setState(() {
                        _cancelSubscription = value;
                      });
                    },
                    activeTrackColor: SpendexColors.expense,
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'You don\'t have any active subscriptions. You can proceed with account deletion.',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 16),

          // Back Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _previousStep,
              child: Text(
                'Back',
                style: SpendexTheme.titleMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordStep(bool isDark, SettingsState settingsState) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    final isLoading = settingsState.deletionState == DeletionState.verifyingPassword;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.lock,
                  color: SpendexColors.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'Verify Your Identity',
                style: SpendexTheme.headlineSmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'For security, please enter your password to continue',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Password Input
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                enabled: !isLoading,
                validator: _validatePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onFieldSubmitted: (_) => _verifyPassword(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Iconsax.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Deletion Reason
            Text(
              'Why are you leaving? (Optional)',
              style: SpendexTheme.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DeletionReason.values.map((reason) {
                final isSelected = _selectedReason == reason;
                return FilterChip(
                  label: Text(reason.label),
                  selected: isSelected,
                  onSelected: isLoading
                      ? null
                      : (selected) {
                          setState(() {
                            _selectedReason = selected ? reason : null;
                          });
                        },
                  selectedColor: SpendexColors.expense.withValues(alpha: 0.2),
                  checkmarkColor: SpendexColors.expense,
                  labelStyle: TextStyle(
                    color: isSelected ? SpendexColors.expense : secondaryTextColor,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading || !_isPasswordValid ? null : _verifyPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.expense,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: SpendexColors.expense.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Verify Password'),
              ),
            ),
            const SizedBox(height: 16),

            // Back Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: isLoading ? null : _previousStep,
                child: Text(
                  'Back',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: isLoading ? secondaryTextColor.withValues(alpha: 0.5) : secondaryTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationStep(bool isDark, SettingsState settingsState) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    final isLoading = settingsState.deletionState == DeletionState.deleting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: SpendexColors.expense,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),

          Center(
            child: Text(
              'Final Step',
              style: SpendexTheme.headlineSmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Type DELETE to confirm',
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Warning Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SpendexColors.expense.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SpendexColors.expense.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.danger,
                      color: SpendexColors.expense,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Warning',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.expense,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This will permanently delete:\n'
                  '• All your financial data\n'
                  '• All transactions and accounts\n'
                  '• All budgets and goals\n'
                  '• Your account settings',
                  style: SpendexTheme.bodySmall.copyWith(
                    color: SpendexColors.expense,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirmation Input
          Text(
            'Type DELETE to confirm:',
            style: SpendexTheme.labelMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConfirmValid
                    ? SpendexColors.expense
                    : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
                width: _isConfirmValid ? 2 : 1,
              ),
            ),
            child: TextField(
              controller: _confirmController,
              focusNode: _confirmFocusNode,
              enabled: !isLoading,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                UpperCaseTextFormatter(),
              ],
              onSubmitted: (_) => _handleDeleteAccount(),
              decoration: InputDecoration(
                hintText: 'DELETE',
                hintStyle: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.5),
                  letterSpacing: 2,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: TextStyle(
                color: _isConfirmValid ? SpendexColors.expense : textColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Delete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading || !_isConfirmValid ? null : _handleDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
                disabledBackgroundColor: SpendexColors.expense.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete My Account'),
            ),
          ),
          const SizedBox(height: 16),

          // Back Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: isLoading ? null : _previousStep,
              child: Text(
                'Back',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isLoading ? secondaryTextColor.withValues(alpha: 0.5) : secondaryTextColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
