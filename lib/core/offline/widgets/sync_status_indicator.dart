import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../providers/offline_provider.dart';
import '../models/sync_result.dart';

/// Widget that shows sync status in a compact form
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({
    super.key,
    this.showLabel = true,
    this.onTap,
  });

  final bool showLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap ?? () => _showSyncDetails(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(syncState, theme),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(syncState, theme),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                _getStatusText(syncState),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: _getTextColor(syncState, theme),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            if (syncState.pendingCount > 0 && !syncState.isSyncing) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${syncState.pendingCount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SyncState state, ThemeData theme) {
    if (state.isSyncing) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (!state.isOnline) {
      return Icon(
        Iconsax.wifi_square,
        size: 16,
        color: theme.colorScheme.error,
      );
    }

    if (state.pendingCount > 0) {
      return Icon(
        Iconsax.cloud_change,
        size: 16,
        color: theme.colorScheme.tertiary,
      );
    }

    return Icon(
      Iconsax.cloud_tick,
      size: 16,
      color: theme.colorScheme.primary,
    );
  }

  Color _getBackgroundColor(SyncState state, ThemeData theme) {
    if (!state.isOnline) {
      return theme.colorScheme.errorContainer;
    }
    if (state.isSyncing) {
      return theme.colorScheme.primaryContainer;
    }
    if (state.pendingCount > 0) {
      return theme.colorScheme.tertiaryContainer;
    }
    return theme.colorScheme.surfaceContainerHighest;
  }

  Color _getTextColor(SyncState state, ThemeData theme) {
    if (!state.isOnline) {
      return theme.colorScheme.onErrorContainer;
    }
    if (state.isSyncing) {
      return theme.colorScheme.onPrimaryContainer;
    }
    if (state.pendingCount > 0) {
      return theme.colorScheme.onTertiaryContainer;
    }
    return theme.colorScheme.onSurfaceVariant;
  }

  String _getStatusText(SyncState state) {
    if (state.isSyncing) {
      final progress = state.progress;
      if (progress != null) {
        return progress.phase.label;
      }
      return 'Syncing...';
    }

    if (!state.isOnline) {
      return 'Offline';
    }

    if (state.pendingCount > 0) {
      return 'Pending sync';
    }

    return 'Synced';
  }

  void _showSyncDetails(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SyncDetailsSheet(),
    );
  }
}

/// Bottom sheet showing detailed sync information
class SyncDetailsSheet extends ConsumerWidget {
  const SyncDetailsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStatusProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                syncState.isOnline ? Iconsax.cloud : Iconsax.cloud_cross,
                color: syncState.isOnline
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
              const SizedBox(width: 12),
              Text(
                'Sync Status',
                style: theme.textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Connection status
          _buildStatusRow(
            context,
            'Connection',
            syncState.isOnline ? 'Online' : 'Offline',
            syncState.isOnline ? Iconsax.tick_circle : Iconsax.close_circle,
            syncState.isOnline
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(height: 12),

          // Pending changes
          _buildStatusRow(
            context,
            'Pending changes',
            '${syncState.pendingCount}',
            Iconsax.document_upload,
            syncState.pendingCount > 0
                ? theme.colorScheme.tertiary
                : theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),

          // Last sync
          _buildStatusRow(
            context,
            'Last synced',
            _formatLastSync(syncState.lastSyncTime),
            Iconsax.clock,
            theme.colorScheme.outline,
          ),

          if (syncState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.warning_2,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      syncState.error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Sync button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: syncState.isSyncing || !syncState.isOnline
                  ? null
                  : () {
                      ref.read(syncStatusProvider.notifier).syncAll();
                      Navigator.pop(context);
                    },
              icon: syncState.isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Iconsax.refresh),
              label: Text(syncState.isSyncing ? 'Syncing...' : 'Sync Now'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatLastSync(DateTime? lastSync) {
    if (lastSync == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(lastSync);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${lastSync.day}/${lastSync.month}/${lastSync.year}';
  }
}
