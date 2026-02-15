import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/account_model.dart';

/// Account Card Widget
/// A beautiful card displaying account information with gradient backgrounds
class AccountCard extends StatelessWidget {
  const AccountCard({
    required this.account,
    super.key,
    this.onTap,
    this.showBalance = true,
    this.compact = false,
  });

  final AccountModel account;
  final VoidCallback? onTap;
  final bool showBalance;
  final bool compact;

  /// Build semantic label for screen readers
  String _buildSemanticLabel() {
    final parts = <String>[];
    
    parts.add(account.name);
    parts.add(account.type.label);
    
    if (account.bankName != null) {
      parts.add(account.bankName!);
    }
    
    if (showBalance) {
      final balanceLabel = account.isCreditCard ? 'Outstanding' : 'Balance';
      parts.add('$balanceLabel: ${formatCurrency(account.balanceInRupees)}');
    }
    
    if (account.isDefault) {
      parts.add('Default account');
    }
    
    if (account.isCreditCard && account.creditLimit != null) {
      parts.add('Credit limit: ${formatCurrency(account.creditLimitInRupees ?? 0)}');
      parts.add('Utilized: ${account.utilizedPercentage?.toStringAsFixed(0) ?? 0}%');
    }
    
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = getAccountTypeColor(account.type);

    if (compact) {
      return _buildCompactCard(context, isDark, color);
    }

    return Semantics(
      label: _buildSemanticLabel(),
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Account Type Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        getAccountTypeIcon(account.type),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // Default Badge
                    if (account.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.star1,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Default',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Account Name
                Text(
                  account.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Bank Name & Account Number
                Row(
                  children: [
                    if (account.bankName != null) ...[
                      Text(
                        account.bankName!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      if (account.accountNumber != null) ...[
                        Text(
                          ' • ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                    if (account.accountNumber != null)
                      Text(
                        _maskAccountNumber(account.accountNumber!),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Balance
                if (showBalance) ...[
                  Text(
                    account.isCreditCard ? 'Outstanding' : 'Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(account.balanceInRupees),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],

                // Credit Card Info
                if (account.isCreditCard && account.creditLimit != null) ...[
                  const SizedBox(height: 16),
                  _buildCreditCardInfo(),
                ],

                // Account Type Label
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    account.type.label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, bool isDark, Color color) {
    return Semantics(
      label: _buildSemanticLabel(),
      button: onTap != null,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            border: Border.all(
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  getAccountTypeIcon(account.type),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Account Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.name,
                            style: SpendexTheme.titleMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextPrimary
                                  : SpendexColors.lightTextPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (account.isDefault) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Iconsax.star1,
                            color: color,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      account.type.label,
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Balance
              if (showBalance)
                Text(
                  formatCurrency(account.balanceInRupees),
                  style: SpendexTheme.titleMedium.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 8),
              ExcludeSemantics(
                child: Icon(
                  Iconsax.arrow_right_3,
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardInfo() {
    final utilized = account.utilizedPercentage ?? 0;
    final available = account.availableCredit ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (utilized / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              utilized > 80 ? SpendexColors.expense : Colors.white.withValues(alpha: 0.8),
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 12),

        // Credit Details Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCreditInfo(
              'Limit',
              formatCurrency(account.creditLimitInRupees ?? 0),
            ),
            _buildCreditInfo(
              'Available',
              formatCurrency(available),
            ),
            _buildCreditInfo(
              'Utilized',
              '${utilized.toStringAsFixed(0)}%',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreditInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) {
      return '•••• $accountNumber';
    }
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '•••• $lastFour';
  }
}

/// Format currency in Indian format
String formatCurrency(double amount) {
  final format = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );
  return format.format(amount);
}

/// Format currency without decimals for compact display
String formatCurrencyCompact(double amount) {
  if (amount.abs() >= 10000000) {
    // Crores
    return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
  } else if (amount.abs() >= 100000) {
    // Lakhs
    return '₹${(amount / 100000).toStringAsFixed(1)}L';
  } else if (amount.abs() >= 1000) {
    // Thousands
    return '₹${(amount / 1000).toStringAsFixed(1)}K';
  } else {
    return '₹${amount.toStringAsFixed(0)}';
  }
}

/// Get icon for account type
IconData getAccountTypeIcon(AccountType type) {
  switch (type) {
    case AccountType.savings:
      return Iconsax.bank;
    case AccountType.current:
      return Iconsax.building;
    case AccountType.creditCard:
      return Iconsax.card;
    case AccountType.cash:
      return Iconsax.wallet_1;
    case AccountType.wallet:
      return Iconsax.wallet;
    case AccountType.investment:
      return Iconsax.chart;
    case AccountType.loan:
      return Iconsax.receipt_2;
    case AccountType.other:
      return Iconsax.more;
  }
}

/// Get color for account type
Color getAccountTypeColor(AccountType type) {
  switch (type) {
    case AccountType.savings:
      return SpendexColors.primary;
    case AccountType.current:
      return SpendexColors.income;
    case AccountType.creditCard:
      return SpendexColors.expense;
    case AccountType.cash:
      return SpendexColors.warning;
    case AccountType.wallet:
      return SpendexColors.transfer;
    case AccountType.investment:
      return const Color(0xFF6366F1);
    case AccountType.loan:
      return const Color(0xFFEC4899);
    case AccountType.other:
      return SpendexColors.lightTextSecondary;
  }
}
