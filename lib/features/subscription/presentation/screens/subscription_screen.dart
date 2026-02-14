import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscription_provider.dart';
import '../widgets/widgets.dart';

/// Subscription Screen
///
/// Main subscription management screen that displays:
/// - Current subscription status and plan details
/// - Usage overview with progress indicators
/// - Quick actions for upgrade, invoices, and cancellation
/// - Billing information and payment methods
///
/// For users without a subscription, displays plan comparison with trial CTA.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  static const String routeName = 'subscription';
  static const String routePath = '/subscription';

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSubscriptionData();
    });
  }

  /// Load all subscription-related data
  Future<void> _loadSubscriptionData() async {
    final notifier = ref.read(subscriptionProvider.notifier);
    await Future.wait([
      notifier.loadSubscription(),
      notifier.loadPlans(),
      notifier.loadUsage(),
      notifier.loadPaymentMethods(),
    ]);
  }

  /// Handle refresh action
  Future<void> _onRefresh() async {
    await _loadSubscriptionData();
  }

  /// Navigate to plans screen for upgrade/downgrade
  void _navigateToPlans() {
    context.push('/subscription/plans');
  }

  /// Navigate to invoices screen
  void _navigateToInvoices() {
    context.push('/subscription/invoices');
  }

  /// Show cancel subscription bottom sheet
  void _showCancelSheet() {
    final subscription = ref.read(subscriptionProvider).currentSubscription;
    if (subscription == null) return;

    showCancelSubscriptionSheet(
      context: context,
      subscription: subscription,
      onCancel: (cancelAtPeriodEnd, reason, feedback) async {
        await ref.read(subscriptionProvider.notifier).cancelSubscription(
              cancelAtPeriodEnd: cancelAtPeriodEnd,
              reason: reason,
              feedback: feedback,
            );
      },
    );
  }

  /// Resume a cancelled subscription
  Future<void> _resumeSubscription() async {
    await ref.read(subscriptionProvider.notifier).resumeSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listen for success/error messages
    ref.listen<SubscriptionState>(subscriptionProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? ''),
            backgroundColor: SpendexColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearMessages();
      }

      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? ''),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        centerTitle: true,
        actions: [
          if (state.hasActiveSubscription)
            IconButton(
              icon: const Icon(Iconsax.receipt_1),
              onPressed: _navigateToInvoices,
              tooltip: 'View Invoices',
            ),
        ],
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
    if (state.isLoadingSubscription && state.currentSubscription == null) {
      return const LoadingStateWidget(
        message: 'Loading subscription...',
      );
    }

    // Error state
    if (state.error != null &&
        state.currentSubscription == null &&
        state.plans.isEmpty) {
      return ErrorStateWidget(
        message: state.error ?? 'An error occurred',
        onRetry: _loadSubscriptionData,
      );
    }

    // No subscription - show plans comparison
    if (!state.hasActiveSubscription) {
      return _buildNoSubscriptionView(state, theme, isDark);
    }

    // Has subscription - show management view
    return _buildSubscriptionView(state, theme, isDark);
  }

  /// Build view for users without an active subscription
  Widget _buildNoSubscriptionView(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header illustration
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
            decoration: BoxDecoration(
              gradient: SpendexColors.primaryGradient,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpendexTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Iconsax.crown_1,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingLg),
                Text(
                  'Unlock Premium Features',
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpendexTheme.spacingSm),
                Text(
                  'Get unlimited access to all features and take control of your finances',
                  textAlign: TextAlign.center,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Plans section title
          Text(
            'Choose Your Plan',
            style: SpendexTheme.headlineSmall.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),

          const SizedBox(height: SpendexTheme.spacingLg),

          // Plans list
          if (state.isLoadingPlans)
            ...List.generate(
              3,
              (_) => const Padding(
                padding: EdgeInsets.only(bottom: SpendexTheme.spacingMd),
                child: PlanCardSkeleton(),
              ),
            )
          else if (state.plans.isEmpty)
            const EmptyStateWidget(
              icon: Iconsax.box_1,
              title: 'No Plans Available',
              message: 'Please try again later.',
            )
          else
            ...state.plans.map(
              (plan) => Padding(
                padding: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
                child: PlanCard(
                  plan: plan,
                  isSelected: false,
                  isCurrentPlan: false,
                  onSelect: () {
                    ref.read(subscriptionProvider.notifier).selectPlan(plan);
                    _navigateToPlans();
                  },
                ),
              ),
            ),

          const SizedBox(height: SpendexTheme.spacingLg),

          // Feature comparison
          if (state.plans.isNotEmpty) ...[
            Text(
              'Compare Features',
              style: SpendexTheme.headlineSmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            PlanComparisonTable(plans: state.plans),
          ],

          const SizedBox(height: SpendexTheme.spacing3xl),

          // Start trial CTA
          _buildTrialCTA(theme, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),
        ],
      ),
    );
  }

  /// Build view for users with an active subscription
  Widget _buildSubscriptionView(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final subscription = state.currentSubscription;
    if (subscription == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current plan card
          _buildCurrentPlanCard(subscription, state, theme, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Usage overview section
          _buildUsageSection(state, theme, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Quick actions
          _buildQuickActions(state, theme, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Billing info section
          _buildBillingSection(subscription, theme, isDark),

          const SizedBox(height: SpendexTheme.spacing2xl),

          // Payment method section
          _buildPaymentMethodSection(state, theme, isDark),

          const SizedBox(height: SpendexTheme.spacing3xl),
        ],
      ),
    );
  }

  /// Build current plan card with status
  Widget _buildCurrentPlanCard(
    SubscriptionModel subscription,
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final plan = subscription.plan;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            decoration: const BoxDecoration(
              gradient: SpendexColors.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SpendexTheme.radiusXl),
                topRight: Radius.circular(SpendexTheme.radiusXl),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                  child: const Icon(
                    Iconsax.crown_1,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: SpendexTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan?.name ?? 'Premium',
                        style: SpendexTheme.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subscription.plan?.billingCycle.label ?? 'Monthly',
                        style: SpendexTheme.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                SubscriptionStatusBadge(status: subscription.status),
              ],
            ),
          ),

          // Plan details
          Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${plan?.priceInRupees.toStringAsFixed(0) ?? '0'}',
                      style: SpendexTheme.displayLarge.copyWith(
                        color: textPrimary,
                        fontSize: 36,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '/${plan?.billingCycle.label.toLowerCase() ?? 'month'}',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: SpendexTheme.spacingLg),

                // Status message
                Container(
                  padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(subscription),
                    borderRadius:
                        BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(subscription),
                        size: 20,
                        color: _getStatusColor(subscription),
                      ),
                      const SizedBox(width: SpendexTheme.spacingSm),
                      Expanded(
                        child: Text(
                          subscription.statusMessage,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: _getStatusColor(subscription),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Period progress
                if (subscription.isValid) ...[
                  const SizedBox(height: SpendexTheme.spacingLg),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Billing Period',
                            style: SpendexTheme.labelMedium.copyWith(
                              color: textSecondary,
                            ),
                          ),
                          Text(
                            '${subscription.periodProgressPercentage.toStringAsFixed(0)}%',
                            style: SpendexTheme.labelMedium.copyWith(
                              color: SpendexColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpendexTheme.spacingSm),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                        child: LinearProgressIndicator(
                          value: subscription.periodProgressPercentage / 100,
                          backgroundColor: borderColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            SpendexColors.primary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build usage overview section
  Widget _buildUsageSection(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage Overview',
              style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
            ),
            if (state.usage != null)
              Text(
                '${state.usage?.daysRemainingInPeriod ?? 0} days left',
                style: SpendexTheme.labelMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        if (state.isLoadingUsage)
          ...List.generate(
            4,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: SpendexTheme.spacingSm),
              child: UsageProgressCardSkeleton(),
            ),
          )
        else if (state.usage == null)
          const EmptyStateWidget(
            icon: Iconsax.chart_1,
            title: 'No Usage Data',
            message: 'Usage statistics will appear here.',
            compact: true,
          )
        else
          _buildUsageCards(state.usage),
      ],
    );
  }

  /// Build usage progress cards
  Widget _buildUsageCards(UsageModel? usage) {
    if (usage == null) return const SizedBox.shrink();

    return Column(
      children: [
        UsageProgressCard(
          icon: Iconsax.receipt_2,
          label: 'Transactions',
          used: usage.transactionsUsed,
          limit: usage.limits.transactions,
          isUnlimited: usage.limits.hasUnlimitedTransactions,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        UsageProgressCard(
          icon: Iconsax.wallet_3,
          label: 'Accounts',
          used: usage.accountsUsed,
          limit: usage.limits.accounts,
          isUnlimited: usage.limits.hasUnlimitedAccounts,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        UsageProgressCard(
          icon: Iconsax.money_send,
          label: 'Budgets',
          used: usage.budgetsUsed,
          limit: usage.limits.budgets,
          isUnlimited: usage.limits.hasUnlimitedBudgets,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        UsageProgressCard(
          icon: Iconsax.flag,
          label: 'Goals',
          used: usage.goalsUsed,
          limit: usage.limits.goals,
          isUnlimited: usage.limits.hasUnlimitedGoals,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        UsageProgressCard(
          icon: Iconsax.people,
          label: 'Family Members',
          used: usage.familyMembersUsed,
          limit: usage.limits.familyMembers,
          isUnlimited: usage.limits.hasUnlimitedFamilyMembers,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        UsageProgressCard(
          icon: Iconsax.magic_star,
          label: 'AI Insights',
          used: usage.aiInsightsUsed,
          limit: usage.limits.aiInsights,
          isUnlimited: usage.limits.hasUnlimitedAiInsights,
        ),
      ],
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              // Upgrade/Change Plan
              _buildActionTile(
                icon: Iconsax.arrow_up_3,
                iconColor: SpendexColors.primary,
                title: 'Change Plan',
                subtitle: 'Upgrade or downgrade your subscription',
                onTap: _navigateToPlans,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              Divider(height: 1, color: borderColor),

              // View Invoices
              _buildActionTile(
                icon: Iconsax.receipt_1,
                iconColor: SpendexColors.transfer,
                title: 'View Invoices',
                subtitle: 'Download and manage your invoices',
                onTap: _navigateToInvoices,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              Divider(height: 1, color: borderColor),

              // Cancel or Resume
              if (state.canResume)
                _buildActionTile(
                  icon: Iconsax.refresh,
                  iconColor: SpendexColors.income,
                  title: 'Resume Subscription',
                  subtitle: 'Reactivate your cancelled subscription',
                  onTap: _resumeSubscription,
                  isLoading: state.isResuming,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                )
              else if (state.canCancel)
                _buildActionTile(
                  icon: Iconsax.close_circle,
                  iconColor: SpendexColors.expense,
                  title: 'Cancel Subscription',
                  subtitle: 'Cancel your subscription',
                  onTap: _showCancelSheet,
                  isLoading: state.isCancelling,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build billing info section
  Widget _buildBillingSection(
    SubscriptionModel subscription,
    ThemeData theme,
    bool isDark,
  ) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Information',
          style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Container(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Current Period Start',
                _formatDate(subscription.currentPeriodStart),
                textPrimary,
                textSecondary,
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildInfoRow(
                'Current Period End',
                _formatDate(subscription.currentPeriodEnd),
                textPrimary,
                textSecondary,
              ),
              if (subscription.isTrialing && subscription.trialEnd != null) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                _buildInfoRow(
                  'Trial Ends',
                  _formatDate(subscription.trialEnd ?? DateTime.now()),
                  textPrimary,
                  SpendexColors.warning,
                ),
              ],
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildInfoRow(
                'Next Billing Date',
                subscription.cancelAtPeriodEnd
                    ? 'Cancelled'
                    : _formatDate(subscription.currentPeriodEnd),
                textPrimary,
                subscription.cancelAtPeriodEnd
                    ? SpendexColors.expense
                    : textSecondary,
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildInfoRow(
                'Auto Renewal',
                subscription.willRenew ? 'Enabled' : 'Disabled',
                textPrimary,
                subscription.willRenew
                    ? SpendexColors.income
                    : SpendexColors.expense,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build payment method section
  Widget _buildPaymentMethodSection(
    SubscriptionState state,
    ThemeData theme,
    bool isDark,
  ) {
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Method',
              style: SpendexTheme.headlineSmall.copyWith(color: textPrimary),
            ),
            TextButton.icon(
              onPressed: () {
                // Navigate to manage payment methods
                context.push('/subscription/payment-methods');
              },
              icon: const Icon(Iconsax.add, size: 18),
              label: const Text('Manage'),
              style: TextButton.styleFrom(
                foregroundColor: SpendexColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        if (state.isLoadingPaymentMethods)
          const PaymentMethodCardSkeleton()
        else if (state.defaultPaymentMethod != null)
          PaymentMethodCard(
            paymentMethod: state.defaultPaymentMethod,
            isSelected: true,
            onTap: () {
              showPaymentMethodSelector(
                context: context,
                paymentMethods: state.paymentMethods,
                selectedMethod: state.defaultPaymentMethod,
                onSelect: (method) {
                  ref
                      .read(subscriptionProvider.notifier)
                      .setDefaultPaymentMethod(method.id);
                },
              );
            },
          )
        else
          _buildAddPaymentMethodCard(isDark),
      ],
    );
  }

  /// Build add payment method card
  Widget _buildAddPaymentMethodCard(bool isDark) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return InkWell(
      onTap: () => context.push('/subscription/payment-methods/add'),
      borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingMd),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: const Icon(
                Iconsax.add_circle,
                color: SpendexColors.primary,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Payment Method',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: SpendexColors.primary,
                    ),
                  ),
                  Text(
                    'Add a card or UPI for automatic payments',
                    style: SpendexTheme.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Build trial CTA button
  Widget _buildTrialCTA(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Start Your Free Trial',
            style: SpendexTheme.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          Text(
            '7 days free, then ₹199/month. Cancel anytime.',
            style: SpendexTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToPlans,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: SpendexColors.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: SpendexTheme.spacingMd,
                ),
              ),
              child: const Text('Start Free Trial'),
            ),
          ),
        ],
      ),
    );
  }

  /// Build action tile widget
  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color textPrimary,
    required Color textSecondary,
    bool isLoading = false,
  }) {
    return ListTile(
      onTap: isLoading ? null : onTap,
      leading: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingSm),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: SpendexTheme.titleMedium.copyWith(color: textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: SpendexTheme.bodySmall.copyWith(color: textSecondary),
      ),
      trailing: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Iconsax.arrow_right_3,
              color: textSecondary,
              size: 18,
            ),
    );
  }

  /// Build info row for billing section
  Widget _buildInfoRow(
    String label,
    String value,
    Color textPrimary,
    Color valueColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: SpendexTheme.bodyMedium.copyWith(
            color: textPrimary.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: SpendexTheme.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Get status background color
  Color _getStatusBackgroundColor(SubscriptionModel subscription) {
    if (subscription.isTrialing || subscription.isTrialEnding) {
      return SpendexColors.warning.withValues(alpha: 0.1);
    }
    if (subscription.cancelAtPeriodEnd || subscription.isCancelled) {
      return SpendexColors.expense.withValues(alpha: 0.1);
    }
    if (subscription.isPastDue) {
      return SpendexColors.expense.withValues(alpha: 0.1);
    }
    return SpendexColors.income.withValues(alpha: 0.1);
  }

  /// Get status color
  Color _getStatusColor(SubscriptionModel subscription) {
    if (subscription.isTrialing || subscription.isTrialEnding) {
      return SpendexColors.warning;
    }
    if (subscription.cancelAtPeriodEnd || subscription.isCancelled) {
      return SpendexColors.expense;
    }
    if (subscription.isPastDue) {
      return SpendexColors.expense;
    }
    return SpendexColors.income;
  }

  /// Get status icon
  IconData _getStatusIcon(SubscriptionModel subscription) {
    if (subscription.isTrialing) {
      return Iconsax.timer_1;
    }
    if (subscription.cancelAtPeriodEnd) {
      return Iconsax.warning_2;
    }
    if (subscription.isPastDue) {
      return Iconsax.danger;
    }
    if (subscription.isActive) {
      return Iconsax.tick_circle;
    }
    return Iconsax.info_circle;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
