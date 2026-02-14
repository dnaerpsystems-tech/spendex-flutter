import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendex/core/security/pin_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late PinServiceImpl pinService;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    pinService = PinServiceImpl(mockStorage);
  });

  group('PinServiceImpl', () {
    // =========================================================================
    // isPinSet() Tests
    // =========================================================================
    group('isPinSet()', () {
      test('returns false when no PIN is stored', () async {
        when(() => mockStorage.read(key: 'spendex_pin_hash'))
            .thenAnswer((_) async => null);

        final result = await pinService.isPinSet();

        expect(result, isFalse);
        verify(() => mockStorage.read(key: 'spendex_pin_hash')).called(1);
      });

      test('returns false when empty PIN is stored', () async {
        when(() => mockStorage.read(key: 'spendex_pin_hash'))
            .thenAnswer((_) async => '');

        final result = await pinService.isPinSet();

        expect(result, isFalse);
      });

      test('returns true when PIN hash exists', () async {
        when(() => mockStorage.read(key: 'spendex_pin_hash'))
            .thenAnswer((_) async => 'some_hash_value');

        final result = await pinService.isPinSet();

        expect(result, isTrue);
      });
    });

    // =========================================================================
    // setPin() Tests
    // =========================================================================
    group('setPin()', () {
      test('stores hashed PIN successfully', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await pinService.setPin('1234');

        verify(() => mockStorage.write(
          key: 'spendex_pin_hash',
          value: any(named: 'value'),
        )).called(1);
        verify(() => mockStorage.write(
          key: 'spendex_pin_salt',
          value: any(named: 'value'),
        )).called(1);
      });

      test('throws ArgumentError for PIN shorter than 4 digits', () async {
        expect(
          () => pinService.setPin('12'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for PIN longer than 6 digits', () async {
        expect(
          () => pinService.setPin('12345678'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('throws ArgumentError for non-numeric PIN', () async {
        expect(
          () => pinService.setPin('abcd'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('accepts 4-digit PIN', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await expectLater(pinService.setPin('1234'), completes);
      });

      test('accepts 6-digit PIN', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await expectLater(pinService.setPin('123456'), completes);
      });

      test('resets failed attempts when setting new PIN', () async {
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await pinService.setPin('1234');

        verify(() => mockStorage.delete(key: 'spendex_pin_failed_attempts')).called(1);
        verify(() => mockStorage.delete(key: 'spendex_pin_lock_until')).called(1);
      });
    });

    // =========================================================================
    // verifyPin() Tests
    // =========================================================================
    group('verifyPin()', () {
      const testHash = 'test_hash_value';
      const testSalt = 'test_salt_value';

      test('returns false when locked out', () async {
        final futureTime = DateTime.now().add(const Duration(minutes: 15));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => futureTime.toIso8601String());

        final result = await pinService.verifyPin('1234');

        expect(result, isFalse);
      });

      test('returns false when no PIN is stored', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'spendex_pin_hash'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'spendex_pin_salt'))
            .thenAnswer((_) async => null);

        final result = await pinService.verifyPin('1234');

        expect(result, isFalse);
      });

      test('returns false when salt is missing', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(key: 'spendex_pin_hash'))
            .thenAnswer((_) async => testHash);
        when(() => mockStorage.read(key: 'spendex_pin_salt'))
            .thenAnswer((_) async => null);

        final result = await pinService.verifyPin('1234');

        expect(result, isFalse);
      });
    });

    // =========================================================================
    // incrementFailedAttempts() Tests
    // =========================================================================
    group('incrementFailedAttempts()', () {
      test('increments counter from zero', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => null);
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        await pinService.incrementFailedAttempts();

        verify(() => mockStorage.write(
          key: 'spendex_pin_failed_attempts',
          value: '1',
        )).called(1);
      });

      test('increments existing counter', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => '3');
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        await pinService.incrementFailedAttempts();

        verify(() => mockStorage.write(
          key: 'spendex_pin_failed_attempts',
          value: '4',
        )).called(1);
      });

      test('triggers lockout after 5 failed attempts', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => '4');
        when(() => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async {});

        await pinService.incrementFailedAttempts();

        verify(() => mockStorage.write(
          key: 'spendex_pin_lock_until',
          value: any(named: 'value'),
        )).called(1);
      });
    });

    // =========================================================================
    // getFailedAttempts() Tests
    // =========================================================================
    group('getFailedAttempts()', () {
      test('returns zero when no attempts stored', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => null);

        final result = await pinService.getFailedAttempts();

        expect(result, equals(0));
      });

      test('returns stored count', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => '3');

        final result = await pinService.getFailedAttempts();

        expect(result, equals(3));
      });

      test('returns zero for invalid stored value', () async {
        when(() => mockStorage.read(key: 'spendex_pin_failed_attempts'))
            .thenAnswer((_) async => 'invalid');

        final result = await pinService.getFailedAttempts();

        expect(result, equals(0));
      });
    });

    // =========================================================================
    // resetFailedAttempts() Tests
    // =========================================================================
    group('resetFailedAttempts()', () {
      test('clears both failed attempts and lock time', () async {
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await pinService.resetFailedAttempts();

        verify(() => mockStorage.delete(key: 'spendex_pin_failed_attempts')).called(1);
        verify(() => mockStorage.delete(key: 'spendex_pin_lock_until')).called(1);
      });
    });

    // =========================================================================
    // isLocked() Tests
    // =========================================================================
    group('isLocked()', () {
      test('returns false when no lock time stored', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => null);

        final result = await pinService.isLocked();

        expect(result, isFalse);
      });

      test('returns false when lock has expired', () async {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => pastTime.toIso8601String());
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        final result = await pinService.isLocked();

        expect(result, isFalse);
      });

      test('returns true when still locked', () async {
        final futureTime = DateTime.now().add(const Duration(minutes: 15));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => futureTime.toIso8601String());

        final result = await pinService.isLocked();

        expect(result, isTrue);
      });

      test('resets lock when expired', () async {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => pastTime.toIso8601String());
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await pinService.isLocked();

        verify(() => mockStorage.delete(key: 'spendex_pin_failed_attempts')).called(1);
        verify(() => mockStorage.delete(key: 'spendex_pin_lock_until')).called(1);
      });
    });

    // =========================================================================
    // getLockDuration() Tests
    // =========================================================================
    group('getLockDuration()', () {
      test('returns null when not locked', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => null);

        final result = await pinService.getLockDuration();

        expect(result, isNull);
      });

      test('returns null for invalid lock time', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => 'invalid_date');

        final result = await pinService.getLockDuration();

        expect(result, isNull);
      });

      test('returns null when lock has expired', () async {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => pastTime.toIso8601String());

        final result = await pinService.getLockDuration();

        expect(result, isNull);
      });

      test('returns remaining duration when locked', () async {
        final futureTime = DateTime.now().add(const Duration(minutes: 10));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => futureTime.toIso8601String());

        final result = await pinService.getLockDuration();

        expect(result, isNotNull);
        expect(result, isA<Duration>());
        expect(result!.inMinutes, greaterThanOrEqualTo(9));
      });
    });

    // =========================================================================
    // getLockoutEndTime() Tests
    // =========================================================================
    group('getLockoutEndTime()', () {
      test('returns null when not locked', () async {
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => null);

        final result = await pinService.getLockoutEndTime();

        expect(result, isNull);
      });

      test('returns lock end time when locked', () async {
        final futureTime = DateTime.now().add(const Duration(minutes: 15));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => futureTime.toIso8601String());

        final result = await pinService.getLockoutEndTime();

        expect(result, isNotNull);
        expect(result!.isAfter(DateTime.now()), isTrue);
      });

      test('returns null when lock has expired', () async {
        final pastTime = DateTime.now().subtract(const Duration(minutes: 1));
        when(() => mockStorage.read(key: 'spendex_pin_lock_until'))
            .thenAnswer((_) async => pastTime.toIso8601String());

        final result = await pinService.getLockoutEndTime();

        expect(result, isNull);
      });
    });

    // =========================================================================
    // clearPin() Tests
    // =========================================================================
    group('clearPin()', () {
      test('deletes all PIN-related data', () async {
        when(() => mockStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async {});

        await pinService.clearPin();

        verify(() => mockStorage.delete(key: 'spendex_pin_hash')).called(1);
        verify(() => mockStorage.delete(key: 'spendex_pin_salt')).called(1);
      });
    });

    // =========================================================================
    // Constants Tests
    // =========================================================================
    group('Constants', () {
      test('maxAttempts is 5', () {
        expect(PinServiceImpl.maxAttempts, equals(5));
      });

      test('lockDuration is 30 minutes', () {
        expect(PinServiceImpl.lockDuration, equals(const Duration(minutes: 30)));
      });
    });
  });
}
