import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../../data/models/subscription_models.dart';
import '../providers/subscription_provider.dart';
import '../widgets/widgets.dart';

/// Invoices Screen
///
/// Displays invoice history with:
/// - List of invoices with status indicators
/// - Pull-to-refresh functionality
/// - Pagination (load more on scroll)
/// - Empty state for no invoices
/// - Filter by status (optional)
/// - Download invoice action
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  static const String routeName = 'invoices';
  static const String routePath = '/subscription/invoices';

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final ScrollController _scrollController = ScrollController();
  InvoiceStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInvoices();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Load invoices
  Future<void> _loadInvoices({bool refresh = false}) async {
    if (refresh) {
      await ref.read(subscriptionProvider.notifier).refreshInvoices();
    } else {
      await ref.read(subscriptionProvider.notifier).loadInvoices();
    }
  }

  /// Handle scroll for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(subscriptionProvider);
      if (state.hasMoreInvoices && !state.isLoadingInvoices) {
        ref.read(subscriptionProvider.notifier).loadMoreInvoices();
      }
    }
  }

  /// Handle refresh
  Future<void> _onRefresh() async {
    await _loadInvoices(refresh: true);
  }

  /// Handle filter change
  void _onFilterChanged(InvoiceStatus? status) {
    setState(() {
      _selectedFilter = status;
    });
  }

  /// Download invoice
  Future<void> _downloadInvoice(InvoiceModel invoice) async {
    if (invoice.downloadUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice download not available'),
          backgroundColor: SpendexColors.warning,
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(invoice.downloadUrl ?? '');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open invoice'),
              backgroundColor: SpendexColors.expense,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  /// Get filtered invoices
  List<InvoiceModel> _getFilteredInvoices(List<InvoiceModel> invoices) {
    if (_selectedFilter == null) return invoices;
    return invoices.where((i) => i.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterSheet(isDark),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SpendexColors.primary,
        child: _buildBody(state, theme, isDark),
      ),
    );
  }

  Widget _buildBody(SubscriptionState state, ThemeData theme, bool isDark) {
    // Loading state (initial load)
    if (state.isLoadingInvoices && state.invoices.isEmpty) {
      return const LoadingStateWidget(
        message: 'Loading invoices...',
      );
    }

    // Error state
    if (state.error != null && state.invoices.isEmpty) {
      return ErrorStateWidget(
        message: state.error ?? 'Failed to load invoices',
        onRetry: _loadInvoices,
      );
    }

    // Empty state
    if (state.invoices.isEmpty) {
      return const EmptyStateWidget(
        icon: Iconsax.receipt_1,
        title: 'No Invoices Yet',
        message: 'Your invoices will appear here once you make a payment.',
      );
    }

    return _buildInvoicesList(state, isDark);
  }

  /// Build invoices list
  Widget _buildInvoicesList(SubscriptionState state, bool isDark) {
    final filteredInvoices = _getFilteredInvoices(state.invoices);
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    // Empty filtered results
    if (filteredInvoices.isEmpty && _selectedFilter != null) {
      return _buildEmptyFilteredState(isDark);
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Filter chips
        if (_selectedFilter != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: _buildActiveFilterChip(isDark),
            ),
          ),

        // Invoices list
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index < filteredInvoices.length) {
                  final invoice = filteredInvoices[index];
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: SpendexTheme.spacingMd,
                    ),
                    child: InvoiceCard(
                      invoice: invoice,
                      onDownload: () => _downloadInvoice(invoice),
                      onTap: () => _showInvoiceDetails(invoice, isDark),
                    ),
                  );
                }

                // Loading indicator for pagination
                if (state.hasMoreInvoices) {
                  return const Padding(
                    padding: EdgeInsets.all(SpendexTheme.spacingLg),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // End of list
                return Padding(
                  padding: const EdgeInsets.all(SpendexTheme.spacingLg),
                  child: Center(
                    child: Text(
                      'No more invoices',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredInvoices.length + 1,
            ),
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: SpendexTheme.spacing2xl),
        ),
      ],
    );
  }

  /// Build active filter chip
  Widget _buildActiveFilterChip(bool isDark) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingMd,
            vertical: SpendexTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: SpendexColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            border: Border.all(color: SpendexColors.primary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedFilter?.label ?? '',
                style: SpendexTheme.labelMedium.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingSm),
              GestureDetector(
                onTap: () => _onFilterChanged(null),
                child: const Icon(
                  Iconsax.close_circle5,
                  size: 16,
                  color: SpendexColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build empty filtered state
  Widget _buildEmptyFilteredState(bool isDark) {
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.filter_remove,
              size: 64,
              color: textSecondary,
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Text(
              'No ${_selectedFilter?.label ?? ''} Invoices',
              style: SpendexTheme.headlineSmall.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              'Try changing your filter',
              style: SpendexTheme.bodyMedium.copyWith(
                color: textSecondary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            TextButton(
              onPressed: () => _onFilterChanged(null),
              child: const Text('Clear Filter'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show filter bottom sheet
  void _showFilterSheet(bool isDark) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),

            // Title
            Text(
              'Filter by Status',
              style: SpendexTheme.headlineSmall.copyWith(
                color: textPrimary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),

            // Filter options
            _buildFilterOption(
              label: 'All Invoices',
              status: null,
              isDark: isDark,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildFilterOption(
              label: 'Paid',
              status: InvoiceStatus.paid,
              isDark: isDark,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildFilterOption(
              label: 'Pending',
              status: InvoiceStatus.pending,
              isDark: isDark,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildFilterOption(
              label: 'Failed',
              status: InvoiceStatus.failed,
              isDark: isDark,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildFilterOption(
              label: 'Refunded',
              status: InvoiceStatus.refunded,
              isDark: isDark,
            ),

            const SizedBox(height: SpendexTheme.spacingLg),

            // Apply button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),

            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  /// Build filter option
  Widget _buildFilterOption({
    required String label,
    required InvoiceStatus? status,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == status;
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return InkWell(
      onTap: () {
        _onFilterChanged(status);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingMd),
        decoration: BoxDecoration(
          color: isSelected
              ? SpendexColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isSelected ? SpendexColors.primary : borderColor,
          ),
        ),
        child: Row(
          children: [
            if (status != null)
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: SpendexTheme.spacingMd),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                label,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Iconsax.tick_circle5,
                color: SpendexColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Show invoice details
  void _showInvoiceDetails(InvoiceModel invoice, bool isDark) {
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final cardColor =
        isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textPrimary =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final textSecondary = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpendexTheme.spacingLg),

              // Invoice number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: SpendexTheme.headlineSmall.copyWith(
                      color: textPrimary,
                    ),
                  ),
                  _buildStatusBadge(invoice.status),
                ],
              ),

              const SizedBox(height: SpendexTheme.spacingLg),
              Divider(color: borderColor),
              const SizedBox(height: SpendexTheme.spacingMd),

              // Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow(
                      'Amount',
                      '₹${invoice.amountInRupees.toStringAsFixed(2)}',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildDetailRow(
                      'Tax',
                      '₹${invoice.taxInRupees.toStringAsFixed(2)}',
                      textPrimary,
                      textSecondary,
                    ),
                    _buildDetailRow(
                      'Total',
                      '₹${invoice.totalInRupees.toStringAsFixed(2)}',
                      textPrimary,
                      SpendexColors.primary,
                      isBold: true,
                    ),
                    const SizedBox(height: SpendexTheme.spacingMd),
                    Divider(color: borderColor),
                    const SizedBox(height: SpendexTheme.spacingMd),
                    _buildDetailRow(
                      'Due Date',
                      _formatDate(invoice.dueDate),
                      textPrimary,
                      textSecondary,
                    ),
                    if (invoice.paidAt != null)
                      _buildDetailRow(
                        'Paid On',
                        _formatDate(invoice.paidAt ?? DateTime.now()),
                        textPrimary,
                        SpendexColors.income,
                      ),
                    _buildDetailRow(
                      'Period',
                      '${_formatDate(invoice.periodStart)} - ${_formatDate(invoice.periodEnd)}',
                      textPrimary,
                      textSecondary,
                    ),
                    if (invoice.paymentMethod != null)
                      _buildDetailRow(
                        'Payment Method',
                        invoice.paymentMethod ?? '',
                        textPrimary,
                        textSecondary,
                      ),
                  ],
                ),
              ),

              // Download button
              if (invoice.downloadUrl != null)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _downloadInvoice(invoice);
                  },
                  icon: const Icon(Iconsax.document_download),
                  label: const Text('Download Invoice'),
                ),

              const SizedBox(height: SpendexTheme.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(InvoiceStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
      ),
      child: Text(
        status.label,
        style: SpendexTheme.labelMedium.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpendexTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SpendexTheme.bodyMedium.copyWith(
              color: labelColor.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: SpendexTheme.bodyMedium.copyWith(
              color: valueColor,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color
  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.paid:
        return SpendexColors.income;
      case InvoiceStatus.pending:
        return SpendexColors.warning;
      case InvoiceStatus.failed:
        return SpendexColors.expense;
      case InvoiceStatus.refunded:
        return SpendexColors.transfer;
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
