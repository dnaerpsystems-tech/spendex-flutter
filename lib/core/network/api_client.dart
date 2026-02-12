import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../errors/failures.dart';

/// API Response wrapper
class ApiResponse<T> {
  ApiResponse({
    required this.success,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, Object?> json,
    T Function(Object?)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      meta: json['meta'] != null
          ? Meta.fromJson(json['meta']! as Map<String, Object?>)
          : null,
      error: json['error'] != null
          ? ApiError.fromJson(json['error']! as Map<String, Object?>)
          : null,
    );
  }

  final bool success;
  final T? data;
  final Meta? meta;
  final ApiError? error;
}

/// Pagination meta data
class Meta {
  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, Object?> json) {
    return Meta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

/// API Error response
class ApiError {
  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, Object?> json) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unknown error occurred',
      details: json['details'] as List<Object?>?,
    );
  }

  final String code;
  final String message;
  final List<Object?>? details;
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<T> data;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

/// API Client for making HTTP requests
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  /// GET request
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    T Function(Object?)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// POST request
  Future<Either<Failure, T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object?)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// PUT request
  Future<Either<Failure, T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object?)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// DELETE request
  Future<Either<Failure, T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object?)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  /// PATCH request
  Future<Either<Failure, T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    T Function(Object?)? fromJson,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<Object?>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
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
    Map<String, Object?>? additionalData,
    T Function(Object?)? fromJson,
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

      final response = await _dio.post<Object?>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _handleResponse<T>(response, fromJson);
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
    Map<String, Object?>? queryParameters,
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
    Response<Object?> response,
    T Function(Object?)? fromJson,
  ) {
    debugPrint('API Response Status: ${response.statusCode}');
    debugPrint('API Response Data: ${response.data}');
    debugPrint('API Response Data Type: ${response.data.runtimeType}');

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      if (fromJson != null && response.data != null) {
        final responseData = response.data;
        debugPrint('API responseData type: ${responseData.runtimeType}');
        if (responseData is Map<String, Object?>) {
          debugPrint('API responseData[data]: ${responseData['data']}');
          debugPrint('API responseData[data] type: ${responseData['data'].runtimeType}');
          if (responseData['data'] != null) {
            return Right(fromJson(responseData['data']));
          }
        }
        return Right(fromJson(response.data));
      }
      return Right(response.data as T);
    } else {
      final responseData = response.data;
      final apiError = responseData is Map<String, Object?>
          ? ApiError.fromJson(
              responseData['error'] as Map<String, Object?>? ?? {},
            )
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
  Failure _handleBadResponse(Response<Object?>? response) {
    if (response == null) {
      return const ServerFailure('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    var message = 'An error occurred';
    var code = 'UNKNOWN_ERROR';

    if (data is Map<String, Object?>) {
      final error = data['error'];
      if (error is Map<String, Object?>) {
        message = error['message'] as String? ?? message;
        code = error['code'] as String? ?? code;
      } else if (data['message'] != null) {
        message = data['message'] as String? ?? message;
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
