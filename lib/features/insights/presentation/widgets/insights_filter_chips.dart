import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../data/models/insight_model.dart';

/// Extension to provide display labels for InsightType
extension InsightTypeExtension on InsightType {
  /// Get human-readable label for the insight type
  String get label {
    switch (this) {
      case InsightType.spendingPattern:
        return 'Spending Pattern';
      case InsightType.savingsOpportunity:
        return 'Savings';
      case InsightType.billPrediction:
        return 'Bill Prediction';
      case InsightType.anomalyDetection:
        return 'Anomaly';
      case InsightType.budgetRecommendation:
        return 'Budget';
      case InsightType.goalAchievability:
        return 'Goal';
      case InsightType.loanInsight:
        return 'Loan';
      case InsightType.categoryTrend:
        return 'Category Trend';
      case InsightType.merchantAnalysis:
        return 'Merchant';
      case InsightType.cashFlowForecast:
        return 'Cash Flow';
    }
  }
}

/// A horizontal scrollable filter chips widget for filtering insights by type
class InsightsFilterChips extends StatelessWidget {

  const InsightsFilterChips({
    required this.selectedType, required this.onTypeSelected, super.key,
    this.typeCounts = const {},
  });
  /// Currently selected insight type (null means "All")
  final InsightType? selectedType;

  /// Callback when a type is selected
  final Function(InsightType?) onTypeSelected;

  /// Count of insights per type for displaying badges
  final Map<InsightType, int> typeCounts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
        vertical: SpendexTheme.spacingSm,
      ),
      child: Row(
        children: [
          // "All" chip
          _buildFilterChip(
            context: context,
            label: 'All',
            isSelected: selectedType == null,
            count: typeCounts.values.fold(0, (sum, count) => sum + count),
            onTap: () => onTypeSelected(null),
            isDark: isDark,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),

          // Individual type chips
          ...InsightType.values.map((type) {
            final count = typeCounts[type] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: SpendexTheme.spacingSm),
              child: _buildFilterChip(
                context: context,
                label: type.label,
                isSelected: selectedType == type,
                count: count,
                onTap: () => onTypeSelected(type),
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds a single filter chip with optional count badge
  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required int count,
    required VoidCallback onTap,
    required bool isDark,
  }) {

    return Stack(
      clipBehavior: Clip.none,
      children: [
        FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => onTap(),
          backgroundColor: isDark
              ? SpendexColors.darkSurface
              : SpendexColors.lightSurface,
          selectedColor: SpendexColors.primary,
          checkmarkColor: Colors.white,
          labelStyle: SpendexTheme.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            side: BorderSide(
              color: isSelected
                  ? SpendexColors.primary
                  : (isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder),
              width: isSelected ? 0 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingMd,
            vertical: SpendexTheme.spacingSm,
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          elevation: 0,
          pressElevation: 0,
        ),

        // Count badge
        if (count > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : SpendexColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? SpendexColors.darkSurface
                      : SpendexColors.lightSurface,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: SpendexTheme.labelSmall.copyWith(
                    color: isSelected
                        ? SpendexColors.primary
                        : Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
