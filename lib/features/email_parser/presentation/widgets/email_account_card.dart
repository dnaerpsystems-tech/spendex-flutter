import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../data/models/email_account_model.dart';

/// Card widget displaying connected email account with disconnect option
class EmailAccountCard extends StatelessWidget {
  const EmailAccountCard({
    required this.account,
    required this.onDisconnect,
    required this.onSelect,
    this.isSelected = false,
    super.key,
  });

  final EmailAccountModel account;
  final VoidCallback onDisconnect;
  final VoidCallback onSelect;
  final bool isSelected;

  IconData _getProviderIcon() {
    switch (account.provider) {
      case EmailProvider.gmail:
        return Iconsax.sms;
      case EmailProvider.outlook:
        return Iconsax.message;
      case EmailProvider.yahoo:
        return Iconsax.global;
      case EmailProvider.icloud:
        return Iconsax.cloud;
      case EmailProvider.other:
        return Iconsax.direct_inbox;
    }
  }

  String _getProviderName() {
    switch (account.provider) {
      case EmailProvider.gmail:
        return 'Gmail';
      case EmailProvider.outlook:
        return 'Outlook';
      case EmailProvider.yahoo:
        return 'Yahoo';
      case EmailProvider.icloud:
        return 'iCloud';
      case EmailProvider.other:
        return 'Custom';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never synced';
    return 'Last sync: ${DateFormat('dd MMM yyyy, HH:mm').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? SpendexColors.primary
              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelect,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Provider icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SpendexColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Icon(
                      _getProviderIcon(),
                      color: SpendexColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Account details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            account.email,
                            style: SpendexTheme.titleMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 8),
                          if (account.isConnected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: SpendexColors.income.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const BoxDecoration(
                                      color: SpendexColors.income,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Connected',
                                    style: SpendexTheme.labelMedium.copyWith(
                                      color: SpendexColors.income,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getProviderName(),
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(account.lastSyncDate),
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Disconnect button
                IconButton(
                  onPressed: onDisconnect,
                  icon: const Icon(
                    Iconsax.close_circle,
                    color: SpendexColors.expense,
                  ),
                  tooltip: 'Disconnect',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
