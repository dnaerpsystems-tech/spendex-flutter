import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/analytics_summary_model.dart';
import '../../data/models/category_breakdown_model.dart';
import '../../data/models/daily_stats_model.dart';
import '../../data/models/monthly_stats_model.dart';
import '../../data/models/net_worth_model.dart';
import '../../domain/repositories/analytics_repository.dart';

enum AnalyticsTab { overview, income, expense, trends, netWorth }

enum DateRangePreset { thisWeek, thisMonth, last3Months, last6Months, thisYear, lastYear, custom }

extension DateRangePresetExtension on DateRangePreset {
  String get label {
    switch (this) {
      case DateRangePreset.thisWeek: return 'This Week';
      case DateRangePreset.thisMonth: return 'This Month';
      case DateRangePreset.last3Months: return 'Last 3 Months';
      case DateRangePreset.last6Months: return 'Last 6 Months';
      case DateRangePreset.thisYear: return 'This Year';
      case DateRangePreset.lastYear: return 'Last Year';
      case DateRangePreset.custom: return 'Custom';
    }
  }

  DateTimeRange getDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case DateRangePreset.thisWeek:
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        return DateTimeRange(start: startOfWeek, end: today);
      case DateRangePreset.thisMonth:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: today);
      case DateRangePreset.last3Months:
        return DateTimeRange(start: DateTime(now.year, now.month - 2, 1), end: today);
      case DateRangePreset.last6Months:
        return DateTimeRange(start: DateTime(now.year, now.month - 5, 1), end: today);
      case DateRangePreset.thisYear:
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: today);
      case DateRangePreset.lastYear:
        return DateTimeRange(start: DateTime(now.year - 1, 1, 1), end: DateTime(now.year - 1, 12, 31));
      case DateRangePreset.custom:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: today);
    }
  }
}

class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentTab = AnalyticsTab.overview,
    this.dateRangePreset = DateRangePreset.thisMonth,
    required this.dateRange,
    this.summary,
    this.incomeBreakdown,
    this.expenseBreakdown,
    this.dailyStats,
    this.monthlyStats,
    this.netWorthHistory,
    this.isExporting = false,
    this.exportUrl,
  });

  factory AnalyticsState.initial() {
    final now = DateTime.now();
    return AnalyticsState(
      dateRange: DateTimeRange(start: DateTime(now.year, now.month, 1), end: DateTime(now.year, now.month, now.day)),
    );
  }

  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final AnalyticsTab currentTab;
  final DateRangePreset dateRangePreset;
  final DateTimeRange dateRange;
  final AnalyticsSummaryModel? summary;
  final CategoryBreakdownResponse? incomeBreakdown;
  final CategoryBreakdownResponse? expenseBreakdown;
  final DailyStatsResponse? dailyStats;
  final MonthlyStatsResponse? monthlyStats;
  final NetWorthResponse? netWorthHistory;
  final bool isExporting;
  final String? exportUrl;

  bool get hasData => summary != null;

  AnalyticsState copyWith({
    bool? isLoading, bool? isLoadingMore, String? error, AnalyticsTab? currentTab,
    DateRangePreset? dateRangePreset, DateTimeRange? dateRange, AnalyticsSummaryModel? summary,
    CategoryBreakdownResponse? incomeBreakdown, CategoryBreakdownResponse? expenseBreakdown,
    DailyStatsResponse? dailyStats, MonthlyStatsResponse? monthlyStats,
    NetWorthResponse? netWorthHistory, bool? isExporting, String? exportUrl,
    bool clearError = false, bool clearExportUrl = false,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentTab: currentTab ?? this.currentTab,
      dateRangePreset: dateRangePreset ?? this.dateRangePreset,
      dateRange: dateRange ?? this.dateRange,
      summary: summary ?? this.summary,
      incomeBreakdown: incomeBreakdown ?? this.incomeBreakdown,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      dailyStats: dailyStats ?? this.dailyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      netWorthHistory: netWorthHistory ?? this.netWorthHistory,
      isExporting: isExporting ?? this.isExporting,
      exportUrl: clearExportUrl ? null : (exportUrl ?? this.exportUrl),
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoadingMore, error, currentTab, dateRangePreset, dateRange, summary, incomeBreakdown, expenseBreakdown, dailyStats, monthlyStats, netWorthHistory, isExporting, exportUrl];
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(this._repository) : super(AnalyticsState.initial());
  final AnalyticsRepository _repository;

  Future<void> loadAnalytics() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);

    final summaryResult = await _repository.getAnalyticsSummary(
      startDate: state.dateRange.start,
      endDate: state.dateRange.end,
    );

    summaryResult.fold(
      (failure) => state = state.copyWith(isLoading: false, error: failure.message),
      (summary) {
        state = state.copyWith(summary: summary);
        _loadAdditionalData();
      },
    );
  }

  Future<void> _loadAdditionalData() async {
    await Future.wait([_loadIncomeBreakdown(), _loadExpenseBreakdown(), _loadMonthlyStats()]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadIncomeBreakdown() async {
    final result = await _repository.getIncomeBreakdown(startDate: state.dateRange.start, endDate: state.dateRange.end);
    result.fold((failure) {}, (data) => state = state.copyWith(incomeBreakdown: data));
  }

  Future<void> _loadExpenseBreakdown() async {
    final result = await _repository.getExpenseBreakdown(startDate: state.dateRange.start, endDate: state.dateRange.end);
    result.fold((failure) {}, (data) => state = state.copyWith(expenseBreakdown: data));
  }

  Future<void> _loadMonthlyStats() async {
    final result = await _repository.getMonthlyStats(months: 12);
    result.fold((failure) {}, (data) => state = state.copyWith(monthlyStats: data));
  }

  Future<void> loadDailyStats() async {
    if (state.dailyStats != null) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.getDailyStats(startDate: state.dateRange.start, endDate: state.dateRange.end);
    result.fold(
      (failure) => state = state.copyWith(isLoadingMore: false, error: failure.message),
      (data) => state = state.copyWith(isLoadingMore: false, dailyStats: data),
    );
  }

  Future<void> loadNetWorthHistory() async {
    if (state.netWorthHistory != null) return;
    state = state.copyWith(isLoadingMore: true);
    final result = await _repository.getNetWorthHistory(months: 12);
    result.fold(
      (failure) => state = state.copyWith(isLoadingMore: false, error: failure.message),
      (data) => state = state.copyWith(isLoadingMore: false, netWorthHistory: data),
    );
  }

  void setTab(AnalyticsTab tab) {
    if (state.currentTab == tab) return;
    state = state.copyWith(currentTab: tab);
    if (tab == AnalyticsTab.trends) loadDailyStats();
    if (tab == AnalyticsTab.netWorth) loadNetWorthHistory();
  }

  void setDateRangePreset(DateRangePreset preset) {
    state = state.copyWith(
      dateRangePreset: preset,
      dateRange: preset.getDateRange(),
      summary: null, incomeBreakdown: null, expenseBreakdown: null, dailyStats: null,
    );
    loadAnalytics();
  }

  void setCustomDateRange(DateTimeRange range) {
    state = state.copyWith(
      dateRangePreset: DateRangePreset.custom,
      dateRange: range,
      summary: null, incomeBreakdown: null, expenseBreakdown: null, dailyStats: null,
    );
    loadAnalytics();
  }

  Future<void> exportAnalytics(String format) async {
    if (state.isExporting) return;
    state = state.copyWith(isExporting: true, clearExportUrl: true);
    final result = await _repository.exportAnalytics(startDate: state.dateRange.start, endDate: state.dateRange.end, format: format);
    result.fold(
      (failure) => state = state.copyWith(isExporting: false, error: failure.message),
      (url) => state = state.copyWith(isExporting: false, exportUrl: url),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  Future<void> refresh() async {
    state = state.copyWith(summary: null, incomeBreakdown: null, expenseBreakdown: null, dailyStats: null, monthlyStats: null, netWorthHistory: null);
    await loadAnalytics();
  }
}

final analyticsStateProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(getIt<AnalyticsRepository>());
});

final analyticsSummaryProvider = Provider<AnalyticsSummaryModel?>((ref) => ref.watch(analyticsStateProvider).summary);
final incomeBreakdownProvider = Provider<CategoryBreakdownResponse?>((ref) => ref.watch(analyticsStateProvider).incomeBreakdown);
final expenseBreakdownProvider = Provider<CategoryBreakdownResponse?>((ref) => ref.watch(analyticsStateProvider).expenseBreakdown);
final monthlyStatsProvider = Provider<MonthlyStatsResponse?>((ref) => ref.watch(analyticsStateProvider).monthlyStats);
final dailyStatsProvider = Provider<DailyStatsResponse?>((ref) => ref.watch(analyticsStateProvider).dailyStats);
final netWorthProvider = Provider<NetWorthResponse?>((ref) => ref.watch(analyticsStateProvider).netWorthHistory);
final analyticsCurrentTabProvider = Provider<AnalyticsTab>((ref) => ref.watch(analyticsStateProvider).currentTab);
final analyticsLoadingProvider = Provider<bool>((ref) => ref.watch(analyticsStateProvider).isLoading);
final analyticsErrorProvider = Provider<String?>((ref) => ref.watch(analyticsStateProvider).error);
final analyticsDateRangeProvider = Provider<DateTimeRange>((ref) => ref.watch(analyticsStateProvider).dateRange);
final analyticsDateRangePresetProvider = Provider<DateRangePreset>((ref) => ref.watch(analyticsStateProvider).dateRangePreset);
