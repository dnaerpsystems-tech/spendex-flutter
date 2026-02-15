import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/imported_statement_model.dart';

/// Reusable card for displaying import history item
class ImportHistoryCard extends StatelessWidget {
  const ImportHistoryCard({
    required this.import,
    required this.onTap,
    this.onDelete,
    super.key,
  });

  final ImportedStatementModel import;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  IconData _getFileIcon() {
    switch (import.fileType) {
      case FileType.pdf:
        return Iconsax.document;
      case FileType.csv:
        return Iconsax.document_text;
    }
  }

  Color _getStatusColor() {
    switch (import.status) {
      case ImportStatus.completed:
        return SpendexColors.income;
      case ImportStatus.failed:
        return SpendexColors.expense;
      case ImportStatus.processing:
        return SpendexColors.warning;
      case ImportStatus.pending:
        return SpendexColors.primary;
    }
  }

  String _getStatusLabel() {
    switch (import.status) {
      case ImportStatus.completed:
        return 'Completed';
      case ImportStatus.failed:
        return 'Failed';
      case ImportStatus.processing:
        return 'Processing';
      case ImportStatus.pending:
        return 'Pending';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Dismissible(
      key: ValueKey(import.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (direction) async {
        return showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Import?'),
            content: const Text(
              'Are you sure you want to delete this import? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: SpendexColors.expense,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: SpendexColors.expense,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Iconsax.trash,
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                // File icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _getFileIcon(),
                      color: SpendexColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // File name
                      Text(
                        import.fileName,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Date and transaction count
                      Row(
                        children: [
                          Icon(
                            Iconsax.calendar,
                            size: 14,
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(import.uploadDate),
                            style: SpendexTheme.labelMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                          if (import.transactionCount > 0) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Iconsax.receipt_item,
                              size: 14,
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${import.transactionCount} transactions',
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getStatusLabel(),
                              style: SpendexTheme.labelMedium.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Iconsax.arrow_right_3,
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
