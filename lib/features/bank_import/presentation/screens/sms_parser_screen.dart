import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import '../../data/models/parsed_transaction_model.dart';
import '../../data/models/sms_message_model.dart';
import '../providers/sms_parser_provider.dart';
import '../widgets/bank_selector_sheet.dart';
import '../widgets/confirm_import_dialog.dart';
import '../widgets/empty_import_state.dart';
import '../widgets/sms_permission_dialog.dart';

/// SMS Parser Screen
/// Allows users to parse bank transaction SMS messages
class SmsParserScreen extends ConsumerStatefulWidget {
  const SmsParserScreen({super.key});

  @override
  ConsumerState<SmsParserScreen> createState() => _SmsParserScreenState();
}

class _SmsParserScreenState extends ConsumerState<SmsParserScreen> {
  @override
  void initState() {
    super.initState();
    // Check permissions and load bank configs on init
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndInit();
    });
  }

  @override
  void dispose() {
    // Clear SMS messages when leaving
    ref.read(smsParserProvider.notifier).clearSmsMessages();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInit() async {
    await ref.read(smsParserProvider.notifier).checkPermissions();

    final permissionStatus = ref.read(smsParserProvider).permissionStatus;

    if (permissionStatus == SmsPermissionStatus.denied) {
      // Show permission dialog
      if (!mounted) {
        return;
      }
      _showPermissionDialog().ignore();
    }
  }

  Future<void> _showPermissionDialog() async {
    final result = await showSmsPermissionDialog(
      context,
      _requestPermission,
    );

    if (result == null || !result) {
      // User declined permission, show info
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SMS permission is required to read bank messages'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _requestPermission() async {
    await ref.read(smsParserProvider.notifier).requestPermissions();
  }

  Future<void> _selectDateRange() async {
    final currentRange = ref.read(smsParserProvider).dateRange;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: currentRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SpendexColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(smsParserProvider.notifier).setDateRange(picked);
    }
  }

  Future<void> _selectBanks() async {
    final banks = ref.read(smsParserProvider).bankConfigs;
    final selectedBanks = ref.read(smsParserProvider).selectedBanks;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: BankSelectorSheet(
          banks: banks,
          selectedBanks: selectedBanks,
          onSelectionChanged: (selected) {
            // Update selected banks in provider
            for (final bank in banks) {
              if (selected.contains(bank.bankName)) {
                if (!ref.read(smsParserProvider).selectedBanks.contains(bank.bankName)) {
                  ref.read(smsParserProvider.notifier).toggleBankSelection(bank.bankName);
                }
              } else {
                if (ref.read(smsParserProvider).selectedBanks.contains(bank.bankName)) {
                  ref.read(smsParserProvider.notifier).toggleBankSelection(bank.bankName);
                }
              }
            }
          },
        ),
      ),
    );
  }

  Future<void> _readSmsMessages() async {
    final dateRange = ref.read(smsParserProvider).dateRange;

    if (dateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date range'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(smsParserProvider.notifier).readSmsMessages();

    if (!mounted) {
      return;
    }

    final error = ref.read(smsParserProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final parsedCount = ref.read(parsedSmsCountProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found $parsedCount transaction${parsedCount != 1 ? 's' : ''}'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _toggleAllSelection() {
    final allSelected = ref.read(allSmsSelectedProvider);

    if (allSelected) {
      ref.read(smsParserProvider.notifier).deselectAllSms();
    } else {
      ref.read(smsParserProvider.notifier).selectAllSms();
    }
  }

  Future<void> _confirmImport() async {
    final selectedCount = ref.read(selectedSmsCountProvider);
    final totalAmount = ref.read(selectedSmsTotalProvider);

    // Show confirmation dialog
    final confirmed = await showConfirmImportDialog(
      context,
      selectedCount: selectedCount,
      totalAmount: totalAmount,
      onConfirm: _performImport,
    );

    if (confirmed ?? false) {
      // Dialog already called _performImport
    }
  }

  Future<void> _performImport() async {
    final state = ref.read(smsParserProvider);

    // Extract parsed transactions from selected SMS messages
    final selectedTransactions = state.smsMessages
        .where((sms) => state.selectedSms.contains(sms.id))
        .where((sms) => sms.parsedTransaction != null)
        .map((sms) => sms.parsedTransaction!)
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
          'importId': 'sms_${DateTime.now().millisecondsSinceEpoch}',
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

        // Navigate to transactions screen
        context.go('/home/transactions');
      }
      // If user clicked "Review Later", stay on this screen
      return;
    }

    // Step 3: No duplicates, proceed with direct import
    final success = await ref.read(smsParserProvider.notifier).bulkImportTransactions();

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

      // Navigate to transactions screen
      context.go('/home/transactions');
    } else {
      final error = ref.read(smsParserProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to import transactions'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) {
      return 'Select date range';
    }

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final smsState = ref.watch(smsParserProvider);
    final selectedCount = ref.watch(selectedSmsCountProvider);
    final parsedCount = ref.watch(parsedSmsCountProvider);
    final failedCount = ref.watch(failedSmsCountProvider);
    final allSelected = ref.watch(allSmsSelectedProvider);

    // Show permission screen if not granted
    if (smsState.permissionStatus == SmsPermissionStatus.denied ||
        smsState.permissionStatus == SmsPermissionStatus.permanentlyDenied) {
      return Scaffold(
        backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        appBar: AppBar(
          title: const Text('SMS Parser'),
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
                    color: SpendexColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Icon(
                      Iconsax.shield_cross,
                      size: 56,
                      color: SpendexColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SMS Permission Required',
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'To read and parse bank SMS messages, we need permission to access your SMS inbox.',
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
                    onPressed: _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Grant Permission',
                      style: SpendexTheme.titleMedium.copyWith(
                        color: Colors.white,
                      ),
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
        title: const Text('SMS Parser'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (smsState.smsMessages.isNotEmpty)
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
          // Filters section
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Date range selector
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.calendar,
                          color: SpendexColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateRange(smsState.dateRange),
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
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
                const SizedBox(height: 12),

                // Bank selector
                InkWell(
                  onTap: _selectBanks,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.bank,
                          color: SpendexColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${smsState.selectedBanks.length} bank${smsState.selectedBanks.length != 1 ? 's' : ''} selected',
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
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
                const SizedBox(height: 16),

                // Read SMS button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        smsState.isLoadingSms || smsState.isParsing || smsState.dateRange == null
                            ? null
                            : _readSmsMessages,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: SpendexColors.primary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: smsState.isLoadingSms || smsState.isParsing
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                smsState.isParsing ? 'Parsing SMS...' : 'Reading SMS...',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.messages,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Read SMS Messages',
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

          // SMS list or empty state
          Expanded(
            child: smsState.smsMessages.isEmpty
                ? const NoSmsEmptyState()
                : Column(
                    children: [
                      // Stats summary
                      if (parsedCount > 0 || failedCount > 0)
                        Container(
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SpendexColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: SpendexColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Parsed',
                                value: '$parsedCount',
                                color: SpendexColors.income,
                              ),
                              _StatItem(
                                label: 'Failed',
                                value: '$failedCount',
                                color: SpendexColors.expense,
                              ),
                              _StatItem(
                                label: 'Selected',
                                value: '$selectedCount',
                                color: SpendexColors.primary,
                              ),
                            ],
                          ),
                        ),

                      // SMS list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: smsState.smsMessages.length,
                          itemBuilder: (context, index) {
                            final sms = smsState.smsMessages[index];
                            final isSelected = smsState.selectedSms.contains(sms.id);
                            final isParsed = sms.parseStatus == ParseStatus.parsed;

                            return _SmsMessageTile(
                              sms: sms,
                              isSelected: isSelected,
                              isParsed: isParsed,
                              onToggle: () {
                                if (isParsed) {
                                  ref.read(smsParserProvider.notifier).toggleSmsSelection(sms.id);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      bottomNavigationBar: smsState.smsMessages.isNotEmpty && parsedCount > 0
          ? Container(
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
                      disabledBackgroundColor: SpendexColors.primary.withValues(alpha: 0.5),
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: SpendexTheme.headlineMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SmsMessageTile extends StatelessWidget {
  const _SmsMessageTile({
    required this.sms,
    required this.isSelected,
    required this.isParsed,
    required this.onToggle,
  });

  final SmsMessageModel sms;
  final bool isSelected;
  final bool isParsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transaction = sms.parsedTransaction;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? SpendexColors.primary
              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isParsed ? onToggle : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isParsed)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => onToggle(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            sms.bankName ?? 'Unknown Bank',
                            style: SpendexTheme.titleMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isParsed
                                  ? SpendexColors.income.withValues(alpha: 0.1)
                                  : SpendexColors.expense.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isParsed ? 'Parsed' : 'Failed',
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isParsed ? SpendexColors.income : SpendexColors.expense,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (transaction != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          transaction.description,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(transaction.date),
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text(
                          sms.body.length > 100 ? '${sms.body.substring(0, 100)}...' : sms.body,
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (transaction != null)
                  Text(
                    CurrencyFormatter.formatPaise(
                      transaction.amount.toInt(),
                      decimalDigits: 0,
                    ),
                    style: SpendexTheme.titleMedium.copyWith(
                      color: transaction.type == TransactionType.income
                          ? SpendexColors.income
                          : SpendexColors.expense,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
