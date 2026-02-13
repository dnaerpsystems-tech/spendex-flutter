import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/investment_model.dart';

/// A card widget that displays tax savings summary with progress bars.
///
/// This widget shows:
/// - Tax savings summary for the fiscal year
/// - Four main sections: 80C, 80D, 80E, 80CCD
/// - Progress bars showing current savings vs limits
/// - Color-coded progress indicators
/// - Gradient background (green/blue theme)
///
/// Features:
/// - Section-wise limits: 80C (₹1.5L), 80D (₹25K/50K), 80E (unlimited), 80CCD (₹50K)
/// - Indian currency formatting
/// - Material 3 design
/// - Dark mode support
class TaxSavingsCard extends StatelessWidget {
  const TaxSavingsCard({
    required this.summary,
    super.key,
  });

  final TaxSavingsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.teal.shade800.withOpacity(0.3),
                  Colors.blue.shade900.withOpacity(0.3),
                ]
              : [
                  Colors.teal.shade400,
                  Colors.blue.shade600,
                ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark
              ? SpendexColors.darkBorder
              : Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(SpendexTheme.spacingSm),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                ),
                child: Icon(
                  Iconsax.shield_tick,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Savings FY ${_getFiscalYear(summary.year)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: SpendexTheme.spacingXs),
                    Text(
                      'Total: ${CurrencyFormatter.formatPaise(summary.totalTaxSavings, decimalDigits: 0)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingXl),
          _TaxSectionProgress(
            sectionLabel: 'Section 80C',
            currentAmount: summary.savingsBySection['80C'] ?? 0,
            maxLimit: 15000000,
            description: 'PPF, EPF, ELSS, etc.',
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          _TaxSectionProgress(
            sectionLabel: 'Section 80D',
            currentAmount: summary.savingsBySection['80D'] ?? 0,
            maxLimit: 2500000,
            description: 'Health Insurance',
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          _TaxSectionProgress(
            sectionLabel: 'Section 80E',
            currentAmount: summary.savingsBySection['80E'] ?? 0,
            maxLimit: null,
            description: 'Education Loan Interest',
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          _TaxSectionProgress(
            sectionLabel: 'Section 80CCD(1B)',
            currentAmount: summary.savingsBySection['80CCD'] ?? 0,
            maxLimit: 5000000,
            description: 'NPS (Additional)',
          ),
        ],
      ),
    );
  }

  String _getFiscalYear(int year) {
    return '$year-${(year + 1).toString().substring(2)}';
  }
}

class _TaxSectionProgress extends StatelessWidget {
  const _TaxSectionProgress({
    required this.sectionLabel,
    required this.currentAmount,
    required this.maxLimit,
    required this.description,
  });

  final String sectionLabel;
  final int currentAmount;
  final int? maxLimit;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = maxLimit != null ? (currentAmount / maxLimit!).clamp(0.0, 1.0) : 0.0;
    final progressColor = _getProgressColor(progress);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingXs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            if (maxLimit != null)
              Text(
                'Limit: ${CurrencyFormatter.formatPaiseCompact(maxLimit!, decimalDigits: 2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        if (maxLimit != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatPaise(
                  currentAmount,
                  decimalDigits: 0,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpendexTheme.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.formatPaise(
                    currentAmount,
                    decimalDigits: 0,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingSm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'No Limit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.9) {
      return Colors.orange;
    } else if (progress >= 0.7) {
      return Colors.yellow.shade600;
    } else {
      return Colors.green.shade300;
    }
  }
}
