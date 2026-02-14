import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/subscription_models.dart';

/// A card widget displaying invoice details with download option.
class InvoiceCard extends StatelessWidget {
  const InvoiceCard({
    required this.invoice,
    super.key,
    this.onDownload,
    this.isDownloading = false,
  });

  final InvoiceModel invoice;
  final VoidCallback? onDownload;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM dd, yyyy');
    final statusConfig = _getStatusConfig(invoice.status);

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                ),
                child: const Icon(
                  Iconsax.receipt_2,
                  size: 20,
                  color: SpendexColors.primary,
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.invoiceNumber,
                      style: SpendexTheme.titleMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextPrimary
                            : SpendexColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(invoice.date),
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpendexTheme.spacingMd,
                  vertical: SpendexTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: statusConfig.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                  border: Border.all(
                    color: statusConfig.color.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusConfig.icon, size: 12, color: statusConfig.color),
                    const SizedBox(width: 4),
                    Text(
                      statusConfig.label,
                      style: SpendexTheme.labelSmall.copyWith(
                        color: statusConfig.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Divider(
            height: 1,
            color:
                isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period',
                      style: SpendexTheme.labelSmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(invoice.periodStart)} - ${dateFormat.format(invoice.periodEnd)}',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Amount',
                    style: SpendexTheme.labelSmall.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextTertiary
                          : SpendexColors.lightTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${invoice.amount}',
                    style: SpendexTheme.headlineSmall.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isDownloading ? null : onDownload,
              icon: isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          SpendexColors.primary,
                        ),
                      ),
                    )
                  : const Icon(Iconsax.document_download, size: 18),
              label: Text(isDownloading ? 'Downloading...' : 'Download PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: SpendexColors.primary,
                side: const BorderSide(color: SpendexColors.primary),
                padding: const EdgeInsets.symmetric(
                  vertical: SpendexTheme.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return _StatusConfig(
          label: 'Paid',
          icon: Iconsax.tick_circle5,
          color: SpendexColors.income,
        );
      case InvoiceStatus.pending:
        return _StatusConfig(
          label: 'Pending',
          icon: Iconsax.clock,
          color: SpendexColors.warning,
        );
      case InvoiceStatus.failed:
        return _StatusConfig(
          label: 'Failed',
          icon: Iconsax.close_circle5,
          color: SpendexColors.expense,
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
  });
  final String label;
  final IconData icon;
  final Color color;
}

/// Skeleton loading widget for the invoice card.
class InvoiceCardSkeleton extends StatelessWidget {
  const InvoiceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? SpendexColors.darkBorder.withOpacity(0.5)
        : SpendexColors.lightBorder.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}
