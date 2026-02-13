import 'package:flutter/material.dart';
import 'package:spendex/app/theme.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';

/// Widget for selecting resolution action for a duplicate match
///
/// Provides three action buttons: Skip, Merge, and Keep Both
class ResolutionActionSelector extends StatelessWidget {
  const ResolutionActionSelector({
    required this.onActionSelected,
    super.key,
    this.selectedAction,
    this.compact = false,
  });

  /// Currently selected action (null if none selected)
  final DuplicateResolutionAction? selectedAction;

  /// Callback when an action is selected
  final ValueChanged<DuplicateResolutionAction> onActionSelected;

  /// Whether to use compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (compact) {
      return _buildCompactLayout(colorScheme);
    }

    return _buildFullLayout(colorScheme);
  }

  Widget _buildFullLayout(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose action:',
          style: SpendexTheme.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                action: DuplicateResolutionAction.skip,
                icon: Icons.block_outlined,
                label: 'Skip',
                description: 'Don\'t import',
                color: SpendexColors.expense,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Expanded(
              child: _buildActionButton(
                action: DuplicateResolutionAction.merge,
                icon: Icons.merge_outlined,
                label: 'Merge',
                description: 'Update existing',
                color: SpendexColors.warning,
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Expanded(
              child: _buildActionButton(
                action: DuplicateResolutionAction.keepBoth,
                icon: Icons.content_copy_outlined,
                label: 'Keep Both',
                description: 'Import anyway',
                color: SpendexColors.primary,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout(ColorScheme colorScheme) {
    return Row(
      children: [
        _buildCompactActionButton(
          action: DuplicateResolutionAction.skip,
          icon: Icons.block_outlined,
          label: 'Skip',
          color: SpendexColors.expense,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        _buildCompactActionButton(
          action: DuplicateResolutionAction.merge,
          icon: Icons.merge_outlined,
          label: 'Merge',
          color: SpendexColors.warning,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        _buildCompactActionButton(
          action: DuplicateResolutionAction.keepBoth,
          icon: Icons.content_copy_outlined,
          label: 'Keep Both',
          color: SpendexColors.primary,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required DuplicateResolutionAction action,
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final isSelected = selectedAction == action;

    return InkWell(
      onTap: () => onActionSelected(action),
      borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
          border: Border.all(
            color: isSelected ? color : colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? color : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isSelected ? color : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: SpendexTheme.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required DuplicateResolutionAction action,
    required IconData icon,
    required String label,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final isSelected = selectedAction == action;

    return Expanded(
      child: InkWell(
        onTap: () => onActionSelected(action),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingSm,
            vertical: SpendexTheme.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            border: Border.all(
              color: isSelected ? color : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? color : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: SpendexTheme.labelSmall.copyWith(
                  color: isSelected ? color : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension on DuplicateResolutionAction for UI helpers
extension DuplicateResolutionActionUI on DuplicateResolutionAction {
  String get label {
    switch (this) {
      case DuplicateResolutionAction.skip:
        return 'Skip';
      case DuplicateResolutionAction.merge:
        return 'Merge';
      case DuplicateResolutionAction.keepBoth:
        return 'Keep Both';
    }
  }

  String get description {
    switch (this) {
      case DuplicateResolutionAction.skip:
        return 'Don\'t import this transaction';
      case DuplicateResolutionAction.merge:
        return 'Update existing transaction';
      case DuplicateResolutionAction.keepBoth:
        return 'Import as new transaction';
    }
  }

  IconData get icon {
    switch (this) {
      case DuplicateResolutionAction.skip:
        return Icons.block_outlined;
      case DuplicateResolutionAction.merge:
        return Icons.merge_outlined;
      case DuplicateResolutionAction.keepBoth:
        return Icons.content_copy_outlined;
    }
  }

  Color get color {
    switch (this) {
      case DuplicateResolutionAction.skip:
        return SpendexColors.expense;
      case DuplicateResolutionAction.merge:
        return SpendexColors.warning;
      case DuplicateResolutionAction.keepBoth:
        return SpendexColors.primary;
    }
  }
}
