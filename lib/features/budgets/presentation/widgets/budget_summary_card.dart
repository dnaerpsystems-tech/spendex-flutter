import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/budget_model.dart';
import 'budget_progress_bar.dart';

/// Budget Summary Card Widget
/// Displays overall budget summary with total amounts and progress
class BudgetSummaryCard extends StatelessWidget {
  final BudgetsSummary summary;
  final VoidCallback? onTap;

  const BudgetSummaryCard({
    super.key,
    required this.summary,
    this.onTap,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    SpendexColors.primary.withValues(alpha: 0.2),
                    SpendexColors.primaryDark.withValues(alpha: 0.15),
                  ]
                : [
                    SpendexColors.primary.withValues(alpha: 0.1),
                    SpendexColors.primaryLight.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
          border: Border.all(
            color: SpendexColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Iconsax.wallet_3,
                        color: SpendexColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Overview',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${summary.budgetCount} active budgets',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (summary.overBudgetCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SpendexColors.expense.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.warning_2,
                          size: 14,
                          color: SpendexColors.expense,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.overBudgetCount} over',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: SpendexColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Progress bar
            BudgetProgressBar(
              percentage: summary.overallPercentage,
              height: 10,
              showLabel: true,
              showWarningIcon: true,
            ),

            const SizedBox(height: 20),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Budget',
                    value: _formatCurrency(summary.totalBudgetInRupees),
                    color: SpendexColors.primary,
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Spent',
                    value: _formatCurrency(summary.totalSpentInRupees),
                    color: _getSpentColor(summary.overallPercentage),
                    isDark: isDark,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Remaining',
                    value: _formatCurrency(summary.totalRemainingInRupees),
                    color: summary.totalRemaining >= 0
                        ? SpendexColors.income
                        : SpendexColors.expense,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getSpentColor(double percentage) {
    if (percentage >= 100) return SpendexColors.expense;
    if (percentage >= 80) return const Color(0xFFF97316);
    if (percentage >= 60) return SpendexColors.warning;
    return SpendexColors.income;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: SpendexTheme.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextTertiary
                : SpendexColors.lightTextTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Budget Summary Loading Skeleton
class BudgetSummaryLoadingSkeleton extends StatelessWidget {
  const BudgetSummaryLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final shimmerHighlight = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shimmerBase, shimmerHighlight],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
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
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 10,
            decoration: BoxDecoration(
              color: shimmerHighlight,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 12,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
