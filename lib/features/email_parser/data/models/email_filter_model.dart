import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'email_message_model.dart';

class EmailFilterModel extends Equatable {
  final Set<String> selectedBanks;
  final DateTimeRange? dateRange;
  final bool includeAttachments;
  final Set<EmailType> emailTypes;
  final bool onlyUnparsed;
  final String? searchQuery;
  final int? maxResults;

  const EmailFilterModel({
    this.selectedBanks = const {},
    this.dateRange,
    this.includeAttachments = true,
    this.emailTypes = const {
      EmailType.notification,
      EmailType.statement,
      EmailType.receipt,
    },
    this.onlyUnparsed = false,
    this.searchQuery,
    this.maxResults,
  });

  factory EmailFilterModel.fromJson(Map<String, dynamic> json) {
    return EmailFilterModel(
      selectedBanks: json['selectedBanks'] != null
          ? (json['selectedBanks'] as List<dynamic>)
              .map((e) => e as String)
              .toSet()
          : const {},
      dateRange: json['dateRange'] != null
          ? DateTimeRange(
              start: DateTime.parse(
                (json['dateRange'] as Map<String, dynamic>)['start'] as String,
              ),
              end: DateTime.parse(
                (json['dateRange'] as Map<String, dynamic>)['end'] as String,
              ),
            )
          : null,
      includeAttachments: json['includeAttachments'] as bool? ?? true,
      emailTypes: json['emailTypes'] != null
          ? (json['emailTypes'] as List<dynamic>)
              .map((e) => EmailType.values.firstWhere(
                    (type) => type.name == e,
                    orElse: () => EmailType.other,
                  ))
              .toSet()
          : const {
              EmailType.notification,
              EmailType.statement,
              EmailType.receipt,
            },
      onlyUnparsed: json['onlyUnparsed'] as bool? ?? false,
      searchQuery: json['searchQuery'] as String?,
      maxResults: json['maxResults'] != null
          ? (json['maxResults'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedBanks': selectedBanks.toList(),
      'dateRange': dateRange != null
          ? {
              'start': dateRange!.start.toIso8601String(),
              'end': dateRange!.end.toIso8601String(),
            }
          : null,
      'includeAttachments': includeAttachments,
      'emailTypes': emailTypes.map((e) => e.name).toList(),
      'onlyUnparsed': onlyUnparsed,
      'searchQuery': searchQuery,
      'maxResults': maxResults,
    };
  }

  EmailFilterModel copyWith({
    Set<String>? selectedBanks,
    DateTimeRange? dateRange,
    bool? includeAttachments,
    Set<EmailType>? emailTypes,
    bool? onlyUnparsed,
    String? searchQuery,
    int? maxResults,
  }) {
    return EmailFilterModel(
      selectedBanks: selectedBanks ?? this.selectedBanks,
      dateRange: dateRange ?? this.dateRange,
      includeAttachments: includeAttachments ?? this.includeAttachments,
      emailTypes: emailTypes ?? this.emailTypes,
      onlyUnparsed: onlyUnparsed ?? this.onlyUnparsed,
      searchQuery: searchQuery ?? this.searchQuery,
      maxResults: maxResults ?? this.maxResults,
    );
  }

  @override
  List<Object?> get props => [
        selectedBanks,
        dateRange,
        includeAttachments,
        emailTypes,
        onlyUnparsed,
        searchQuery,
        maxResults,
      ];

  /// Check if filters are empty (default state)
  bool get isEmpty =>
      selectedBanks.isEmpty &&
      dateRange == null &&
      emailTypes.length == 3 &&
      !onlyUnparsed &&
      (searchQuery == null || searchQuery!.isEmpty);

  /// Get filter count for UI display
  int get activeFilterCount {
    int count = 0;

    if (selectedBanks.isNotEmpty) count++;
    if (dateRange != null) count++;
    if (!includeAttachments) count++;
    if (emailTypes.length < 3) count++;
    if (onlyUnparsed) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    if (maxResults != null) count++;

    return count;
  }

  /// Create default filter with last 30 days
  factory EmailFilterModel.defaultFilter() {
    return EmailFilterModel(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
      emailTypes: const {
        EmailType.notification,
        EmailType.statement,
        EmailType.receipt,
      },
      includeAttachments: true,
    );
  }

  /// Create filter for last 7 days
  factory EmailFilterModel.lastWeek() {
    return EmailFilterModel(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 7)),
        end: DateTime.now(),
      ),
    );
  }

  /// Create filter for last month
  factory EmailFilterModel.lastMonth() {
    return EmailFilterModel(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
  }

  /// Create filter for last 3 months
  factory EmailFilterModel.lastThreeMonths() {
    return EmailFilterModel(
      dateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 90)),
        end: DateTime.now(),
      ),
    );
  }

  /// Create filter for current year
  factory EmailFilterModel.currentYear() {
    final now = DateTime.now();
    return EmailFilterModel(
      dateRange: DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: now,
      ),
    );
  }
}
