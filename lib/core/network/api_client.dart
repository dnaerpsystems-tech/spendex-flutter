import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../errors/exceptions.dart';

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final Meta? meta;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
    );
  }
}

/// Pagination meta data
class Meta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}

/// API Error response
class ApiError {
  final String code;
  final String message;
  final List<dynamic>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'],
    );
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

/// API Client for making HTTP requests
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET request
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// POST request
  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// PUT request
  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// DELETE request
  Future<Either<Failure, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// PATCH request
  Future<Either<Failure, T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Upload file
  Future<Either<Failure, T>> uploadFile<T>(
    String path, {
    required File file,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    T Function(dynamic)? fromJson,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        ...?additionalData,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Download file
  Future<Either<Failure, File>> downloadFile(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return Right(File(savePath));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// Handle response
  Either<Failure, T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (fromJson != null && response.data != null) {
        if (response.data is Map && response.data['data'] != null) {
          return Right(fromJson(response.data['data']));
        }
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } else {
      final apiError = response.data is Map
          ? ApiError.fromJson(response.data['error'] ?? {})
          : ApiError(code: 'UNKNOWN', message: 'Unknown error');
      return Left(ServerFailure(apiError.message, code: apiError.code));
    }
  }

  /// Handle Dio errors
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'No internet connection. Please check your network.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkFailure(
            'No internet connection. Please check your network.',
          );
        }
        return UnexpectedFailure(error.message ?? 'An unknown error occurred');

      default:
        return UnexpectedFailure(error.message ?? 'An unknown error occurred');
    }
  }

  /// Handle bad response
  Failure _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerFailure('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = 'An error occurred';
    String code = 'UNKNOWN_ERROR';

    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        message = error['message'] ?? message;
        code = error['code'] ?? code;
      } else if (data['message'] != null) {
        message = data['message'];
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationFailure(message, code: code);
      case 401:
        return const AuthFailure('Session expired. Please login again.');
      case 403:
        return AuthFailure(message, code: code);
      case 404:
        return ServerFailure(message, code: code);
      case 409:
        return ServerFailure(message, code: code);
      case 422:
        return ValidationFailure(message, code: code);
      case 429:
        return const ServerFailure(
          'Too many requests. Please try again later.',
          code: 'RATE_LIMITED',
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerFailure(
          'Server error. Please try again later.',
          code: 'SERVER_ERROR',
        );
      default:
        return ServerFailure(message, code: code);
    }
  }
}
