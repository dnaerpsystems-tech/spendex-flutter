import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/parsed_transaction_model.dart';

/// Reusable tile for displaying parsed transaction preview
class TransactionPreviewTile extends StatelessWidget {
  const TransactionPreviewTile({
    required this.transaction,
    required this.isSelected,
    required this.onSelectionChanged,
    this.onEdit,
    this.showCheckbox = true,
    this.showEditButton = true,
    this.showConfidence = true,
    super.key,
  });

  final ParsedTransactionModel transaction;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback? onEdit;
  final bool showCheckbox;
  final bool showEditButton;
  final bool showConfidence;

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.income:
        return Iconsax.money_recive;
      case TransactionType.expense:
        return Iconsax.money_send;
    }
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getTransactionColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? SpendexColors.primary
              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showCheckbox
              ? () => onSelectionChanged(!isSelected)
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                if (showCheckbox)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _getTransactionIcon(),
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant/Description
                      Text(
                        transaction.merchant ?? (
                            transaction.description.isNotEmpty ? transaction.description : 'Transaction'),
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Category and Date
                      Row(
                        children: [
                          if (transaction.category != null) ...[
                            Icon(
                              Iconsax.category,
                              size: 14,
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              transaction.category!,
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Icon(
                            Iconsax.calendar,
                            size: 14,
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(transaction.date),
                            style: SpendexTheme.labelMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Confidence badge (if enabled)
                      if (showConfidence && transaction.confidence < 1.0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getConfidenceColor(transaction.confidence)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                size: 12,
                                color:
                                    _getConfidenceColor(transaction.confidence),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(transaction.confidence * 100).toInt()}% confidence',
                                style: SpendexTheme.labelMedium.copyWith(
                                  color: _getConfidenceColor(
                                    transaction.confidence,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount and Edit button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.formatPaise(transaction.amount.toInt(), decimalDigits: 0)}',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (showEditButton && onEdit != null) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                SpendexColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.edit,
                                size: 12,
                                color: SpendexColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Edit',
                                style: SpendexTheme.labelMedium.copyWith(
                                  color: SpendexColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) {
      return SpendexColors.income;
    } else if (confidence >= 0.5) {
      return SpendexColors.warning;
    } else {
      return SpendexColors.expense;
    }
  }
}
