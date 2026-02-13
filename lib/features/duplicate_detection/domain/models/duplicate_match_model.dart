import 'package:equatable/equatable.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/transactions/data/models/transaction_model.dart';

/// Enum representing possible resolution actions for duplicate transactions
enum DuplicateResolutionAction {
  /// Skip importing this transaction (treat as duplicate)
  skip,

  /// Merge with existing transaction (update existing with new data)
  merge,

  /// Keep both transactions (import as new despite similarity)
  keepBoth,
}

/// Enum representing reasons why two transactions might match
enum MatchReason {
  /// Amounts are exactly the same
  exactAmount,

  /// Amounts are similar (within tolerance)
  similarAmount,

  /// Dates are the same day
  sameDate,

  /// Dates are within tolerance (±1-2 days)
  similarDate,

  /// Descriptions are similar
  similarDescription,

  /// Merchant/payee names match
  sameMerchant,

  /// Transaction types match
  sameType,
}

/// Extension on MatchReason to provide display labels
extension MatchReasonExtension on MatchReason {
  String get label {
    switch (this) {
      case MatchReason.exactAmount:
        return 'Exact amount';
      case MatchReason.similarAmount:
        return 'Similar amount';
      case MatchReason.sameDate:
        return 'Same date';
      case MatchReason.similarDate:
        return 'Similar date';
      case MatchReason.similarDescription:
        return 'Similar description';
      case MatchReason.sameMerchant:
        return 'Same merchant';
      case MatchReason.sameType:
        return 'Same type';
    }
  }

  String get icon {
    switch (this) {
      case MatchReason.exactAmount:
      case MatchReason.similarAmount:
        return '💰';
      case MatchReason.sameDate:
      case MatchReason.similarDate:
        return '📅';
      case MatchReason.similarDescription:
        return '📝';
      case MatchReason.sameMerchant:
        return '🏪';
      case MatchReason.sameType:
        return '🔄';
    }
  }
}

/// Model representing a potential duplicate match between an imported and existing transaction
class DuplicateMatchModel extends Equatable {
  const DuplicateMatchModel({
    required this.id,
    required this.importedTransaction,
    required this.existingTransaction,
    required this.confidenceScore,
    required this.reasons,
    this.resolution,
    this.amountScore,
    this.dateScore,
    this.descriptionScore,
    this.merchantScore,
  });

  /// Factory constructor from JSON
  factory DuplicateMatchModel.fromJson(Map<String, dynamic> json) {
    return DuplicateMatchModel(
      id: json['id'] as String,
      importedTransaction: ParsedTransactionModel.fromJson(
        json['importedTransaction'] as Map<String, dynamic>,
      ),
      existingTransaction: TransactionModel.fromJson(
        json['existingTransaction'] as Map<String, dynamic>,
      ),
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      reasons: (json['reasons'] as List<dynamic>)
          .map((e) => MatchReason.values.firstWhere(
                (r) => r.name == e,
                orElse: () => MatchReason.sameType,
              ),)
          .toList(),
      resolution: json['resolution'] != null
          ? DuplicateResolutionAction.values.firstWhere(
              (e) => e.name == json['resolution'],
            )
          : null,
      amountScore: json['amountScore'] != null
          ? (json['amountScore'] as num).toDouble()
          : null,
      dateScore: json['dateScore'] != null
          ? (json['dateScore'] as num).toDouble()
          : null,
      descriptionScore: json['descriptionScore'] != null
          ? (json['descriptionScore'] as num).toDouble()
          : null,
      merchantScore: json['merchantScore'] != null
          ? (json['merchantScore'] as num).toDouble()
          : null,
    );
  }

  /// Unique identifier for this duplicate match
  final String id;

  /// The transaction being imported
  final ParsedTransactionModel importedTransaction;

  /// The existing transaction in the database
  final TransactionModel existingTransaction;

  /// Confidence score (0.0 to 1.0) indicating how likely this is a duplicate
  final double confidenceScore;

  /// List of reasons why these transactions match
  final List<MatchReason> reasons;

  /// User's chosen resolution action (null if not yet resolved)
  final DuplicateResolutionAction? resolution;

  /// Individual component scores (optional, for detailed analysis)
  final double? amountScore;
  final double? dateScore;
  final double? descriptionScore;
  final double? merchantScore;

  /// Get confidence level as a string
  String get confidenceLevel {
    if (confidenceScore >= 0.85) return 'High';
    if (confidenceScore >= 0.70) return 'Medium';
    if (confidenceScore >= 0.50) return 'Low';
    return 'Very Low';
  }

  /// Get confidence score as percentage
  int get confidencePercentage => (confidenceScore * 100).round();

  /// Whether this match has been resolved
  bool get isResolved => resolution != null;

  /// Whether this is a high confidence match
  bool get isHighConfidence => confidenceScore >= 0.85;

  /// Whether this is a medium confidence match
  bool get isMediumConfidence => confidenceScore >= 0.70 && confidenceScore < 0.85;

  /// Whether this is a low confidence match
  bool get isLowConfidence => confidenceScore >= 0.50 && confidenceScore < 0.70;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'importedTransaction': importedTransaction.toJson(),
      'existingTransaction': existingTransaction.toJson(),
      'confidenceScore': confidenceScore,
      'reasons': reasons.map((r) => r.name).toList(),
      'resolution': resolution?.name,
      if (amountScore != null) 'amountScore': amountScore,
      if (dateScore != null) 'dateScore': dateScore,
      if (descriptionScore != null) 'descriptionScore': descriptionScore,
      if (merchantScore != null) 'merchantScore': merchantScore,
    };
  }

  /// Copy with method for creating modified copies
  DuplicateMatchModel copyWith({
    String? id,
    ParsedTransactionModel? importedTransaction,
    TransactionModel? existingTransaction,
    double? confidenceScore,
    List<MatchReason>? reasons,
    DuplicateResolutionAction? resolution,
    double? amountScore,
    double? dateScore,
    double? descriptionScore,
    double? merchantScore,
  }) {
    return DuplicateMatchModel(
      id: id ?? this.id,
      importedTransaction: importedTransaction ?? this.importedTransaction,
      existingTransaction: existingTransaction ?? this.existingTransaction,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      reasons: reasons ?? this.reasons,
      resolution: resolution ?? this.resolution,
      amountScore: amountScore ?? this.amountScore,
      dateScore: dateScore ?? this.dateScore,
      descriptionScore: descriptionScore ?? this.descriptionScore,
      merchantScore: merchantScore ?? this.merchantScore,
    );
  }

  @override
  List<Object?> get props => [
        id,
        importedTransaction,
        existingTransaction,
        confidenceScore,
        reasons,
        resolution,
        amountScore,
        dateScore,
        descriptionScore,
        merchantScore,
      ];
}
