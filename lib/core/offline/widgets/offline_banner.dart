import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/offline_provider.dart';

/// Banner that appears when the app is offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({
    super.key,
    this.showWhenOnline = false,
  });

  final bool showWhenOnline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    // Don't show if online and we don't want to show when online
    if (syncState.isOnline && !showWhenOnline) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: syncState.isOnline
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.errorContainer,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            Icon(
              syncState.isOnline ? Iconsax.wifi : Iconsax.wifi_square,
              size: 20,
              color: syncState.isOnline
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                syncState.isOnline
                    ? 'Back online. Syncing changes...'
                    : 'You\'re offline. Changes will sync when connected.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: syncState.isOnline
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (syncState.pendingCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: syncState.isOnline
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${syncState.pendingCount} pending',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: syncState.isOnline
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Wrapper widget that shows offline banner at the top of a scaffold
class OfflineAwareScaffold extends ConsumerWidget {
  const OfflineAwareScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      body: Column(
        children: [
          // Show banner when offline
          if (!syncState.isOnline) const OfflineBanner(),

          // Main content
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Animated offline indicator that can be placed anywhere
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({
    super.key,
    this.size = 24,
    this.showTooltip = true,
  });

  final double size;
  final bool showTooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    final indicator = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: syncState.isOnline
          ? Icon(
              Iconsax.wifi,
              key: const ValueKey('online'),
              size: size,
              color: theme.colorScheme.primary,
            )
          : Icon(
              Iconsax.wifi_square,
              key: const ValueKey('offline'),
              size: size,
              color: theme.colorScheme.error,
            ),
    );

    if (showTooltip) {
      return Tooltip(
        message: syncState.isOnline ? 'Online' : 'Offline',
        child: indicator,
      );
    }

    return indicator;
  }
}
