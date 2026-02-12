import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Investment Model
class InvestmentModel extends Equatable {

  const InvestmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.investedAmount,
    required this.currentValue,
    required this.returns,
    required this.returnsPercent,
    required this.createdAt,
    required this.updatedAt,
    this.symbol,
    this.isin,
    this.folioNumber,
    this.units,
    this.purchasePrice,
    this.currentPrice,
    this.interestRate,
    this.purchaseDate,
    this.maturityDate,
    this.maturityAmount,
    this.taxSaving = false,
    this.taxSection,
    this.broker,
    this.isActive = true,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: InvestmentType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => InvestmentType.other,
      ),
      symbol: json['symbol'] as String?,
      isin: json['isin'] as String?,
      folioNumber: json['folioNumber'] as String?,
      units: (json['units'] as num?)?.toDouble(),
      purchasePrice: json['purchasePrice'] as int?,
      currentPrice: json['currentPrice'] as int?,
      investedAmount: json['investedAmount'] as int,
      currentValue: json['currentValue'] as int,
      returns: json['returns'] as int,
      returnsPercent: (json['returnsPercent'] as num).toDouble(),
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      maturityDate: json['maturityDate'] != null
          ? DateTime.parse(json['maturityDate'] as String)
          : null,
      maturityAmount: json['maturityAmount'] as int?,
      taxSaving: json['taxSaving'] as bool? ?? false,
      taxSection: json['taxSection'] != null
          ? TaxSection.values.firstWhere(
              (e) => e.value == json['taxSection'],
              orElse: () => TaxSection.none,
            )
          : null,
      broker: json['broker'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  final String id;
  final String name;
  final InvestmentType type;
  final String? symbol;
  final String? isin;
  final String? folioNumber;
  final double? units;
  final int? purchasePrice;
  final int? currentPrice;
  final int investedAmount;
  final int currentValue;
  final int returns;
  final double returnsPercent;
  final double? interestRate;
  final DateTime? purchaseDate;
  final DateTime? maturityDate;
  final int? maturityAmount;
  final bool taxSaving;
  final TaxSection? taxSection;
  final String? broker;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'symbol': symbol,
      'isin': isin,
      'folioNumber': folioNumber,
      'units': units,
      'purchasePrice': purchasePrice,
      'currentPrice': currentPrice,
      'investedAmount': investedAmount,
      'currentValue': currentValue,
      'returns': returns,
      'returnsPercent': returnsPercent,
      'interestRate': interestRate,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'maturityDate': maturityDate?.toIso8601String(),
      'maturityAmount': maturityAmount,
      'taxSaving': taxSaving,
      'taxSection': taxSection?.value,
      'broker': broker,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get investedAmountInRupees => investedAmount / 100;
  double get currentValueInRupees => currentValue / 100;
  double get returnsInRupees => returns / 100;
  double? get purchasePriceInRupees =>
      purchasePrice != null ? purchasePrice! / 100 : null;
  double? get currentPriceInRupees =>
      currentPrice != null ? currentPrice! / 100 : null;
  double? get maturityAmountInRupees =>
      maturityAmount != null ? maturityAmount! / 100 : null;

  bool get isProfit => returns > 0;
  bool get isLoss => returns < 0;

  bool get isMarketLinked =>
      type == InvestmentType.mutualFund ||
      type == InvestmentType.stock ||
      type == InvestmentType.crypto;

  int? get daysToMaturity {
    if (maturityDate == null) {
      return null;
    }
    return maturityDate!.difference(DateTime.now()).inDays;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        symbol,
        isin,
        folioNumber,
        units,
        purchasePrice,
        currentPrice,
        investedAmount,
        currentValue,
        returns,
        returnsPercent,
        interestRate,
        purchaseDate,
        maturityDate,
        maturityAmount,
        taxSaving,
        taxSection,
        broker,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Investment Summary
class InvestmentSummary extends Equatable {

  const InvestmentSummary({
    required this.totalInvested,
    required this.currentValue,
    required this.totalReturns,
    required this.overallReturnsPercent,
    required this.investmentCount,
    this.allocationByType = const {},
  });

  factory InvestmentSummary.fromJson(Map<String, dynamic> json) {
    return InvestmentSummary(
      totalInvested: json['totalInvested'] as int,
      currentValue: json['currentValue'] as int,
      totalReturns: json['totalReturns'] as int,
      overallReturnsPercent: (json['overallReturnsPercent'] as num).toDouble(),
      investmentCount: json['investmentCount'] as int,
      allocationByType: (json['allocationByType'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
    );
  }
  final int totalInvested;
  final int currentValue;
  final int totalReturns;
  final double overallReturnsPercent;
  final int investmentCount;
  final Map<String, int> allocationByType;

  double get totalInvestedInRupees => totalInvested / 100;
  double get currentValueInRupees => currentValue / 100;
  double get totalReturnsInRupees => totalReturns / 100;

  @override
  List<Object?> get props => [
        totalInvested,
        currentValue,
        totalReturns,
        overallReturnsPercent,
        investmentCount,
        allocationByType,
      ];
}

/// Tax Savings Summary
class TaxSavingsSummary extends Equatable {

  const TaxSavingsSummary({
    required this.year,
    required this.savingsBySection,
    required this.totalTaxSavings,
  });

  factory TaxSavingsSummary.fromJson(Map<String, dynamic> json) {
    return TaxSavingsSummary(
      year: json['year'] as int,
      savingsBySection: (json['savingsBySection'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int)),
      totalTaxSavings: json['totalTaxSavings'] as int,
    );
  }
  final int year;
  final Map<String, int> savingsBySection;
  final int totalTaxSavings;

  double get totalTaxSavingsInRupees => totalTaxSavings / 100;

  @override
  List<Object?> get props => [year, savingsBySection, totalTaxSavings];
}

/// Create Investment Request
class CreateInvestmentRequest {

  const CreateInvestmentRequest({
    required this.name,
    required this.type,
    required this.investedAmount,
    this.symbol,
    this.isin,
    this.folioNumber,
    this.units,
    this.purchasePrice,
    this.interestRate,
    this.purchaseDate,
    this.maturityDate,
    this.maturityAmount,
    this.taxSaving,
    this.taxSection,
    this.broker,
  });
  final String name;
  final InvestmentType type;
  final int investedAmount;
  final String? symbol;
  final String? isin;
  final String? folioNumber;
  final double? units;
  final int? purchasePrice;
  final double? interestRate;
  final DateTime? purchaseDate;
  final DateTime? maturityDate;
  final int? maturityAmount;
  final bool? taxSaving;
  final TaxSection? taxSection;
  final String? broker;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      'investedAmount': investedAmount,
      if (symbol != null) 'symbol': symbol,
      if (isin != null) 'isin': isin,
      if (folioNumber != null) 'folioNumber': folioNumber,
      if (units != null) 'units': units,
      if (purchasePrice != null) 'purchasePrice': purchasePrice,
      if (interestRate != null) 'interestRate': interestRate,
      if (purchaseDate != null) 'purchaseDate': purchaseDate!.toIso8601String(),
      if (maturityDate != null) 'maturityDate': maturityDate!.toIso8601String(),
      if (maturityAmount != null) 'maturityAmount': maturityAmount,
      if (taxSaving != null) 'taxSaving': taxSaving,
      if (taxSection != null) 'taxSection': taxSection!.value,
      if (broker != null) 'broker': broker,
    };
  }
}
