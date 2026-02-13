import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Statistics row for email parser (total, parsed, failed, selected)
class EmailStatsRow extends StatelessWidget {
  const EmailStatsRow({
    required this.total,
    required this.parsed,
    required this.failed,
    required this.selected,
    super.key,
  });

  final int total;
  final int parsed;
  final int failed;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SpendexColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'Total',
            value: '$total',
            color: SpendexColors.primary,
          ),
          _StatItem(
            label: 'Parsed',
            value: '$parsed',
            color: SpendexColors.income,
          ),
          _StatItem(
            label: 'Failed',
            value: '$failed',
            color: SpendexColors.expense,
          ),
          _StatItem(
            label: 'Selected',
            value: '$selected',
            color: SpendexColors.transfer,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: SpendexTheme.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}
