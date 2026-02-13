import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/investment_model.dart';
import '../providers/investments_provider.dart';

/// Tax Savings Dashboard Screen
///
/// Displays comprehensive tax savings information with real calculations
/// for all tax sections including 80C, 80CCD(1B), 80D, 80E, 80G, 80TTA, 80TTB.
class TaxSavingsScreen extends ConsumerStatefulWidget {
  const TaxSavingsScreen({super.key});

  @override
  ConsumerState<TaxSavingsScreen> createState() => _TaxSavingsScreenState();
}

class _TaxSavingsScreenState extends ConsumerState<TaxSavingsScreen> {
  late String _selectedFinancialYear;
  double _selectedTaxSlab = 30.0;
  bool _isCalculatorExpanded = false;
  final TextEditingController _incomeController = TextEditingController();
  bool _isOldRegime = true;

  @override
  void initState() {
    super.initState();
    _selectedFinancialYear = _getCurrentFinancialYear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentsStateProvider.notifier).loadInvestments();
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  String _getCurrentFinancialYear() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    if (month >= 4) {
      return '$year-${(year + 1).toString().substring(2)}';
    } else {
      return '${year - 1}-${year.toString().substring(2)}';
    }
  }

  List<String> _getFinancialYearOptions() {
    final current = _getCurrentFinancialYear();
    final currentYear = int.parse(current.split('-')[0]);

    return [
      current,
      '${currentYear - 1}-${currentYear.toString().substring(2)}',
      '${currentYear - 2}-${(currentYear - 1).toString().substring(2)}',
    ];
  }

  void _showFinancialYearPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _FYSelectorSheet(
        selectedYear: _selectedFinancialYear,
        years: _getFinancialYearOptions(),
        onYearSelected: (year) {
          setState(() {
            _selectedFinancialYear = year;
          });
          ref.read(investmentsStateProvider.notifier).loadInvestments();
          Navigator.pop(context);
        },
      ),
    );
  }

  TaxSavingsData _calculateTaxSavings(List<InvestmentModel> investments) {
    final Map<TaxSection, int> sectionTotals = {};
    final Map<TaxSection, List<InvestmentModel>> sectionInvestments = {};

    for (final investment in investments) {
      if (investment.taxSaving && investment.taxSection != null) {
        final section = investment.taxSection!;
        sectionTotals[section] = (sectionTotals[section] ?? 0) + investment.investedAmount;
        sectionInvestments.putIfAbsent(section, () => []).add(investment);
      }
    }

    return TaxSavingsData(
      sectionTotals: sectionTotals,
      sectionInvestments: sectionInvestments,
    );
  }

  int _getTotalTaxSavings(Map<TaxSection, int> sectionTotals) {
    int total = 0;

    final section80C = sectionTotals[TaxSection.section80C] ?? 0;
    total += section80C > 15000000 ? 15000000 : section80C;

    final section80CCD = sectionTotals[TaxSection.section80CCD] ?? 0;
    total += section80CCD > 5000000 ? 5000000 : section80CCD;

    final section80D = sectionTotals[TaxSection.section80D] ?? 0;
    total += section80D > 2500000 ? 2500000 : section80D;

    total += sectionTotals[TaxSection.section80E] ?? 0;

    final section80G = sectionTotals[TaxSection.section80G] ?? 0;
    total += (section80G * 0.5).round();

    final section80TTA = sectionTotals[TaxSection.section80TTA] ?? 0;
    total += section80TTA > 1000000 ? 1000000 : section80TTA;

    final section80TTB = sectionTotals[TaxSection.section80TTB] ?? 0;
    total += section80TTB > 5000000 ? 5000000 : section80TTB;

    return total;
  }

  Future<void> _handleRefresh() async {
    await ref.read(investmentsStateProvider.notifier).loadInvestments();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investmentsState = ref.watch(investmentsStateProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tax Savings'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                'FY $_selectedFinancialYear',
                style: SpendexTheme.labelMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
              onPressed: _showFinancialYearPicker,
              side: const BorderSide(color: SpendexColors.primary),
              backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
      body: investmentsState.isLoading
          ? const LoadingStateWidget(message: 'Loading tax savings...')
          : investmentsState.error != null
              ? ErrorStateWidget(
                  message: investmentsState.error!,
                  onRetry: _handleRefresh,
                )
              : _buildContent(investmentsState.investments),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/investments/add'),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Tax-Saving Investment'),
      ),
    );
  }

  Widget _buildContent(List<InvestmentModel> investments) {
    final taxSavingsData = _calculateTaxSavings(investments);
    final totalSavings = _getTotalTaxSavings(taxSavingsData.sectionTotals);

    if (totalSavings == 0) {
      return EmptyStateWidget(
        icon: Iconsax.shield_tick,
        title: 'No Tax-Saving Investments',
        subtitle: 'Start saving taxes by adding tax-saving investments',
        actionLabel: 'Add Investment',
        actionIcon: Iconsax.add,
        onAction: () => context.push('/investments/add'),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(totalSavings),
              const SizedBox(height: 24),
              _buildTaxCalculatorCard(),
              const SizedBox(height: 24),
              Text(
                'Tax Sections',
                style: SpendexTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              _buildSection80C(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80CCD(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80D(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80E(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80G(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80TTA(taxSavingsData),
              const SizedBox(height: 16),
              _buildSection80TTB(taxSavingsData),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalSavings) {
    final totalTaxBenefit = (totalSavings * _selectedTaxSlab / 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Tax Savings',
            style: SpendexTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.formatPaise(totalSavings, decimalDigits: 0),
            style: SpendexTheme.displayLarge.copyWith(
              color: Colors.white,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Benefit',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatPaise(totalTaxBenefit, decimalDigits: 0),
                      style: SpendexTheme.headlineMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tax Slab',
            style: SpendexTheme.labelMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTaxSlabChip(10),
              const SizedBox(width: 8),
              _buildTaxSlabChip(20),
              const SizedBox(width: 8),
              _buildTaxSlabChip(30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaxSlabChip(double slab) {
    final isSelected = _selectedTaxSlab == slab;

    return FilterChip(
      label: Text(
        '${slab.toInt()}%',
        style: SpendexTheme.labelMedium.copyWith(
          color: isSelected ? SpendexColors.primary : Colors.white,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTaxSlab = slab;
        });
      },
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      selectedColor: Colors.white,
      side: BorderSide.none,
      showCheckmark: false,
    );
  }

  Widget _buildTaxCalculatorCard() {
    return Card(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isCalculatorExpanded = !_isCalculatorExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calculator,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Calculate Your Tax Savings',
                      style: SpendexTheme.titleMedium,
                    ),
                  ),
                  Icon(
                    _isCalculatorExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isCalculatorExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Annual Income (₹)',
                      prefixIcon: Icon(Iconsax.money),
                      hintText: 'Enter your annual income',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tax Regime',
                    style: SpendexTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Old Regime'),
                          value: true,
                          groupValue: _isOldRegime,
                          onChanged: (value) {
                            setState(() {
                              _isOldRegime = value ?? true;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('New Regime'),
                          value: false,
                          groupValue: _isOldRegime,
                          onChanged: (value) {
                            setState(() {
                              _isOldRegime = value ?? false;
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _calculateTaxSavingAmount,
                    child: const Text('Calculate'),
                  ),
                  if (_incomeController.text.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimated Tax Savings',
                            style: SpendexTheme.labelMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _calculateEstimatedSavings(),
                            style: SpendexTheme.headlineMedium.copyWith(
                              color: SpendexColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _calculateTaxSavingAmount() {
    setState(() {});
  }

  String _calculateEstimatedSavings() {
    final income = double.tryParse(_incomeController.text) ?? 0;
    if (income == 0) return '₹0';

    final investmentsState = ref.read(investmentsStateProvider);
    final taxSavingsData = _calculateTaxSavings(investmentsState.investments);
    final totalDeductions = _getTotalTaxSavings(taxSavingsData.sectionTotals);

    final savingsInPaise = (totalDeductions * _selectedTaxSlab / 100).round();

    return CurrencyFormatter.formatPaise(savingsInPaise, decimalDigits: 0);
  }

  Widget _buildSection80C(TaxSavingsData data) {
    const limit = 15000000;
    final amount = data.sectionTotals[TaxSection.section80C] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80C] ?? [];

    return _TaxSectionCard(
      title: 'Section 80C',
      subtitle: 'Investment in PPF, EPF, ELSS, Insurance, etc.',
      icon: Iconsax.shield_tick,
      amount: amount,
      limit: limit,
      investments: investments,
    );
  }

  Widget _buildSection80CCD(TaxSavingsData data) {
    const limit = 5000000;
    final amount = data.sectionTotals[TaxSection.section80CCD] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80CCD] ?? [];

    return _TaxSectionCard(
      title: 'Section 80CCD(1B)',
      subtitle: 'Additional NPS deduction',
      icon: Iconsax.security_user,
      amount: amount,
      limit: limit,
      investments: investments,
    );
  }

  Widget _buildSection80D(TaxSavingsData data) {
    const limit = 2500000;
    final amount = data.sectionTotals[TaxSection.section80D] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80D] ?? [];

    return _TaxSectionCard(
      title: 'Section 80D',
      subtitle: 'Health Insurance Premiums (Max ₹25K or ₹50K for senior citizens)',
      icon: Iconsax.health,
      amount: amount,
      limit: limit,
      investments: investments,
    );
  }

  Widget _buildSection80E(TaxSavingsData data) {
    final amount = data.sectionTotals[TaxSection.section80E] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80E] ?? [];

    return _TaxSectionCard(
      title: 'Section 80E',
      subtitle: 'Education Loan Interest (Unlimited deduction)',
      icon: Iconsax.teacher,
      amount: amount,
      limit: null,
      investments: investments,
    );
  }

  Widget _buildSection80G(TaxSavingsData data) {
    final amount = data.sectionTotals[TaxSection.section80G] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80G] ?? [];

    return _TaxSectionCard(
      title: 'Section 80G',
      subtitle: 'Charitable Donations (50%/100% deduction applicable)',
      icon: Iconsax.heart,
      amount: amount,
      limit: null,
      investments: investments,
      showHalfDeduction: true,
    );
  }

  Widget _buildSection80TTA(TaxSavingsData data) {
    const limit = 1000000;
    final amount = data.sectionTotals[TaxSection.section80TTA] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80TTA] ?? [];

    return _TaxSectionCard(
      title: 'Section 80TTA',
      subtitle: 'Savings Account Interest (Max ₹10,000)',
      icon: Iconsax.wallet_money,
      amount: amount,
      limit: limit,
      investments: investments,
    );
  }

  Widget _buildSection80TTB(TaxSavingsData data) {
    const limit = 5000000;
    final amount = data.sectionTotals[TaxSection.section80TTB] ?? 0;
    final investments = data.sectionInvestments[TaxSection.section80TTB] ?? [];

    return _TaxSectionCard(
      title: 'Section 80TTB',
      subtitle: 'Senior Citizen Interest Income (Max ₹50,000)',
      icon: Iconsax.user_octagon,
      amount: amount,
      limit: limit,
      investments: investments,
    );
  }
}

class TaxSavingsData {
  const TaxSavingsData({
    required this.sectionTotals,
    required this.sectionInvestments,
  });

  final Map<TaxSection, int> sectionTotals;
  final Map<TaxSection, List<InvestmentModel>> sectionInvestments;
}

class _TaxSectionCard extends StatelessWidget {
  const _TaxSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.amount,
    required this.investments,
    this.limit,
    this.showHalfDeduction = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int amount;
  final int? limit;
  final List<InvestmentModel> investments;
  final bool showHalfDeduction;

  @override
  Widget build(BuildContext context) {
    final hasLimit = limit != null;
    final displayAmount = showHalfDeduction ? (amount * 0.5).round() : amount;

    if (amount == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: SpendexColors.lightTextTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: SpendexColors.lightTextTertiary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SpendexTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No investments',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: SpendexColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: SpendexTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: SpendexColors.lightTextSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (hasLimit) ...[
                  _TaxProgressBar(
                    amount: amount,
                    limit: limit!,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount Saved: ${CurrencyFormatter.formatPaise(amount, decimalDigits: 0)}',
                        style: SpendexTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'of ${CurrencyFormatter.formatPaise(limit!, decimalDigits: 0)}',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (amount < limit!) ...[
                    Text(
                      'Remaining: ${CurrencyFormatter.formatPaise(limit! - amount, decimalDigits: 0)}',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.warning,
                      ),
                    ),
                  ],
                  if (showHalfDeduction) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Eligible Deduction: ${CurrencyFormatter.formatPaise(displayAmount, decimalDigits: 0)} (50%)',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: SpendexColors.primary,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Row(
                    children: [
                      Text(
                        'Amount: ',
                        style: SpendexTheme.bodyMedium,
                      ),
                      Text(
                        CurrencyFormatter.formatPaise(displayAmount, decimalDigits: 0),
                        style: SpendexTheme.titleMedium.copyWith(
                          color: SpendexColors.primary,
                          fontSize: 18,
                        ),
                      ),
                      if (showHalfDeduction) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(50% of ${CurrencyFormatter.formatPaise(amount, decimalDigits: 0)})',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SpendexColors.income.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unlimited Deduction',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.income,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (investments.isNotEmpty) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: investments.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _TaxInvestmentTile(investment: investments[index]);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _TaxProgressBar extends StatelessWidget {
  const _TaxProgressBar({
    required this.amount,
    required this.limit,
  });

  final int amount;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final percentage = (amount / limit).clamp(0.0, 1.0);

    Color barColor;
    if (percentage < 0.8) {
      barColor = SpendexColors.income;
    } else if (percentage < 1.0) {
      barColor = SpendexColors.warning;
    } else {
      barColor = SpendexColors.expense;
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: SpendexColors.lightDivider,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

class _TaxInvestmentTile extends ConsumerWidget {
  const _TaxInvestmentTile({required this.investment});

  final InvestmentModel investment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isProfit = investment.returns >= 0;

    return InkWell(
      onTap: () => context.push('/investments/${investment.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getInvestmentTypeIcon(investment.type),
                color: SpendexColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.name,
                    style: SpendexTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    investment.type.label,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatPaise(investment.investedAmount, decimalDigits: 0),
                  style: SpendexTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (investment.returns != 0)
                  Text(
                    '${isProfit ? '+' : ''}${CurrencyFormatter.formatPaise(investment.returns, decimalDigits: 0)}',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isProfit ? SpendexColors.income : SpendexColors.expense,
                    ),
                  ),
              ],
            ),
          ],
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
        return Iconsax.safe_home;
      case InvestmentType.ppf:
      case InvestmentType.epf:
        return Iconsax.shield_tick;
      case InvestmentType.nps:
        return Iconsax.security_user;
      case InvestmentType.gold:
      case InvestmentType.sovereignGoldBond:
        return Iconsax.coin;
      case InvestmentType.realEstate:
        return Iconsax.home;
      case InvestmentType.crypto:
        return Iconsax.bitcoin_card;
      default:
        return Iconsax.money;
    }
  }
}

class _FYSelectorSheet extends StatelessWidget {
  const _FYSelectorSheet({
    required this.selectedYear,
    required this.years,
    required this.onYearSelected,
  });

  final String selectedYear;
  final List<String> years;
  final void Function(String) onYearSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Select Financial Year',
                  style: SpendexTheme.headlineMedium,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == selectedYear;

              return ListTile(
                title: Text(
                  'FY $year',
                  style: SpendexTheme.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Iconsax.tick_circle5,
                        color: SpendexColors.primary,
                      )
                    : null,
                onTap: () => onYearSelected(year),
              );
            },
          ),
        ],
      ),
    );
  }
}
