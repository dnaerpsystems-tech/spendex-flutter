import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

/// Plan Limits Model
///
/// Defines the usage limits for each subscription plan.
/// Use -1 to indicate unlimited access to a feature.
class PlanLimits extends Equatable {
  const PlanLimits({
    required this.transactions,
    required this.accounts,
    required this.budgets,
    required this.goals,
    required this.familyMembers,
    required this.aiInsights,
  });

  /// Creates a [PlanLimits] instance from JSON.
  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      transactions: json['transactions'] as int? ?? 0,
      accounts: json['accounts'] as int? ?? 0,
      budgets: json['budgets'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      familyMembers: json['familyMembers'] as int? ?? 0,
      aiInsights: json['aiInsights'] as int? ?? 0,
    );
  }

  /// Maximum number of transactions per month (-1 for unlimited)
  final int transactions;

  /// Maximum number of accounts allowed
  final int accounts;

  /// Maximum number of budgets allowed
  final int budgets;

  /// Maximum number of goals allowed
  final int goals;

  /// Maximum number of family members allowed
  final int familyMembers;

  /// Monthly AI insights limit (-1 for unlimited)
  final int aiInsights;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'transactions': transactions,
      'accounts': accounts,
      'budgets': budgets,
      'goals': goals,
      'familyMembers': familyMembers,
      'aiInsights': aiInsights,
    };
  }

  /// Creates a copy with modified fields.
  PlanLimits copyWith({
    int? transactions,
    int? accounts,
    int? budgets,
    int? goals,
    int? familyMembers,
    int? aiInsights,
  }) {
    return PlanLimits(
      transactions: transactions ?? this.transactions,
      accounts: accounts ?? this.accounts,
      budgets: budgets ?? this.budgets,
      goals: goals ?? this.goals,
      familyMembers: familyMembers ?? this.familyMembers,
      aiInsights: aiInsights ?? this.aiInsights,
    );
  }

  /// Check if transactions are unlimited
  bool get hasUnlimitedTransactions => transactions == -1;

  /// Check if accounts are unlimited
  bool get hasUnlimitedAccounts => accounts == -1;

  /// Check if budgets are unlimited
  bool get hasUnlimitedBudgets => budgets == -1;

  /// Check if goals are unlimited
  bool get hasUnlimitedGoals => goals == -1;

  /// Check if family members are unlimited
  bool get hasUnlimitedFamilyMembers => familyMembers == -1;

  /// Check if AI insights are unlimited
  bool get hasUnlimitedAiInsights => aiInsights == -1;

  @override
  List<Object?> get props => [
        transactions,
        accounts,
        budgets,
        goals,
        familyMembers,
        aiInsights,
      ];
}

/// Plan Model
///
/// Represents a subscription plan with its features, pricing, and limits.
class PlanModel extends Equatable {
  const PlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.billingCycle,
    required this.features,
    required this.limits,
    this.currency = 'INR',
    this.isPopular = false,
    this.isEnterprise = false,
    this.trialDays = 0,
    this.discountPercentage = 0,
    this.originalPrice,
  });

  /// Creates a [PlanModel] instance from JSON.
  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: json['price'] as int,
      currency: json['currency'] as String? ?? 'INR',
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.value == json['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : const PlanLimits(
              transactions: 50,
              accounts: 2,
              budgets: 3,
              goals: 2,
              familyMembers: 0,
              aiInsights: 5,
            ),
      isPopular: json['isPopular'] as bool? ?? false,
      isEnterprise: json['isEnterprise'] as bool? ?? false,
      trialDays: json['trialDays'] as int? ?? 0,
      discountPercentage: json['discountPercentage'] as int? ?? 0,
      originalPrice: json['originalPrice'] as int?,
    );
  }

  /// Unique identifier for the plan
  final String id;

  /// Plan name (e.g., "Free", "Pro", "Enterprise")
  final String name;

  /// Description of the plan
  final String description;

  /// Price in paise (1/100 of rupee)
  final int price;

  /// Currency code (default: INR)
  final String currency;

  /// Billing cycle (monthly, quarterly, half-yearly, yearly)
  final BillingCycle billingCycle;

  /// List of features included in the plan
  final List<String> features;

  /// Usage limits for the plan
  final PlanLimits limits;

  /// Whether this plan is marked as popular/recommended
  final bool isPopular;

  /// Whether this is an enterprise plan
  final bool isEnterprise;

  /// Number of trial days offered
  final int trialDays;

  /// Discount percentage (for showing savings)
  final int discountPercentage;

  /// Original price before discount (in paise)
  final int? originalPrice;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'billingCycle': billingCycle.value,
      'features': features,
      'limits': limits.toJson(),
      'isPopular': isPopular,
      'isEnterprise': isEnterprise,
      'trialDays': trialDays,
      'discountPercentage': discountPercentage,
      if (originalPrice != null) 'originalPrice': originalPrice,
    };
  }

  /// Creates a copy with modified fields.
  PlanModel copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? currency,
    BillingCycle? billingCycle,
    List<String>? features,
    PlanLimits? limits,
    bool? isPopular,
    bool? isEnterprise,
    int? trialDays,
    int? discountPercentage,
    int? originalPrice,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      features: features ?? this.features,
      limits: limits ?? this.limits,
      isPopular: isPopular ?? this.isPopular,
      isEnterprise: isEnterprise ?? this.isEnterprise,
      trialDays: trialDays ?? this.trialDays,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      originalPrice: originalPrice ?? this.originalPrice,
    );
  }

  /// Get price in rupees
  double get priceInRupees => price / 100;

  /// Get original price in rupees
  double? get originalPriceInRupees =>
      originalPrice != null ? originalPrice! / 100 : null;

  /// Get savings amount in paise
  int get savingsAmount => originalPrice != null ? originalPrice! - price : 0;

  /// Get savings amount in rupees
  double get savingsInRupees => savingsAmount / 100;

  /// Check if plan has a discount
  bool get hasDiscount => discountPercentage > 0 && originalPrice != null;

  /// Check if plan has a trial
  bool get hasTrial => trialDays > 0;

  /// Check if this is a free plan
  bool get isFree => price == 0;

  /// Get monthly equivalent price for comparison
  double get monthlyEquivalentPrice {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return priceInRupees;
      case BillingCycle.quarterly:
        return priceInRupees / 3;
      case BillingCycle.halfYearly:
        return priceInRupees / 6;
      case BillingCycle.yearly:
        return priceInRupees / 12;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        currency,
        billingCycle,
        features,
        limits,
        isPopular,
        isEnterprise,
        trialDays,
        discountPercentage,
        originalPrice,
      ];
}

/// Plans Response Model
///
/// Represents the API response containing a list of plans.
class PlansResponse extends Equatable {
  const PlansResponse({
    required this.plans,
    this.currentPlanId,
  });

  /// Creates a [PlansResponse] instance from JSON.
  factory PlansResponse.fromJson(Map<String, dynamic> json) {
    return PlansResponse(
      plans: (json['plans'] as List<dynamic>?)
              ?.map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentPlanId: json['currentPlanId'] as String?,
    );
  }

  /// List of available plans
  final List<PlanModel> plans;

  /// ID of the user's current plan (if subscribed)
  final String? currentPlanId;

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'plans': plans.map((e) => e.toJson()).toList(),
      if (currentPlanId != null) 'currentPlanId': currentPlanId,
    };
  }

  @override
  List<Object?> get props => [plans, currentPlanId];
}
