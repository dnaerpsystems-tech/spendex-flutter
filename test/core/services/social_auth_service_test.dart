import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/services/social_auth_service.dart';

void main() {
  group('SocialAuthService', () {
    late SocialAuthService service;

    setUp(() {
      service = SocialAuthService();
    });

    group('SocialAuthCredentials', () {
      test('toJson should serialize correctly', () {
        const credentials = SocialAuthCredentials(
          provider: 'google',
          idToken: 'test_id_token',
          accessToken: 'test_access_token',
          email: 'test@example.com',
          name: 'Test User',
        );

        final json = credentials.toJson();

        expect(json['provider'], 'google');
        expect(json['idToken'], 'test_id_token');
        expect(json['accessToken'], 'test_access_token');
        expect(json['email'], 'test@example.com');
        expect(json['name'], 'Test User');
      });

      test('toJson should exclude null values', () {
        const credentials = SocialAuthCredentials(
          provider: 'apple',
          idToken: 'test_id_token',
        );

        final json = credentials.toJson();

        expect(json['provider'], 'apple');
        expect(json['idToken'], 'test_id_token');
        expect(json.containsKey('accessToken'), isFalse);
        expect(json.containsKey('email'), isFalse);
        expect(json.containsKey('name'), isFalse);
      });

      test('toString should return correct format', () {
        const credentials = SocialAuthCredentials(
          provider: 'facebook',
          idToken: 'token',
          email: 'test@example.com',
          name: 'Test',
        );

        final string = credentials.toString();

        expect(string, contains('provider: facebook'));
        expect(string, contains('email: test@example.com'));
        expect(string, contains('name: Test'));
      });

      test('should include nonce when provided', () {
        const credentials = SocialAuthCredentials(
          provider: 'apple',
          idToken: 'token',
          nonce: 'test_nonce',
        );

        final json = credentials.toJson();

        expect(json['nonce'], 'test_nonce');
      });

      test('should include authorizationCode when provided', () {
        const credentials = SocialAuthCredentials(
          provider: 'apple',
          idToken: 'token',
          authorizationCode: 'auth_code',
        );

        final json = credentials.toJson();

        expect(json['authorizationCode'], 'auth_code');
      });
    });

    group('Service lifecycle', () {
      test('should create new instance', () {
        expect(service, isNotNull);
        expect(service, isA<SocialAuthService>());
      });

      test('should dispose without errors', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
