import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';

/// Category Model
class CategoryModel extends Equatable {

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.icon,
    this.color,
    this.parentId,
    this.isSystem = false,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => CategoryType.expense,
      ),
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      parentId: json['parentId'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  final String id;
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final String? parentId;
  final bool isSystem;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'icon': icon,
      'color': color,
      'parentId': parentId,
      'isSystem': isSystem,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    CategoryType? type,
    String? icon,
    String? color,
    String? parentId,
    bool? isSystem,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      parentId: parentId ?? this.parentId,
      isSystem: isSystem ?? this.isSystem,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isIncome => type == CategoryType.income;
  bool get isExpense => type == CategoryType.expense;
  bool get canDelete => !isSystem;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        icon,
        color,
        parentId,
        isSystem,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}

/// Category with spending info
class CategoryWithSpending extends Equatable {

  const CategoryWithSpending({
    required this.category,
    required this.totalSpent,
    required this.transactionCount,
    required this.percentage,
  });

  factory CategoryWithSpending.fromJson(Map<String, dynamic> json) {
    return CategoryWithSpending(
      category: CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      totalSpent: json['totalSpent'] as int,
      transactionCount: json['transactionCount'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
  final CategoryModel category;
  final int totalSpent;
  final int transactionCount;
  final double percentage;

  double get totalSpentInRupees => totalSpent / 100;

  @override
  List<Object?> get props => [category, totalSpent, transactionCount, percentage];
}

/// Create Category Request
class CreateCategoryRequest {

  const CreateCategoryRequest({
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
  });
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final String? parentId;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.value,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (parentId != null) 'parentId': parentId,
    };
  }
}

/// Category Suggestion Request
class CategorySuggestionRequest {

  const CategorySuggestionRequest({
    required this.description,
    this.amount,
  });
  final String description;
  final int? amount;

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      if (amount != null) 'amount': amount,
    };
  }
}
