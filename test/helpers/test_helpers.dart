import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:spendex/core/network/api_client.dart';
import 'package:spendex/core/storage/secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:spendex/core/errors/failures.dart';

// ===========================================================================
// Mock Classes
// ===========================================================================

/// Mock FlutterSecureStorage for testing PIN service and secure storage
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

/// Mock SharedPreferences for testing auto-lock and other preferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

/// Mock Dio for testing API client
class MockDio extends Mock implements Dio {}

/// Mock ApiClient for testing repositories
class MockApiClient extends Mock implements ApiClient {}

/// Mock SecureStorageService for testing auth providers
class MockSecureStorageService extends Mock implements SecureStorageService {}

/// Mock Response for Dio
class MockResponse<T> extends Mock implements Response<T> {}

// ===========================================================================
// Test Data Fixtures
// ===========================================================================

/// Test user data
class TestFixtures {
  TestFixtures._();

  // Currency test amounts
  static const int zeroAmount = 0;
  static const int smallAmount = 500;
  static const int mediumAmount = 15000;
  static const int lakhAmount = 150000;
  static const int croreAmount = 25000000;
  static const int negativeAmount = -42500;

  // Paise amounts
  static const int smallPaise = 15000; // ₹150.00
  static const int lakhPaise = 15000000; // ₹1,50,000.00

  // PIN test data
  static const String validPin = '1234';
  static const String invalidPin = '0000';
  static const String shortPin = '12';
  static const String longPin = '12345678';
  static const String nonNumericPin = 'abcd';

  // Date test data
  static DateTime get today => DateTime.now();
  static DateTime get yesterday => DateTime.now().subtract(const Duration(days: 1));
  static DateTime get tomorrow => DateTime.now().add(const Duration(days: 1));
  static DateTime get lastWeek => DateTime.now().subtract(const Duration(days: 7));
  static DateTime get lastMonth => DateTime.now().subtract(const Duration(days: 30));
  static DateTime get lastYear => DateTime.now().subtract(const Duration(days: 365));

  // Financial year dates
  static DateTime get aprilFirst2024 => DateTime(2024, 4, 1);
  static DateTime get marchEnd2024 => DateTime(2024, 3, 31);
  static DateTime get may2024 => DateTime(2024, 5, 15);
  static DateTime get feb2024 => DateTime(2024, 2, 15);

  // API response data
  static Map<String, dynamic> get successResponse => {
        'success': true,
        'data': {'id': '123', 'name': 'Test'},
        'meta': {'page': 1, 'limit': 20, 'total': 100, 'totalPages': 5},
      };

  static Map<String, dynamic> get errorResponse => {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Invalid input provided',
        },
      };

  // User data
  static Map<String, dynamic> get testUserData => {
        'id': 'user_123',
        'email': 'test@example.com',
        'name': 'Test User',
        'phone': '+919876543210',
        'createdAt': DateTime.now().toIso8601String(),
      };

  // Transaction data
  static Map<String, dynamic> get testTransactionData => {
        'id': 'txn_123',
        'amount': 15000,
        'type': 'expense',
        'categoryId': 'cat_123',
        'accountId': 'acc_123',
        'description': 'Test transaction',
        'date': DateTime.now().toIso8601String(),
      };

  // Account data
  static Map<String, dynamic> get testAccountData => {
        'id': 'acc_123',
        'name': 'Test Account',
        'type': 'bank',
        'balance': 100000,
        'currency': 'INR',
      };

  // Payment method test data
  static const String upiDescription = 'Payment via UPI to merchant@paytm';
  static const String neftDescription = 'NEFT Transfer to Account';
  static const String rtgsDescription = 'RTGS payment for property';
  static const String impsDescription = 'IMPS instant transfer';
  static const String cardDescription = 'POS debit card purchase';
  static const String cashDescription = 'ATM withdrawal';
  static const int rtgsAmount = 20000000; // ₹2L in paise
  static const int upiAmount = 500000; // ₹5K in paise
}

// ===========================================================================
// Helper Functions
// ===========================================================================

/// Setup mock secure storage with predefined values
void setupMockSecureStorage(MockFlutterSecureStorage mock, Map<String, String?> data) {
  for (final entry in data.entries) {
    when(() => mock.read(key: entry.key)).thenAnswer((_) async => entry.value);
  }
  when(() => mock.write(key: any(named: 'key'), value: any(named: 'value')))
      .thenAnswer((_) async {});
  when(() => mock.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  when(() => mock.deleteAll()).thenAnswer((_) async {});
}

/// Setup mock SharedPreferences with predefined values
void setupMockSharedPreferences(MockSharedPreferences mock, {
  Map<String, int>? intValues,
  Map<String, bool>? boolValues,
  Map<String, String>? stringValues,
}) {
  // Default returns
  when(() => mock.getInt(any())).thenReturn(null);
  when(() => mock.getBool(any())).thenReturn(null);
  when(() => mock.getString(any())).thenReturn(null);

  // Set specific values
  intValues?.forEach((key, value) {
    when(() => mock.getInt(key)).thenReturn(value);
  });
  boolValues?.forEach((key, value) {
    when(() => mock.getBool(key)).thenReturn(value);
  });
  stringValues?.forEach((key, value) {
    when(() => mock.getString(key)).thenReturn(value);
  });

  // Write operations
  when(() => mock.setInt(any(), any())).thenAnswer((_) async => true);
  when(() => mock.setBool(any(), any())).thenAnswer((_) async => true);
  when(() => mock.setString(any(), any())).thenAnswer((_) async => true);
  when(() => mock.remove(any())).thenAnswer((_) async => true);
}

/// Setup mock API client for success responses
void setupMockApiClientSuccess<T>(MockApiClient mock, String path, T data) {
  when(() => mock.get<T>(
        path,
        queryParameters: any(named: 'queryParameters'),
        fromJson: any(named: 'fromJson'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Right(data));
}

/// Setup mock API client for failure responses
void setupMockApiClientFailure(MockApiClient mock, String path, Failure failure) {
  when(() => mock.get<dynamic>(
        path,
        queryParameters: any(named: 'queryParameters'),
        fromJson: any(named: 'fromJson'),
        options: any(named: 'options'),
      )).thenAnswer((_) async => Left(failure));
}

// ===========================================================================
// Fallback Values for Mocktail
// ===========================================================================

/// Register all fallback values for Mocktail
void registerFallbackValues() {
  registerFallbackValue(const Duration(seconds: 1));
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(Options());
}
