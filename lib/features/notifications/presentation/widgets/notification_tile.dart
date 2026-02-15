import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../../data/models/notification_model.dart';

/// Notification tile widget
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    super.key,
    this.onTap,
    this.onDismissed,
    this.onMarkAsRead,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismissed;
  final VoidCallback? onMarkAsRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpendexTheme.spacingLg),
        color: SpendexColors.expense,
        child: const Icon(
          Iconsax.trash,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) => onDismissed?.call(),
      child: InkWell(
        onTap: () {
          if (notification.isRead == false) {
            onMarkAsRead?.call();
          }
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.transparent
                : (isDark
                    ? SpendexColors.primary.withValues(alpha: 0.08)
                    : SpendexColors.primary.withValues(alpha: 0.04)),
            border: Border(
              bottom: BorderSide(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              _buildIcon(isDark),
              const SizedBox(width: SpendexTheme.spacingMd),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: SpendexTheme.titleMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextPrimary
                                  : SpendexColors.lightTextPrimary,
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Text(
                          notification.timeAgo,
                          style: SpendexTheme.labelSmall.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpendexTheme.spacingXs),

                    // Body
                    Text(
                      notification.body,
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpendexTheme.spacingSm),

                    // Type badge and priority indicator
                    Row(
                      children: [
                        _buildTypeBadge(isDark),
                        if (notification.isHighPriority) ...[
                          const SizedBox(width: SpendexTheme.spacingSm),
                          _buildPriorityIndicator(isDark),
                        ],
                        const Spacer(),
                        if (notification.isRead == false)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: SpendexColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    final iconData = _getIconForType(notification.type);
    final iconColor = _getColorForType(notification.type);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildTypeBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _getColorForType(notification.type).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      ),
      child: Text(
        notification.type.label,
        style: SpendexTheme.labelSmall.copyWith(
          color: _getColorForType(notification.type),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(bool isDark) {
    final color = notification.priority == NotificationPriority.urgent
        ? SpendexColors.expense
        : SpendexColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            notification.priority == NotificationPriority.urgent
                ? Iconsax.danger5
                : Iconsax.warning_2,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            notification.priority == NotificationPriority.urgent ? 'Urgent' : 'High',
            style: SpendexTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Iconsax.receipt_2;
      case NotificationType.budget:
        return Iconsax.chart;
      case NotificationType.goal:
        return Iconsax.flag;
      case NotificationType.family:
        return Iconsax.people;
      case NotificationType.loan:
        return Iconsax.bank;
      case NotificationType.investment:
        return Iconsax.trend_up;
      case NotificationType.system:
        return Iconsax.setting_2;
      case NotificationType.reminder:
        return Iconsax.clock;
      case NotificationType.alert:
        return Iconsax.notification;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return SpendexColors.primary;
      case NotificationType.budget:
        return SpendexColors.warning;
      case NotificationType.goal:
        return SpendexColors.income;
      case NotificationType.family:
        return SpendexColors.transfer;
      case NotificationType.loan:
        return const Color(0xFF8B5CF6);
      case NotificationType.investment:
        return const Color(0xFF06B6D4);
      case NotificationType.system:
        return const Color(0xFF64748B);
      case NotificationType.reminder:
        return const Color(0xFFF97316);
      case NotificationType.alert:
        return SpendexColors.expense;
    }
  }
}

/// Skeleton loader for notification tile
class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon skeleton
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: shimmerColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingMd),

          // Content skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                        ),
                      ),
                    ),
                    const SizedBox(width: SpendexTheme.spacingMd),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpendexTheme.spacingSm),
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingXs),
                Container(
                  height: 14,
                  width: 200,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingSm),
                Container(
                  height: 20,
                  width: 80,
                  decoration: BoxDecoration(
                    color: shimmerColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
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
