import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/category_breakdown_model.dart';

/// Donut/Pie chart showing category breakdown with legend.
class CategoryDonutChart extends StatefulWidget {
  const CategoryDonutChart({
    required this.breakdown,
    super.key,
    this.height = 280,
    this.showLegend = true,
    this.maxCategories = 6,
  });

  final CategoryBreakdownResponse breakdown;
  final double height;
  final bool showLegend;
  final int maxCategories;

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.breakdown.categories.isEmpty) {
      return _buildEmptyState(isDark);
    }

    final displayCategories = _prepareCategories();

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
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
          Text(
            '${widget.breakdown.isExpense ? "Expense" : "Income"} Distribution',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          SizedBox(
            height: widget.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: _buildSections(displayCategories, isDark),
                  ),
                ),
                _buildCenterContent(isDark),
              ],
            ),
          ),
          if (widget.showLegend) ...[
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildLegend(displayCategories, isDark),
          ],
        ],
      ),
    );
  }

  List<_DisplayCategory> _prepareCategories() {
    final displayCategories = <_DisplayCategory>[];
    var otherAmount = 0.0;
    var otherPercentage = 0.0;

    for (var i = 0; i < widget.breakdown.categories.length; i++) {
      final cat = widget.breakdown.categories[i];
      if (i < widget.maxCategories) {
        displayCategories.add(
          _DisplayCategory(
            name: cat.categoryName,
            amount: cat.amountInRupees,
            percentage: cat.percentage,
            color: cat.color,
            isOther: false,
          ),
        );
      } else {
        otherAmount += cat.amountInRupees;
        otherPercentage += cat.percentage;
      }
    }

    if (otherAmount > 0) {
      displayCategories.add(
        _DisplayCategory(
          name: 'Other',
          amount: otherAmount,
          percentage: otherPercentage,
          color: SpendexColors.lightTextTertiary,
          isOther: true,
        ),
      );
    }

    return displayCategories;
  }

  List<PieChartSectionData> _buildSections(
    List<_DisplayCategory> categories,
    bool isDark,
  ) {
    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final cat = entry.value;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 45.0 : 35.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: cat.color.withValues(alpha: isTouched ? 1.0 : 0.85),
        value: cat.percentage,
        title: '${cat.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: SpendexTheme.labelSmall.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: const [
            Shadow(blurRadius: 2, color: Colors.black26),
          ],
        ),
        titlePositionPercentageOffset: 0.55,
        borderSide: isTouched ? BorderSide(color: cat.color, width: 2) : BorderSide.none,
      );
    }).toList();
  }

  Widget _buildCenterContent(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Total',
          style: SpendexTheme.labelSmall.copyWith(
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatCompact(
            widget.breakdown.totalAmountInRupees,
            decimalDigits: 1,
          ),
          style: SpendexTheme.headlineSmall.copyWith(
            color: widget.breakdown.isExpense ? SpendexColors.expense : SpendexColors.income,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(List<_DisplayCategory> categories, bool isDark) {
    return Wrap(
      spacing: SpendexTheme.spacingLg,
      runSpacing: SpendexTheme.spacingSm,
      children: categories.asMap().entries.map((entry) {
        final index = entry.key;
        final cat = entry.value;
        final isTouched = index == _touchedIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _touchedIndex = _touchedIndex == index ? -1 : index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: SpendexTheme.spacingSm,
              vertical: SpendexTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: isTouched ? cat.color.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: SpendexTheme.labelSmall.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    fontWeight: isTouched ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${cat.percentage.toStringAsFixed(1)}%',
                  style: SpendexTheme.labelSmall.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingXl),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'No ${widget.breakdown.isExpense ? "expense" : "income"} data',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisplayCategory {
  const _DisplayCategory({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.isOther,
  });

  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final bool isOther;
}
