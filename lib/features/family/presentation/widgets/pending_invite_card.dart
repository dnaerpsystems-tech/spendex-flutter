import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/family_invite_model.dart';
import 'role_badge.dart';

/// Card widget displaying a pending family invite
class PendingInviteCard extends StatelessWidget {
  const PendingInviteCard({
    required this.invite,
    super.key,
    this.onCancel,
    this.onResend,
    this.canManage = false,
  });

  final FamilyInviteModel invite;
  final VoidCallback? onCancel;
  final VoidCallback? onResend;
  final bool canManage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = invite.isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isExpired
              ? SpendexColors.expense.withValues(alpha: 0.3)
              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildInviteIcon(isDark, isExpired),
                const SizedBox(width: 12),
                Expanded(child: _buildInviteInfo(isDark, isExpired)),
                if (canManage) _buildActions(context, isDark, isExpired),
              ],
            ),
            const SizedBox(height: 12),
            _buildFooter(isDark, isExpired),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteIcon(bool isDark, bool isExpired) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isExpired
            ? SpendexColors.expense.withValues(alpha: 0.1)
            : SpendexColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Icon(
        isExpired ? Iconsax.timer_pause : Iconsax.send_2,
        size: 22,
        color: isExpired ? SpendexColors.expense : SpendexColors.warning,
      ),
    );
  }

  Widget _buildInviteInfo(bool isDark, bool isExpired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          invite.email,
          style: SpendexTheme.titleMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
            decoration: isExpired ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            RoleBadge(role: invite.role, size: RoleBadgeSize.small),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isExpired
                    ? SpendexColors.expense.withValues(alpha: 0.1)
                    : SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
              ),
              child: Text(
                isExpired ? 'Expired' : 'Pending',
                style: SpendexTheme.labelSmall.copyWith(
                  color: isExpired ? SpendexColors.expense : SpendexColors.warning,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark, bool isExpired) {
    return PopupMenuButton<String>(
      icon: Icon(
        Iconsax.more,
        color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      color: isDark ? SpendexColors.darkCard : Colors.white,
      onSelected: (value) {
        if (value == 'cancel' && onCancel != null) {
          onCancel!();
        } else if (value == 'resend' && onResend != null) {
          onResend!();
        }
      },
      itemBuilder: (context) => [
        if (isExpired && onResend != null)
          PopupMenuItem(
            value: 'resend',
            child: Row(
              children: [
                Icon(
                  Iconsax.refresh,
                  size: 18,
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Resend Invite',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'cancel',
          child: Row(
            children: [
              const Icon(
                Iconsax.close_circle,
                size: 18,
                color: SpendexColors.expense,
              ),
              const SizedBox(width: 12),
              Text(
                'Cancel Invite',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.expense,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDark, bool isExpired) {
    return Row(
      children: [
        Icon(
          Iconsax.user,
          size: 14,
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          'Invited by ${invite.invitedByName}',
          style: SpendexTheme.labelSmall.copyWith(
            color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            fontSize: 11,
          ),
        ),
        const Spacer(),
        Icon(
          Iconsax.timer_1,
          size: 14,
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          isExpired ? 'Expired' : _formatTimeRemaining(invite.remainingTime),
          style: SpendexTheme.labelSmall.copyWith(
            color: isExpired
                ? SpendexColors.expense
                : (isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.isNegative) {
      return 'Expired';
    }

    if (duration.inDays > 0) {
      return '${duration.inDays}d left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h left';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m left';
    } else {
      return 'Expiring soon';
    }
  }
}

/// Loading skeleton for pending invite card
class PendingInviteCardSkeleton extends StatelessWidget {
  const PendingInviteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final shimmerHighlight =
        isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shimmerBase, shimmerHighlight],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: shimmerHighlight,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 16,
                      decoration: BoxDecoration(
                        color: shimmerHighlight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 20,
                      decoration: BoxDecoration(
                        color: shimmerHighlight,
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: shimmerHighlight,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}
