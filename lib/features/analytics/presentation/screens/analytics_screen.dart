import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../providers/analytics_provider.dart';
import '../../data/models/net_worth_model.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/analytics_summary_model.dart';
import '../../data/models/monthly_stats_model.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsStateProvider.notifier).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(analyticsStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
        actions: [
          _DateRangeChip(isDark: isDark),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(analyticsStateProvider.notifier).refresh(),
        color: SpendexColors.primary,
        child: _buildBody(state, isDark),
      ),
    );
  }

  Widget _buildBody(AnalyticsState state, bool isDark) {
    if (state.isLoading && state.summary == null) {
      return const LoadingStateWidget(message: 'Loading analytics...');
    }

    if (state.error != null && state.summary == null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(analyticsStateProvider.notifier).loadAnalytics(),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TabBar(isDark: isDark),
          const SizedBox(height: 16),
          _buildTabContent(state, isDark),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
        ],
      ),
    );
  }

  Widget _buildTabContent(AnalyticsState state, bool isDark) {
    switch (state.currentTab) {
      case AnalyticsTab.overview:
        return _OverviewContent(state: state, isDark: isDark);
      case AnalyticsTab.income:
        return _CategoryContent(state: state, isDark: isDark, isExpense: false);
      case AnalyticsTab.expense:
        return _CategoryContent(state: state, isDark: isDark, isExpense: true);
      case AnalyticsTab.trends:
        return _TrendsContent(state: state, isDark: isDark);
      case AnalyticsTab.netWorth:
        return _NetWorthContent(state: state, isDark: isDark);
    }
  }
}

class _DateRangeChip extends ConsumerWidget {
  const _DateRangeChip({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(analyticsDateRangePresetProvider);

    return GestureDetector(
      onTap: () => _showPresetPicker(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.calendar_1, size: 16, color: SpendexColors.primary),
            const SizedBox(width: 6),
            Text(preset.label, style: SpendexTheme.labelSmall),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_down_1, size: 14, color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary),
          ],
        ),
      ),
    );
  }

  void _showPresetPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DateRangePreset.values.where((p) => p != DateRangePreset.custom).map((preset) {
            return ListTile(
              leading: const Icon(Iconsax.calendar_1),
              title: Text(preset.label),
              onTap: () {
                ref.read(analyticsStateProvider.notifier).setDateRangePreset(preset);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabBar extends ConsumerWidget {
  const _TabBar({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(analyticsCurrentTabProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsTab.values.map((tab) {
          final isSelected = currentTab == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(_getTabLabel(tab)),
              selected: isSelected,
              onSelected: (_) => ref.read(analyticsStateProvider.notifier).setTab(tab),
              selectedColor: SpendexColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : null),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getTabLabel(AnalyticsTab tab) {
    switch (tab) {
      case AnalyticsTab.overview: return 'Overview';
      case AnalyticsTab.income: return 'Income';
      case AnalyticsTab.expense: return 'Expense';
      case AnalyticsTab.trends: return 'Trends';
      case AnalyticsTab.netWorth: return 'Net Worth';
    }
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.state, required this.isDark});
  final AnalyticsState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    if (summary == null) return const SizedBox.shrink();

    return Column(
      children: [
        _SummaryCards(summary: summary, isDark: isDark),
        const SizedBox(height: 16),
        if (state.monthlyStats != null) _BarChartCard(stats: state.monthlyStats!, isDark: isDark),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary, required this.isDark});
  final AnalyticsSummaryModel summary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Income', value: summary.totalIncomeInRupees, color: SpendexColors.income, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(title: 'Expense', value: summary.totalExpenseInRupees, color: SpendexColors.expense, isDark: isDark)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(title: 'Savings', value: summary.netSavingsInRupees, color: SpendexColors.primary, isDark: isDark)),
            const SizedBox(width: 12),
            Expanded(child: _RateCard(title: 'Savings Rate', value: summary.savingsRate, isDark: isDark)),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value, required this.color, required this.isDark});
  final String title;
  final double value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SpendexTheme.labelSmall.copyWith(color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Text(CurrencyFormatter.formatCompact(value), style: SpendexTheme.headlineSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.title, required this.value, required this.isDark});
  final String title;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = value >= 20 ? SpendexColors.income : (value >= 0 ? SpendexColors.warning : SpendexColors.expense);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SpendexTheme.labelSmall.copyWith(color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary)),
          const SizedBox(height: 8),
          Text('${value.toStringAsFixed(1)}%', style: SpendexTheme.headlineSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  const _BarChartCard({required this.stats, required this.isDark});
  final MonthlyStatsResponse stats;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final data = stats.stats;
    if (data.isEmpty) return const SizedBox.shrink();

    double maxY = 0;
    for (final s in data) {
      if (s.incomeInRupees > maxY) maxY = s.incomeInRupees;
      if (s.expenseInRupees > maxY) maxY = s.expenseInRupees;
    }
    maxY *= 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Income vs Expense', style: SpendexTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: data.asMap().entries.map<BarChartGroupData>((entry) {
                  final i = entry.key;
                  final s = entry.value as MonthlyStatsModel;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: s.incomeInRupees, color: SpendexColors.income, width: 8),
                    BarChartRodData(toY: s.expenseInRupees, color: SpendexColors.expense, width: 8),
                  ]);
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= data.length) return const SizedBox.shrink();
                    return Text(data[i].shortLabel, style: SpendexTheme.labelSmall);
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, m) => Text(CurrencyFormatter.formatCompact(v, showSymbol: false, decimalDigits: 0), style: SpendexTheme.labelSmall))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryContent extends StatelessWidget {
  const _CategoryContent({required this.state, required this.isDark, required this.isExpense});
  final AnalyticsState state;
  final bool isDark;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final breakdown = isExpense ? state.expenseBreakdown : state.incomeBreakdown;
    if (breakdown == null || breakdown.categories.isEmpty) {
      return Center(child: Text('No ${isExpense ? 'expense' : 'income'} data available'));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${isExpense ? 'Expense' : 'Income'} Breakdown', style: SpendexTheme.titleMedium),
          const SizedBox(height: 16),
          ...breakdown.categories.take(8).map((cat) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(width: 12, height: 12, decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 12),
                Expanded(child: Text(cat.categoryName, style: SpendexTheme.bodyMedium)),
                Text(CurrencyFormatter.formatCompact(cat.amountInRupees), style: SpendexTheme.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('${cat.percentage.toStringAsFixed(1)}%', style: SpendexTheme.labelSmall.copyWith(color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _TrendsContent extends StatelessWidget {
  const _TrendsContent({required this.state, required this.isDark});
  final AnalyticsState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) return const Center(child: CircularProgressIndicator());
    final dailyStats = state.dailyStats;
    if (dailyStats == null || dailyStats.stats.isEmpty) {
      return Center(child: Text('No trend data available', style: SpendexTheme.bodyMedium));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Spending Trend', style: SpendexTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: dailyStats.stats.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expenseInRupees)).toList(),
                    isCurved: true,
                    color: SpendexColors.expense,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: SpendexColors.expense.withValues(alpha: 0.1)),
                  ),
                ],
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetWorthContent extends StatelessWidget {
  const _NetWorthContent({required this.state, required this.isDark});
  final AnalyticsState state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) return const Center(child: CircularProgressIndicator());
    final netWorth = state.netWorthHistory;
    if (netWorth == null) {
      return Center(child: Text('No net worth data available', style: SpendexTheme.bodyMedium));
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: SpendexColors.primaryGradient,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Net Worth', style: SpendexTheme.labelMedium.copyWith(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(CurrencyFormatter.format(netWorth.currentNetWorthInRupees), style: SpendexTheme.displayLarge.copyWith(color: Colors.white, fontSize: 28)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assets', style: SpendexTheme.labelSmall.copyWith(color: Colors.white70)),
                      Text(CurrencyFormatter.formatCompact(netWorth.currentAssetsInRupees), style: SpendexTheme.titleMedium.copyWith(color: Colors.white)),
                    ],
                  )),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Liabilities', style: SpendexTheme.labelSmall.copyWith(color: Colors.white70)),
                      Text(CurrencyFormatter.formatCompact(netWorth.currentLiabilitiesInRupees), style: SpendexTheme.titleMedium.copyWith(color: Colors.white)),
                    ],
                  )),
                ],
              ),
            ],
          ),
        ),
        if (netWorth.history.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
              border: Border.all(color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Worth History', style: SpendexTheme.titleMedium),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: netWorth.history.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.netWorthInRupees)).toList(),
                          isCurved: true,
                          color: SpendexColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: true, color: SpendexColors.primary.withValues(alpha: 0.2)),
                        ),
                      ],
                      titlesData: const FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
