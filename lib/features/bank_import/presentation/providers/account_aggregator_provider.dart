import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/aa_consent_model.dart';
import '../../data/models/parsed_transaction_model.dart';
import '../../domain/repositories/account_aggregator_repository.dart';

/// Provider for Account Aggregator repository
final accountAggregatorRepositoryProvider =
    Provider<AccountAggregatorRepository>((ref) {
  return getIt<AccountAggregatorRepository>();
});

/// State class for Account Aggregator
class AccountAggregatorState extends Equatable {
  const AccountAggregatorState({
    this.isInitiatingConsent = false,
    this.isFetchingConsentStatus = false,
    this.isFetchingData = false,
    this.isLoadingAccounts = false,
    this.isRevokingConsent = false,
    this.isImportingTransactions = false,
    this.consent,
    this.linkedAccounts = const [],
    this.selectedAccounts = const {},
    this.dateRange,
    this.fetchedTransactions = const [],
    this.selectedTransactions = const {},
    this.error,
  });

  final bool isInitiatingConsent;
  final bool isFetchingConsentStatus;
  final bool isFetchingData;
  final bool isLoadingAccounts;
  final bool isRevokingConsent;
  final bool isImportingTransactions;
  final AccountAggregatorConsentModel? consent;
  final List<String> linkedAccounts; // Account IDs
  final Set<String> selectedAccounts; // Selected account IDs for consent
  final DateTimeRange? dateRange;
  final List<ParsedTransactionModel> fetchedTransactions;
  final Set<String> selectedTransactions; // Transaction IDs for import
  final String? error;

  AccountAggregatorState copyWith({
    bool? isInitiatingConsent,
    bool? isFetchingConsentStatus,
    bool? isFetchingData,
    bool? isLoadingAccounts,
    bool? isRevokingConsent,
    bool? isImportingTransactions,
    AccountAggregatorConsentModel? consent,
    List<String>? linkedAccounts,
    Set<String>? selectedAccounts,
    DateTimeRange? dateRange,
    List<ParsedTransactionModel>? fetchedTransactions,
    Set<String>? selectedTransactions,
    String? error,
  }) {
    return AccountAggregatorState(
      isInitiatingConsent: isInitiatingConsent ?? this.isInitiatingConsent,
      isFetchingConsentStatus:
          isFetchingConsentStatus ?? this.isFetchingConsentStatus,
      isFetchingData: isFetchingData ?? this.isFetchingData,
      isLoadingAccounts: isLoadingAccounts ?? this.isLoadingAccounts,
      isRevokingConsent: isRevokingConsent ?? this.isRevokingConsent,
      isImportingTransactions: isImportingTransactions ?? this.isImportingTransactions,
      consent: consent ?? this.consent,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      selectedAccounts: selectedAccounts ?? this.selectedAccounts,
      dateRange: dateRange ?? this.dateRange,
      fetchedTransactions: fetchedTransactions ?? this.fetchedTransactions,
      selectedTransactions: selectedTransactions ?? this.selectedTransactions,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isInitiatingConsent,
        isFetchingConsentStatus,
        isFetchingData,
        isLoadingAccounts,
        isRevokingConsent,
        isImportingTransactions,
        consent,
        linkedAccounts,
        selectedAccounts,
        dateRange,
        fetchedTransactions,
        selectedTransactions,
        error,
      ];
}

/// Notifier for Account Aggregator
class AccountAggregatorNotifier extends StateNotifier<AccountAggregatorState> {
  AccountAggregatorNotifier(this._repository)
      : super(const AccountAggregatorState()) {
    _initialize();
  }

  final AccountAggregatorRepository _repository;

  /// Initialize - load linked accounts
  Future<void> _initialize() async {
    await loadLinkedAccounts();
  }

  /// Load linked accounts
  Future<void> loadLinkedAccounts() async {
    state = state.copyWith(isLoadingAccounts: true, error: null);

    final result = await _repository.getLinkedAccounts();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingAccounts: false,
        error: failure.message,
      ),
      (accounts) => state = state.copyWith(
        isLoadingAccounts: false,
        linkedAccounts: accounts,
        error: null,
      ),
    );
  }

  /// Set date range for data fetch
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  /// Toggle account selection
  void toggleAccountSelection(String accountId) {
    final selected = Set<String>.from(state.selectedAccounts);

    if (selected.contains(accountId)) {
      selected.remove(accountId);
    } else {
      selected.add(accountId);
    }

    state = state.copyWith(selectedAccounts: selected);
  }

  /// Select all accounts
  void selectAllAccounts() {
    final allAccounts = state.linkedAccounts.toSet();
    state = state.copyWith(selectedAccounts: allAccounts);
  }

  /// Deselect all accounts
  void deselectAllAccounts() {
    state = state.copyWith(selectedAccounts: {});
  }

  /// Initiate consent
  Future<bool> initiateConsent() async {
    if (state.selectedAccounts.isEmpty) {
      state = state.copyWith(error: 'Please select at least one account');
      return false;
    }

    if (state.dateRange == null) {
      state = state.copyWith(error: 'Please select a date range');
      return false;
    }

    state = state.copyWith(isInitiatingConsent: true, error: null);

    final result = await _repository.initiateConsent(
      state.selectedAccounts.toList(),
      state.dateRange!,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isInitiatingConsent: false,
          error: failure.message,
        );
        return false;
      },
      (consent) {
        state = state.copyWith(
          isInitiatingConsent: false,
          consent: consent,
          error: null,
        );
        return true;
      },
    );
  }

  /// Get consent status
  Future<void> getConsentStatus(String consentId) async {
    state = state.copyWith(isFetchingConsentStatus: true, error: null);

    final result = await _repository.getConsentStatus(consentId);

    result.fold(
      (failure) => state = state.copyWith(
        isFetchingConsentStatus: false,
        error: failure.message,
      ),
      (consent) => state = state.copyWith(
        isFetchingConsentStatus: false,
        consent: consent,
        error: null,
      ),
    );
  }

  /// Fetch account data
  Future<bool> fetchAccountData(String consentId) async {
    state = state.copyWith(isFetchingData: true, error: null);

    final result = await _repository.fetchAccountData(consentId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isFetchingData: false,
          error: failure.message,
        );
        return false;
      },
      (transactions) {
        // Select all transactions by default
        final selectedIds = transactions.map((t) => t.id).toSet();

        state = state.copyWith(
          isFetchingData: false,
          fetchedTransactions: transactions,
          selectedTransactions: selectedIds,
          error: null,
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
    final allIds = state.fetchedTransactions.map((t) => t.id).toSet();
    state = state.copyWith(selectedTransactions: allIds);
  }

  /// Deselect all transactions
  void deselectAllTransactions() {
    state = state.copyWith(selectedTransactions: {});
  }

  /// Revoke consent
  Future<bool> revokeConsent(String consentId) async {
    state = state.copyWith(isRevokingConsent: true, error: null);

    final result = await _repository.revokeConsent(consentId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isRevokingConsent: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isRevokingConsent: false,
          consent: null,
          selectedAccounts: {},
          fetchedTransactions: [],
          selectedTransactions: {},
          error: null,
        );
        return true;
      },
    );
  }

  /// Import selected transactions
  Future<bool> importTransactions() async {
    // Validate selected transactions
    if (state.selectedTransactions.isEmpty) {
      state = state.copyWith(error: 'Please select at least one transaction');
      return false;
    }

    // Set loading state
    state = state.copyWith(isImportingTransactions: true, error: null);

    // Get selected transactions
    final transactions = state.fetchedTransactions
        .where((t) => state.selectedTransactions.contains(t.id))
        .toList();

    // Validate we have transactions to import
    if (transactions.isEmpty) {
      state = state.copyWith(
        isImportingTransactions: false,
        error: 'No valid transactions to import',
      );
      return false;
    }

    // Call repository
    final result = await _repository.bulkImportTransactions(transactions);

    // Handle result
    return result.fold(
      (failure) {
        state = state.copyWith(
          isImportingTransactions: false,
          error: failure.message,
        );
        return false;
      },
      (importedCount) {
        // Clear fetched data on success
        state = state.copyWith(
          isImportingTransactions: false,
          fetchedTransactions: [],
          selectedTransactions: {},
          error: null,
        );
        return true;
      },
    );
  }

  /// Clear fetched data
  void clearFetchedData() {
    state = state.copyWith(
      fetchedTransactions: [],
      selectedTransactions: {},
      error: null,
    );
  }

  /// Clear consent
  void clearConsent() {
    state = state.copyWith(
      consent: null,
      selectedAccounts: {},
      fetchedTransactions: [],
      selectedTransactions: {},
      error: null,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for Account Aggregator state
final accountAggregatorProvider =
    StateNotifierProvider<AccountAggregatorNotifier, AccountAggregatorState>(
        (ref) {
  final repository = ref.watch(accountAggregatorRepositoryProvider);
  return AccountAggregatorNotifier(repository);
});

/// Computed providers

/// Whether consent is active
final isConsentActiveProvider = Provider<bool>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  return state.consent?.isActive ?? false;
});

/// Whether consent is expired
final isConsentExpiredProvider = Provider<bool>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  return state.consent?.isExpired ?? false;
});

/// Selected accounts count
final selectedAccountsCountProvider = Provider<int>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  return state.selectedAccounts.length;
});

/// Selected transactions count
final selectedTransactionsCountProvider = Provider<int>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  return state.selectedTransactions.length;
});

/// Total amount of selected transactions
final selectedTransactionsTotalProvider = Provider<int>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  final selectedTxns = state.fetchedTransactions
      .where((t) => state.selectedTransactions.contains(t.id));

  return selectedTxns.fold<int>(0, (sum, txn) => sum + txn.amount.toInt());
});

/// Whether all transactions are selected
final allTransactionsSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  if (state.fetchedTransactions.isEmpty) return false;

  return state.selectedTransactions.length ==
      state.fetchedTransactions.length;
});

/// Consent status message
final consentStatusMessageProvider = Provider<String>((ref) {
  final state = ref.watch(accountAggregatorProvider);
  final consent = state.consent;

  if (consent == null) return 'No active consent';

  switch (consent.status) {
    case ConsentStatus.pending:
      return 'Consent pending approval';
    case ConsentStatus.active:
      return 'Consent is active';
    case ConsentStatus.paused:
      return 'Consent is paused';
    case ConsentStatus.revoked:
      return 'Consent has been revoked';
    case ConsentStatus.expired:
      return 'Consent has expired';
  }
});
