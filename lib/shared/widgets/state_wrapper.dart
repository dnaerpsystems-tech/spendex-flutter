import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import 'empty_state_widget.dart';
import 'error_state_widget.dart';
import 'loading_state_widget.dart';

/// A generic wrapper widget that renders the appropriate state widget
/// based on loading, error, empty, or data conditions.
///
/// This widget encapsulates the common pattern of checking `isLoading`,
/// `error`, and data emptiness, and delegates to [LoadingStateWidget],
/// [ErrorStateWidget], [EmptyStateWidget], or a custom data builder.
///
/// Example usage:
/// ```dart
/// StateWrapper<List<BudgetModel>>(
///   isLoading: state.isLoading,
///   error: state.error,
///   data: state.budgets,
///   isEmpty: (budgets) => budgets.isEmpty,
///   onRetry: () => ref.read(provider.notifier).loadAll(),
///   emptyIcon: Iconsax.wallet_3,
///   emptyTitle: 'No Budgets Yet',
///   dataBuilder: (context, budgets) => BudgetsList(budgets: budgets),
/// )
/// ```
class StateWrapper<T> extends StatelessWidget {
  const StateWrapper({
    required this.isLoading,
    required this.dataBuilder,
    super.key,
    this.error,
    this.data,
    this.isEmpty,
    this.onRetry,
    this.loadingMessage,
    this.loadingWidget,
    this.errorTitle,
    this.errorIcon,
    this.retryLabel,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionLabel,
    this.emptyActionIcon,
    this.onEmptyAction,
  });

  /// Whether the data is currently loading.
  final bool isLoading;

  /// An optional error message. When non-null, the error state is displayed.
  final String? error;

  /// The data to display. May be null if not yet loaded.
  final T? data;

  /// A function that determines whether the data should be considered empty.
  /// If null, the empty state is never shown.
  final bool Function(T data)? isEmpty;

  /// Builder invoked when data is available and not empty.
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// Callback invoked when the retry button is pressed in the error state.
  final VoidCallback? onRetry;

  /// An optional message displayed during the loading state.
  final String? loadingMessage;

  /// An optional custom widget to display during the loading state.
  /// When provided, this takes precedence over the default loading indicator.
  final Widget? loadingWidget;

  /// An optional title for the error state.
  final String? errorTitle;

  /// An optional icon for the error state.
  final IconData? errorIcon;

  /// An optional label for the retry button.
  final String? retryLabel;

  /// The icon displayed in the empty state. Defaults to [Iconsax.box_1].
  final IconData? emptyIcon;

  /// The title displayed in the empty state.
  final String? emptyTitle;

  /// The subtitle displayed in the empty state.
  final String? emptySubtitle;

  /// The label for the action button in the empty state.
  final String? emptyActionLabel;

  /// The icon for the action button in the empty state.
  final IconData? emptyActionIcon;

  /// Callback invoked when the action button is pressed in the empty state.
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return loadingWidget ?? LoadingStateWidget(message: loadingMessage);
    }

    if (error != null && data == null) {
      return ErrorStateWidget(
        message: error!,
        title: errorTitle,
        icon: errorIcon,
        onRetry: onRetry,
        retryLabel: retryLabel,
      );
    }

    if (data == null) {
      return EmptyStateWidget(
        icon: emptyIcon ?? Iconsax.box_1,
        title: emptyTitle ?? 'Nothing here',
        subtitle: emptySubtitle,
        actionLabel: emptyActionLabel,
        actionIcon: emptyActionIcon,
        onAction: onEmptyAction,
      );
    }

    final currentData = data as T;

    if (isEmpty != null && isEmpty!(currentData)) {
      return EmptyStateWidget(
        icon: emptyIcon ?? Iconsax.box_1,
        title: emptyTitle ?? 'Nothing here',
        subtitle: emptySubtitle,
        actionLabel: emptyActionLabel,
        actionIcon: emptyActionIcon,
        onAction: onEmptyAction,
      );
    }

    return dataBuilder(context, currentData);
  }
}

/// A sliver-compatible variant of [StateWrapper].
///
/// Wraps each state in the appropriate sliver widget for use inside
/// [CustomScrollView] or other sliver-based layouts.
class SliverStateWrapper<T> extends StatelessWidget {
  const SliverStateWrapper({
    required this.isLoading,
    required this.dataBuilder,
    super.key,
    this.error,
    this.data,
    this.isEmpty,
    this.onRetry,
    this.loadingMessage,
    this.loadingWidget,
    this.errorTitle,
    this.errorIcon,
    this.retryLabel,
    this.emptyIcon,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyActionLabel,
    this.emptyActionIcon,
    this.onEmptyAction,
  });

  /// Whether the data is currently loading.
  final bool isLoading;

  /// An optional error message.
  final String? error;

  /// The data to display.
  final T? data;

  /// A function that determines whether the data should be considered empty.
  final bool Function(T data)? isEmpty;

  /// Builder invoked when data is available and not empty.
  /// Should return a sliver widget.
  final Widget Function(BuildContext context, T data) dataBuilder;

  /// Callback invoked when the retry button is pressed.
  final VoidCallback? onRetry;

  /// An optional message for the loading state.
  final String? loadingMessage;

  /// An optional custom sliver widget for the loading state.
  final Widget? loadingWidget;

  /// An optional title for the error state.
  final String? errorTitle;

  /// An optional icon for the error state.
  final IconData? errorIcon;

  /// An optional label for the retry button.
  final String? retryLabel;

  /// The icon for the empty state.
  final IconData? emptyIcon;

  /// The title for the empty state.
  final String? emptyTitle;

  /// The subtitle for the empty state.
  final String? emptySubtitle;

  /// The label for the empty state action button.
  final String? emptyActionLabel;

  /// The icon for the empty state action button.
  final IconData? emptyActionIcon;

  /// Callback for the empty state action button.
  final VoidCallback? onEmptyAction;

  @override
  Widget build(BuildContext context) {
    if (isLoading && data == null) {
      return loadingWidget ?? SliverLoadingStateWidget(message: loadingMessage);
    }

    if (error != null && data == null) {
      return SliverErrorStateWidget(
        message: error!,
        title: errorTitle,
        icon: errorIcon,
        onRetry: onRetry,
        retryLabel: retryLabel,
      );
    }

    if (data == null) {
      return SliverEmptyStateWidget(
        icon: emptyIcon ?? Iconsax.box_1,
        title: emptyTitle ?? 'Nothing here',
        subtitle: emptySubtitle,
        actionLabel: emptyActionLabel,
        actionIcon: emptyActionIcon,
        onAction: onEmptyAction,
      );
    }

    final currentData = data as T;

    if (isEmpty != null && isEmpty!(currentData)) {
      return SliverEmptyStateWidget(
        icon: emptyIcon ?? Iconsax.box_1,
        title: emptyTitle ?? 'Nothing here',
        subtitle: emptySubtitle,
        actionLabel: emptyActionLabel,
        actionIcon: emptyActionIcon,
        onAction: onEmptyAction,
      );
    }

    return dataBuilder(context, currentData);
  }
}
