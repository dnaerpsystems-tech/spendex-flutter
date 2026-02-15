import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/category_breakdown_model.dart';

/// List view of category breakdown with percentage bars
class CategoryBreakdownList extends StatelessWidget {
  const CategoryBreakdownList({
    required this.categories,
    required this.title,
    super.key,
    this.maxItems = 8,
    this.onCategoryTap,
  });

  final List<CategoryBreakdownModel> categories;
  final String title;
  final int maxItems;
  final void Function(CategoryBreakdownModel)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No data available',
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SpendexTheme.titleMedium),
          const SizedBox(height: 16),
          ...categories.take(maxItems).map(
                (cat) => _CategoryRow(
                  category: cat,
                  isDark: isDark,
                  onTap: onCategoryTap != null ? () => onCategoryTap!(cat) : null,
                ),
              ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.isDark,
    this.onTap,
  });

  final CategoryBreakdownModel category;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: category.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: SpendexTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: category.percentage / 100,
                      backgroundColor:
                          isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      valueColor: AlwaysStoppedAnimation(category.color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCompact(category.amountInRupees),
                  style: SpendexTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${category.percentage.toStringAsFixed(1)}%',
                  style: SpendexTheme.labelSmall.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
