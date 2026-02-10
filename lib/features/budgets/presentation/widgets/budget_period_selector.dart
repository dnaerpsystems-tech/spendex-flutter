import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/budget_model.dart';

/// Budget Period Selector Widget
/// Displays selectable chips for budget periods
class BudgetPeriodSelector extends StatelessWidget {

  const BudgetPeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.showAllOption = true,
    this.compact = false,
  });
  final BudgetPeriod? selectedPeriod;
  final ValueChanged<BudgetPeriod?> onPeriodChanged;
  final bool showAllOption;
  final bool compact;

  IconData _getPeriodIcon(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        return Iconsax.calendar_1;
      case BudgetPeriod.monthly:
        return Iconsax.calendar;
      case BudgetPeriod.quarterly:
        return Iconsax.calendar_2;
      case BudgetPeriod.yearly:
        return Iconsax.calendar_tick;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: compact ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (showAllOption) ...[
            _PeriodChip(
              label: 'All',
              icon: Iconsax.category,
              isSelected: selectedPeriod == null,
              onTap: () => onPeriodChanged(null),
              isDark: isDark,
              compact: compact,
            ),
            SizedBox(width: compact ? 6 : 8),
          ],
          ...BudgetPeriod.values.map((period) {
            return Padding(
              padding: EdgeInsets.only(right: compact ? 6 : 8),
              child: _PeriodChip(
                label: period.label,
                icon: _getPeriodIcon(period),
                isSelected: selectedPeriod == period,
                onTap: () => onPeriodChanged(period),
                isDark: isDark,
                compact: compact,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {

  const _PeriodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    this.compact = false,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 14,
          vertical: compact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? SpendexColors.primary
              : isDark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(compact ? 8 : 10),
          border: Border.all(
            color: isSelected
                ? SpendexColors.primary
                : isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: SpendexColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: compact ? 14 : 16,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
            ),
            SizedBox(width: compact ? 4 : 6),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: compact ? 11 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Budget Status Filter Widget
/// Displays selectable chips for budget status filtering
class BudgetStatusFilter extends StatelessWidget {

  const BudgetStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.onTrackCount,
    this.warningCount,
    this.exceededCount,
  });
  final BudgetStatus? selectedStatus;
  final ValueChanged<BudgetStatus?> onStatusChanged;
  final int? onTrackCount;
  final int? warningCount;
  final int? exceededCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          _StatusChip(
            label: 'All',
            color: SpendexColors.primary,
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'On Track',
            count: onTrackCount,
            color: SpendexColors.income,
            isSelected: selectedStatus == BudgetStatus.onTrack,
            onTap: () => onStatusChanged(BudgetStatus.onTrack),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Warning',
            count: warningCount,
            color: SpendexColors.warning,
            isSelected: selectedStatus == BudgetStatus.warning,
            onTap: () => onStatusChanged(BudgetStatus.warning),
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'Over Budget',
            count: exceededCount,
            color: SpendexColors.expense,
            isSelected: selectedStatus == BudgetStatus.exceeded,
            onTap: () => onStatusChanged(BudgetStatus.exceeded),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {

  const _StatusChip({
    required this.label,
    this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });
  final String label;
  final int? count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color
              : isDark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isSelected ? Colors.white : color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
