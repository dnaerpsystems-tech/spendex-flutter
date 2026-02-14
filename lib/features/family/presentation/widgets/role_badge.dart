import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Size variants for the role badge
enum RoleBadgeSize { small, medium, large }

/// Badge widget displaying user role with appropriate color styling
class RoleBadge extends StatelessWidget {
  const RoleBadge({
    required this.role,
    super.key,
    this.size = RoleBadgeSize.medium,
  });

  final UserRole role;
  final RoleBadgeSize size;

  /// Get background color based on role
  Color get _backgroundColor => switch (role) {
        UserRole.owner => SpendexColors.primary,
        UserRole.admin => const Color(0xFF3B82F6),
        UserRole.member => SpendexColors.income,
        UserRole.viewer => const Color(0xFF6B7280),
      };

  /// Get text color - white for all roles for good contrast
  Color get _textColor => Colors.white;

  /// Get icon for each role
  IconData get _roleIcon => switch (role) {
        UserRole.owner => Icons.workspace_premium_rounded,
        UserRole.admin => Icons.shield_rounded,
        UserRole.member => Icons.person_rounded,
        UserRole.viewer => Icons.visibility_rounded,
      };

  /// Get dimensions based on size
  double get _fontSize => switch (size) {
        RoleBadgeSize.small => 10,
        RoleBadgeSize.medium => 11,
        RoleBadgeSize.large => 12,
      };

  double get _iconSize => switch (size) {
        RoleBadgeSize.small => 10,
        RoleBadgeSize.medium => 12,
        RoleBadgeSize.large => 14,
      };

  EdgeInsets get _padding => switch (size) {
        RoleBadgeSize.small => const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
        RoleBadgeSize.medium => const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
        RoleBadgeSize.large => const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
      };

  double get _borderRadius => switch (size) {
        RoleBadgeSize.small => SpendexTheme.radiusXs,
        RoleBadgeSize.medium => SpendexTheme.radiusSm,
        RoleBadgeSize.large => SpendexTheme.radiusMd,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: _backgroundColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _roleIcon,
            size: _iconSize,
            color: _textColor,
          ),
          SizedBox(width: size == RoleBadgeSize.small ? 3 : 4),
          Text(
            role.label,
            style: SpendexTheme.labelSmall.copyWith(
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              color: _textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple text-only role badge without icon
class RoleBadgeCompact extends StatelessWidget {
  const RoleBadgeCompact({
    required this.role,
    super.key,
  });

  final UserRole role;

  Color get _backgroundColor => switch (role) {
        UserRole.owner => SpendexColors.primary,
        UserRole.admin => const Color(0xFF3B82F6),
        UserRole.member => SpendexColors.income,
        UserRole.viewer => const Color(0xFF6B7280),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _backgroundColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
        border: Border.all(
          color: _backgroundColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        role.label,
        style: SpendexTheme.labelSmall.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _backgroundColor,
        ),
      ),
    );
  }
}
