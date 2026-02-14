import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/account_model.dart';
import '../../domain/repositories/accounts_repository.dart';

/// Accounts State
class AccountsState extends Equatable {

  const AccountsState({
    this.accounts = const [],
    this.summary,
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.error,
    this.selectedAccount,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.isTransferring = false,
  });

  const AccountsState.initial()
      : accounts = const [],
        summary = null,
        isLoading = false,
        isSummaryLoading = false,
        error = null,
        selectedAccount = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false,
        isTransferring = false;
  final List<AccountModel> accounts;
  final AccountsSummary? summary;
  final bool isLoading;
  final bool isSummaryLoading;
  final String? error;
  final AccountModel? selectedAccount;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final bool isTransferring;

  AccountsState copyWith({
    List<AccountModel>? accounts,
    AccountsSummary? summary,
    bool? isLoading,
    bool? isSummaryLoading,
    String? error,
    AccountModel? selectedAccount,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool? isTransferring,
    bool clearError = false,
    bool clearSelectedAccount = false,
  }) {
    return AccountsState(
      accounts: accounts ?? this.accounts,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      error: clearError ? null : (error ?? this.error),
      selectedAccount: clearSelectedAccount ? null : (selectedAccount ?? this.selectedAccount),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      isTransferring: isTransferring ?? this.isTransferring,
    );
  }

  /// Get accounts filtered by type
  List<AccountModel> getAccountsByType(AccountType type) {
    return accounts.where((account) => account.type == type).toList();
  }

  /// Get all asset accounts (savings, current, cash, wallet, investment)
  List<AccountModel> get assetAccounts {
    const assetTypes = [
      AccountType.savings,
      AccountType.current,
      AccountType.cash,
      AccountType.wallet,
      AccountType.investment,
    ];
    return accounts.where((account) => assetTypes.contains(account.type)).toList();
  }

  /// Get all liability accounts (credit_card, loan)
  List<AccountModel> get liabilityAccounts {
    const liabilityTypes = [
      AccountType.creditCard,
      AccountType.loan,
    ];
    return accounts.where((account) => liabilityTypes.contains(account.type)).toList();
  }

  /// Get default account
  AccountModel? get defaultAccount {
    try {
      return accounts.firstWhere((account) => account.isDefault);
    } catch (_) {
      return accounts.isNotEmpty ? accounts.first : null;
    }
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress =>
      isCreating || isUpdating || isDeleting || isTransferring;

  @override
  List<Object?> get props => [
        accounts,
        summary,
        isLoading,
        isSummaryLoading,
        error,
        selectedAccount,
        isCreating,
        isUpdating,
        isDeleting,
        isTransferring,
      ];
}

/// Accounts State Notifier
class AccountsNotifier extends StateNotifier<AccountsState> {

  AccountsNotifier(this._repository) : super(const AccountsState.initial());
  final AccountsRepository _repository;

  /// Load all accounts
  Future<void> loadAccounts() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getAccounts();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (accounts) {
        state = state.copyWith(
          isLoading: false,
          accounts: accounts,
        );
      },
    );
  }

  /// Load accounts summary
  Future<void> loadSummary() async {
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
          summary: summary,
        );
      },
    );
  }

  /// Load both accounts and summary
  Future<void> loadAll() async {
    await Future.wait([
      loadAccounts(),
      loadSummary(),
    ]);
  }

  /// Get account by ID
  Future<AccountModel?> getAccountById(String id) async {
    // First try to find in local state
    try {
      final localAccount = state.accounts.firstWhere((a) => a.id == id);
      state = state.copyWith(selectedAccount: localAccount);
      return localAccount;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getAccountById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (account) {
        state = state.copyWith(
          isLoading: false,
          selectedAccount: account,
        );
        return account;
      },
    );
  }

  /// Create a new account
  Future<AccountModel?> createAccount(CreateAccountRequest request) async {
    if (state.isCreating) {
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createAccount(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (account) {
        state = state.copyWith(
          isCreating: false,
          accounts: [...state.accounts, account],
        );
        // Reload summary to update totals
        loadSummary();
        return account;
      },
    );
  }

  /// Update an existing account
  Future<AccountModel?> updateAccount(String id, CreateAccountRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateAccount(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedAccount) {
        final updatedAccounts = state.accounts.map((account) {
          return account.id == id ? updatedAccount : account;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          accounts: updatedAccounts,
          selectedAccount: updatedAccount,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedAccount;
      },
    );
  }

  /// Delete an account
  Future<bool> deleteAccount(String id) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteAccount(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedAccounts = state.accounts.where((a) => a.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          accounts: updatedAccounts,
          clearSelectedAccount: true,
        );
        // Reload summary to update totals
        loadSummary();
        return true;
      },
    );
  }

  /// Transfer between accounts
  Future<bool> transferBetweenAccounts(TransferRequest request) async {
    if (state.isTransferring) {
      return false;
    }

    state = state.copyWith(isTransferring: true, clearError: true);

    final result = await _repository.transferBetweenAccounts(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isTransferring: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isTransferring: false);
        // Reload accounts and summary to reflect new balances
        loadAll();
        return true;
      },
    );
  }

  /// Select an account
  void selectAccount(AccountModel? account) {
    state = account != null
        ? state.copyWith(selectedAccount: account)
        : state.copyWith(clearSelectedAccount: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const AccountsState.initial();
    await loadAll();
  }
}

/// Accounts State Provider
final accountsStateProvider =
    StateNotifierProvider.autoDispose<AccountsNotifier, AccountsState>((ref) {
  return AccountsNotifier(getIt<AccountsRepository>());
});

/// Accounts List Provider (computed from state)
final accountsListProvider = Provider<List<AccountModel>>((ref) {
  return ref.watch(accountsStateProvider).accounts;
});

/// Accounts Summary Provider (computed from state)
final accountsSummaryProvider = Provider<AccountsSummary?>((ref) {
  return ref.watch(accountsStateProvider).summary;
});

/// Selected Account Provider
final selectedAccountProvider = Provider<AccountModel?>((ref) {
  return ref.watch(accountsStateProvider).selectedAccount;
});

/// Accounts By Type Provider
final accountsByTypeProvider = Provider.family<List<AccountModel>, AccountType>((ref, type) {
  return ref.watch(accountsStateProvider).getAccountsByType(type);
});

/// Asset Accounts Provider (savings, current, cash, wallet, investment)
final assetAccountsProvider = Provider<List<AccountModel>>((ref) {
  return ref.watch(accountsStateProvider).assetAccounts;
});

/// Liability Accounts Provider (credit_card, loan)
final liabilityAccountsProvider = Provider<List<AccountModel>>((ref) {
  return ref.watch(accountsStateProvider).liabilityAccounts;
});

/// Default Account Provider
final defaultAccountProvider = Provider<AccountModel?>((ref) {
  return ref.watch(accountsStateProvider).defaultAccount;
});

/// Accounts Loading Provider
final accountsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(accountsStateProvider).isLoading;
});

/// Accounts Error Provider
final accountsErrorProvider = Provider<String?>((ref) {
  return ref.watch(accountsStateProvider).error;
});

/// Account Operation In Progress Provider
final accountsOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(accountsStateProvider).isOperationInProgress;
});
