import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/budget_model.dart';
import '../../domain/repositories/budgets_repository.dart';

/// Budgets State
class BudgetsState extends Equatable {
  const BudgetsState({
    this.budgets = const [],
    this.summary,
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.error,
    this.selectedBudget,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  const BudgetsState.initial()
      : budgets = const [],
        summary = null,
        isLoading = false,
        isSummaryLoading = false,
        error = null,
        selectedBudget = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false;
  final List<BudgetModel> budgets;
  final BudgetsSummary? summary;
  final bool isLoading;
  final bool isSummaryLoading;
  final String? error;
  final BudgetModel? selectedBudget;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  BudgetsState copyWith({
    List<BudgetModel>? budgets,
    BudgetsSummary? summary,
    bool? isLoading,
    bool? isSummaryLoading,
    String? error,
    BudgetModel? selectedBudget,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
    bool clearSelectedBudget = false,
    bool clearSummary = false,
  }) {
    return BudgetsState(
      budgets: budgets ?? this.budgets,
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      error: clearError ? null : (error ?? this.error),
      selectedBudget: clearSelectedBudget ? null : (selectedBudget ?? this.selectedBudget),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Get active budgets only
  List<BudgetModel> get activeBudgets {
    return budgets.where((budget) => budget.isActive).toList();
  }

  /// Get budgets that are over 100%
  List<BudgetModel> get overBudgets {
    return budgets.where((budget) => budget.percentage >= 100).toList();
  }

  /// Get budgets over alert threshold but under 100%
  List<BudgetModel> get warningBudgets {
    return budgets
        .where(
          (budget) => budget.percentage >= budget.alertThreshold && budget.percentage < 100,
        )
        .toList();
  }

  /// Get budgets on track (under alert threshold)
  List<BudgetModel> get onTrackBudgets {
    return budgets.where((budget) => budget.percentage < budget.alertThreshold).toList();
  }

  /// Get budgets filtered by period
  List<BudgetModel> getBudgetsByPeriod(BudgetPeriod period) {
    return budgets.where((budget) => budget.period == period).toList();
  }

  /// Get budgets filtered by status
  List<BudgetModel> getBudgetsByStatus(BudgetStatus status) {
    return budgets.where((budget) => budget.status == status).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        budgets,
        summary,
        isLoading,
        isSummaryLoading,
        error,
        selectedBudget,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

/// Budgets State Notifier
class BudgetsNotifier extends StateNotifier<BudgetsState> {
  BudgetsNotifier(this._repository) : super(const BudgetsState.initial());
  final BudgetsRepository _repository;

  /// Load all budgets
  Future<void> loadBudgets() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getBudgets();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (budgets) {
        state = state.copyWith(
          isLoading: false,
          budgets: budgets,
        );
      },
    );
  }

  /// Load budgets summary
  Future<void> loadSummary() async {
    if (state.isSummaryLoading) {
      return;
    }

    state = state.copyWith(isSummaryLoading: true);

    final result = await _repository.getBudgetsSummary();

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
          summary: summary,
        );
      },
    );
  }

  /// Load both budgets and summary
  Future<void> loadAll() async {
    await Future.wait([
      loadBudgets(),
      loadSummary(),
    ]);
  }

  /// Get budget by ID
  Future<BudgetModel?> getBudgetById(String id) async {
    // First try to find in local state
    try {
      final localBudget = state.budgets.firstWhere((b) => b.id == id);
      state = state.copyWith(selectedBudget: localBudget);
      return localBudget;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getBudgetById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (budget) {
        state = state.copyWith(
          isLoading: false,
          selectedBudget: budget,
        );
        return budget;
      },
    );
  }

  /// Create a new budget
  Future<BudgetModel?> createBudget(CreateBudgetRequest request) async {
    if (state.isCreating) {
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createBudget(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (budget) {
        state = state.copyWith(
          isCreating: false,
          budgets: [...state.budgets, budget],
        );
        // Reload summary to update totals
        loadSummary();
        return budget;
      },
    );
  }

  /// Update an existing budget
  Future<BudgetModel?> updateBudget(String id, CreateBudgetRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateBudget(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedBudget) {
        final updatedBudgets = state.budgets.map((budget) {
          return budget.id == id ? updatedBudget : budget;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          budgets: updatedBudgets,
          selectedBudget: updatedBudget,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedBudget;
      },
    );
  }

  /// Delete a budget
  Future<bool> deleteBudget(String id) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteBudget(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedBudgets = state.budgets.where((b) => b.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          budgets: updatedBudgets,
          clearSelectedBudget: true,
        );
        // Reload summary to update totals
        loadSummary();
        return true;
      },
    );
  }

  /// Select a budget
  void selectBudget(BudgetModel? budget) {
    state = budget != null
        ? state.copyWith(selectedBudget: budget)
        : state.copyWith(clearSelectedBudget: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const BudgetsState.initial();
    await loadAll();
  }
}

/// Budgets State Provider
final budgetsStateProvider =
    StateNotifierProvider.autoDispose<BudgetsNotifier, BudgetsState>((ref) {
  return BudgetsNotifier(getIt<BudgetsRepository>());
});

/// Budgets List Provider (computed from state)
final budgetsListProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStateProvider).budgets;
});

/// Budgets Summary Provider (computed from state)
final budgetsSummaryProvider = Provider<BudgetsSummary?>((ref) {
  return ref.watch(budgetsStateProvider).summary;
});

/// Selected Budget Provider
final selectedBudgetProvider = Provider<BudgetModel?>((ref) {
  return ref.watch(budgetsStateProvider).selectedBudget;
});

/// Active Budgets Provider
final activeBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStateProvider).activeBudgets;
});

/// Over Budget Provider (budgets over 100%)
final overBudgetProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStateProvider).overBudgets;
});

/// Warning Budgets Provider (over alertThreshold but under 100%)
final warningBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStateProvider).warningBudgets;
});

/// On Track Budgets Provider
final onTrackBudgetsProvider = Provider<List<BudgetModel>>((ref) {
  return ref.watch(budgetsStateProvider).onTrackBudgets;
});

/// Budgets By Period Provider
final budgetsByPeriodProvider = Provider.family<List<BudgetModel>, BudgetPeriod>((ref, period) {
  return ref.watch(budgetsStateProvider).getBudgetsByPeriod(period);
});

/// Budgets By Status Provider
final budgetsByStatusProvider = Provider.family<List<BudgetModel>, BudgetStatus>((ref, status) {
  return ref.watch(budgetsStateProvider).getBudgetsByStatus(status);
});

/// Budgets Loading Provider
final budgetsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(budgetsStateProvider).isLoading;
});

/// Budgets Error Provider
final budgetsErrorProvider = Provider<String?>((ref) {
  return ref.watch(budgetsStateProvider).error;
});

/// Budget Operation In Progress Provider
final budgetsOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(budgetsStateProvider).isOperationInProgress;
});
