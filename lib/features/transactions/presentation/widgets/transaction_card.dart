import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';

/// A reusable card widget for displaying transaction information.
///
/// This widget displays transaction details including:
/// - Category icon with color-coded background
/// - Description/title
/// - Category name and date
/// - Amount with color based on transaction type
class TransactionCard extends StatelessWidget {
  /// Creates a transaction card.
  ///
  /// The [transaction] parameter is required and specifies the transaction to display.
  /// The [onTap] callback is triggered when the card is tapped.
  const TransactionCard({
    required this.transaction,
    super.key,
    this.onTap,
    this.showDate = true,
    this.compact = false,
  });

  /// The transaction to display.
  final TransactionModel transaction;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show the date in the subtitle.
  final bool showDate;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 0,
    );

    // Determine transaction color based on type
    final Color typeColor;
    final String amountPrefix;
    switch (transaction.type) {
      case TransactionType.income:
        typeColor = SpendexColors.income;
        amountPrefix = '+';
        break;
      case TransactionType.expense:
        typeColor = SpendexColors.expense;
        amountPrefix = '-';
        break;
      case TransactionType.transfer:
        typeColor = SpendexColors.transfer;
        amountPrefix = '';
        break;
    }

    // Get icon based on category or transaction type
    final iconData = _getCategoryIcon(
      transaction.category?.icon,
      transaction.type,
    );

    // Format the date
    final dateString = _formatDate(transaction.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: compact ? 6 : 8),
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: compact ? 40 : 48,
              height: compact ? 40 : 48,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  iconData,
                  color: typeColor,
                  size: compact ? 20 : 24,
                ),
              ),
            ),
            SizedBox(width: compact ? 12 : 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.description ?? transaction.category?.name ?? transaction.type.label,
                    style: SpendexTheme.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: compact ? 13 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  Row(
                    children: [
                      // Category name
                      if (transaction.category != null) ...[
                        Flexible(
                          child: Text(
                            transaction.category!.name,
                            style: SpendexTheme.labelMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: compact ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (transaction.type == TransactionType.transfer) ...[
                        Flexible(
                          child: Text(
                            'Transfer',
                            style: SpendexTheme.labelMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: compact ? 11 : 12,
                            ),
                          ),
                        ),
                      ],
                      // Dot separator
                      if (showDate &&
                          (transaction.category != null ||
                              transaction.type == TransactionType.transfer)) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: SpendexColors.lightTextTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                      // Date
                      if (showDate)
                        Text(
                          dateString,
                          style: SpendexTheme.labelMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: compact ? 11 : 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Text(
              '$amountPrefix${currencyFormat.format(transaction.amountInRupees)}',
              style: SpendexTheme.titleMedium.copyWith(
                color: typeColor,
                fontSize: compact ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the icon based on category icon string or transaction type.
  IconData _getCategoryIcon(String? categoryIcon, TransactionType type) {
    // If we have a category icon string, try to map it
    if (categoryIcon != null) {
      return _iconFromString(categoryIcon);
    }

    // Default icons based on transaction type
    switch (type) {
      case TransactionType.income:
        return Iconsax.wallet_add;
      case TransactionType.expense:
        return Iconsax.shopping_cart;
      case TransactionType.transfer:
        return Iconsax.arrow_swap_horizontal;
    }
  }

  /// Maps icon string to IconData.
  IconData _iconFromString(String iconName) {
    // Common category icons mapping
    final iconMap = <String, IconData>{
      'shopping_cart': Iconsax.shopping_cart,
      'shopping': Iconsax.shopping_bag,
      'food': Iconsax.coffee,
      'restaurant': Iconsax.reserve,
      'transport': Iconsax.car,
      'travel': Iconsax.airplane,
      'entertainment': Iconsax.game,
      'health': Iconsax.health,
      'medical': Iconsax.hospital,
      'education': Iconsax.book,
      'bills': Iconsax.receipt_2,
      'utilities': Iconsax.flash,
      'rent': Iconsax.home,
      'home': Iconsax.home_2,
      'clothing': Iconsax.shopping_cart,
      'personal': Iconsax.user,
      'gifts': Iconsax.gift,
      'investment': Iconsax.chart,
      'savings': Iconsax.wallet_money,
      'salary': Iconsax.wallet_add,
      'income': Iconsax.wallet_add_1,
      'business': Iconsax.briefcase,
      'freelance': Iconsax.monitor,
      'other': Iconsax.more,
      'transfer': Iconsax.arrow_swap_horizontal,
    };

    return iconMap[iconName.toLowerCase()] ?? Iconsax.category;
  }

  /// Formats the date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
