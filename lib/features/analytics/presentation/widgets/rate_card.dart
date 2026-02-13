import 'package:flutter/material.dart';
import '../../../../app/theme.dart';

/// Card for displaying rate/percentage values like savings rate
class RateCard extends StatelessWidget {
  const RateCard({
    super.key,
    required this.title,
    required this.value,
    this.suffix = '%',
    this.goodThreshold = 20,
    this.warningThreshold = 0,
  });

  final String title;
  final double value;
  final String suffix;
  final double goodThreshold;
  final double warningThreshold;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = value >= goodThreshold
        ? SpendexColors.income
        : (value >= warningThreshold ? SpendexColors.warning : SpendexColors.expense);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SpendexTheme.labelSmall.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${value.toStringAsFixed(1)}$suffix',
            style: SpendexTheme.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
