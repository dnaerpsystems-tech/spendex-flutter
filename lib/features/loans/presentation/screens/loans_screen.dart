import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/loan_model.dart';
import '../providers/loans_provider.dart';
import '../widgets/loan_card.dart';
import '../widgets/loans_summary_card.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});

  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loansStateProvider.notifier).loadAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(loansStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(loansSummaryProvider);
    final loans = ref.watch(loansListProvider);
    final isLoading = ref.watch(loansLoadingProvider);
    final error = ref.watch(loansErrorProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Loans & EMIs'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: isLoading ? null : _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: SpendexColors.primary,
        child: CustomScrollView(
          slivers: [
            if (summary != null && !isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: LoansSummaryCard(summary: summary),
                ),
              ),

            if (isLoading && summary == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _LoansSummarySkeleton(isDark: isDark),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            if (isLoading && loans.isEmpty)
              _buildLoadingSkeleton(isDark)
            else if (error != null && loans.isEmpty)
              _buildErrorState(error)
            else if (loans.isEmpty)
              _buildEmptyState()
            else
              _buildLoansList(loans, isDark),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/loans/add'),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Loan'),
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _LoanCardSkeleton(isDark: isDark),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorStateWidget(
        title: 'Failed to load loans',
        message: error,
        onRetry: _refresh,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(
        icon: Iconsax.money_send,
        title: 'No Loans Yet',
        subtitle: 'Start tracking your loans and EMIs',
        actionLabel: 'Add Loan',
        actionIcon: Iconsax.add,
        onAction: () => context.push('/loans/add'),
      ),
    );
  }

  Widget _buildLoansList(List<LoanModel> loans, bool isDark) {
    final activeLoans = loans.where((l) => l.isActive).toList();
    final closedLoans = loans.where((l) => l.isClosed).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < activeLoans.length) {
              final loan = activeLoans[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Active Loans',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  LoanCard(
                    loan: loan,
                    isDark: isDark,
                    onTap: () => context.push('/loans/${loan.id}'),
                  ),
                ],
              );
            } else {
              final closedIndex = index - activeLoans.length;
              if (closedIndex >= closedLoans.length) {
                return null;
              }
              final loan = closedLoans[closedIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (closedIndex == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        'Closed Loans',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  LoanCard(
                    loan: loan,
                    isDark: isDark,
                    onTap: () => context.push('/loans/${loan.id}'),
                  ),
                ],
              );
            }
          },
          childCount: activeLoans.length + closedLoans.length,
        ),
      ),
    );
  }
}

class _LoansSummarySkeleton extends StatelessWidget {
  const _LoansSummarySkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 70,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoanCardSkeleton extends StatelessWidget {
  const _LoanCardSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color:
                isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder,
                          borderRadius:
                              BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder,
                          borderRadius:
                              BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
