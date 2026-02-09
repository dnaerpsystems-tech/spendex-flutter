import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import 'account_card.dart';

/// Account Type Selector Widget
/// A grid or horizontal list of account types with selection state
class AccountTypeSelector extends StatelessWidget {
  final AccountType? selectedType;
  final ValueChanged<AccountType> onTypeSelected;
  final bool horizontal;
  final List<AccountType>? excludeTypes;

  const AccountTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.horizontal = false,
    this.excludeTypes,
  });

  @override
  Widget build(BuildContext context) {
    final types = AccountType.values
        .where((type) => !(excludeTypes?.contains(type) ?? false))
        .toList();

    if (horizontal) {
      return _buildHorizontalList(context, types);
    }

    return _buildGrid(context, types);
  }

  Widget _buildGrid(BuildContext context, List<AccountType> types) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _buildTypeItem(context, types[index]);
      },
    );
  }

  Widget _buildHorizontalList(BuildContext context, List<AccountType> types) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return _buildTypeItem(context, types[index], horizontal: true);
        },
      ),
    );
  }

  Widget _buildTypeItem(BuildContext context, AccountType type, {bool horizontal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedType == type;
    final color = getAccountTypeColor(type);

    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: horizontal ? 80 : null,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? SpendexColors.darkCard : SpendexColors.lightCard),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : (isDark
                        ? SpendexColors.darkBackground
                        : SpendexColors.lightBackground),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                getAccountTypeIcon(type),
                color: isSelected
                    ? color
                    : (isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                type.label,
                style: SpendexTheme.labelMedium.copyWith(
                  color: isSelected
                      ? color
                      : (isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Account Type Chip
/// A smaller, inline version for displaying account type
class AccountTypeChip extends StatelessWidget {
  final AccountType type;
  final bool selected;
  final VoidCallback? onTap;

  const AccountTypeChip({
    super.key,
    required this.type,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getAccountTypeColor(type);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
              : (isDark ? SpendexColors.darkCard : SpendexColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? color
                : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              getAccountTypeIcon(type),
              color: selected
                  ? color
                  : (isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              type.label,
              style: SpendexTheme.labelMedium.copyWith(
                color: selected
                    ? color
                    : (isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Account Type Filter List
/// Horizontal scrollable list of account type chips for filtering
class AccountTypeFilterList extends StatelessWidget {
  final AccountType? selectedType;
  final ValueChanged<AccountType?> onTypeSelected;
  final bool showAll;

  const AccountTypeFilterList({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.showAll = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (showAll)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onTypeSelected(null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedType == null
                        ? SpendexColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? SpendexColors.darkCard : SpendexColors.lightCard),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selectedType == null
                          ? SpendexColors.primary
                          : (isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder),
                    ),
                  ),
                  child: Text(
                    'All',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: selectedType == null
                          ? SpendexColors.primary
                          : (isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary),
                      fontWeight:
                          selectedType == null ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ...AccountType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AccountTypeChip(
                type: type,
                selected: selectedType == type,
                onTap: () => onTypeSelected(type),
              ),
            );
          }),
        ],
      ),
    );
  }
}
