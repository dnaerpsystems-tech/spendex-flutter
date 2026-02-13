/// Client-side duplicate detection service
///
/// Provides duplicate detection logic for comparing imported transactions
/// against existing transactions using configurable matching algorithms.
library;

import 'package:spendex/core/utils/string_similarity.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/transactions/data/models/transaction_model.dart';

/// Configuration for duplicate detection algorithms
class DuplicateDetectionConfig {
  const DuplicateDetectionConfig({
    this.dateTolerance = 2,
    this.amountTolerance = 0.01,
    this.descriptionSimilarityThreshold = 0.85,
    this.merchantSimilarityThreshold = 0.80,
    this.accountAware = true,
  });

  /// Number of days +/- to consider for date matching
  final int dateTolerance;

  /// Percentage tolerance for amount matching (0.01 = 1%)
  final double amountTolerance;

  /// Minimum similarity score for description matching (0.0 to 1.0)
  final double descriptionSimilarityThreshold;

  /// Minimum similarity score for merchant matching (0.0 to 1.0)
  final double merchantSimilarityThreshold;

  /// Only compare transactions within the same account
  final bool accountAware;

  DuplicateDetectionConfig copyWith({
    int? dateTolerance,
    double? amountTolerance,
    double? descriptionSimilarityThreshold,
    double? merchantSimilarityThreshold,
    bool? accountAware,
  }) {
    return DuplicateDetectionConfig(
      dateTolerance: dateTolerance ?? this.dateTolerance,
      amountTolerance: amountTolerance ?? this.amountTolerance,
      descriptionSimilarityThreshold:
          descriptionSimilarityThreshold ?? this.descriptionSimilarityThreshold,
      merchantSimilarityThreshold:
          merchantSimilarityThreshold ?? this.merchantSimilarityThreshold,
      accountAware: accountAware ?? this.accountAware,
    );
  }
}

/// Reasons why two transactions might be duplicates
enum MatchReason {
  exactAmount,
  similarAmount,
  sameDate,
  similarDate,
  similarDescription,
  sameMerchant,
  sameType,
}

/// Result of comparing two transactions
class DuplicateMatchResult {
  const DuplicateMatchResult({
    required this.confidenceScore,
    required this.reasons,
    required this.amountScore,
    required this.dateScore,
    required this.descriptionScore,
    required this.merchantScore,
  });

  /// Overall confidence score (0.0 to 1.0)
  final double confidenceScore;

  /// List of reasons for the match
  final List<MatchReason> reasons;

  /// Individual component scores
  final double amountScore;
  final double dateScore;
  final double descriptionScore;
  final double merchantScore;

  /// Get confidence level as a string
  String get confidenceLevel {
    if (confidenceScore >= 0.85) return 'high';
    if (confidenceScore >= 0.70) return 'medium';
    if (confidenceScore >= 0.50) return 'low';
    return 'very_low';
  }

  /// Whether this is a high confidence match
  bool get isHighConfidence => confidenceScore >= 0.85;

  /// Whether this is a medium confidence match
  bool get isMediumConfidence => confidenceScore >= 0.70 && confidenceScore < 0.85;

  /// Whether this is a low confidence match
  bool get isLowConfidence => confidenceScore >= 0.50 && confidenceScore < 0.70;
}

/// Service for detecting duplicate transactions
class DuplicateDetectionService {
  const DuplicateDetectionService({
    this.config = const DuplicateDetectionConfig(),
  });

  final DuplicateDetectionConfig config;

  /// Compare an imported transaction with an existing transaction
  ///
  /// Returns a [DuplicateMatchResult] with confidence score and match reasons.
  /// Returns null if transactions are from different accounts (when accountAware is true).
  DuplicateMatchResult? compareTransactions({
    required ParsedTransactionModel imported,
    required TransactionModel existing,
  }) {
    // Account-aware check: only compare within same account
    if (config.accountAware) {
      if (imported.account == null || existing.accountId != imported.account) {
        return null;
      }
    }

    // Calculate individual component scores
    final amountScore = _calculateAmountScore(imported, existing);
    final dateScore = _calculateDateScore(imported, existing);
    final descriptionScore = _calculateDescriptionScore(imported, existing);
    final merchantScore = _calculateMerchantScore(imported, existing);

    // Calculate weighted confidence score
    final confidenceScore = _calculateConfidenceScore(
      amountScore: amountScore,
      dateScore: dateScore,
      descriptionScore: descriptionScore,
      merchantScore: merchantScore,
    );

    // Determine match reasons
    final reasons = _determineMatchReasons(
      imported: imported,
      existing: existing,
      amountScore: amountScore,
      dateScore: dateScore,
      descriptionScore: descriptionScore,
      merchantScore: merchantScore,
    );

    return DuplicateMatchResult(
      confidenceScore: confidenceScore,
      reasons: reasons,
      amountScore: amountScore,
      dateScore: dateScore,
      descriptionScore: descriptionScore,
      merchantScore: merchantScore,
    );
  }

  /// Calculate amount match score (0.0 to 1.0)
  ///
  /// Converts both amounts to paise for comparison to avoid floating point issues.
  /// Returns 1.0 for exact match, partial score for matches within tolerance.
  double _calculateAmountScore(
    ParsedTransactionModel imported,
    TransactionModel existing,
  ) {
    // Convert imported amount (in rupees) to paise
    final importedAmountInPaise = (imported.amount * 100).round();
    final existingAmountInPaise = existing.amount;

    // Exact match
    if (importedAmountInPaise == existingAmountInPaise) {
      return 1.0;
    }

    // Calculate percentage difference
    final difference = (importedAmountInPaise - existingAmountInPaise).abs();
    final percentageDiff = difference / existingAmountInPaise;

    // Within tolerance
    if (percentageDiff <= config.amountTolerance) {
      return 0.75; // Partial score for matches within tolerance
    }

    // Calculate score based on how close the amounts are
    // Further away = lower score
    if (percentageDiff <= 0.05) {
      return 0.5;
    } else if (percentageDiff <= 0.10) {
      return 0.3;
    }

    return 0.0;
  }

  /// Calculate date match score (0.0 to 1.0)
  ///
  /// Returns 1.0 for same day, partial scores for dates within tolerance.
  double _calculateDateScore(
    ParsedTransactionModel imported,
    TransactionModel existing,
  ) {
    // Normalize dates to day precision (ignore time)
    final importedDate = DateTime(
      imported.date.year,
      imported.date.month,
      imported.date.day,
    );
    final existingDate = DateTime(
      existing.date.year,
      existing.date.month,
      existing.date.day,
    );

    // Exact match
    if (importedDate == existingDate) {
      return 1.0;
    }

    // Calculate day difference
    final daysDifference = importedDate.difference(existingDate).inDays.abs();

    // Within ±1 day
    if (daysDifference == 1) {
      return 0.67;
    }

    // Within ±2 days
    if (daysDifference == 2) {
      return 0.33;
    }

    // Within configured tolerance
    if (daysDifference <= config.dateTolerance) {
      return 0.2;
    }

    return 0.0;
  }

  /// Calculate description similarity score (0.0 to 1.0)
  ///
  /// Uses the best string similarity algorithm for comparing descriptions.
  double _calculateDescriptionScore(
    ParsedTransactionModel imported,
    TransactionModel existing,
  ) {
    final importedDesc = imported.description.trim();
    final existingDesc = existing.description?.trim() ?? '';

    if (importedDesc.isEmpty || existingDesc.isEmpty) {
      return 0.0;
    }

    // Use the best similarity algorithm from string_similarity.dart
    return bestSimilarity(importedDesc, existingDesc);
  }

  /// Calculate merchant/payee similarity score (0.0 to 1.0)
  ///
  /// Compares merchant field from imported transaction with payee from existing.
  /// Returns 0.0 if either field is missing.
  double _calculateMerchantScore(
    ParsedTransactionModel imported,
    TransactionModel existing,
  ) {
    final importedMerchant = imported.merchant?.trim();
    final existingPayee = existing.payee?.trim();

    // If both are missing, return neutral score (doesn't affect overall)
    if (importedMerchant == null || existingPayee == null) {
      return 0.0;
    }

    if (importedMerchant.isEmpty || existingPayee.isEmpty) {
      return 0.0;
    }

    // Use case-insensitive similarity
    return caseInsensitiveSimilarity(importedMerchant, existingPayee);
  }

  /// Calculate overall confidence score using weighted components
  ///
  /// Weights:
  /// - Amount: 40%
  /// - Date: 30%
  /// - Description: 20%
  /// - Merchant: 10%
  double _calculateConfidenceScore({
    required double amountScore,
    required double dateScore,
    required double descriptionScore,
    required double merchantScore,
  }) {
    const amountWeight = 0.40;
    const dateWeight = 0.30;
    const descriptionWeight = 0.20;
    const merchantWeight = 0.10;

    final score = (amountScore * amountWeight) +
        (dateScore * dateWeight) +
        (descriptionScore * descriptionWeight) +
        (merchantScore * merchantWeight);

    // Ensure score is between 0.0 and 1.0
    return score.clamp(0.0, 1.0);
  }

  /// Determine match reasons based on component scores
  List<MatchReason> _determineMatchReasons({
    required ParsedTransactionModel imported,
    required TransactionModel existing,
    required double amountScore,
    required double dateScore,
    required double descriptionScore,
    required double merchantScore,
  }) {
    final reasons = <MatchReason>[];

    // Amount reasons
    if (amountScore == 1.0) {
      reasons.add(MatchReason.exactAmount);
    } else if (amountScore >= 0.75) {
      reasons.add(MatchReason.similarAmount);
    }

    // Date reasons
    if (dateScore == 1.0) {
      reasons.add(MatchReason.sameDate);
    } else if (dateScore >= 0.5) {
      reasons.add(MatchReason.similarDate);
    }

    // Description reasons
    if (descriptionScore >= config.descriptionSimilarityThreshold) {
      reasons.add(MatchReason.similarDescription);
    }

    // Merchant reasons
    if (merchantScore >= config.merchantSimilarityThreshold) {
      reasons.add(MatchReason.sameMerchant);
    }

    // Type match (transaction type should be same)
    if (_isSameType(imported, existing)) {
      reasons.add(MatchReason.sameType);
    }

    return reasons;
  }

  /// Check if imported and existing transactions have the same type
  bool _isSameType(ParsedTransactionModel imported, TransactionModel existing) {
    // Map ParsedTransaction type enum to Transaction type enum
    final importedTypeValue = imported.type.name.toUpperCase();
    final existingTypeValue = existing.type.value;

    return importedTypeValue == existingTypeValue;
  }

  /// Find potential duplicates for a list of imported transactions
  ///
  /// Compares each imported transaction against a list of existing transactions
  /// and returns matches that exceed the minimum confidence threshold.
  Map<String, List<DuplicateMatchResult>> findDuplicates({
    required List<ParsedTransactionModel> importedTransactions,
    required List<TransactionModel> existingTransactions,
    double minimumConfidence = 0.50,
  }) {
    final duplicates = <String, List<DuplicateMatchResult>>{};

    for (final imported in importedTransactions) {
      final matches = <DuplicateMatchResult>[];

      for (final existing in existingTransactions) {
        final result = compareTransactions(
          imported: imported,
          existing: existing,
        );

        if (result != null && result.confidenceScore >= minimumConfidence) {
          matches.add(result);
        }
      }

      if (matches.isNotEmpty) {
        // Sort by confidence score (highest first)
        matches.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));
        duplicates[imported.id] = matches;
      }
    }

    return duplicates;
  }

  /// Check if a single imported transaction is a duplicate
  ///
  /// Returns the best match (highest confidence) if found, null otherwise.
  DuplicateMatchResult? isDuplicate({
    required ParsedTransactionModel imported,
    required List<TransactionModel> existingTransactions,
    double minimumConfidence = 0.70,
  }) {
    DuplicateMatchResult? bestMatch;
    double highestConfidence = minimumConfidence;

    for (final existing in existingTransactions) {
      final result = compareTransactions(
        imported: imported,
        existing: existing,
      );

      if (result != null && result.confidenceScore > highestConfidence) {
        bestMatch = result;
        highestConfidence = result.confidenceScore;
      }
    }

    return bestMatch;
  }
}
