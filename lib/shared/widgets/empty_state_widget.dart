import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A reusable empty state widget with Material 3 theming.
///
/// Displays an icon, title, subtitle, and an optional action button.
/// Use this widget to present empty states consistently across the app.
class EmptyStateWidget extends StatelessWidget {

  const EmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.iconColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.compact = false,
  });

  /// The icon displayed in the circular container.
  final IconData icon;

  /// The primary title text.
  final String title;

  /// An optional subtitle displayed below the title.
  final String? subtitle;

  /// The color used for the icon and its background.
  /// Defaults to [SpendexColors.primary].
  final Color? iconColor;

  /// Label for the optional action button.
  final String? actionLabel;

  /// Icon for the optional action button.
  final IconData? actionIcon;

  /// Callback invoked when the action button is pressed.
  /// If null, the action button is hidden.
  final VoidCallback? onAction;

  /// Whether to use a compact layout with smaller spacing.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? SpendexColors.primary;
    final iconSize = compact ? 60.0 : 80.0;
    final innerIconSize = compact ? 30.0 : 40.0;
    final borderRadius = compact ? 16.0 : 20.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 24 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: innerIconSize,
              ),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title,
              style: SpendexTheme.headlineMedium.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: compact ? 16 : 24),
              if (actionIcon != null)
                ElevatedButton.icon(
                  onPressed: onAction,
                  icon: Icon(actionIcon),
                  label: Text(actionLabel!),
                )
              else
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A sliver-compatible variant of [EmptyStateWidget].
///
/// Use this inside [CustomScrollView] or other sliver-based layouts.
class SliverEmptyStateWidget extends StatelessWidget {

  const SliverEmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.iconColor,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  /// The icon displayed in the circular container.
  final IconData icon;

  /// The primary title text.
  final String title;

  /// An optional subtitle displayed below the title.
  final String? subtitle;

  /// The color used for the icon and its background.
  final Color? iconColor;

  /// Label for the optional action button.
  final String? actionLabel;

  /// Icon for the optional action button.
  final IconData? actionIcon;

  /// Callback invoked when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(
        icon: icon,
        title: title,
        subtitle: subtitle,
        iconColor: iconColor,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        onAction: onAction,
      ),
    );
  }
}
