import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A pie chart widget that visualizes portfolio asset allocation by investment type.
///
/// This widget displays:
/// - Interactive pie chart with colored sections for each investment type
/// - Percentage labels on tap
/// - Legend below chart showing type name and percentage
/// - Center text showing "Portfolio"
/// - Responsive sizing
/// - Empty state handling
///
/// Features:
/// - Uses fl_chart package for rendering
/// - Color-coded investment types
/// - Dark mode support
/// - Interactive touch feedback
class PortfolioPieChart extends StatefulWidget {
  const PortfolioPieChart({
    required this.allocationByType,
    super.key,
  });

  final Map<String, int> allocationByType;

  @override
  State<PortfolioPieChart> createState() => _PortfolioPieChartState();
}

class _PortfolioPieChartState extends State<PortfolioPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    if (widget.allocationByType.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: textSecondary,
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'No investments yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final totalValue = widget.allocationByType.values.reduce((a, b) => a + b);
    final sections = _buildPieChartSections(totalValue, textPrimary);

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: sections,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Portfolio',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingXs),
                  Text(
                    '${widget.allocationByType.length}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Types',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingXl),
        Wrap(
          spacing: SpendexTheme.spacingMd,
          runSpacing: SpendexTheme.spacingMd,
          children: widget.allocationByType.entries.map((entry) {
            final percentage = entry.value / totalValue * 100;
            final investmentType = _parseInvestmentType(entry.key);
            return _LegendItem(
              color: _getColorForType(investmentType),
              label: investmentType.label,
              percentage: percentage,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    int totalValue,
    Color textPrimary,
  ) {
    final entries = widget.allocationByType.entries.toList();
    return List.generate(entries.length, (index) {
      final entry = entries[index];
      final isTouched = index == touchedIndex;
      final percentage = entry.value / totalValue * 100;
      final investmentType = _parseInvestmentType(entry.key);

      return PieChartSectionData(
        color: _getColorForType(investmentType),
        value: entry.value.toDouble(),
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 70 : 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  InvestmentType _parseInvestmentType(String value) {
    return InvestmentType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => InvestmentType.other,
    );
  }

  Color _getColorForType(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return SpendexColors.primary;
      case InvestmentType.stock:
        return Colors.blue;
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return Colors.green;
      case InvestmentType.ppf:
        return Colors.orange;
      case InvestmentType.epf:
        return Colors.purple;
      case InvestmentType.nps:
        return Colors.teal;
      case InvestmentType.gold:
        return Colors.amber;
      case InvestmentType.sovereignGoldBond:
        return Colors.yellow.shade700;
      case InvestmentType.realEstate:
        return Colors.brown;
      case InvestmentType.crypto:
        return Colors.indigo;
      case InvestmentType.sukanyaSamriddhi:
      case InvestmentType.postOffice:
      case InvestmentType.other:
        return Colors.grey;
    }
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.percentage,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color color;
  final String label;
  final double percentage;
  final Color textPrimary;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        Text(
          '$label ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w500,
              ),
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textSecondary,
              ),
        ),
      ],
    );
  }
}
