import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Reusable stat card for displaying financial values
class StatCard extends StatelessWidget {
  const StatCard({
    required this.title, required this.value, required this.color, super.key,
    this.subtitle,
    this.icon,
    this.showTrend = false,
    this.trendValue,
    this.trendIsPositive,
  });

  final String title;
  final double value;
  final Color color;
  final String? subtitle;
  final IconData? icon;
  final bool showTrend;
  final double? trendValue;
  final bool? trendIsPositive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  title,
                  style: SpendexTheme.labelSmall.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatCompact(value),
            style: SpendexTheme.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: SpendexTheme.labelSmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
            ),
          ],
          if (showTrend && trendValue != null) ...[
            const SizedBox(height: 8),
            TrendIndicator(
              value: trendValue!,
              isPositive: trendIsPositive ?? trendValue! >= 0,
            ),
          ],
        ],
      ),
    );
  }
}

/// Trend indicator showing percentage change
class TrendIndicator extends StatelessWidget {
  const TrendIndicator({
    required this.value, required this.isPositive, super.key,
  });

  final double value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? SpendexColors.income : SpendexColors.expense;
    final iconData = isPositive ? Icons.trending_up : Icons.trending_down;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '${value.abs().toStringAsFixed(1)}%',
          style: SpendexTheme.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
