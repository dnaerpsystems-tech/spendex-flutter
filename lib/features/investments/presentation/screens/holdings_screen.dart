import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/investment_model.dart';
import '../providers/investments_provider.dart';
import '../widgets/holdings_tile.dart';

/// Holdings Screen
///
/// Displays a list of investment holdings grouped by investment type.
/// Features:
/// - Pull-to-refresh functionality
/// - Grouping by investment type with section headers
/// - Expandable holdings tiles
/// - Navigation to investment details
/// - FAB to add new investments
/// - Loading, error, and empty states
class HoldingsScreen extends ConsumerStatefulWidget {
  const HoldingsScreen({super.key});

  @override
  ConsumerState<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends ConsumerState<HoldingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(investmentsStateProvider.notifier).loadInvestments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(investmentsStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Holdings'),
            if (!state.isLoading && state.error == null)
              Text(
                '${state.activeInvestments.length} Investment${state.activeInvestments.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
              ),
          ],
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(investmentsStateProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/investments/add'),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Investment'),
      ),
    );
  }

  Widget _buildBody(InvestmentsState state) {
    if (state.isLoading && state.investments.isEmpty) {
      return const _HoldingsSkeleton();
    }

    if (state.error != null && state.investments.isEmpty) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () {
          ref.read(investmentsStateProvider.notifier).loadInvestments();
        },
      );
    }

    if (state.activeInvestments.isEmpty) {
      return EmptyStateWidget(
        icon: Iconsax.chart_21,
        title: 'No Holdings',
        subtitle: 'Start building your investment portfolio by adding your first investment.',
        actionLabel: 'Add Investment',
        actionIcon: Iconsax.add,
        onAction: () => context.push('/investments/add'),
      );
    }

    final groupedHoldings = _groupInvestmentsByType(state.activeInvestments);

    return ListView.builder(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      itemCount: groupedHoldings.length,
      itemBuilder: (context, index) {
        final entry = groupedHoldings.entries.elementAt(index);
        final typeKey = entry.key;
        final investments = entry.value;

        return _HoldingsSection(
          title: typeKey,
          count: investments.length,
          investments: investments,
        );
      },
    );
  }

  Map<String, List<InvestmentModel>> _groupInvestmentsByType(
    List<InvestmentModel> investments,
  ) {
    final grouped = <String, List<InvestmentModel>>{};

    for (final investment in investments) {
      final typeKey = _getTypeDisplayName(investment.type);

      if (grouped.containsKey(typeKey)) {
        grouped[typeKey]!.add(investment);
      } else {
        grouped[typeKey] = [investment];
      }
    }

    for (final list in grouped.values) {
      list.sort((a, b) => b.currentValue.compareTo(a.currentValue));
    }

    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.fold<int>(
          0,
          (sum, inv) => sum + inv.currentValue,
        );
        final totalB = b.value.fold<int>(
          0,
          (sum, inv) => sum + inv.currentValue,
        );
        return totalB.compareTo(totalA);
      });

    return Map.fromEntries(sortedEntries);
  }

  String _getTypeDisplayName(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return 'Mutual Funds';
      case InvestmentType.stock:
        return 'Stocks';
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return 'Fixed Deposits';
      case InvestmentType.ppf:
        return 'PPF';
      case InvestmentType.epf:
        return 'EPF';
      case InvestmentType.nps:
        return 'NPS';
      case InvestmentType.gold:
        return 'Gold';
      case InvestmentType.sovereignGoldBond:
        return 'Sovereign Gold Bonds';
      case InvestmentType.realEstate:
        return 'Real Estate';
      case InvestmentType.crypto:
        return 'Cryptocurrency';
      case InvestmentType.sukanyaSamriddhi:
        return 'Sukanya Samriddhi';
      case InvestmentType.postOffice:
        return 'Post Office';
      case InvestmentType.other:
        return 'Others';
    }
  }
}

class _HoldingsSection extends ConsumerWidget {
  const _HoldingsSection({
    required this.title,
    required this.count,
    required this.investments,
  });

  final String title;
  final int count;
  final List<InvestmentModel> investments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    final totalValue = investments.fold<int>(
      0,
      (sum, inv) => sum + inv.currentValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpendexTheme.spacingSm,
            right: SpendexTheme.spacingSm,
            bottom: SpendexTheme.spacingMd,
            top: SpendexTheme.spacingMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingXs),
                  Text(
                    '($count)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                CurrencyFormatter.formatPaiseCompact(
                  totalValue,
                  decimalDigits: 1,
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ...investments.map(
          (investment) => GestureDetector(
            onTap: () => context.push('/investments/${investment.id}'),
            child: HoldingsTile(investment: investment),
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
      ],
    );
  }
}

class _HoldingsSkeleton extends StatelessWidget {
  const _HoldingsSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shimmerColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return ListView.builder(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      itemCount: 3,
      itemBuilder: (context, sectionIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: SpendexTheme.spacingSm,
                right: SpendexTheme.spacingSm,
                bottom: SpendexTheme.spacingMd,
                top: SpendexTheme.spacingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(
                        SpendexTheme.radiusSm,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 20,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(
                        SpendexTheme.radiusSm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...List.generate(
              2,
              (index) => Card(
                margin: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
                child: Padding(
                  padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: shimmerColor,
                        ),
                      ),
                      const SizedBox(width: SpendexTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 16,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(
                                  SpendexTheme.radiusSm,
                                ),
                              ),
                            ),
                            const SizedBox(height: SpendexTheme.spacingXs),
                            Container(
                              width: 120,
                              height: 14,
                              decoration: BoxDecoration(
                                color: shimmerColor,
                                borderRadius: BorderRadius.circular(
                                  SpendexTheme.radiusSm,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpendexTheme.spacingSm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 80,
                            height: 16,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(
                                SpendexTheme.radiusSm,
                              ),
                            ),
                          ),
                          const SizedBox(height: SpendexTheme.spacingXs),
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: shimmerColor,
                              borderRadius: BorderRadius.circular(
                                SpendexTheme.radiusSm,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        );
      },
    );
  }
}
