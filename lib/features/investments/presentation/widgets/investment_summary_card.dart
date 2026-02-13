import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/investment_model.dart';

/// A summary card widget that displays investment portfolio statistics.
///
/// This widget shows:
/// - Total Invested amount
/// - Current Value
/// - Total Returns (color-coded)
/// - Overall Returns percentage (color-coded)
/// - Grid layout with stat items
///
/// Features:
/// - Gradient background (purple/pink theme)
/// - Material 3 design
/// - Responsive to theme
/// - Indian currency formatting
/// - Color-coded profit/loss indicators
class InvestmentSummaryCard extends StatelessWidget {
  const InvestmentSummaryCard({
    required this.summary,
    super.key,
  });

  final InvestmentSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isProfit = summary.totalReturns >= 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.purple.shade900.withOpacity(0.3),
                  Colors.pink.shade900.withOpacity(0.3),
                ]
              : [
                  Colors.purple.shade400,
                  Colors.pink.shade400,
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
                child: const Icon(
                  Iconsax.chart_square,
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
                      'Portfolio Overview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: SpendexTheme.spacingXs),
                    Text(
                      '${summary.investmentCount} ${summary.investmentCount == 1 ? 'Investment' : 'Investments'}',
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
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: SpendexTheme.spacingMd,
            mainAxisSpacing: SpendexTheme.spacingMd,
            childAspectRatio: 1.5,
            children: [
              _SummaryStatItem(
                label: 'Total Invested',
                value: CurrencyFormatter.formatPaiseCompact(
                  summary.totalInvested,
                ),
                icon: Iconsax.money_send,
              ),
              _SummaryStatItem(
                label: 'Current Value',
                value: CurrencyFormatter.formatPaiseCompact(
                  summary.currentValue,
                ),
                icon: Iconsax.wallet_money,
              ),
              _SummaryStatItem(
                label: 'Total Returns',
                value:
                    '${isProfit ? '+' : ''}${CurrencyFormatter.formatPaiseCompact(summary.totalReturns)}',
                icon: isProfit ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                valueColor: isProfit ? Colors.green.shade300 : Colors.red.shade300,
              ),
              _SummaryStatItem(
                label: 'Returns %',
                value:
                    '${isProfit ? '+' : ''}${summary.overallReturnsPercent.toStringAsFixed(2)}%',
                icon: isProfit ? Iconsax.trend_up : Iconsax.trend_down,
                valueColor: isProfit ? Colors.green.shade300 : Colors.red.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  const _SummaryStatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white.withOpacity(0.8),
                size: 18,
              ),
              const SizedBox(width: SpendexTheme.spacingSm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
