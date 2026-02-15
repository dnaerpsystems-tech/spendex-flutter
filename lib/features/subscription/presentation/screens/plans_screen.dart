import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscription_provider.dart';
import '../widgets/widgets.dart';

/// Plans Screen
///
/// Displays all available subscription plans with:
/// - Billing cycle toggle (Monthly/Yearly)
/// - Plan cards with pricing and features
/// - Feature comparison table (expandable)
/// - Current plan indicator
/// - Plan selection and navigation to checkout
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  static const String routeName = 'plans';
  static const String routePath = '/subscription/plans';

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  bool _isComparisonExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPlans();
    });
  }

  /// Load available plans
  Future<void> _loadPlans() async {
    await ref.read(subscriptionStateProvider.notifier).loadPlans();
  }

  /// Handle refresh
  Future<void> _onRefresh() async {
    await _loadPlans();
  }

  /// Handle billing cycle change
  void _onBillingCycleChanged(BillingCycle cycle) {
    ref.read(subscriptionStateProvider.notifier).setBillingCycle(cycle);
  }

  /// Handle plan selection
  void _onPlanSelected(PlanModel plan) {
    ref.read(subscriptionStateProvider.notifier).selectPlan(plan);

    // Handle free plan differently
    if (plan.isFree) {
      _showFreePlanDialog(plan);
      return;
    }

    // Navigate to checkout
    context.push('/subscription/checkout');
  }

  /// Show dialog for free plan selection
  void _showFreePlanDialog(PlanModel plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Switch to Free Plan',
          style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to switch to the Free plan?',
              style: SpendexTheme.bodyMedium.copyWith(color: textSecondary),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'You will lose access to premium features:',
              style: SpendexTheme.bodyMedium.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildLimitationItem('Unlimited transactions', textSecondary),
            _buildLimitationItem('Multiple accounts', textSecondary),
            _buildLimitationItem('AI-powered insights', textSecondary),
            _buildLimitationItem('Family sharing', textSecondary),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleFreePlanSelection();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SpendexColors.expense,
            ),
            child: const Text('Switch to Free'),
          ),
        ],
      ),
    );
  }

  /// Build limitation item for free plan dialog
  Widget _buildLimitationItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(
            Iconsax.close_circle,
            size: 16,
            color: SpendexColors.expense,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Text(
            text,
            style: SpendexTheme.bodySmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  /// Handle free plan selection
  Future<void> _handleFreePlanSelection() async {
    await ref.read(subscriptionStateProvider.notifier).downgradeToFree();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for success/error messages
    ref.listen<SubscriptionState>(subscriptionStateProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? ''),
            backgroundColor: SpendexColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionStateProvider.notifier).clearMessages();
      }

      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? ''),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionStateProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Plan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SpendexColors.primary,
        child: _buildBody(state, theme, isDark),
      ),
    );
  }

  Widget _buildBody(SubscriptionState state, ThemeData theme, bool isDark) {
    // Loading state
    if (state.isLoadingPlans && state.plans.isEmpty) {
      return const LoadingStateWidget(
        message: 'Loading plans...',
      );
    }

    // Error state
    if (state.error != null && state.plans.isEmpty) {
      return ErrorStateWidget(
        message: state.error ?? 'Failed to load plans',
        onRetry: _loadPlans,
      );
    }

    // Empty state
    if (state.plans.isEmpty) {
      return const EmptyStateWidget(
        icon: Iconsax.box_1,
        title: 'No Plans Available',
        subtitle: 'Please check back later for available subscription plans.',
      );
    }

    return _buildPlansContent(state, theme, isDark);
  }

  Widget _buildPlansContent(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    // Filter plans by selected billing cycle
    final filteredPlans = state.plans.where((plan) {
      return plan.billingCycle == state.selectedBillingCycle || plan.isFree;
    }).toList();

    // Get current plan ID
    final currentPlanId = state.currentSubscription?.planId;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Billing cycle toggle
          _buildBillingCycleToggle(state, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Savings indicator for yearly
          if (state.selectedBillingCycle == BillingCycle.yearly) _buildSavingsBanner(isDark),

          if (state.selectedBillingCycle == BillingCycle.yearly)
            const SizedBox(height: SpendexTheme.spacingLg),

          // Plans list
          ...filteredPlans.map((plan) {
            final isCurrentPlan = plan.id == currentPlanId;

            return Padding(
              padding: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
              child: PlanCard(
                plan: plan,
                billingCycle: state.selectedBillingCycle,
                isCurrentPlan: isCurrentPlan,
                onSelect: () => _onPlanSelected(plan),
              ),
            );
          }),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Feature comparison section
          _buildComparisonSection(state, textPrimary, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Money-back guarantee
          _buildGuaranteeSection(isDark),

          const SizedBox(height: SpendexTheme.spacing3xl),
        ],
      ),
    );
  }

  /// Build billing cycle toggle
  Widget _buildBillingCycleToggle(SubscriptionState state, bool isDark) {
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingXs),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildCycleOption(
              label: 'Monthly',
              cycle: BillingCycle.monthly,
              isSelected: state.selectedBillingCycle == BillingCycle.monthly,
              onTap: () => _onBillingCycleChanged(BillingCycle.monthly),
              textSecondary: textSecondary,
            ),
          ),
          Expanded(
            child: _buildCycleOption(
              label: 'Yearly',
              cycle: BillingCycle.yearly,
              isSelected: state.selectedBillingCycle == BillingCycle.yearly,
              onTap: () => _onBillingCycleChanged(BillingCycle.yearly),
              textSecondary: textSecondary,
              badge: 'Save 20%',
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual cycle option
  Widget _buildCycleOption({
    required String label,
    required BillingCycle cycle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textSecondary,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: SpendexTheme.spacingMd,
          horizontal: SpendexTheme.spacingLg,
        ),
        decoration: BoxDecoration(
          color: isSelected ? SpendexColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: SpendexTheme.titleMedium.copyWith(
                color: isSelected ? Colors.white : textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: SpendexTheme.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpendexTheme.spacingSm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
                ),
                child: Text(
                  badge,
                  style: SpendexTheme.labelSmall.copyWith(
                    color: isSelected ? Colors.white : SpendexColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build savings banner for yearly billing
  Widget _buildSavingsBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: SpendexColors.incomeGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingSm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: const Icon(
              Iconsax.discount_shape,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Save 20% with yearly billing',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Pay annually and get 2 months free',
                  style: SpendexTheme.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build feature comparison section
  Widget _buildComparisonSection(
    SubscriptionState state,
    Color textPrimary,
    bool isDark,
  ) {
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isComparisonExpanded = !_isComparisonExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(SpendexTheme.radiusLg),
              topRight: Radius.circular(SpendexTheme.radiusLg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpendexTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                    ),
                    child: const Icon(
                      Iconsax.diagram,
                      color: SpendexColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compare Features',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'See what each plan includes',
                          style: SpendexTheme.bodySmall.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isComparisonExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Iconsax.arrow_down_1,
                      color: textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comparison table
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(height: 1, color: borderColor),
                Padding(
                  padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                  child: PlanComparisonTable(plans: state.plans),
                ),
              ],
            ),
            crossFadeState:
                _isComparisonExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  /// Build money-back guarantee section
  Widget _buildGuaranteeSection(bool isDark) {
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Iconsax.shield_tick,
              color: SpendexColors.primary,
              size: 24,
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Text(
              '7-Day Money-Back Guarantee',
              style: SpendexTheme.titleMedium.copyWith(
                color: SpendexColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        Text(
          "Try any plan risk-free. If you're not satisfied within 7 days, we'll refund your payment.",
          textAlign: TextAlign.center,
          style: SpendexTheme.bodySmall.copyWith(
            color: textSecondary,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingLg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTrustBadge(Iconsax.lock_1, 'Secure Payment', textSecondary),
            const SizedBox(width: SpendexTheme.spacingXl),
            _buildTrustBadge(Iconsax.close_circle, 'Cancel Anytime', textSecondary),
            const SizedBox(width: SpendexTheme.spacingXl),
            _buildTrustBadge(Iconsax.headphone, '24/7 Support', textSecondary),
          ],
        ),
      ],
    );
  }

  /// Build trust badge
  Widget _buildTrustBadge(IconData icon, String label, Color textColor) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: textColor,
        ),
        const SizedBox(height: SpendexTheme.spacingXs),
        Text(
          label,
          style: SpendexTheme.labelSmall.copyWith(
            color: textColor,
          ),
        ),
      ],
    );
  }
}
