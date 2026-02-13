import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:spendex/app/theme.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';
import 'package:spendex/features/duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import 'package:spendex/features/duplicate_detection/presentation/widgets/batch_resolution_dialog.dart';
import 'package:spendex/features/duplicate_detection/presentation/widgets/duplicate_match_card.dart';
import 'package:spendex/shared/widgets/empty_state_widget.dart';
import 'package:spendex/shared/widgets/loading_state_widget.dart';

/// Screen for resolving detected duplicate transactions
class DuplicateResolutionScreen extends ConsumerStatefulWidget {
  const DuplicateResolutionScreen({
    required this.importId,
    required this.transactions,
    super.key,
  });

  /// Import batch ID
  final String importId;

  /// List of transactions to check for duplicates
  final List<ParsedTransactionModel> transactions;

  @override
  ConsumerState<DuplicateResolutionScreen> createState() =>
      _DuplicateResolutionScreenState();
}

class _DuplicateResolutionScreenState
    extends ConsumerState<DuplicateResolutionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _expandedCards = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Detect duplicates on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(duplicateDetectionProvider.notifier).detectDuplicates(
            transactions: widget.transactions,
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duplicateDetectionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duplicate Detection'),
        actions: [
          if (state.result != null && state.hasDuplicates)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'apply_all',
                  child: Row(
                    children: [
                      Icon(Icons.auto_fix_high),
                      SizedBox(width: 12),
                      Text('Apply to All'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: 12),
                      Text('Clear Resolutions'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(state, colorScheme),
      bottomNavigationBar: state.result != null && state.hasDuplicates
          ? _buildBottomBar(state, colorScheme)
          : null,
    );
  }

  Widget _buildBody(DuplicateDetectionState state, ColorScheme colorScheme) {
    // Loading state
    if (state.isDetecting) {
      return const LoadingStateWidget(
        message: 'Checking for duplicates...',
      );
    }

    // Error state
    if (state.error != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline,
        title: 'Error Detecting Duplicates',
        subtitle: state.error,
        iconColor: SpendexColors.expense,
        actionLabel: 'Retry',
        actionIcon: Icons.refresh,
        onAction: () {
          ref.read(duplicateDetectionProvider.notifier).detectDuplicates(
                transactions: widget.transactions,
              );
        },
      );
    }

    // No result yet
    if (state.result == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // No duplicates found
    if (!state.hasDuplicates) {
      return EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'No Duplicates Found',
        subtitle:
            'All ${state.result!.totalChecked} transactions are unique and ready to import.',
        iconColor: SpendexColors.primary,
        actionLabel: 'Continue Import',
        actionIcon: Icons.arrow_forward,
        onAction: () => _confirmImport(),
      );
    }

    // Show duplicates
    return Column(
      children: [
        // Summary card
        _buildSummaryCard(state, colorScheme),

        // Tabs
        Container(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: SpendexColors.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: SpendexColors.primary,
            tabs: [
              Tab(
                text: 'All (${state.totalDuplicates})',
              ),
              Tab(
                text: 'High (${state.result!.highConfidenceDuplicates.length})',
              ),
              Tab(
                text:
                    'Medium (${state.result!.mediumConfidenceDuplicates.length})',
              ),
              Tab(
                text: 'Low (${state.result!.lowConfidenceDuplicates.length})',
              ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDuplicateList(state.result!.duplicateMatches),
              _buildDuplicateList(state.result!.highConfidenceDuplicates),
              _buildDuplicateList(state.result!.mediumConfidenceDuplicates),
              _buildDuplicateList(state.result!.lowConfidenceDuplicates),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    DuplicateDetectionState state,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(SpendexTheme.spacingLg),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: SpendexColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: SpendexColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: SpendexColors.warning,
            size: 32,
          ),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.totalDuplicates} Duplicates Found',
                  style: SpendexTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.result!.uniqueTransactions.length} unique transactions',
                  style: SpendexTheme.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (state.resolvedCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.progressText,
                    style: SpendexTheme.bodySmall.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicateList(List<DuplicateMatchModel> matches) {
    if (matches.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'No Duplicates',
        subtitle: 'This confidence level has no duplicates.',
        iconColor: SpendexColors.primary,
        compact: true,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        bottom: SpendexTheme.spacing3xl * 2,
      ),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        final state = ref.watch(duplicateDetectionProvider);
        final resolution = state.resolutions[match.id];

        return DuplicateMatchCard(
          match: match.copyWith(resolution: resolution),
          onResolutionChanged: (action) {
            ref
                .read(duplicateDetectionProvider.notifier)
                .setResolution(match.id, action);
          },
          isExpanded: _expandedCards[match.id] ?? false,
          onExpandToggle: () {
            setState(() {
              _expandedCards[match.id] = !(_expandedCards[match.id] ?? false);
            });
          },
        );
      },
    );
  }

  Widget _buildBottomBar(
    DuplicateDetectionState state,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpendexTheme.spacingLg,
                  ),
                ),
                child: const Text('Review Later'),
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: FilledButton(
                onPressed: state.allResolved
                    ? () => _confirmImport()
                    : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: SpendexTheme.spacingLg,
                  ),
                  backgroundColor: SpendexColors.primary,
                  disabledBackgroundColor:
                      colorScheme.surfaceContainerHighest,
                ),
                child: state.isResolving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm (${state.progressText})',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String action) async {
    final state = ref.read(duplicateDetectionProvider);

    switch (action) {
      case 'apply_all':
        final selectedAction = await showBatchResolutionDialog(
          context: context,
          duplicateCount: state.totalDuplicates,
        );

        if (selectedAction != null) {
          ref
              .read(duplicateDetectionProvider.notifier)
              .applyToAll(selectedAction);
        }
        break;

      case 'clear':
        ref.read(duplicateDetectionProvider.notifier).clearResolutions();
        break;
    }
  }

  Future<void> _confirmImport() async {
    final state = ref.read(duplicateDetectionProvider);

    final success = await ref
        .read(duplicateDetectionProvider.notifier)
        .submitResolutions(
          importId: widget.importId,
          uniqueTransactions: state.result!.uniqueTransactions,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully imported ${state.result!.uniqueTransactions.length} transactions',
          ),
          backgroundColor: SpendexColors.primary,
        ),
      );
      context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Failed to import transactions'),
          backgroundColor: SpendexColors.expense,
        ),
      );
    }
  }
}
