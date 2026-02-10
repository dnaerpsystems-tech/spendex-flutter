import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/categories_repository.dart';

/// Categories State
class CategoriesState extends Equatable {
  final List<CategoryModel> categories;
  final List<CategoryModel> incomeCategories;
  final List<CategoryModel> expenseCategories;
  final bool isLoading;
  final bool isIncomeLoading;
  final bool isExpenseLoading;
  final String? error;
  final CategoryModel? selectedCategory;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const CategoriesState({
    this.categories = const [],
    this.incomeCategories = const [],
    this.expenseCategories = const [],
    this.isLoading = false,
    this.isIncomeLoading = false,
    this.isExpenseLoading = false,
    this.error,
    this.selectedCategory,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  const CategoriesState.initial()
      : categories = const [],
        incomeCategories = const [],
        expenseCategories = const [],
        isLoading = false,
        isIncomeLoading = false,
        isExpenseLoading = false,
        error = null,
        selectedCategory = null,
        isCreating = false,
        isUpdating = false,
        isDeleting = false;

  CategoriesState copyWith({
    List<CategoryModel>? categories,
    List<CategoryModel>? incomeCategories,
    List<CategoryModel>? expenseCategories,
    bool? isLoading,
    bool? isIncomeLoading,
    bool? isExpenseLoading,
    String? error,
    CategoryModel? selectedCategory,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearError = false,
    bool clearSelectedCategory = false,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      isLoading: isLoading ?? this.isLoading,
      isIncomeLoading: isIncomeLoading ?? this.isIncomeLoading,
      isExpenseLoading: isExpenseLoading ?? this.isExpenseLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Get categories by type
  List<CategoryModel> getCategoriesByType(CategoryType type) {
    return categories.where((c) => c.type == type).toList();
  }

  /// Check if any operation is in progress
  bool get isOperationInProgress => isCreating || isUpdating || isDeleting;

  @override
  List<Object?> get props => [
        categories,
        incomeCategories,
        expenseCategories,
        isLoading,
        isIncomeLoading,
        isExpenseLoading,
        error,
        selectedCategory,
        isCreating,
        isUpdating,
        isDeleting,
      ];
}

/// Categories State Notifier
class CategoriesNotifier extends StateNotifier<CategoriesState> {
  final CategoriesRepository _repository;

  CategoriesNotifier(this._repository) : super(const CategoriesState.initial());

  /// Load all categories
  Future<void> loadCategories() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getCategories();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (categories) {
        state = state.copyWith(
          isLoading: false,
          categories: categories,
        );
      },
    );
  }

  /// Load income categories
  Future<void> loadIncomeCategories() async {
    if (state.isIncomeLoading) return;

    state = state.copyWith(isIncomeLoading: true, clearError: true);

    final result = await _repository.getIncomeCategories();

    result.fold(
      (failure) {
        state = state.copyWith(
          isIncomeLoading: false,
          error: failure.message,
        );
      },
      (categories) {
        state = state.copyWith(
          isIncomeLoading: false,
          incomeCategories: categories,
        );
      },
    );
  }

  /// Load expense categories
  Future<void> loadExpenseCategories() async {
    if (state.isExpenseLoading) return;

    state = state.copyWith(isExpenseLoading: true, clearError: true);

    final result = await _repository.getExpenseCategories();

    result.fold(
      (failure) {
        state = state.copyWith(
          isExpenseLoading: false,
          error: failure.message,
        );
      },
      (categories) {
        state = state.copyWith(
          isExpenseLoading: false,
          expenseCategories: categories,
        );
      },
    );
  }

  /// Load all categories (both types)
  Future<void> loadAll() async {
    await Future.wait([
      loadCategories(),
      loadIncomeCategories(),
      loadExpenseCategories(),
    ]);
  }

  /// Get category by ID
  Future<CategoryModel?> getCategoryById(String id) async {
    // First try to find in local state
    try {
      final localCategory = state.categories.firstWhere((c) => c.id == id);
      state = state.copyWith(selectedCategory: localCategory);
      return localCategory;
    } catch (_) {
      // Not found locally, fetch from server
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getCategoryById(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return null;
      },
      (category) {
        state = state.copyWith(
          isLoading: false,
          selectedCategory: category,
        );
        return category;
      },
    );
  }

  /// Create a new category
  Future<CategoryModel?> createCategory(CreateCategoryRequest request) async {
    if (state.isCreating) return null;

    state = state.copyWith(isCreating: true, clearError: true);

    final result = await _repository.createCategory(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: failure.message,
        );
        return null;
      },
      (category) {
        final updatedCategories = [...state.categories, category];
        final updatedIncome = category.isIncome
            ? [...state.incomeCategories, category]
            : state.incomeCategories;
        final updatedExpense = category.isExpense
            ? [...state.expenseCategories, category]
            : state.expenseCategories;

        state = state.copyWith(
          isCreating: false,
          categories: updatedCategories,
          incomeCategories: updatedIncome,
          expenseCategories: updatedExpense,
        );
        return category;
      },
    );
  }

  /// Update an existing category
  Future<CategoryModel?> updateCategory(String id, CreateCategoryRequest request) async {
    if (state.isUpdating) return null;

    state = state.copyWith(isUpdating: true, clearError: true);

    final result = await _repository.updateCategory(id, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdating: false,
          error: failure.message,
        );
        return null;
      },
      (updatedCategory) {
        final updatedCategories = state.categories.map((c) {
          return c.id == id ? updatedCategory : c;
        }).toList();

        final updatedIncome = state.incomeCategories.map((c) {
          return c.id == id ? updatedCategory : c;
        }).toList();

        final updatedExpense = state.expenseCategories.map((c) {
          return c.id == id ? updatedCategory : c;
        }).toList();

        state = state.copyWith(
          isUpdating: false,
          categories: updatedCategories,
          incomeCategories: updatedIncome,
          expenseCategories: updatedExpense,
          selectedCategory: updatedCategory,
        );
        return updatedCategory;
      },
    );
  }

  /// Delete a category
  Future<bool> deleteCategory(String id) async {
    if (state.isDeleting) return false;

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteCategory(id);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedCategories = state.categories.where((c) => c.id != id).toList();
        final updatedIncome = state.incomeCategories.where((c) => c.id != id).toList();
        final updatedExpense = state.expenseCategories.where((c) => c.id != id).toList();

        state = state.copyWith(
          isDeleting: false,
          categories: updatedCategories,
          incomeCategories: updatedIncome,
          expenseCategories: updatedExpense,
          clearSelectedCategory: true,
        );
        return true;
      },
    );
  }

  /// Suggest category based on description
  Future<CategoryModel?> suggestCategory(CategorySuggestionRequest request) async {
    final result = await _repository.suggestCategory(request);

    return result.fold(
      (failure) => null,
      (category) => category,
    );
  }

  /// Select a category
  void selectCategory(CategoryModel? category) {
    state = category != null
        ? state.copyWith(selectedCategory: category)
        : state.copyWith(clearSelectedCategory: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Refresh all data
  Future<void> refresh() async {
    state = const CategoriesState.initial();
    await loadAll();
  }
}

/// Categories State Provider
final categoriesStateProvider =
    StateNotifierProvider<CategoriesNotifier, CategoriesState>((ref) {
  return CategoriesNotifier(getIt<CategoriesRepository>());
});

/// Categories List Provider (computed from state)
final categoriesListProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoriesStateProvider).categories;
});

/// Income Categories Provider
final incomeCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoriesStateProvider).incomeCategories;
});

/// Expense Categories Provider
final expenseCategoriesProvider = Provider<List<CategoryModel>>((ref) {
  return ref.watch(categoriesStateProvider).expenseCategories;
});

/// Selected Category Provider
final selectedCategoryProvider = Provider<CategoryModel?>((ref) {
  return ref.watch(categoriesStateProvider).selectedCategory;
});

/// Categories By Type Provider
final categoriesByTypeProvider =
    Provider.family<List<CategoryModel>, CategoryType>((ref, type) {
  return ref.watch(categoriesStateProvider).getCategoriesByType(type);
});

/// Categories Loading Provider
final categoriesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(categoriesStateProvider).isLoading;
});

/// Categories Error Provider
final categoriesErrorProvider = Provider<String?>((ref) {
  return ref.watch(categoriesStateProvider).error;
});
