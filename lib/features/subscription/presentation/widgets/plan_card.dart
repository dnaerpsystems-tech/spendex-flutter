import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/subscription_models.dart';

/// A card widget that displays subscription plan details.
///
/// Shows plan name, description, pricing, features list, and action button.
/// Supports highlighting popular plans and indicating the current plan.
class PlanCard extends StatelessWidget {
  /// Creates a plan card widget.
  const PlanCard({
    required this.plan,
    required this.billingCycle,
    super.key,
    this.isCurrentPlan = false,
    this.isPopular = false,
    this.isLoading = false,
    this.onSelect,
  });

  /// The plan data to display.
  final PlanModel plan;

  /// The selected billing cycle for price display.
  final BillingCycle billingCycle;

  /// Whether this is the user's current plan.
  final bool isCurrentPlan;

  /// Whether to show the popular badge.
  final bool isPopular;

  /// Whether the card is in a loading state.
  final bool isLoading;

  /// Callback when the select button is pressed.
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final price = billingCycle == BillingCycle.monthly
        ? plan.monthlyPrice
        : plan.annualPrice;
    final monthlyEquivalent = billingCycle == BillingCycle.yearly
        ? (plan.annualPrice / 12).round()
        : plan.monthlyPrice;
    final savings = billingCycle == BillingCycle.yearly
        ? (plan.monthlyPrice * 12) - plan.annualPrice
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isCurrentPlan
              ? SpendexColors.primary
              : isPopular
                  ? SpendexColors.primary.withOpacity(0.5)
                  : isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
          width: isCurrentPlan ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: SpendexColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, isDark),
          _buildPriceSection(context, isDark, price, monthlyEquivalent),
          if (savings > 0) _buildSavingsBadge(context, savings),
          const SizedBox(height: SpendexTheme.spacingLg),
          _buildFeaturesList(context, isDark),
          const SizedBox(height: SpendexTheme.spacingLg),
          _buildLimitsSection(context, isDark),
          const SizedBox(height: SpendexTheme.spacing2xl),
          _buildActionButton(context),
          const SizedBox(height: SpendexTheme.spacingLg),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                  ),
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingMd,
                    vertical: SpendexTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    gradient: SpendexColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(SpendexTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.star1, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Popular',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (isCurrentPlan)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingMd,
                    vertical: SpendexTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(SpendexTheme.radiusFull),
                    border: Border.all(
                      color: SpendexColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.tick_circle5,
                        size: 12,
                        color: SpendexColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Current',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: SpendexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (plan.description.isNotEmpty) ...[
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              plan.description,
              style: SpendexTheme.bodySmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceSection(
    BuildContext context,
    bool isDark,
    int price,
    int monthlyEquivalent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              Text(
                billingCycle == BillingCycle.yearly
                    ? monthlyEquivalent.toString()
                    : price.toString(),
                style: SpendexTheme.displayLarge.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                  fontSize: 40,
                ),
              ),
              Text(
                '/month',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (billingCycle == BillingCycle.yearly) ...[
            const SizedBox(height: SpendexTheme.spacingXs),
            Text(
              'Billed ₹$price annually',
              style: SpendexTheme.bodySmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingsBadge(BuildContext context, int savings) {
    return Padding(
      padding: const EdgeInsets.only(
        left: SpendexTheme.spacingLg,
        top: SpendexTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpendexTheme.spacingSm,
              vertical: SpendexTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: SpendexColors.income.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.discount_shape,
                  size: 14,
                  color: SpendexColors.income,
                ),
                const SizedBox(width: 4),
                Text(
                  'Save ₹$savings/year',
                  style: SpendexTheme.labelSmall.copyWith(
                    color: SpendexColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Features',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: SpendexColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.tick_circle5,
                      size: 14,
                      color: SpendexColors.primary,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  Expanded(
                    child: Text(
                      feature,
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Limits',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          _buildLimitRow(context, isDark, Iconsax.wallet_2, 'Accounts',
              plan.limits.maxAccounts),
          _buildLimitRow(context, isDark, Iconsax.receipt, 'Transactions/month',
              plan.limits.maxTransactionsPerMonth),
          _buildLimitRow(context, isDark, Iconsax.money_recive, 'Budgets',
              plan.limits.maxBudgets),
          _buildLimitRow(
              context, isDark, Iconsax.flag, 'Goals', plan.limits.maxGoals),
        ],
      ),
    );
  }

  Widget _buildLimitRow(
    BuildContext context,
    bool isDark,
    IconData icon,
    String label,
    int limit,
  ) {
    final isUnlimited = limit == -1;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? SpendexColors.darkTextTertiary
                : SpendexColors.lightTextTertiary,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Expanded(
            child: Text(
              label,
              style: SpendexTheme.bodySmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
            ),
          ),
          Text(
            isUnlimited ? 'Unlimited' : limit.toString(),
            style: SpendexTheme.labelMedium.copyWith(
              color: isUnlimited
                  ? SpendexColors.primary
                  : isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingLg),
      child: ElevatedButton(
        onPressed: isCurrentPlan || isLoading ? null : onSelect,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isCurrentPlan ? Colors.transparent : SpendexColors.primary,
          foregroundColor: isCurrentPlan ? SpendexColors.primary : Colors.white,
          side: isCurrentPlan
              ? const BorderSide(color: SpendexColors.primary)
              : null,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isCurrentPlan ? 'Current Plan' : 'Select Plan',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isCurrentPlan ? SpendexColors.primary : Colors.white,
                ),
              ),
      ),
    );
  }
}

/// Skeleton loading widget for the plan card.
class PlanCardSkeleton extends StatelessWidget {
  const PlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? SpendexColors.darkBorder.withOpacity(0.5)
        : SpendexColors.lightBorder.withOpacity(0.5);

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
          Container(
            width: 120,
            height: 24,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          for (var i = 0; i < 4; i++) ...[
            Container(
              width: double.infinity,
              height: 16,
              margin: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
            ),
          ],
          const SizedBox(height: SpendexTheme.spacingLg),
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}
