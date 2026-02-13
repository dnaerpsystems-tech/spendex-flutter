import 'package:flutter/material.dart';
import 'package:spendex/app/theme.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';

/// Dialog for applying resolution action to multiple duplicates at once
class BatchResolutionDialog extends StatefulWidget {
  const BatchResolutionDialog({
    required this.duplicateCount,
    super.key,
    this.confidenceLevel,
  });

  /// Total number of duplicates that will be affected
  final int duplicateCount;

  /// Optional confidence level filter ('all', 'high', 'medium', 'low')
  final String? confidenceLevel;

  @override
  State<BatchResolutionDialog> createState() => _BatchResolutionDialogState();
}

class _BatchResolutionDialogState extends State<BatchResolutionDialog> {
  DuplicateResolutionAction? _selectedAction;

  String get _targetText {
    if (widget.confidenceLevel != null && widget.confidenceLevel != 'all') {
      return '${widget.duplicateCount} ${widget.confidenceLevel} confidence duplicates';
    }
    return '${widget.duplicateCount} duplicates';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  color: SpendexColors.primary,
                  size: 28,
                ),
                const SizedBox(width: SpendexTheme.spacingMd),
                Expanded(
                  child: Text(
                    'Apply to All',
                    style: SpendexTheme.headlineSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpendexTheme.spacingLg),

            // Description
            Text(
              'Apply the same action to $_targetText at once.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Action selection
            Text(
              'Choose action:',
              style: SpendexTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: SpendexTheme.spacingMd),

            // Action options
            _buildActionOption(
              action: DuplicateResolutionAction.skip,
              icon: Icons.block_outlined,
              title: 'Skip All',
              description: 'Don\'t import any of these transactions',
              color: SpendexColors.expense,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: SpendexTheme.spacingMd),

            _buildActionOption(
              action: DuplicateResolutionAction.merge,
              icon: Icons.merge_outlined,
              title: 'Merge All',
              description: 'Update all existing transactions',
              color: SpendexColors.warning,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: SpendexTheme.spacingMd),

            _buildActionOption(
              action: DuplicateResolutionAction.keepBoth,
              icon: Icons.content_copy_outlined,
              title: 'Keep All',
              description: 'Import all as new transactions',
              color: SpendexColors.primary,
              colorScheme: colorScheme,
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: SpendexTheme.labelLarge.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: SpendexTheme.spacingMd),
                FilledButton(
                  onPressed: _selectedAction != null
                      ? () => Navigator.of(context).pop(_selectedAction)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: SpendexColors.primary,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                  child: Text(
                    'Apply',
                    style: SpendexTheme.labelLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required DuplicateResolutionAction action,
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedAction == action;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedAction = action;
        });
      },
      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: SpendexTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: SpendexTheme.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

/// Show batch resolution dialog
Future<DuplicateResolutionAction?> showBatchResolutionDialog({
  required BuildContext context,
  required int duplicateCount,
  String? confidenceLevel,
}) {
  return showDialog<DuplicateResolutionAction>(
    context: context,
    builder: (context) => BatchResolutionDialog(
      duplicateCount: duplicateCount,
      confidenceLevel: confidenceLevel,
    ),
  );
}
