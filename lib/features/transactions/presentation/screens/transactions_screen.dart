import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import '../widgets/date_group_header.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import '../widgets/receipt_scanner_sheet.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_search_delegate.dart';
import '../widgets/voice_input_sheet.dart';

/// Transactions Screen
/// Displays all transactions with filtering, search, and pagination
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  // ignore: unused_field
  final __currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '\u20B9',
    decimalDigits: 0,
  );

  TransactionType? _selectedType;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsStateProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(transactionsStateProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(transactionsStateProvider.notifier).loadMore();
      }
    }
  }

  Future<void> _refresh() async {
    await ref.read(transactionsStateProvider.notifier).loadTransactions(refresh: true);
  }

  Future<void> _openSearch() async {
    final transactionsState = ref.read(transactionsStateProvider);
    final result = await showSearch<TransactionModel?>(
      context: context,
      delegate: TransactionSearchDelegate(
        ref: ref,
        transactions: transactionsState.transactions,
      ),
    );
    if (result != null && mounted) {
      unawaited(context.push('/transactions/${result.id}'));
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedType: _selectedType,
        selectedDateRange: _selectedDateRange,
        onApply: (type, dateRange) {
          setState(() {
            _selectedType = type;
            _selectedDateRange = dateRange;
          });
          Navigator.pop(context);
          if (type != null) {
            ref.read(transactionsStateProvider.notifier).applyFilter(
                  TransactionFilter(type: type),
                );
          } else {
            ref.read(transactionsStateProvider.notifier).clearFilter();
          }
        },
      ),
    );
  }

  void _showVoiceInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceInputSheet(
        onTransactionParsed: (request) {
          Navigator.pop(context);
          if (request != null) {
            context.go(
                '${AppRoutes.addTransaction}?amount=${request.amount}&type=${request.type.value}',);
          }
        },
      ),
    );
  }

  void _showReceiptScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptScannerSheet(
        onReceiptScanned: (request) {
          Navigator.pop(context);
          if (request != null) {
            context.go('${AppRoutes.addTransaction}?amount=${request.amount}');
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsState = ref.watch(transactionsStateProvider);

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          Semantics(
            label: 'Search transactions',
            button: true,
            child: IconButton(
              icon: const Icon(Iconsax.search_normal),
              onPressed: _openSearch,
              tooltip: 'Search transactions',
            ),
          ),
          Semantics(
            label: 'Filter transactions',
            button: true,
            child: IconButton(
              icon: const Icon(Iconsax.filter),
              onPressed: _showFilterSheet,
              tooltip: 'Filter',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: SpendexColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Filter Chips
            if (_selectedType != null || _selectedDateRange != null)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      if (_selectedType != null)
                        _FilterChip(
                          label: _selectedType!.label,
                          color: _getTypeColor(_selectedType!),
                          onRemove: () {
                            setState(() => _selectedType = null);
                            ref.read(transactionsStateProvider.notifier).clearFilter();
                          },
                        ),
                      if (_selectedDateRange != null)
                        _FilterChip(
                          label:
                              '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                          onRemove: () => setState(() => _selectedDateRange = null),
                        ),
                    ],
                  ),
                ),
              ),

            // Content
            if (transactionsState.isLoading && transactionsState.transactions.isEmpty)
              _buildLoadingSkeleton()
            else if (transactionsState.error != null && transactionsState.transactions.isEmpty)
              _buildErrorState(transactionsState.error!)
            else if (transactionsState.transactions.isEmpty)
              _buildEmptyState()
            else
              _buildTransactionsList(transactionsState, isDark),

            // Loading More Indicator
            if (transactionsState.isLoading && transactionsState.transactions.isNotEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: SpendexColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: QuickAddFab(
        onManualTap: () => context.go(AppRoutes.addTransaction),
        onVoiceTap: _showVoiceInput,
        onReceiptTap: _showReceiptScanner,
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _TransactionSkeleton(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: SpendexColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Iconsax.warning_2, size: 40, color: SpendexColors.expense),
              ),
              const SizedBox(height: 16),
              Text('Something went wrong', style: SpendexTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(Iconsax.receipt_item, size: 48, color: SpendexColors.primary),
              ),
              const SizedBox(height: 24),
              Text('No transactions yet', style: SpendexTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Start tracking your finances by adding your first transaction',
                textAlign: TextAlign.center,
                style: SpendexTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Semantics(
                label: 'Add your first transaction',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.addTransaction),
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add Transaction'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(TransactionsState state, bool isDark) {
    final grouped = _groupTransactionsByDate(state.transactions);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final entry = grouped.entries.elementAt(index);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateGroupHeader(date: entry.key),
                ...entry.value.map(
                  (t) => TransactionCard(
                    transaction: t,
                    onTap: () => context.push('/transactions/${t.id}'),
                  ),
                ),
              ],
            );
          },
          childCount: grouped.length,
        ),
      ),
    );
  }

  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(
      List<TransactionModel> transactions,) {
    final grouped = <DateTime, List<TransactionModel>>{};
    for (final t in transactions) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      grouped.putIfAbsent(key, () => []).add(t);
    }
    return Map.fromEntries(grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)));
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
      case TransactionType.transfer:
        return SpendexColors.transfer;
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onRemove, this.color});
  final String label;
  final Color? color;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? SpendexColors.primary;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: SpendexTheme.labelMedium.copyWith(color: chipColor)),
          const SizedBox(width: 8),
          Semantics(
            label: 'Remove $label filter',
            button: true,
            child: GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 16, color: chipColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 16,
                    width: 120,
                    decoration:
                        BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),),
                const SizedBox(height: 8),
                Container(
                    height: 12,
                    width: 80,
                    decoration:
                        BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),),
              ],
            ),
          ),
          Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet(
      {required this.selectedType, required this.selectedDateRange, required this.onApply,});
  final TransactionType? selectedType;
  final DateTimeRange? selectedDateRange;
  final void Function(TransactionType?, DateTimeRange?) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  TransactionType? _type;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _dateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter Transactions', style: SpendexTheme.headlineMedium),
              TextButton(
                onPressed: () => setState(() {
                  _type = null;
                  _dateRange = null;
                }),
                child: const Text('Reset', style: TextStyle(color: SpendexColors.expense)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Transaction Type', style: SpendexTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: TransactionType.values
                .map(
                  (t) => ChoiceChip(
                    label: Text(t.label),
                    selected: _type == t,
                    selectedColor: _getColor(t).withValues(alpha: 0.2),
                    onSelected: (s) => setState(() => _type = s ? t : null),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('Date Range', style: SpendexTheme.titleMedium),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _dateRange,
              );
              if (picked != null) {
                setState(() => _dateRange = picked);
              }
            },
            icon: const Icon(Iconsax.calendar),
            label: Text(
              _dateRange != null
                  ? '${DateFormat('MMM d').format(_dateRange!.start)} - ${DateFormat('MMM d').format(_dateRange!.end)}'
                  : 'Select Date Range',
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_type, _dateRange),
              child: const Text('Apply Filters'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getColor(TransactionType t) {
    switch (t) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
      case TransactionType.transfer:
        return SpendexColors.transfer;
    }
  }
}
