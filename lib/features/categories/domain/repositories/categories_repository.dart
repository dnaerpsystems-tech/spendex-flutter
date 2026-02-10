import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/category_model.dart';

/// Categories Repository Interface
/// Defines the contract for categories data operations
abstract class CategoriesRepository {
  /// Get all categories for the current user
  Future<Either<Failure, List<CategoryModel>>> getCategories();

  /// Get income categories
  Future<Either<Failure, List<CategoryModel>>> getIncomeCategories();

  /// Get expense categories
  Future<Either<Failure, List<CategoryModel>>> getExpenseCategories();

  /// Get a specific category by ID
  Future<Either<Failure, CategoryModel>> getCategoryById(String id);

  /// Create a new category
  Future<Either<Failure, CategoryModel>> createCategory(CreateCategoryRequest request);

  /// Update an existing category
  Future<Either<Failure, CategoryModel>> updateCategory(String id, CreateCategoryRequest request);

  /// Delete a category
  Future<Either<Failure, void>> deleteCategory(String id);

  /// Suggest category based on description
  Future<Either<Failure, CategoryModel?>> suggestCategory(CategorySuggestionRequest request);
}
