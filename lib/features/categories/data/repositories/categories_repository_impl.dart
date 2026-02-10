import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/categories_repository.dart';
import '../datasources/categories_remote_datasource.dart';
import '../models/category_model.dart';

/// Categories Repository Implementation
class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesRemoteDataSource _remoteDataSource;

  CategoriesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<CategoryModel>>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getIncomeCategories() {
    return _remoteDataSource.getIncomeCategories();
  }

  @override
  Future<Either<Failure, List<CategoryModel>>> getExpenseCategories() {
    return _remoteDataSource.getExpenseCategories();
  }

  @override
  Future<Either<Failure, CategoryModel>> getCategoryById(String id) {
    return _remoteDataSource.getCategoryById(id);
  }

  @override
  Future<Either<Failure, CategoryModel>> createCategory(CreateCategoryRequest request) {
    return _remoteDataSource.createCategory(request);
  }

  @override
  Future<Either<Failure, CategoryModel>> updateCategory(String id, CreateCategoryRequest request) {
    return _remoteDataSource.updateCategory(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) {
    return _remoteDataSource.deleteCategory(id);
  }

  @override
  Future<Either<Failure, CategoryModel?>> suggestCategory(CategorySuggestionRequest request) {
    return _remoteDataSource.suggestCategory(request);
  }
}
