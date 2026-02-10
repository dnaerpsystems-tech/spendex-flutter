import 'package:equatable/equatable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../categories/data/models/category_model.dart';

/// Transaction Model
class TransactionModel extends Equatable {

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.notes,
    this.categoryId,
    this.toAccountId,
    this.tags = const [],
    this.payee,
    this.receiptUrl,
    this.isRecurring = false,
    this.account,
    this.category,
    this.toAccount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: json['amount'] as int,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      accountId: json['accountId'] as String,
      categoryId: json['categoryId'] as String?,
      toAccountId: json['toAccountId'] as String?,
      date: DateTime.parse(json['date'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      payee: json['payee'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      account: json['account'] != null
          ? AccountModel.fromJson(json['account'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      toAccount: json['toAccount'] != null
          ? AccountModel.fromJson(json['toAccount'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
  final String id;
  final TransactionType type;
  final int amount; // in paise
  final String? description;
  final String? notes;
  final String accountId;
  final String? categoryId;
  final String? toAccountId; // for transfers
  final DateTime date;
  final List<String> tags;
  final String? payee;
  final String? receiptUrl;
  final bool isRecurring;
  final AccountModel? account;
  final CategoryModel? category;
  final AccountModel? toAccount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'amount': amount,
      'description': description,
      'notes': notes,
      'accountId': accountId,
      'categoryId': categoryId,
      'toAccountId': toAccountId,
      'date': date.toIso8601String(),
      'tags': tags,
      'payee': payee,
      'receiptUrl': receiptUrl,
      'isRecurring': isRecurring,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? description,
    String? notes,
    String? accountId,
    String? categoryId,
    String? toAccountId,
    DateTime? date,
    List<String>? tags,
    String? payee,
    String? receiptUrl,
    bool? isRecurring,
    AccountModel? account,
    CategoryModel? category,
    AccountModel? toAccount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      toAccountId: toAccountId ?? this.toAccountId,
      date: date ?? this.date,
      tags: tags ?? this.tags,
      payee: payee ?? this.payee,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isRecurring: isRecurring ?? this.isRecurring,
      account: account ?? this.account,
      category: category ?? this.category,
      toAccount: toAccount ?? this.toAccount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get amount in rupees
  double get amountInRupees => amount / 100;

  /// Check if income
  bool get isIncome => type == TransactionType.income;

  /// Check if expense
  bool get isExpense => type == TransactionType.expense;

  /// Check if transfer
  bool get isTransfer => type == TransactionType.transfer;

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        description,
        notes,
        accountId,
        categoryId,
        toAccountId,
        date,
        tags,
        payee,
        receiptUrl,
        isRecurring,
        createdAt,
        updatedAt,
      ];
}

/// Transaction Stats
class TransactionStats extends Equatable {

  const TransactionStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.transactionCount,
    required this.savingsRate,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      totalIncome: json['totalIncome'] as int,
      totalExpense: json['totalExpense'] as int,
      netAmount: json['netAmount'] as int,
      transactionCount: json['transactionCount'] as int,
      savingsRate: (json['savingsRate'] as num).toDouble(),
    );
  }
  final int totalIncome;
  final int totalExpense;
  final int netAmount;
  final int transactionCount;
  final double savingsRate;

  double get totalIncomeInRupees => totalIncome / 100;
  double get totalExpenseInRupees => totalExpense / 100;
  double get netAmountInRupees => netAmount / 100;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netAmount,
        transactionCount,
        savingsRate,
      ];
}

/// Daily Transaction Total
class DailyTotal extends Equatable {

  const DailyTotal({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });

  factory DailyTotal.fromJson(Map<String, dynamic> json) {
    return DailyTotal(
      date: DateTime.parse(json['date'] as String),
      income: json['income'] as int,
      expense: json['expense'] as int,
      net: json['net'] as int,
    );
  }
  final DateTime date;
  final int income;
  final int expense;
  final int net;

  double get incomeInRupees => income / 100;
  double get expenseInRupees => expense / 100;
  double get netInRupees => net / 100;

  @override
  List<Object?> get props => [date, income, expense, net];
}

/// Create Transaction Request
class CreateTransactionRequest {

  const CreateTransactionRequest({
    required this.type,
    required this.amount,
    required this.accountId,
    this.categoryId,
    this.toAccountId,
    this.description,
    this.notes,
    this.date,
    this.tags,
    this.payee,
  });
  final TransactionType type;
  final int amount;
  final String accountId;
  final String? categoryId;
  final String? toAccountId;
  final String? description;
  final String? notes;
  final DateTime? date;
  final List<String>? tags;
  final String? payee;

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      'amount': amount,
      'accountId': accountId,
      if (categoryId != null) 'categoryId': categoryId,
      if (toAccountId != null) 'toAccountId': toAccountId,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date!.toIso8601String(),
      if (tags != null) 'tags': tags,
      if (payee != null) 'payee': payee,
    };
  }
}

/// Transaction Filter
class TransactionFilter {

  const TransactionFilter({
    this.type,
    this.accountId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.search,
  });
  final TransactionType? type;
  final String? accountId;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minAmount;
  final int? maxAmount;
  final String? search;

  Map<String, dynamic> toQueryParams() {
    return {
      if (type != null) 'type': type!.value,
      if (accountId != null) 'accountId': accountId,
      if (categoryId != null) 'categoryId': categoryId,
      if (startDate != null) 'startDate': startDate!.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (minAmount != null) 'minAmount': minAmount.toString(),
      if (maxAmount != null) 'maxAmount': maxAmount.toString(),
      if (search != null) 'search': search,
    };
  }
}
