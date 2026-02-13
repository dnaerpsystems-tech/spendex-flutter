import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A generic reusable card widget for displaying investment details.
///
/// This widget shows:
/// - Title section
/// - List of InfoRow items (label-value pairs)
/// - Card wrapper with elevation
/// - Consistent spacing and typography
///
/// Features:
/// - Material 3 card styling
/// - Can be reused in details screen
/// - Dark mode support
/// - Flexible row configuration
class InvestmentInfoCard extends StatelessWidget {
  const InvestmentInfoCard({
    required this.title,
    required this.rows,
    this.icon,
    super.key,
  });

  final String title;
  final List<InfoRow> rows;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? SpendexColors.darkTextPrimary
        : SpendexColors.lightTextPrimary;
    final dividerColor =
        isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: SpendexColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            ...List.generate(
              rows.length,
              (index) {
                final row = rows[index];
                final isLast = index == rows.length - 1;
                return Column(
                  children: [
                    _InfoRowWidget(
                      label: row.label,
                      value: row.value,
                      valueColor: row.valueColor,
                      textPrimary: textPrimary,
                    ),
                    if (!isLast) ...[
                      const SizedBox(height: SpendexTheme.spacingMd),
                      Divider(
                        color: dividerColor,
                        height: 1,
                      ),
                      const SizedBox(height: SpendexTheme.spacingMd),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRowWidget extends StatelessWidget {
  const _InfoRowWidget({
    required this.label,
    required this.value,
    required this.textPrimary,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final Color textPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textSecondary,
            ),
          ),
        ),
        const SizedBox(width: SpendexTheme.spacingMd),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// A data class representing a single row of information in the InvestmentInfoCard.
///
/// Used to pass label-value pairs to the card widget.
class InfoRow {
  const InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
}
