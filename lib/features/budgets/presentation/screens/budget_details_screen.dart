import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../data/models/budget_model.dart';
import '../providers/budgets_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_progress_bar.dart';

/// Budget Details Screen
/// Displays detailed budget information, progress, and spending breakdown
class BudgetDetailsScreen extends ConsumerStatefulWidget {

  const BudgetDetailsScreen({required this.budgetId, super.key});
  final String budgetId;

  @override
  ConsumerState<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends ConsumerState<BudgetDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetsStateProvider.notifier).getBudgetById(widget.budgetId);
    });
  }

  Future<void> _refresh() async {
    await ref.read(budgetsStateProvider.notifier).getBudgetById(widget.budgetId);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(double percentage) {
    if (percentage >= 100) {
      return SpendexColors.expense;
    }
    if (percentage >= 80) {
      return const Color(0xFFF97316);
    }
    if (percentage >= 60) {
      return SpendexColors.warning;
    }
    return SpendexColors.income;
  }

  void _showDeleteConfirmation(BudgetModel budget) {
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
            const Text('Delete Budget'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
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
                  .read(budgetsStateProvider.notifier)
                  .deleteBudget(widget.budgetId);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget deleted'),
                      backgroundColor: SpendexColors.income,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete budget'),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgetsState = ref.watch(budgetsStateProvider);
    final budget = budgetsState.selectedBudget;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Budget Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (budget != null) ...[
            IconButton(
              icon: const Icon(Iconsax.edit_2),
              onPressed: () => context.push('${AppRoutes.addBudget}?id=${budget.id}'),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: SpendexColors.expense),
              onPressed: () => _showDeleteConfirmation(budget),
            ),
          ],
        ],
      ),
      body: budgetsState.isLoading && budget == null
          ? const Center(child: CircularProgressIndicator())
          : budget == null
              ? _buildErrorState(budgetsState.error ?? 'Budget not found')
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: SpendexColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Budget Detail Card
                        BudgetDetailCard(
                          budget: budget,
                          onEdit: () => context.push(
                            '${AppRoutes.addBudget}?id=${budget.id}',
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Daily Spending Chart (Simplified visualization)
                        _buildSpendingChart(budget, isDark),

                        const SizedBox(height: 24),

                        // Budget Info
                        _buildBudgetInfo(budget, isDark),

                        const SizedBox(height: 24),

                        // Quick Actions
                        _buildQuickActions(budget, isDark),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
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
              'Failed to load budget',
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

  Widget _buildSpendingChart(BudgetModel budget, bool isDark) {
    final statusColor = _getStatusColor(budget.percentage);
    final daysTotal = budget.endDate.difference(budget.startDate).inDays;
    final daysPassed = DateTime.now().difference(budget.startDate).inDays;
    final expectedPercentage = daysTotal > 0 ? (daysPassed / daysTotal) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(20),
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
                'Spending Progress',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  budget.status == BudgetStatus.onTrack
                      ? 'On Track'
                      : budget.status == BudgetStatus.warning
                          ? 'Warning'
                          : 'Over Budget',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Actual vs Expected
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actual Spending',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetProgressBar(
                      percentage: budget.percentage,
                      alertThreshold: budget.alertThreshold,
                      height: 12,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${budget.percentage.toStringAsFixed(1)}% spent',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Expected progress
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expected Progress',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: (expectedPercentage / 100).clamp(0.0, 1.0),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: SpendexColors.primary.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expectedPercentage.toStringAsFixed(1)}% of period',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Comparison message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  budget.percentage <= expectedPercentage
                      ? Iconsax.tick_circle
                      : Iconsax.info_circle,
                  size: 18,
                  color: budget.percentage <= expectedPercentage
                      ? SpendexColors.income
                      : SpendexColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    budget.percentage <= expectedPercentage
                        ? "You're spending less than expected. Keep it up!"
                        : "You're spending faster than expected. Consider slowing down.",
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetInfo(BudgetModel budget, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            'Budget Details',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Iconsax.calendar,
            label: 'Period',
            value: budget.period.label,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Iconsax.calendar_tick,
            label: 'Start Date',
            value: _formatDate(budget.startDate),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Iconsax.calendar_remove,
            label: 'End Date',
            value: _formatDate(budget.endDate),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Iconsax.notification,
            label: 'Alert Threshold',
            value: '${budget.alertThreshold}%',
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Iconsax.refresh_2,
            label: 'Rollover',
            value: budget.rollover ? 'Enabled' : 'Disabled',
            isDark: isDark,
          ),
          if (budget.category != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Iconsax.category,
              label: 'Category',
              value: budget.category!.name,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BudgetModel budget, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: SpendexTheme.titleMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Iconsax.add,
                label: 'Add Expense',
                color: SpendexColors.expense,
                onTap: () => context.push(AppRoutes.addTransaction),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Iconsax.edit_2,
                label: 'Edit Budget',
                color: SpendexColors.primary,
                onTap: () => context.push('${AppRoutes.addBudget}?id=${budget.id}'),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark
              ? SpendexColors.darkTextTertiary
              : SpendexColors.lightTextTertiary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
