import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// Category Breakdown Model
/// Represents spending/income breakdown by category
class CategoryBreakdownModel extends Equatable {
  const CategoryBreakdownModel({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
    this.iconName,
    this.colorHex,
  });

  factory CategoryBreakdownModel.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownModel(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
      transactionCount: (json['transactionCount'] as num).toInt(),
      iconName: json['iconName'] as String?,
      colorHex: json['colorHex'] as String?,
    );
  }

  final String categoryId;
  final String categoryName;
  final int amount;
  final double percentage;
  final int transactionCount;
  final String? iconName;
  final String? colorHex;

  double get amountInRupees => amount / 100;

  Color get color {
    if (colorHex != null) {
      final hex = colorHex;
      if (hex != null && hex.isNotEmpty) {
        try {
          final cleanHex = hex.replaceFirst('#', '');
          return Color(int.parse('FF$cleanHex', radix: 16));
        } catch (_) {
          // Fall through to default
        }
      }
    }
    final index = categoryName.hashCode.abs() % SpendexColors.categoryColors.length;
    return SpendexColors.categoryColors[index];
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'amount': amount,
      'percentage': percentage,
      'transactionCount': transactionCount,
      if (iconName != null) 'iconName': iconName,
      if (colorHex != null) 'colorHex': colorHex,
    };
  }

  CategoryBreakdownModel copyWith({
    String? categoryId,
    String? categoryName,
    int? amount,
    double? percentage,
    int? transactionCount,
    String? iconName,
    String? colorHex,
  }) {
    return CategoryBreakdownModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      amount: amount ?? this.amount,
      percentage: percentage ?? this.percentage,
      transactionCount: transactionCount ?? this.transactionCount,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [
        categoryId,
        categoryName,
        amount,
        percentage,
        transactionCount,
        iconName,
        colorHex,
      ];
}

class CategoryBreakdownResponse extends Equatable {
  const CategoryBreakdownResponse({
    required this.type,
    required this.totalAmount,
    required this.categories,
    required this.startDate,
    required this.endDate,
  });

  factory CategoryBreakdownResponse.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdownResponse(
      type: json['type'] as String,
      totalAmount: (json['totalAmount'] as num).toInt(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryBreakdownModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  final String type;
  final int totalAmount;
  final List<CategoryBreakdownModel> categories;
  final DateTime startDate;
  final DateTime endDate;

  double get totalAmountInRupees => totalAmount / 100;
  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  List<CategoryBreakdownModel> getTopCategories(int count) {
    final sorted = List<CategoryBreakdownModel>.from(categories)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(count).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'totalAmount': totalAmount,
      'categories': categories.map((c) => c.toJson()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [type, totalAmount, categories, startDate, endDate];
}
