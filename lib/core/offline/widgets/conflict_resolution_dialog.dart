import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../models/sync_conflict.dart';
import '../providers/offline_provider.dart';
import '../services/sync_service.dart';

/// Dialog for resolving sync conflicts
class ConflictResolutionDialog extends ConsumerStatefulWidget {
  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
  });

  final SyncConflict conflict;

  static Future<ConflictResolution?> show(
    BuildContext context,
    SyncConflict conflict,
  ) {
    return showDialog<ConflictResolution>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConflictResolutionDialog(conflict: conflict),
    );
  }

  @override
  ConsumerState<ConflictResolutionDialog> createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState
    extends ConsumerState<ConflictResolutionDialog> {
  ConflictResolution? _selectedResolution;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final conflict = widget.conflict;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Iconsax.warning_2,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Sync Conflict'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This ${conflict.entityType} was modified both locally and on the server.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Time comparison
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildTimeRow(
                    context,
                    'Local change',
                    conflict.localModifiedAt,
                    conflict.isLocalNewer,
                  ),
                  const SizedBox(height: 8),
                  _buildTimeRow(
                    context,
                    'Server change',
                    conflict.serverModifiedAt,
                    conflict.isServerNewer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Show details toggle
            TextButton.icon(
              onPressed: () => setState(() => _showDetails = !_showDetails),
              icon: Icon(_showDetails ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1),
              label: Text(_showDetails ? 'Hide details' : 'Show details'),
            ),

            // Details section
            if (_showDetails) ...[
              const SizedBox(height: 8),
              _buildDataComparison(context, conflict),
            ],

            const SizedBox(height: 16),

            // Resolution options
            Text(
              'Choose how to resolve:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),

            _buildResolutionOption(
              context,
              ConflictResolution.keepLocal,
              'Keep local changes',
              'Your local changes will be uploaded, overwriting the server version.',
              Iconsax.mobile,
            ),
            const SizedBox(height: 8),

            _buildResolutionOption(
              context,
              ConflictResolution.keepServer,
              'Keep server changes',
              'The server version will be downloaded, discarding your local changes.',
              Iconsax.cloud,
            ),
            const SizedBox(height: 8),

            _buildResolutionOption(
              context,
              ConflictResolution.merge,
              'Merge changes',
              'Attempt to merge both versions. Server wins for conflicting fields.',
              Iconsax.arrow_swap_horizontal,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedResolution == null
              ? null
              : () => Navigator.pop(context, _selectedResolution),
          child: const Text('Resolve'),
        ),
      ],
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    String label,
    DateTime time,
    bool isNewer,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Iconsax.clock,
          size: 16,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const Spacer(),
        Text(
          _formatDateTime(time),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: isNewer ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isNewer) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Newer',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataComparison(BuildContext context, SyncConflict conflict) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Local data
          ExpansionTile(
            title: Text(
              'Local version',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const Icon(Iconsax.mobile, size: 20),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildJsonView(context, conflict.localData),
              ),
            ],
          ),
          const Divider(height: 1),
          // Server data
          ExpansionTile(
            title: Text(
              'Server version',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: const Icon(Iconsax.cloud, size: 20),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildJsonView(context, conflict.serverData),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJsonView(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          final isConflicting =
              widget.conflict.conflictingFields.contains(entry.key);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isConflicting)
                  Icon(
                    Iconsax.warning_2,
                    size: 12,
                    color: theme.colorScheme.error,
                  ),
                if (isConflicting) const SizedBox(width: 4),
                Text(
                  '${entry.key}: ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isConflicting
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.value}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildResolutionOption(
    BuildContext context,
    ConflictResolution resolution,
    String title,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedResolution == resolution;

    return InkWell(
      onTap: () => setState(() => _selectedResolution = resolution),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Iconsax.tick_circle5,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';

    return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// List widget for showing multiple conflicts
class ConflictsList extends ConsumerWidget {
  const ConflictsList({
    super.key,
    required this.conflicts,
    this.onResolved,
  });

  final List<SyncConflict> conflicts;
  final VoidCallback? onResolved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.tick_circle,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No conflicts',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: conflicts.length,
      itemBuilder: (context, index) {
        final conflict = conflicts[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Icon(
              Iconsax.warning_2,
              color: theme.colorScheme.error,
            ),
            title: Text(conflict.entityType.toUpperCase()),
            subtitle: Text(
              'Modified ${_formatTimeDiff(conflict.timeDifference)} apart',
            ),
            trailing: FilledButton.tonal(
              onPressed: () async {
                final resolution = await ConflictResolutionDialog.show(
                  context,
                  conflict,
                );
                if (resolution != null) {
                  await ref.read(syncStatusProvider.notifier).resolveConflict(
                        conflict.entityId,
                        resolution,
                      );
                  onResolved?.call();
                }
              },
              child: const Text('Resolve'),
            ),
          ),
        );
      },
    );
  }

  String _formatTimeDiff(Duration duration) {
    if (duration.inMinutes < 1) return 'seconds';
    if (duration.inHours < 1) return '${duration.inMinutes} minutes';
    if (duration.inDays < 1) return '${duration.inHours} hours';
    return '${duration.inDays} days';
  }
}
