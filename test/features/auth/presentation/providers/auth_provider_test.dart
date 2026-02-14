import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendex/core/errors/failures.dart';
import 'package:spendex/core/storage/secure_storage.dart';
import 'package:spendex/features/auth/domain/repositories/auth_repository.dart';
import 'package:spendex/features/auth/data/models/user_model.dart';
import 'package:spendex/features/auth/data/models/auth_response_model.dart';
import 'package:spendex/features/auth/presentation/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorage;
  late AuthNotifier authNotifier;

  final testUser = UserModel(
    id: 'user_123',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime.now(),
  );

  final testAuthResponse = AuthResponseModel(
    accessToken: 'test_access_token',
    refreshToken: 'test_refresh_token',
    user: testUser,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockSecureStorage = MockSecureStorageService();
    authNotifier = AuthNotifier(mockAuthRepository, mockSecureStorage);
  });

  group('AuthNotifier', () {
    // =========================================================================
    // Initial State Tests
    // =========================================================================
    group('Initial State', () {
      test('initial state is not authenticated and not loading', () {
        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.isLoading, isFalse);
        expect(authNotifier.state.user, isNull);
        expect(authNotifier.state.error, isNull);
      });
    });

    // =========================================================================
    // checkAuthStatus() Tests
    // =========================================================================
    group('checkAuthStatus()', () {
      test('sets loading state during check', () async {
        when(() => mockSecureStorage.isAuthenticated())
            .thenAnswer((_) async => false);

        final future = authNotifier.checkAuthStatus();
        
        // State should be loading at some point
        await future;
        
        expect(authNotifier.state.isLoading, isFalse);
      });

      test('sets unauthenticated state when no stored token', () async {
        when(() => mockSecureStorage.isAuthenticated())
            .thenAnswer((_) async => false);

        await authNotifier.checkAuthStatus();

        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.user, isNull);
      });

      test('sets authenticated state when user exists', () async {
        when(() => mockSecureStorage.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => Right(testUser));
        when(() => mockAuthRepository.isBiometricEnabled())
            .thenAnswer((_) async => false);

        await authNotifier.checkAuthStatus();

        expect(authNotifier.state.isAuthenticated, isTrue);
        expect(authNotifier.state.user, isNotNull);
        expect(authNotifier.state.user!.email, equals('test@example.com'));
      });

      test('sets unauthenticated when getCurrentUser fails', () async {
        when(() => mockSecureStorage.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => const Left(AuthFailure('Session expired')));
        when(() => mockAuthRepository.isBiometricEnabled())
            .thenAnswer((_) async => false);

        await authNotifier.checkAuthStatus();

        expect(authNotifier.state.isAuthenticated, isFalse);
      });
    });

    // =========================================================================
    // login() Tests
    // =========================================================================
    group('login()', () {
      test('returns true and sets authenticated state on success', () async {
        when(() => mockAuthRepository.login('test@example.com', 'password123'))
            .thenAnswer((_) async => Right(testAuthResponse));

        final result = await authNotifier.login('test@example.com', 'password123');

        expect(result, isTrue);
        expect(authNotifier.state.isAuthenticated, isTrue);
        expect(authNotifier.state.user, isNotNull);
        expect(authNotifier.state.isLoading, isFalse);
      });

      test('returns false and sets error state on failure', () async {
        when(() => mockAuthRepository.login('test@example.com', 'wrongpassword'))
            .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

        final result = await authNotifier.login('test@example.com', 'wrongpassword');

        expect(result, isFalse);
        expect(authNotifier.state.isAuthenticated, isFalse);
        expect(authNotifier.state.error, isNotNull);
        expect(authNotifier.state.error, contains('Invalid credentials'));
      });

      test('sets loading state during login', () async {
        when(() => mockAuthRepository.login(any(), any()))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return Right(testAuthResponse);
        });

        final future = authNotifier.login('test@example.com', 'password');
        
        // Check loading state
        await Future.delayed(const Duration(milliseconds: 10));
        expect(authNotifier.state.isLoading, isTrue);
        
        await future;
        expect(authNotifier.state.isLoading, isFalse);
      });
    });

    // =========================================================================
    // register() Tests
    // =========================================================================
    group('register()', () {
      test('returns true on successful registration', () async {
        when(() => mockAuthRepository.register(
          'test@example.com',
          'password123',
          'Test User',
          null,
        )).thenAnswer((_) async => const Right(null));

        final result = await authNotifier.register(
          'test@example.com',
          'password123',
          'Test User',
          null,
        );

        expect(result, isTrue);
        expect(authNotifier.state.isLoading, isFalse);
      });

      test('returns false and sets error on failure', () async {
        when(() => mockAuthRepository.register(
          'existing@example.com',
          'password123',
          'Test User',
          null,
        )).thenAnswer((_) async => const Left(ValidationFailure('Email already exists')));

        final result = await authNotifier.register(
          'existing@example.com',
          'password123',
          'Test User',
          null,
        );

        expect(result, isFalse);
        expect(authNotifier.state.error, contains('Email already exists'));
      });
    });

    // =========================================================================
    // verifyOtp() Tests
    // =========================================================================
    group('verifyOtp()', () {
      test('returns true and sets authenticated state on success', () async {
        when(() => mockAuthRepository.verifyOtp('test@example.com', '123456'))
            .thenAnswer((_) async => Right(testAuthResponse));

        final result = await authNotifier.verifyOtp('test@example.com', '123456');

        expect(result, isTrue);
        expect(authNotifier.state.isAuthenticated, isTrue);
      });

      test('returns false and sets error on invalid OTP', () async {
        when(() => mockAuthRepository.verifyOtp('test@example.com', '000000'))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid OTP')));

        final result = await authNotifier.verifyOtp('test@example.com', '000000');

        expect(result, isFalse);
        expect(authNotifier.state.error, contains('Invalid OTP'));
      });
    });

    // =========================================================================
    // forgotPassword() Tests
    // =========================================================================
    group('forgotPassword()', () {
      test('returns true on success', () async {
        when(() => mockAuthRepository.forgotPassword('test@example.com'))
            .thenAnswer((_) async => const Right(null));

        final result = await authNotifier.forgotPassword('test@example.com');

        expect(result, isTrue);
      });

      test('returns false and sets error on failure', () async {
        when(() => mockAuthRepository.forgotPassword('nonexistent@example.com'))
            .thenAnswer((_) async => const Left(ValidationFailure('Email not found')));

        final result = await authNotifier.forgotPassword('nonexistent@example.com');

        expect(result, isFalse);
        expect(authNotifier.state.error, contains('Email not found'));
      });
    });

    // =========================================================================
    // resetPassword() Tests
    // =========================================================================
    group('resetPassword()', () {
      test('returns true on success', () async {
        when(() => mockAuthRepository.resetPassword('valid_token', 'newpassword123'))
            .thenAnswer((_) async => const Right(null));

        final result = await authNotifier.resetPassword('valid_token', 'newpassword123');

        expect(result, isTrue);
      });

      test('returns false and sets error on invalid token', () async {
        when(() => mockAuthRepository.resetPassword('invalid_token', 'newpassword123'))
            .thenAnswer((_) async => const Left(ValidationFailure('Invalid or expired token')));

        final result = await authNotifier.resetPassword('invalid_token', 'newpassword123');

        expect(result, isFalse);
        expect(authNotifier.state.error, contains('Invalid or expired token'));
      });
    });
  });

  // ===========================================================================
  // AuthState Tests
  // ===========================================================================
  group('AuthState', () {
    test('initial state has correct values', () {
      const state = AuthState.initial();

      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.error, isNull);
      expect(state.isBiometricAvailable, isFalse);
      expect(state.isBiometricEnabled, isFalse);
    });

    test('loading state has correct values', () {
      const state = AuthState.loading();

      expect(state.isLoading, isTrue);
      expect(state.isAuthenticated, isFalse);
    });

    test('authenticated state has user', () {
      final state = AuthState.authenticated(testUser);

      expect(state.isAuthenticated, isTrue);
      expect(state.user, isNotNull);
      expect(state.isLoading, isFalse);
    });

    test('unauthenticated state has correct values', () {
      const state = AuthState.unauthenticated();

      expect(state.isAuthenticated, isFalse);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
    });

    test('error state has error message', () {
      const state = AuthState.error('Something went wrong');

      expect(state.error, equals('Something went wrong'));
      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
    });

    test('copyWith creates new state with updated values', () {
      const state = AuthState.initial();
      
      final newState = state.copyWith(
        isLoading: true,
        isBiometricAvailable: true,
      );

      expect(newState.isLoading, isTrue);
      expect(newState.isBiometricAvailable, isTrue);
      expect(newState.isAuthenticated, isFalse);
    });

    test('props includes all fields for equality', () {
      const state1 = AuthState.initial();
      const state2 = AuthState.initial();

      expect(state1, equals(state2));
    });

    test('different states are not equal', () {
      const state1 = AuthState.initial();
      const state2 = AuthState.loading();

      expect(state1, isNot(equals(state2)));
    });
  });
}
