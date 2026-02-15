import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/investment_model.dart';
import '../providers/investments_provider.dart';
import '../widgets/investment_card.dart';
import '../widgets/investment_summary_card.dart';
import '../widgets/portfolio_pie_chart.dart';

/// Portfolio Dashboard Screen that displays investment portfolio overview.
///
/// Features:
/// - Investment summary card with total invested, current value, returns
/// - Asset allocation pie chart
/// - Quick stats grid (best/worst performers, tax savings, mix)
/// - Recent investments list
/// - Pull-to-refresh
/// - Sync prices functionality
/// - Add investment FAB
class PortfolioDashboardScreen extends ConsumerStatefulWidget {
  const PortfolioDashboardScreen({super.key});

  @override
  ConsumerState<PortfolioDashboardScreen> createState() => _PortfolioDashboardScreenState();
}

class _PortfolioDashboardScreenState extends ConsumerState<PortfolioDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentsStateProvider.notifier).loadAll();
    });
  }

  Future<void> _handleRefresh() async {
    await ref.read(investmentsStateProvider.notifier).refresh();
  }

  Future<void> _handleSyncPrices() async {
    final success = await ref.read(investmentsStateProvider.notifier).syncPrices();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prices synced successfully'),
          backgroundColor: SpendexColors.income,
        ),
      );
    } else {
      final error = ref.read(investmentsErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to sync prices'),
          backgroundColor: SpendexColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentsStateProvider);
    final summary = ref.watch(investmentsSummaryProvider);
    final investments = ref.watch(investmentsListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        title: const Text('Portfolio'),
        centerTitle: true,
        actions: [
          if (state.isSyncing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Iconsax.refresh),
              onPressed: _handleSyncPrices,
              tooltip: 'Sync Prices',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _buildBody(state, summary, investments, theme, isDark),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/investments/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Investment'),
        backgroundColor: SpendexColors.primary,
      ),
    );
  }

  Widget _buildBody(
    InvestmentsState state,
    InvestmentSummary? summary,
    List<InvestmentModel> investments,
    ThemeData theme,
    bool isDark,
  ) {
    if (state.isLoading && investments.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummarySkeleton(isDark: isDark),
              const SizedBox(height: SpendexTheme.spacingXl),
              _ChartSkeleton(isDark: isDark),
              const SizedBox(height: SpendexTheme.spacingXl),
              _StatsSkeleton(isDark: isDark),
              const SizedBox(height: SpendexTheme.spacingXl),
              _CardSkeleton(isDark: isDark),
              const SizedBox(height: SpendexTheme.spacingMd),
              _CardSkeleton(isDark: isDark),
            ],
          ),
        ),
      );
    }

    if (state.error != null && investments.isEmpty) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(investmentsStateProvider.notifier).loadAll(),
      );
    }

    if (investments.isEmpty) {
      return EmptyStateWidget(
        icon: Iconsax.chart_square,
        title: 'No Investments Yet',
        subtitle: 'Start building your portfolio by adding your first investment',
        actionLabel: 'Add Investment',
        actionIcon: Icons.add,
        onAction: () => context.push('/investments/add'),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null) ...[
              InvestmentSummaryCard(summary: summary),
              const SizedBox(height: SpendexTheme.spacingXl),
            ],
            if (summary != null && summary.allocationByType.isNotEmpty) ...[
              _SectionHeader(
                title: 'Asset Allocation',
                theme: theme,
                isDark: isDark,
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              PortfolioPieChart(allocationByType: summary.allocationByType),
              const SizedBox(height: SpendexTheme.spacingXl),
            ],
            _SectionHeader(
              title: 'Quick Stats',
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            _buildQuickStats(investments, theme, isDark),
            const SizedBox(height: SpendexTheme.spacingXl),
            _SectionHeader(
              title: 'Recent Investments',
              theme: theme,
              isDark: isDark,
              actionLabel: 'View All',
              onAction: () => context.push('/investments/holdings'),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            _buildRecentInvestments(investments),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(
    List<InvestmentModel> investments,
    ThemeData theme,
    bool isDark,
  ) {
    final bestPerformer = investments.isEmpty
        ? null
        : investments.reduce(
            (curr, next) => curr.returnsPercent > next.returnsPercent ? curr : next,
          );

    final worstPerformer = investments.isEmpty
        ? null
        : investments.reduce(
            (curr, next) => curr.returnsPercent < next.returnsPercent ? curr : next,
          );

    final taxSavingInvestments = investments.where((i) => i.taxSaving).toList();
    final taxSavingsTotal = taxSavingInvestments.fold<int>(
      0,
      (sum, i) => sum + i.investedAmount,
    );

    final marketLinked = investments.where((i) => i.isMarketLinked).length;
    final fixedIncome = investments.length - marketLinked;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: SpendexTheme.spacingMd,
      mainAxisSpacing: SpendexTheme.spacingMd,
      childAspectRatio: 1.2,
      children: [
        _QuickStatCard(
          icon: Iconsax.trend_up,
          label: 'Best Performer',
          value: bestPerformer != null
              ? '${bestPerformer.returnsPercent >= 0 ? '+' : ''}${bestPerformer.returnsPercent.toStringAsFixed(2)}%'
              : 'N/A',
          subtitle: bestPerformer?.name,
          color: Colors.green,
          theme: theme,
          isDark: isDark,
        ),
        _QuickStatCard(
          icon: Iconsax.trend_down,
          label: 'Worst Performer',
          value: worstPerformer != null
              ? '${worstPerformer.returnsPercent >= 0 ? '+' : ''}${worstPerformer.returnsPercent.toStringAsFixed(2)}%'
              : 'N/A',
          subtitle: worstPerformer?.name,
          color: Colors.red,
          theme: theme,
          isDark: isDark,
        ),
        _QuickStatCard(
          icon: Iconsax.shield_tick,
          label: 'Tax Savings',
          value: '${taxSavingInvestments.length}',
          subtitle: CurrencyFormatter.formatPaise(
            taxSavingsTotal,
            decimalDigits: 0,
          ),
          color: Colors.orange,
          theme: theme,
          isDark: isDark,
        ),
        _QuickStatCard(
          icon: Iconsax.chart,
          label: 'Investment Mix',
          value: '$marketLinked / $fixedIncome',
          subtitle: 'Market / Fixed',
          color: Colors.blue,
          theme: theme,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRecentInvestments(List<InvestmentModel> investments) {
    final recentInvestments = investments.take(5).toList();

    return Column(
      children: recentInvestments.map((investment) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
          child: InvestmentCard(
            investment: investment,
            onTap: () => context.push('/investments/${investment.id}'),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.theme,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final ThemeData theme;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
    required this.isDark,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color color;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingMd),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingSm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: SpendexTheme.spacingXs),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SpendexTheme.spacingXs),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
      ),
    );
  }
}

class _ChartSkeleton extends StatelessWidget {
  const _ChartSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Row(
            children: [
              Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Container(
                width: 80,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: SpendexTheme.spacingMd,
        mainAxisSpacing: SpendexTheme.spacingMd,
        childAspectRatio: 1.2,
        children: List.generate(
          4,
          (index) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
      ),
    );
  }
}
