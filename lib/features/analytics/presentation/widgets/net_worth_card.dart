import 'package:flutter/material.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/net_worth_model.dart';

/// Card showing current net worth with assets and liabilities
class NetWorthCard extends StatelessWidget {
  const NetWorthCard({
    required this.netWorth, super.key,
  });

  final NetWorthResponse netWorth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Net Worth',
            style: SpendexTheme.labelMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(netWorth.currentNetWorthInRupees),
            style: SpendexTheme.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NetWorthItem(
                  label: 'Assets',
                  value: netWorth.currentAssetsInRupees,
                  isPositive: true,
                ),
              ),
              Expanded(
                child: _NetWorthItem(
                  label: 'Liabilities',
                  value: netWorth.currentLiabilitiesInRupees,
                  isPositive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetWorthItem extends StatelessWidget {
  const _NetWorthItem({
    required this.label,
    required this.value,
    required this.isPositive,
  });

  final String label;
  final double value;
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpendexTheme.labelSmall.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatCompact(value),
          style: SpendexTheme.titleMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
