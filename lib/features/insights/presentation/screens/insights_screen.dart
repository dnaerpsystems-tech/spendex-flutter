import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/firebase/analytics_events.dart';
import '../../../../core/firebase/analytics_service.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/insight_model.dart';
import '../providers/insights_provider.dart';
import '../widgets/insight_card.dart';
import '../widgets/insights_filter_chips.dart';

/// Main Insights screen displaying all financial insights with filtering capabilities.
///
/// Features:
/// - Filter by insight type
/// - Unread count banner
/// - Grouped by priority (High, Medium, Low)
/// - Pull-to-refresh functionality
/// - Generate new insights with AI
/// - Navigate to detail view
/// - Dismiss individual insights
class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    // Analytics screen view
    AnalyticsService.logScreenView(screenName: AnalyticsEvents.screenInsights);
    // Load insights on initialization if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(insightsStateProvider);
      if (state.allInsights.isEmpty && !state.isLoading) {
        ref.read(insightsStateProvider.notifier).loadAll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsStateProvider);
    final insights = ref.watch(allInsightsProvider);
    final unreadCount = ref.watch(unreadCountProvider);
    final isLoading = ref.watch(insightsLoadingProvider);
    final error = ref.watch(insightsErrorProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () => ref.read(insightsStateProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            // Filter Chips
            _buildFilterChips(state.selectedType, insights),

            // Unread Count Banner
            if (unreadCount > 0) _buildUnreadBanner(unreadCount),

            // Content based on state
            if (isLoading)
              _buildLoadingState()
            else if (error != null)
              _buildErrorState(error)
            else if (insights.isEmpty)
              _buildEmptyState()
            else
              _buildInsightsList(insights),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(state.isGenerating),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Insights'),
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Iconsax.refresh),
          onPressed: () {
            ref.read(insightsStateProvider.notifier).refresh();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChips(InsightType? selectedType, List<InsightModel> insights) {
    // Calculate type counts
    final typeCounts = <InsightType, int>{};
    for (final insight in insights) {
      typeCounts[insight.type] = (typeCounts[insight.type] ?? 0) + 1;
    }

    return SliverToBoxAdapter(
      child: InsightsFilterChips(
        selectedType: selectedType,
        typeCounts: typeCounts,
        onTypeSelected: (type) {
          ref.read(insightsStateProvider.notifier).filterByType(type);
        },
      ),
    );
  }

  Widget _buildUnreadBanner(int count) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingLg,
          vertical: SpendexTheme.spacingSm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingMd,
          vertical: SpendexTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: SpendexColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: SpendexColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Iconsax.notification,
              size: 20,
              color: SpendexColors.primary,
            ),
            const SizedBox(width: SpendexTheme.spacingSm),
            Expanded(
              child: Text(
                '$count new insight${count == 1 ? '' : 's'}',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: SpendexColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SliverShimmerLoadingList(
      itemCount: 5,
      itemHeight: 120,
      padding: EdgeInsets.all(SpendexTheme.spacingLg),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverErrorStateWidget(
      message: error,
      title: 'Failed to Load Insights',
      onRetry: () {
        ref.read(insightsStateProvider.notifier).loadAll();
      },
    );
  }

  Widget _buildEmptyState() {
    return SliverEmptyStateWidget(
      icon: Iconsax.lamp_1,
      title: 'No Insights Yet',
      subtitle: 'Generate insights to discover spending patterns',
      actionLabel: 'Generate Insights',
      actionIcon: Iconsax.magic_star,
      onAction: _generateInsights,
    );
  }

  Widget _buildInsightsList(List<InsightModel> insights) {
    // Group insights by priority
    final highPriority = insights.where((i) => i.priority == InsightPriority.high).toList();
    final mediumPriority = insights.where((i) => i.priority == InsightPriority.medium).toList();
    final lowPriority = insights.where((i) => i.priority == InsightPriority.low).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        // High Priority Section
        if (highPriority.isNotEmpty) ...[
          _buildSectionHeader('High Priority', SpendexColors.expense),
          ...highPriority.map(_buildInsightCard),
        ],

        // Medium Priority Section
        if (mediumPriority.isNotEmpty) ...[
          _buildSectionHeader('Medium Priority', SpendexColors.primary),
          ...mediumPriority.map(_buildInsightCard),
        ],

        // Low Priority Section
        if (lowPriority.isNotEmpty) ...[
          _buildSectionHeader('Low Priority', Colors.grey),
          ...lowPriority.map(_buildInsightCard),
        ],

        // Bottom spacing for FAB
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpendexTheme.spacingLg,
        SpendexTheme.spacingLg,
        SpendexTheme.spacingLg,
        SpendexTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Text(
            title,
            style: SpendexTheme.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(InsightModel insight) {
    return InsightCard(
      insight: insight,
      onTap: () {
        // Mark as read when tapped
        ref.read(insightsStateProvider.notifier).markAsRead(insight.id);
        // Navigate to detail screen
        context.push('/insights/${insight.id}');
      },
      onDismiss: () {
        ref.read(insightsStateProvider.notifier).dismiss(insight.id);
      },
      onActionTap: () => _handleAction(insight),
    );
  }

  Widget _buildFAB(bool isGenerating) {
    return FloatingActionButton.extended(
      onPressed: isGenerating ? null : _generateInsights,
      icon: isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Iconsax.magic_star),
      label: Text(isGenerating ? 'Generating...' : 'Generate Insights'),
      backgroundColor:
          isGenerating ? SpendexColors.primary.withValues(alpha: 0.5) : SpendexColors.primary,
    );
  }

  void _generateInsights() {
    // Create a default request for last 30 days
    const request = CreateInsightRequest(
      type: InsightType.spendingPattern,
      title: 'Auto-generated insights',
      description: 'AI-generated financial insights based on recent transactions',
    );

    ref.read(insightsStateProvider.notifier).generateInsights(request);
  }

  void _handleAction(InsightModel insight) {
    switch (insight.actionType) {
      case InsightActionType.viewTransactions:
        // Navigate to transactions with filter
        final categoryId = insight.actionData?['category_id'];
        if (categoryId != null) {
          context.push('/transactions?category=$categoryId');
        } else {
          context.push('/transactions');
        }
        break;

      case InsightActionType.setBudget:
        // Navigate to add budget screen
        final categoryId = insight.actionData?['category_id'];
        if (categoryId != null) {
          context.push('/budgets/add?category=$categoryId');
        } else {
          context.push('/budgets/add');
        }
        break;

      case InsightActionType.setGoal:
        // Navigate to add goal screen
        context.push('/goals/add');
        break;

      case InsightActionType.viewCategory:
        // Navigate to category details
        final categoryId = insight.actionData?['category_id'];
        if (categoryId != null) {
          context.push('/categories/$categoryId');
        }
        break;

      case InsightActionType.viewMerchant:
        // Navigate to transactions with merchant filter
        final merchantName = insight.actionData?['merchant_name'];
        if (merchantName != null) {
          context.push('/transactions?merchant=$merchantName');
        } else {
          context.push('/transactions');
        }
        break;

      case InsightActionType.viewAccount:
        // Navigate to account details
        final accountId = insight.actionData?['account_id'];
        if (accountId != null) {
          context.push('/accounts/$accountId');
        }
        break;

      case InsightActionType.viewLoan:
        // Navigate to loan details
        final loanId = insight.actionData?['loan_id'];
        if (loanId != null) {
          context.push('/loans/$loanId');
        }
        break;

      case InsightActionType.none:
        // No action
        break;
    }
  }
}
