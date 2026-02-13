import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../budgets/data/models/budget_model.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Dashboard State
class DashboardState extends Equatable {

  const DashboardState({
    this.accountsSummary,
    this.monthlyStats,
    this.recentTransactions = const [],
    this.budgetAlerts = const [],
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.isStatsLoading = false,
    this.isTransactionsLoading = false,
    this.isBudgetsLoading = false,
    this.error,
  });

  const DashboardState.initial()
      : accountsSummary = null,
        monthlyStats = null,
        recentTransactions = const [],
        budgetAlerts = const [],
        isLoading = false,
        isSummaryLoading = false,
        isStatsLoading = false,
        isTransactionsLoading = false,
        isBudgetsLoading = false,
        error = null;
  final AccountsSummary? accountsSummary;
  final TransactionStats? monthlyStats;
  final List<TransactionModel> recentTransactions;
  final List<BudgetModel> budgetAlerts;
  final bool isLoading;
  final bool isSummaryLoading;
  final bool isStatsLoading;
  final bool isTransactionsLoading;
  final bool isBudgetsLoading;
  final String? error;

  DashboardState copyWith({
    AccountsSummary? accountsSummary,
    TransactionStats? monthlyStats,
    List<TransactionModel>? recentTransactions,
    List<BudgetModel>? budgetAlerts,
    bool? isLoading,
    bool? isSummaryLoading,
    bool? isStatsLoading,
    bool? isTransactionsLoading,
    bool? isBudgetsLoading,
    String? error,
    bool clearError = false,
  }) {
    return DashboardState(
      accountsSummary: accountsSummary ?? this.accountsSummary,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isStatsLoading: isStatsLoading ?? this.isStatsLoading,
      isTransactionsLoading: isTransactionsLoading ?? this.isTransactionsLoading,
      isBudgetsLoading: isBudgetsLoading ?? this.isBudgetsLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        accountsSummary,
        monthlyStats,
        recentTransactions,
        budgetAlerts,
        isLoading,
        isSummaryLoading,
        isStatsLoading,
        isTransactionsLoading,
        isBudgetsLoading,
        error,
      ];
}

/// Dashboard State Notifier
class DashboardNotifier extends StateNotifier<DashboardState> {

  DashboardNotifier(this._repository) : super(const DashboardState.initial());
  final DashboardRepository _repository;

  /// Load all dashboard data in parallel
  Future<void> loadAll() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    await Future.wait([
      loadAccountsSummary(),
      loadMonthlyStats(),
      loadRecentTransactions(),
      loadBudgetAlerts(),
    ]);

    state = state.copyWith(isLoading: false);
  }

  /// Load accounts summary
  Future<void> loadAccountsSummary() async {
    if (state.isSummaryLoading) {
      return;
    }

    state = state.copyWith(isSummaryLoading: true);

    final result = await _repository.getAccountsSummary();

    result.fold(
      (failure) {
        state = state.copyWith(
          isSummaryLoading: false,
          error: failure.message,
        );
      },
      (summary) {
        state = state.copyWith(
          isSummaryLoading: false,
          accountsSummary: summary,
        );
      },
    );
  }

  /// Load monthly transaction stats for the current month
  Future<void> loadMonthlyStats() async {
    if (state.isStatsLoading) {
      return;
    }

    state = state.copyWith(isStatsLoading: true);

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month);
    final endDate = DateTime(now.year, now.month + 1, 0);

    final result = await _repository.getMonthlyStats(
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
          monthlyStats: stats,
        );
      },
    );
  }

  /// Load recent transactions
  Future<void> loadRecentTransactions() async {
    if (state.isTransactionsLoading) {
      return;
    }

    state = state.copyWith(isTransactionsLoading: true);

    final result = await _repository.getRecentTransactions();

    result.fold(
      (failure) {
        state = state.copyWith(
          isTransactionsLoading: false,
          error: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          isTransactionsLoading: false,
          recentTransactions: transactions,
        );
      },
    );
  }

  /// Load active budgets and filter to those at or above alert threshold
  Future<void> loadBudgetAlerts() async {
    if (state.isBudgetsLoading) {
      return;
    }

    state = state.copyWith(isBudgetsLoading: true);

    final result = await _repository.getActiveBudgets();

    result.fold(
      (failure) {
        state = state.copyWith(
          isBudgetsLoading: false,
          error: failure.message,
        );
      },
      (budgets) {
        final alerts = budgets
            .where((budget) => budget.percentage >= budget.alertThreshold)
            .toList();
        state = state.copyWith(
          isBudgetsLoading: false,
          budgetAlerts: alerts,
        );
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all dashboard data
  Future<void> refresh() async {
    state = const DashboardState.initial();
    await loadAll();
  }
}

/// Dashboard State Provider
final dashboardStateProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(getIt<DashboardRepository>());
});

/// Accounts Summary Provider (computed from state)
final accountsSummaryProvider = Provider<AccountsSummary?>((ref) {
  return ref.watch(dashboardStateProvider).accountsSummary;
});

/// Monthly Stats Provider (computed from state)
final monthlyStatsProvider = Provider<TransactionStats?>((ref) {
  return ref.watch(dashboardStateProvider).monthlyStats;
});

/// Recent Transactions Provider (computed from state)
final recentTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  return ref.watch(dashboardStateProvider).recentTransactions;
});

/// Budget Alerts Provider (computed from state)
final budgetAlertsProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(dashboardStateProvider).budgetAlerts;
});

/// Dashboard Loading Provider
final dashboardLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dashboardStateProvider).isLoading;
});

/// Dashboard Error Provider
final dashboardErrorProvider = Provider<String?>((ref) {
  return ref.watch(dashboardStateProvider).error;
});
