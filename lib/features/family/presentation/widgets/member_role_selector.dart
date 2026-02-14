import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import 'role_badge.dart';

/// Bottom sheet for selecting a member role with descriptions
class MemberRoleSelector extends StatelessWidget {
  const MemberRoleSelector({
    required this.currentRole,
    required this.onRoleSelected,
    super.key,
    this.excludeOwner = true,
  });

  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleSelected;
  final bool excludeOwner;

  /// Get role descriptions
  static String getRoleDescription(UserRole role) {
    return switch (role) {
      UserRole.owner => 'Full control over the family. Can delete the family and transfer ownership.',
      UserRole.admin => 'Can manage members, categories, and all financial data.',
      UserRole.member => 'Can add and edit transactions and view reports.',
      UserRole.viewer => 'Can only view data, cannot make changes.',
    };
  }

  /// Get role icon
  static IconData getRoleIcon(UserRole role) {
    return switch (role) {
      UserRole.owner => Icons.workspace_premium_rounded,
      UserRole.admin => Icons.shield_rounded,
      UserRole.member => Icons.person_rounded,
      UserRole.viewer => Icons.visibility_rounded,
    };
  }

  /// Get available roles
  List<UserRole> get _availableRoles {
    if (excludeOwner) {
      return UserRole.values.where((r) => r != UserRole.owner).toList();
    }
    return UserRole.values.toList();
  }

  /// Show the bottom sheet
  static Future<UserRole?> show({
    required BuildContext context,
    required UserRole currentRole,
    bool excludeOwner = true,
  }) {
    return showModalBottomSheet<UserRole>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MemberRoleSelector(
        currentRole: currentRole,
        excludeOwner: excludeOwner,
        onRoleSelected: (role) => Navigator.of(context).pop(role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: SpendexTheme.spacingSm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.user_edit,
                    size: 24,
                    color: SpendexColors.primary,
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  Text(
                    'Select Role',
                    style: SpendexTheme.headlineSmall.copyWith(
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingXs),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
              child: Text(
                'Choose the permissions level for this member',
                style: SpendexTheme.bodySmall.copyWith(
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            // Role options
            ..._availableRoles.map((role) => _RoleOption(
                  role: role,
                  isSelected: role == currentRole,
                  onTap: () => onRoleSelected(role),
                  isDark: isDark,
                )),
            const SizedBox(height: SpendexTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.role,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  Color get _roleColor => switch (role) {
        UserRole.owner => SpendexColors.primary,
        UserRole.admin => const Color(0xFF3B82F6),
        UserRole.member => SpendexColors.income,
        UserRole.viewer => const Color(0xFF6B7280),
      };

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final selectedBgColor = _roleColor.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingLg,
          vertical: SpendexTheme.spacingXs,
        ),
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? _roleColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
        child: Row(
          children: [
            // Role icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _roleColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Icon(
                MemberRoleSelector.getRoleIcon(role),
                size: 22,
                color: _roleColor,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            // Role info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        role.label,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _roleColor,
                            borderRadius:
                                BorderRadius.circular(SpendexTheme.radiusXs),
                          ),
                          child: Text(
                            'Current',
                            style: SpendexTheme.labelSmall.copyWith(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MemberRoleSelector.getRoleDescription(role),
                    style: SpendexTheme.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Selection indicator
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _roleColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
