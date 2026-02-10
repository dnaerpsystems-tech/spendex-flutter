import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';

/// Auth Interceptor for handling JWT token refresh
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor(this._storage, this._dio);

  final SecureStorageService _storage;
  final Dio _dio;
  bool _isRefreshing = false;
  final List<(RequestOptions, ErrorInterceptorHandler)> _pendingRequests = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Check if the failed request was the refresh token request itself
      if (err.requestOptions.path == ApiEndpoints.refresh) {
        await _storage.clearTokens();
        handler.reject(err);
        return;
      }

      // Queue the request if already refreshing
      if (_isRefreshing) {
        _pendingRequests.add((err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Retry the original request
          final retryResponse = await _retryRequest(err.requestOptions);
          handler.resolve(retryResponse);

          // Process pending requests
          await _processPendingRequests();
        } else {
          // Clear tokens and reject
          await _storage.clearTokens();
          handler.reject(err);
          _rejectPendingRequests(err);
        }
      } catch (e) {
        await _storage.clearTokens();
        handler.reject(err);
        _rejectPendingRequests(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  /// Refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      // Create a new Dio instance for refresh to avoid interceptor loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final responseData = response.data;
      if (response.statusCode == 200 &&
          responseData != null &&
          responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null) {
          final newAccessToken = data['accessToken'] as String;
          final newRefreshToken = data['refreshToken'] as String;

          await _storage.saveTokens(newAccessToken, newRefreshToken);

          if (kDebugMode) {
            print('Token refreshed successfully');
          }

          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Retry a failed request with new token
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final accessToken = await _storage.getAccessToken();

    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Process pending requests after token refresh
  Future<void> _processPendingRequests() async {
    final requests = List<(RequestOptions, ErrorInterceptorHandler)>.from(
      _pendingRequests,
    );
    _pendingRequests.clear();

    for (final (options, handler) in requests) {
      try {
        final response = await _retryRequest(options);
        handler.resolve(response);
      } catch (e) {
        handler.reject(
          DioException(
            requestOptions: options,
            error: e,
          ),
        );
      }
    }
  }

  /// Reject all pending requests
  void _rejectPendingRequests(DioException error) {
    for (final (options, handler) in _pendingRequests) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
        ),
      );
    }
    _pendingRequests.clear();
  }

  /// Check if endpoint is public (no auth required)
  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.refresh,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.biometricLoginOptions,
      ApiEndpoints.biometricLogin,
      ApiEndpoints.subscriptionPlans,
    ];

    return publicEndpoints.any((endpoint) => path.endsWith(endpoint));
  }
}
