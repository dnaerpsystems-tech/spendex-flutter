import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:spendex/core/errors/failures.dart';
import 'package:spendex/core/network/api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(mockDio);
  });

  group('ApiClient', () {
    // =========================================================================
    // GET Request Tests
    // =========================================================================
    group('get()', () {
      test('returns Right with data on successful response', () async {
        final responseData = {
          'success': true,
          'data': {'id': '123', 'name': 'Test'},
        };
        
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<Map<String, dynamic>>(
          '/test',
          fromJson: (data) => data! as Map<String, dynamic>,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r['id'], equals('123')),
        );
      });

      test('returns Left with NetworkFailure on connection timeout', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<NetworkFailure>()),
          (r) => fail('Should not return success'),
        );
      });

      test('returns Left with NetworkFailure on send timeout', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.sendTimeout,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) {
            expect(l, isA<NetworkFailure>());
            expect(l.message, contains('timeout'));
          },
          (r) => fail('Should not return success'),
        );
      });

      test('returns Left with NetworkFailure on connection error', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) {
            expect(l, isA<NetworkFailure>());
            expect(l.message, contains('internet'));
          },
          (r) => fail('Should not return success'),
        );
      });

      test('returns Left with UnexpectedFailure on unknown error', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(Exception('Unknown error'));

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<UnexpectedFailure>()),
          (r) => fail('Should not return success'),
        );
      });

      test('passes query parameters correctly', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: {'success': true, 'data': {}},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        await apiClient.get<dynamic>(
          '/test',
          queryParameters: {'page': 1, 'limit': 20},
        );

        verify(() => mockDio.get<Object?>(
          '/test',
          queryParameters: {'page': 1, 'limit': 20},
          options: any(named: 'options'),
        ),).called(1);
      });
    });

    // =========================================================================
    // POST Request Tests
    // =========================================================================
    group('post()', () {
      test('returns Right with data on successful response', () async {
        final responseData = {
          'success': true,
          'data': {'id': 'new_123'},
        };
        
        when(() => mockDio.post<Object?>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.post<Map<String, dynamic>>(
          '/test',
          data: {'name': 'Test'},
          fromJson: (data) => data! as Map<String, dynamic>,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r['id'], equals('new_123')),
        );
      });

      test('sends data in request body', () async {
        when(() => mockDio.post<Object?>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: {'success': true, 'data': {}},
          statusCode: 201,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final requestData = {'email': 'test@example.com', 'password': 'secret'};
        await apiClient.post<dynamic>('/test', data: requestData);

        verify(() => mockDio.post<Object?>(
          '/test',
          data: requestData,
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).called(1);
      });
    });

    // =========================================================================
    // PUT Request Tests
    // =========================================================================
    group('put()', () {
      test('returns Right with data on successful response', () async {
        final responseData = {
          'success': true,
          'data': {'id': '123', 'updated': true},
        };
        
        when(() => mockDio.put<Object?>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/123'),
        ),);

        final result = await apiClient.put<Map<String, dynamic>>(
          '/test/123',
          data: {'name': 'Updated'},
          fromJson: (data) => data! as Map<String, dynamic>,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r['updated'], isTrue),
        );
      });
    });

    // =========================================================================
    // DELETE Request Tests
    // =========================================================================
    group('delete()', () {
      test('returns Right on successful delete', () async {
        when(() => mockDio.delete<Object?>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: {'success': true},
          statusCode: 204,
          requestOptions: RequestOptions(path: '/test/123'),
        ),);

        final result = await apiClient.delete<dynamic>('/test/123');

        expect(result.isRight(), isTrue);
      });
    });

    // =========================================================================
    // PATCH Request Tests
    // =========================================================================
    group('patch()', () {
      test('returns Right with data on successful response', () async {
        final responseData = {
          'success': true,
          'data': {'id': '123', 'patched': true},
        };
        
        when(() => mockDio.patch<Object?>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/test/123'),
        ),);

        final result = await apiClient.patch<Map<String, dynamic>>(
          '/test/123',
          data: {'status': 'active'},
          fromJson: (data) => data! as Map<String, dynamic>,
        );

        expect(result.isRight(), isTrue);
        result.fold(
          (l) => fail('Should not return failure'),
          (r) => expect(r['patched'], isTrue),
        );
      });
    });

    // =========================================================================
    // Bad Response Handling Tests
    // =========================================================================
    group('Bad Response Handling', () {
      test('returns AuthFailure for 401 status code', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            data: {'error': {'message': 'Unauthorized'}},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Should not return success'),
        );
      });

      test('returns ValidationFailure for 400 status code', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 400,
            data: {'error': {'message': 'Invalid input', 'code': 'VALIDATION_ERROR'}},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) {
            expect(l, isA<ValidationFailure>());
            expect(l.message, equals('Invalid input'));
          },
          (r) => fail('Should not return success'),
        );
      });

      test('returns ServerFailure for 500 status code', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'error': {'message': 'Internal Server Error'}},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<ServerFailure>()),
          (r) => fail('Should not return success'),
        );
      });

      test('returns ServerFailure for 429 rate limit', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            data: {},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) {
            expect(l, isA<ServerFailure>());
            expect(l.message, contains('Too many'));
          },
          (r) => fail('Should not return success'),
        );
      });

      test('returns AuthFailure for 403 status code', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 403,
            data: {'error': {'message': 'Forbidden'}},
            requestOptions: RequestOptions(path: '/test'),
          ),
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Should not return success'),
        );
      });
    });

    // =========================================================================
    // Cancel Request Tests
    // =========================================================================
    group('Cancel Request', () {
      test('returns NetworkFailure on request cancel', () async {
        when(() => mockDio.get<Object?>(
          any(),
          queryParameters: any(named: 'queryParameters'),
          options: any(named: 'options'),
        ),).thenThrow(DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        ),);

        final result = await apiClient.get<dynamic>('/test');

        expect(result.isLeft(), isTrue);
        result.fold(
          (l) {
            expect(l, isA<NetworkFailure>());
            expect(l.message, contains('cancelled'));
          },
          (r) => fail('Should not return success'),
        );
      });
    });
  });

  // ===========================================================================
  // ApiResponse Tests
  // ===========================================================================
  group('ApiResponse', () {
    test('fromJson parses success response correctly', () {
      final json = {
        'success': true,
        'data': {'id': '123'},
        'meta': {'page': 1, 'limit': 20, 'total': 100, 'totalPages': 5},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data! as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!['id'], equals('123'));
      expect(response.meta, isNotNull);
      expect(response.meta!.page, equals(1));
    });

    test('fromJson parses error response correctly', () {
      final json = {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Invalid input',
        },
      };

      final response = ApiResponse.fromJson(json, null);

      expect(response.success, isFalse);
      expect(response.error, isNotNull);
      expect(response.error!.code, equals('VALIDATION_ERROR'));
      expect(response.error!.message, equals('Invalid input'));
    });
  });

  // ===========================================================================
  // Meta Tests
  // ===========================================================================
  group('Meta', () {
    test('fromJson parses correctly', () {
      final json = {
        'page': 2,
        'limit': 20,
        'total': 100,
        'totalPages': 5,
      };

      final meta = Meta.fromJson(json);

      expect(meta.page, equals(2));
      expect(meta.limit, equals(20));
      expect(meta.total, equals(100));
      expect(meta.totalPages, equals(5));
    });

    test('hasMore returns true when more pages exist', () {
      final meta = Meta(page: 2, limit: 20, total: 100, totalPages: 5);

      expect(meta.hasMore, isTrue);
    });

    test('hasMore returns false on last page', () {
      final meta = Meta(page: 5, limit: 20, total: 100, totalPages: 5);

      expect(meta.hasMore, isFalse);
    });
  });

  // ===========================================================================
  // ApiError Tests
  // ===========================================================================
  group('ApiError', () {
    test('fromJson parses correctly', () {
      final json = {
        'code': 'NOT_FOUND',
        'message': 'Resource not found',
        'details': ['Item with ID 123 not found'],
      };

      final error = ApiError.fromJson(json);

      expect(error.code, equals('NOT_FOUND'));
      expect(error.message, equals('Resource not found'));
      expect(error.details, isNotNull);
    });

    test('fromJson handles missing fields', () {
      final json = <String, dynamic>{};

      final error = ApiError.fromJson(json);

      expect(error.code, equals('UNKNOWN_ERROR'));
      expect(error.message, equals('An unknown error occurred'));
    });
  });
}
