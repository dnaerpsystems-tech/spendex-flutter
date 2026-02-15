import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing search history in SharedPreferences.
const String _searchHistoryKey = 'transaction_search_history';

/// Maximum number of search history items to store.
const int _maxHistoryItems = 10;

/// A StateNotifier that manages the transaction search history.
///
/// This class provides functionality to:
/// - Add new search queries to history
/// - Remove individual search queries
/// - Clear all search history
/// - Persist history to local storage
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  /// Creates a new SearchHistoryNotifier.
  ///
  /// The notifier initializes with an empty list and automatically
  /// loads the persisted history from local storage.
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  /// Adds a search query to the history.
  ///
  /// The query is added to the beginning of the list. If the query
  /// already exists, it's moved to the top. The history is capped
  /// at [_maxHistoryItems] items.
  ///
  /// Empty or whitespace-only queries are ignored.
  Future<void> addSearch(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return;
    }

    // Remove if already exists (to move to top)
    final newHistory = state.where((q) => q != trimmedQuery).toList()
      // Add to beginning
      ..insert(0, trimmedQuery);

    // Cap at max items
    if (newHistory.length > _maxHistoryItems) {
      newHistory.removeRange(_maxHistoryItems, newHistory.length);
    }

    state = newHistory;
    await _saveHistory();
  }

  /// Removes a specific search query from the history.
  Future<void> removeSearch(String query) async {
    state = state.where((q) => q != query).toList();
    await _saveHistory();
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    state = [];
    await _saveHistory();
  }

  /// Loads the search history from local storage.
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_searchHistoryKey) ?? [];
      state = history;
    } catch (e) {
      // If loading fails, just use empty list
      state = [];
    }
  }

  /// Saves the search history to local storage.
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_searchHistoryKey, state);
    } catch (e) {
      // Silently fail - search history is not critical
    }
  }
}

/// Provider for the search history state.
///
/// Usage:
/// ```dart
/// final history = ref.watch(searchHistoryProvider);
/// ref.read(searchHistoryProvider.notifier).addSearch('groceries');
/// ```
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

/// Provider that returns filtered search history based on a query.
///
/// This is useful for showing relevant suggestions while typing.
final filteredSearchHistoryProvider = Provider.family<List<String>, String>((ref, query) {
  final history = ref.watch(searchHistoryProvider);

  if (query.isEmpty) {
    return history;
  }

  final lowerQuery = query.toLowerCase();
  return history.where((item) => item.toLowerCase().contains(lowerQuery)).toList();
});
