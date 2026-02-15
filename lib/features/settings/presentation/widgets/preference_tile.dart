import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A preference/settings tile widget for displaying configurable options.
///
/// Features:
/// - Leading icon with optional colored background
/// - Title text in bold
/// - Optional subtitle/description text
/// - Trailing widget: Switch, dropdown arrow, or custom widget
/// - Support for tap and switch change callbacks
/// - Material 3 styling with proper spacing
/// - Dark mode support with theme-aware colors
///
/// Example:
/// ```dart
/// PreferenceTile(
///   icon: Iconsax.notification,
///   title: 'Push Notifications',
///   subtitle: 'Receive alerts for transactions',
///   trailing: Switch(value: true, onChanged: (val) {}),
///   onTap: () {
///     // Handle tap
///   },
/// )
/// ```
class PreferenceTile extends StatelessWidget {
  /// Creates a preference tile.
  ///
  /// [icon] is the leading icon.
  /// [title] is the main title text.
  /// [subtitle] is optional description text.
  /// [trailing] is an optional custom trailing widget.
  /// [onTap] callback triggered when tile is tapped.
  /// [onChanged] callback for switch value changes (only used with [showSwitch]).
  /// [showSwitch] displays a switch widget as trailing (defaults to false).
  /// [switchValue] is the current value of the switch (required if [showSwitch] is true).
  /// [showArrow] displays a chevron arrow as trailing (defaults to false).
  /// [iconColor] sets the icon color.
  /// [iconBackgroundColor] sets the icon background color.
  /// [showIconBackground] controls icon background visibility.
  const PreferenceTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onChanged,
    this.showSwitch = false,
    this.switchValue = false,
    this.showArrow = false,
    this.iconColor,
    this.iconBackgroundColor,
    this.showIconBackground = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged;
  final bool showSwitch;
  final bool switchValue;
  final bool showArrow;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final bool showIconBackground;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final hoverColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    final effectiveIconColor = iconColor ?? SpendexColors.primary;
    final effectiveIconBackground =
        iconBackgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showSwitch && onChanged != null ? () => onChanged!(!switchValue) : onTap,
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
                      title,
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: SpendexTheme.labelMedium.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingSm),
              _buildTrailing(isDark, secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(Color color, Color backgroundColor) {
    final iconWidget = Icon(
      icon,
      color: color,
      size: 22,
    );

    if (!showIconBackground) {
      return iconWidget;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Center(child: iconWidget),
    );
  }

  Widget _buildTrailing(bool isDark, Color secondaryTextColor) {
    if (trailing != null) {
      return trailing!;
    }

    if (showSwitch) {
      return Switch(
        value: switchValue,
        onChanged: onChanged,
        activeTrackColor: SpendexColors.primary,
      );
    }

    if (showArrow) {
      return Icon(
        Icons.chevron_right,
        color: secondaryTextColor,
        size: 20,
      );
    }

    return const SizedBox.shrink();
  }
}
