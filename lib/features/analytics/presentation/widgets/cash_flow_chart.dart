import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/monthly_stats_model.dart';

/// Line chart showing cash flow (income - expense) over time.
class CashFlowChart extends StatefulWidget {
  const CashFlowChart({
    required this.stats,
    super.key,
    this.height = 220,
    this.showNetFlow = true,
  });

  final List<MonthlyStatsModel> stats;
  final double height;
  final bool showNetFlow;

  @override
  State<CashFlowChart> createState() => _CashFlowChartState();
}

class _CashFlowChartState extends State<CashFlowChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.stats.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cash Flow',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
              _buildLegend(isDark),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          SizedBox(
            height: widget.height,
            child: LineChart(
              LineChartData(
                lineTouchData: _buildTouchData(isDark),
                gridData: _buildGridData(isDark),
                titlesData: _buildTitlesData(isDark),
                borderData: FlBorderData(show: false),
                lineBarsData: _buildLineBarsData(),
                minY: _calculateMinY(),
                maxY: _calculateMaxY(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineTouchData _buildTouchData(bool isDark) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            String label;
            Color color;

            if (spot.barIndex == 0) {
              label = 'Income';
              color = SpendexColors.income;
            } else if (spot.barIndex == 1) {
              label = 'Expense';
              color = SpendexColors.expense;
            } else {
              label = 'Net';
              color = spot.y >= 0 ? SpendexColors.income : SpendexColors.expense;
            }

            return LineTooltipItem(
              '$label\n${CurrencyFormatter.formatCompact(spot.y)}',
              SpendexTheme.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList();
        },
        getTooltipColor: (touchedSpot) =>
            isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
      ),
      touchCallback: (event, touchResponse) {
        setState(() {
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null ||
              touchResponse.lineBarSpots!.isEmpty) {
            _touchedIndex = null;
            return;
          }
          _touchedIndex = touchResponse.lineBarSpots!.first.x.toInt();
        });
      },
    );
  }

  FlGridData _buildGridData(bool isDark) {
    return FlGridData(
      drawVerticalLine: false,
      horizontalInterval: _calculateInterval(),
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color:
              isDark ? SpendexColors.darkBorder.withValues(alpha: 0.5) : SpendexColors.lightBorder,
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  FlTitlesData _buildTitlesData(bool isDark) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _calculateInterval(),
          getTitlesWidget: (value, meta) {
            if (value == meta.min || value == meta.max) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                CurrencyFormatter.formatCompact(
                  value,
                  showSymbol: false,
                  decimalDigits: 0,
                ),
                style: SpendexTheme.labelSmall.copyWith(
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= widget.stats.length) {
              return const SizedBox.shrink();
            }
            if (widget.stats.length > 6 && index % 2 != 0) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.stats[index].shortLabel,
                style: SpendexTheme.labelSmall.copyWith(
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
    );
  }

  List<LineChartBarData> _buildLineBarsData() {
    final lines = <LineChartBarData>[LineChartBarData(
          spots: widget.stats.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.incomeInRupees);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: SpendexColors.income,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            getDotPainter: (spot, percent, bar, index) {
              final isHighlighted = _touchedIndex == index;
              return FlDotCirclePainter(
                radius: isHighlighted ? 6 : 3,
                color: SpendexColors.income,
                strokeWidth: isHighlighted ? 2 : 0,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                SpendexColors.income.withValues(alpha: 0.3),
                SpendexColors.income.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        LineChartBarData(
        spots: widget.stats.asMap().entries.map((entry) {
          return FlSpot(entry.key.toDouble(), entry.value.expenseInRupees);
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: SpendexColors.expense,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          getDotPainter: (spot, percent, bar, index) {
            final isHighlighted = _touchedIndex == index;
            return FlDotCirclePainter(
              radius: isHighlighted ? 6 : 3,
              color: SpendexColors.expense,
              strokeWidth: isHighlighted ? 2 : 0,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SpendexColors.expense.withValues(alpha: 0.3),
              SpendexColors.expense.withValues(alpha: 0),
            ],
          ),
        ),
      ),]
      // Income line
      
      // Expense line
      ;

    // Net flow line (optional)
    if (widget.showNetFlow) {
      lines.add(
        LineChartBarData(
          spots: widget.stats.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.netFlowInRupees);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: SpendexColors.primary,
          isStrokeCapRound: true,
          dashArray: [5, 5],
          dotData: const FlDotData(show: false),
        ),
      );
    }

    return lines;
  }

  double _calculateMaxY() {
    var maxValue = 0.0;
    for (final stat in widget.stats) {
      if (stat.incomeInRupees > maxValue) {
        maxValue = stat.incomeInRupees;
      }
      if (stat.expenseInRupees > maxValue) {
        maxValue = stat.expenseInRupees;
      }
    }
    return maxValue * 1.15;
  }

  double _calculateMinY() {
    if (!widget.showNetFlow) {
      return 0;
    }
    var minValue = 0.0;
    for (final stat in widget.stats) {
      if (stat.netFlowInRupees < minValue) {
        minValue = stat.netFlowInRupees;
      }
    }
    return minValue < 0 ? minValue * 1.15 : 0;
  }

  double _calculateInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 0) {
      return 1000;
    }

    final rawInterval = maxY / 4;
    final magnitude = _calculateMagnitude(rawInterval);
    final normalized = rawInterval / magnitude;

    double niceInterval;
    if (normalized <= 1) {
      niceInterval = 1;
    } else if (normalized <= 2) {
      niceInterval = 2;
    } else if (normalized <= 5) {
      niceInterval = 5;
    } else {
      niceInterval = 10;
    }

    return niceInterval * magnitude;
  }

  double _calculateMagnitude(double value) {
    if (value == 0) {
      return 1;
    }
    var magnitude = 1.0;
    final absValue = value.abs();

    if (absValue >= 1) {
      while (magnitude * 10 <= absValue) {
        magnitude *= 10;
      }
    } else {
      while (magnitude > absValue) {
        magnitude /= 10;
      }
    }

    return magnitude;
  }

  Widget _buildLegend(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendItem('Income', SpendexColors.income, isDark),
        const SizedBox(width: 12),
        _buildLegendItem('Expense', SpendexColors.expense, isDark),
        if (widget.showNetFlow) ...[
          const SizedBox(width: 12),
          _buildLegendItem('Net', SpendexColors.primary, isDark, isDashed: true),
        ],
      ],
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    bool isDark, {
    bool isDashed = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          Container(
            width: 16,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, Colors.transparent, color],
              ),
            ),
          )
        else
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: SpendexTheme.labelSmall.copyWith(
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(SpendexTheme.spacingXl),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              'No cash flow data available',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
