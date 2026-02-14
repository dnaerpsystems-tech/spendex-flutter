import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/theme.dart';

/// A reusable error state widget with Material 3 theming.
///
/// Displays an error icon, message, and an optional retry button.
/// Use this widget to present error states consistently across the app.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryLabel,
    this.compact = false,
    this.semanticLabel,
  });

  /// The error message to display.
  final String message;

  /// An optional title displayed above the message.
  final String? title;

  /// The icon to display. Defaults to [Iconsax.warning_2].
  final IconData? icon;

  /// The color of the icon container. Defaults to [SpendexColors.expense].
  final Color? iconColor;

  /// Callback invoked when the retry button is pressed.
  /// If null, the retry button is hidden.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to 'Retry'.
  final String? retryLabel;

  /// Whether to use a compact layout without the icon container.
  final bool compact;

  /// Semantic label for screen readers. Defaults to error message.
  final String? semanticLabel;

  String _buildSemanticLabel() {
    final parts = <String>['Error'];
    if (title != null) {
      parts.add(title!);
    }
    parts.add(message);
    if (onRetry != null) {
      parts.add('Double tap to ${retryLabel ?? "retry"}');
    }
    return semanticLabel ?? parts.join('. ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? SpendexColors.expense;

    if (compact) {
      return _buildCompact(context, colorScheme, effectiveIconColor);
    }

    return Semantics(
      label: _buildSemanticLabel(),
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon ?? Iconsax.warning_2,
                    color: effectiveIconColor,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (title != null) ...[
                ExcludeSemantics(
                  child: Text(
                    title!,
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ExcludeSemantics(
                child: Text(
                  message,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                Semantics(
                  button: true,
                  label: retryLabel ?? 'Retry',
                  onTap: onRetry,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Iconsax.refresh),
                    label: Text(retryLabel ?? 'Retry'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(
    BuildContext context,
    ColorScheme colorScheme,
    Color effectiveIconColor,
  ) {
    return Semantics(
      label: _buildSemanticLabel(),
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                icon ?? Iconsax.warning_2,
                color: effectiveIconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ExcludeSemantics(
                child: Text(
                  message,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            if (onRetry != null)
              Semantics(
                button: true,
                label: retryLabel ?? 'Retry',
                onTap: onRetry,
                child: TextButton(
                  onPressed: onRetry,
                  child: Text(retryLabel ?? 'Retry'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A sliver-compatible variant of [ErrorStateWidget].
///
/// Use this inside [CustomScrollView] or other sliver-based layouts.
class SliverErrorStateWidget extends StatelessWidget {
  const SliverErrorStateWidget({
    required this.message,
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.onRetry,
    this.retryLabel,
    this.semanticLabel,
  });

  /// The error message to display.
  final String message;

  /// An optional title displayed above the message.
  final String? title;

  /// The icon to display.
  final IconData? icon;

  /// The color of the icon container.
  final Color? iconColor;

  /// Callback invoked when the retry button is pressed.
  final VoidCallback? onRetry;

  /// Label for the retry button.
  final String? retryLabel;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorStateWidget(
        message: message,
        title: title,
        icon: icon,
        iconColor: iconColor,
        onRetry: onRetry,
        retryLabel: retryLabel,
        semanticLabel: semanticLabel,
      ),
    );
  }
}
