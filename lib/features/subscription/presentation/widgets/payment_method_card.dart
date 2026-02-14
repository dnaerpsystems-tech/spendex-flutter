import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/subscription_models.dart';

/// A card widget displaying a saved payment method.
class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    required this.paymentMethod,
    super.key,
    this.isSelected = false,
    this.onSelect,
    this.onRemove,
  });

  final PaymentMethodModel paymentMethod;
  final bool isSelected;
  final VoidCallback? onSelect;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? SpendexColors.primary
                  : isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildIcon(isDark),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getDisplayName(),
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                        if (paymentMethod.isDefault) ...[
                          const SizedBox(width: SpendexTheme.spacingSm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: SpendexColors.primary.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(SpendexTheme.radiusSm),
                            ),
                            child: Text(
                              'Default',
                              style: SpendexTheme.labelSmall.copyWith(
                                color: SpendexColors.primary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getSubtitle(),
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Iconsax.tick_circle5,
                  color: SpendexColors.primary,
                  size: 24,
                )
              else if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Iconsax.trash,
                    size: 20,
                    color: isDark
                        ? SpendexColors.darkTextTertiary
                        : SpendexColors.lightTextTertiary,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    IconData iconData;
    Color iconColor;

    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        iconData = Iconsax.card;
        iconColor = SpendexColors.transfer;
        break;
      case PaymentMethodType.upi:
        iconData = Iconsax.mobile;
        iconColor = SpendexColors.primary;
        break;
      case PaymentMethodType.netBanking:
        iconData = Iconsax.bank;
        iconColor = SpendexColors.warning;
        break;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      ),
      child: Icon(iconData, size: 24, color: iconColor),
    );
  }

  String _getDisplayName() {
    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        final brand = paymentMethod.cardBrand ?? 'Card';
        final last4 = paymentMethod.last4 ?? '****';
        return '$brand •••• $last4';
      case PaymentMethodType.upi:
        return paymentMethod.upiVpa ?? 'UPI';
      case PaymentMethodType.netBanking:
        return paymentMethod.bankName ?? 'Net Banking';
    }
  }

  String _getSubtitle() {
    switch (paymentMethod.type) {
      case PaymentMethodType.card:
        if (paymentMethod.expiryMonth != null &&
            paymentMethod.expiryYear != null) {
          return 'Expires ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}';
        }
        return 'Credit/Debit Card';
      case PaymentMethodType.upi:
        return 'UPI Payment';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
    }
  }
}

/// Skeleton loading widget for the payment method card.
class PaymentMethodCardSkeleton extends StatelessWidget {
  const PaymentMethodCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? SpendexColors.darkBorder.withOpacity(0.5)
        : SpendexColors.lightBorder.withOpacity(0.5);

    return Container(
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
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 16,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
