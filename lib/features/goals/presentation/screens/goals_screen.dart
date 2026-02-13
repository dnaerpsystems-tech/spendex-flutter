import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/goal_model.dart';
import '../providers/goals_provider.dart';
import '../widgets/goal_card.dart';
import '../widgets/goals_summary_card.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(goalsStateProvider.notifier).loadAll();
    });
  }

  Future<void> _refresh() async {
    await ref.read(goalsStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = ref.watch(goalsSummaryProvider);
    final goals = ref.watch(goalsListProvider);
    final isLoading = ref.watch(goalsLoadingProvider);
    final error = ref.watch(goalsErrorProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Goals'),
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
                  child: GoalsSummaryCard(summary: summary),
                ),
              ),

            if (isLoading && summary == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _SummaryCardSkeleton(isDark: isDark),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            if (isLoading && goals.isEmpty)
              _buildLoadingSkeleton(isDark)
            else if (error != null && goals.isEmpty)
              _buildErrorState(error)
            else if (goals.isEmpty)
              _buildEmptyState()
            else
              _buildGoalsList(goals, isDark),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addGoal),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Goal'),
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
          (context, index) => _GoalCardSkeleton(isDark: isDark),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: ErrorStateWidget(
        title: 'Failed to load goals',
        message: error,
        onRetry: _refresh,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyStateWidget(
        icon: Iconsax.flag,
        title: 'No Goals Yet',
        subtitle: 'Start tracking your savings goals',
        actionLabel: 'Create Goal',
        actionIcon: Iconsax.add,
        onAction: () => context.push(AppRoutes.addGoal),
      ),
    );
  }

  Widget _buildGoalsList(List<GoalModel> goals, bool isDark) {
    final activeGoals = goals.where((g) => g.isActive).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < activeGoals.length) {
              final goal = activeGoals[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index == 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Active Goals',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  GoalCard(
                    goal: goal,
                    onTap: () => context.push('/goals/${goal.id}'),
                  ),
                ],
              );
            } else {
              final completedIndex = index - activeGoals.length;
              if (completedIndex >= completedGoals.length) {
                return null;
              }
              final goal = completedGoals[completedIndex];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (completedIndex == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      child: Text(
                        'Completed Goals',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  GoalCard(
                    goal: goal,
                    onTap: () => context.push('/goals/${goal.id}'),
                  ),
                ],
              );
            }
          },
          childCount: activeGoals.length + completedGoals.length,
        ),
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton({required this.isDark});

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
                      width: 60,
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
                      width: 40,
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
                      width: 60,
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
                      width: 40,
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
          Row(
            children: [
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
                      width: 80,
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
                      width: 80,
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
        ],
      ),
    );
  }
}


class _GoalCardSkeleton extends StatelessWidget {
  const _GoalCardSkeleton({required this.isDark});

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
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
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
                    width: 120,
                    height: 14,
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
                    height: 12,
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
      ),
    );
  }
}
