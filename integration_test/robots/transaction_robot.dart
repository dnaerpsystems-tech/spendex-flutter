import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot pattern for transaction testing
class TransactionRobot {
  
  TransactionRobot(this.tester);
  final WidgetTester tester;
  
  Future<void> navigateToTransactions() async {
    final transactionsTab = find.byIcon(Icons.receipt_long);
    await tester.tap(transactionsTab);
    await tester.pumpAndSettle();
  }
  
  Future<void> tapAddTransaction() async {
    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();
  }
  
  Future<void> enterAmount(String amount) async {
    final amountField = find.byKey(const Key('transaction_amount_field'));
    await tester.enterText(amountField, amount);
    await tester.pumpAndSettle();
  }
  
  Future<void> selectCategory(String categoryName) async {
    final categorySelector = find.byKey(const Key('category_selector'));
    await tester.tap(categorySelector);
    await tester.pumpAndSettle();
    
    final category = find.text(categoryName);
    await tester.tap(category);
    await tester.pumpAndSettle();
  }
  
  Future<void> saveTransaction() async {
    final saveButton = find.text('Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
  
  void expectTransactionInList(String amount) {
    expect(find.textContaining(amount), findsWidgets);
  }
}
