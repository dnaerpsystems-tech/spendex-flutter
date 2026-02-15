import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/subscription_models.dart';

/// A card widget displaying checkout summary with price breakdown.
class CheckoutSummaryCard extends StatefulWidget {
  const CheckoutSummaryCard({
    required this.plan,
    required this.billingCycle,
    super.key,
    this.showPromoCode = false,
    this.promoDiscount,
    this.promoCode,
    this.onPromoCodeApply,
    this.onPromoCodeRemove,
    this.isPromoLoading = false,
    this.taxPercentage = 18,
  });

  final PlanModel plan;
  final BillingCycle billingCycle;
  final bool showPromoCode;
  final int? promoDiscount;
  final String? promoCode;
  final void Function(String)? onPromoCodeApply;
  final VoidCallback? onPromoCodeRemove;
  final bool isPromoLoading;
  final double taxPercentage;

  @override
  State<CheckoutSummaryCard> createState() => _CheckoutSummaryCardState();
}

class _CheckoutSummaryCardState extends State<CheckoutSummaryCard> {
  final _promoController = TextEditingController();
  bool _showPromoInput = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final basePrice = widget.billingCycle == BillingCycle.monthly
        ? widget.plan.monthlyPrice
        : widget.plan.annualPrice;
    final savings = widget.billingCycle == BillingCycle.yearly
        ? (widget.plan.monthlyPrice * 12) - widget.plan.annualPrice
        : 0;
    final subtotal = basePrice - (widget.promoDiscount ?? 0);
    final tax = (subtotal * widget.taxPercentage / 100).round();
    final total = subtotal + tax;

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: SpendexTheme.headlineSmall.copyWith(
              color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.name,
                      style: SpendexTheme.titleMedium.copyWith(
                        color:
                            isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.billingCycle == BillingCycle.monthly
                          ? 'Monthly subscription'
                          : 'Annual subscription',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹$basePrice',
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          if (savings > 0) ...[
            const SizedBox(height: SpendexTheme.spacingMd),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingMd,
                vertical: SpendexTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.income.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.discount_shape,
                    size: 14,
                    color: SpendexColors.income,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'You save ₹$savings with annual billing',
                    style: SpendexTheme.labelSmall.copyWith(
                      color: SpendexColors.income,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: SpendexTheme.spacingLg),
          Divider(
            color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          if (widget.showPromoCode) ...[
            if (widget.promoCode != null)
              _buildAppliedPromo(isDark)
            else if (_showPromoInput)
              _buildPromoInput(isDark)
            else
              _buildAddPromoButton(isDark),
            const SizedBox(height: SpendexTheme.spacingLg),
          ],
          _buildPriceRow(isDark, 'Subtotal', '₹$basePrice'),
          if (widget.promoDiscount != null && widget.promoDiscount! > 0)
            _buildPriceRow(
              isDark,
              'Promo Discount',
              '-₹${widget.promoDiscount}',
              valueColor: SpendexColors.income,
            ),
          _buildPriceRow(
            isDark,
            'GST (${widget.taxPercentage.toInt()}%)',
            '₹$tax',
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Divider(
            color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: SpendexTheme.headlineSmall.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
              ),
              Text(
                '₹$total',
                style: SpendexTheme.headlineSmall.copyWith(
                  color: SpendexColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    bool isDark,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpendexTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SpendexTheme.bodySmall.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: SpendexTheme.bodyMedium.copyWith(
              color: valueColor ??
                  (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPromoButton(bool isDark) {
    return TextButton.icon(
      onPressed: () => setState(() => _showPromoInput = true),
      icon: const Icon(Iconsax.ticket_discount, size: 18),
      label: const Text('Add Promo Code'),
      style: TextButton.styleFrom(
        foregroundColor: SpendexColors.primary,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildPromoInput(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _promoController,
            decoration: InputDecoration(
              hintText: 'Enter promo code',
              hintStyle: SpendexTheme.bodySmall.copyWith(
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingMd,
                vertical: SpendexTheme.spacingSm,
              ),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(width: SpendexTheme.spacingSm),
        ElevatedButton(
          onPressed: widget.isPromoLoading
              ? null
              : () {
                  if (_promoController.text.isNotEmpty) {
                    widget.onPromoCodeApply?.call(_promoController.text);
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: SpendexTheme.spacingLg,
            ),
          ),
          child: widget.isPromoLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildAppliedPromo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: SpendexColors.income.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(color: SpendexColors.income.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Iconsax.tick_circle5, size: 16, color: SpendexColors.income),
          const SizedBox(width: SpendexTheme.spacingSm),
          Expanded(
            child: Text(
              'Promo "${widget.promoCode}" applied',
              style: SpendexTheme.bodySmall.copyWith(
                color: SpendexColors.income,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onPromoCodeRemove,
            icon: const Icon(Iconsax.close_circle, size: 18),
            color: SpendexColors.income,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Skeleton loading widget for the checkout summary card.
class CheckoutSummaryCardSkeleton extends StatelessWidget {
  const CheckoutSummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark
        ? SpendexColors.darkBorder.withValues(alpha: 0.5)
        : SpendexColors.lightBorder.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          for (var i = 0; i < 3; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
                Container(
                  width: 50,
                  height: 14,
                  decoration: BoxDecoration(
                    color: skeletonColor,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
          ],
        ],
      ),
    );
  }
}
