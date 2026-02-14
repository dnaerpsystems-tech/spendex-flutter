import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/investment_model.dart';
import '../../domain/repositories/investments_repository.dart';

/// Investments State
class InvestmentsState extends Equatable {

  const InvestmentsState({
    this.investments = const [],
    this.summary,
    this.selectedInvestment,
    this.taxSavings,
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.isTaxLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isSyncing = false,
    this.error,
  });

  const InvestmentsState.initial()
      : investments = const [],
        summary = null,
        selectedInvestment = null,
        taxSavings = null,
        isLoading = false,
        isSummaryLoading = false,
        isTaxLoading = false,
        isCreating = false,
        isUpdating = false,
        isDeleting = false,
        isSyncing = false,
        error = null;
  final List<InvestmentModel> investments;
  final InvestmentSummary? summary;
  final InvestmentModel? selectedInvestment;
  final TaxSavingsSummary? taxSavings;
  final bool isLoading;
  final bool isSummaryLoading;
  final bool isTaxLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isSyncing;
  final String? error;

  InvestmentsState copyWith({
    List<InvestmentModel>? investments,
    InvestmentSummary? summary,
    InvestmentModel? selectedInvestment,
    TaxSavingsSummary? taxSavings,
    bool? isLoading,
    bool? isSummaryLoading,
    bool? isTaxLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isSyncing,
    String? error,
    bool clearError = false,
    bool clearSelectedInvestment = false,
    bool clearSummary = false,
    bool clearTaxSavings = false,
  }) {
    return InvestmentsState(
      investments: investments ?? this.investments,
      summary: clearSummary ? null : (summary ?? this.summary),
      selectedInvestment: clearSelectedInvestment ? null : (selectedInvestment ?? this.selectedInvestment),
      taxSavings: clearTaxSavings ? null : (taxSavings ?? this.taxSavings),
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      isTaxLoading: isTaxLoading ?? this.isTaxLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isSyncing: isSyncing ?? this.isSyncing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Get active investments only
  List<InvestmentModel> get activeInvestments {
    return investments.where((investment) => investment.isActive).toList();
  }

  /// Get investments filtered by type
  List<InvestmentModel> getInvestmentsByType(InvestmentType type) {
    return investments.where((investment) => investment.type == type).toList();
  }

  /// Get market-linked investments (Mutual Funds, Stocks, Crypto)
  List<InvestmentModel> get marketLinkedInvestments {
    return investments.where((investment) => investment.isMarketLinked).toList();
  }

  /// Get fixed income investments (FD, RD, PPF, etc.)
  List<InvestmentModel> get fixedIncomeInvestments {
    return investments.where((investment) => !investment.isMarketLinked).toList();
  }

  /// Get tax-saving investments
  List<InvestmentModel> get taxSavingInvestments {
    return investments.where((investment) => investment.taxSaving).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting || isSyncing;

  @override
  List<Object?> get props => [
        investments,
        summary,
        selectedInvestment,
        taxSavings,
        isLoading,
        isSummaryLoading,
        isTaxLoading,
        isCreating,
        isUpdating,
        isDeleting,
        isSyncing,
        error,
      ];
}

/// Investments State Notifier
class InvestmentsNotifier extends StateNotifier<InvestmentsState> {

  InvestmentsNotifier(this._repository) : super(const InvestmentsState.initial());
  final InvestmentsRepository _repository;

  /// Load all investments
  Future<void> loadInvestments() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getInvestments();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (investments) {
        state = state.copyWith(
          isLoading: false,
          investments: investments,
        );
      },
    );
  }

  /// Load investments summary
  Future<void> loadSummary() async {
    if (state.isSummaryLoading) {
      return;
    }

    state = state.copyWith(isSummaryLoading: true);

    final result = await _repository.getInvestmentsSummary();

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

  /// Load tax savings summary for a specific year
  Future<void> loadTaxSavings(String year) async {
    if (state.isTaxLoading) {
      return;
    }

    state = state.copyWith(isTaxLoading: true, clearError: true);

    final result = await _repository.getTaxSavings(year);

    result.fold(
      (failure) {
        state = state.copyWith(
          isTaxLoading: false,
          error: failure.message,
        );
      },
      (taxSavings) {
        state = state.copyWith(
          isTaxLoading: false,
          taxSavings: taxSavings,
        );
      },
    );
  }

  /// Load investments, summary, and tax savings for current year
  Future<void> loadAll() async {
    final currentYear = DateTime.now().year.toString();
    await Future.wait([
      loadInvestments(),
      loadSummary(),
      loadTaxSavings(currentYear),
    ]);
  }

  /// Get investment by ID
  Future<InvestmentModel?> loadInvestmentById(String id) async {
    // First try to find in local state
    try {
      final localInvestment = state.investments.firstWhere((i) => i.id == id);
      state = state.copyWith(selectedInvestment: localInvestment);
      return localInvestment;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getInvestmentById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (investment) {
        state = state.copyWith(
          isLoading: false,
          selectedInvestment: investment,
        );
        return investment;
      },
    );
  }

  /// Create a new investment
  Future<InvestmentModel?> createInvestment(CreateInvestmentRequest request) async {
    if (state.isCreating) {
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createInvestment(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (investment) {
        state = state.copyWith(
          isCreating: false,
          investments: [...state.investments, investment],
        );
        // Reload summary to update totals
        loadSummary();
        return investment;
      },
    );
  }

  /// Update an existing investment
  Future<InvestmentModel?> updateInvestment(String id, CreateInvestmentRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateInvestment(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedInvestment) {
        final updatedInvestments = state.investments.map((investment) {
          return investment.id == id ? updatedInvestment : investment;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          investments: updatedInvestments,
          selectedInvestment: updatedInvestment,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedInvestment;
      },
    );
  }

  /// Delete an investment
  Future<bool> deleteInvestment(String id) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteInvestment(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedInvestments = state.investments.where((i) => i.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          investments: updatedInvestments,
          clearSelectedInvestment: true,
        );
        // Reload summary to update totals
        loadSummary();
        return true;
      },
    );
  }

  /// Sync current prices for market-linked investments
  Future<bool> syncPrices() async {
    if (state.isSyncing) {
      return false;
    }

    state = state.copyWith(isSyncing: true, clearError: true);

    final result = await _repository.syncPrices();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSyncing: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isSyncing: false);
        // Reload investments and summary to get updated prices
        loadInvestments();
        loadSummary();
        return true;
      },
    );
  }

  /// Select an investment
  void selectInvestment(InvestmentModel? investment) {
    state = investment != null
        ? state.copyWith(selectedInvestment: investment)
        : state.copyWith(clearSelectedInvestment: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const InvestmentsState.initial();
    await loadAll();
  }
}

/// Investments State Provider
final investmentsStateProvider =
    StateNotifierProvider.autoDispose<InvestmentsNotifier, InvestmentsState>((ref) {
  return InvestmentsNotifier(getIt<InvestmentsRepository>());
});

/// Investments List Provider (computed from state)
final investmentsListProvider = Provider<List<InvestmentModel>>((ref) {
  return ref.watch(investmentsStateProvider).investments;
});

/// Investments Summary Provider (computed from state)
final investmentsSummaryProvider = Provider<InvestmentSummary?>((ref) {
  return ref.watch(investmentsStateProvider).summary;
});

/// Tax Savings Provider (computed from state)
final taxSavingsProvider = Provider<TaxSavingsSummary?>((ref) {
  return ref.watch(investmentsStateProvider).taxSavings;
});

/// Selected Investment Provider
final selectedInvestmentProvider = Provider<InvestmentModel?>((ref) {
  return ref.watch(investmentsStateProvider).selectedInvestment;
});

/// Investments By Type Provider
final investmentsByTypeProvider =
    Provider.family<List<InvestmentModel>, InvestmentType>((ref, type) {
  return ref.watch(investmentsStateProvider).getInvestmentsByType(type);
});

/// Active Investments Provider
final activeInvestmentsProvider = Provider<List<InvestmentModel>>((ref) {
  return ref.watch(investmentsStateProvider).activeInvestments;
});

/// Market-Linked Investments Provider
final marketLinkedInvestmentsProvider = Provider<List<InvestmentModel>>((ref) {
  return ref.watch(investmentsStateProvider).marketLinkedInvestments;
});

/// Fixed Income Investments Provider
final fixedIncomeInvestmentsProvider = Provider<List<InvestmentModel>>((ref) {
  return ref.watch(investmentsStateProvider).fixedIncomeInvestments;
});

/// Tax-Saving Investments Provider
final taxSavingInvestmentsProvider = Provider<List<InvestmentModel>>((ref) {
  return ref.watch(investmentsStateProvider).taxSavingInvestments;
});

/// Investments Loading Provider
final investmentsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(investmentsStateProvider).isLoading;
});

/// Investments Error Provider
final investmentsErrorProvider = Provider<String?>((ref) {
  return ref.watch(investmentsStateProvider).error;
});

/// Investment Operation In Progress Provider
final investmentsOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(investmentsStateProvider).isOperationInProgress;
});
