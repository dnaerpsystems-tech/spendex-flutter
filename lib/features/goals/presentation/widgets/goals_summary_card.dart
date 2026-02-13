import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/goal_model.dart';

/// A summary card widget displaying overall goals statistics.
///
/// This widget shows:
/// - Total goals count and completed count
/// - Total target amount and total saved amount
/// - Overall progress percentage
class GoalsSummaryCard extends StatelessWidget {
  /// Creates a goals summary card.
  ///
  /// The [summary] parameter is required and contains the aggregated statistics.
  const GoalsSummaryCard({
    required this.summary,
    super.key,
  });

  /// The summary data containing goals statistics.
  final GoalsSummary summary;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
                  SpendexColors.primary.withValues(alpha: 0.15),
                  SpendexColors.primaryLight.withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: SpendexColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryStatItem(
                  label: 'Total Goals',
                  value: '${summary.goalCount}',
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: SummaryStatItem(
                  label: 'Completed',
                  value: '${summary.completedCount}',
                  isDark: isDark,
                  valueColor: SpendexColors.income,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SummaryStatItem(
                  label: 'Total Target',
                  value: CurrencyFormatter.formatPaiseCompact(
                    summary.totalTarget,
                    decimalDigits: 1,
                  ),
                  isDark: isDark,
                ),
              ),
              Expanded(
                child: SummaryStatItem(
                  label: 'Total Saved',
                  value: CurrencyFormatter.formatPaiseCompact(
                    summary.totalSaved,
                    decimalDigits: 1,
                  ),
                  isDark: isDark,
                  valueColor: SpendexColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '${summary.overallProgress.toStringAsFixed(1)}%',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget displaying a single statistic item within the summary card.
///
/// Shows a label and a value with optional custom color.
class SummaryStatItem extends StatelessWidget {
  /// Creates a summary stat item.
  const SummaryStatItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    super.key,
  });

  /// The label text for the statistic.
  final String label;

  /// The value to display.
  final String value;

  /// Whether dark mode is active.
  final bool isDark;

  /// Optional custom color for the value.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: SpendexTheme.headlineMedium.copyWith(
            color: valueColor ??
                (isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
