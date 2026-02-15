import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/investment_model.dart';
import '../providers/investments_provider.dart';
import '../widgets/investment_info_card.dart';

/// Investment Details Screen
///
/// Displays comprehensive investment information with:
/// - Investment header with icon and name
/// - Performance card showing returns
/// - Type-specific investment details
/// - Tax information (if applicable)
/// - Actions: Edit, Delete, Sync prices
class InvestmentDetailsScreen extends ConsumerStatefulWidget {
  const InvestmentDetailsScreen({
    required this.investmentId,
    super.key,
  });

  final String investmentId;

  @override
  ConsumerState<InvestmentDetailsScreen> createState() => _InvestmentDetailsScreenState();
}

class _InvestmentDetailsScreenState extends ConsumerState<InvestmentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(investmentsStateProvider.notifier).loadInvestmentById(widget.investmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentsStateProvider);
    final investment = state.selectedInvestment;

    return Scaffold(
      appBar: _buildAppBar(context, investment),
      body: state.isLoading && investment == null
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && investment == null
              ? ErrorStateWidget(
                  message: state.error!,
                  onRetry: () => ref
                      .read(investmentsStateProvider.notifier)
                      .loadInvestmentById(widget.investmentId),
                )
              : investment == null
                  ? const ErrorStateWidget(message: 'Investment not found')
                  : _buildBody(context, investment, state.isSyncing),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    InvestmentModel? investment,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return AppBar(
      centerTitle: true,
      title: Text(
        'Investment Details',
        style: theme.textTheme.titleLarge?.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        if (investment != null) ...[
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            tooltip: 'Edit Investment',
            onPressed: () {
              context.push('/investments/add?id=${widget.investmentId}');
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash),
            tooltip: 'Delete Investment',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    InvestmentModel investment,
    bool isSyncing,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _InvestmentHeader(investment: investment),
          const SizedBox(height: SpendexTheme.spacingLg),
          _PerformanceCard(investment: investment),
          const SizedBox(height: SpendexTheme.spacingLg),
          _buildInvestmentDetailsCard(investment),
          if (investment.taxSaving) ...[
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildTaxInfoCard(investment),
          ],
          if (investment.isMarketLinked) ...[
            const SizedBox(height: SpendexTheme.spacing2xl),
            _buildSyncButton(context, isSyncing),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentDetailsCard(InvestmentModel investment) {
    final rows = _buildInfoRows(investment);

    return InvestmentInfoCard(
      title: 'Investment Information',
      icon: Iconsax.info_circle,
      rows: rows,
    );
  }

  List<InfoRow> _buildInfoRows(InvestmentModel investment) {
    final type = investment.type;
    final rows = <InfoRow>[];

    if (type == InvestmentType.mutualFund) {
      if (investment.name.isNotEmpty) {
        rows.add(InfoRow(label: 'Scheme Name', value: investment.name));
      }
      if (investment.folioNumber != null) {
        rows.add(
          InfoRow(label: 'Folio Number', value: investment.folioNumber!),
        );
      }
      if (investment.units != null) {
        rows.add(
          InfoRow(
            label: 'Units',
            value: investment.units!.toStringAsFixed(3),
          ),
        );
      }
      if (investment.purchasePrice != null) {
        rows.add(
          InfoRow(
            label: 'Purchase NAV',
            value: formatCurrency(investment.purchasePriceInRupees!),
          ),
        );
      }
      if (investment.currentPrice != null) {
        rows.add(
          InfoRow(
            label: 'Current NAV',
            value: formatCurrency(investment.currentPriceInRupees!),
          ),
        );
      }
    } else if (type == InvestmentType.stock) {
      if (investment.symbol != null) {
        rows.add(InfoRow(label: 'Stock Symbol', value: investment.symbol!));
      }
      if (investment.isin != null) {
        rows.add(InfoRow(label: 'ISIN', value: investment.isin!));
      }
      if (investment.units != null) {
        rows.add(
          InfoRow(
            label: 'Quantity',
            value: investment.units!.toStringAsFixed(0),
          ),
        );
      }
      if (investment.purchasePrice != null) {
        rows.add(
          InfoRow(
            label: 'Purchase Price',
            value: formatCurrency(investment.purchasePriceInRupees!),
          ),
        );
      }
      if (investment.currentPrice != null) {
        rows.add(
          InfoRow(
            label: 'Current Price',
            value: formatCurrency(investment.currentPriceInRupees!),
          ),
        );
      }
      if (investment.broker != null) {
        rows.add(InfoRow(label: 'Broker', value: investment.broker!));
      }
    } else if (type == InvestmentType.fixedDeposit || type == InvestmentType.recurringDeposit) {
      if (investment.broker != null) {
        rows.add(InfoRow(label: 'Bank Name', value: investment.broker!));
      }
      if (investment.interestRate != null) {
        rows.add(
          InfoRow(
            label: 'Interest Rate',
            value: '${investment.interestRate!.toStringAsFixed(2)}% p.a.',
          ),
        );
      }
      if (investment.purchaseDate != null && investment.maturityDate != null) {
        final tenureMonths =
            investment.maturityDate!.difference(investment.purchaseDate!).inDays ~/ 30;
        rows.add(
          InfoRow(
            label: 'Tenure',
            value: tenureMonths >= 12
                ? '${(tenureMonths / 12).toStringAsFixed(1)} years'
                : '$tenureMonths months',
          ),
        );
      }
      if (investment.maturityDate != null) {
        rows.add(
          InfoRow(
            label: 'Maturity Date',
            value: _formatDate(investment.maturityDate!),
          ),
        );
      }
      if (investment.maturityAmount != null) {
        rows.add(
          InfoRow(
            label: 'Maturity Amount',
            value: formatCurrency(investment.maturityAmountInRupees!),
          ),
        );
      }
      if (investment.daysToMaturity != null) {
        rows.add(
          InfoRow(
            label: 'Days to Maturity',
            value: '${investment.daysToMaturity} days',
          ),
        );
      }
    } else if (type == InvestmentType.ppf ||
        type == InvestmentType.epf ||
        type == InvestmentType.nps) {
      if (investment.folioNumber != null) {
        rows.add(
          InfoRow(label: 'Account Number', value: investment.folioNumber!),
        );
      }
      if (investment.interestRate != null) {
        rows.add(
          InfoRow(
            label: 'Interest Rate',
            value: '${investment.interestRate!.toStringAsFixed(2)}% p.a.',
          ),
        );
      }
      if (investment.taxSection != null) {
        rows.add(
          InfoRow(label: 'Tax Section', value: investment.taxSection!.label),
        );
      }
    } else if (type == InvestmentType.gold || type == InvestmentType.sovereignGoldBond) {
      if (investment.units != null) {
        rows.add(
          InfoRow(
            label: type == InvestmentType.gold ? 'Weight (grams)' : 'Units',
            value: investment.units!.toStringAsFixed(2),
          ),
        );
      }
      if (investment.purchasePrice != null) {
        rows.add(
          InfoRow(
            label: 'Price per ${type == InvestmentType.gold ? 'gram' : 'unit'}',
            value: formatCurrency(investment.purchasePriceInRupees!),
          ),
        );
      }
    }

    if (investment.purchaseDate != null) {
      rows.add(
        InfoRow(
          label: 'Purchase Date',
          value: _formatDate(investment.purchaseDate!),
        ),
      );

      final daysHeld = DateTime.now().difference(investment.purchaseDate!).inDays;
      rows.add(
        InfoRow(
          label: 'Days Held',
          value: '$daysHeld days',
        ),
      );
    }

    return rows;
  }

  Widget _buildTaxInfoCard(InvestmentModel investment) {
    final taxSection = investment.taxSection;
    final rows = <InfoRow>[];

    if (taxSection != null && taxSection != TaxSection.none) {
      rows.add(InfoRow(label: 'Tax Section', value: taxSection.label));
    }

    rows.add(
      InfoRow(
        label: 'Eligible Amount',
        value: formatCurrency(investment.investedAmountInRupees),
      ),
    );

    var taxBenefitInfo = '';
    if (taxSection == TaxSection.section80C) {
      taxBenefitInfo = 'Eligible for deduction up to ₹1.5 lakhs per year under Section 80C';
    } else if (taxSection == TaxSection.section80CCD) {
      taxBenefitInfo = 'Additional deduction up to ₹50,000 under Section 80CCD(1B)';
    } else if (taxSection == TaxSection.section80D) {
      taxBenefitInfo = 'Health insurance premium deduction under Section 80D';
    } else {
      taxBenefitInfo = 'Eligible for tax benefits under ${taxSection?.label}';
    }

    rows.add(
      InfoRow(
        label: 'Tax Benefit',
        value: taxBenefitInfo,
      ),
    );

    return InvestmentInfoCard(
      title: 'Tax Benefits',
      icon: Iconsax.shield_tick,
      rows: rows,
    );
  }

  Widget _buildSyncButton(BuildContext context, bool isSyncing) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isSyncing
            ? null
            : () async {
                final success = await ref.read(investmentsStateProvider.notifier).syncPrices();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Prices synced successfully' : 'Failed to sync prices',
                      ),
                      backgroundColor: success ? SpendexColors.income : SpendexColors.expense,
                    ),
                  );
                }
              },
        icon: isSyncing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Iconsax.refresh),
        label: Text(isSyncing ? 'Syncing...' : 'Sync Current Prices'),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Investment?'),
        content: const Text(
          'Are you sure you want to delete this investment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && context.mounted) {
      final success =
          await ref.read(investmentsStateProvider.notifier).deleteInvestment(widget.investmentId);

      if (context.mounted) {
        if (success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Investment deleted successfully'),
              backgroundColor: SpendexColors.income,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete investment'),
              backgroundColor: SpendexColors.expense,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}

class _InvestmentHeader extends StatelessWidget {
  const _InvestmentHeader({required this.investment});

  final InvestmentModel investment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getInvestmentIcon(investment.type),
                size: 40,
                color: SpendexColors.primary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            Text(
              investment.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpendexTheme.spacingXs),
            Text(
              investment.type.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textSecondary,
              ),
            ),
            if (investment.taxSaving) ...[
              const SizedBox(height: SpendexTheme.spacingMd),
              _TaxInfoBadge(investment: investment),
            ],
            if (investment.broker != null &&
                investment.type != InvestmentType.fixedDeposit &&
                investment.type != InvestmentType.recurringDeposit) ...[
              const SizedBox(height: SpendexTheme.spacingSm),
              Text(
                investment.broker!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getInvestmentIcon(InvestmentType type) {
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
      default:
        return Iconsax.wallet_money;
    }
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.investment});

  final InvestmentModel investment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    final returnsColor = investment.isProfit
        ? SpendexColors.income
        : investment.isLoss
            ? SpendexColors.expense
            : textSecondary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          children: [
            Text(
              'Current Value',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingXs),
            Text(
              formatCurrencyCompact(investment.currentValueInRupees),
              style: theme.textTheme.displaySmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingXs),
            Text(
              'Invested: ${formatCurrency(investment.investedAmountInRupees)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Divider(
              color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Returns',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        investment.isProfit
                            ? '+${formatCurrency(investment.returnsInRupees)}'
                            : formatCurrency(investment.returnsInRupees),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: returnsColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Returns %',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        investment.isProfit
                            ? '+${investment.returnsPercent.toStringAsFixed(2)}%'
                            : '${investment.returnsPercent.toStringAsFixed(2)}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: returnsColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (investment.isMarketLinked) ...[
              const SizedBox(height: SpendexTheme.spacingLg),
              Text(
                'Last synced: ${_formatDate(investment.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

class _TaxInfoBadge extends StatelessWidget {
  const _TaxInfoBadge({required this.investment});

  final InvestmentModel investment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taxSection = investment.taxSection;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.income.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
        border: Border.all(
          color: SpendexColors.income.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconsax.shield_tick,
            size: 16,
            color: SpendexColors.income,
          ),
          const SizedBox(width: SpendexTheme.spacingXs),
          Text(
            taxSection != null && taxSection != TaxSection.none
                ? 'Tax Saving: ${taxSection.label}'
                : 'Tax Saving',
            style: theme.textTheme.bodySmall?.copyWith(
              color: SpendexColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String formatCurrency(double amount) {
  final format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  return format.format(amount);
}

String formatCurrencyCompact(double amount) {
  if (amount.abs() >= 10000000) {
    return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
  } else if (amount.abs() >= 100000) {
    return '₹${(amount / 100000).toStringAsFixed(2)}L';
  } else if (amount.abs() >= 1000) {
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return formatCurrency(amount);
  }
}
