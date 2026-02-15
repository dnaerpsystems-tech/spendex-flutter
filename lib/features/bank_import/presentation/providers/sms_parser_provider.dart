import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/bank_config_model.dart';
import '../../data/models/sms_message_model.dart';
import '../../domain/repositories/sms_parser_repository.dart';

/// Provider for SMS Parser repository
final smsParserRepositoryProvider = Provider<SmsParserRepository>((ref) {
  return getIt<SmsParserRepository>();
});

/// SMS Permission status
enum SmsPermissionStatus {
  unknown,
  checking,
  granted,
  denied,
  permanentlyDenied,
}

/// State class for SMS Parser
class SmsParserState extends Equatable {
  const SmsParserState({
    this.permissionStatus = SmsPermissionStatus.unknown,
    this.isLoadingSms = false,
    this.isLoadingBankConfigs = false,
    this.isParsing = false,
    this.isImporting = false,
    this.smsMessages = const [],
    this.bankConfigs = const [],
    this.selectedBanks = const {},
    this.selectedSms = const {},
    this.dateRange,
    this.isSmsTrackingEnabled = false,
    this.error,
  });

  final SmsPermissionStatus permissionStatus;
  final bool isLoadingSms;
  final bool isLoadingBankConfigs;
  final bool isParsing;
  final bool isImporting;
  final List<SmsMessageModel> smsMessages;
  final List<BankConfigModel> bankConfigs;
  final Set<String> selectedBanks; // Bank names
  final Set<String> selectedSms; // SMS IDs
  final DateTimeRange? dateRange;
  final bool isSmsTrackingEnabled;
  final String? error;

  SmsParserState copyWith({
    SmsPermissionStatus? permissionStatus,
    bool? isLoadingSms,
    bool? isLoadingBankConfigs,
    bool? isParsing,
    bool? isImporting,
    List<SmsMessageModel>? smsMessages,
    List<BankConfigModel>? bankConfigs,
    Set<String>? selectedBanks,
    Set<String>? selectedSms,
    DateTimeRange? dateRange,
    bool? isSmsTrackingEnabled,
    String? error,
  }) {
    return SmsParserState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoadingSms: isLoadingSms ?? this.isLoadingSms,
      isLoadingBankConfigs: isLoadingBankConfigs ?? this.isLoadingBankConfigs,
      isParsing: isParsing ?? this.isParsing,
      isImporting: isImporting ?? this.isImporting,
      smsMessages: smsMessages ?? this.smsMessages,
      bankConfigs: bankConfigs ?? this.bankConfigs,
      selectedBanks: selectedBanks ?? this.selectedBanks,
      selectedSms: selectedSms ?? this.selectedSms,
      dateRange: dateRange ?? this.dateRange,
      isSmsTrackingEnabled: isSmsTrackingEnabled ?? this.isSmsTrackingEnabled,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        permissionStatus,
        isLoadingSms,
        isLoadingBankConfigs,
        isParsing,
        isImporting,
        smsMessages,
        bankConfigs,
        selectedBanks,
        selectedSms,
        dateRange,
        isSmsTrackingEnabled,
        error,
      ];
}

/// Notifier for SMS Parser
class SmsParserNotifier extends StateNotifier<SmsParserState> {
  SmsParserNotifier(this._repository) : super(const SmsParserState()) {
    _initialize();
  }

  final SmsParserRepository _repository;

  /// Initialize - check permissions and load bank configs
  Future<void> _initialize() async {
    await checkPermissions();
    await loadBankConfigs();
  }

  /// Check SMS permissions
  Future<void> checkPermissions() async {
    state = state.copyWith(
      permissionStatus: SmsPermissionStatus.checking,
    );

    final result = await _repository.checkSmsPermissions();

    result.fold(
      (failure) => state = state.copyWith(
        permissionStatus: SmsPermissionStatus.unknown,
        error: failure.message,
      ),
      (hasPermission) => state = state.copyWith(
        permissionStatus: hasPermission ? SmsPermissionStatus.granted : SmsPermissionStatus.denied,
      ),
    );
  }

  /// Request SMS permissions
  Future<bool> requestPermissions() async {
    state = state.copyWith(
      permissionStatus: SmsPermissionStatus.checking,
    );

    final result = await _repository.requestSmsPermissions();

    return result.fold(
      (failure) {
        state = state.copyWith(
          permissionStatus: SmsPermissionStatus.denied,
          error: failure.message,
        );
        return false;
      },
      (granted) {
        state = state.copyWith(
          permissionStatus: granted ? SmsPermissionStatus.granted : SmsPermissionStatus.denied,
        );
        return granted;
      },
    );
  }

  /// Load bank configs
  Future<void> loadBankConfigs() async {
    state = state.copyWith(isLoadingBankConfigs: true);

    final result = await _repository.getBankConfigs();

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingBankConfigs: false,
        error: failure.message,
      ),
      (configs) {
        // Select all banks by default
        final bankNames = configs.map((c) => c.bankName).toSet();

        state = state.copyWith(
          isLoadingBankConfigs: false,
          bankConfigs: configs,
          selectedBanks: bankNames,
        );
      },
    );
  }

  /// Set date range for SMS filtering
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  /// Toggle bank selection
  void toggleBankSelection(String bankName) {
    final selected = Set<String>.from(state.selectedBanks);

    if (selected.contains(bankName)) {
      selected.remove(bankName);
    } else {
      selected.add(bankName);
    }

    state = state.copyWith(selectedBanks: selected);
  }

  /// Select all banks
  void selectAllBanks() {
    final allBanks = state.bankConfigs.map((c) => c.bankName).toSet();
    state = state.copyWith(selectedBanks: allBanks);
  }

  /// Deselect all banks
  void deselectAllBanks() {
    state = state.copyWith(selectedBanks: {});
  }

  /// Read SMS messages
  Future<void> readSmsMessages() async {
    if (state.permissionStatus != SmsPermissionStatus.granted) {
      state = state.copyWith(error: 'SMS permission not granted');
      return;
    }

    if (state.dateRange == null) {
      state = state.copyWith(
        error: 'Please select a date range',
      );
      return;
    }

    state = state.copyWith(
      isLoadingSms: true,
    );

    final result = await _repository.readSmsMessages(
      state.dateRange!.start,
      state.dateRange!.end,
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          isLoadingSms: false,
          error: failure.message,
        );
      },
      (messages) async {
        // Filter messages by selected banks
        final filteredMessages = messages.where((msg) {
          return state.selectedBanks.contains(msg.bankName);
        }).toList();

        // Parse all messages
        await _parseMessages(filteredMessages);
      },
    );
  }

  /// Parse SMS messages
  Future<void> _parseMessages(List<SmsMessageModel> messages) async {
    state = state.copyWith(isParsing: true);

    final parsedMessages = <SmsMessageModel>[];

    for (final sms in messages) {
      final result = await _repository.parseSmsMessage(sms);

      result.fold(
        (failure) {
          // Keep original SMS with failed status
          parsedMessages.add(sms.copyWith(parseStatus: ParseStatus.failed));
        },
        (parsedTransaction) {
          if (parsedTransaction != null) {
            parsedMessages.add(
              sms.copyWith(
                parseStatus: ParseStatus.parsed,
                parsedTransaction: parsedTransaction,
              ),
            );
          } else {
            parsedMessages.add(sms.copyWith(parseStatus: ParseStatus.failed));
          }
        },
      );
    }

    // Select all successfully parsed SMS by default
    final selectedIds =
        parsedMessages.where((s) => s.parseStatus == ParseStatus.parsed).map((s) => s.id).toSet();

    state = state.copyWith(
      isLoadingSms: false,
      isParsing: false,
      smsMessages: parsedMessages,
      selectedSms: selectedIds,
    );
  }

  /// Toggle SMS selection
  void toggleSmsSelection(String smsId) {
    final selected = Set<String>.from(state.selectedSms);

    if (selected.contains(smsId)) {
      selected.remove(smsId);
    } else {
      selected.add(smsId);
    }

    state = state.copyWith(selectedSms: selected);
  }

  /// Select all SMS
  void selectAllSms() {
    final allIds = state.smsMessages
        .where((s) => s.parseStatus == ParseStatus.parsed)
        .map((s) => s.id)
        .toSet();
    state = state.copyWith(selectedSms: allIds);
  }

  /// Deselect all SMS
  void deselectAllSms() {
    state = state.copyWith(selectedSms: {});
  }

  /// Bulk import selected transactions
  Future<bool> bulkImportTransactions() async {
    if (state.selectedSms.isEmpty) {
      state = state.copyWith(error: 'Please select at least one SMS');
      return false;
    }

    state = state.copyWith(isImporting: true);

    // Get parsed transactions from selected SMS
    final transactions = state.smsMessages
        .where(
          (s) => state.selectedSms.contains(s.id) && s.parsedTransaction != null,
        )
        .map((s) => s.parsedTransaction!)
        .toList();

    final result = await _repository.bulkImportTransactions(transactions);

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
          smsMessages: [],
          selectedSms: {},
        );
        return true;
      },
    );
  }

  /// Toggle SMS tracking
  Future<void> toggleSmsTracking({required bool enabled}) async {
    final result = await _repository.toggleSmsTracking(enabled: enabled);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (success) => state = state.copyWith(
        isSmsTrackingEnabled: enabled,
      ),
    );
  }

  /// Clear SMS messages
  void clearSmsMessages() {
    state = state.copyWith(
      smsMessages: [],
      selectedSms: {},
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith();
  }
}

/// Provider for SMS Parser state
final smsParserProvider = StateNotifierProvider<SmsParserNotifier, SmsParserState>((ref) {
  final repository = ref.watch(smsParserRepositoryProvider);
  return SmsParserNotifier(repository);
});

/// Computed providers

/// Selected SMS count
final selectedSmsCountProvider = Provider<int>((ref) {
  final state = ref.watch(smsParserProvider);
  return state.selectedSms.length;
});

/// Parsed SMS count
final parsedSmsCountProvider = Provider<int>((ref) {
  final state = ref.watch(smsParserProvider);
  return state.smsMessages.where((s) => s.parseStatus == ParseStatus.parsed).length;
});

/// Failed SMS count
final failedSmsCountProvider = Provider<int>((ref) {
  final state = ref.watch(smsParserProvider);
  return state.smsMessages.where((s) => s.parseStatus == ParseStatus.failed).length;
});

/// Total amount of selected transactions
final selectedSmsTotalProvider = Provider<int>((ref) {
  final state = ref.watch(smsParserProvider);
  final selectedMessages = state.smsMessages
      .where((s) => state.selectedSms.contains(s.id) && s.parsedTransaction != null);

  return selectedMessages.fold<int>(
    0,
    (sum, sms) => sum + (sms.parsedTransaction?.amount.toInt() ?? 0),
  );
});

/// Whether all parsed SMS are selected
final allSmsSelectedProvider = Provider<bool>((ref) {
  final state = ref.watch(smsParserProvider);
  final parsedCount = state.smsMessages.where((s) => s.parseStatus == ParseStatus.parsed).length;

  if (parsedCount == 0) {
    return false;
  }

  return state.selectedSms.length == parsedCount;
});
