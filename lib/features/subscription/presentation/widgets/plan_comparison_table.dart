import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/subscription_models.dart';

/// A responsive table widget that compares features across subscription plans.
class PlanComparisonTable extends StatelessWidget {
  const PlanComparisonTable({
    required this.plans,
    super.key,
    this.currentPlanId,
  });

  final List<PlanModel> plans;
  final String? currentPlanId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allFeatures = _collectAllFeatures();
    final limitFeatures = _getLimitFeatures();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: Column(
          children: [
            _buildHeaderRow(context, isDark),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildSectionHeader(context, isDark, 'Features'),
            ...allFeatures.map(
              (feature) => _buildFeatureRow(context, isDark, feature),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildSectionHeader(context, isDark, 'Limits'),
            ...limitFeatures.map(
              (limit) => _buildLimitRow(context, isDark, limit),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _collectAllFeatures() {
    final features = <String>{};
    for (final plan in plans) {
      features.addAll(plan.features);
    }
    return features.toList()..sort();
  }

  List<_LimitFeature> _getLimitFeatures() {
    return [
      _LimitFeature('Accounts', (p) => p.limits.maxAccounts),
      _LimitFeature(
        'Transactions/month',
        (p) => p.limits.maxTransactionsPerMonth,
      ),
      _LimitFeature('Budgets', (p) => p.limits.maxBudgets),
      _LimitFeature('Goals', (p) => p.limits.maxGoals),
    ];
  }

  Widget _buildHeaderRow(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(left: SpendexTheme.spacingMd),
              child: Text(
                'Feature',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          ...plans.map((plan) {
            final isCurrentPlan = plan.id == currentPlanId;
            return Container(
              width: 100,
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingSm,
              ),
              child: Column(
                children: [
                  Text(
                    plan.name,
                    style: SpendexTheme.titleMedium.copyWith(
                      color: isCurrentPlan
                          ? SpendexColors.primary
                          : isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                      fontWeight: isCurrentPlan ? FontWeight.w700 : FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isCurrentPlan) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                      child: Text(
                        'Current',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: SpendexColors.primary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, bool isDark, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingSm,
      ),
      margin: const EdgeInsets.only(
        top: SpendexTheme.spacingSm,
        bottom: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      ),
      child: Text(
        title,
        style: SpendexTheme.labelMedium.copyWith(
          color: SpendexColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFeatureRow(BuildContext context, bool isDark, String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(left: SpendexTheme.spacingMd),
              child: Text(
                feature,
                style: SpendexTheme.bodySmall.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          ...plans.map((plan) {
            final hasFeature = plan.features.contains(feature);
            final isCurrentPlan = plan.id == currentPlanId;
            return Container(
              width: 100,
              decoration: isCurrentPlan
                  ? BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.03),
                    )
                  : null,
              child: Center(child: _buildCheckIndicator(hasFeature, isDark)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLimitRow(
    BuildContext context,
    bool isDark,
    _LimitFeature limit,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Padding(
              padding: const EdgeInsets.only(left: SpendexTheme.spacingMd),
              child: Text(
                limit.name,
                style: SpendexTheme.bodySmall.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
              ),
            ),
          ),
          ...plans.map((plan) {
            final value = limit.getValue(plan);
            final isCurrentPlan = plan.id == currentPlanId;
            return Container(
              width: 100,
              decoration: isCurrentPlan
                  ? BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.03),
                    )
                  : null,
              child: Center(child: _buildLimitValue(value, isDark)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckIndicator(bool hasFeature, bool isDark) {
    if (hasFeature) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: SpendexColors.income.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Iconsax.tick_circle5,
          size: 16,
          color: SpendexColors.income,
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkBorder.withValues(alpha: 0.3)
            : SpendexColors.lightBorder.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Iconsax.close_circle5,
        size: 16,
        color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
      ),
    );
  }

  Widget _buildLimitValue(int value, bool isDark) {
    final isUnlimited = value == -1;
    return Text(
      isUnlimited ? '∞' : value.toString(),
      style: SpendexTheme.labelMedium.copyWith(
        color: isUnlimited
            ? SpendexColors.primary
            : isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
        fontSize: isUnlimited ? 20 : 14,
      ),
    );
  }
}

class _LimitFeature {
  const _LimitFeature(this.name, this.getValue);
  final String name;
  final int Function(PlanModel) getValue;
}

/// Skeleton loading widget for the plan comparison table.
class PlanComparisonTableSkeleton extends StatelessWidget {
  const PlanComparisonTableSkeleton({super.key, this.planCount = 3});
  final int planCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? SpendexColors.darkBorder.withValues(alpha: 0.5)
        : SpendexColors.lightBorder.withValues(alpha: 0.5);

    return Column(
      children: [
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: skeletonColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        for (var i = 0; i < 6; i++) ...[
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
            decoration: BoxDecoration(
              color: skeletonColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
          ),
        ],
      ],
    );
  }
}
