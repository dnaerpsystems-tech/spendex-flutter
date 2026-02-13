import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Reusable empty state widget for import screens
class EmptyImportState extends StatelessWidget {
  const EmptyImportState({
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 56,
                  color: SpendexColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: SpendexTheme.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty state: No imports
class NoImportsEmptyState extends StatelessWidget {
  const NoImportsEmptyState({
    this.onAction,
    super.key,
  });

  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return EmptyImportState(
      icon: Iconsax.document_upload,
      title: 'No Imports Yet',
      description:
          'Start importing your bank transactions from PDF, SMS, or Account Aggregator to get insights into your spending.',
      actionLabel: 'Import Now',
      onAction: onAction,
    );
  }
}

/// Predefined empty state: No SMS found
class NoSmsEmptyState extends StatelessWidget {
  const NoSmsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyImportState(
      icon: Iconsax.messages,
      title: 'No Bank SMS Found',
      description:
          'No bank transaction SMS messages found in the selected date range. Try adjusting the date range or check if you have bank SMS in your inbox.',
    );
  }
}

/// Predefined empty state: No accounts linked
class NoLinkedAccountsEmptyState extends StatelessWidget {
  const NoLinkedAccountsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyImportState(
      icon: Iconsax.bank,
      title: 'No Linked Accounts',
      description:
          "You haven't linked any bank accounts yet. Link your accounts to start importing transactions via Account Aggregator.",
    );
  }
}

/// Predefined empty state: No transactions parsed
class NoTransactionsParsedEmptyState extends StatelessWidget {
  const NoTransactionsParsedEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyImportState(
      icon: Iconsax.receipt_item,
      title: 'No Transactions Found',
      description:
          "We couldn't extract any transactions from the uploaded file. Please make sure the file contains valid transaction data in a supported format.",
    );
  }
}
