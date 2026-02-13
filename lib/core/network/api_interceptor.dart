import '../utils/app_logger.dart';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../storage/secure_storage.dart';

/// Auth Interceptor for handling JWT token attachment and refresh
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
    if (_isPublicEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _storage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Attach refresh token cookie for endpoints that need it
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      options.headers['Cookie'] = 'spendex_refresh=$refreshToken';
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    // Extract refresh token from Set-Cookie header on auth responses
    _extractAndSaveRefreshToken(response);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (err.requestOptions.path.contains(ApiEndpoints.refresh)) {
        await _storage.clearTokens();
        handler.reject(err);
        return;
      }

      if (_isRefreshing) {
        _pendingRequests.add((err.requestOptions, handler));
        return;
      }

      _isRefreshing = true;

      try {
        final refreshed = await _refreshToken();

        if (refreshed) {
          final retryResponse = await _retryRequest(err.requestOptions);
          handler.resolve(retryResponse);
          await _processPendingRequests();
        } else {
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

  /// Extract refresh token from Set-Cookie header and persist it
  void _extractAndSaveRefreshToken(Response<dynamic> response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders == null || setCookieHeaders.isEmpty) {
      return;
    }

    for (final cookie in setCookieHeaders) {
      if (cookie.startsWith('spendex_refresh=')) {
        final tokenValue = cookie
            .split(';')
            .first
            .replaceFirst('spendex_refresh=', '');
        if (tokenValue.isNotEmpty) {
          _storage.saveRefreshToken(tokenValue);
        }
        break;
      }
    }
  }

  /// Refresh the access token using the stored refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Use a separate Dio to avoid interceptor loop
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: _dio.options.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cookie': 'spendex_refresh=$refreshToken',
          },
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
      );

      final responseData = response.data;
      if (response.statusCode == 200 &&
          responseData != null &&
          responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>?;
        if (data != null && data['accessToken'] != null) {
          final newAccessToken = data['accessToken'] as String;
          await _storage.saveTokens(newAccessToken, null);

          // Extract new refresh token from response cookies
          final setCookieHeaders = response.headers['set-cookie'];
          if (setCookieHeaders != null) {
            for (final cookie in setCookieHeaders) {
              if (cookie.startsWith('spendex_refresh=')) {
                final newRefresh = cookie
                    .split(';')
                    .first
                    .replaceFirst('spendex_refresh=', '');
                if (newRefresh.isNotEmpty) {
                  await _storage.saveRefreshToken(newRefresh);
                }
                break;
              }
            }
          }

          if (kDebugMode) {
            AppLogger.d('AuthInterceptor: Token refreshed successfully');
          }
          return true;
        }
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('AuthInterceptor: Token refresh failed: $e');
      }
      return false;
    }
  }

  /// Retry a failed request with the new access token
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
  ) async {
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

  /// Replay queued requests after a successful token refresh
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
          DioException(requestOptions: options, error: e),
        );
      }
    }
  }

  /// Reject all queued requests
  void _rejectPendingRequests(DioException error) {
    for (final (options, handler) in _pendingRequests) {
      handler.reject(
        DioException(requestOptions: options, error: error),
      );
    }
    _pendingRequests.clear();
  }

  /// Endpoints that do not require authentication
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
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
