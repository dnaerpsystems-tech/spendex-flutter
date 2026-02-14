import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spendex/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end tests', () {
    testWidgets('App launches successfully', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // App should show either login screen or dashboard
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
      );
    });
  });
}
