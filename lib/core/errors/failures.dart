import 'package:equatable/equatable.dart';

/// Base Failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Network failure - no internet connection
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Server failure - backend error
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Authentication failure - unauthorized or forbidden
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Validation failure - invalid input
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Cache failure - local storage error
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Unexpected failure - unknown error
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}

/// Subscription required failure
class SubscriptionRequiredFailure extends Failure {
  const SubscriptionRequiredFailure(super.message, {super.code});
}

/// Limit exceeded failure
class LimitExceededFailure extends Failure {
  const LimitExceededFailure(super.message, {super.code});
}

/// Extension to get user-friendly error message
extension FailureExtension on Failure {
  String get userMessage {
    switch (code) {
      case 'UNAUTHORIZED':
        return 'Your session has expired. Please login again.';
      case 'FORBIDDEN':
        return 'You do not have permission to perform this action.';
      case 'NOT_FOUND':
        return 'The requested resource was not found.';
      case 'VALIDATION_ERROR':
        return message;
      case 'RATE_LIMITED':
        return 'Too many requests. Please wait a moment and try again.';
      case 'SUBSCRIPTION_REQUIRED':
        return 'This feature requires a paid subscription.';
      case 'LIMIT_EXCEEDED':
        return 'You have reached your plan limit. Please upgrade to continue.';
      case 'SERVER_ERROR':
        return 'Something went wrong on our end. Please try again later.';
      default:
        return message;
    }
  }
}
