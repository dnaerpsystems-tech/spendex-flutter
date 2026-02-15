import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/monthly_stats_model.dart';

/// Bar chart showing income vs expense comparison
class IncomeExpenseBarChart extends StatelessWidget {
  const IncomeExpenseBarChart({
    required this.stats,
    super.key,
    this.height = 200,
  });

  final List<MonthlyStatsModel> stats;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    double maxY = 0;
    for (final s in stats) {
      if (s.incomeInRupees > maxY) {
        maxY = s.incomeInRupees;
      }
      if (s.expenseInRupees > maxY) {
        maxY = s.expenseInRupees;
      }
    }
    maxY *= 1.2;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Text('Income vs Expense', style: SpendexTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: _buildBarGroups(),
                titlesData: _buildTitles(),
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return stats.asMap().entries.map((entry) {
      final i = entry.key;
      final s = entry.value;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: s.incomeInRupees,
            color: SpendexColors.income,
            width: 8,
          ),
          BarChartRodData(
            toY: s.expenseInRupees,
            color: SpendexColors.expense,
            width: 8,
          ),
        ],
      );
    }).toList();
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (v, m) {
            final i = v.toInt();
            if (i < 0 || i >= stats.length) {
              return const SizedBox.shrink();
            }
            return Text(stats[i].shortLabel, style: SpendexTheme.labelSmall);
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (v, m) => Text(
            CurrencyFormatter.formatCompact(v, showSymbol: false, decimalDigits: 0),
            style: SpendexTheme.labelSmall,
          ),
        ),
      ),
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
    );
  }
}
