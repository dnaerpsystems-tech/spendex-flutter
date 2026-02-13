import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/transaction_model.dart';
import '../../domain/repositories/transactions_repository.dart';

/// Transactions State
class TransactionsState extends Equatable {
  const TransactionsState({
    this.transactions = const [],
    this.stats,
    this.dailyTotals = const [],
    this.isLoading = false,
    this.isStatsLoading = false,
    this.error,
    this.selectedTransaction,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = false,
    this.filter,
  });

  const TransactionsState.initial()
      : transactions = const [],
        stats = null,
        dailyTotals = const [],
        isLoading = false,
        isStatsLoading = false,
        error = null,
        selectedTransaction = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false,
        currentPage = 1,
        totalPages = 1,
        hasMore = false,
        filter = null;

  final List<TransactionModel> transactions;
  final TransactionStats? stats;
  final List<DailyTotal> dailyTotals;
  final bool isLoading;
  final bool isStatsLoading;
  final String? error;
  final TransactionModel? selectedTransaction;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final TransactionFilter? filter;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    TransactionStats? stats,
    List<DailyTotal>? dailyTotals,
    bool? isLoading,
    bool? isStatsLoading,
    String? error,
    TransactionModel? selectedTransaction,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    TransactionFilter? filter,
    bool clearError = false,
    bool clearSelectedTransaction = false,
    bool clearStats = false,
    bool clearFilter = false,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      stats: clearStats ? null : (stats ?? this.stats),
      dailyTotals: dailyTotals ?? this.dailyTotals,
      isLoading: isLoading ?? this.isLoading,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      error: clearError ? null : (error ?? this.error),
      selectedTransaction: clearSelectedTransaction
          ? null
          : (selectedTransaction ?? this.selectedTransaction),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      filter: clearFilter ? null : (filter ?? this.filter),
    );
  }

  /// Get income transactions only
  List<TransactionModel> get incomeTransactions {
    return transactions.where((t) => t.isIncome).toList();
  }

  /// Get expense transactions only
  List<TransactionModel> get expenseTransactions {
    return transactions.where((t) => t.isExpense).toList();
  }

  /// Get transfer transactions only
  List<TransactionModel> get transferTransactions {
    return transactions.where((t) => t.isTransfer).toList();
  }

  /// Get transactions by type
  List<TransactionModel> getTransactionsByType(TransactionType type) {
    return transactions.where((t) => t.type == type).toList();
  }

  /// Get transactions for today
  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return transactions.where((t) {
      final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
      return transactionDate.isAtSameMomentAs(today);
    }).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        transactions,
        stats,
        dailyTotals,
        isLoading,
        isStatsLoading,
        error,
        selectedTransaction,
        isCreating,
        isUpdating,
        isDeleting,
        currentPage,
        totalPages,
        hasMore,
        filter,
      ];
}

/// Transactions State Notifier
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  TransactionsNotifier(this._repository) : super(const TransactionsState.initial());

  final TransactionsRepository _repository;

  /// Load transactions with optional pagination
  Future<void> loadTransactions({
    TransactionFilter? filter,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filter: filter,
      currentPage: page,
    );

    final result = await _repository.getTransactions(
      filter: filter ?? state.filter,
      page: page,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (paginatedResponse) {
        final newTransactions = refresh
            ? paginatedResponse.data
            : [...state.transactions, ...paginatedResponse.data];

        state = state.copyWith(
          isLoading: false,
          transactions: newTransactions,
          currentPage: page,
          totalPages: paginatedResponse.totalPages,
          hasMore: paginatedResponse.hasMore,
        );
      },
    );
  }

  /// Load more transactions (pagination)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadTransactions();
  }

  /// Load transaction stats
  Future<void> loadStats({DateTime? startDate, DateTime? endDate}) async {
    if (state.isStatsLoading) return;

    state = state.copyWith(isStatsLoading: true);

    final result = await _repository.getTransactionStats(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isStatsLoading: false,
          error: failure.message,
        );
      },
      (stats) {
        state = state.copyWith(
          isStatsLoading: false,
          stats: stats,
        );
      },
    );
  }

  /// Load daily totals for charts
  Future<void> loadDailyTotals({DateTime? startDate, DateTime? endDate}) async {
    final result = await _repository.getDailyTotals(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (dailyTotals) {
        state = state.copyWith(dailyTotals: dailyTotals);
      },
    );
  }

  /// Load all data (transactions, stats, daily totals)
  Future<void> loadAll({TransactionFilter? filter}) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    await Future.wait([
      loadTransactions(filter: filter, refresh: true),
      loadStats(startDate: startOfMonth, endDate: endOfMonth),
      loadDailyTotals(startDate: startOfMonth, endDate: endOfMonth),
    ]);
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    // First try to find in local state
    try {
      final localTransaction = state.transactions.firstWhere((t) => t.id == id);
      state = state.copyWith(selectedTransaction: localTransaction);
      return localTransaction;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getTransactionById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (transaction) {
        state = state.copyWith(
          isLoading: false,
          selectedTransaction: transaction,
        );
        return transaction;
      },
    );
  }

  /// Create a new transaction
  Future<TransactionModel?> createTransaction(CreateTransactionRequest request) async {
    if (state.isCreating) return null;

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createTransaction(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (transaction) {
        // Add to beginning of list (most recent first)
        state = state.copyWith(
          isCreating: false,
          transactions: [transaction, ...state.transactions],
        );
        // Reload stats to update totals
        loadStats();
        return transaction;
      },
    );
  }

  /// Update an existing transaction
  Future<TransactionModel?> updateTransaction(
    String id,
    CreateTransactionRequest request,
  ) async {
    if (state.isUpdating) return null;

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateTransaction(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedTransaction) {
        final updatedTransactions = state.transactions.map((transaction) {
          return transaction.id == id ? updatedTransaction : transaction;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          transactions: updatedTransactions,
          selectedTransaction: updatedTransaction,
        );
        // Reload stats to update totals
        loadStats();
        return updatedTransaction;
      },
    );
  }

  /// Delete a transaction
  Future<bool> deleteTransaction(String id) async {
    if (state.isDeleting) return false;

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteTransaction(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedTransactions =
            state.transactions.where((t) => t.id != id).toList();

        state = state.copyWith(
          isDeleting: false,
          transactions: updatedTransactions,
          clearSelectedTransaction: true,
        );
        // Reload stats to update totals
        loadStats();
        return true;
      },
    );
  }

  /// Select a transaction
  void selectTransaction(TransactionModel? transaction) {
    state = transaction != null
        ? state.copyWith(selectedTransaction: transaction)
        : state.copyWith(clearSelectedTransaction: true);
  }

  /// Apply filter
  void applyFilter(TransactionFilter? filter) {
    loadTransactions(filter: filter, refresh: true);
  }

  /// Clear filter
  void clearFilter() {
    loadTransactions(refresh: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const TransactionsState.initial();
    await loadAll();
  }
}

/// Transactions State Provider
final transactionsStateProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  return TransactionsNotifier(getIt<TransactionsRepository>());
});

/// Transactions List Provider (computed from state)
final transactionsListProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStateProvider).transactions;
});

/// Transaction Stats Provider (computed from state)
final transactionStatsProvider = Provider<TransactionStats?>((ref) {
  return ref.watch(transactionsStateProvider).stats;
});

/// Selected Transaction Provider
final selectedTransactionProvider = Provider<TransactionModel?>((ref) {
  return ref.watch(transactionsStateProvider).selectedTransaction;
});

/// Income Transactions Provider
final incomeTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStateProvider).incomeTransactions;
});

/// Expense Transactions Provider
final expenseTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStateProvider).expenseTransactions;
});

/// Transfer Transactions Provider
final transferTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStateProvider).transferTransactions;
});

/// Today Transactions Provider
final todayTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(transactionsStateProvider).todayTransactions;
});

/// Transactions By Type Provider
final transactionsByTypeProvider =
    Provider.family<List<TransactionModel>, TransactionType>((ref, type) {
  return ref.watch(transactionsStateProvider).getTransactionsByType(type);
});

/// Transactions Loading Provider
final transactionsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(transactionsStateProvider).isLoading;
});

/// Transactions Error Provider
final transactionsErrorProvider = Provider<String?>((ref) {
  return ref.watch(transactionsStateProvider).error;
});

/// Transactions Has More Provider
final transactionsHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(transactionsStateProvider).hasMore;
});

/// Transaction Operation In Progress Provider
final transactionsOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(transactionsStateProvider).isOperationInProgress;
});

/// Daily Totals Provider
final dailyTotalsProvider = Provider<List<DailyTotal>>((ref) {
  return ref.watch(transactionsStateProvider).dailyTotals;
});
