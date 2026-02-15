import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A badge widget that displays the subscription status with appropriate colors.
///
/// The badge uses semantic colors to indicate the subscription state:
/// - Active: Green - subscription is active and in good standing
/// - Trialing: Blue - user is in a trial period
/// - Past Due: Orange - payment is overdue
/// - Cancelled/Expired: Red - subscription has ended
/// - Paused: Gray - subscription is temporarily paused
///
/// Example usage:
/// ```dart
/// SubscriptionStatusBadge(
///   status: SubscriptionStatus.active,
///   showIcon: true,
/// )
/// ```
class SubscriptionStatusBadge extends StatelessWidget {
  /// Creates a subscription status badge.
  const SubscriptionStatusBadge({
    required this.status,
    super.key,
    this.showIcon = true,
    this.size = SubscriptionBadgeSize.medium,
  });

  /// The current subscription status to display.
  final SubscriptionStatus status;

  /// Whether to show an icon alongside the status text.
  final bool showIcon;

  /// The size variant of the badge.
  final SubscriptionBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getStatusConfig(isDark);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == SubscriptionBadgeSize.small ? 8 : 12,
        vertical: size == SubscriptionBadgeSize.small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: size == SubscriptionBadgeSize.small ? 12 : 14,
              color: config.textColor,
            ),
            SizedBox(width: size == SubscriptionBadgeSize.small ? 4 : 6),
          ],
          Text(
            config.label,
            style: (size == SubscriptionBadgeSize.small
                    ? SpendexTheme.labelSmall
                    : SpendexTheme.labelMedium)
                .copyWith(
              color: config.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getStatusConfig(bool isDark) {
    switch (status) {
      case SubscriptionStatus.active:
        return _StatusConfig(
          label: 'Active',
          icon: Icons.check_circle_outline,
          textColor: SpendexColors.income,
          backgroundColor: SpendexColors.income.withValues(alpha: 0.1),
          borderColor: SpendexColors.income.withValues(alpha: 0.3),
        );
      case SubscriptionStatus.trialing:
        return _StatusConfig(
          label: 'Trial',
          icon: Icons.access_time,
          textColor: SpendexColors.transfer,
          backgroundColor: SpendexColors.transfer.withValues(alpha: 0.1),
          borderColor: SpendexColors.transfer.withValues(alpha: 0.3),
        );
      case SubscriptionStatus.pastDue:
        return _StatusConfig(
          label: 'Past Due',
          icon: Icons.warning_amber_outlined,
          textColor: SpendexColors.warning,
          backgroundColor: SpendexColors.warning.withValues(alpha: 0.1),
          borderColor: SpendexColors.warning.withValues(alpha: 0.3),
        );
      case SubscriptionStatus.cancelled:
        return _StatusConfig(
          label: 'Cancelled',
          icon: Icons.cancel_outlined,
          textColor: SpendexColors.expense,
          backgroundColor: SpendexColors.expense.withValues(alpha: 0.1),
          borderColor: SpendexColors.expense.withValues(alpha: 0.3),
        );
      case SubscriptionStatus.expired:
        return _StatusConfig(
          label: 'Expired',
          icon: Icons.event_busy_outlined,
          textColor: SpendexColors.expense,
          backgroundColor: SpendexColors.expense.withValues(alpha: 0.1),
          borderColor: SpendexColors.expense.withValues(alpha: 0.3),
        );
      case SubscriptionStatus.paused:
        return _StatusConfig(
          label: 'Paused',
          icon: Icons.pause_circle_outline,
          textColor: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          backgroundColor: isDark
              ? SpendexColors.darkBorder.withValues(alpha: 0.5)
              : SpendexColors.lightBorder.withValues(alpha: 0.5),
          borderColor: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        );
    }
  }
}

/// Size variants for the subscription status badge.
enum SubscriptionBadgeSize {
  /// Small badge with compact padding and smaller text.
  small,

  /// Medium badge with standard padding and text size.
  medium,
}

/// Internal configuration class for status badge styling.
class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
}

/// Skeleton loading widget for the subscription status badge.
class SubscriptionStatusBadgeSkeleton extends StatelessWidget {
  /// Creates a skeleton loading state for the status badge.
  const SubscriptionStatusBadgeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 80,
      height: 28,
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkBorder.withValues(alpha: 0.5)
            : SpendexColors.lightBorder.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
      ),
    );
  }
}
