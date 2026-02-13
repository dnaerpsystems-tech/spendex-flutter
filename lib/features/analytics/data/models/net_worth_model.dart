import 'package:equatable/equatable.dart';

class NetWorthPointModel extends Equatable {
  const NetWorthPointModel({
    required this.date,
    required this.assets,
    required this.liabilities,
    required this.netWorth,
  });

  factory NetWorthPointModel.fromJson(Map<String, dynamic> json) {
    return NetWorthPointModel(
      date: DateTime.parse(json['date'] as String),
      assets: (json['assets'] as num).toInt(),
      liabilities: (json['liabilities'] as num).toInt(),
      netWorth: (json['netWorth'] as num).toInt(),
    );
  }

  final DateTime date;
  final int assets;
  final int liabilities;
  final int netWorth;

  double get assetsInRupees => assets / 100;
  double get liabilitiesInRupees => liabilities / 100;
  double get netWorthInRupees => netWorth / 100;

  @override
  List<Object?> get props => [date, assets, liabilities, netWorth];
}

class NetWorthResponse extends Equatable {
  const NetWorthResponse({
    required this.history,
    required this.currentAssets,
    required this.currentLiabilities,
    required this.currentNetWorth,
    this.netWorthGrowth,
    this.netWorthGrowthPercentage,
  });

  factory NetWorthResponse.fromJson(Map<String, dynamic> json) {
    return NetWorthResponse(
      history: (json['history'] as List<dynamic>)
          .map((e) => NetWorthPointModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentAssets: (json['currentAssets'] as num).toInt(),
      currentLiabilities: (json['currentLiabilities'] as num).toInt(),
      currentNetWorth: (json['currentNetWorth'] as num).toInt(),
      netWorthGrowth: (json['netWorthGrowth'] as num?)?.toInt(),
      netWorthGrowthPercentage: (json['netWorthGrowthPercentage'] as num?)?.toDouble(),
    );
  }

  final List<NetWorthPointModel> history;
  final int currentAssets;
  final int currentLiabilities;
  final int currentNetWorth;
  final int? netWorthGrowth;
  final double? netWorthGrowthPercentage;

  double get currentAssetsInRupees => currentAssets / 100;
  double get currentLiabilitiesInRupees => currentLiabilities / 100;
  double get currentNetWorthInRupees => currentNetWorth / 100;
  bool get isPositiveGrowth => netWorthGrowthPercentage != null && netWorthGrowthPercentage! > 0;

  @override
  List<Object?> get props => [history, currentAssets, currentLiabilities, currentNetWorth, netWorthGrowth, netWorthGrowthPercentage];
}
