import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/account_model.dart';
import '../providers/accounts_provider.dart';
import '../widgets/account_card.dart';

/// Account Details Screen
/// Shows detailed account information with edit and delete options
class AccountDetailsScreen extends ConsumerStatefulWidget {
  final String accountId;

  const AccountDetailsScreen({
    super.key,
    required this.accountId,
  });

  @override
  ConsumerState<AccountDetailsScreen> createState() =>
      _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    await ref.read(accountsStateProvider.notifier).getAccountById(widget.accountId);
  }

  Future<void> _handleDelete() async {
    final account = ref.read(selectedAccountProvider);
    if (account == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.name}"?\n\n'
          'This action cannot be undone. All associated transactions will be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(accountsStateProvider.notifier)
          .deleteAccount(widget.accountId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account deleted successfully'),
            backgroundColor: SpendexColors.primary,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      } else if (mounted) {
        final error = ref.read(accountsStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete account'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsState = ref.watch(accountsStateProvider);
    final account = ref.watch(selectedAccountProvider);
    final isDeleting = accountsState.isDeleting;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(account?.name ?? 'Account Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (account != null) ...[
            IconButton(
              icon: const Icon(Iconsax.edit_2),
              onPressed: () {
                // Navigate to edit screen with account ID
                context.push('/accounts/add?id=${widget.accountId}');
              },
              tooltip: 'Edit',
            ),
            IconButton(
              icon: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Iconsax.trash),
              onPressed: isDeleting ? null : _handleDelete,
              tooltip: 'Delete',
            ),
          ],
        ],
      ),
      body: _buildBody(isDark, account, accountsState),
    );
  }

  Widget _buildBody(bool isDark, AccountModel? account, AccountsState state) {
    if (state.isLoading && account == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && account == null) {
      return _buildErrorState(state.error!);
    }

    if (account == null) {
      return _buildNotFoundState();
    }

    return RefreshIndicator(
      onRefresh: _loadAccount,
      color: SpendexColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Card
            AccountCard(
              account: account,
              showBalance: true,
            ),

            const SizedBox(height: 24),

            // Account Information Section
            _buildSectionTitle('Account Information', isDark),
            const SizedBox(height: 12),
            _buildInfoCard(isDark, account),

            // Credit Card Details (if applicable)
            if (account.isCreditCard && account.creditLimit != null) ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Credit Details', isDark),
              const SizedBox(height: 12),
              _buildCreditDetailsCard(isDark, account),
            ],

            const SizedBox(height: 24),

            // Quick Actions
            _buildSectionTitle('Quick Actions', isDark),
            const SizedBox(height: 12),
            _buildQuickActions(isDark, account),

            const SizedBox(height: 24),

            // Recent Transactions Section (placeholder)
            _buildSectionTitle('Recent Transactions', isDark),
            const SizedBox(height: 12),
            _buildTransactionsPlaceholder(isDark),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: SpendexTheme.titleMedium.copyWith(
        color: isDark
            ? SpendexColors.darkTextPrimary
            : SpendexColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, AccountModel account) {
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
        children: [
          _buildInfoRow(
            isDark,
            'Account Type',
            account.type.label,
            getAccountTypeIcon(account.type),
            getAccountTypeColor(account.type),
          ),
          if (account.bankName != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              isDark,
              'Bank Name',
              account.bankName!,
              Iconsax.building,
              null,
            ),
          ],
          if (account.accountNumber != null) ...[
            const Divider(height: 24),
            _buildInfoRow(
              isDark,
              'Account Number',
              _maskAccountNumber(account.accountNumber!),
              Iconsax.card,
              null,
            ),
          ],
          const Divider(height: 24),
          _buildInfoRow(
            isDark,
            'Currency',
            account.currency,
            Iconsax.money,
            null,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            isDark,
            'Status',
            account.isActive ? 'Active' : 'Inactive',
            account.isActive ? Iconsax.tick_circle : Iconsax.close_circle,
            account.isActive ? SpendexColors.income : SpendexColors.expense,
          ),
          if (account.isDefault) ...[
            const Divider(height: 24),
            _buildInfoRow(
              isDark,
              'Default Account',
              'Yes',
              Iconsax.star1,
              SpendexColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color? iconColor,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? SpendexColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? SpendexColors.primary,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: SpendexTheme.titleMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCreditDetailsCard(bool isDark, AccountModel account) {
    final utilized = account.utilizedPercentage ?? 0;
    final available = account.availableCredit ?? 0;
    final limit = account.creditLimitInRupees ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF59E0B),
            const Color(0xFFF59E0B).withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Credit Utilization',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${utilized.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: utilized > 80 ? SpendexColors.expense : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (utilized / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                utilized > 80 ? SpendexColors.expense : Colors.white,
              ),
              minHeight: 10,
            ),
          ),

          const SizedBox(height: 20),

          // Details Row
          Row(
            children: [
              Expanded(
                child: _buildCreditDetailItem(
                  'Credit Limit',
                  formatCurrency(limit),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCreditDetailItem(
                  'Outstanding',
                  formatCurrency(account.balanceInRupees),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildCreditDetailItem(
                  'Available',
                  formatCurrency(available),
                ),
              ),
            ],
          ),

          // Warning if utilization is high
          if (utilized > 80) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.warning_2,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'High credit utilization may affect your credit score',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
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

  Widget _buildCreditDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark, AccountModel account) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            isDark,
            icon: Iconsax.arrow_swap_horizontal,
            label: 'Transfer',
            color: SpendexColors.transfer,
            onTap: () {
              // Navigate to transfer screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Transfer feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            isDark,
            icon: Iconsax.add,
            label: 'Add Transaction',
            color: SpendexColors.primary,
            onTap: () {
              context.push(AppRoutes.addTransaction);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            isDark,
            icon: Iconsax.chart,
            label: 'Analytics',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              // Navigate to analytics
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Analytics feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    bool isDark, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsPlaceholder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Iconsax.receipt_2,
              color: SpendexColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions for this account will appear here',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addTransaction),
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: SpendexColors.expense,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load account',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAccount,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Iconsax.search_status,
                color: SpendexColors.warning,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Account Not Found',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The account you\'re looking for doesn\'t exist or has been deleted.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
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

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return '•••• $accountNumber';
    }
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• •••• •••• $lastFour';
  }
}
