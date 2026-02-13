import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A card widget for displaying security settings and options.
///
/// Features:
/// - Large leading icon in colored circle background
/// - Title in headline style with bold weight
/// - Description text in smaller gray font
/// - Trailing widget: Switch or arrow
/// - Enabled/disabled state with visual feedback
/// - Tap and toggle callbacks
/// - Card with elevation and border
/// - Material 3 design with proper spacing
/// - Dark mode support
///
/// Example:
/// ```dart
/// SecurityOptionCard(
///   icon: Iconsax.finger_scan,
///   title: 'Biometric Authentication',
///   description: 'Use fingerprint or face ID to unlock',
///   isEnabled: true,
///   showSwitch: true,
///   onToggle: (value) {
///     // Handle toggle
///   },
/// )
/// ```
class SecurityOptionCard extends StatelessWidget {
  /// Creates a security option card.
  ///
  /// [icon] is the leading icon displayed in a colored circle.
  /// [title] is the main title text.
  /// [description] is the descriptive text below the title.
  /// [isEnabled] controls the enabled/disabled visual state.
  /// [showSwitch] displays a switch as trailing widget (defaults to true).
  /// [showArrow] displays a chevron arrow as trailing widget (defaults to false).
  /// [onTap] callback triggered when card is tapped.
  /// [onToggle] callback for switch value changes.
  /// [iconColor] sets the icon and circle background color.
  /// [trailing] is an optional custom trailing widget.
  const SecurityOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
    this.isEnabled = true,
    this.showSwitch = true,
    this.showArrow = false,
    this.onTap,
    this.onToggle,
    this.iconColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isEnabled;
  final bool showSwitch;
  final bool showArrow;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    final effectiveIconColor = iconColor ?? SpendexColors.primary;
    final opacity = isEnabled ? 1.0 : 0.5;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        side: BorderSide(color: borderColor),
      ),
      color: cardColor,
      child: InkWell(
        onTap: isEnabled
            ? (showSwitch && onToggle != null
                ? () => onToggle!(!isEnabled)
                : onTap)
            : null,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Row(
            children: [
              Opacity(
                opacity: opacity,
                child: _buildIcon(effectiveIconColor),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Opacity(
                  opacity: opacity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: SpendexTheme.labelMedium.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              _buildTrailing(isDark, secondaryTextColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }

  Widget _buildTrailing(bool isDark, Color secondaryTextColor) {
    if (trailing != null) {
      return trailing!;
    }

    if (showSwitch) {
      return Switch(
        value: isEnabled,
        onChanged: onToggle,
        activeTrackColor: SpendexColors.primary,
      );
    }

    if (showArrow) {
      return Icon(
        Icons.chevron_right,
        color: secondaryTextColor,
        size: 24,
      );
    }

    return const SizedBox.shrink();
  }
}
