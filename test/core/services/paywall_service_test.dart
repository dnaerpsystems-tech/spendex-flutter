import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:dartz/dartz.dart";
import "package:spendex/core/constants/app_constants.dart";
import "package:spendex/core/errors/failures.dart";
import "package:spendex/core/services/paywall_service.dart";
import "package:spendex/features/subscription/data/models/subscription_models.dart";
import "package:spendex/features/subscription/domain/repositories/subscription_repository.dart";

class MockSubscriptionRepository extends Mock implements SubscriptionRepository {}

void main() {
  late PaywallService paywallService;
  late MockSubscriptionRepository mockRepository;

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    paywallService = PaywallService(mockRepository);
  });

  group("PaywallService", () {
    group("getCurrentPlan", () {
      test("returns free plan when no subscription exists", () async {
        // Arrange
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.getCurrentPlan();

        // Assert
        expect(result, equals(SubscriptionPlan.free));
      });

      test("returns pro plan when user has pro subscription", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.getCurrentPlan();

        // Assert
        expect(result, equals(SubscriptionPlan.pro));
      });

      test("returns premium plan when user has premium subscription", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.getCurrentPlan();

        // Assert
        expect(result, equals(SubscriptionPlan.premium));
      });
    });

    group("checkFeature - count-based limits", () {
      test("allows adding account when under free plan limit", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.free,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final usage = UsageModel(
          accountsCount: 1, // Under limit of 2
          budgetsCount: 0,
          goalsCount: 0,
          transactionsThisMonth: 0,
          storageUsedMb: 0,
          apiCallsThisMonth: 0,
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Right(usage));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.unlimitedAccounts);

        // Assert
        expect(result.isAllowed, isTrue);
        expect(result.currentCount, equals(1));
        expect(result.limit, equals(2));
        expect(result.remaining, equals(1));
      });

      test("blocks adding account when at free plan limit", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.free,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final usage = UsageModel(
          accountsCount: 2, // At limit
          budgetsCount: 0,
          goalsCount: 0,
          transactionsThisMonth: 0,
          storageUsedMb: 0,
          apiCallsThisMonth: 0,
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Right(usage));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.unlimitedAccounts);

        // Assert
        expect(result.isAllowed, isFalse);
        expect(result.isAtLimit, isTrue);
        expect(result.currentCount, equals(2));
        expect(result.limit, equals(2));
        expect(result.requiredPlan, equals(SubscriptionPlan.pro));
        expect(result.message, contains("limit"));
      });

      test("allows adding budget when pro plan has higher limit", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final usage = UsageModel(
          accountsCount: 0,
          budgetsCount: 5, // Under pro limit of 10
          goalsCount: 0,
          transactionsThisMonth: 0,
          storageUsedMb: 0,
          apiCallsThisMonth: 0,
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Right(usage));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.unlimitedBudgets);

        // Assert
        expect(result.isAllowed, isTrue);
        expect(result.currentCount, equals(5));
        expect(result.limit, equals(10));
      });

      test("allows unlimited goals for premium plan", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final usage = UsageModel(
          accountsCount: 0,
          budgetsCount: 0,
          goalsCount: 100, // Any count should be allowed
          transactionsThisMonth: 0,
          storageUsedMb: 0,
          apiCallsThisMonth: 0,
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Right(usage));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.unlimitedGoals);

        // Assert
        expect(result.isAllowed, isTrue);
        expect(result.limit, isNull); // Unlimited
      });
    });

    group("checkFeature - boolean features", () {
      test("blocks AI insights for free plan", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.free,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.aiInsights);

        // Assert
        expect(result.isAllowed, isFalse);
        expect(result.requiredPlan, equals(SubscriptionPlan.pro));
      });

      test("allows AI insights for pro plan", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.aiInsights);

        // Assert
        expect(result.isAllowed, isTrue);
      });

      test("blocks family sharing for pro plan", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.familySharing);

        // Assert
        expect(result.isAllowed, isFalse);
        expect(result.requiredPlan, equals(SubscriptionPlan.premium));
      });

      test("allows family sharing for premium plan", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.premium,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final result = await paywallService.checkFeature(GatedFeature.familySharing);

        // Assert
        expect(result.isAllowed, isTrue);
      });
    });

    group("trial detection", () {
      test("detects user on trial", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.trialing,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          trialEnd: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final isOnTrial = await paywallService.isOnTrial();
        final trialDays = await paywallService.getTrialDaysRemaining();

        // Assert
        expect(isOnTrial, isTrue);
        expect(trialDays, equals(7));
      });

      test("returns false for non-trial subscription", () async {
        // Arrange
        final subscription = SubscriptionModel(
          id: "sub_123",
          userId: "user_123",
          plan: SubscriptionPlan.pro,
          status: SubscriptionStatus.active,
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        when(() => mockRepository.getCurrentSubscription())
            .thenAnswer((_) async => Right(subscription));
        when(() => mockRepository.getUsage())
            .thenAnswer((_) async => Left(const ServerFailure(message: "Not found")));

        // Act
        final isOnTrial = await paywallService.isOnTrial();

        // Assert
        expect(isOnTrial, isFalse);
      });
    });

    group("plan limits", () {
      test("free plan has correct limits", () {
        final limits = PaywallService.planLimits[SubscriptionPlan.free]!;
        expect(limits["accounts"], equals(2));
        expect(limits["budgets"], equals(3));
        expect(limits["goals"], equals(2));
        expect(limits["transactions_per_month"], equals(100));
      });

      test("pro plan has correct limits", () {
        final limits = PaywallService.planLimits[SubscriptionPlan.pro]!;
        expect(limits["accounts"], equals(10));
        expect(limits["budgets"], equals(10));
        expect(limits["goals"], equals(5));
        expect(limits["transactions_per_month"], equals(1000));
      });

      test("premium plan has unlimited (-1) limits", () {
        final limits = PaywallService.planLimits[SubscriptionPlan.premium]!;
        expect(limits["accounts"], equals(-1));
        expect(limits["budgets"], equals(-1));
        expect(limits["goals"], equals(-1));
        expect(limits["transactions_per_month"], equals(-1));
      });
    });

    group("plan features", () {
      test("free plan has no premium features", () {
        final features = PaywallService.planFeatures[SubscriptionPlan.free]!;
        expect(features, isEmpty);
      });

      test("pro plan has expected features", () {
        final features = PaywallService.planFeatures[SubscriptionPlan.pro]!;
        expect(features.contains(GatedFeature.aiInsights), isTrue);
        expect(features.contains(GatedFeature.advancedAnalytics), isTrue);
        expect(features.contains(GatedFeature.receiptScanning), isTrue);
        expect(features.contains(GatedFeature.voiceInput), isTrue);
        expect(features.contains(GatedFeature.familySharing), isFalse); // Premium only
      });

      test("premium plan has all features", () {
        final features = PaywallService.planFeatures[SubscriptionPlan.premium]!;
        expect(features.contains(GatedFeature.aiInsights), isTrue);
        expect(features.contains(GatedFeature.familySharing), isTrue);
        expect(features.contains(GatedFeature.prioritySupport), isTrue);
        expect(features.contains(GatedFeature.taxReports), isTrue);
      });
    });

    group("FeatureGateResult", () {
      test("calculates isAtLimit correctly", () {
        final result = FeatureGateResult(
          isAllowed: false,
          currentCount: 2,
          limit: 2,
        );
        expect(result.isAtLimit, isTrue);
      });

      test("calculates remaining correctly", () {
        final result = FeatureGateResult(
          isAllowed: true,
          currentCount: 1,
          limit: 5,
        );
        expect(result.remaining, equals(4));
      });

      test("remaining is null for unlimited", () {
        const result = FeatureGateResult(
          isAllowed: true,
          currentCount: 100,
          limit: null,
        );
        expect(result.remaining, isNull);
      });
    });
  });
}
