import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/utils/connectivity_checker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ConnectivityChecker', () {
    setUp(() {
      // Mock the method channel for connectivity_plus
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'check') {
            return ['wifi'];
          }
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/connectivity'),
        null,
      );
    });

    test('hasConnection should return a boolean', () async {
      final result = await ConnectivityChecker.hasConnection();
      expect(result, isA<bool>());
    });

    test('onConnectivityChanged should return a stream', () {
      final stream = ConnectivityChecker.onConnectivityChanged;
      expect(stream, isA<Stream<bool>>());
    });
  });
}
