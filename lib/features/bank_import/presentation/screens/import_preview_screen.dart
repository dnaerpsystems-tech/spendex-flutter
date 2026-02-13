import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import '../providers/pdf_import_provider.dart';
import '../widgets/confirm_import_dialog.dart';
import '../widgets/empty_import_state.dart';
import '../widgets/transaction_preview_tile.dart';

/// Import Preview Screen
/// Displays parsed transactions from an import for review and confirmation
class ImportPreviewScreen extends ConsumerStatefulWidget {
  const ImportPreviewScreen({
    required this.importId,
    super.key,
  });

  final String importId;

  @override
  ConsumerState<ImportPreviewScreen> createState() =>
      _ImportPreviewScreenState();
}

class _ImportPreviewScreenState extends ConsumerState<ImportPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load parse results on screen init
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(pdfImportProvider.notifier).getParseResults(widget.importId);
    });
  }

  @override
  void dispose() {
    // Clear parsed transactions when leaving
    ref.read(pdfImportProvider.notifier).clearCurrentImport();
    super.dispose();
  }

  void _toggleAllSelection() {
    final allSelected = ref.read(allTransactionsSelectedProvider);

    if (allSelected) {
      ref.read(pdfImportProvider.notifier).deselectAllTransactions();
    } else {
      ref.read(pdfImportProvider.notifier).selectAllTransactions();
    }
  }

  Future<void> _confirmImport() async {
    final selectedCount = ref.read(selectedTransactionsCountProvider);
    final totalAmount = ref.read(selectedTransactionsTotalProvider);

    // Show confirmation dialog
    final confirmed = await showConfirmImportDialog(
      context,
      selectedCount: selectedCount,
      totalAmount: totalAmount,
      onConfirm: _performImport,
    );

    if (confirmed ?? false) {
      // Dialog already called _performImport
      // Just wait for it to complete
    }
  }

  Future<void> _performImport() async {
    final state = ref.read(pdfImportProvider);
    final selectedTransactions = state.parsedTransactions
        .where((t) => state.selectedTransactions.contains(t.id))
        .toList();

    // Step 1: Check for duplicates
    await ref.read(duplicateDetectionProvider.notifier).detectDuplicates(
          transactions: selectedTransactions,
        );

    if (!mounted) return;

    final duplicateState = ref.read(duplicateDetectionProvider);

    // Step 2: If duplicates found, navigate to resolution screen
    if (duplicateState.hasDuplicates) {
      final result = await context.push<bool>(
        AppRoutes.duplicateResolution,
        extra: {
          'importId': widget.importId,
          'transactions': selectedTransactions,
        },
      );

      if (!mounted) return;

      // If user resolved duplicates successfully
      if (result ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transactions imported successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate back to home or transactions screen
        context.go('/home/transactions');
      }
      // If user clicked "Review Later", stay on this screen
      return;
    }

    // Step 3: No duplicates, proceed with direct import
    final success = await ref
        .read(pdfImportProvider.notifier)
        .confirmImport(widget.importId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transactions imported successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate back to home or transactions screen
      context.go('/home/transactions');
    } else {
      final error = ref.read(pdfImportProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to import transactions'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showEditTransactionBottomSheet(int index) {
    final transaction = ref.read(pdfImportProvider).parsedTransactions[index];

    // Show bottom sheet to edit transaction
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Edit Transaction',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Amount field
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            prefixText: '₹',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(
                            text: (transaction.amount / 100).toString(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          controller: TextEditingController(
                            text: transaction.description,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Category field
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          controller: TextEditingController(
                            text: transaction.category,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Transaction editing coming soon',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SpendexColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final importState = ref.watch(pdfImportProvider);
    final selectedCount = ref.watch(selectedTransactionsCountProvider);
    final totalAmount = ref.watch(selectedTransactionsTotalProvider);
    final allSelected = ref.watch(allTransactionsSelectedProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Review Import'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _toggleAllSelection,
            child: Text(
              allSelected ? 'Deselect All' : 'Select All',
              style: SpendexTheme.labelMedium.copyWith(
                color: SpendexColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: importState.isLoading
          ? const Center(child: ShimmerLoadingList())
          : importState.error != null
              ? ErrorStateWidget(
                  message: importState.error!,
                  onRetry: () => ref
                      .read(pdfImportProvider.notifier)
                      .getParseResults(widget.importId),
                )
              : importState.parsedTransactions.isEmpty
                  ? const NoTransactionsParsedEmptyState()
                  : Column(
                      children: [
                        // Summary card
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: SpendexColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: SpendexColors.primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selected',
                                        style: SpendexTheme.bodyMedium.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$selectedCount / ${importState.parsedTransactions.length}',
                                        style:
                                            SpendexTheme.headlineMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: SpendexTheme.bodyMedium.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.formatPaise(
                                          totalAmount,
                                          decimalDigits: 0,
                                        ),
                                        style:
                                            SpendexTheme.headlineMedium.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Transactions list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 100),
                            itemCount: importState.parsedTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction =
                                  importState.parsedTransactions[index];
                              final isSelected = importState
                                  .selectedTransactions
                                  .contains(transaction.id);

                              return TransactionPreviewTile(
                                transaction: transaction,
                                isSelected: isSelected,
                                onSelectionChanged: (selected) {
                                  ref
                                      .read(pdfImportProvider.notifier)
                                      .toggleTransactionSelection(
                                        transaction.id,
                                      );
                                },
                                onEdit: () =>
                                    _showEditTransactionBottomSheet(index),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: importState.parsedTransactions.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: selectedCount > 0 ? _confirmImport : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          SpendexColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.tick_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Import $selectedCount Transaction${selectedCount != 1 ? 's' : ''}',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
