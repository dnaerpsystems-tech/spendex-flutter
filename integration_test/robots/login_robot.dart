import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot pattern for login screen testing
class LoginRobot {
  
  LoginRobot(this.tester);
  final WidgetTester tester;
  
  Future<void> enterEmail(String email) async {
    final emailField = find.byKey(const Key('login_email_field'));
    await tester.enterText(emailField, email);
    await tester.pumpAndSettle();
  }
  
  Future<void> enterPassword(String password) async {
    final passwordField = find.byKey(const Key('login_password_field'));
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();
  }
  
  Future<void> tapLoginButton() async {
    final loginButton = find.byKey(const Key('login_button'));
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }
  
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await enterEmail(email);
    await enterPassword(password);
    await tapLoginButton();
  }
  
  void expectLoginScreen() {
    expect(find.text('Login'), findsWidgets);
  }
  
  void expectLoginError() {
    expect(find.textContaining('Invalid'), findsOneWidget);
  }
}
