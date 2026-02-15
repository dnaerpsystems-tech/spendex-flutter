import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    group('withExponentialBackoff', () {
      test('should succeed on first attempt', () async {
        var attempts = 0;
        final result = await RetryHelper.withExponentialBackoff<String>(
          operation: () async {
            attempts++;
            return 'success';
          },
        );
        
        expect(result, 'success');
        expect(attempts, 1);
      });

      test('should retry on failure and eventually succeed', () async {
        var attempts = 0;
        final result = await RetryHelper.withExponentialBackoff<String>(
          operation: () async {
            attempts++;
            if (attempts < 3) {
              throw Exception('Temporary failure');
            }
            return 'success';
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
        );
        
        expect(result, 'success');
        expect(attempts, 3);
      });

      test('should throw after max attempts exceeded', () async {
        var attempts = 0;
        
        await expectLater(
          () => RetryHelper.withExponentialBackoff<String>(
            operation: () async {
              attempts++;
              throw Exception('Always fails');
            },
            maxAttempts: 3,
            initialDelay: const Duration(milliseconds: 10),
          ),
          throwsException,
        );
        
        expect(attempts, 3);
      });

      test('should respect retryIf condition - should retry', () async {
        var attempts = 0;
        final result = await RetryHelper.withExponentialBackoff<String>(
          operation: () async {
            attempts++;
            if (attempts < 2) {
              throw Exception('socket error');
            }
            return 'success';
          },
          maxAttempts: 3,
          initialDelay: const Duration(milliseconds: 10),
          retryIf: (e) => e.toString().contains('socket'),
        );
        
        expect(result, 'success');
        expect(attempts, 2);
      });

      test('should respect retryIf condition - should not retry', () async {
        var attempts = 0;
        
        await expectLater(
          () => RetryHelper.withExponentialBackoff<String>(
            operation: () async {
              attempts++;
              throw Exception('validation error');
            },
            maxAttempts: 3,
            initialDelay: const Duration(milliseconds: 10),
            retryIf: (e) => e.toString().contains('socket'),
          ),
          throwsException,
        );
        
        expect(attempts, 1); // Should not retry for non-matching exception
      });

      test('should handle custom maxDelay', () async {
        var attempts = 0;
        
        await expectLater(
          () => RetryHelper.withExponentialBackoff<String>(
            operation: () async {
              attempts++;
              throw Exception('Always fails');
            },
            maxAttempts: 2,
            initialDelay: const Duration(milliseconds: 5),
            maxDelay: const Duration(milliseconds: 10),
          ),
          throwsException,
        );
        
        expect(attempts, 2);
      });
    });

    group('isRetryableException', () {
      test('should identify socket errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('socket error occurred')),
          isTrue,
        );
      });

      test('should identify timeout errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('connection timeout')),
          isTrue,
        );
      });

      test('should identify connection refused as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('connection refused')),
          isTrue,
        );
      });

      test('should identify 500 errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('500 internal server error')),
          isTrue,
        );
      });

      test('should identify 502 errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('502 bad gateway')),
          isTrue,
        );
      });

      test('should identify 503 errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('503 service unavailable')),
          isTrue,
        );
      });

      test('should identify network errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('network error')),
          isTrue,
        );
      });

      test('should NOT identify validation errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('validation error')),
          isFalse,
        );
      });

      test('should NOT identify auth errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('unauthorized')),
          isFalse,
        );
      });

      test('should NOT identify 404 errors as retryable', () {
        expect(
          RetryHelper.isRetryableException(Exception('404 not found')),
          isFalse,
        );
      });

      test('should be case insensitive', () {
        expect(
          RetryHelper.isRetryableException(Exception('SOCKET ERROR')),
          isTrue,
        );
        expect(
          RetryHelper.isRetryableException(Exception('TIMEOUT')),
          isTrue,
        );
      });
    });
  });
}
