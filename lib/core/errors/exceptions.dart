/// Base Exception class
class AppException implements Exception {
  AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server Exception - backend errors
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Network Exception - connectivity issues
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Auth Exception - authentication/authorization errors
class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

/// Validation Exception - invalid input
class ValidationException extends AppException {
  ValidationException(super.message, {super.code, this.errors});

  final Map<String, List<String>>? errors;
}

/// Cache Exception - local storage errors
class CacheException extends AppException {
  CacheException(super.message, {super.code});
}

/// Not Found Exception
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}

/// Rate Limit Exception
class RateLimitException extends AppException {
  RateLimitException(super.message, {super.code, this.retryAfter});

  final Duration? retryAfter;
}

/// Subscription Required Exception
class SubscriptionRequiredException extends AppException {
  SubscriptionRequiredException(super.message, {super.code, this.requiredPlan});

  final String? requiredPlan;
}

/// Limit Exceeded Exception
class LimitExceededException extends AppException {
  LimitExceededException(
    super.message, {
    super.code,
    this.limitType,
    this.currentUsage,
    this.maxLimit,
  });

  final String? limitType;
  final int? currentUsage;
  final int? maxLimit;
}
