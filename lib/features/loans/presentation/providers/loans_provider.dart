import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/loan_model.dart';
import '../../domain/repositories/loans_repository.dart';

/// Loans State
class LoansState extends Equatable {
  const LoansState({
    this.loans = const [],
    this.summary,
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.error,
    this.selectedLoan,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  const LoansState.initial()
      : loans = const [],
        summary = null,
        isLoading = false,
        isSummaryLoading = false,
        error = null,
        selectedLoan = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false;
  final List<LoanModel> loans;
  final LoansSummary? summary;
  final bool isLoading;
  final bool isSummaryLoading;
  final String? error;
  final LoanModel? selectedLoan;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  LoansState copyWith({
    List<LoanModel>? loans,
    LoansSummary? summary,
    bool? isLoading,
    bool? isSummaryLoading,
    String? error,
    LoanModel? selectedLoan,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
    bool clearSelectedLoan = false,
    bool clearSummary = false,
  }) {
    return LoansState(
      loans: loans ?? this.loans,
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      error: clearError ? null : (error ?? this.error),
      selectedLoan: clearSelectedLoan ? null : (selectedLoan ?? this.selectedLoan),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Get active loans only
  List<LoanModel> get activeLoans {
    return loans.where((loan) => loan.isActive).toList();
  }

  /// Get closed loans
  List<LoanModel> get closedLoans {
    return loans.where((loan) => loan.isClosed).toList();
  }

  /// Get loans filtered by status
  List<LoanModel> getLoansByStatus(LoanStatus status) {
    return loans.where((loan) => loan.status == status).toList();
  }

  /// Get loans filtered by type
  List<LoanModel> getLoansByType(LoanType type) {
    return loans.where((loan) => loan.type == type).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        loans,
        summary,
        isLoading,
        isSummaryLoading,
        error,
        selectedLoan,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

/// Loans State Notifier
class LoansNotifier extends StateNotifier<LoansState> {
  LoansNotifier(this._repository) : super(const LoansState.initial());
  final LoansRepository _repository;

  /// Load all loans
  Future<void> loadLoans() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getLoans();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (loans) {
        state = state.copyWith(
          isLoading: false,
          loans: loans,
        );
      },
    );
  }

  /// Load loans summary
  Future<void> loadSummary() async {
    if (state.isSummaryLoading) {
      return;
    }

    state = state.copyWith(isSummaryLoading: true);

    final result = await _repository.getLoansSummary();

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

  /// Load both loans and summary
  Future<void> loadAll() async {
    await Future.wait([
      loadLoans(),
      loadSummary(),
    ]);
  }

  /// Get loan by ID
  Future<LoanModel?> loadLoanById(String id) async {
    // First try to find in local state
    try {
      final localLoan = state.loans.firstWhere((l) => l.id == id);
      state = state.copyWith(selectedLoan: localLoan);
      return localLoan;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getLoanById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (loan) {
        state = state.copyWith(
          isLoading: false,
          selectedLoan: loan,
        );
        return loan;
      },
    );
  }

  /// Create a new loan
  Future<LoanModel?> createLoan(CreateLoanRequest request) async {
    if (state.isCreating) {
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createLoan(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (loan) {
        state = state.copyWith(
          isCreating: false,
          loans: [...state.loans, loan],
        );
        // Reload summary to update totals
        loadSummary();
        return loan;
      },
    );
  }

  /// Update an existing loan
  Future<LoanModel?> updateLoan(String id, CreateLoanRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateLoan(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedLoan) {
        final updatedLoans = state.loans.map((loan) {
          return loan.id == id ? updatedLoan : loan;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          loans: updatedLoans,
          selectedLoan: updatedLoan,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedLoan;
      },
    );
  }

  /// Delete a loan
  Future<bool> deleteLoan(String id) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteLoan(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedLoans = state.loans.where((l) => l.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          loans: updatedLoans,
          clearSelectedLoan: true,
        );
        // Reload summary to update totals
        loadSummary();
        return true;
      },
    );
  }

  /// Record EMI payment for a loan
  Future<LoanModel?> recordEmiPayment(String loanId, EmiPaymentRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.recordEmiPayment(loanId, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedLoan) {
        final updatedLoans = state.loans.map((loan) {
          return loan.id == loanId ? updatedLoan : loan;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          loans: updatedLoans,
          selectedLoan: updatedLoan,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedLoan;
      },
    );
  }

  /// Select a loan
  void selectLoan(LoanModel? loan) {
    state =
        loan != null ? state.copyWith(selectedLoan: loan) : state.copyWith(clearSelectedLoan: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const LoansState.initial();
    await loadAll();
  }
}

/// Loans State Provider
final loansStateProvider = StateNotifierProvider.autoDispose<LoansNotifier, LoansState>((ref) {
  return LoansNotifier(getIt<LoansRepository>());
});

/// Loans List Provider (computed from state)
final loansListProvider = Provider<List<LoanModel>>((ref) {
  return ref.watch(loansStateProvider).loans;
});

/// Loans Summary Provider (computed from state)
final loansSummaryProvider = Provider<LoansSummary?>((ref) {
  return ref.watch(loansStateProvider).summary;
});

/// Selected Loan Provider
final selectedLoanProvider = Provider<LoanModel?>((ref) {
  return ref.watch(loansStateProvider).selectedLoan;
});

/// Active Loans Provider
final activeLoansProvider = Provider<List<LoanModel>>((ref) {
  return ref.watch(loansStateProvider).activeLoans;
});

/// Closed Loans Provider
final closedLoansProvider = Provider<List<LoanModel>>((ref) {
  return ref.watch(loansStateProvider).closedLoans;
});

/// Loans By Status Provider
final loansByStatusProvider = Provider.family<List<LoanModel>, LoanStatus>((ref, status) {
  return ref.watch(loansStateProvider).getLoansByStatus(status);
});

/// Loans By Type Provider
final loansByTypeProvider = Provider.family<List<LoanModel>, LoanType>((ref, type) {
  return ref.watch(loansStateProvider).getLoansByType(type);
});

/// Loans Loading Provider
final loansLoadingProvider = Provider<bool>((ref) {
  return ref.watch(loansStateProvider).isLoading;
});

/// Loans Error Provider
final loansErrorProvider = Provider<String?>((ref) {
  return ref.watch(loansStateProvider).error;
});

/// Loan Operation In Progress Provider
final loansOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(loansStateProvider).isOperationInProgress;
});
