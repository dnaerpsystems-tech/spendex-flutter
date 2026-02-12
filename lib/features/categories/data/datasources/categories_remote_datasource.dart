import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/category_model.dart';

/// Categories Remote Data Source Interface
abstract class CategoriesRemoteDataSource {
  /// Get all categories
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

/// Categories Remote Data Source Implementation
class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {

  CategoriesRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.categories,
    );

    return result.fold(
      Left.new,
      (data) {
        final categories = data
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(categories);
      },
    );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getIncomeCategories() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.categoriesIncome,
    );

    return result.fold(
      Left.new,
      (data) {
        final categories = data
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(categories);
      },
    );
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getExpenseCategories() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.categoriesExpense,
    );

    return result.fold(
      Left.new,
      (data) {
        final categories = data
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(categories);
      },
    );
  }

  @override
  Future<Either<Failure, CategoryModel>> getCategoryById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.categoryById(id),
    );

    return result.fold(
      Left.new,
      (data) {
        final category = CategoryModel.fromJson(data);
        return Right(category);
      },
    );
  }

  @override
  Future<Either<Failure, CategoryModel>> createCategory(CreateCategoryRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.categories,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final category = CategoryModel.fromJson(data);
        return Right(category);
      },
    );
  }

  @override
  Future<Either<Failure, CategoryModel>> updateCategory(String id, CreateCategoryRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.categoryById(id),
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final category = CategoryModel.fromJson(data);
        return Right(category);
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.categoryById(id),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, CategoryModel?>> suggestCategory(CategorySuggestionRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>?>(
      ApiEndpoints.categoriesSuggest,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        if (data == null) {
          return const Right(null);
        }
        final category = CategoryModel.fromJson(data);
        return Right(category);
      },
    );
  }
}
