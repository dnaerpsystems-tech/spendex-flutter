import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/goal_model.dart';
import '../providers/goals_provider.dart';
import '../widgets/add_contribution_sheet.dart';
import '../widgets/goal_progress_ring.dart';

class GoalDetailsScreen extends ConsumerStatefulWidget {
  const GoalDetailsScreen({required this.goalId, super.key});

  final String goalId;

  @override
  ConsumerState<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends ConsumerState<GoalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Analytics screen view
    AnalyticsService.logScreenView(screenName: AnalyticsEvents.screenGoalDetails);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalsStateProvider.notifier).loadGoalById(widget.goalId);
    });
  }

  Future<void> _refresh() async {
    await ref.read(goalsStateProvider.notifier).loadGoalById(widget.goalId);
  }

  Color _getGoalColor(GoalModel goal) {
    if (goal.color != null) {
      try {
        return Color(int.parse(goal.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return SpendexColors.primary;
      }
    }
    return SpendexColors.primary;
  }

  IconData _getGoalIcon(GoalModel goal) {
    if (goal.icon == null) {
      return Iconsax.flag;
    }

    final iconMap = {
      'home': Iconsax.home,
      'car': Iconsax.car,
      'airplane': Iconsax.airplane,
      'shopping_bag': Iconsax.shopping_bag,
      'wallet': Iconsax.wallet_3,
      'heart': Iconsax.heart,
      'gift': Iconsax.gift,
      'briefcase': Iconsax.briefcase,
      'crown': Iconsax.crown,
      'medal': Iconsax.medal,
      'money': Iconsax.money,
      'bank': Iconsax.bank,
      'safe': Iconsax.safe_home,
      'graduation': Iconsax.book,
      'flag': Iconsax.flag,
    };

    return iconMap[goal.icon] ?? Iconsax.flag;
  }

  void _showDeleteConfirmation(GoalModel goal) {
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
            const Text('Delete Goal'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${goal.name}"? This action cannot be undone.',
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
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

              final success = await ref.read(goalsStateProvider.notifier).deleteGoal(widget.goalId);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Goal deleted'),
                      backgroundColor: SpendexColors.income,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete goal'),
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

  void _showAddContributionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddContributionSheet(goalId: widget.goalId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsState = ref.watch(goalsStateProvider);
    final goal = goalsState.selectedGoal;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(goal?.name ?? 'Goal Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (goal != null) ...[
            IconButton(
              icon: const Icon(Iconsax.edit_2),
              onPressed: () => context.push('/goals/edit/${goal.id}'),
            ),
            IconButton(
              icon: const Icon(Iconsax.trash, color: SpendexColors.expense),
              onPressed: () => _showDeleteConfirmation(goal),
            ),
          ],
        ],
      ),
      body: goalsState.isLoading && goal == null
          ? const Center(child: CircularProgressIndicator())
          : goal == null
              ? _buildErrorState(goalsState.error ?? 'Goal not found')
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: SpendexColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroSection(goal, isDark),
                        const SizedBox(height: 20),
                        _buildGoalInfoCard(goal, isDark),
                        const SizedBox(height: 20),
                        _buildAddContributionSection(goal, isDark),
                        const SizedBox(height: 20),
                        _buildContributionHistorySection(goal, isDark),
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
              'Failed to load goal',
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

  Widget _buildHeroSection(GoalModel goal, bool isDark) {
    final goalColor = _getGoalColor(goal);
    final goalIcon = _getGoalIcon(goal);
    final progressPercentage = goal.progress.clamp(0, 100);
    final isCompleted = progressPercentage >= 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  goalColor.withValues(alpha: 0.2),
                  goalColor.withValues(alpha: 0.1),
                ]
              : [
                  goalColor.withValues(alpha: 0.15),
                  goalColor.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: goalColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SpendexColors.income.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                border: Border.all(
                  color: SpendexColors.income.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.cup5,
                    color: SpendexColors.income,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Goal Achieved!',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: SpendexColors.income,
                    ),
                  ),
                ],
              ),
            ),
          if (isCompleted) const SizedBox(height: 20),
          GoalProgressRing(
            progress: progressPercentage / 100,
            color: goalColor,
            size: 240,
            strokeWidth: 16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  goalIcon,
                  color: goalColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: SpendexTheme.displayLarge.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalInfoCard(GoalModel goal, bool isDark) {
    final goalColor = _getGoalColor(goal);
    final remaining = goal.targetAmount - goal.currentAmount;
    final daysRemaining = goal.daysRemaining;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatPaise(goal.currentAmount),
                      style: SpendexTheme.headlineMedium.copyWith(
                        color: goalColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatPaise(goal.targetAmount),
                      style: SpendexTheme.headlineMedium.copyWith(
                        color:
                            isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatPaise(remaining > 0 ? remaining : 0),
                  style: SpendexTheme.titleMedium.copyWith(
                    color: remaining > 0
                        ? (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary)
                        : SpendexColors.income,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (goal.targetDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar,
                    size: 18,
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Date',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('dd MMM yyyy').format(goal.targetDate!),
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (daysRemaining != null && daysRemaining > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                      child: Text(
                        '$daysRemaining days',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: SpendexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(goal.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                  child: Text(
                    goal.status.label,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: _getStatusColor(goal.status),
                      fontWeight: FontWeight.w600,
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

  Color _getStatusColor(GoalStatus status) {
    switch (status) {
      case GoalStatus.active:
        return SpendexColors.primary;
      case GoalStatus.completed:
        return SpendexColors.income;
      case GoalStatus.cancelled:
        return SpendexColors.expense;
    }
  }

  Widget _buildAddContributionSection(GoalModel goal, bool isDark) {
    return GestureDetector(
      onTap: _showAddContributionSheet,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SpendexColors.income.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color: SpendexColors.income.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: SpendexColors.income,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Contribution',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: SpendexColors.income,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Save money towards your goal',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              color: SpendexColors.income,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionHistorySection(GoalModel goal, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contributions',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              ),
              child: Text(
                '0',
                style: SpendexTheme.labelMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
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
                  Iconsax.wallet_add,
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Contributions Yet',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start saving towards your goal',
                style: SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
