import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../insights/presentation/providers/insights_provider.dart';
import '../../../insights/presentation/widgets/insights_dashboard_widget.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Log screen view
      AnalyticsService.logScreenView(screenName: AnalyticsEvents.screenDashboard);
      ref.read(dashboardStateProvider.notifier).loadAll();
      ref.read(insightsStateProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final dashboardState = ref.watch(dashboardStateProvider);
    final accountsSummary = ref.watch(accountsSummaryProvider);
    final monthlyStats = ref.watch(monthlyStatsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final budgetAlerts = ref.watch(budgetAlertsProvider);
    final error = ref.watch(dashboardErrorProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(dashboardStateProvider.notifier).refresh();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar with semantics
                      Semantics(
                        label: 'User profile picture for ${user?.name ?? 'User'}',
                        image: true,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: SpendexTheme.headlineMedium.copyWith(
                              color: SpendexColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Semantics(
                          label: 'Good ${_getGreeting()}, ${user?.name ?? 'User'}',
                          header: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good ${_getGreeting()}',
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                user?.name ?? 'User',
                                style: SpendexTheme.headlineMedium.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'Notifications',
                        hint: 'Double tap to view notifications',
                        button: true,
                        child: IconButton(
                          onPressed: () => context.push(AppRoutes.notifications),
                          icon: Badge(
                            smallSize: 8,
                            child: Icon(
                              Iconsax.notification,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Error Banner
              if (error != null)
                SliverToBoxAdapter(
                  child: Semantics(
                    label: 'Error: $error',
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MaterialBanner(
                        content: Text(error),
                        backgroundColor: SpendexColors.expense.withValues(alpha: 0.1),
                        actions: [
                          Semantics(
                            label: 'Dismiss error',
                            button: true,
                            child: TextButton(
                              onPressed: () {
                                ref.read(dashboardStateProvider.notifier).clearError();
                              },
                              child: const Text('Dismiss'),
                            ),
                          ),
                          Semantics(
                            label: 'Retry loading data',
                            button: true,
                            child: TextButton(
                              onPressed: () {
                                ref.read(dashboardStateProvider.notifier).refresh();
                              },
                              child: const Text('Retry'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Net Worth Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: dashboardState.isSummaryLoading && accountsSummary == null
                      ? const ShimmerLoadingList(
                          itemCount: 1,
                          itemHeight: 180,
                          padding: EdgeInsets.zero,
                        )
                      : _NetWorthCard(
                          netWorth: accountsSummary?.netWorth ?? 0,
                          totalAssets: accountsSummary?.totalAssets ?? 0,
                          totalLiabilities: accountsSummary?.totalLiabilities ?? 0,
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Quick Actions',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _QuickActionButton(
                            icon: Iconsax.add_circle,
                            label: 'Add',
                            color: SpendexColors.primary,
                            onTap: () => context.go(AppRoutes.addTransaction),
                            semanticLabel: 'Add new transaction',
                          ),
                          _QuickActionButton(
                            icon: Iconsax.arrow_swap_horizontal,
                            label: 'Transfer',
                            color: SpendexColors.transfer,
                            onTap: () {},
                            semanticLabel: 'Transfer money between accounts',
                          ),
                          _QuickActionButton(
                            icon: Iconsax.scan_barcode,
                            label: 'Scan',
                            color: SpendexColors.warning,
                            onTap: () {},
                            semanticLabel: 'Scan receipt or barcode',
                          ),
                          _QuickActionButton(
                            icon: Iconsax.wallet_1,
                            label: 'Accounts',
                            color: SpendexColors.income,
                            onTap: () => context.push(AppRoutes.accounts),
                            semanticLabel: 'View all accounts',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // AI Insights Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer(
                    builder: (context, ref, _) {
                      final dashboardInsights = ref.watch(dashboardInsightsProvider);
                      final isLoading = ref.watch(insightsLoadingProvider);
                      final error = ref.watch(insightsErrorProvider);

                      return InsightsDashboardWidget(
                        insights: dashboardInsights,
                        isLoading: isLoading,
                        error: error,
                        onViewAllTap: () => context.push(AppRoutes.insights),
                        onInsightTap: (insight) => context.push('/insights/${insight.id}'),
                        onDismiss: (id) => ref.read(insightsStateProvider.notifier).dismiss(id),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Monthly Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: dashboardState.isStatsLoading && monthlyStats == null
                      ? const ShimmerLoadingList(
                          itemCount: 1,
                          itemHeight: 160,
                          padding: EdgeInsets.zero,
                        )
                      : _MonthlySummaryCard(
                          income: monthlyStats?.totalIncome ?? 0,
                          expense: monthlyStats?.totalExpense ?? 0,
                          savingsRate: monthlyStats?.savingsRate ?? 0,
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Recent Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Recent Transactions',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Semantics(
                        label: 'See all transactions',
                        button: true,
                        child: TextButton(
                          onPressed: () => context.go(AppRoutes.transactions),
                          child: Text(
                            'See All',
                            style: SpendexTheme.labelMedium.copyWith(
                              color: SpendexColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Recent Transactions List
              if (dashboardState.isTransactionsLoading && recentTransactions.isEmpty)
                const SliverToBoxAdapter(
                  child: ShimmerLoadingList(
                    itemCount: 3,
                    itemHeight: 72,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ),
                )
              else if (recentTransactions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Semantics(
                      label: 'No transactions yet. Add your first transaction to get started.',
                      child: Center(
                        child: Column(
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                Iconsax.receipt_item,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add your first transaction to get started',
                              style: SpendexTheme.labelMedium.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final transaction = recentTransactions[index];
                      return _TransactionTile(transaction: transaction);
                    },
                    childCount: recentTransactions.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              // Budget Alerts
              if (dashboardState.isBudgetsLoading && budgetAlerts.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ShimmerLoadingList(
                      itemCount: 1,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
              else if (budgetAlerts.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final budget = budgetAlerts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
                          bottom: index < budgetAlerts.length - 1 ? 12 : 0,
                        ),
                        child: _BudgetAlertCard(budget: budget),
                      );
                    },
                    childCount: budgetAlerts.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}

class _NetWorthCard extends StatelessWidget {
  const _NetWorthCard({
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
  });

  final int netWorth;
  final int totalAssets;
  final int totalLiabilities;

  String _buildSemanticLabel() {
    final netWorthStr = CurrencyFormatter.formatPaise(netWorth, decimalDigits: 0);
    final assetsStr = CurrencyFormatter.formatPaise(totalAssets, decimalDigits: 0);
    final liabilitiesStr = CurrencyFormatter.formatPaise(totalLiabilities, decimalDigits: 0);
    return 'Net Worth: $netWorthStr. Total Assets: $assetsStr. Total Liabilities: $liabilitiesStr';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _buildSemanticLabel(),
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: SpendexColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: SpendexColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net Worth',
              style: SpendexTheme.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              CurrencyFormatter.formatPaise(netWorth, decimalDigits: 0),
              style: SpendexTheme.displayLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _NetWorthItem(
                    label: 'Assets',
                    value: CurrencyFormatter.formatPaise(totalAssets, decimalDigits: 0),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _NetWorthItem(
                    label: 'Liabilities',
                    value: CurrencyFormatter.formatPaise(totalLiabilities, decimalDigits: 0),
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

class _NetWorthItem extends StatelessWidget {
  const _NetWorthItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: SpendexTheme.titleMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.savingsRate,
  });

  final int income;
  final int expense;
  final double savingsRate;

  String _buildSemanticLabel() {
    final savings = income - expense;
    final incomeStr = CurrencyFormatter.formatPaise(income, decimalDigits: 0);
    final expenseStr = CurrencyFormatter.formatPaise(expense, decimalDigits: 0);
    final savingsStr = CurrencyFormatter.formatPaise(savings, decimalDigits: 0);
    return 'This month summary. Income: $incomeStr. Expense: $expenseStr. Savings: $savingsStr, ${savingsRate.toStringAsFixed(0)}% saved.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savings = income - expense;

    return Semantics(
      label: _buildSemanticLabel(),
      container: true,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Month',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Income',
                    value: CurrencyFormatter.formatPaise(
                      income,
                      decimalDigits: 0,
                    ),
                    color: SpendexColors.income,
                    icon: Iconsax.arrow_down,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryItem(
                    label: 'Expense',
                    value: CurrencyFormatter.formatPaise(
                      expense,
                      decimalDigits: 0,
                    ),
                    color: SpendexColors.expense,
                    icon: Iconsax.arrow_up_3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Savings',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatPaise(
                        savings,
                        decimalDigits: 0,
                      ),
                      style: SpendexTheme.titleMedium.copyWith(
                        color: savings >= 0 ? SpendexColors.income : SpendexColors.expense,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${savingsRate.toStringAsFixed(0)}% saved',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(icon, color: color, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SpendexTheme.labelMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: SpendexTheme.titleMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
  });

  final TransactionModel transaction;

  IconData _getTransactionIcon() {
    if (transaction.type == TransactionType.transfer) {
      return Iconsax.arrow_swap_horizontal;
    }
    if (transaction.type == TransactionType.income) {
      return Iconsax.money_recive;
    }
    return Iconsax.money_send;
  }

  Color _getTransactionColor() {
    if (transaction.type == TransactionType.transfer) {
      return SpendexColors.transfer;
    }
    if (transaction.type == TransactionType.income) {
      return SpendexColors.income;
    }
    return SpendexColors.expense;
  }

  String _buildSemanticLabel() {
    final description = transaction.description ?? 'Transaction';
    final category = transaction.category?.name ?? transaction.type.label;
    final amount = CurrencyFormatter.formatPaise(transaction.amount, decimalDigits: 0);
    final prefix = transaction.isExpense ? 'expense' : 'income';
    return '$description, $category, $prefix of $amount';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.isExpense;
    final color = _getTransactionColor();

    return Semantics(
      label: _buildSemanticLabel(),
      container: true,
      excludeSemantics: true,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  _getTransactionIcon(),
                  color: color,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? 'Transaction',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category?.name ?? transaction.type.label,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'}${CurrencyFormatter.formatPaise(transaction.amount, decimalDigits: 0)}',
              style: SpendexTheme.titleMedium.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetAlertCard extends StatelessWidget {
  const _BudgetAlertCard({required this.budget});

  final BudgetModel budget;

  String _buildSemanticLabel() {
    final isExceeded = budget.percentage >= 100;
    final alertType = isExceeded ? 'Budget Exceeded' : 'Budget Alert';
    return "$alertType: You've used ${budget.percentage.toStringAsFixed(0)}% of your ${budget.name} budget";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExceeded = budget.percentage >= 100;
    final alertColor = isExceeded ? SpendexColors.expense : SpendexColors.warning;

    return Semantics(
      label: _buildSemanticLabel(),
      container: true,
      liveRegion: isExceeded,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: alertColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alertColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  isExceeded ? Iconsax.danger : Iconsax.warning_2,
                  color: alertColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExceeded ? 'Budget Exceeded' : 'Budget Alert',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: alertColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "You've used ${budget.percentage.toStringAsFixed(0)}% of your ${budget.name} budget",
                    style: SpendexTheme.bodyMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: alertColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
