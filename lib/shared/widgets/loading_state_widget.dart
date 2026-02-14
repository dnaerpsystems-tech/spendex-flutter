import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/theme.dart';

/// A reusable loading state widget with Material 3 theming.
///
/// Displays a centered circular progress indicator with an optional message.
class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({
    super.key,
    this.message,
    this.color,
    this.size = 40,
    this.semanticLabel,
  });

  /// An optional message displayed below the indicator.
  final String? message;

  /// The color of the progress indicator. Defaults to [SpendexColors.primary].
  final Color? color;

  /// The size of the progress indicator.
  final double size;

  /// Semantic label for screen readers. Defaults to message or 'Loading'.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveLabel = semanticLabel ?? message ?? 'Loading';

    return Semantics(
      label: effectiveLabel,
      liveRegion: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                excludeSemantics: true,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    color: color ?? SpendexColors.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                ExcludeSemantics(
                  child: Text(
                    message!,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A sliver-compatible variant of [LoadingStateWidget].
///
/// Use this inside [CustomScrollView] or other sliver-based layouts.
class SliverLoadingStateWidget extends StatelessWidget {
  const SliverLoadingStateWidget({
    super.key,
    this.message,
    this.color,
    this.semanticLabel,
  });

  /// An optional message displayed below the indicator.
  final String? message;

  /// The color of the progress indicator.
  final Color? color;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: LoadingStateWidget(
        message: message,
        color: color,
        semanticLabel: semanticLabel,
      ),
    );
  }
}

/// A shimmer/skeleton loading widget for list items.
///
/// Renders a configurable number of skeleton placeholders with a shimmer
/// animation, suitable for use while list data is loading.
class ShimmerLoadingList extends StatelessWidget {
  const ShimmerLoadingList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 80,
    this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.spacing = 12,
    this.semanticLabel,
  });

  /// The number of skeleton items to display.
  final int itemCount;

  /// The height of each skeleton item.
  final double itemHeight;

  /// An optional custom builder for each skeleton item.
  /// If null, a default rounded rectangle skeleton is used.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Padding around the list of skeleton items.
  final EdgeInsets padding;

  /// Spacing between skeleton items.
  final double spacing;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? SpendexColors.darkBorder
        : SpendexColors.lightBorder;
    final highlightColor = isDark
        ? SpendexColors.darkSurface
        : SpendexColors.lightBackground;

    return Semantics(
      label: semanticLabel ?? 'Loading content',
      liveRegion: true,
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Padding(
            padding: padding,
            child: Column(
              children: List.generate(
                itemCount,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: spacing),
                  child: itemBuilder?.call(context, index) ??
                      _DefaultSkeletonItem(height: itemHeight),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A sliver-compatible variant of [ShimmerLoadingList].
///
/// Renders shimmer skeleton items as a sliver list, suitable for use
/// inside [CustomScrollView].
class SliverShimmerLoadingList extends StatelessWidget {
  const SliverShimmerLoadingList({
    super.key,
    this.itemCount = 4,
    this.itemHeight = 80,
    this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.semanticLabel,
  });

  /// The number of skeleton items to display.
  final int itemCount;

  /// The height of each skeleton item.
  final double itemHeight;

  /// An optional custom builder for each skeleton item.
  final Widget Function(BuildContext context, int index)? itemBuilder;

  /// Padding around the sliver list.
  final EdgeInsets padding;

  /// Semantic label for screen readers.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? SpendexColors.darkBorder
        : SpendexColors.lightBorder;
    final highlightColor = isDark
        ? SpendexColors.darkSurface
        : SpendexColors.lightBackground;

    return SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final isFirst = index == 0;
            return Semantics(
              label: isFirst ? (semanticLabel ?? 'Loading content') : null,
              liveRegion: isFirst,
              excludeSemantics: index > 0,
              child: Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: itemBuilder?.call(context, index) ??
                      _DefaultSkeletonItem(height: itemHeight),
                ),
              ),
            );
          },
          childCount: itemCount,
        ),
      ),
    );
  }
}

class _DefaultSkeletonItem extends StatelessWidget {
  const _DefaultSkeletonItem({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
    );
  }
}
