import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/subscription_models.dart';
import 'payment_method_card.dart';

/// A bottom sheet widget for selecting a payment method.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.savedMethods,
    super.key,
    this.selectedMethodId,
    this.onSelect,
    this.onAddCard,
    this.onSelectUpi,
    this.onSelectNetBanking,
    this.isLoading = false,
  });

  final List<PaymentMethodModel> savedMethods;
  final String? selectedMethodId;
  final void Function(PaymentMethodModel)? onSelect;
  final VoidCallback? onAddCard;
  final VoidCallback? onSelectUpi;
  final VoidCallback? onSelectNetBanking;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: SpendexTheme.spacingMd),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Row(
              children: [
                Text(
                  'Select Payment Method',
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color:
                        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (savedMethods.isNotEmpty) ...[
                    Text(
                      'Saved Methods',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: SpendexTheme.spacingMd),
                    ...savedMethods.map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: SpendexTheme.spacingSm,
                        ),
                        child: PaymentMethodCard(
                          paymentMethod: method,
                          isSelected: method.id == selectedMethodId,
                          onSelect: () {
                            onSelect?.call(method);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: SpendexTheme.spacingLg),
                  ],
                  Text(
                    'Other Options',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  _buildOptionTile(
                    context,
                    isDark,
                    icon: Iconsax.card_add,
                    iconColor: SpendexColors.transfer,
                    title: 'Add New Card',
                    subtitle: 'Credit or Debit Card',
                    onTap: () {
                      Navigator.of(context).pop();
                      onAddCard?.call();
                    },
                  ),
                  _buildOptionTile(
                    context,
                    isDark,
                    icon: Iconsax.mobile,
                    iconColor: SpendexColors.primary,
                    title: 'UPI',
                    subtitle: 'Google Pay, PhonePe, Paytm, etc.',
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectUpi?.call();
                    },
                  ),
                  _buildOptionTile(
                    context,
                    isDark,
                    icon: Iconsax.bank,
                    iconColor: SpendexColors.warning,
                    title: 'Net Banking',
                    subtitle: 'All major banks supported',
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectNetBanking?.call();
                    },
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              border: Border.all(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(width: SpendexTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: SpendexTheme.titleMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: SpendexTheme.bodySmall.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextTertiary
                              : SpendexColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 20,
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the payment method selector bottom sheet.
Future<void> showPaymentMethodSelector(
  BuildContext context, {
  required List<PaymentMethodModel> savedMethods,
  String? selectedMethodId,
  void Function(PaymentMethodModel)? onSelect,
  VoidCallback? onAddCard,
  VoidCallback? onSelectUpi,
  VoidCallback? onSelectNetBanking,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => PaymentMethodSelector(
        savedMethods: savedMethods,
        selectedMethodId: selectedMethodId,
        onSelect: onSelect,
        onAddCard: onAddCard,
        onSelectUpi: onSelectUpi,
        onSelectNetBanking: onSelectNetBanking,
      ),
    ),
  );
}
