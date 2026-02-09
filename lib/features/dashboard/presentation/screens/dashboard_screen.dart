import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
                        child: Text(
                          user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: SpendexTheme.headlineMedium.copyWith(
                            color: SpendexColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
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
                      IconButton(
                        onPressed: () => context.push(AppRoutes.notifications),
                        icon: Badge(
                          smallSize: 8,
                          child: Icon(
                            Iconsax.notification,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Net Worth Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _NetWorthCard(
                    netWorth: 125000000, // Mock data in paise
                    change: 5.2,
                    currencyFormat: _currencyFormat,
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
                      Text(
                        'Quick Actions',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
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
                          ),
                          _QuickActionButton(
                            icon: Iconsax.arrow_swap_horizontal,
                            label: 'Transfer',
                            color: SpendexColors.transfer,
                            onTap: () {},
                          ),
                          _QuickActionButton(
                            icon: Iconsax.scan_barcode,
                            label: 'Scan',
                            color: SpendexColors.warning,
                            onTap: () {},
                          ),
                          _QuickActionButton(
                            icon: Iconsax.wallet_1,
                            label: 'Accounts',
                            color: SpendexColors.income,
                            onTap: () => context.push(AppRoutes.accounts),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Monthly Summary
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _MonthlySummaryCard(
                    income: 7500000, // Mock data
                    expense: 4500000,
                    currencyFormat: _currencyFormat,
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
                      Text(
                        'Recent Transactions',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.transactions),
                        child: Text(
                          'See All',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: SpendexColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Transactions List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transactions = _getMockTransactions();
                    if (index >= transactions.length) return null;
                    final transaction = transactions[index];
                    return _TransactionTile(
                      transaction: transaction,
                      currencyFormat: _currencyFormat,
                    );
                  },
                  childCount: 5,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Budget Alerts
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _BudgetAlertCard(),
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
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  List<Map<String, dynamic>> _getMockTransactions() {
    return [
      {
        'id': '1',
        'description': 'Grocery Shopping',
        'amount': -250000,
        'category': 'Food',
        'icon': Iconsax.shopping_cart,
        'date': DateTime.now(),
      },
      {
        'id': '2',
        'description': 'Salary Credit',
        'amount': 7500000,
        'category': 'Income',
        'icon': Iconsax.money_recive,
        'date': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'id': '3',
        'description': 'Netflix Subscription',
        'amount': -64900,
        'category': 'Entertainment',
        'icon': Iconsax.video,
        'date': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'id': '4',
        'description': 'Electricity Bill',
        'amount': -185000,
        'category': 'Utilities',
        'icon': Iconsax.flash,
        'date': DateTime.now().subtract(const Duration(days: 3)),
      },
      {
        'id': '5',
        'description': 'Freelance Project',
        'amount': 2500000,
        'category': 'Income',
        'icon': Iconsax.money_recive,
        'date': DateTime.now().subtract(const Duration(days: 4)),
      },
    ];
  }
}

class _NetWorthCard extends StatelessWidget {
  final int netWorth;
  final double change;
  final NumberFormat currencyFormat;

  const _NetWorthCard({
    required this.netWorth,
    required this.change,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = change >= 0;

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Worth',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Iconsax.arrow_up_3 : Iconsax.arrow_down,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${change.abs()}%',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currencyFormat.format(netWorth / 100),
            style: SpendexTheme.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _NetWorthItem(
                label: 'Assets',
                value: currencyFormat.format(150000000 / 100),
              ),
              const SizedBox(width: 32),
              _NetWorthItem(
                label: 'Liabilities',
                value: currencyFormat.format(25000000 / 100),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetWorthItem extends StatelessWidget {
  final String label;
  final String value;

  const _NetWorthItem({required this.label, required this.value});

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
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  final int income;
  final int expense;
  final NumberFormat currencyFormat;

  const _MonthlySummaryCard({
    required this.income,
    required this.expense,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savings = income - expense;
    final savingsRate = income > 0 ? (savings / income) * 100 : 0;

    return Container(
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
                  value: currencyFormat.format(income / 100),
                  color: SpendexColors.income,
                  icon: Iconsax.arrow_down,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SummaryItem(
                  label: 'Expense',
                  value: currencyFormat.format(expense / 100),
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
                    currencyFormat.format(savings / 100),
                    style: SpendexTheme.titleMedium.copyWith(
                      color: savings >= 0
                          ? SpendexColors.income
                          : SpendexColors.expense,
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
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

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
        Column(
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
            ),
          ],
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final NumberFormat currencyFormat;

  const _TransactionTile({
    required this.transaction,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amount = transaction['amount'] as int;
    final isExpense = amount < 0;

    return Container(
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
              color: (isExpense ? SpendexColors.expense : SpendexColors.income)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                transaction['icon'] as IconData,
                color: isExpense ? SpendexColors.expense : SpendexColors.income,
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
                  transaction['description'] as String,
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction['category'] as String,
                  style: SpendexTheme.labelMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}${currencyFormat.format(amount.abs() / 100)}',
            style: SpendexTheme.titleMedium.copyWith(
              color: isExpense ? SpendexColors.expense : SpendexColors.income,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetAlertCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpendexColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SpendexColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SpendexColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Iconsax.warning_2,
                color: SpendexColors.warning,
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
                  'Budget Alert',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You\'ve used 85% of your Food budget this month',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Iconsax.arrow_right_3,
            color: SpendexColors.warning,
            size: 20,
          ),
        ],
      ),
    );
  }
}
