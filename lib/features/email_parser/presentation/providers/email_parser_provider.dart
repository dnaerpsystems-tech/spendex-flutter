import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../../../bank_import/data/models/sms_message_model.dart';
import '../../data/models/email_account_model.dart';
import '../../data/models/email_filter_model.dart';
import '../../data/models/email_message_model.dart';
import '../../domain/repositories/email_parser_repository.dart';

/// Provider for Email Parser repository
final emailParserRepositoryProvider = Provider<EmailParserRepository>((ref) {
  return getIt<EmailParserRepository>();
});

/// Email account connection status
enum EmailConnectionStatus {
  idle,
  connecting,
  connected,
  failed,
  disconnecting,
}

/// State class for Email Parser
class EmailParserState extends Equatable {
  const EmailParserState({
    this.connectionStatus = EmailConnectionStatus.idle,
    this.isLoadingAccounts = false,
    this.isFetchingEmails = false,
    this.isParsing = false,
    this.isImporting = false,
    this.isImportingSingle = false,
    this.isDownloadingAttachment = false,
    this.downloadingAttachmentId,
    this.downloadProgress = 0,
    this.accounts = const [],
    this.selectedAccountId,
    this.emails = const [],
    this.selectedEmailIds = const {},
    this.filters,
    this.error,
    this.successMessage,
  });

  final EmailConnectionStatus connectionStatus;
  final bool isLoadingAccounts;
  final bool isFetchingEmails;
  final bool isParsing;
  final bool isImporting;
  final bool isImportingSingle;
  final bool isDownloadingAttachment;
  final String? downloadingAttachmentId;
  final double downloadProgress;
  final List<EmailAccountModel> accounts;
  final String? selectedAccountId;
  final List<EmailMessageModel> emails;
  final Set<String> selectedEmailIds;
  final EmailFilterModel? filters;
  final String? error;
  final String? successMessage;

  EmailParserState copyWith({
    EmailConnectionStatus? connectionStatus,
    bool? isLoadingAccounts,
    bool? isFetchingEmails,
    bool? isParsing,
    bool? isImporting,
    bool? isImportingSingle,
    bool? isDownloadingAttachment,
    String? downloadingAttachmentId,
    double? downloadProgress,
    List<EmailAccountModel>? accounts,
    String? selectedAccountId,
    List<EmailMessageModel>? emails,
    Set<String>? selectedEmailIds,
    EmailFilterModel? filters,
    String? error,
    String? successMessage,
  }) {
    return EmailParserState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isLoadingAccounts: isLoadingAccounts ?? this.isLoadingAccounts,
      isFetchingEmails: isFetchingEmails ?? this.isFetchingEmails,
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      isImportingSingle: isImportingSingle ?? this.isImportingSingle,
      isDownloadingAttachment: isDownloadingAttachment ?? this.isDownloadingAttachment,
      downloadingAttachmentId: downloadingAttachmentId ?? this.downloadingAttachmentId,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      accounts: accounts ?? this.accounts,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      emails: emails ?? this.emails,
      selectedEmailIds: selectedEmailIds ?? this.selectedEmailIds,
      filters: filters ?? this.filters,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        isLoadingAccounts,
        isFetchingEmails,
        isParsing,
        isImporting,
        isImportingSingle,
        isDownloadingAttachment,
        downloadingAttachmentId,
        downloadProgress,
        accounts,
        selectedAccountId,
        emails,
        selectedEmailIds,
        filters,
        error,
        successMessage,
      ];
}

/// Notifier for Email Parser
class EmailParserNotifier extends StateNotifier<EmailParserState> {
  EmailParserNotifier(this._repository) : super(const EmailParserState()) {
    _initialize();
  }

  final EmailParserRepository _repository;

  /// Initialize - load accounts and filters
  Future<void> _initialize() async {
    await loadAccounts();
    await loadFilters();
  }

  /// Load connected email accounts
  Future<void> loadAccounts() async {
    state = state.copyWith(
      isLoadingAccounts: true,
    );

    final result = await _repository.getAccounts();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingAccounts: false,
        error: failure.message,
      ),
      (accounts) {
        // Auto-select first account if available
        final selectedId = accounts.isNotEmpty ? accounts.first.id : null;

        state = state.copyWith(
          isLoadingAccounts: false,
          accounts: accounts,
          selectedAccountId: selectedId,
        );
      },
    );
  }

  /// Load filters
  Future<void> loadFilters() async {
    final result = await _repository.getFilters();

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (filters) => state = state.copyWith(filters: filters),
    );
  }

  /// Connect email account
  Future<bool> connectAccount({
    required String email,
    required String password,
    EmailProvider? provider,
    String? imapServer,
    int? imapPort,
  }) async {
    state = state.copyWith(
      connectionStatus: EmailConnectionStatus.connecting,
    );

    final result = await _repository.connectAccount(
      email: email,
      password: password,
      provider: provider,
      imapServer: imapServer,
      imapPort: imapPort,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          connectionStatus: EmailConnectionStatus.failed,
          error: failure.message,
        );
        return false;
      },
      (account) {
        final updatedAccounts = [...state.accounts, account];

        state = state.copyWith(
          connectionStatus: EmailConnectionStatus.connected,
          accounts: updatedAccounts,
          selectedAccountId: account.id,
          successMessage: 'Email account connected successfully',
        );
        return true;
      },
    );
  }

  /// Disconnect email account
  Future<bool> disconnectAccount(String accountId) async {
    state = state.copyWith(
      connectionStatus: EmailConnectionStatus.disconnecting,
    );

    final result = await _repository.disconnectAccount(accountId: accountId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          connectionStatus: EmailConnectionStatus.idle,
          error: failure.message,
        );
        return false;
      },
      (success) {
        final updatedAccounts = state.accounts.where((a) => a.id != accountId).toList();

        // Clear selected account if it was disconnected
        final newSelectedId = state.selectedAccountId == accountId
            ? (updatedAccounts.isNotEmpty ? updatedAccounts.first.id : null)
            : state.selectedAccountId;

        state = state.copyWith(
          connectionStatus: EmailConnectionStatus.idle,
          accounts: updatedAccounts,
          selectedAccountId: newSelectedId,
          emails: [], // Clear emails
          selectedEmailIds: {},
          successMessage: 'Email account disconnected successfully',
        );
        return true;
      },
    );
  }

  /// Select email account
  void selectAccount(String accountId) {
    state = state.copyWith(
      selectedAccountId: accountId,
      emails: [], // Clear emails when switching accounts
      selectedEmailIds: {},
    );
  }

  /// Fetch emails from selected account
  Future<void> fetchEmails() async {
    if (state.selectedAccountId == null) {
      state = state.copyWith(error: 'Please select an email account');
      return;
    }

    state = state.copyWith(
      isFetchingEmails: true,
    );

    final result = await _repository.fetchEmails(
      accountId: state.selectedAccountId!,
      filters: state.filters,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isFetchingEmails: false,
        error: failure.message,
      ),
      (emails) => state = state.copyWith(
        isFetchingEmails: false,
        emails: emails,
      ),
    );
  }

  /// Parse emails
  Future<void> parseEmails() async {
    if (state.emails.isEmpty) {
      state = state.copyWith(error: 'No emails to parse');
      return;
    }

    state = state.copyWith(isParsing: true);

    final result = await _repository.bulkParseEmails(emails: state.emails);

    result.fold(
      (failure) => state = state.copyWith(
        isParsing: false,
        error: failure.message,
      ),
      (parsedEmails) {
        // Auto-select successfully parsed emails
        final selectedIds =
            parsedEmails.where((e) => e.parseStatus == ParseStatus.parsed).map((e) => e.id).toSet();

        state = state.copyWith(
          isParsing: false,
          emails: parsedEmails,
          selectedEmailIds: selectedIds,
        );
      },
    );
  }

  /// Toggle email selection
  void toggleEmailSelection(String emailId) {
    final selected = Set<String>.from(state.selectedEmailIds);

    if (selected.contains(emailId)) {
      selected.remove(emailId);
    } else {
      selected.add(emailId);
    }

    state = state.copyWith(selectedEmailIds: selected);
  }

  /// Select all emails
  void selectAllEmails() {
    final allIds =
        state.emails.where((e) => e.parseStatus == ParseStatus.parsed).map((e) => e.id).toSet();
    state = state.copyWith(selectedEmailIds: allIds);
  }

  /// Deselect all emails
  void deselectAllEmails() {
    state = state.copyWith(selectedEmailIds: {});
  }

  /// Update filters
  Future<void> updateFilters(EmailFilterModel filters) async {
    final result = await _repository.updateFilters(filters: filters);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (success) => state = state.copyWith(
        filters: filters,
      ),
    );
  }

  /// Import selected transactions
  Future<bool> importTransactions() async {
    if (state.selectedEmailIds.isEmpty) {
      state = state.copyWith(error: 'Please select at least one email');
      return false;
    }

    state = state.copyWith(isImporting: true);

    // Get parsed transactions from selected emails
    final transactions = state.emails
        .where(
          (e) => state.selectedEmailIds.contains(e.id) && e.parsedTransaction != null,
        )
        .map((e) => e.parsedTransaction!)
        .toList();

    if (transactions.isEmpty) {
      state = state.copyWith(
        isImporting: false,
        error: 'No valid transactions to import',
      );
      return false;
    }

    final result = await _repository.bulkImportTransactions(
      transactions: transactions,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isImporting: false,
          error: failure.message,
        );
        return false;
      },
      (importedCount) {
        state = state.copyWith(
          isImporting: false,
          emails: [],
          selectedEmailIds: {},
          successMessage: '$importedCount transactions imported successfully',
        );
        return true;
      },
    );
  }

  /// Import single transaction
  Future<bool> importSingleTransaction({
    required ParsedTransactionModel transaction,
  }) async {
    state = state.copyWith(isImportingSingle: true);

    final result = await _repository.importTransaction(
      transaction: transaction,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isImportingSingle: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isImportingSingle: false,
          successMessage: 'Transaction imported successfully',
        );
        return success;
      },
    );
  }

  /// Download email attachment
  Future<File?> downloadAttachment({
    required String attachmentId,
    required String fileName,
  }) async {
    // Step 1: Get save location from user
    final savePath = await _getSaveLocation(fileName);
    if (savePath == null) {
      // User cancelled
      return null;
    }

    // Step 2: Update state to show downloading
    state = state.copyWith(
      isDownloadingAttachment: true,
      downloadingAttachmentId: attachmentId,
      downloadProgress: 0,
    );

    // Step 3: Download with progress tracking
    final result = await _repository.downloadAttachment(
      attachmentId: attachmentId,
      savePath: savePath,
      onProgress: (progress) {
        state = state.copyWith(
          downloadProgress: progress,
        );
      },
    );

    // Step 4: Handle result
    return result.fold(
      (failure) {
        state = state.copyWith(
          isDownloadingAttachment: false,
          downloadProgress: 0,
          error: failure.message,
        );
        return null;
      },
      (file) {
        state = state.copyWith(
          isDownloadingAttachment: false,
          downloadProgress: 1,
        );
        return file;
      },
    );
  }

  /// Get save location using file picker
  Future<String?> _getSaveLocation(String fileName) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Attachment',
        fileName: fileName,
      );
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Sync account status
  Future<void> syncAccountStatus(String accountId) async {
    final result = await _repository.syncAccountStatus(accountId: accountId);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (account) {
        final updatedAccounts = state.accounts.map((a) {
          return a.id == accountId ? account : a;
        }).toList();

        state = state.copyWith(
          accounts: updatedAccounts,
        );
      },
    );
  }

  /// Toggle email tracking
  Future<void> toggleEmailTracking(String accountId, {required bool enabled}) async {
    final result = await _repository.toggleEmailTracking(
      accountId: accountId,
      enabled: enabled,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (success) => state = state.copyWith(),
    );
  }

  /// Clear emails
  void clearEmails() {
    state = state.copyWith(
      emails: [],
      selectedEmailIds: {},
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith();
  }
}

/// Provider for Email Parser state
final emailParserProvider = StateNotifierProvider<EmailParserNotifier, EmailParserState>((ref) {
  final repository = ref.watch(emailParserRepositoryProvider);
  return EmailParserNotifier(repository);
});

/// Computed providers

/// Selected account
final selectedAccountProvider = Provider<EmailAccountModel?>((ref) {
  final state = ref.watch(emailParserProvider);
  if (state.selectedAccountId == null) {
    return null;
  }
  final account = state.accounts.where((a) => a.id == state.selectedAccountId);
  if (account.isNotEmpty) {
    return account.first;
  }
  return state.accounts.isNotEmpty ? state.accounts.first : null;
});

/// Selected email count
final selectedEmailCountProvider = Provider<int>((ref) {
  final state = ref.watch(emailParserProvider);
  return state.selectedEmailIds.length;
});

/// Parsed email count
final parsedEmailCountProvider = Provider<int>((ref) {
  final state = ref.watch(emailParserProvider);
  return state.emails.where((e) => e.parseStatus == ParseStatus.parsed).length;
});

/// Failed email count
final failedEmailCountProvider = Provider<int>((ref) {
  final state = ref.watch(emailParserProvider);
  return state.emails.where((e) => e.parseStatus == ParseStatus.failed).length;
});

/// Total amount of selected transactions
final selectedEmailsTotalProvider = Provider<double>((ref) {
  final state = ref.watch(emailParserProvider);
  final selectedEmails = state.emails.where(
    (e) => state.selectedEmailIds.contains(e.id) && e.parsedTransaction != null,
  );

  return selectedEmails.fold<double>(
    0,
    (sum, email) => sum + (email.parsedTransaction?.amount ?? 0.0),
  );
});

/// Whether all parsed emails are selected
final allEmailsSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(emailParserProvider);
  final parsedCount = state.emails.where((e) => e.parseStatus == ParseStatus.parsed).length;

  if (parsedCount == 0) {
    return false;
  }

  return state.selectedEmailIds.length == parsedCount;
});

/// Has connected accounts
final hasConnectedAccountsProvider = Provider<bool>((ref) {
  final state = ref.watch(emailParserProvider);
  return state.accounts.isNotEmpty;
});

/// Email statistics
final emailStatsProvider = Provider<Map<String, int>>((ref) {
  final state = ref.watch(emailParserProvider);

  return {
    'total': state.emails.length,
    'parsed': state.emails.where((e) => e.parseStatus == ParseStatus.parsed).length,
    'failed': state.emails.where((e) => e.parseStatus == ParseStatus.failed).length,
    'unparsed': state.emails.where((e) => e.parseStatus == ParseStatus.unparsed).length,
    'selected': state.selectedEmailIds.length,
  };
});
