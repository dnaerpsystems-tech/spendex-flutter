import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../goals/presentation/widgets/goal_progress_ring.dart';
import '../../data/models/loan_model.dart';
import '../providers/loans_provider.dart';
import '../widgets/emi_schedule_tile.dart';
import '../widgets/loan_info_card.dart';
import '../widgets/mark_emi_paid_sheet.dart';

class LoanDetailsScreen extends ConsumerStatefulWidget {
  const LoanDetailsScreen({required this.loanId, super.key});

  final String loanId;

  @override
  ConsumerState<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends ConsumerState<LoanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loansStateProvider.notifier).loadLoanById(widget.loanId);
    });
  }

  Future<void> _refresh() async {
    await ref.read(loansStateProvider.notifier).loadLoanById(widget.loanId);
  }

  IconData _getLoanIcon(LoanType type) {
    switch (type) {
      case LoanType.home:
        return Iconsax.home;
      case LoanType.vehicle:
        return Iconsax.car;
      case LoanType.personal:
        return Iconsax.wallet_money;
      case LoanType.education:
        return Iconsax.book;
      case LoanType.gold:
        return Iconsax.medal_star;
      case LoanType.business:
        return Iconsax.brifecase_tick;
      case LoanType.other:
        return Iconsax.receipt_item;
    }
  }

  // ignore: unused_element
  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return SpendexColors.primary;
      case LoanStatus.closed:
        return SpendexColors.income;
      case LoanStatus.defaulted:
        return SpendexColors.expense;
    }
  }

  void _showDeleteConfirmation(LoanModel loan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.trash,
                color: SpendexColors.expense,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Loan'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this loan? This action cannot be undone.',
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await ref
                  .read(loansStateProvider.notifier)
                  .deleteLoan(widget.loanId);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loan deleted'),
                      backgroundColor: SpendexColors.income,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete loan'),
                      backgroundColor: SpendexColors.expense,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SpendexColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMarkEmiPaidSheet(EmiSchedule emi) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MarkEmiPaidSheet(
        loanId: widget.loanId,
        emi: emi,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loansState = ref.watch(loansStateProvider);
    final loan = loansState.selectedLoan;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Loan Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (loan != null) ...[
            IconButton(
              icon: const Icon(Iconsax.edit_2),
              onPressed: () => context.push('/loans/add?id=${loan.id}'),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: SpendexColors.expense),
              onPressed: () => _showDeleteConfirmation(loan),
            ),
          ],
        ],
      ),
      body: loansState.isLoading && loan == null
          ? const Center(child: CircularProgressIndicator())
          : loan == null
              ? _buildErrorState(loansState.error ?? 'Loan not found')
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: SpendexColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LoanHeader(loan: loan, icon: _getLoanIcon(loan.type)),
                        const SizedBox(height: 20),
                        _buildProgressSection(loan, isDark),
                        const SizedBox(height: 20),
                        InfoCard(
                          title: 'Loan Information',
                          child: Column(
                            children: [
                              InfoRow(
                                label: 'Principal Amount',
                                value: CurrencyFormatter.formatPaise(loan.principalAmount),
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'Interest Rate',
                                value: '${loan.interestRate.toStringAsFixed(2)}%',
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'Tenure',
                                value: '${loan.tenure} months',
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'EMI Amount',
                                value: CurrencyFormatter.formatPaise(loan.emiAmount),
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'Start Date',
                                value: DateFormat('dd MMM yyyy').format(loan.startDate),
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'Total Interest',
                                value: CurrencyFormatter.formatPaise(loan.totalInterest),
                                valueColor: SpendexColors.expense,
                              ),
                              const SizedBox(height: 12),
                              InfoRow(
                                label: 'Total Payable',
                                value: CurrencyFormatter.formatPaise(
                                  loan.principalAmount + loan.totalInterest,
                                ),
                                isBold: true,
                              ),
                              if (loan.type == LoanType.home || loan.type == LoanType.education) ...[
                                const SizedBox(height: 16),
                                _TaxBadge(loanType: loan.type),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        InfoCard(
                          title: 'Payment Progress',
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoRow(
                                      label: 'Total Paid',
                                      value: CurrencyFormatter.formatPaise(loan.totalPaid),
                                      valueColor: SpendexColors.income,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: InfoRow(
                                      label: 'Remaining',
                                      value: CurrencyFormatter.formatPaise(loan.remainingAmount),
                                      valueColor: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InfoRow(
                                      label: 'EMIs Paid',
                                      value: '${loan.paidEmis} of ${loan.tenure}',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (loan.nextEmiDate != null)
                                    Expanded(
                                      child: InfoRow(
                                        label: 'Next EMI Date',
                                        value: DateFormat('dd MMM yyyy').format(loan.nextEmiDate!),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildEmiScheduleSection(loan, isDark),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
      floatingActionButton: loan != null && loan.isActive && loan.remainingEmis > 0
          ? FloatingActionButton.extended(
              onPressed: () {
                final nextUnpaidEmi = loan.emiSchedule.firstWhere(
                  (emi) => !emi.isPaid,
                );
                _showMarkEmiPaidSheet(nextUnpaidEmi);
              },
              backgroundColor: SpendexColors.primary,
              label: const Text('Mark Next EMI Paid'),
              icon: const Icon(Iconsax.tick_circle),
            )
          : null,
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: SpendexColors.expense,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load loan',
              style: SpendexTheme.headlineMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: SpendexTheme.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(LoanModel loan, bool isDark) {
    final totalPayable = loan.principalAmount + loan.totalInterest;
    final progress = totalPayable > 0 ? loan.totalPaid / totalPayable : 0.0;
    final progressPercentage = (progress * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          GoalProgressRing(
            progress: progress,
            color: loan.isActive ? SpendexColors.primary : SpendexColors.income,
            size: 200,
            strokeWidth: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  CurrencyFormatter.formatPaise(loan.totalPaid),
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${CurrencyFormatter.formatPaise(totalPayable)}',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${progressPercentage.toStringAsFixed(1)}% Paid',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmiScheduleSection(LoanModel loan, bool isDark) {
    if (loan.emiSchedule.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Iconsax.calendar,
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No EMI Schedule Available',
              style: SpendexTheme.titleMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EMI Schedule',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              ),
              child: Text(
                '${loan.emiSchedule.length}',
                style: SpendexTheme.labelMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: loan.emiSchedule.length,
          itemBuilder: (context, index) {
            final emi = loan.emiSchedule[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: EmiScheduleTile(
                emi: emi,
                onTap: !emi.isPaid ? () => _showMarkEmiPaidSheet(emi) : null,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LoanHeader extends StatelessWidget {
  const _LoanHeader({
    required this.loan,
    required this.icon,
  });

  final LoanModel loan;
  final IconData icon;

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.active:
        return SpendexColors.primary;
      case LoanStatus.closed:
        return SpendexColors.income;
      case LoanStatus.defaulted:
        return SpendexColors.expense;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: SpendexColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loan.name,
            style: SpendexTheme.headlineMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            loan.type.label,
            style: SpendexTheme.bodyMedium.copyWith(
              fontSize: 13,
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(loan.status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: Text(
              loan.status.label,
              style: SpendexTheme.labelMedium.copyWith(
                color: _getStatusColor(loan.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (loan.lender != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.building,
                  size: 16,
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  loan.lender!,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (loan.accountNumber != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.card,
                  size: 16,
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  loan.accountNumber!,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TaxBadge extends StatelessWidget {
  const _TaxBadge({required this.loanType});

  final LoanType loanType;

  @override
  Widget build(BuildContext context) {

    String text;
    if (loanType == LoanType.home) {
      text = '80C Eligible (Principal)';
    } else if (loanType == LoanType.education) {
      text = '80E Eligible (Interest)';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SpendexColors.income.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: SpendexColors.income.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: SpendexColors.income,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.income,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
