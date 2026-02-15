import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';

/// Transaction Details Screen
/// Displays detailed transaction information with edit and delete functionality
class TransactionDetailsScreen extends ConsumerStatefulWidget {
  const TransactionDetailsScreen({
    required this.transactionId,
    super.key,
  });

  final String transactionId;

  @override
  ConsumerState<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends ConsumerState<TransactionDetailsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransaction();
    });
  }

  Future<void> _loadTransaction() async {
    await ref.read(transactionsStateProvider.notifier).getTransactionById(widget.transactionId);
  }

  Future<void> _refresh() async {
    await _loadTransaction();
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
      case TransactionType.transfer:
        return SpendexColors.transfer;
    }
  }

  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Iconsax.arrow_down;
      case TransactionType.expense:
        return Iconsax.arrow_up;
      case TransactionType.transfer:
        return Iconsax.arrow_swap_horizontal;
    }
  }

  String _getAmountPrefix(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '+';
      case TransactionType.expense:
        return '-';
      case TransactionType.transfer:
        return '';
    }
  }

  void _navigateToEdit(TransactionModel transaction) {
    // Navigate to add transaction screen with transaction ID for editing
    context.push('${AppRoutes.addTransaction}?id=${transaction.id}');
  }

  void _showDeleteConfirmation(TransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getTypeColor(transaction.type);
    final amountStr = _currencyFormat.format(transaction.amountInRupees);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.trash,
                color: SpendexColors.expense,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Transaction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this transaction?',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(transaction.type),
                      color: typeColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.description ?? transaction.type.label,
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${_getAmountPrefix(transaction.type)}$amountStr',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: SpendexTheme.labelMedium.copyWith(
                color: SpendexColors.expense,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleDelete(transaction.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: SpendexColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(String transactionId) async {
    Navigator.pop(context); // Close dialog

    final success =
        await ref.read(transactionsStateProvider.notifier).deleteTransaction(transactionId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(transactionsStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete transaction'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactionsState = ref.watch(transactionsStateProvider);
    final transaction = transactionsState.selectedTransaction;
    final isDeleting = transactionsState.isDeleting;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (transaction != null) ...[
            PopupMenuButton<String>(
              icon: const Icon(Iconsax.more),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _navigateToEdit(transaction);
                    break;
                  case 'delete':
                    _showDeleteConfirmation(transaction);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.edit_2,
                        size: 20,
                        color:
                            isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Edit',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Iconsax.trash,
                        size: 20,
                        color: SpendexColors.expense,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete',
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: SpendexColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _buildBody(
        isDark: isDark,
        isLoading: transactionsState.isLoading && transaction == null,
        isDeleting: isDeleting,
        error: transactionsState.error,
        transaction: transaction,
      ),
    );
  }

  Widget _buildBody({
    required bool isDark,
    required bool isLoading,
    required bool isDeleting,
    required String? error,
    required TransactionModel? transaction,
  }) {
    // Show loading state
    if (isLoading) {
      return _buildLoadingState(isDark);
    }

    // Show error state
    if (error != null && transaction == null) {
      return _buildErrorState(isDark, error);
    }

    // Show not found state
    if (transaction == null) {
      return _buildNotFoundState(isDark);
    }

    // Show transaction details
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refresh,
          color: SpendexColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount Header Card
                _buildAmountCard(transaction, isDark),
                const SizedBox(height: 24),

                // Transaction Details Card
                _buildDetailsCard(transaction, isDark),
                const SizedBox(height: 16),

                // Account Information Card
                _buildAccountCard(transaction, isDark),

                // Notes Card (if available)
                if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildNotesCard(transaction, isDark),
                ],

                // Tags Card (if available)
                if (transaction.tags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildTagsCard(transaction, isDark),
                ],

                // Metadata Card
                const SizedBox(height: 16),
                _buildMetadataCard(transaction, isDark),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Loading overlay for delete operation
        if (isDeleting)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(
                color: SpendexColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Amount skeleton
          _buildSkeletonCard(
            isDark: isDark,
            height: 160,
          ),
          const SizedBox(height: 24),

          // Details skeleton
          _buildSkeletonCard(
            isDark: isDark,
            height: 200,
          ),
          const SizedBox(height: 16),

          // Account skeleton
          _buildSkeletonCard(
            isDark: isDark,
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({
    required bool isDark,
    required double height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 40,
                color: SpendexColors.expense,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Transaction',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransaction,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Iconsax.document_text,
                size: 40,
                color: SpendexColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction Not Found',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The transaction you are looking for does not exist or has been deleted.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Iconsax.arrow_left),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(TransactionModel transaction, bool isDark) {
    final typeColor = _getTypeColor(transaction.type);
    final amountPrefix = _getAmountPrefix(transaction.type);
    final amountStr = _currencyFormat.format(transaction.amountInRupees);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor,
            typeColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: typeColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Type Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              _getTypeIcon(transaction.type),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          Text(
            '$amountPrefix$amountStr',
            style: SpendexTheme.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              transaction.type.label,
              style: SpendexTheme.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(transaction.date),
            style: SpendexTheme.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(TransactionModel transaction, bool isDark) {
    final typeColor = _getTypeColor(transaction.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            'Details',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          _buildDetailRow(
            isDark: isDark,
            icon: Iconsax.document_text,
            iconColor: typeColor,
            label: 'Description',
            value: transaction.description ?? 'No description',
          ),

          // Category (for non-transfers)
          if (!transaction.isTransfer && transaction.category != null) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              isDark: isDark,
              icon: _getCategoryIcon(transaction.category?.icon),
              iconColor: _getCategoryColor(transaction.category?.color),
              label: 'Category',
              value: transaction.category!.name,
            ),
          ],

          // Payee (if available)
          if (transaction.payee != null && transaction.payee!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
              isDark: isDark,
              icon: Iconsax.user,
              iconColor: SpendexColors.primary,
              label: 'Payee',
              value: transaction.payee!,
            ),
          ],

          // Time
          const SizedBox(height: 16),
          _buildDetailRow(
            isDark: isDark,
            icon: Iconsax.clock,
            iconColor: SpendexColors.primary,
            label: 'Time',
            value: DateFormat('hh:mm a').format(transaction.date),
          ),

          // Recurring Badge
          if (transaction.isRecurring) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.repeat,
                    size: 16,
                    color: SpendexColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recurring Transaction',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountCard(TransactionModel transaction, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Text(
            transaction.isTransfer ? 'Transfer Details' : 'Account',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (transaction.isTransfer) ...[
            // Transfer: From Account
            _buildAccountRow(
              isDark: isDark,
              label: 'From',
              accountName: transaction.account?.name ?? 'Unknown Account',
              accountType: transaction.account?.type.label ?? '',
              accountIcon: _getAccountIcon(transaction.account?.icon),
              accountColor: _getAccountColor(transaction.account?.color),
            ),
            const SizedBox(height: 12),

            // Arrow
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: SpendexColors.transfer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.arrow_down,
                  color: SpendexColors.transfer,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Transfer: To Account
            _buildAccountRow(
              isDark: isDark,
              label: 'To',
              accountName: transaction.toAccount?.name ?? 'Unknown Account',
              accountType: transaction.toAccount?.type.label ?? '',
              accountIcon: _getAccountIcon(transaction.toAccount?.icon),
              accountColor: _getAccountColor(transaction.toAccount?.color),
            ),
          ] else ...[
            // Regular transaction: Single account
            _buildAccountRow(
              isDark: isDark,
              label: 'Account',
              accountName: transaction.account?.name ?? 'Unknown Account',
              accountType: transaction.account?.type.label ?? '',
              accountIcon: _getAccountIcon(transaction.account?.icon),
              accountColor: _getAccountColor(transaction.account?.color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountRow({
    required bool isDark,
    required String label,
    required String accountName,
    required String accountType,
    required IconData accountIcon,
    required Color accountColor,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accountColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            accountIcon,
            color: accountColor,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SpendexTheme.labelMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                ),
              ),
              Text(
                accountName,
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
              if (accountType.isNotEmpty)
                Text(
                  accountType,
                  style: SpendexTheme.labelMedium.copyWith(
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(TransactionModel transaction, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.note_text,
                size: 20,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            transaction.notes!,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard(TransactionModel transaction, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.tag,
                size: 20,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                'Tags',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: transaction.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SpendexColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '#$tag',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: SpendexColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(TransactionModel transaction, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Info',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetadataRow(
            isDark: isDark,
            label: 'Transaction ID',
            value: transaction.id.length > 12
                ? '${transaction.id.substring(0, 12)}...'
                : transaction.id,
            onTap: () {
              Clipboard.setData(ClipboardData(text: transaction.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transaction ID copied'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildMetadataRow(
            isDark: isDark,
            label: 'Created',
            value: DateFormat('MMM d, yyyy - hh:mm a').format(transaction.createdAt),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow(
            isDark: isDark,
            label: 'Last Updated',
            value: DateFormat('MMM d, yyyy - hh:mm a').format(transaction.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: SpendexTheme.labelMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                ),
              ),
              Text(
                value,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow({
    required bool isDark,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: SpendexTheme.bodyMedium.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.copy,
                    size: 14,
                    color:
                        isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(String? iconName) {
    // Map category icon names to IconData
    final iconMap = <String, IconData>{
      'shopping': Iconsax.shopping_cart,
      'food': Iconsax.reserve,
      'transport': Iconsax.car,
      'entertainment': Iconsax.game,
      'health': Iconsax.health,
      'education': Iconsax.book,
      'bills': Iconsax.receipt,
      'salary': Iconsax.money_recive,
      'business': Iconsax.briefcase,
      'investment': Iconsax.chart_2,
      'gift': Iconsax.gift,
      'other': Iconsax.category,
    };
    return iconMap[iconName?.toLowerCase()] ?? Iconsax.category;
  }

  Color _getCategoryColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return SpendexColors.primary;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return SpendexColors.primary;
    }
  }

  IconData _getAccountIcon(String? iconName) {
    // Map account icon names to IconData
    final iconMap = <String, IconData>{
      'bank': Iconsax.bank,
      'cash': Iconsax.wallet_money,
      'card': Iconsax.card,
      'wallet': Iconsax.wallet,
      'savings': Iconsax.safe_home,
      'credit_card': Iconsax.card,
      'investment': Iconsax.chart_2,
    };
    return iconMap[iconName?.toLowerCase()] ?? Iconsax.wallet;
  }

  Color _getAccountColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return SpendexColors.primary;
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return SpendexColors.primary;
    }
  }
}
