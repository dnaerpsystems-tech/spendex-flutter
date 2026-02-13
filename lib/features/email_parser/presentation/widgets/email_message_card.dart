import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../../../bank_import/data/models/sms_message_model.dart';
import '../../data/models/email_message_model.dart';

/// Email message card with checkbox, status badge, and preview
class EmailMessageCard extends StatelessWidget {
  const EmailMessageCard({
    required this.email,
    required this.isSelected,
    required this.onToggle,
    this.onTap,
    super.key,
  });

  final EmailMessageModel email;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  Color _getStatusColor() {
    switch (email.parseStatus) {
      case ParseStatus.parsed:
        return SpendexColors.income;
      case ParseStatus.failed:
        return SpendexColors.expense;
      case ParseStatus.unparsed:
        return SpendexColors.warning;
    }
  }

  String _getStatusLabel() {
    switch (email.parseStatus) {
      case ParseStatus.parsed:
        return 'Parsed';
      case ParseStatus.failed:
        return 'Failed';
      case ParseStatus.unparsed:
        return 'Unparsed';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _getEmailPreview() {
    final preview = email.body.replaceAll('\n', ' ').trim();
    return preview.length > 80 ? '${preview.substring(0, 80)}...' : preview;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transaction = email.parsedTransaction;
    final isParsed = email.parseStatus == ParseStatus.parsed;

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
          onTap: onTap ?? (isParsed ? onToggle : null),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox for parsed emails
                if (isParsed)
                  Padding(
                    padding: const EdgeInsets.only(right: 12, top: 2),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggle(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                // Email content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email.subject,
                              style: SpendexTheme.titleMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getStatusLabel(),
                              style: SpendexTheme.labelMedium.copyWith(
                                color: _getStatusColor(),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // From and date
                      Row(
                        children: [
                          Icon(
                            Iconsax.sms,
                            size: 14,
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              email.from,
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(email.date),
                            style: SpendexTheme.labelMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Parsed transaction or preview
                      if (transaction != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SpendexColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: SpendexColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      transaction.description,
                                      style: SpendexTheme.bodyMedium.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    if (email.bankName != null)
                                      Text(
                                        email.bankName!,
                                        style: SpendexTheme.labelMedium.copyWith(
                                          color: isDark
                                              ? SpendexColors.darkTextSecondary
                                              : SpendexColors.lightTextSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                CurrencyFormatter.formatPaise(
                                  transaction.amount.toInt(),
                                  decimalDigits: 0,
                                ),
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: transaction.type == TransactionType.income
                                      ? SpendexColors.income
                                      : SpendexColors.expense,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          _getEmailPreview(),
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Attachments indicator
                      if (email.hasAttachment) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Iconsax.attach_circle,
                              size: 14,
                              color: SpendexColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${email.attachments.length} attachment${email.attachments.length != 1 ? 's' : ''}',
                              style: SpendexTheme.labelMedium.copyWith(
                                color: SpendexColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
