import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../app/theme.dart';
import '../../data/models/insight_model.dart';
import 'insight_type_icon.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    required this.insight,
    super.key,
    this.onTap,
    this.onDismiss,
    this.onActionTap,
    this.isCompact = false,
  });
  final InsightModel insight;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final VoidCallback? onActionTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(insight.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            onDismiss?.call();
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) {
              onDismiss?.call();
            },
            backgroundColor: SpendexColors.expense,
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
            label: 'Dismiss',
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final backgroundColor = _getBackgroundColor(context);
    final borderColor = _getBorderColor(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: insight.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMainContent(context),
              if (!isCompact && insight.actionType != InsightActionType.none) ...[
                const SizedBox(height: 12),
                _buildActionButton(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: Icon
        InsightTypeIcon(
          type: insight.type,
          size: isCompact ? 36 : 44,
        ),
        SizedBox(width: isCompact ? 10 : 12),

        // Middle: Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                insight.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: insight.isRead ? FontWeight.w600 : FontWeight.bold,
                  fontSize: isCompact ? 14 : 16,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Description
              Text(
                insight.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: isCompact ? 12 : 14,
                ),
                maxLines: isCompact ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Priority badge and timestamp
              Row(
                children: [
                  _buildPriorityBadge(context),
                  const Spacer(),
                  _buildTimestamp(context),
                ],
              ),
            ],
          ),
        ),

        // Right: Dismiss button
        if (!isCompact)
          IconButton(
            icon: const Icon(Iconsax.close_circle),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onDismiss,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
          ),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    final theme = Theme.of(context);
    final (color, label) = _getPriorityInfo();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6 : 8,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: isCompact ? 10 : 11,
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = Jiffy.parseFromDateTime(insight.createdAt).fromNow();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Iconsax.clock,
          size: isCompact ? 12 : 14,
          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 4),
        Text(
          timeAgo,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            fontSize: isCompact ? 10 : 11,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);
    final actionLabel = _getActionLabel();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onActionTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: SpendexColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          actionLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    if (insight.isRead) {
      return baseColor.withValues(alpha: 0.7);
    }

    switch (insight.priority) {
      case InsightPriority.high:
        return isDark
            ? SpendexColors.expense.withValues(alpha: 0.1)
            : SpendexColors.expense.withValues(alpha: 0.05);
      case InsightPriority.medium:
        return isDark
            ? SpendexColors.primary.withValues(alpha: 0.1)
            : SpendexColors.primary.withValues(alpha: 0.05);
      case InsightPriority.low:
        return isDark ? Colors.grey.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.05);
    }
  }

  Color _getBorderColor(BuildContext context) {
    final theme = Theme.of(context);

    if (insight.isRead) {
      return theme.dividerColor.withValues(alpha: 0.3);
    }

    switch (insight.priority) {
      case InsightPriority.high:
        return SpendexColors.expense.withValues(alpha: 0.4);
      case InsightPriority.medium:
        return SpendexColors.primary.withValues(alpha: 0.4);
      case InsightPriority.low:
        return theme.dividerColor.withValues(alpha: 0.5);
    }
  }

  (Color, String) _getPriorityInfo() {
    switch (insight.priority) {
      case InsightPriority.high:
        return (SpendexColors.expense, 'HIGH');
      case InsightPriority.medium:
        return (SpendexColors.primary, 'MEDIUM');
      case InsightPriority.low:
        return (Colors.grey, 'LOW');
    }
  }

  String _getActionLabel() {
    switch (insight.actionType) {
      case InsightActionType.viewTransactions:
        return 'View Transactions';
      case InsightActionType.setGoal:
        return 'Set Goal';
      case InsightActionType.setBudget:
        return 'Create Budget';
      case InsightActionType.viewCategory:
        return 'View Category';
      case InsightActionType.viewMerchant:
        return 'View Merchant';
      case InsightActionType.viewAccount:
        return 'View Account';
      case InsightActionType.viewLoan:
        return 'View Loan';
      case InsightActionType.none:
        return '';
    }
  }
}
