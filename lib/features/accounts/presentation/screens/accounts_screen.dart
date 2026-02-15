import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/account_model.dart';
import '../providers/accounts_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/account_summary_card.dart';

/// Accounts Screen
/// Displays all accounts with summary, filtering, and management options
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AccountType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load accounts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountsStateProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(accountsStateProvider.notifier).loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsState = ref.watch(accountsStateProvider);

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Accounts'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: accountsState.isLoading ? null : _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: SpendexColors.primary,
        child: CustomScrollView(
          slivers: [
            // Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildSummarySection(accountsState),
              ),
            ),

            // Tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabs(isDark),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Content based on tab and loading state
            if (accountsState.isLoading)
              _buildLoadingSkeleton()
            else if (accountsState.error != null)
              _buildErrorState(accountsState.error!)
            else
              _buildAccountsList(accountsState, isDark),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addAccount),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Account'),
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummarySection(AccountsState state) {
    if (state.isSummaryLoading && state.summary == null) {
      return const AccountSummaryLoadingSkeleton();
    }

    if (state.summary == null) {
      return const SizedBox.shrink();
    }

    return AccountSummaryCard(summary: state.summary!);
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: SpendexColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
        labelStyle: SpendexTheme.titleMedium,
        unselectedLabelStyle: SpendexTheme.titleMedium,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Assets'),
          Tab(text: 'Liabilities'),
        ],
        onTap: (index) {
          setState(() {
            _selectedFilter = null;
          });
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildAccountLoadingSkeleton(),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildAccountLoadingSkeleton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final shimmerHighlight =
        isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [shimmerBase, shimmerHighlight],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: shimmerHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: shimmerHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: shimmerHighlight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: shimmerHighlight,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SpendexColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Iconsax.warning_2,
                  color: SpendexColors.expense,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to load accounts',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountsList(AccountsState state, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        List<AccountModel> accounts;

        switch (_tabController.index) {
          case 0:
            accounts = state.accounts;
            break;
          case 1:
            accounts = state.assetAccounts;
            break;
          case 2:
            accounts = state.liabilityAccounts;
            break;
          default:
            accounts = state.accounts;
        }

        // Apply filter if selected
        if (_selectedFilter != null) {
          accounts = accounts.where((a) => a.type == _selectedFilter).toList();
        }

        if (accounts.isEmpty) {
          return _buildEmptyState(_tabController.index);
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final account = accounts[index];
                return AccountCard(
                  account: account,
                  compact: true,
                  onTap: () {
                    context.push('/accounts/${account.id}');
                  },
                );
              },
              childCount: accounts.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;

    switch (tabIndex) {
      case 1:
        title = 'No Asset Accounts';
        subtitle = 'Add a savings, current, or cash account to get started';
        icon = Iconsax.wallet_add;
        break;
      case 2:
        title = 'No Liability Accounts';
        subtitle = 'Add a credit card or loan account to track your debts';
        icon = Iconsax.card_add;
        break;
      default:
        title = 'No Accounts Yet';
        subtitle = 'Add your first account to start tracking your finances';
        icon = Iconsax.bank;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: SpendexColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.addAccount),
                icon: const Icon(Iconsax.add),
                label: const Text('Add Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
