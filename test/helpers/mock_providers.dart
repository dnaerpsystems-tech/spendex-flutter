import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:spendex/core/network/api_client.dart';
import 'package:spendex/core/storage/secure_storage.dart';
import 'package:spendex/features/auth/domain/repositories/auth_repository.dart';
import 'package:spendex/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:spendex/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:spendex/features/subscription/domain/repositories/subscription_repository.dart';

// ===========================================================================
// Mock Repository Classes
// ===========================================================================

/// Mock AuthRepository for testing auth providers
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock AccountsRepository for testing accounts providers
class MockAccountsRepository extends Mock implements AccountsRepository {}

/// Mock TransactionRepository for testing transaction providers
class MockTransactionRepository extends Mock implements TransactionRepository {}

/// Mock SubscriptionRepository for testing subscription providers
class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

/// Mock SecureStorageService for testing
class MockSecureStorage extends Mock implements SecureStorageService {}

/// Mock ApiClient for testing
class MockApiClientForProvider extends Mock implements ApiClient {}

// ===========================================================================
// Provider Overrides Builder
// ===========================================================================

/// Builder for creating provider overrides for testing
class ProviderOverridesBuilder {
  final List<Override> _overrides = [];

  /// Add a custom override
  ProviderOverridesBuilder addOverride(Override override) {
    _overrides.add(override);
    return this;
  }

  /// Build the list of overrides
  List<Override> build() => _overrides;
}

// ===========================================================================
// Test Provider Container
// ===========================================================================

/// Creates a ProviderContainer with common overrides for testing
ProviderContainer createTestProviderContainer({
  List<Override>? overrides,
}) {
  return ProviderContainer(
    overrides: overrides ?? [],
  );
}

/// Creates a ProviderScope for widget testing
ProviderScope createTestProviderScope({
  required Widget child,
  List<Override>? overrides,
}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: child,
  );
}

// ===========================================================================
// State Matchers
// ===========================================================================

/// Matcher for checking provider state
class StateMatcher<T> {
  final bool Function(T) predicate;
  final String description;

  StateMatcher(this.predicate, this.description);

  bool matches(T state) => predicate(state);

  @override
  String toString() => description;
}

/// Create a state matcher that checks if loading
StateMatcher<T> isLoadingState<T>(bool Function(T) isLoading) {
  return StateMatcher(isLoading, 'is in loading state');
}

/// Create a state matcher that checks for error
StateMatcher<T> hasErrorState<T>(bool Function(T) hasError) {
  return StateMatcher(hasError, 'has error state');
}

// ===========================================================================
// Async State Helpers
// ===========================================================================

/// Wait for async state changes
Future<void> pumpAndSettle() async {
  await Future.delayed(const Duration(milliseconds: 100));
}

/// Wait for multiple async operations
Future<void> pumpMultiple(int count) async {
  for (var i = 0; i < count; i++) {
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

// Placeholder for Flutter imports in widget tests
class Widget {}
