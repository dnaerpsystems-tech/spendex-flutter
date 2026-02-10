import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/budget_model.dart';
import '../providers/budgets_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_period_selector.dart';
import '../widgets/budget_summary_card.dart';

/// Budgets Screen
/// Displays all budgets with summary, filtering, and management options
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  BudgetPeriod? _selectedPeriod;
  BudgetStatus? _selectedStatus;
  String _sortBy = 'percentage'; // name, percentage, amount

  @override
  void initState() {
    super.initState();
    // Load budgets when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetsStateProvider.notifier).loadAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(budgetsStateProvider.notifier).loadAll();
  }

  List<BudgetModel> _filterAndSortBudgets(List<BudgetModel> budgets) {
    var filtered = budgets.toList();

    // Filter by period
    if (_selectedPeriod != null) {
      filtered = filtered.where((b) => b.period == _selectedPeriod).toList();
    }

    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered.where((b) => b.status == _selectedStatus).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'percentage':
        filtered.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case 'amount':
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
    }

    return filtered;
  }

  void _showSortOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort By',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                label: 'Percentage (High to Low)',
                icon: Iconsax.chart,
                isSelected: _sortBy == 'percentage',
                onTap: () {
                  setState(() => _sortBy = 'percentage');
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
              _SortOption(
                label: 'Name (A to Z)',
                icon: Iconsax.text,
                isSelected: _sortBy == 'name',
                onTap: () {
                  setState(() => _sortBy = 'name');
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
              _SortOption(
                label: 'Amount (High to Low)',
                icon: Iconsax.money,
                isSelected: _sortBy == 'amount',
                onTap: () {
                  setState(() => _sortBy = 'amount');
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetsState = ref.watch(budgetsStateProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Budgets'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: budgetsState.isLoading ? null : _refresh,
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
                child: _buildSummarySection(budgetsState),
              ),
            ),

            // Period Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Period',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetPeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() => _selectedPeriod = period);
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),

            // Status Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetStatusFilter(
                      selectedStatus: _selectedStatus,
                      onStatusChanged: (status) {
                        setState(() => _selectedStatus = status);
                      },
                      onTrackCount: budgetsState.onTrackBudgets.length,
                      warningCount: budgetsState.warningBudgets.length,
                      exceededCount: budgetsState.overBudgets.length,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),

            // Content based on loading state
            if (budgetsState.isLoading)
              _buildLoadingSkeleton()
            else if (budgetsState.error != null)
              _buildErrorState(budgetsState.error!)
            else
              _buildBudgetsList(budgetsState, isDark),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addBudget),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Budget'),
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSummarySection(BudgetsState state) {
    if (state.isSummaryLoading && state.summary == null) {
      return const BudgetSummaryLoadingSkeleton();
    }

    if (state.summary == null) {
      return const SizedBox.shrink();
    }

    return BudgetSummaryCard(summary: state.summary!);
  }

  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const BudgetCardSkeleton(),
          childCount: 4,
        ),
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
                'Failed to load budgets',
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

  Widget _buildBudgetsList(BudgetsState state, bool isDark) {
    final filteredBudgets = _filterAndSortBudgets(state.budgets);

    if (filteredBudgets.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final budget = filteredBudgets[index];
            return BudgetCard(
              budget: budget,
              compact: true,
              onTap: () => context.push('/budgets/${budget.id}'),
            );
          },
          childCount: filteredBudgets.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final hasFilters = _selectedPeriod != null || _selectedStatus != null;

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
                  hasFilters ? Iconsax.filter_search : Iconsax.wallet_3,
                  color: SpendexColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                hasFilters ? 'No Matching Budgets' : 'No Budgets Yet',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasFilters
                    ? 'Try adjusting your filters to see more results'
                    : 'Create your first budget to start tracking your spending',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (hasFilters)
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedPeriod = null;
                      _selectedStatus = null;
                    });
                  },
                  icon: const Icon(Iconsax.close_circle),
                  label: const Text('Clear Filters'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.addBudget),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Budget'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? SpendexColors.primary
            : isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
      ),
      title: Text(
        label,
        style: SpendexTheme.bodyMedium.copyWith(
          color: isSelected
              ? SpendexColors.primary
              : isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: isSelected
          ? const Icon(Iconsax.tick_circle, color: SpendexColors.primary)
          : null,
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
