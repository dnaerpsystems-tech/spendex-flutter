import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';

/// A widget that displays a date header for grouping transactions by date.
///
/// This widget is designed to be used as a section header in transaction lists,
/// showing the date and optionally displaying income/expense totals for that date.
class DateGroupHeader extends StatelessWidget {
  /// Creates a date group header.
  ///
  /// The [date] parameter is required and specifies the date to display.
  /// If [showTotals] is true, [totalIncome] and [totalExpense] will be displayed.
  const DateGroupHeader({
    required this.date, super.key,
    this.totalIncome,
    this.totalExpense,
    this.showTotals = false,
  });

  /// The date to display in the header.
  final DateTime date;

  /// The total income for this date in rupees.
  final double? totalIncome;

  /// The total expense for this date in rupees.
  final double? totalExpense;

  /// Whether to show the income/expense totals.
  final bool showTotals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingXl,
        vertical: SpendexTheme.spacingMd,
      ),
      color: isDark
          ? SpendexColors.darkBackground.withOpacity(0.95)
          : SpendexColors.lightBackground.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Date label
          Text(
            _formatDate(date),
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
              fontSize: 15,
            ),
          ),

          // Totals (optional)
          if (showTotals) _buildTotals(),
        ],
      ),
    );
  }

  /// Formats the date based on how recent it is.
  ///
  /// Returns:
  /// - "Today" if the date is today
  /// - "Yesterday" if the date is yesterday
  /// - "Monday, Feb 10" for dates within the last 7 days
  /// - "Feb 10, 2026" for older dates
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      // Within last 7 days - show day name and date
      return DateFormat('EEEE, MMM d').format(date);
    } else {
      // Older dates - show full date with year
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  /// Builds the income/expense totals display.
  Widget _buildTotals() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Income total
        if (totalIncome != null && totalIncome! > 0) ...[
          Text(
            '+${_formatAmount(totalIncome!)}',
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        // Separator
        if (totalIncome != null &&
            totalIncome! > 0 &&
            totalExpense != null &&
            totalExpense! > 0)
          const SizedBox(width: SpendexTheme.spacingSm),

        // Expense total
        if (totalExpense != null && totalExpense! > 0) ...[
          Text(
            '-${_formatAmount(totalExpense!)}',
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.expense,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Formats the amount with rupee symbol and proper formatting.
  ///
  /// Examples:
  /// - 1234.56 -> "₹1,234"
  /// - 1000000 -> "₹10,00,000"
  String _formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}

/// A sliver version of [DateGroupHeader] for use with [CustomScrollView].
///
/// This widget wraps [DateGroupHeader] in a [SliverToBoxAdapter] and can be
/// used as a sticky header in sliver lists.
class SliverDateGroupHeader extends StatelessWidget {
  /// Creates a sliver date group header.
  const SliverDateGroupHeader({
    required this.date, super.key,
    this.totalIncome,
    this.totalExpense,
    this.showTotals = false,
  });

  /// The date to display in the header.
  final DateTime date;

  /// The total income for this date in rupees.
  final double? totalIncome;

  /// The total expense for this date in rupees.
  final double? totalExpense;

  /// Whether to show the income/expense totals.
  final bool showTotals;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _DateGroupHeaderDelegate(
        date: date,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        showTotals: showTotals,
      ),
    );
  }
}

/// A delegate for creating sticky date group headers.
class _DateGroupHeaderDelegate extends SliverPersistentHeaderDelegate {
  _DateGroupHeaderDelegate({
    required this.date,
    this.totalIncome,
    this.totalExpense,
    this.showTotals = false,
  });

  final DateTime date;
  final double? totalIncome;
  final double? totalExpense;
  final bool showTotals;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DateGroupHeader(
      date: date,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      showTotals: showTotals,
    );
  }

  @override
  double get maxExtent => 44;

  @override
  double get minExtent => 44;

  @override
  bool shouldRebuild(covariant _DateGroupHeaderDelegate oldDelegate) {
    return date != oldDelegate.date ||
        totalIncome != oldDelegate.totalIncome ||
        totalExpense != oldDelegate.totalExpense ||
        showTotals != oldDelegate.showTotals;
  }
}
