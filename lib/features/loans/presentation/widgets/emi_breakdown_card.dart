import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class EmiBreakdownCard extends StatelessWidget {
  const EmiBreakdownCard({
    required this.emiAmount,
    required this.principalAmount,
    required this.totalInterest,
    required this.totalAmount,
    required this.isDark,
    super.key,
  });

  final int emiAmount;
  final num principalAmount;
  final int totalInterest;
  final int totalAmount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Monthly EMI',
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatPaise(emiAmount, decimalDigits: 0),
            style: SpendexTheme.headlineMedium.copyWith(
              fontSize: 28,
              color: const Color(0xFF7C3AED),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
            child: Column(
              children: [
                BreakdownRow(
                  label: 'Principal Amount',
                  value: CurrencyFormatter.formatPaise(
                    principalAmount.round(),
                    decimalDigits: 0,
                  ),
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                BreakdownRow(
                  label: 'Total Interest',
                  value: CurrencyFormatter.formatPaise(
                    totalInterest,
                    decimalDigits: 0,
                  ),
                  isDark: isDark,
                  valueColor: SpendexColors.expense,
                ),
                const SizedBox(height: 12),
                Divider(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
                const SizedBox(height: 12),
                BreakdownRow(
                  label: 'Total Payable',
                  value: CurrencyFormatter.formatPaise(
                    totalAmount,
                    decimalDigits: 0,
                  ),
                  isDark: isDark,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BreakdownRow extends StatelessWidget {
  const BreakdownRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    this.isTotal = false,
    super.key,
  });

  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? SpendexTheme.titleMedium.copyWith(fontSize: 14)
              : SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
                ),
        ),
        Text(
          value,
          style: (isTotal ? SpendexTheme.titleMedium : SpendexTheme.bodyMedium).copyWith(
            color: valueColor ??
                (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
