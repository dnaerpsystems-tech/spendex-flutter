import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/loan_model.dart';

class LoanCard extends StatelessWidget {
  const LoanCard({
    required this.loan,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final LoanModel loan;
  final bool isDark;
  final VoidCallback onTap;

  IconData _getLoanTypeIcon(LoanType type) {
    switch (type) {
      case LoanType.home:
        return Iconsax.home;
      case LoanType.vehicle:
        return Iconsax.car;
      case LoanType.personal:
        return Iconsax.wallet_money;
      case LoanType.education:
        return Iconsax.book;
      case LoanType.gold:
        return Iconsax.medal_star;
      case LoanType.business:
        return Iconsax.brifecase_tick;
      case LoanType.other:
        return Iconsax.receipt_item;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = loan.progressPercentage / 100;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            border: Border.all(
              color:
                  isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getLoanTypeIcon(loan.type),
                      color: const Color(0xFF7C3AED),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                loan.name,
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextPrimary
                                      : SpendexColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: loan.isActive
                                    ? SpendexColors.income
                                        .withValues(alpha: 0.12)
                                    : SpendexColors.darkTextSecondary
                                        .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(SpendexTheme.radiusSm),
                              ),
                              child: Text(
                                loan.status.label,
                                style: SpendexTheme.labelMedium.copyWith(
                                  fontSize: 12,
                                  color: loan.isActive
                                      ? SpendexColors.income
                                      : SpendexColors.darkTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loan.type.label,
                          style: SpendexTheme.bodyMedium.copyWith(
                            fontSize: 13,
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loan.isActive
                        ? const Color(0xFF7C3AED)
                        : SpendexColors.income,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remaining',
                        style: SpendexTheme.labelMedium.copyWith(
                          fontSize: 12,
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatPaiseCompact(
                          loan.remainingAmount,
                          decimalDigits: 1,
                        ),
                        style: SpendexTheme.titleMedium.copyWith(
                          fontSize: 14,
                          color: SpendexColors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EMI Amount',
                        style: SpendexTheme.labelMedium.copyWith(
                          fontSize: 12,
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatPaise(
                          loan.emiAmount,
                          decimalDigits: 0,
                        ),
                        style: SpendexTheme.titleMedium.copyWith(
                          fontSize: 14,
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (loan.isActive && loan.nextEmiDate != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBorder.withValues(alpha: 0.3)
                        : SpendexColors.lightBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 16,
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next EMI: ${dateFormat.format(loan.nextEmiDate!)}',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
