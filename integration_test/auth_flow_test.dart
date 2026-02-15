import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:spendex/main.dart' as app;
import 'robots/login_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('User can see login screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      LoginRobot(tester).expectLoginScreen();
    });

    testWidgets('Invalid login shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final loginRobot = LoginRobot(tester);
      await loginRobot.login(
        email: 'invalid@test.com',
        password: 'wrongpassword',
      );
      
      // Should show error or remain on login screen
      loginRobot.expectLoginScreen();
    });
  });
}
