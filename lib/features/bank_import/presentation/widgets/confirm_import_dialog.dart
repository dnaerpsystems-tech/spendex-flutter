import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Confirmation dialog before importing transactions
class ConfirmImportDialog extends StatelessWidget {
  const ConfirmImportDialog({
    required this.selectedCount,
    required this.totalAmount,
    required this.onConfirm,
    super.key,
  });

  final int selectedCount;
  final int totalAmount;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
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
              child: const Center(
                child: Icon(
                  Iconsax.document_upload,
                  size: 40,
                  color: SpendexColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Confirm Import',
              style: SpendexTheme.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'You are about to import the following transactions to your account:',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Stats card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpendexColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Transaction count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.receipt_item,
                            size: 20,
                            color: SpendexColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Transactions',
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$selectedCount',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: SpendexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: SpendexColors.primary.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  // Total amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Iconsax.wallet_money,
                            size: 20,
                            color: SpendexColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total Amount',
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.formatPaise(
                          totalAmount,
                          decimalDigits: 0,
                        ),
                        style: SpendexTheme.titleMedium.copyWith(
                          color: SpendexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Warning notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpendexColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    color: SpendexColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action cannot be undone',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
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
                        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Cancel',
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
                      onConfirm();
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
                      'Confirm',
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

/// Show confirm import dialog
Future<bool?> showConfirmImportDialog(
  BuildContext context, {
  required int selectedCount,
  required int totalAmount,
  required VoidCallback onConfirm,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ConfirmImportDialog(
      selectedCount: selectedCount,
      totalAmount: totalAmount,
      onConfirm: onConfirm,
    ),
  );
}
