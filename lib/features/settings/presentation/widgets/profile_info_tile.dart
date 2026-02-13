import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A generic information display tile for profile and settings screens.
///
/// Similar to [ListTile] but with customized styling for profile information display.
/// Features:
/// - Leading icon with optional colored circle background
/// - Label text as title
/// - Value text as subtitle in gray color
/// - Trailing widget (arrow, icon, or custom widget)
/// - Optional divider at the bottom
/// - Material 3 card/list styling with hover effects
/// - Dark mode support
///
/// Example:
/// ```dart
/// ProfileInfoTile(
///   icon: Iconsax.user,
///   label: 'Full Name',
///   value: 'John Doe',
///   onTap: () {
///     // Navigate to edit screen
///   },
/// )
/// ```
class ProfileInfoTile extends StatelessWidget {
  /// Creates a profile information tile.
  ///
  /// [icon] is the leading icon displayed on the left.
  /// [label] is the title/label text.
  /// [value] is the subtitle/value text shown below the label.
  /// [trailing] is an optional custom widget displayed on the right.
  /// [onTap] callback triggered when the tile is tapped.
  /// [showDivider] controls whether to show a bottom divider (defaults to true).
  /// [iconColor] sets the color of the leading icon.
  /// [iconBackgroundColor] sets the background color of the icon circle.
  /// [showIconBackground] controls whether to show background circle for icon.
  const ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.iconColor,
    this.iconBackgroundColor,
    this.showIconBackground = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool showIconBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final dividerColor =
        isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider;
    final hoverColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    final effectiveIconColor = iconColor ?? SpendexColors.primary;
    final effectiveIconBackground =
        iconBackgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            hoverColor: hoverColor,
            splashColor: SpendexColors.primary.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
                vertical: SpendexTheme.spacingMd,
              ),
              child: Row(
                children: [
                  _buildLeadingIcon(effectiveIconColor, effectiveIconBackground),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: SpendexTheme.labelMedium.copyWith(
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                  if (trailing == null && onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: secondaryTextColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(
              left: SpendexTheme.spacingLg + 40 + SpendexTheme.spacingMd,
            ),
            child: Divider(
              height: 1,
              thickness: 1,
              color: dividerColor,
            ),
          ),
      ],
    );
  }

  Widget _buildLeadingIcon(Color color, Color backgroundColor) {
    final iconWidget = Icon(
      icon,
      color: color,
      size: 20,
    );

    if (!showIconBackground) {
      return iconWidget;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Center(child: iconWidget),
    );
  }
}
