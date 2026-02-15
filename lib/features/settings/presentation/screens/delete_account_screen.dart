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
  
  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _cancelSubscription = true;

  @override
  void initState() {
    super.initState();
    // Check for active subscription when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsStateProvider.notifier).checkActiveSubscription();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _nextStep() {
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

  Future<void> _handleDeleteAccount() async {
    if (_confirmController.text != 'DELETE') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type DELETE to confirm'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final request = DeleteAccountRequest(
      password: _passwordController.text,
      confirmationText: _confirmController.text,
      cancelSubscription: _cancelSubscription,
    );

    final success = await ref.read(settingsStateProvider.notifier).deleteAccount(request);

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
          title: Text('Delete Account'),
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
            
            // Content
            Expanded(
              child: settingsState.deletionState == DeletionState.deleting
                  ? _buildLoadingState()
                  : settingsState.deletionState == DeletionState.error
                      ? _buildErrorState(settingsState.errorMessage)
                      : PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildWarningStep(isDark),
                            _buildSubscriptionStep(isDark, settingsState.subscriptionInfo),
                            _buildPasswordStep(isDark),
                            _buildConfirmationStep(isDark),
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
          final isCompleted = index < _currentStep;
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(SpendexColors.expense),
          ),
          SizedBox(height: 24),
          Text(
            'Deleting your account...',
            style: SpendexTheme.bodyMedium,
          ),
          SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: SpendexTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.warning_2,
              color: SpendexColors.expense,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to delete account',
              style: SpendexTheme.headlineSmall.copyWith(
                color: SpendexColors.expense,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              error ?? 'An unexpected error occurred',
              style: SpendexTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(settingsStateProvider.notifier).resetDeletionState();
                setState(() {
                  _currentStep = 0;
                });
                _pageController.jumpToPage(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
              ),
              child: Text('Try Again'),
            ),
          ],
        ),
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
              child: Text('I Understand, Continue'),
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
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (hasSubscription ? SpendexColors.transfer : SpendexColors.income)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSubscription ? Iconsax.crown : Iconsax.tick_circle,
                color: hasSubscription ? SpendexColors.transfer : SpendexColors.income,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Center(
            child: Text(
              hasSubscription ? 'Active Subscription Found' : 'No Active Subscription',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (hasSubscription && subscriptionInfo != null) ...[
            // Subscription Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildSubscriptionRow(
                    'Plan',
                    subscriptionInfo.planName ?? 'Unknown',
                    isDark,
                  ),
                  const Divider(height: 24),
                  _buildSubscriptionRow(
                    'Billing Cycle',
                    subscriptionInfo.formattedBillingCycle,
                    isDark,
                  ),
                  const Divider(height: 24),
                  _buildSubscriptionRow(
                    'Amount',
                    subscriptionInfo.formattedAmount,
                    isDark,
                  ),
                  if (subscriptionInfo.expiryDate != null) ...[
                    const Divider(height: 24),
                    _buildSubscriptionRow(
                      'Expires',
                      subscriptionInfo.expiryDate!,
                      isDark,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Subscription Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SpendexColors.expense.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _cancelSubscription,
                    onChanged: (value) {
                      setState(() {
                        _cancelSubscription = value ?? true;
                      });
                      HapticFeedback.selectionClick();
                    },
                    activeColor: SpendexColors.expense,
                  ),
                  Expanded(
                    child: Text(
                      'Cancel my subscription immediately',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // No Subscription Message
            Center(
              child: Text(
                'You do not have any active subscriptions.',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
                textAlign: TextAlign.center,
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
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRow(String label, String value, bool isDark) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: SpendexTheme.bodyMedium.copyWith(color: secondaryTextColor),
        ),
        Text(
          value,
          style: SpendexTheme.labelMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
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

          // Title
          Center(
            child: Text(
              'Verify Your Identity',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Enter your password to continue',
              style: SpendexTheme.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Password Field
          Text(
            'Password',
            style: SpendexTheme.labelLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your password'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                _nextStep();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep(bool isDark) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
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

          // Title
          Center(
            child: Text(
              'Final Confirmation',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Type DELETE to confirm account deletion',
              style: SpendexTheme.bodyMedium.copyWith(
                color: SpendexColors.expense,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Confirmation Field
          Text(
            'Type "DELETE" to confirm',
            style: SpendexTheme.labelLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'DELETE',
              prefixIcon: const Icon(Iconsax.text),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: SpendexColors.expense),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 32),

          // Delete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmController.text == 'DELETE'
                  ? _handleDeleteAccount
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
                disabledBackgroundColor: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Delete My Account'),
            ),
          ),
          const SizedBox(height: 16),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel, Keep My Account',
                style: SpendexTheme.titleMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
