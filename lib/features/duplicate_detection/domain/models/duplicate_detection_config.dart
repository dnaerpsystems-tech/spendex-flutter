import 'package:equatable/equatable.dart';

/// Configuration for duplicate detection algorithm
class DuplicateDetectionConfig extends Equatable {
  const DuplicateDetectionConfig({
    this.dateTolerance = 2,
    this.amountTolerance = 0.01,
    this.descriptionSimilarityThreshold = 0.85,
    this.merchantSimilarityThreshold = 0.80,
    this.accountAware = true,
    this.minimumConfidence = 0.50,
  });

  /// Factory constructor from JSON
  factory DuplicateDetectionConfig.fromJson(Map<String, dynamic> json) {
    return DuplicateDetectionConfig(
      dateTolerance: json['dateTolerance'] as int? ?? 2,
      amountTolerance: (json['amountTolerance'] as num?)?.toDouble() ?? 0.01,
      descriptionSimilarityThreshold:
          (json['descriptionSimilarityThreshold'] as num?)?.toDouble() ?? 0.85,
      merchantSimilarityThreshold:
          (json['merchantSimilarityThreshold'] as num?)?.toDouble() ?? 0.80,
      accountAware: json['accountAware'] as bool? ?? true,
      minimumConfidence: (json['minimumConfidence'] as num?)?.toDouble() ?? 0.50,
    );
  }

  /// Number of days ± to consider for date matching
  ///
  /// Default: 2 days
  /// - Transactions within ±2 days are considered for matching
  /// - Same day = full score, ±1 day = partial score, ±2 days = low score
  final int dateTolerance;

  /// Percentage tolerance for amount matching
  ///
  /// Default: 0.01 (1%)
  /// - Amounts within 1% are considered similar
  /// - Exact match = full score, within tolerance = partial score
  final double amountTolerance;

  /// Minimum similarity score for description matching (0.0 to 1.0)
  ///
  /// Default: 0.85 (85% similar)
  /// - Uses Levenshtein distance and token-based similarity
  /// - Higher threshold = stricter matching
  final double descriptionSimilarityThreshold;

  /// Minimum similarity score for merchant/payee matching (0.0 to 1.0)
  ///
  /// Default: 0.80 (80% similar)
  /// - Uses case-insensitive string comparison
  /// - Optional field (only used if both transactions have merchant/payee)
  final double merchantSimilarityThreshold;

  /// Only compare transactions within the same account
  ///
  /// Default: true
  /// - Prevents false positives for transfers between accounts
  /// - Transactions in different accounts are never matched
  final bool accountAware;

  /// Minimum confidence score to consider as potential duplicate (0.0 to 1.0)
  ///
  /// Default: 0.50 (50%)
  /// - Matches below this threshold are ignored
  /// - Recommended: 0.50 for comprehensive detection, 0.70 for stricter matching
  final double minimumConfidence;

  /// Get default configuration
  static const DuplicateDetectionConfig defaultConfig = DuplicateDetectionConfig();

  /// Get strict configuration (higher thresholds)
  static const DuplicateDetectionConfig strict = DuplicateDetectionConfig(
    dateTolerance: 1,
    amountTolerance: 0.005,
    descriptionSimilarityThreshold: 0.90,
    merchantSimilarityThreshold: 0.85,
    minimumConfidence: 0.70,
  );

  /// Get relaxed configuration (lower thresholds)
  static const DuplicateDetectionConfig relaxed = DuplicateDetectionConfig(
    dateTolerance: 3,
    amountTolerance: 0.02,
    descriptionSimilarityThreshold: 0.75,
    merchantSimilarityThreshold: 0.70,
    minimumConfidence: 0.40,
  );

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dateTolerance': dateTolerance,
      'amountTolerance': amountTolerance,
      'descriptionSimilarityThreshold': descriptionSimilarityThreshold,
      'merchantSimilarityThreshold': merchantSimilarityThreshold,
      'accountAware': accountAware,
      'minimumConfidence': minimumConfidence,
    };
  }

  /// Copy with method
  DuplicateDetectionConfig copyWith({
    int? dateTolerance,
    double? amountTolerance,
    double? descriptionSimilarityThreshold,
    double? merchantSimilarityThreshold,
    bool? accountAware,
    double? minimumConfidence,
  }) {
    return DuplicateDetectionConfig(
      dateTolerance: dateTolerance ?? this.dateTolerance,
      amountTolerance: amountTolerance ?? this.amountTolerance,
      descriptionSimilarityThreshold:
          descriptionSimilarityThreshold ?? this.descriptionSimilarityThreshold,
      merchantSimilarityThreshold:
          merchantSimilarityThreshold ?? this.merchantSimilarityThreshold,
      accountAware: accountAware ?? this.accountAware,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
    );
  }

  @override
  List<Object?> get props => [
        dateTolerance,
        amountTolerance,
        descriptionSimilarityThreshold,
        merchantSimilarityThreshold,
        accountAware,
        minimumConfidence,
      ];
}
