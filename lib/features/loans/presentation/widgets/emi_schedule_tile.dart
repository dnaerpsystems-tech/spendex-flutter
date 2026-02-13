import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/loan_model.dart';
import 'loan_info_card.dart';

class EmiScheduleTile extends StatefulWidget {
  const EmiScheduleTile({
    required this.emi,
    this.onTap,
    super.key,
  });

  final EmiSchedule emi;
  final VoidCallback? onTap;

  @override
  State<EmiScheduleTile> createState() => _EmiScheduleTileState();
}

class _EmiScheduleTileState extends State<EmiScheduleTile> {
  bool _isExpanded = false;

  Color _getBackgroundColor(bool isDark) {
    if (widget.emi.isPaid) {
      return SpendexColors.income.withValues(alpha: 0.08);
    } else if (widget.emi.isOverdue) {
      return SpendexColors.expense.withValues(alpha: 0.08);
    }
    return isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
  }

  Color _getBorderColor(bool isDark) {
    if (widget.emi.isPaid) {
      return SpendexColors.income.withValues(alpha: 0.3);
    } else if (widget.emi.isOverdue) {
      return SpendexColors.expense.withValues(alpha: 0.3);
    }
    return isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
  }

  IconData _getStatusIcon() {
    if (widget.emi.isPaid) {
      return Iconsax.tick_circle;
    } else if (widget.emi.isOverdue) {
      return Iconsax.warning_2;
    }
    return Iconsax.clock;
  }

  Color _getStatusIconColor() {
    if (widget.emi.isPaid) {
      return SpendexColors.income;
    } else if (widget.emi.isOverdue) {
      return SpendexColors.expense;
    }
    return SpendexColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: _getBorderColor(isDark),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getStatusIconColor().withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusIconColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Month ${widget.emi.month}',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(widget.emi.dueDate),
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.formatPaise(widget.emi.emiAmount),
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Icon(
                          _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                          size: 16,
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(SpendexTheme.radiusMd),
                    bottomRight: Radius.circular(SpendexTheme.radiusMd),
                  ),
                ),
                child: Column(
                  children: [
                    InfoRow(
                      label: 'Principal',
                      value: CurrencyFormatter.formatPaise(widget.emi.principal),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Interest',
                      value: CurrencyFormatter.formatPaise(widget.emi.interest),
                      valueColor: SpendexColors.expense,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      label: 'Balance Remaining',
                      value: CurrencyFormatter.formatPaise(widget.emi.balance),
                    ),
                    if (widget.emi.paidDate != null) ...[
                      const SizedBox(height: 8),
                      InfoRow(
                        label: 'Paid On',
                        value: DateFormat('dd MMM yyyy').format(widget.emi.paidDate!),
                        valueColor: SpendexColors.income,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
