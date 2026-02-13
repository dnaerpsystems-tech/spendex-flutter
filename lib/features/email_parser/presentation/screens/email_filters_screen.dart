import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/email_filter_model.dart';
import '../../data/models/email_message_model.dart';
import '../providers/email_parser_provider.dart';

/// Email filters screen (modal bottom sheet)
class EmailFiltersScreen extends ConsumerStatefulWidget {
  const EmailFiltersScreen({super.key});

  @override
  ConsumerState<EmailFiltersScreen> createState() => _EmailFiltersScreenState();
}

class _EmailFiltersScreenState extends ConsumerState<EmailFiltersScreen> {
  late Set<String> _selectedBanks;
  late DateTimeRange? _dateRange;
  late Set<EmailType> _emailTypes;
  late bool _includeAttachments;
  late String _searchQuery;
  late int _maxResults;

  final TextEditingController _searchController = TextEditingController();

  // Indian bank list
  static const List<String> _banks = [
    'HDFC Bank',
    'ICICI Bank',
    'State Bank of India',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'IndusInd Bank',
    'Yes Bank',
    'IDFC First Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
  ];

  @override
  void initState() {
    super.initState();

    final currentFilters = ref.read(emailParserProvider).filters ??
        EmailFilterModel.defaultFilter();

    _selectedBanks = Set.from(currentFilters.selectedBanks);
    _dateRange = currentFilters.dateRange;
    _emailTypes = Set.from(currentFilters.emailTypes);
    _includeAttachments = currentFilters.includeAttachments;
    _searchQuery = currentFilters.searchQuery ?? '';
    _maxResults = currentFilters.maxResults ?? 100;

    _searchController.text = _searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: SpendexColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _applyFilters() {
    final filters = EmailFilterModel(
      selectedBanks: _selectedBanks,
      dateRange: _dateRange,
      emailTypes: _emailTypes,
      includeAttachments: _includeAttachments,
      searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
      maxResults: _maxResults,
    );

    ref.read(emailParserProvider.notifier).updateFilters(filters);
    Navigator.of(context).pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedBanks = {};
      _dateRange = null;
      _emailTypes = {
        EmailType.notification,
        EmailType.statement,
        EmailType.receipt,
      };
      _includeAttachments = true;
      _searchQuery = '';
      _maxResults = 100;
      _searchController.clear();
    });
  }

  String _formatDateRange(DateTimeRange? range) {
    if (range == null) return 'Select date range';

    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Email Filters',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.expense,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Filters content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Bank selector
                Text(
                  'Banks',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _banks.map((bank) {
                    final isSelected = _selectedBanks.contains(bank);
                    return FilterChip(
                      label: Text(bank),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBanks.add(bank);
                          } else {
                            _selectedBanks.remove(bank);
                          }
                        });
                      },
                      backgroundColor: isDark
                          ? SpendexColors.darkBackground
                          : SpendexColors.lightBackground,
                      selectedColor: SpendexColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: SpendexColors.primary,
                      side: BorderSide(
                        color: isSelected
                            ? SpendexColors.primary
                            : (isDark
                                ? SpendexColors.darkBorder
                                : SpendexColors.lightBorder),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Date range
                Text(
                  'Date Range',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? SpendexColors.darkBorder
                            : SpendexColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Iconsax.calendar,
                          color: SpendexColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateRange(_dateRange),
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 16,
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Email types
                Text(
                  'Email Types',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...EmailType.values
                    .where((type) => type != EmailType.other)
                    .map((type) {
                  final isSelected = _emailTypes.contains(type);
                  String label;
                  IconData icon;

                  switch (type) {
                    case EmailType.notification:
                      label = 'Transaction Notifications';
                      icon = Iconsax.notification;
                      break;
                    case EmailType.statement:
                      label = 'Account Statements';
                      icon = Iconsax.document_text;
                      break;
                    case EmailType.receipt:
                      label = 'Payment Receipts';
                      icon = Iconsax.receipt;
                      break;
                    case EmailType.other:
                      label = 'Other';
                      icon = Iconsax.more;
                      break;
                  }

                  return CheckboxListTile(
                    title: Text(label),
                    subtitle: Text(
                      type.name.toUpperCase(),
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    secondary: Icon(icon, color: SpendexColors.primary),
                    value: isSelected,
                    onChanged: (selected) {
                      setState(() {
                        if (selected ?? false) {
                          _emailTypes.add(type);
                        } else {
                          _emailTypes.remove(type);
                        }
                      });
                    },
                    activeColor: SpendexColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
                const SizedBox(height: 24),

                // Include attachments toggle
                SwitchListTile(
                  title: const Text('Include Attachments'),
                  subtitle: Text(
                    'Include emails with PDF/CSV attachments',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                  secondary: const Icon(
                    Iconsax.attach_circle,
                    color: SpendexColors.primary,
                  ),
                  value: _includeAttachments,
                  onChanged: (value) {
                    setState(() {
                      _includeAttachments = value;
                    });
                  },
                  activeThumbColor: SpendexColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Search query
                Text(
                  'Search Query',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search in subject and body...',
                    prefixIcon: const Icon(Iconsax.search_normal),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Iconsax.close_circle),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                // Max results slider
                Text(
                  'Max Results: $_maxResults',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxResults.toDouble(),
                  min: 10,
                  max: 500,
                  divisions: 49,
                  label: _maxResults.toString(),
                  activeColor: SpendexColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _maxResults = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Apply Filters Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpendexColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Apply Filters',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
