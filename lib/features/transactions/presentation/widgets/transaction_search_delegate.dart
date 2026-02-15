import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../app/theme.dart';
import '../../data/models/transaction_model.dart';
import '../providers/search_history_provider.dart';
import 'date_group_header.dart';
import 'transaction_card.dart';

/// Check if speech is supported on this platform
bool get _isSpeechSupportedForSearch {
  if (kIsWeb) return false;
  return Platform.isIOS || Platform.isAndroid;
}

/// A custom SearchDelegate for searching transactions.
///
/// Features:
/// - Search by description, category name, account name, payee, notes
/// - Real-time search as user types (with debounce)
/// - Search history (stores last 10 searches locally)
/// - Recent searches suggestions
/// - Search results grouped by date
/// - Empty state when no results
/// - Loading state while searching
class TransactionSearchDelegate extends SearchDelegate<TransactionModel?> {
  /// Creates a TransactionSearchDelegate.
  ///
  /// [ref] is the WidgetRef for accessing providers.
  /// [transactions] is the list of transactions to search through.
  TransactionSearchDelegate({
    required this.ref,
    required this.transactions,
  }) : super(
          searchFieldLabel: 'Search transactions...',
          searchFieldStyle: SpendexTheme.bodyMedium,
        );

  /// The WidgetRef for accessing providers.
  final WidgetRef ref;

  /// The list of transactions to search through.
  final List<TransactionModel> transactions;

  /// Debounce timer for search input.
  Timer? _debounce;

  /// Current search results.
  List<TransactionModel> _searchResults = [];

  /// Whether a search is in progress.
  // ignore: unused_field
  final bool __isSearching = false;

  /// Speech to text instance for voice search.
  final SpeechToText _speech = SpeechToText();
  bool _speechInitialized = false;

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        foregroundColor: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: SpendexTheme.bodyMedium.copyWith(
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        ),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: SpendexTheme.bodyMedium.copyWith(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        ),
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Iconsax.arrow_left),
      onPressed: () {
        _debounce?.cancel();
        close(context, null);
      },
      tooltip: 'Back',
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // Clear button - only show when there's text
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          tooltip: 'Clear',
        ),
      // Voice input button
      IconButton(
        icon: const Icon(Iconsax.microphone_2),
        onPressed: () => _startVoiceSearch(context),
        tooltip: 'Voice search',
      ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Cancel any pending debounce
    _debounce?.cancel();

    if (query.isEmpty) {
      // Show search history when query is empty
      return _buildSearchHistory(context);
    }

    // Debounce search for better performance
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchResults = _searchTransactions(query);
    });

    // Show immediate results while typing
    _searchResults = _searchTransactions(query);

    if (_searchResults.isEmpty) {
      return _buildEmptyState(context, query);
    }

    return _buildSearchResults(context, _searchResults);
  }

  @override
  Widget buildResults(BuildContext context) {
    _debounce?.cancel();
    _searchResults = _searchTransactions(query);

    // Save to search history if there's a valid query
    if (query.trim().isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addSearch(query.trim());
    }

    if (_searchResults.isEmpty) {
      return _buildEmptyState(context, query);
    }

    return _buildSearchResults(context, _searchResults);
  }

  /// Searches through transactions based on the query.
  ///
  /// Matches against:
  /// - description (partial match, case insensitive)
  /// - category.name (partial match)
  /// - account.name (partial match)
  /// - toAccount.name (partial match, for transfers)
  /// - payee (partial match)
  /// - notes (partial match)
  /// - amount (if query is numeric)
  List<TransactionModel> _searchTransactions(String searchQuery) {
    if (searchQuery.trim().isEmpty) {
      return [];
    }

    final lowerQuery = searchQuery.toLowerCase().trim();
    final numericQuery = double.tryParse(searchQuery.trim());

    return transactions.where((transaction) {
      // Search in description
      if (transaction.description != null &&
          transaction.description!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in category name
      if (transaction.category != null &&
          transaction.category!.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in account name
      if (transaction.account != null &&
          transaction.account!.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in toAccount name (for transfers)
      if (transaction.toAccount != null &&
          transaction.toAccount!.name.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in payee
      if (transaction.payee != null && transaction.payee!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in notes
      if (transaction.notes != null && transaction.notes!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in tags
      if (transaction.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) {
        return true;
      }

      // Search by amount (if query is numeric)
      if (numericQuery != null) {
        final amountInRupees = transaction.amountInRupees;
        // Check if amount contains the numeric query
        if (amountInRupees.toString().contains(numericQuery.toString())) {
          return true;
        }
        // Also check exact match
        if (amountInRupees == numericQuery) {
          return true;
        }
      }

      return false;
    }).toList()
      // Sort by date (most recent first)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Builds the search history view.
  Widget _buildSearchHistory(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = ref.watch(searchHistoryProvider);

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_normal,
              size: 64,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'Search your transactions',
              style: SpendexTheme.titleMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search by description, category, payee, or amount',
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Header with clear all button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Searches',
              style: SpendexTheme.titleMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).clearHistory();
              },
              child: Text(
                'Clear all',
                style: SpendexTheme.labelMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // History items
        ...history.map(
          (historyItem) => _buildHistoryItem(
            context,
            historyItem,
            isDark,
          ),
        ),
      ],
    );
  }

  /// Builds a single history item.
  Widget _buildHistoryItem(BuildContext context, String historyItem, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Iconsax.clock,
        color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        size: 20,
      ),
      title: Text(
        historyItem,
        style: SpendexTheme.bodyMedium.copyWith(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Iconsax.close_circle,
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
          size: 20,
        ),
        onPressed: () {
          ref.read(searchHistoryProvider.notifier).removeSearch(historyItem);
        },
      ),
      onTap: () {
        query = historyItem;
        showResults(context);
      },
    );
  }

  /// Builds the search results view with transactions grouped by date.
  Widget _buildSearchResults(
    BuildContext context,
    List<TransactionModel> results,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group transactions by date
    final groupedTransactions = _groupByDate(results);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '${results.length} result${results.length == 1 ? '' : 's'} found',
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final entry = groupedTransactions.entries.elementAt(index);
              final date = entry.key;
              final dayTransactions = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  DateGroupHeader(
                    date: date,
                  ),
                  // Transactions for this date
                  ...dayTransactions.map(
                    (transaction) => TransactionCard(
                      transaction: transaction,
                      onTap: () {
                        // Save to history and close with result
                        if (query.trim().isNotEmpty) {
                          ref.read(searchHistoryProvider.notifier).addSearch(query.trim());
                        }
                        close(context, transaction);
                      },
                      showDate: false,
                      compact: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Groups transactions by date.
  Map<DateTime, List<TransactionModel>> _groupByDate(
    List<TransactionModel> transactions,
  ) {
    final grouped = <DateTime, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final dateOnly = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (!grouped.containsKey(dateOnly)) {
        grouped[dateOnly] = [];
      }
      grouped[dateOnly]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  /// Builds the empty state view.
  Widget _buildEmptyState(BuildContext context, String searchQuery) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_status,
              size: 80,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              'No transactions found',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find any transactions matching '$searchQuery'",
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Try searching for:',
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(context, 'Food', isDark),
                _buildSuggestionChip(context, 'Shopping', isDark),
                _buildSuggestionChip(context, 'Salary', isDark),
                _buildSuggestionChip(context, '1000', isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a suggestion chip for the empty state.
  Widget _buildSuggestionChip(
    BuildContext context,
    String suggestion,
    bool isDark,
  ) {
    return ActionChip(
      label: Text(
        suggestion,
        style: SpendexTheme.labelMedium.copyWith(
          color: SpendexColors.primary,
        ),
      ),
      backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
      side: BorderSide.none,
      onPressed: () {
        query = suggestion;
        showResults(context);
      },
    );
  }

  /// Start voice search
  Future<void> _startVoiceSearch(BuildContext context) async {
    // Check if platform supports speech
    if (!_isSpeechSupportedForSearch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice search is not supported on this platform'),
          backgroundColor: SpendexColors.expense,
        ),
      );
      return;
    }

    // Initialize speech if not already initialized
    if (!_speechInitialized) {
      _speechInitialized = await _speech.initialize(
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Speech recognition error: ${error.errorMsg}'),
              backgroundColor: SpendexColors.expense,
            ),
          );
        },
      );

      if (!_speechInitialized) {
        if (!context.mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available on this device'),
            backgroundColor: SpendexColors.expense,
          ),
        );
        return;
      }
    }

    // Check permission
    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Microphone permission required. Please enable in settings.',
          ),
          backgroundColor: SpendexColors.expense,
        ),
      );
      return;
    }

    // Show listening dialog
    if (!context.mounted) {
      return;
    }
    unawaited(
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _VoiceSearchDialog(
          onResult: (recognizedText) {
            Navigator.pop(dialogContext);
            if (recognizedText.isNotEmpty) {
              query = recognizedText;
              showResults(context);
            }
          },
          speech: _speech,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

/// Voice search dialog widget
class _VoiceSearchDialog extends StatefulWidget {
  const _VoiceSearchDialog({
    required this.onResult,
    required this.speech,
  });

  final ValueChanged<String> onResult;
  final SpeechToText speech;

  @override
  State<_VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<_VoiceSearchDialog> {
  String _recognizedText = '';
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    if (widget.speech.isListening) {
      widget.speech.stop();
    }
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    try {
      await widget.speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });

          if (result.finalResult) {
            widget.onResult(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 2),
      );
    } catch (e) {
      widget.onResult('');
    }
  }

  void _stopListening() {
    if (widget.speech.isListening) {
      widget.speech.stop();
    }
    widget.onResult(_recognizedText);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          const Icon(
            Iconsax.microphone_2,
            color: SpendexColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            'Voice Search',
            style: SpendexTheme.headlineMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Icon(
            Iconsax.microphone_2,
            size: 48,
            color: _isListening ? SpendexColors.primary : SpendexColors.expense,
          ),
          const SizedBox(height: 24),
          Text(
            _isListening ? 'Listening...' : 'Processing...',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _recognizedText.isEmpty ? 'Say something...' : _recognizedText,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.speech.cancel();
            widget.onResult('');
          },
          child: Text(
            'Cancel',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
        FilledButton(
          onPressed: _stopListening,
          child: const Text('Done'),
        ),
      ],
    );
  }
}
