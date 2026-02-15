import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/budget_model.dart';
import 'budget_progress_bar.dart';

/// Budget Card Widget
/// Displays a budget with progress, amounts, and status
class BudgetCard extends StatelessWidget {
  const BudgetCard({
    required this.budget,
    super.key,
    this.onTap,
    this.compact = false,
    this.showCategory = true,
  });
  final BudgetModel budget;
  final VoidCallback? onTap;
  final bool compact;
  final bool showCategory;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  int _getDaysRemaining() {
    final now = DateTime.now();
    return budget.endDate.difference(now).inDays;
  }

  Color _getStatusColor() {
    if (budget.percentage >= 100) {
      return SpendexColors.expense;
    }
    if (budget.percentage >= 80) {
      return const Color(0xFFF97316);
    }
    if (budget.percentage >= 60) {
      return SpendexColors.warning;
    }
    return SpendexColors.income;
  }

  IconData _getCategoryIcon() {
    if (budget.category != null && budget.category!.icon != null) {
      return _parseIconName(budget.category!.icon!);
    }
    return Iconsax.wallet_3;
  }

  IconData _parseIconName(String iconName) {
    final iconMap = {
      'shopping-cart': Iconsax.shopping_cart,
      'restaurant': Iconsax.reserve,
      'car': Iconsax.car,
      'home': Iconsax.home,
      'medical': Iconsax.health,
      'education': Iconsax.book,
      'entertainment': Iconsax.game,
      'travel': Iconsax.airplane,
      'gift': Iconsax.gift,
      'bills': Iconsax.receipt,
      'groceries': Iconsax.shopping_bag,
      'fitness': Iconsax.weight,
      'personal': Iconsax.user,
      'investment': Iconsax.chart_2,
      'salary': Iconsax.money_recive,
      'business': Iconsax.briefcase,
    };
    return iconMap[iconName] ?? Iconsax.wallet_3;
  }

  Color _getCategoryColor() {
    final categoryColor = budget.category?.color;
    if (categoryColor != null && categoryColor.isNotEmpty) {
      try {
        final colorString = categoryColor.replaceAll('#', '');
        return Color(int.parse('FF$colorString', radix: 16));
      } catch (_) {
        return SpendexColors.primary;
      }
    }
    return SpendexColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysRemaining = _getDaysRemaining();
    final statusColor = _getStatusColor();
    final categoryColor = _getCategoryColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: compact ? 10 : 12),
        padding: EdgeInsets.all(compact ? 14 : 16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Category icon
                Container(
                  width: compact ? 40 : 44,
                  height: compact ? 40 : 44,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: categoryColor,
                    size: compact ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                          fontSize: compact ? 14 : 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (showCategory && budget.category != null) ...[
                            Text(
                              budget.category!.name,
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? SpendexColors.darkTextTertiary
                                    : SpendexColors.lightTextTertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Text(
                            budget.period.label,
                            style: SpendexTheme.labelMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(
                  daysRemaining: daysRemaining,
                  percentage: budget.percentage,
                  statusColor: statusColor,
                  isDark: isDark,
                  compact: compact,
                ),
              ],
            ),

            SizedBox(height: compact ? 14 : 16),

            // Progress bar
            BudgetProgressBar(
              percentage: budget.percentage,
              alertThreshold: budget.alertThreshold,
              height: compact ? 6 : 8,
            ),

            SizedBox(height: compact ? 12 : 14),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Spent
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(budget.spentInRupees),
                      style: SpendexTheme.titleMedium.copyWith(
                        color: statusColor,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Limit
                Column(
                  children: [
                    Text(
                      'Limit',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(budget.amountInRupees),
                      style: SpendexTheme.titleMedium.copyWith(
                        color:
                            isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Remaining
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      budget.isOverBudget ? 'Over' : 'Left',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(budget.remainingInRupees.abs()),
                      style: SpendexTheme.titleMedium.copyWith(
                        color: budget.isOverBudget ? SpendexColors.expense : SpendexColors.income,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.daysRemaining,
    required this.percentage,
    required this.statusColor,
    required this.isDark,
    this.compact = false,
  });
  final int daysRemaining;
  final double percentage;
  final Color statusColor;
  final bool isDark;
  final bool compact;

  String _formatDaysRemaining(int days) {
    if (days < 0) {
      return 'Ended';
    }
    if (days == 0) {
      return 'Last day';
    }
    if (days == 1) {
      return '1 day';
    }
    return '$days days';
  }

  @override
  Widget build(BuildContext context) {
    final isOverBudget = percentage >= 100;
    final isWarning = percentage >= 80;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isOverBudget || isWarning) ...[
            Icon(
              isOverBudget ? Iconsax.danger : Iconsax.warning_2,
              size: compact ? 12 : 14,
              color: statusColor,
            ),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            isOverBudget
                ? '${percentage.toStringAsFixed(0)}%'
                : _formatDaysRemaining(daysRemaining),
            style: SpendexTheme.labelMedium.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Budget Card Loading Skeleton
class BudgetCardSkeleton extends StatelessWidget {
  const BudgetCardSkeleton({
    super.key,
    this.compact = false,
  });
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final shimmerHighlight =
        isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 10 : 12),
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shimmerBase, shimmerHighlight],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: compact ? 40 : 44,
                height: compact ? 40 : 44,
                decoration: BoxDecoration(
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: shimmerHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmerHighlight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 28,
                decoration: BoxDecoration(
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),

          SizedBox(height: compact ? 14 : 16),

          // Progress bar
          Container(
            width: double.infinity,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: shimmerHighlight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          SizedBox(height: compact ? 12 : 14),

          // Amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (index) => Column(
                crossAxisAlignment: index == 0
                    ? CrossAxisAlignment.start
                    : index == 2
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 35,
                    height: 10,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: shimmerHighlight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Large Budget Card for details screen header
class BudgetDetailCard extends StatelessWidget {
  const BudgetDetailCard({
    required this.budget,
    super.key,
    this.onEdit,
  });
  final BudgetModel budget;
  final VoidCallback? onEdit;

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor() {
    if (budget.percentage >= 100) {
      return SpendexColors.expense;
    }
    if (budget.percentage >= 80) {
      return const Color(0xFFF97316);
    }
    if (budget.percentage >= 60) {
      return SpendexColors.warning;
    }
    return SpendexColors.income;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();
    final daysRemaining = budget.endDate.difference(DateTime.now()).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withValues(alpha: 0.15),
            statusColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and period
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name,
                      style: SpendexTheme.headlineMedium.copyWith(
                        color:
                            isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SpendexColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            budget.period.label,
                            style: SpendexTheme.labelMedium.copyWith(
                              color: SpendexColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        if (budget.category != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            budget.category!.name,
                            style: SpendexTheme.labelMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Iconsax.edit_2,
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Circular progress
          Center(
            child: BudgetCircularProgress(
              percentage: budget.percentage,
              alertThreshold: budget.alertThreshold,
              size: 160,
              strokeWidth: 14,
            ),
          ),

          const SizedBox(height: 24),

          // Amount stats
          Row(
            children: [
              Expanded(
                child: _DetailStatItem(
                  label: 'Spent',
                  value: _formatCurrency(budget.spentInRupees),
                  color: statusColor,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
              Expanded(
                child: _DetailStatItem(
                  label: 'Limit',
                  value: _formatCurrency(budget.amountInRupees),
                  color: SpendexColors.primary,
                  isDark: isDark,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
              Expanded(
                child: _DetailStatItem(
                  label: budget.isOverBudget ? 'Over' : 'Remaining',
                  value: _formatCurrency(budget.remainingInRupees.abs()),
                  color: budget.isOverBudget ? SpendexColors.expense : SpendexColors.income,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Period info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
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
                      '${_formatDate(budget.startDate)} - ${_formatDate(budget.endDate)}',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    daysRemaining < 0
                        ? 'Ended'
                        : daysRemaining == 0
                            ? 'Last day'
                            : '$daysRemaining days left',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
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

class _DetailStatItem extends StatelessWidget {
  const _DetailStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: SpendexTheme.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
          ),
        ),
      ],
    );
  }
}
