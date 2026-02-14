import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/insight_model.dart';
import '../../domain/repositories/insights_repository.dart';

/// State class for managing insights data and UI state
class InsightsState extends Equatable {

  const InsightsState({
    this.allInsights = const [],
    this.dashboardInsights = const [],
    this.selectedType,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
  });
  final List<InsightModel> allInsights;
  final List<InsightModel> dashboardInsights;
  final InsightType? selectedType;
  final bool isLoading;
  final bool isGenerating;
  final String? error;

  /// Creates a copy of this state with the given fields replaced
  InsightsState copyWith({
    List<InsightModel>? allInsights,
    List<InsightModel>? dashboardInsights,
    InsightType? selectedType,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    bool clearError = false,
    bool clearSelectedType = false,
  }) {
    return InsightsState(
      allInsights: allInsights ?? this.allInsights,
      dashboardInsights: dashboardInsights ?? this.dashboardInsights,
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        allInsights,
        dashboardInsights,
        selectedType,
        isLoading,
        isGenerating,
        error,
      ];
}

/// Notifier for managing insights state and operations
class InsightsNotifier extends StateNotifier<InsightsState> {

  InsightsNotifier(this._repository) : super(const InsightsState());
  final InsightsRepository _repository;

  /// Load all insights from the repository
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getAll();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load insights: ${failure.message}',
        );
      },
      (insights) {
        state = state.copyWith(
          allInsights: insights,
          isLoading: false,
        );
      },
    );
  }

  /// Load dashboard insights (top insights for home screen)
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getDashboardInsights();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load dashboard insights: ${failure.message}',
        );
      },
      (insights) {
        state = state.copyWith(
          dashboardInsights: insights,
          isLoading: false,
        );
      },
    );
  }

  /// Load a specific insight by ID
  Future<InsightModel?> loadById(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getById(id);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to load insight: ${failure.message}',
        );
        return null;
      },
      (insight) {
        state = state.copyWith(isLoading: false);
        return insight;
      },
    );
  }

  /// Generate new insights based on the provided request
  Future<void> generateInsights(CreateInsightRequest request) async {
    state = state.copyWith(isGenerating: true, clearError: true);

    final result = await _repository.generateInsights(request);
    result.fold(
      (failure) {
        state = state.copyWith(
          isGenerating: false,
          error: 'Failed to generate insights: ${failure.message}',
        );
      },
      (insights) {
        state = state.copyWith(isGenerating: false);
        // Reload insights after generation
        loadAll();
        loadDashboard();
      },
    );
  }

  /// Mark an insight as read
  Future<void> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    result.fold(
      (failure) {
        state = state.copyWith(
          error: 'Failed to mark insight as read: ${failure.message}',
        );
      },
      (updatedInsight) {
        // Update local state
        final updatedAllInsights = state.allInsights.map((insight) {
          if (insight.id == id) {
            return insight.copyWith(isRead: true);
          }
          return insight;
        }).toList();

        final updatedDashboardInsights = state.dashboardInsights.map((insight) {
          if (insight.id == id) {
            return insight.copyWith(isRead: true);
          }
          return insight;
        }).toList();

        state = state.copyWith(
          allInsights: updatedAllInsights,
          dashboardInsights: updatedDashboardInsights,
        );
      },
    );
  }

  /// Dismiss an insight
  Future<void> dismiss(String id) async {
    final result = await _repository.dismiss(id);
    result.fold(
      (failure) {
        state = state.copyWith(
          error: 'Failed to dismiss insight: ${failure.message}',
        );
      },
      (success) {
        // Remove from local state
        final updatedAllInsights = state.allInsights
            .where((insight) => insight.id != id)
            .toList();

        final updatedDashboardInsights = state.dashboardInsights
            .where((insight) => insight.id != id)
            .toList();

        state = state.copyWith(
          allInsights: updatedAllInsights,
          dashboardInsights: updatedDashboardInsights,
        );
      },
    );
  }

  /// Refresh all insights data
  Future<void> refresh() async {
    await Future.wait([
      loadAll(),
      loadDashboard(),
    ]);
  }

  /// Filter insights by type
  void filterByType(InsightType? type) {
    state = state.copyWith(
      selectedType: type,
      clearSelectedType: type == null,
    );
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ============================================================================
// Providers
// ============================================================================

/// Main state notifier provider for insights
final insightsStateProvider =
    StateNotifierProvider.autoDispose<InsightsNotifier, InsightsState>((ref) {
  return InsightsNotifier(getIt<InsightsRepository>());
});

/// Provider for all insights list
final allInsightsProvider = Provider<List<InsightModel>>((ref) {
  final state = ref.watch(insightsStateProvider);
  final selectedType = state.selectedType;

  if (selectedType != null) {
    return state.allInsights
        .where((insight) => insight.type == selectedType)
        .toList();
  }

  return state.allInsights;
});

/// Provider for dashboard insights list
final dashboardInsightsProvider = Provider<List<InsightModel>>((ref) {
  return ref.watch(insightsStateProvider).dashboardInsights;
});

/// Provider for active insights only (not dismissed)
final activeInsightsProvider = Provider<List<InsightModel>>((ref) {
  final insights = ref.watch(allInsightsProvider);
  return insights.where((insight) => insight.isActive).toList();
});

/// Provider for unread insights count
final unreadCountProvider = Provider<int>((ref) {
  final insights = ref.watch(activeInsightsProvider);
  return insights.where((insight) => !insight.isRead).length;
});

/// Provider for loading state
final insightsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(insightsStateProvider).isLoading;
});

/// Provider for error state
final insightsErrorProvider = Provider<String?>((ref) {
  return ref.watch(insightsStateProvider).error;
});
