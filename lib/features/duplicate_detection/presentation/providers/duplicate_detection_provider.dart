import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendex/core/di/injection.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_config.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_detection_result.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';
import 'package:spendex/features/duplicate_detection/domain/repositories/duplicate_detection_repository.dart';

/// Duplicate Detection State
class DuplicateDetectionState extends Equatable {
  const DuplicateDetectionState({
    this.isDetecting = false,
    this.result,
    this.resolutions = const {},
    this.isResolving = false,
    this.error,
    this.config = const DuplicateDetectionConfig(),
  });

  /// Initial state
  const DuplicateDetectionState.initial()
      : isDetecting = false,
        result = null,
        resolutions = const {},
        isResolving = false,
        error = null,
        config = const DuplicateDetectionConfig();

  /// Detecting state
  const DuplicateDetectionState.detecting()
      : isDetecting = true,
        result = null,
        resolutions = const {},
        isResolving = false,
        error = null,
        config = const DuplicateDetectionConfig();

  /// Detected state with results
  const DuplicateDetectionState.detected(this.result)
      : isDetecting = false,
        resolutions = const {},
        isResolving = false,
        error = null,
        config = const DuplicateDetectionConfig();

  /// Error state
  const DuplicateDetectionState.error(this.error)
      : isDetecting = false,
        result = null,
        resolutions = const {},
        isResolving = false,
        config = const DuplicateDetectionConfig();

  /// Whether duplicate detection is in progress
  final bool isDetecting;

  /// Result of duplicate detection
  final DuplicateDetectionResult? result;

  /// Map of duplicate match ID to user's chosen resolution action
  final Map<String, DuplicateResolutionAction> resolutions;

  /// Whether resolution submission is in progress
  final bool isResolving;

  /// Error message if detection or resolution failed
  final String? error;

  /// Configuration for duplicate detection
  final DuplicateDetectionConfig config;

  /// Get number of resolved duplicates
  int get resolvedCount => resolutions.length;

  /// Get number of total duplicates
  int get totalDuplicates => result?.duplicateMatches.length ?? 0;

  /// Check if all duplicates have been resolved
  bool get allResolved => totalDuplicates > 0 && resolvedCount == totalDuplicates;

  /// Get resolution progress text
  String get progressText => '$resolvedCount of $totalDuplicates resolved';

  /// Check if there are duplicates
  bool get hasDuplicates => result?.hasDuplicates ?? false;

  /// Copy with method
  DuplicateDetectionState copyWith({
    bool? isDetecting,
    DuplicateDetectionResult? result,
    Map<String, DuplicateResolutionAction>? resolutions,
    bool? isResolving,
    String? error,
    DuplicateDetectionConfig? config,
  }) {
    return DuplicateDetectionState(
      isDetecting: isDetecting ?? this.isDetecting,
      result: result ?? this.result,
      resolutions: resolutions ?? this.resolutions,
      isResolving: isResolving ?? this.isResolving,
      error: error,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        isDetecting,
        result,
        resolutions,
        isResolving,
        error,
        config,
      ];
}

/// Duplicate Detection State Notifier
class DuplicateDetectionNotifier extends StateNotifier<DuplicateDetectionState> {
  DuplicateDetectionNotifier(this._repository)
      : super(const DuplicateDetectionState.initial());

  final DuplicateDetectionRepository _repository;

  /// Detect duplicates for a list of transactions
  Future<void> detectDuplicates({
    required List<ParsedTransactionModel> transactions,
    DuplicateDetectionConfig? config,
  }) async {
    state = state.copyWith(
      isDetecting: true,
      error: null,
    );

    final result = await _repository.detectDuplicates(
      transactions: transactions,
      config: config ?? state.config,
    );

    result.fold(
      (failure) {
        state = DuplicateDetectionState.error(failure.message);
      },
      (detectionResult) {
        state = state.copyWith(
          isDetecting: false,
          result: detectionResult,
          error: null,
        );
      },
    );
  }

  /// Set resolution for a specific duplicate match
  void setResolution(String matchId, DuplicateResolutionAction action) {
    final updatedResolutions = Map<String, DuplicateResolutionAction>.from(state.resolutions);
    updatedResolutions[matchId] = action;

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Remove resolution for a specific duplicate match
  void removeResolution(String matchId) {
    final updatedResolutions = Map<String, DuplicateResolutionAction>.from(state.resolutions);
    updatedResolutions.remove(matchId);

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Apply the same resolution action to all duplicates
  void applyToAll(DuplicateResolutionAction action) {
    if (state.result == null) return;

    final updatedResolutions = <String, DuplicateResolutionAction>{};

    for (final match in state.result!.duplicateMatches) {
      updatedResolutions[match.id] = action;
    }

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Apply resolution to all high confidence duplicates
  void applyToHighConfidence(DuplicateResolutionAction action) {
    if (state.result == null) return;

    final updatedResolutions = Map<String, DuplicateResolutionAction>.from(state.resolutions);

    for (final match in state.result!.highConfidenceDuplicates) {
      updatedResolutions[match.id] = action;
    }

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Apply resolution to all medium confidence duplicates
  void applyToMediumConfidence(DuplicateResolutionAction action) {
    if (state.result == null) return;

    final updatedResolutions = Map<String, DuplicateResolutionAction>.from(state.resolutions);

    for (final match in state.result!.mediumConfidenceDuplicates) {
      updatedResolutions[match.id] = action;
    }

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Apply resolution to all low confidence duplicates
  void applyToLowConfidence(DuplicateResolutionAction action) {
    if (state.result == null) return;

    final updatedResolutions = Map<String, DuplicateResolutionAction>.from(state.resolutions);

    for (final match in state.result!.lowConfidenceDuplicates) {
      updatedResolutions[match.id] = action;
    }

    state = state.copyWith(resolutions: updatedResolutions);
  }

  /// Clear all resolutions
  void clearResolutions() {
    state = state.copyWith(resolutions: {});
  }

  /// Submit resolutions and import transactions
  Future<bool> submitResolutions({
    required String importId,
    required List<ParsedTransactionModel> uniqueTransactions,
  }) async {
    if (state.resolutions.isEmpty && !state.hasDuplicates) {
      // No duplicates, nothing to resolve
      return true;
    }

    state = state.copyWith(
      isResolving: true,
      error: null,
    );

    final result = await _repository.resolveDuplicates(
      importId: importId,
      resolutions: state.resolutions,
      uniqueTransactions: uniqueTransactions,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isResolving: false,
          error: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isResolving: false,
          error: null,
        );
        return success;
      },
    );
  }

  /// Update detection configuration
  void updateConfig(DuplicateDetectionConfig config) {
    state = state.copyWith(config: config);
  }

  /// Reset state to initial
  void reset() {
    state = const DuplicateDetectionState.initial();
  }
}

/// Provider for duplicate detection
final duplicateDetectionProvider =
    StateNotifierProvider<DuplicateDetectionNotifier, DuplicateDetectionState>(
  (ref) => DuplicateDetectionNotifier(getIt<DuplicateDetectionRepository>()),
);

/// Provider for duplicate detection repository
final duplicateDetectionRepositoryProvider =
    Provider<DuplicateDetectionRepository>(
  (ref) => getIt<DuplicateDetectionRepository>(),
);
