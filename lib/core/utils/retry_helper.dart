import 'dart:async';
import 'dart:math';

/// Utility class for retrying async operations with exponential backoff.
class RetryHelper {
  /// Executes an async operation with exponential backoff retry logic.
  ///
  /// [operation] - The async operation to execute
  /// [maxAttempts] - Maximum number of retry attempts (default: 3)
  /// [initialDelay] - Initial delay before first retry (default: 1 second)
  /// [maxDelay] - Maximum delay between retries (default: 30 seconds)
  /// [retryIf] - Optional condition to determine if retry should happen
  static Future<T> withExponentialBackoff<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    Duration maxDelay = const Duration(seconds: 30),
    bool Function(Exception)? retryIf,
  }) async {
    int attempts = 0;
    Duration currentDelay = initialDelay;

    while (true) {
      try {
        attempts++;
        return await operation();
      } on Exception catch (e) {
        if (attempts >= maxAttempts) {
          rethrow;
        }

        if (retryIf != null && !retryIf(e)) {
          rethrow;
        }

        // Add jitter to prevent thundering herd
        final jitter = Random().nextInt(1000);
        final delayWithJitter = currentDelay + Duration(milliseconds: jitter);

        await Future.delayed(delayWithJitter);

        // Exponential backoff with max cap
        currentDelay = Duration(
          milliseconds: min(
            currentDelay.inMilliseconds * 2,
            maxDelay.inMilliseconds,
          ),
        );
      }
    }
  }

  /// Check if an exception is retryable (network errors, timeouts, 5xx errors)
  static bool isRetryableException(Exception e) {
    final message = e.toString().toLowerCase();
    return message.contains('socket') ||
           message.contains('timeout') ||
           message.contains('connection') ||
           message.contains('503') ||
           message.contains('502') ||
           message.contains('500') ||
           message.contains('network');
  }
}
