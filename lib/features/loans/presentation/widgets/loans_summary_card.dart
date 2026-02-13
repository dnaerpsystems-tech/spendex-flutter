import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/loan_model.dart';

class LoansSummaryCard extends StatelessWidget {
  const LoansSummaryCard({required this.summary, super.key});

  final LoansSummary summary;

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
                  const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  const Color(0xFF3B82F6).withValues(alpha: 0.15),
                ]
              : [
                  const Color(0xFF7C3AED).withValues(alpha: 0.15),
                  const Color(0xFF3B82F6).withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryStatItem(
                  label: 'Total Outstanding',
                  value: CurrencyFormatter.formatPaiseCompact(
                    summary.totalOutstanding,
                    decimalDigits: 1,
                  ),
                  isDark: isDark,
                  valueColor: SpendexColors.expense,
                ),
              ),
              Expanded(
                child: SummaryStatItem(
                  label: 'Monthly EMI',
                  value: CurrencyFormatter.formatPaiseCompact(
                    summary.totalMonthlyEmi,
                    decimalDigits: 1,
                  ),
                  isDark: isDark,
                  valueColor: const Color(0xFF7C3AED),
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
                  'Active Loans',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '${summary.activeLoanCount} of ${summary.loanCount}',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: const Color(0xFF7C3AED),
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

class SummaryStatItem extends StatelessWidget {
  const SummaryStatItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final bool isDark;
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
