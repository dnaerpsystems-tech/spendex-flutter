import 'package:equatable/equatable.dart';

enum TransactionType {
  income,
  expense,
}

enum TransactionSource {
  pdf,
  sms,
  aa,
}

class ParsedTransactionModel extends Equatable {
  final String id;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final String description;
  final String? merchant;
  final String? category;
  final String? account;
  final double confidence;
  final TransactionSource source;
  final Map<String, dynamic>? rawData;

  const ParsedTransactionModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.merchant,
    this.category,
    this.account,
    required this.confidence,
    required this.source,
    this.rawData,
  });

  factory ParsedTransactionModel.fromJson(Map<String, dynamic> json) {
    return ParsedTransactionModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      description: json['description'] as String,
      merchant: json['merchant'] as String?,
      category: json['category'] as String?,
      account: json['account'] as String?,
      confidence: (json['confidence'] as num).toDouble(),
      source: TransactionSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => TransactionSource.pdf,
      ),
      rawData: json['rawData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'type': type.name,
      'description': description,
      'merchant': merchant,
      'category': category,
      'account': account,
      'confidence': confidence,
      'source': source.name,
      'rawData': rawData,
    };
  }

  ParsedTransactionModel copyWith({
    String? id,
    DateTime? date,
    double? amount,
    TransactionType? type,
    String? description,
    String? merchant,
    String? category,
    String? account,
    double? confidence,
    TransactionSource? source,
    Map<String, dynamic>? rawData,
  }) {
    return ParsedTransactionModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      account: account ?? this.account,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      rawData: rawData ?? this.rawData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        date,
        amount,
        type,
        description,
        merchant,
        category,
        account,
        confidence,
        source,
        rawData,
      ];
}
