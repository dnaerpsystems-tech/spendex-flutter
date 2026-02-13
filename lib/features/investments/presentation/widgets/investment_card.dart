import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/investment_model.dart';

/// A card widget that displays individual investment information.
///
/// This widget shows:
/// - Investment type icon in a circular container
/// - Investment name and type label
/// - Current value formatted in Lakhs/Crores
/// - Invested amount (in gray text)
/// - Returns amount and percentage (color-coded)
/// - Tax-saving badge (if applicable)
///
/// Features:
/// - Material 3 design with elevation
/// - Dark mode support
/// - Tap handling for navigation to details
/// - Color-coded returns (green for profit, red for loss)
class InvestmentCard extends StatelessWidget {
  const InvestmentCard({
    required this.investment,
    required this.onTap,
    super.key,
  });

  final InvestmentModel investment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? SpendexColors.darkTextPrimary
        : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getInvestmentTypeColor(investment.type)
                          .withOpacity(0.1),
                    ),
                    child: Icon(
                      _getInvestmentTypeIcon(investment.type),
                      color: _getInvestmentTypeColor(investment.type),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingLg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investment.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SpendexTheme.spacingXs),
                        Text(
                          investment.type.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpendexTheme.spacingLg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        CurrencyFormatter.formatPaiseCompact(
                          investment.currentValue,
                        ),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        'Invested: ${CurrencyFormatter.formatPaise(investment.investedAmount, decimalDigits: 0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Returns',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        '${investment.returns >= 0 ? '+' : ''}${CurrencyFormatter.formatPaise(investment.returns, decimalDigits: 0)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: investment.returns >= 0
                              ? SpendexColors.income
                              : SpendexColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpendexTheme.spacingSm,
                          vertical: SpendexTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: (investment.returns >= 0
                                  ? SpendexColors.income
                                  : SpendexColors.expense)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            SpendexTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${investment.returnsPercent >= 0 ? '+' : ''}${investment.returnsPercent.toStringAsFixed(2)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: investment.returns >= 0
                                ? SpendexColors.income
                                : SpendexColors.expense,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (investment.taxSaving && investment.taxSection != null) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingMd,
                    vertical: SpendexTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Iconsax.shield_tick,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: SpendexTheme.spacingXs),
                      Text(
                        'Tax Saving: ${investment.taxSection!.label}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getInvestmentTypeIcon(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return Iconsax.chart;
      case InvestmentType.stock:
        return Iconsax.trend_up;
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return Iconsax.bank;
      case InvestmentType.ppf:
        return Iconsax.shield_tick;
      case InvestmentType.epf:
        return Iconsax.user_tick;
      case InvestmentType.nps:
        return Iconsax.security_user;
      case InvestmentType.gold:
        return Iconsax.medal_star;
      case InvestmentType.sovereignGoldBond:
        return Iconsax.medal_star;
      case InvestmentType.realEstate:
        return Iconsax.building;
      case InvestmentType.crypto:
        return Iconsax.coin;
      case InvestmentType.sukanyaSamriddhi:
      case InvestmentType.postOffice:
      case InvestmentType.other:
        return Iconsax.wallet_money;
    }
  }

  Color _getInvestmentTypeColor(InvestmentType type) {
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
