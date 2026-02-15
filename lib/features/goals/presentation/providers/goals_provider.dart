import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/goal_model.dart';
import '../../domain/repositories/goals_repository.dart';

/// Goals State
class GoalsState extends Equatable {
  const GoalsState({
    this.goals = const [],
    this.summary,
    this.isLoading = false,
    this.isSummaryLoading = false,
    this.error,
    this.selectedGoal,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  const GoalsState.initial()
      : goals = const [],
        summary = null,
        isLoading = false,
        isSummaryLoading = false,
        error = null,
        selectedGoal = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false;
  final List<GoalModel> goals;
  final GoalsSummary? summary;
  final bool isLoading;
  final bool isSummaryLoading;
  final String? error;
  final GoalModel? selectedGoal;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  GoalsState copyWith({
    List<GoalModel>? goals,
    GoalsSummary? summary,
    bool? isLoading,
    bool? isSummaryLoading,
    String? error,
    GoalModel? selectedGoal,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
    bool clearSelectedGoal = false,
    bool clearSummary = false,
  }) {
    return GoalsState(
      goals: goals ?? this.goals,
      summary: clearSummary ? null : (summary ?? this.summary),
      isLoading: isLoading ?? this.isLoading,
      isSummaryLoading: isSummaryLoading ?? this.isSummaryLoading,
      error: clearError ? null : (error ?? this.error),
      selectedGoal: clearSelectedGoal ? null : (selectedGoal ?? this.selectedGoal),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Get active goals only
  List<GoalModel> get activeGoals {
    return goals.where((goal) => goal.isActive).toList();
  }

  /// Get completed goals
  List<GoalModel> get completedGoals {
    return goals.where((goal) => goal.isCompleted).toList();
  }

  /// Get goals filtered by status
  List<GoalModel> getGoalsByStatus(GoalStatus status) {
    return goals.where((goal) => goal.status == status).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        goals,
        summary,
        isLoading,
        isSummaryLoading,
        error,
        selectedGoal,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

/// Goals State Notifier
class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier(this._repository) : super(const GoalsState.initial());
  final GoalsRepository _repository;

  /// Load all goals
  Future<void> loadGoals() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getGoals();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (goals) {
        state = state.copyWith(
          isLoading: false,
          goals: goals,
        );
      },
    );
  }

  /// Load goals summary
  Future<void> loadSummary() async {
    if (state.isSummaryLoading) {
      return;
    }

    state = state.copyWith(isSummaryLoading: true);

    final result = await _repository.getGoalsSummary();

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

  /// Load both goals and summary
  Future<void> loadAll() async {
    await Future.wait([
      loadGoals(),
      loadSummary(),
    ]);
  }

  /// Get goal by ID
  Future<GoalModel?> loadGoalById(String id) async {
    // First try to find in local state
    try {
      final localGoal = state.goals.firstWhere((g) => g.id == id);
      state = state.copyWith(selectedGoal: localGoal);
      return localGoal;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getGoalById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (goal) {
        state = state.copyWith(
          isLoading: false,
          selectedGoal: goal,
        );
        return goal;
      },
    );
  }

  /// Create a new goal
  Future<GoalModel?> createGoal(CreateGoalRequest request) async {
    if (state.isCreating) {
      return null;
    }

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createGoal(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (goal) {
        state = state.copyWith(
          isCreating: false,
          goals: [...state.goals, goal],
        );
        // Reload summary to update totals
        loadSummary();
        return goal;
      },
    );
  }

  /// Update an existing goal
  Future<GoalModel?> updateGoal(String id, CreateGoalRequest request) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateGoal(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedGoal) {
        final updatedGoals = state.goals.map((goal) {
          return goal.id == id ? updatedGoal : goal;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          goals: updatedGoals,
          selectedGoal: updatedGoal,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedGoal;
      },
    );
  }

  /// Delete a goal
  Future<bool> deleteGoal(String id) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteGoal(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedGoals = state.goals.where((g) => g.id != id).toList();
        state = state.copyWith(
          isDeleting: false,
          goals: updatedGoals,
          clearSelectedGoal: true,
        );
        // Reload summary to update totals
        loadSummary();
        return true;
      },
    );
  }

  /// Add contribution to a goal
  Future<GoalModel?> addContribution(String goalId, int amount, String? notes) async {
    if (state.isUpdating) {
      return null;
    }

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.addContribution(goalId, amount, notes);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedGoal) {
        final updatedGoals = state.goals.map((goal) {
          return goal.id == goalId ? updatedGoal : goal;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          goals: updatedGoals,
          selectedGoal: updatedGoal,
        );
        // Reload summary to update totals
        loadSummary();
        return updatedGoal;
      },
    );
  }

  /// Select a goal
  void selectGoal(GoalModel? goal) {
    state =
        goal != null ? state.copyWith(selectedGoal: goal) : state.copyWith(clearSelectedGoal: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const GoalsState.initial();
    await loadAll();
  }
}

/// Goals State Provider
final goalsStateProvider = StateNotifierProvider.autoDispose<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier(getIt<GoalsRepository>());
});

/// Goals List Provider (computed from state)
final goalsListProvider = Provider<List<GoalModel>>((ref) {
  return ref.watch(goalsStateProvider).goals;
});

/// Goals Summary Provider (computed from state)
final goalsSummaryProvider = Provider<GoalsSummary?>((ref) {
  return ref.watch(goalsStateProvider).summary;
});

/// Selected Goal Provider
final selectedGoalProvider = Provider<GoalModel?>((ref) {
  return ref.watch(goalsStateProvider).selectedGoal;
});

/// Active Goals Provider
final activeGoalsProvider = Provider<List<GoalModel>>((ref) {
  return ref.watch(goalsStateProvider).activeGoals;
});

/// Completed Goals Provider
final completedGoalsProvider = Provider<List<GoalModel>>((ref) {
  return ref.watch(goalsStateProvider).completedGoals;
});

/// Goals By Status Provider
final goalsByStatusProvider = Provider.family<List<GoalModel>, GoalStatus>((ref, status) {
  return ref.watch(goalsStateProvider).getGoalsByStatus(status);
});

/// Goals Loading Provider
final goalsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(goalsStateProvider).isLoading;
});

/// Goals Error Provider
final goalsErrorProvider = Provider<String?>((ref) {
  return ref.watch(goalsStateProvider).error;
});

/// Goal Operation In Progress Provider
final goalsOperationInProgressProvider = Provider<bool>((ref) {
  return ref.watch(goalsStateProvider).isOperationInProgress;
});
