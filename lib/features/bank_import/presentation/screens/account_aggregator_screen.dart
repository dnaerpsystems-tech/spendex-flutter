import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../app/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../../duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import '../../data/models/aa_consent_model.dart';
import '../providers/account_aggregator_provider.dart';
import '../widgets/confirm_import_dialog.dart';
import '../widgets/empty_import_state.dart';
import '../widgets/transaction_preview_tile.dart';

/// Account Aggregator Screen
/// Allows users to link bank accounts and fetch data via Account Aggregator
class AccountAggregatorScreen extends ConsumerStatefulWidget {
  const AccountAggregatorScreen({super.key});

  @override
  ConsumerState<AccountAggregatorScreen> createState() =>
      _AccountAggregatorScreenState();
}

class _AccountAggregatorScreenState
    extends ConsumerState<AccountAggregatorScreen> {
  @override
  void initState() {
    super.initState();
    // Load linked accounts on init
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(accountAggregatorProvider.notifier).loadLinkedAccounts();
    });
  }

  @override
  void dispose() {
    // Clear fetched data when leaving
    ref.read(accountAggregatorProvider.notifier).clearFetchedData();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final currentRange = ref.read(accountAggregatorProvider).dateRange;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: currentRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 90)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: SpendexColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(accountAggregatorProvider.notifier).setDateRange(picked);
    }
  }

  Future<void> _initiateConsent() async {
    final selectedCount = ref.read(selectedAccountsCountProvider);
    final dateRange = ref.read(accountAggregatorProvider).dateRange;

    if (selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one account'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date range'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success =
        await ref.read(accountAggregatorProvider.notifier).initiateConsent();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Consent initiated successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(accountAggregatorProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to initiate consent'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _fetchAccountData() async {
    final consent = ref.read(accountAggregatorProvider).consent;

    if (consent == null || !consent.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No active consent found'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref
        .read(accountAggregatorProvider.notifier)
        .fetchAccountData(consent.consentId);

    if (!mounted) return;

    if (success) {
      final txnCount = ref
          .read(accountAggregatorProvider)
          .fetchedTransactions
          .length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fetched $txnCount transaction${txnCount != 1 ? 's' : ''}'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(accountAggregatorProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to fetch data'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _revokeConsent() async {
    final consent = ref.read(accountAggregatorProvider).consent;

    if (consent == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Consent?'),
        content: const Text(
          'Are you sure you want to revoke this consent? You will need to re-initiate consent to fetch data again.',
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
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(accountAggregatorProvider.notifier)
        .revokeConsent(consent.consentId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Consent revoked successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(accountAggregatorProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to revoke consent'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

    if (confirmed == true) {
      // Dialog already called _performImport
    }
  }

  Future<void> _performImport() async {
    final state = ref.read(accountAggregatorProvider);
    final selectedTransactions = state.fetchedTransactions
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
          'importId': 'aa_${DateTime.now().millisecondsSinceEpoch}',
          'transactions': selectedTransactions,
        },
      );

      if (!mounted) return;

      // If user resolved duplicates successfully
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transactions imported successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to transactions screen
        context.go('/home/transactions');
      }
      // If user clicked "Review Later", stay on this screen
      return;
    }

    // Step 3: No duplicates, proceed with direct import
    // Note: You'll need to implement the actual import in account_aggregator_provider
    final success =
        await ref.read(accountAggregatorProvider.notifier).importTransactions();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transactions imported successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Navigate to transactions screen
      context.go('/home/transactions');
    } else {
      final error = ref.read(accountAggregatorProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to import transactions'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleAllSelection() {
    final allSelected = ref.read(allTransactionsSelectedProvider);

    if (allSelected) {
      ref.read(accountAggregatorProvider.notifier).deselectAllTransactions();
    } else {
      ref.read(accountAggregatorProvider.notifier).selectAllTransactions();
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Select date range';

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final aaState = ref.watch(accountAggregatorProvider);
    final isConsentActive = ref.watch(isConsentActiveProvider);
    final consentStatusMsg = ref.watch(consentStatusMessageProvider);
    final selectedCount = ref.watch(selectedTransactionsCountProvider);
    final totalAmount = ref.watch(selectedTransactionsTotalProvider);
    final allSelected = ref.watch(allTransactionsSelectedProvider);

    // Show fetched transactions if available
    if (aaState.fetchedTransactions.isNotEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? SpendexColors.darkBackground
            : SpendexColors.lightBackground,
        appBar: AppBar(
          title: const Text('Review Transactions'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () {
              // Clear fetched data and go back
              ref.read(accountAggregatorProvider.notifier).clearFetchedData();
            },
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
        body: Column(
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
                    color: SpendexColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$selectedCount / ${aaState.fetchedTransactions.length}',
                        style: SpendexTheme.headlineMedium.copyWith(
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
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatPaise(
                          totalAmount,
                          decimalDigits: 0,
                        ),
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
                itemCount: aaState.fetchedTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = aaState.fetchedTransactions[index];
                  final isSelected =
                      aaState.selectedTransactions.contains(transaction.id);

                  return TransactionPreviewTile(
                    transaction: transaction,
                    isSelected: isSelected,
                    onSelectionChanged: (selected) {
                      ref
                          .read(accountAggregatorProvider.notifier)
                          .toggleTransactionSelection(transaction.id);
                    },
                    showEditButton: false,
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
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
                    Icon(
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
        ),
      );
    }

    // Main consent flow screen
    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Account Aggregator'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: aaState.isLoadingAccounts
          ? const Center(child: ShimmerLoadingList())
          : aaState.linkedAccounts.isEmpty
              ? const NoLinkedAccountsEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Link Your Bank Accounts',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Securely fetch transactions from your linked bank accounts using Account Aggregator',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Consent status card
                      if (aaState.consent != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _getConsentStatusColor(aaState.consent!)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getConsentStatusColor(aaState.consent!)
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getConsentStatusIcon(aaState.consent!),
                                    color: _getConsentStatusColor(
                                      aaState.consent!,
                                    ),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      consentStatusMsg,
                                      style: SpendexTheme.titleMedium.copyWith(
                                        color: _getConsentStatusColor(
                                          aaState.consent!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isConsentActive) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Valid until: ${DateFormat('dd MMM yyyy').format(aaState.consent!.expiresAt)}',
                                  style: SpendexTheme.bodyMedium.copyWith(
                                    color: _getConsentStatusColor(
                                      aaState.consent!,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Date range selector
                      Text(
                        'Select Date Range',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectDateRange,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark
                                  ? SpendexColors.darkBorder
                                  : SpendexColors.lightBorder,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.calendar,
                                color: SpendexColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatDateRange(aaState.dateRange),
                                  style: SpendexTheme.bodyMedium.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 16,
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Linked accounts list
                      Text(
                        'Select Accounts',
                        style: SpendexTheme.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: aaState.linkedAccounts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final accountId = aaState.linkedAccounts[index];
                          final isSelected =
                              aaState.selectedAccounts.contains(accountId);

                          return _AccountTile(
                            accountId: accountId,
                            isSelected: isSelected,
                            onToggle: () {
                              ref
                                  .read(accountAggregatorProvider.notifier)
                                  .toggleAccountSelection(accountId);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      if (!isConsentActive) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: aaState.isInitiatingConsent
                                ? null
                                : _initiateConsent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SpendexColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  SpendexColors.primary.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: aaState.isInitiatingConsent
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Initiating Consent...',
                                        style:
                                            SpendexTheme.titleMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.shield_tick,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Initiate Consent',
                                        style:
                                            SpendexTheme.titleMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: aaState.isFetchingData
                                ? null
                                : _fetchAccountData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SpendexColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  SpendexColors.primary.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: aaState.isFetchingData
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Fetching Data...',
                                        style:
                                            SpendexTheme.titleMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.cloud_add,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Fetch Account Data',
                                        style:
                                            SpendexTheme.titleMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: aaState.isRevokingConsent
                                ? null
                                : _revokeConsent,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SpendexColors.expense,
                              side: BorderSide(
                                color: SpendexColors.expense,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Iconsax.shield_cross,
                                  color: SpendexColors.expense,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Revoke Consent',
                                  style: SpendexTheme.titleMedium.copyWith(
                                    color: SpendexColors.expense,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Color _getConsentStatusColor(AccountAggregatorConsentModel consent) {
    switch (consent.status) {
      case ConsentStatus.active:
        return SpendexColors.income;
      case ConsentStatus.pending:
        return SpendexColors.warning;
      case ConsentStatus.expired:
      case ConsentStatus.revoked:
        return SpendexColors.expense;
      case ConsentStatus.paused:
        return SpendexColors.transfer;
    }
  }

  IconData _getConsentStatusIcon(AccountAggregatorConsentModel consent) {
    switch (consent.status) {
      case ConsentStatus.active:
        return Iconsax.tick_circle;
      case ConsentStatus.pending:
        return Iconsax.timer;
      case ConsentStatus.expired:
      case ConsentStatus.revoked:
        return Iconsax.close_circle;
      case ConsentStatus.paused:
        return Iconsax.pause_circle;
    }
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.accountId,
    required this.isSelected,
    required this.onToggle,
  });

  final String accountId;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? SpendexColors.primary
                  : (isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Iconsax.bank,
                    color: SpendexColors.primary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  accountId,
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
