import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Category Type Selector Widget
///
/// A beautiful segmented control for selecting between Income and Expense
/// category types. Features smooth animations and proper theme support.
class CategoryTypeSelector extends StatelessWidget {

  const CategoryTypeSelector({
    required this.selectedType, required this.onTypeChanged, super.key,
    this.enabled = true,
    this.showIcons = true,
    this.height = 52,
    this.padding = const EdgeInsets.all(4),
  });
  /// Currently selected category type
  final CategoryType selectedType;

  /// Callback when the type is changed
  final ValueChanged<CategoryType> onTypeChanged;

  /// Whether the selector is enabled
  final bool enabled;

  /// Whether to show icons alongside text
  final bool showIcons;

  /// Height of the selector
  final double height;

  /// Padding around the selector content
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkSurface
            : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark
              ? SpendexColors.darkBorder
              : SpendexColors.lightBorder,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = (constraints.maxWidth - padding.horizontal) / 2;
          final selectedIndex = selectedType == CategoryType.income ? 0 : 1;

          return Stack(
            children: [
              // Animated Selection Background
              AnimatedPositioned(
                duration: AppConstants.shortAnimation,
                curve: Curves.easeInOut,
                left: selectedIndex * segmentWidth,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: selectedType == CategoryType.income
                          ? [
                              SpendexColors.income,
                              SpendexColors.income.withValues(alpha: 0.8),
                            ]
                          : [
                              SpendexColors.expense,
                              SpendexColors.expense.withValues(alpha: 0.8),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                    boxShadow: [
                      BoxShadow(
                        color: (selectedType == CategoryType.income
                                ? SpendexColors.income
                                : SpendexColors.expense)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Segment Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildSegment(
                      context: context,
                      type: CategoryType.income,
                      isDark: isDark,
                      isSelected: selectedType == CategoryType.income,
                    ),
                  ),
                  Expanded(
                    child: _buildSegment(
                      context: context,
                      type: CategoryType.expense,
                      isDark: isDark,
                      isSelected: selectedType == CategoryType.expense,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds an individual segment button
  Widget _buildSegment({
    required BuildContext context,
    required CategoryType type,
    required bool isDark,
    required bool isSelected,
  }) {
    final isIncome = type == CategoryType.income;
    final icon = isIncome ? Iconsax.arrow_down : Iconsax.arrow_up;
    final unselectedColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return GestureDetector(
      onTap: enabled ? () => onTypeChanged(type) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedDefaultTextStyle(
        duration: AppConstants.shortAnimation,
        style: SpendexTheme.titleMedium.copyWith(
          color: isSelected ? Colors.white : unselectedColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        child: AnimatedOpacity(
          duration: AppConstants.shortAnimation,
          opacity: enabled ? 1.0 : 0.5,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcons) ...[
                  AnimatedSwitcher(
                    duration: AppConstants.shortAnimation,
                    child: Icon(
                      icon,
                      key: ValueKey('${type.value}_$isSelected'),
                      color: isSelected ? Colors.white : unselectedColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                ],
                Text(type.label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact Category Type Selector
///
/// A smaller version of the type selector for use in forms or tight spaces.
class CompactCategoryTypeSelector extends StatelessWidget {

  const CompactCategoryTypeSelector({
    required this.selectedType, required this.onTypeChanged, super.key,
    this.enabled = true,
  });
  /// Currently selected category type
  final CategoryType selectedType;

  /// Callback when the type is changed
  final ValueChanged<CategoryType> onTypeChanged;

  /// Whether the selector is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChip(
          context: context,
          type: CategoryType.income,
          isDark: isDark,
          isSelected: selectedType == CategoryType.income,
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        _buildChip(
          context: context,
          type: CategoryType.expense,
          isDark: isDark,
          isSelected: selectedType == CategoryType.expense,
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required CategoryType type,
    required bool isDark,
    required bool isSelected,
  }) {
    final isIncome = type == CategoryType.income;
    final color = isIncome ? SpendexColors.income : SpendexColors.expense;

    return GestureDetector(
      onTap: enabled ? () => onTypeChanged(type) : null,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingMd,
          vertical: SpendexTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? color
                : isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              type.label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category Type Toggle Button
///
/// A single toggle button that switches between Income and Expense on tap.
/// Displays the current type with an icon.
class CategoryTypeToggleButton extends StatelessWidget {

  const CategoryTypeToggleButton({
    required this.selectedType, required this.onTypeChanged, super.key,
    this.enabled = true,
  });
  /// Currently selected category type
  final CategoryType selectedType;

  /// Callback when the type is toggled
  final ValueChanged<CategoryType> onTypeChanged;

  /// Whether the button is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isIncome = selectedType == CategoryType.income;
    final color = isIncome ? SpendexColors.income : SpendexColors.expense;

    return GestureDetector(
      onTap: enabled
          ? () {
              final newType = isIncome
                  ? CategoryType.expense
                  : CategoryType.income;
              onTypeChanged(newType);
            }
          : null,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingLg,
          vertical: SpendexTheme.spacingMd,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              duration: AppConstants.shortAnimation,
              turns: isIncome ? 0 : 0.5,
              child: Icon(
                Iconsax.arrow_down,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            AnimatedSwitcher(
              duration: AppConstants.shortAnimation,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                selectedType.label,
                key: ValueKey(selectedType.value),
                style: SpendexTheme.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Icon(
              Iconsax.repeat,
              color: color.withValues(alpha: 0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

/// Category Type Radio Buttons
///
/// Traditional radio button style selection for Income/Expense types.
class CategoryTypeRadioButtons extends StatelessWidget {

  const CategoryTypeRadioButtons({
    required this.selectedType, required this.onTypeChanged, super.key,
    this.enabled = true,
    this.direction = Axis.horizontal,
  });
  /// Currently selected category type
  final CategoryType selectedType;

  /// Callback when the type is changed
  final ValueChanged<CategoryType> onTypeChanged;

  /// Whether the buttons are enabled
  final bool enabled;

  /// Layout direction
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = CategoryType.values.map((type) {
      return _buildRadioItem(
        context: context,
        type: type,
        isDark: isDark,
        isSelected: selectedType == type,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Row(
        children: items
            .expand((item) => [item, const SizedBox(width: SpendexTheme.spacingLg)])
            .toList()
          ..removeLast(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .expand((item) => [item, const SizedBox(height: SpendexTheme.spacingMd)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildRadioItem({
    required BuildContext context,
    required CategoryType type,
    required bool isDark,
    required bool isSelected,
  }) {
    final isIncome = type == CategoryType.income;
    final color = isIncome ? SpendexColors.income : SpendexColors.expense;

    return GestureDetector(
      onTap: enabled ? () => onTypeChanged(type) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: AppConstants.shortAnimation,
        opacity: enabled ? 1.0 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Radio Circle
            AnimatedContainer(
              duration: AppConstants.shortAnimation,
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? color
                      : isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: AppConstants.shortAnimation,
                  width: isSelected ? 12 : 0,
                  height: isSelected ? 12 : 0,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingSm),

            // Type Icon
            Icon(
              isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
              color: isSelected
                  ? color
                  : isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
              size: 18,
            ),
            const SizedBox(width: SpendexTheme.spacingXs),

            // Label
            Text(
              type.label,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isSelected
                    ? (isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary)
                    : (isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
