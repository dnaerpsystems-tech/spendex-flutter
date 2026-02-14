import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/family_member_model.dart';
import 'role_badge.dart';

/// Card widget displaying a family member with their info and actions
class FamilyMemberCard extends StatelessWidget {
  const FamilyMemberCard({
    required this.member,
    super.key,
    this.isCurrentUser = false,
    this.showActions = true,
    this.canManage = false,
    this.onTap,
    this.onEditRole,
    this.onRemove,
  });

  final FamilyMemberModel member;
  final bool isCurrentUser;
  final bool showActions;
  final bool canManage;
  final VoidCallback? onTap;
  final VoidCallback? onEditRole;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isCurrentUser
              ? SpendexColors.primary.withValues(alpha: 0.3)
              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(isDark),
                const SizedBox(width: 12),
                Expanded(child: _buildMemberInfo(isDark)),
                if (showActions && canManage && member.isOwner == false)
                  _buildActions(context, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: member.isOwner
                ? SpendexColors.primaryGradient
                : LinearGradient(
                    colors: [
                      SpendexColors.primary.withValues(alpha: 0.8),
                      SpendexColors.primary,
                    ],
                  ),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
          child: member.avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  child: Image.network(
                    member.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildInitials(),
                  ),
                )
              : _buildInitials(),
        ),
        if (member.isOwner)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: SpendexColors.warning,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                border: Border.all(
                  color: isDark ? SpendexColors.darkCard : Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(member.name);
    return Center(
      child: Text(
        initials,
        style: SpendexTheme.headlineMedium.copyWith(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _buildMemberInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                member.name,
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                ),
                child: Text(
                  'You',
                  style: SpendexTheme.labelSmall.copyWith(
                    color: SpendexColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          member.email,
          style: SpendexTheme.bodySmall.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RoleBadge(role: member.role, size: RoleBadgeSize.small),
            const SizedBox(width: 8),
            Icon(
              Iconsax.calendar,
              size: 12,
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              _formatJoinedDate(member.joinedAt),
              style: SpendexTheme.labelSmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatJoinedDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Joined today';
    } else if (diff.inDays == 1) {
      return 'Joined yesterday';
    } else if (diff.inDays < 30) {
      return 'Joined ${diff.inDays} days ago';
    } else if (diff.inDays < 365) {
      final months = (diff.inDays / 30).floor();
      return 'Joined $months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (diff.inDays / 365).floor();
      return 'Joined $years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return PopupMenuButton<String>(
      icon: Icon(
        Iconsax.more,
        color: isDark
            ? SpendexColors.darkTextSecondary
            : SpendexColors.lightTextSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      color: isDark ? SpendexColors.darkCard : Colors.white,
      onSelected: (value) {
        if (value == 'edit_role' && onEditRole != null) {
          onEditRole!();
        } else if (value == 'remove' && onRemove != null) {
          onRemove!();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit_role',
          child: Row(
            children: [
              Icon(
                Iconsax.user_edit,
                size: 18,
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                'Change Role',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              const Icon(
                Iconsax.user_remove,
                size: 18,
                color: SpendexColors.expense,
              ),
              const SizedBox(width: 12),
              Text(
                'Remove',
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
}

/// Loading skeleton for family member card
class FamilyMemberCardSkeleton extends StatelessWidget {
  const FamilyMemberCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final shimmerHighlight = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.08);

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
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
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
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 160,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmerHighlight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
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
    );
  }
}
