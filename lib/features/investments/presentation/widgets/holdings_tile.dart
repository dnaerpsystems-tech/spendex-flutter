import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/investment_model.dart';

/// A compact expandable tile widget for displaying investment holdings.
///
/// This widget shows:
/// - Investment type icon and name
/// - Units/quantity (if applicable)
/// - Current value (formatted)
/// - Returns with color coding
/// - Expandable details section with additional information
///
/// Features:
/// - Smooth expansion animation
/// - Card/ListTile styling
/// - Detailed view shows invested amount, purchase/current prices, dates, returns %
/// - Material 3 design
/// - Dark mode support
class HoldingsTile extends StatefulWidget {
  const HoldingsTile({
    required this.investment,
    super.key,
  });

  final InvestmentModel investment;

  @override
  State<HoldingsTile> createState() => _HoldingsTileState();
}

class _HoldingsTileState extends State<HoldingsTile> {
  bool _isExpanded = false;

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
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Card(
      margin: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getInvestmentTypeColor(widget.investment.type)
                          .withOpacity(0.1),
                    ),
                    child: Icon(
                      _getInvestmentTypeIcon(widget.investment.type),
                      color: _getInvestmentTypeColor(widget.investment.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.investment.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SpendexTheme.spacingXs),
                        Row(
                          children: [
                            if (widget.investment.units != null) ...[
                              Text(
                                '${widget.investment.units!.toStringAsFixed(2)} units',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(width: SpendexTheme.spacingSm),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: SpendexTheme.spacingSm),
                            ],
                            Text(
                              CurrencyFormatter.formatPaiseCompact(
                                widget.investment.currentValue,
                                decimalDigits: 2,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.investment.returns >= 0 ? '+' : ''}${CurrencyFormatter.formatPaiseCompact(widget.investment.returns, decimalDigits: 1)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: widget.investment.returns >= 0
                              ? SpendexColors.income
                              : SpendexColors.expense,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpendexTheme.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: (widget.investment.returns >= 0
                                  ? SpendexColors.income
                                  : SpendexColors.expense)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            SpendexTheme.radiusSm,
                          ),
                        ),
                        child: Text(
                          '${widget.investment.returnsPercent >= 0 ? '+' : ''}${widget.investment.returnsPercent.toStringAsFixed(2)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: widget.investment.returns >= 0
                                ? SpendexColors.income
                                : SpendexColors.expense,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Iconsax.arrow_down_1,
                      size: 20,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingMd),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Invested Amount',
                    value: CurrencyFormatter.formatPaise(
                      widget.investment.investedAmount,
                      decimalDigits: 0,
                    ),
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  if (widget.investment.purchasePrice != null &&
                      widget.investment.currentPrice != null) ...[
                    const SizedBox(height: SpendexTheme.spacingSm),
                    _DetailRow(
                      label: 'Purchase Price',
                      value: CurrencyFormatter.formatPaise(
                        widget.investment.purchasePrice!,
                        decimalDigits: 2,
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: SpendexTheme.spacingSm),
                    _DetailRow(
                      label: 'Current Price',
                      value: CurrencyFormatter.formatPaise(
                        widget.investment.currentPrice!,
                        decimalDigits: 2,
                      ),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                  if (widget.investment.purchaseDate != null) ...[
                    const SizedBox(height: SpendexTheme.spacingSm),
                    _DetailRow(
                      label: 'Purchase Date',
                      value: DateFormat(AppConstants.dateFormat)
                          .format(widget.investment.purchaseDate!),
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                  const SizedBox(height: SpendexTheme.spacingSm),
                  _DetailRow(
                    label: 'Returns',
                    value:
                        '${widget.investment.returns >= 0 ? '+' : ''}${CurrencyFormatter.formatPaise(widget.investment.returns, decimalDigits: 0)} (${widget.investment.returnsPercent >= 0 ? '+' : ''}${widget.investment.returnsPercent.toStringAsFixed(2)}%)',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    valueColor: widget.investment.returns >= 0
                        ? SpendexColors.income
                        : SpendexColors.expense,
                  ),
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor ?? textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
