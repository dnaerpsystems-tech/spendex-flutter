import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import '../../data/models/email_account_model.dart';
import '../providers/email_parser_provider.dart';
import '../widgets/email_account_card.dart';
import '../widgets/email_filter_chip.dart';
import '../widgets/email_message_card.dart';
import '../widgets/email_stats_row.dart';
import 'email_filters_screen.dart';
import 'email_setup_screen.dart';

/// Main email parser screen
class EmailParserScreen extends ConsumerStatefulWidget {
  const EmailParserScreen({super.key});

  @override
  ConsumerState<EmailParserScreen> createState() => _EmailParserScreenState();
}

class _EmailParserScreenState extends ConsumerState<EmailParserScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _navigateToSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EmailSetupScreen(),
      ),
    );
  }

  Future<void> _showFiltersSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const EmailFiltersScreen(),
    );
  }

  Future<void> _disconnectAccount(EmailAccountModel account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Account?'),
        content: Text(
          'Are you sure you want to disconnect ${account.email}? This will not delete any imported transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      final success = await ref.read(emailParserProvider.notifier).disconnectAccount(account.id);

      if (!mounted) {
        return;
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account disconnected successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final error = ref.read(emailParserProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to disconnect account'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _fetchEmails() async {
    await ref.read(emailParserProvider.notifier).fetchEmails();

    if (!mounted) {
      return;
    }

    final state = ref.read(emailParserProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error!),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${state.emails.length} email${state.emails.length != 1 ? 's' : ''}'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _parseEmails() async {
    await ref.read(emailParserProvider.notifier).parseEmails();

    if (!mounted) {
      return;
    }

    final parsedCount = ref.read(parsedEmailCountProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parsed $parsedCount transaction${parsedCount != 1 ? 's' : ''}'),
        backgroundColor: SpendexColors.income,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _importSelected() async {
    final selectedCount = ref.read(selectedEmailCountProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Transactions'),
        content: Text(
          'Import $selectedCount transaction${selectedCount != 1 ? 's' : ''} from selected emails?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.primary,
            ),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final state = ref.read(emailParserProvider);

    // Extract parsed transactions from selected emails
    final selectedTransactions = state.emails
        .where((email) => state.selectedEmailIds.contains(email.id))
        .where((email) => email.parsedTransaction != null)
        .map((email) => email.parsedTransaction!)
        .toList();

    // Step 1: Check for duplicates
    await ref.read(duplicateDetectionProvider.notifier).detectDuplicates(
          transactions: selectedTransactions,
        );

    if (!mounted) {
      return;
    }

    final duplicateState = ref.read(duplicateDetectionProvider);

    // Step 2: If duplicates found, navigate to resolution screen
    if (duplicateState.hasDuplicates) {
      final result = await context.push<bool>(
        AppRoutes.duplicateResolution,
        extra: {
          'importId': 'email_${DateTime.now().millisecondsSinceEpoch}',
          'transactions': selectedTransactions,
        },
      );

      if (!mounted) {
        return;
      }

      // If user resolved duplicates successfully
      if (result ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transactions imported successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home/transactions');
      }
      // If user clicked "Review Later", stay on this screen
      return;
    }

    // Step 3: No duplicates, proceed with direct import
    final success = await ref.read(emailParserProvider.notifier).importTransactions();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transactions imported successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home/transactions');
    } else {
      final error = ref.read(emailParserProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to import transactions'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _refreshEmails() async {
    await ref.read(emailParserProvider.notifier).fetchEmails();
  }

  void _toggleAllSelection() {
    final allSelected = ref.read(allEmailsSelectedProvider);

    if (allSelected) {
      ref.read(emailParserProvider.notifier).deselectAllEmails();
    } else {
      ref.read(emailParserProvider.notifier).selectAllEmails();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(emailParserProvider);
    final hasAccounts = ref.watch(hasConnectedAccountsProvider);
    ref.watch(selectedAccountProvider);
    final stats = ref.watch(emailStatsProvider);
    ref.watch(selectedEmailCountProvider);
    final allSelected = ref.watch(allEmailsSelectedProvider);

    // Show setup screen if no accounts
    if (!hasAccounts && !state.isLoadingAccounts) {
      return Scaffold(
        backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        appBar: AppBar(
          title: const Text('Email Parser'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Icon(
                      Iconsax.sms,
                      size: 56,
                      color: SpendexColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Email Account Connected',
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect your email account to automatically import bank transaction notifications.',
                  style: SpendexTheme.bodyMedium.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.add_circle,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Connect Email Account',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Email Parser'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: _showFiltersSheet,
          ),
          if (state.emails.isNotEmpty)
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
      body: RefreshIndicator(
        onRefresh: _refreshEmails,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Connected accounts
            if (state.accounts.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.only(top: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Connected Accounts',
                              style: SpendexTheme.titleMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _navigateToSetup,
                              icon: const Icon(Iconsax.add_circle),
                              label: const Text('Add'),
                              style: TextButton.styleFrom(
                                foregroundColor: SpendexColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...state.accounts.map(
                        (account) => EmailAccountCard(
                          account: account,
                          isSelected: account.id == state.selectedAccountId,
                          onSelect: () {
                            ref.read(emailParserProvider.notifier).selectAccount(account.id);
                          },
                          onDisconnect: () => _disconnectAccount(account),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Active filters
            if (state.filters != null && state.filters!.activeFilterCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (state.filters!.selectedBanks.isNotEmpty)
                        EmailFilterChip(
                          label: '${state.filters!.selectedBanks.length} banks',
                          icon: Iconsax.bank,
                          onRemove: () {
                            final updatedFilters = state.filters!.copyWith(selectedBanks: {});
                            ref.read(emailParserProvider.notifier).updateFilters(updatedFilters);
                          },
                        ),
                      if (state.filters!.dateRange != null)
                        EmailFilterChip(
                          label: 'Date range',
                          icon: Iconsax.calendar,
                          onRemove: () {
                            final updatedFilters = state.filters!.copyWith();
                            ref.read(emailParserProvider.notifier).updateFilters(updatedFilters);
                          },
                        ),
                      if (state.filters!.searchQuery != null &&
                          state.filters!.searchQuery!.isNotEmpty)
                        EmailFilterChip(
                          label: 'Search',
                          icon: Iconsax.search_normal,
                          onRemove: () {
                            final updatedFilters = state.filters!.copyWith(searchQuery: '');
                            ref.read(emailParserProvider.notifier).updateFilters(updatedFilters);
                          },
                        ),
                    ],
                  ),
                ),
              ),

            // Statistics
            if (state.emails.isNotEmpty)
              SliverToBoxAdapter(
                child: EmailStatsRow(
                  total: stats['total']!,
                  parsed: stats['parsed']!,
                  failed: stats['failed']!,
                  selected: stats['selected']!,
                ),
              ),

            // Email list
            if (state.emails.isEmpty && !state.isFetchingEmails)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.sms,
                        size: 64,
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Emails',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fetch emails to get started',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final email = state.emails[index];
                    final isSelected = state.selectedEmailIds.contains(email.id);

                    return EmailMessageCard(
                      email: email,
                      isSelected: isSelected,
                      onToggle: () {
                        ref.read(emailParserProvider.notifier).toggleEmailSelection(email.id);
                      },
                    );
                  },
                  childCount: state.emails.length,
                ),
              ),

            // Bottom padding for FAB
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActions(state, stats),
    );
  }

  Widget? _buildFloatingActions(EmailParserState state, Map<String, int> stats) {
    // No account selected
    if (state.selectedAccountId == null) {
      return null;
    }

    // Show fetch button if no emails
    if (state.emails.isEmpty && !state.isFetchingEmails) {
      return FloatingActionButton.extended(
        onPressed: _fetchEmails,
        icon: const Icon(Iconsax.refresh),
        label: const Text('Fetch Emails'),
      );
    }

    // Show parse button if unparsed emails exist
    if (stats['unparsed']! > 0 && !state.isParsing) {
      return FloatingActionButton.extended(
        onPressed: _parseEmails,
        icon: const Icon(Iconsax.document_text),
        label: Text('Parse ${stats['unparsed']} Emails'),
      );
    }

    // Show import button if emails selected
    if (stats['selected']! > 0 && !state.isImporting) {
      return FloatingActionButton.extended(
        onPressed: _importSelected,
        backgroundColor: SpendexColors.income,
        icon: const Icon(Iconsax.tick_circle),
        label: Text('Import ${stats['selected']}'),
      );
    }

    // Show loading if processing
    if (state.isFetchingEmails || state.isParsing || state.isImporting) {
      return const FloatingActionButton(
        onPressed: null,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return null;
  }
}
