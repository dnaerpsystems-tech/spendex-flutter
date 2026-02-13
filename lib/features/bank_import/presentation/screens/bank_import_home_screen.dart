import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../providers/pdf_import_provider.dart';
import '../widgets/empty_import_state.dart';
import '../widgets/import_history_card.dart';
import '../widgets/import_method_card.dart';

/// Bank Import Home Screen
/// Displays import methods and recent import history
class BankImportHomeScreen extends ConsumerStatefulWidget {
  const BankImportHomeScreen({super.key});

  @override
  ConsumerState<BankImportHomeScreen> createState() =>
      _BankImportHomeScreenState();
}

class _BankImportHomeScreenState extends ConsumerState<BankImportHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load import history on screen init
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(pdfImportProvider.notifier).loadImportHistory();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(pdfImportProvider.notifier).loadImportHistory();
  }

  void _navigateToPdfImport() {
    context.push('/bank-import/pdf-import');
  }

  void _navigateToSmsParser() {
    context.push('/bank-import/sms-parser');
  }

  void _navigateToAccountAggregator() {
    context.push('/bank-import/account-aggregator');
  }

  void _navigateToEmailParser() {
    context.push('/email-parser');
  }

  void _navigateToImportHistory() {
    context.push('/bank-import/history');
  }

  void _navigateToImportPreview(String importId) {
    context.push('/bank-import/preview/$importId');
  }

  Future<void> _deleteImport(String importId) async {
    final success =
        await ref.read(pdfImportProvider.notifier).deleteImport(importId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import deleted successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(pdfImportProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to delete import'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final importState = ref.watch(pdfImportProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Bank Import'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {
              // Navigate to import settings (future enhancement)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Import settings coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Transactions',
                      style: SpendexTheme.headlineMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Automatically import your transactions from multiple sources',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Import Methods
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Methods',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // PDF/CSV Import Card
                    ImportMethodCard(
                      icon: Iconsax.document_upload,
                      title: 'PDF/CSV Import',
                      description:
                          'Upload bank statements in PDF or CSV format',
                      onTap: _navigateToPdfImport,
                      color: SpendexColors.primary,
                    ),
                    const SizedBox(height: 12),

                    // SMS Parser Card
                    ImportMethodCard(
                      icon: Iconsax.messages,
                      title: 'SMS Parser',
                      description:
                          'Automatically parse bank transaction SMS messages',
                      onTap: _navigateToSmsParser,
                      color: SpendexColors.transfer,
                    ),
                    const SizedBox(height: 12),

                    // Account Aggregator Card
                    ImportMethodCard(
                      icon: Iconsax.bank,
                      title: 'Account Aggregator',
                      description:
                          'Securely fetch transactions from linked bank accounts',
                      onTap: _navigateToAccountAggregator,
                      color: SpendexColors.warning,
                    ),
                    const SizedBox(height: 12),

                    // Email Parser Card
                    ImportMethodCard(
                      icon: Iconsax.sms,
                      title: 'Email Parser',
                      description:
                          'Parse bank transaction emails from Gmail, Outlook & more',
                      onTap: _navigateToEmailParser,
                      color: SpendexColors.income,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recent Import History Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Imports',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (importState.importHistory.isNotEmpty)
                      TextButton(
                        onPressed: _navigateToImportHistory,
                        child: Text(
                          'View All',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: SpendexColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Import History List or States
            if (importState.isLoading)
              const SliverFillRemaining(
                child: Center(child: ShimmerLoadingList()),
              )
            else if (importState.error != null)
              SliverFillRemaining(
                child: ErrorStateWidget(
                  message: importState.error!,
                  onRetry: _onRefresh,
                ),
              )
            else if (importState.importHistory.isEmpty)
              const SliverFillRemaining(
                child: NoImportsEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Show only first 5 recent imports
                    if (index >= 5) return null;

                    final import = importState.importHistory[index];
                    return ImportHistoryCard(
                      import: import,
                      onTap: () => _navigateToImportPreview(import.id),
                      onDelete: () => _deleteImport(import.id),
                    );
                  },
                  childCount: importState.importHistory.length > 5
                      ? 5
                      : importState.importHistory.length,
                ),
              ),

            // Bottom spacing
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
