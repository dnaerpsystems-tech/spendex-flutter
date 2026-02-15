import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/imported_statement_model.dart';
import '../../data/models/parsed_transaction_model.dart';
import '../../domain/repositories/pdf_import_repository.dart';

/// Provider for PDF Import repository
final pdfImportRepositoryProvider = Provider<PdfImportRepository>((ref) {
  return getIt<PdfImportRepository>();
});

/// State class for PDF Import
class PdfImportState extends Equatable {
  const PdfImportState({
    this.isLoading = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.importHistory = const [],
    this.currentImport,
    this.parsedTransactions = const [],
    this.selectedTransactions = const {},
    this.error,
  });

  final bool isLoading;
  final bool isUploading;
  final double uploadProgress;
  final List<ImportedStatementModel> importHistory;
  final ImportedStatementModel? currentImport;
  final List<ParsedTransactionModel> parsedTransactions;
  final Set<String> selectedTransactions; // Transaction IDs
  final String? error;

  PdfImportState copyWith({
    bool? isLoading,
    bool? isUploading,
    double? uploadProgress,
    List<ImportedStatementModel>? importHistory,
    ImportedStatementModel? currentImport,
    List<ParsedTransactionModel>? parsedTransactions,
    Set<String>? selectedTransactions,
    String? error,
  }) {
    return PdfImportState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      importHistory: importHistory ?? this.importHistory,
      currentImport: currentImport ?? this.currentImport,
      parsedTransactions: parsedTransactions ?? this.parsedTransactions,
      selectedTransactions: selectedTransactions ?? this.selectedTransactions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isUploading,
        uploadProgress,
        importHistory,
        currentImport,
        parsedTransactions,
        selectedTransactions,
        error,
      ];
}

/// Notifier for PDF Import
class PdfImportNotifier extends StateNotifier<PdfImportState> {
  PdfImportNotifier(this._repository) : super(const PdfImportState());

  final PdfImportRepository _repository;

  /// Load import history
  Future<void> loadImportHistory() async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getImportHistory();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (history) => state = state.copyWith(
        isLoading: false,
        importHistory: history,
      ),
    );
  }

  /// Upload PDF file
  Future<ImportedStatementModel?> uploadPdf(File file) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
    );

    final result = await _repository.uploadPdf(file);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 0,
          error: failure.message,
        );
        return null;
      },
      (importModel) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1,
          currentImport: importModel,
        );
        return importModel;
      },
    );
  }

  /// Upload CSV file with column mapping
  Future<ImportedStatementModel?> uploadCsv(
    File file,
    Map<String, String> columnMapping,
  ) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
    );

    final result = await _repository.uploadCsv(file, columnMapping);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 0,
          error: failure.message,
        );
        return null;
      },
      (importModel) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1,
          currentImport: importModel,
        );
        return importModel;
      },
    );
  }

  /// Get parse results for an import
  Future<bool> getParseResults(String importId) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.getParseResults(importId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (transactions) {
        // Select all transactions by default
        final selectedIds = transactions.map((t) => t.id).toSet();

        state = state.copyWith(
          isLoading: false,
          parsedTransactions: transactions,
          selectedTransactions: selectedIds,
        );
        return true;
      },
    );
  }

  /// Toggle transaction selection
  void toggleTransactionSelection(String transactionId) {
    final selected = Set<String>.from(state.selectedTransactions);

    if (selected.contains(transactionId)) {
      selected.remove(transactionId);
    } else {
      selected.add(transactionId);
    }

    state = state.copyWith(selectedTransactions: selected);
  }

  /// Select all transactions
  void selectAllTransactions() {
    final allIds = state.parsedTransactions.map((t) => t.id).toSet();
    state = state.copyWith(selectedTransactions: allIds);
  }

  /// Deselect all transactions
  void deselectAllTransactions() {
    state = state.copyWith(selectedTransactions: {});
  }

  /// Update a parsed transaction
  void updateParsedTransaction(ParsedTransactionModel updatedTransaction) {
    final updatedList = state.parsedTransactions.map((t) {
      if (t.id == updatedTransaction.id) {
        return updatedTransaction;
      }
      return t;
    }).toList();

    state = state.copyWith(parsedTransactions: updatedList);
  }

  /// Confirm import (import selected transactions)
  Future<bool> confirmImport(String importId) async {
    if (state.selectedTransactions.isEmpty) {
      state = state.copyWith(error: 'Please select at least one transaction');
      return false;
    }

    state = state.copyWith(isLoading: true);

    // Get only selected transactions
    final selectedTxns =
        state.parsedTransactions.where((t) => state.selectedTransactions.contains(t.id)).toList();

    final result = await _repository.confirmImport(importId, selectedTxns);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          parsedTransactions: [],
          selectedTransactions: {},
        );
        // Reload history to include this import
        loadImportHistory();
        return true;
      },
    );
  }

  /// Delete an import
  Future<bool> deleteImport(String importId) async {
    state = state.copyWith(isLoading: true);

    final result = await _repository.deleteImport(importId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(isLoading: false);
        // Reload history
        loadImportHistory();
        return true;
      },
    );
  }

  /// Clear current import and parsed transactions
  void clearCurrentImport() {
    state = state.copyWith(
      parsedTransactions: [],
      selectedTransactions: {},
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for PDF Import state
final pdfImportProvider = StateNotifierProvider<PdfImportNotifier, PdfImportState>((ref) {
  final repository = ref.watch(pdfImportRepositoryProvider);
  return PdfImportNotifier(repository);
});

/// Computed providers for easier access

/// Selected transactions count
final selectedTransactionsCountProvider = Provider<int>((ref) {
  final state = ref.watch(pdfImportProvider);
  return state.selectedTransactions.length;
});

/// Total amount of selected transactions
final selectedTransactionsTotalProvider = Provider<int>((ref) {
  final state = ref.watch(pdfImportProvider);
  final selectedTxns =
      state.parsedTransactions.where((t) => state.selectedTransactions.contains(t.id));

  return selectedTxns.fold<int>(0, (sum, txn) => sum + txn.amount.toInt());
});

/// Whether all transactions are selected
final allTransactionsSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(pdfImportProvider);
  if (state.parsedTransactions.isEmpty) {
    return false;
  }

  return state.selectedTransactions.length == state.parsedTransactions.length;
});
