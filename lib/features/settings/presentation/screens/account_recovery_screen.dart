import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/routes.dart';
import '../../../../app/theme.dart';

/// Screen for recovering an account that is scheduled for deletion.
/// Shows the countdown until permanent deletion and allows the user to cancel.
class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  bool _isRecovering = false;

  Future<void> _recoverAccount() async {
    setState(() => _isRecovering = true);

    try {
      // Call backend to cancel scheduled deletion
      // await ref.read(settingsStateProvider.notifier).cancelAccountDeletion();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account recovery successful! Your account has been restored.'),
            backgroundColor: SpendexColors.income,
          ),
        );
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to recover account: ${e.toString()}'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecovering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    // Get scheduled deletion date from state - placeholder for now
    final deletionDate = DateTime.now().add(const Duration(days: 30));
    final daysRemaining = deletionDate.difference(DateTime.now()).inDays;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Account Recovery'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Warning icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 40,
                color: SpendexColors.warning,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Account Scheduled for Deletion',
              style: SpendexTheme.headlineMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            Text(
              'Your account is scheduled to be permanently deleted in $daysRemaining days.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Countdown card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '$daysRemaining',
                    style: SpendexTheme.displayLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SpendexColors.expense,
                    ),
                  ),
                  Text(
                    'days remaining',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: SpendexColors.expense,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // What happens section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'After deletion:',
                    style: SpendexTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(textColor, 'All your data will be permanently removed'),
                  _buildBulletPoint(textColor, 'This action cannot be undone'),
                  _buildBulletPoint(textColor, 'You can create a new account with the same email'),
                ],
              ),
            ),

            const Spacer(),

            // Recover button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRecovering ? null : _recoverAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.income,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRecovering
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Recover My Account'),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Continue with deletion',
                style: TextStyle(color: secondaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(Color textColor, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: textColor)),
          Expanded(
            child: Text(
              text,
              style: SpendexTheme.bodyMedium.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
