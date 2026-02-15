import 'package:equatable/equatable.dart';
import 'package:spendex/features/bank_import/data/models/parsed_transaction_model.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';

/// Result of duplicate detection process
class DuplicateDetectionResult extends Equatable {
  const DuplicateDetectionResult({
    required this.uniqueTransactions,
    required this.duplicateMatches,
    this.stats,
  });

  /// Factory constructor from JSON
  factory DuplicateDetectionResult.fromJson(Map<String, dynamic> json) {
    return DuplicateDetectionResult(
      uniqueTransactions: (json['uniqueTransactions'] as List<dynamic>?)
              ?.map((e) => ParsedTransactionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      duplicateMatches: (json['duplicateMatches'] as List<dynamic>?)
              ?.map((e) => DuplicateMatchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      stats: json['stats'] != null
          ? DuplicateDetectionStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Transactions that have no duplicates (safe to import)
  final List<ParsedTransactionModel> uniqueTransactions;

  /// List of potential duplicate matches that need user review
  final List<DuplicateMatchModel> duplicateMatches;

  /// Statistics about the detection process
  final DuplicateDetectionStats? stats;

  /// Check if any duplicates were found
  bool get hasDuplicates => duplicateMatches.isNotEmpty;

  /// Get total number of transactions checked
  int get totalChecked => uniqueTransactions.length + duplicateMatches.length;

  /// Get high confidence duplicates
  List<DuplicateMatchModel> get highConfidenceDuplicates {
    return duplicateMatches.where((m) => m.isHighConfidence).toList();
  }

  /// Get medium confidence duplicates
  List<DuplicateMatchModel> get mediumConfidenceDuplicates {
    return duplicateMatches.where((m) => m.isMediumConfidence).toList();
  }

  /// Get low confidence duplicates
  List<DuplicateMatchModel> get lowConfidenceDuplicates {
    return duplicateMatches.where((m) => m.isLowConfidence).toList();
  }

  /// Group duplicates by confidence level
  Map<String, List<DuplicateMatchModel>> get groupedByConfidence {
    return {
      'high': highConfidenceDuplicates,
      'medium': mediumConfidenceDuplicates,
      'low': lowConfidenceDuplicates,
    };
  }

  /// Get resolved duplicates
  List<DuplicateMatchModel> get resolvedDuplicates {
    return duplicateMatches.where((m) => m.isResolved).toList();
  }

  /// Get unresolved duplicates
  List<DuplicateMatchModel> get unresolvedDuplicates {
    return duplicateMatches.where((m) => !m.isResolved).toList();
  }

  /// Check if all duplicates have been resolved
  bool get allResolved => duplicateMatches.every((m) => m.isResolved);

  /// Get count of duplicates by resolution action
  Map<DuplicateResolutionAction, int> get resolutionCounts {
    final counts = <DuplicateResolutionAction, int>{
      DuplicateResolutionAction.skip: 0,
      DuplicateResolutionAction.merge: 0,
      DuplicateResolutionAction.keepBoth: 0,
    };

    for (final match in duplicateMatches) {
      if (match.resolution != null) {
        counts[match.resolution!] = (counts[match.resolution!] ?? 0) + 1;
      }
    }

    return counts;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uniqueTransactions': uniqueTransactions.map((t) => t.toJson()).toList(),
      'duplicateMatches': duplicateMatches.map((m) => m.toJson()).toList(),
      if (stats != null) 'stats': stats!.toJson(),
    };
  }

  /// Copy with method
  DuplicateDetectionResult copyWith({
    List<ParsedTransactionModel>? uniqueTransactions,
    List<DuplicateMatchModel>? duplicateMatches,
    DuplicateDetectionStats? stats,
  }) {
    return DuplicateDetectionResult(
      uniqueTransactions: uniqueTransactions ?? this.uniqueTransactions,
      duplicateMatches: duplicateMatches ?? this.duplicateMatches,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [uniqueTransactions, duplicateMatches, stats];
}

/// Statistics from the duplicate detection process
class DuplicateDetectionStats extends Equatable {
  const DuplicateDetectionStats({
    required this.totalChecked,
    required this.duplicatesFound,
    required this.highConfidence,
    required this.mediumConfidence,
    required this.lowConfidence,
    this.processingTimeMs,
  });

  /// Factory constructor from JSON
  factory DuplicateDetectionStats.fromJson(Map<String, dynamic> json) {
    return DuplicateDetectionStats(
      totalChecked: json['totalChecked'] as int,
      duplicatesFound: json['duplicatesFound'] as int,
      highConfidence: json['highConfidence'] as int,
      mediumConfidence: json['mediumConfidence'] as int,
      lowConfidence: json['lowConfidence'] as int,
      processingTimeMs: json['processingTimeMs'] as int?,
    );
  }

  /// Total number of transactions checked
  final int totalChecked;

  /// Total number of duplicates found
  final int duplicatesFound;

  /// Number of high confidence matches
  final int highConfidence;

  /// Number of medium confidence matches
  final int mediumConfidence;

  /// Number of low confidence matches
  final int lowConfidence;

  /// Time taken for detection (milliseconds)
  final int? processingTimeMs;

  /// Get unique transactions count
  int get uniqueCount => totalChecked - duplicatesFound;

  /// Get duplicate percentage
  double get duplicatePercentage {
    if (totalChecked == 0) {
      return 0;
    }
    return (duplicatesFound / totalChecked) * 100;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalChecked': totalChecked,
      'duplicatesFound': duplicatesFound,
      'highConfidence': highConfidence,
      'mediumConfidence': mediumConfidence,
      'lowConfidence': lowConfidence,
      if (processingTimeMs != null) 'processingTimeMs': processingTimeMs,
    };
  }

  @override
  List<Object?> get props => [
        totalChecked,
        duplicatesFound,
        highConfidence,
        mediumConfidence,
        lowConfidence,
        processingTimeMs,
      ];
}
