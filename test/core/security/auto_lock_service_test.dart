import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendex/core/security/auto_lock_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late AutoLockServiceImpl autoLockService;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    // Setup default returns
    when(() => mockPrefs.getInt(any())).thenReturn(null);
    when(() => mockPrefs.getBool(any())).thenReturn(null);
    when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setBool(any(), any())).thenAnswer((_) async => true);
    
    autoLockService = AutoLockServiceImpl(mockPrefs);
  });

  group('AutoLockServiceImpl', () {
    // =========================================================================
    // recordActivity() Tests
    // =========================================================================
    group('recordActivity()', () {
      test('records activity timestamp', () {
        autoLockService.recordActivity();
        
        // After recording, shouldLock should return false (just recorded)
        expect(autoLockService.shouldLock(), isFalse);
      });

      test('updates activity timestamp on subsequent calls', () {
        autoLockService.recordActivity();
        final firstCheck = autoLockService.timeUntilLock;
        
        // Wait a bit and record again
        autoLockService.recordActivity();
        final secondCheck = autoLockService.timeUntilLock;
        
        // Both should be close to the timeout
        expect(firstCheck, isNotNull);
        expect(secondCheck, isNotNull);
      });
    });

    // =========================================================================
    // shouldLock() Tests
    // =========================================================================
    group('shouldLock()', () {
      test('returns false when no activity recorded', () {
        expect(autoLockService.shouldLock(), isFalse);
      });

      test('returns false immediately after recording activity', () {
        autoLockService.recordActivity();
        expect(autoLockService.shouldLock(), isFalse);
      });

      test('returns false when disabled', () async {
        autoLockService.recordActivity();
        await autoLockService.setEnabled(false);
        
        expect(autoLockService.shouldLock(), isFalse);
      });

      test('returns false when within timeout', () {
        autoLockService.recordActivity();
        // Immediately check - should be within timeout
        expect(autoLockService.shouldLock(), isFalse);
      });
    });

    // =========================================================================
    // setTimeout() Tests
    // =========================================================================
    group('setTimeout()', () {
      test('updates timeout duration', () async {
        const newTimeout = Duration(minutes: 10);
        
        await autoLockService.setTimeout(newTimeout);
        
        expect(autoLockService.timeout, equals(newTimeout));
        verify(() => mockPrefs.setInt(
          'spendex_auto_lock_timeout_seconds',
          600,
        )).called(1);
      });

      test('persists timeout to SharedPreferences', () async {
        const newTimeout = Duration(seconds: 30);
        
        await autoLockService.setTimeout(newTimeout);
        
        verify(() => mockPrefs.setInt(
          'spendex_auto_lock_timeout_seconds',
          30,
        )).called(1);
      });

      test('accepts various timeout durations', () async {
        await autoLockService.setTimeout(const Duration(minutes: 1));
        expect(autoLockService.timeout, equals(const Duration(minutes: 1)));
        
        await autoLockService.setTimeout(const Duration(minutes: 30));
        expect(autoLockService.timeout, equals(const Duration(minutes: 30)));
      });
    });

    // =========================================================================
    // timeout Getter Tests
    // =========================================================================
    group('timeout getter', () {
      test('returns default timeout of 5 minutes', () {
        expect(autoLockService.timeout, equals(const Duration(minutes: 5)));
      });

      test('returns stored timeout from preferences', () {
        when(() => mockPrefs.getInt('spendex_auto_lock_timeout_seconds'))
            .thenReturn(120);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.timeout, equals(const Duration(seconds: 120)));
      });
    });

    // =========================================================================
    // reset() Tests
    // =========================================================================
    group('reset()', () {
      test('clears activity timestamp', () {
        autoLockService.recordActivity();
        expect(autoLockService.timeUntilLock, isNotNull);
        
        autoLockService.reset();
        
        expect(autoLockService.timeUntilLock, isNull);
      });

      test('causes shouldLock to return false after reset', () {
        autoLockService.recordActivity();
        autoLockService.reset();
        
        expect(autoLockService.shouldLock(), isFalse);
      });
    });

    // =========================================================================
    // timeUntilLock Getter Tests
    // =========================================================================
    group('timeUntilLock getter', () {
      test('returns null when no activity recorded', () {
        expect(autoLockService.timeUntilLock, isNull);
      });

      test('returns positive duration after activity', () {
        autoLockService.recordActivity();
        
        final remaining = autoLockService.timeUntilLock;
        
        expect(remaining, isNotNull);
        expect(remaining!.inSeconds, greaterThan(0));
      });

      test('returns Duration.zero when expired', () async {
        // Set a very short timeout
        await autoLockService.setTimeout(const Duration(milliseconds: 1));
        autoLockService.recordActivity();
        
        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 10));
        
        final remaining = autoLockService.timeUntilLock;
        
        expect(remaining, equals(Duration.zero));
      });
    });

    // =========================================================================
    // isEnabled Getter Tests
    // =========================================================================
    group('isEnabled getter', () {
      test('returns true by default', () {
        expect(autoLockService.isEnabled, isTrue);
      });

      test('returns stored enabled state from preferences', () {
        when(() => mockPrefs.getBool('spendex_auto_lock_enabled'))
            .thenReturn(false);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.isEnabled, isFalse);
      });
    });

    // =========================================================================
    // setEnabled() Tests
    // =========================================================================
    group('setEnabled()', () {
      test('enables auto-lock and records activity', () async {
        await autoLockService.setEnabled(true);
        
        expect(autoLockService.isEnabled, isTrue);
        verify(() => mockPrefs.setBool(
          'spendex_auto_lock_enabled',
          true,
        )).called(1);
      });

      test('disables auto-lock and resets activity', () async {
        autoLockService.recordActivity();
        
        await autoLockService.setEnabled(false);
        
        expect(autoLockService.isEnabled, isFalse);
        expect(autoLockService.timeUntilLock, isNull);
        verify(() => mockPrefs.setBool(
          'spendex_auto_lock_enabled',
          false,
        )).called(1);
      });

      test('persists enabled state to SharedPreferences', () async {
        await autoLockService.setEnabled(true);
        
        verify(() => mockPrefs.setBool(
          'spendex_auto_lock_enabled',
          true,
        )).called(1);
      });
    });

    // =========================================================================
    // Load Settings Tests
    // =========================================================================
    group('Load Settings', () {
      test('loads timeout from SharedPreferences on init', () {
        when(() => mockPrefs.getInt('spendex_auto_lock_timeout_seconds'))
            .thenReturn(300);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.timeout, equals(const Duration(seconds: 300)));
      });

      test('loads enabled state from SharedPreferences on init', () {
        when(() => mockPrefs.getBool('spendex_auto_lock_enabled'))
            .thenReturn(false);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.isEnabled, isFalse);
      });

      test('uses default timeout when not stored', () {
        when(() => mockPrefs.getInt('spendex_auto_lock_timeout_seconds'))
            .thenReturn(null);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.timeout, equals(const Duration(minutes: 5)));
      });

      test('uses default enabled state when not stored', () {
        when(() => mockPrefs.getBool('spendex_auto_lock_enabled'))
            .thenReturn(null);
        
        final service = AutoLockServiceImpl(mockPrefs);
        
        expect(service.isEnabled, isTrue);
      });
    });
  });

  // ===========================================================================
  // AutoLockTimeout Enum Tests
  // ===========================================================================
  group('AutoLockTimeout', () {
    test('thirtySeconds has correct duration', () {
      expect(AutoLockTimeout.thirtySeconds.duration, equals(const Duration(seconds: 30)));
    });

    test('oneMinute has correct duration', () {
      expect(AutoLockTimeout.oneMinute.duration, equals(const Duration(minutes: 1)));
    });

    test('twoMinutes has correct duration', () {
      expect(AutoLockTimeout.twoMinutes.duration, equals(const Duration(minutes: 2)));
    });

    test('fiveMinutes has correct duration', () {
      expect(AutoLockTimeout.fiveMinutes.duration, equals(const Duration(minutes: 5)));
    });

    test('tenMinutes has correct duration', () {
      expect(AutoLockTimeout.tenMinutes.duration, equals(const Duration(minutes: 10)));
    });

    test('thirtyMinutes has correct duration', () {
      expect(AutoLockTimeout.thirtyMinutes.duration, equals(const Duration(minutes: 30)));
    });

    test('never has very long duration', () {
      expect(AutoLockTimeout.never.duration, equals(const Duration(days: 365)));
    });

    test('fromDuration returns correct timeout for known duration', () {
      expect(
        AutoLockTimeout.fromDuration(const Duration(minutes: 5)),
        equals(AutoLockTimeout.fiveMinutes),
      );
    });

    test('fromDuration returns fiveMinutes for unknown duration', () {
      expect(
        AutoLockTimeout.fromDuration(const Duration(minutes: 7)),
        equals(AutoLockTimeout.fiveMinutes),
      );
    });

    test('all timeouts have labels', () {
      for (final timeout in AutoLockTimeout.values) {
        expect(timeout.label, isNotEmpty);
      }
    });

    test('thirtySeconds label is correct', () {
      expect(AutoLockTimeout.thirtySeconds.label, equals('30 seconds'));
    });

    test('oneMinute label is correct', () {
      expect(AutoLockTimeout.oneMinute.label, equals('1 minute'));
    });

    test('fiveMinutes label is correct', () {
      expect(AutoLockTimeout.fiveMinutes.label, equals('5 minutes'));
    });

    test('never label is correct', () {
      expect(AutoLockTimeout.never.label, equals('Never'));
    });
  });
}
