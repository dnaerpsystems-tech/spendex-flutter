import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../data/models/insight_model.dart';

/// Widget that displays an appropriate icon for each InsightType with color coding
class InsightTypeIcon extends StatelessWidget {

  const InsightTypeIcon({
    required this.type, super.key,
    this.size = 48.0,
    this.showGradient = true,
  });
  final InsightType type;
  final double size;
  final bool showGradient;

  /// Get icon data for the insight type
  IconData _getIconForType() {
    switch (type) {
      case InsightType.spendingPattern:
        return Iconsax.chart_21;
      case InsightType.savingsOpportunity:
        return Iconsax.wallet_add;
      case InsightType.billPrediction:
        return Iconsax.receipt_text;
      case InsightType.anomalyDetection:
        return Iconsax.warning_2;
      case InsightType.budgetRecommendation:
        return Iconsax.percentage_circle;
      case InsightType.goalAchievability:
        return Iconsax.flag;
      case InsightType.loanInsight:
        return Iconsax.bank;
      case InsightType.categoryTrend:
        return Iconsax.trend_up;
      case InsightType.merchantAnalysis:
        return Iconsax.shop;
      case InsightType.cashFlowForecast:
        return Iconsax.money_send;
    }
  }

  /// Get gradient colors for the insight type
  List<Color> _getGradientColors() {
    switch (type) {
      case InsightType.spendingPattern:
        // Red to deep orange
        return [Colors.red, Colors.deepOrange];

      case InsightType.savingsOpportunity:
        // Light green to teal
        return [Colors.lightGreen, Colors.teal];

      case InsightType.billPrediction:
        // Light blue to indigo
        return [Colors.lightBlue, Colors.indigo];

      case InsightType.anomalyDetection:
        // Red to deep orange
        return [Colors.red, Colors.deepOrange];

      case InsightType.budgetRecommendation:
        // Purple to pink
        return [Colors.purple, Colors.pink];

      case InsightType.goalAchievability:
        // Teal to cyan
        return [Colors.teal, Colors.cyan];

      case InsightType.loanInsight:
        // Orange to deep orange
        return [Colors.orange, Colors.deepOrange];

      case InsightType.categoryTrend:
        // Blue to light blue
        return [Colors.blue, Colors.lightBlue];

      case InsightType.merchantAnalysis:
        // Indigo to blue
        return [Colors.indigo, Colors.blue];

      case InsightType.cashFlowForecast:
        // Cyan to teal
        return [Colors.cyan, Colors.teal];
    }
  }

  /// Get solid color for the insight type (when gradient is disabled)
  Color _getSolidColor() {
    switch (type) {
      case InsightType.spendingPattern:
        return Colors.red;
      case InsightType.savingsOpportunity:
        return Colors.green;
      case InsightType.billPrediction:
        return Colors.blue;
      case InsightType.anomalyDetection:
        return Colors.red;
      case InsightType.budgetRecommendation:
        return Colors.purple;
      case InsightType.goalAchievability:
        return Colors.teal;
      case InsightType.loanInsight:
        return Colors.orange;
      case InsightType.categoryTrend:
        return Colors.blue;
      case InsightType.merchantAnalysis:
        return Colors.indigo;
      case InsightType.cashFlowForecast:
        return Colors.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = _getGradientColors();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: showGradient
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: showGradient ? null : _getSolidColor(),
        boxShadow: [
          BoxShadow(
            color: (showGradient ? gradientColors[0] : _getSolidColor())
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIconForType(),
          color: Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
