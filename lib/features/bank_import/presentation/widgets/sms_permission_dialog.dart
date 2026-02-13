import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Dialog explaining SMS permission requirement
class SmsPermissionDialog extends StatelessWidget {
  const SmsPermissionDialog({
    required this.onRequestPermission,
    super.key,
  });

  final VoidCallback onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark
          ? SpendexColors.darkCard
          : SpendexColors.lightCard,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Center(
                child: Icon(
                  Iconsax.messages,
                  size: 40,
                  color: SpendexColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'SMS Permission Required',
              style: SpendexTheme.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'To automatically import transactions from bank SMS, we need permission to read your SMS messages.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Security notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpendexColors.income.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.shield_tick,
                    color: SpendexColors.income,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your SMS data is processed locally and never stored on our servers',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.income,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Features list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeatureItem(
                  icon: Iconsax.tick_circle,
                  text: 'Automatically detect bank transactions',
                ),
                const SizedBox(height: 8),
                _FeatureItem(
                  icon: Iconsax.tick_circle,
                  text: 'Parse amount, category, and merchant',
                ),
                const SizedBox(height: 8),
                _FeatureItem(
                  icon: Iconsax.tick_circle,
                  text: 'Filter by bank and date range',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Not Now',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onRequestPermission();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Allow',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          color: SpendexColors.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Show SMS permission dialog
Future<bool?> showSmsPermissionDialog(
  BuildContext context,
  VoidCallback onRequestPermission,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SmsPermissionDialog(
      onRequestPermission: onRequestPermission,
    ),
  );
}
