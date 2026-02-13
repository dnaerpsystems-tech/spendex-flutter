import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/imported_statement_model.dart';
import '../providers/pdf_import_provider.dart';
import '../widgets/empty_import_state.dart';
import '../widgets/import_history_card.dart';

/// Import History Screen
/// Displays all import history with filtering and search
class ImportHistoryScreen extends ConsumerStatefulWidget {
  const ImportHistoryScreen({super.key});

  @override
  ConsumerState<ImportHistoryScreen> createState() =>
      _ImportHistoryScreenState();
}

class _ImportHistoryScreenState extends ConsumerState<ImportHistoryScreen> {
  ImportStatus? _selectedStatus;
  FileType? _selectedFileType;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load import history on init
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ref.read(pdfImportProvider.notifier).loadImportHistory();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(pdfImportProvider.notifier).loadImportHistory();
  }

  void _navigateToImportPreview(String importId) {
    context.push('/bank-import/preview/$importId');
  }

  Future<void> _deleteImport(String importId) async {
    final success =
        await ref.read(pdfImportProvider.notifier).deleteImport(importId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import deleted successfully'),
          backgroundColor: SpendexColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = ref.read(pdfImportProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to delete import'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedStatus: _selectedStatus,
        selectedFileType: _selectedFileType,
        onApply: (status, fileType) {
          setState(() {
            _selectedStatus = status;
            _selectedFileType = fileType;
          });
        },
      ),
    );
  }

  List<ImportedStatementModel> _filterImports(
    List<ImportedStatementModel> imports,
  ) {
    var filtered = imports;

    // Filter by status
    if (_selectedStatus != null) {
      filtered =
          filtered.where((i) => i.status == _selectedStatus).toList();
    }

    // Filter by file type
    if (_selectedFileType != null) {
      filtered =
          filtered.where((i) => i.fileType == _selectedFileType).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (i) => i.fileName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final importState = ref.watch(pdfImportProvider);
    final filteredImports = _filterImports(importState.importHistory);

    final hasActiveFilters =
        _selectedStatus != null || _selectedFileType != null;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Import History'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: Icon(
                Iconsax.filter,
                color: hasActiveFilters
                    ? SpendexColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by file name...',
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Iconsax.close_circle,
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: SpendexColors.primary,
                  ),
                ),
              ),
            ),
          ),

          // Active filters chips
          if (hasActiveFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedStatus != null)
                    Chip(
                      label: Text(_getStatusLabel(_selectedStatus!)),
                      onDeleted: () {
                        setState(() {
                          _selectedStatus = null;
                        });
                      },
                      deleteIcon: const Icon(
                        Iconsax.close_circle,
                        size: 16,
                      ),
                    ),
                  if (_selectedFileType != null)
                    Chip(
                      label: Text(_getFileTypeLabel(_selectedFileType!)),
                      onDeleted: () {
                        setState(() {
                          _selectedFileType = null;
                        });
                      },
                      deleteIcon: const Icon(
                        Iconsax.close_circle,
                        size: 16,
                      ),
                    ),
                ],
              ),
            ),

          // Import list
          Expanded(
            child: importState.isLoading
                ? const Center(child: ShimmerLoadingList())
                : importState.error != null
                    ? ErrorStateWidget(
                        message: importState.error!,
                        onRetry: _onRefresh,
                      )
                    : filteredImports.isEmpty
                        ? _searchQuery.isNotEmpty || hasActiveFilters
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Iconsax.search_normal,
                                        size: 56,
                                        color: SpendexColors.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No imports found',
                                        style:
                                            SpendexTheme.titleMedium.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your filters or search query',
                                        style:
                                            SpendexTheme.bodyMedium.copyWith(
                                          color: isDark
                                              ? SpendexColors.darkTextSecondary
                                              : SpendexColors
                                                  .lightTextSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const NoImportsEmptyState()
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: filteredImports.length,
                              itemBuilder: (context, index) {
                                final import = filteredImports[index];
                                return ImportHistoryCard(
                                  import: import,
                                  onTap: () =>
                                      _navigateToImportPreview(import.id),
                                  onDelete: () => _deleteImport(import.id),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(ImportStatus status) {
    switch (status) {
      case ImportStatus.completed:
        return 'Completed';
      case ImportStatus.failed:
        return 'Failed';
      case ImportStatus.processing:
        return 'Processing';
      case ImportStatus.pending:
        return 'Pending';
    }
  }

  String _getFileTypeLabel(FileType type) {
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.csv:
        return 'CSV';
    }
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.selectedStatus,
    required this.selectedFileType,
    required this.onApply,
  });

  final ImportStatus? selectedStatus;
  final FileType? selectedFileType;
  final void Function(ImportStatus?, FileType?) onApply;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  ImportStatus? _tempStatus;
  FileType? _tempFileType;

  @override
  void initState() {
    super.initState();
    _tempStatus = widget.selectedStatus;
    _tempFileType = widget.selectedFileType;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkBackground
            : SpendexColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Imports',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempFileType = null;
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.expense,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Status filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ImportStatus.values.map((status) {
                      final isSelected = _tempStatus == status;
                      return ChoiceChip(
                        label: Text(_getStatusLabel(status)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _tempStatus = selected ? status : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // File type filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File Type',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: FileType.values.map((type) {
                      final isSelected = _tempFileType == type;
                      return ChoiceChip(
                        label: Text(_getFileTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _tempFileType = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Apply button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_tempStatus, _tempFileType);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpendexColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(ImportStatus status) {
    switch (status) {
      case ImportStatus.completed:
        return 'Completed';
      case ImportStatus.failed:
        return 'Failed';
      case ImportStatus.processing:
        return 'Processing';
      case ImportStatus.pending:
        return 'Pending';
    }
  }

  String _getFileTypeLabel(FileType type) {
    switch (type) {
      case FileType.pdf:
        return 'PDF';
      case FileType.csv:
        return 'CSV';
    }
  }
}
