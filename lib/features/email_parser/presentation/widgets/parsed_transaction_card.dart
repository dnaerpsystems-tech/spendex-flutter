import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';

/// Card showing parsed transaction details from email
class ParsedTransactionCard extends StatelessWidget {
  const ParsedTransactionCard({
    required this.transaction,
    this.bankName,
    super.key,
  });

  final ParsedTransactionModel transaction;
  final String? bankName;

  IconData _getTypeIcon() {
    switch (transaction.type) {
      case TransactionType.income:
        return Iconsax.arrow_down;
      case TransactionType.expense:
        return Iconsax.arrow_up;
    }
  }

  Color _getTypeColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
    }
  }

  String _getTypeLabel() {
    switch (transaction.type) {
      case TransactionType.income:
        return 'Credit';
      case TransactionType.expense:
        return 'Debit';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getTypeColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getTypeIcon(),
                    color: typeColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getTypeLabel(),
                      style: SpendexTheme.labelMedium.copyWith(
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.formatPaise(
                  transaction.amount.toInt(),
                ),
                style: SpendexTheme.headlineMedium.copyWith(
                  color: typeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details
          _DetailRow(
            icon: Iconsax.calendar,
            label: 'Date',
            value: _formatDate(transaction.date),
          ),
          if (bankName != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Iconsax.bank,
              label: 'Bank',
              value: bankName!,
            ),
          ],
          if (transaction.category != null) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Iconsax.category,
              label: 'Category',
              value: transaction.category!,
            ),
          ],
          if (transaction.account != null && transaction.account!.length >= 4) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Iconsax.card,
              label: 'Account',
              value: '****${transaction.account!.substring(transaction.account!.length - 4)}',
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: SpendexTheme.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
