import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// A bottom sheet modal for selecting investment type.
///
/// This widget displays:
/// - Grid layout (3 columns) with all investment types
/// - Icon and type name for each option
/// - Visual selection feedback (purple accent)
/// - onTypeSelected callback
///
/// Features:
/// - Material 3 bottom sheet styling
/// - Rounded corners and proper padding
/// - Icon mapping for all investment types
/// - Dark mode support
/// - Smooth animations
class InvestmentTypePickerModal extends StatelessWidget {
  const InvestmentTypePickerModal({
    required this.onTypeSelected,
    this.selectedType,
    super.key,
  });

  final Function(InvestmentType) onTypeSelected;
  final InvestmentType? selectedType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        left: SpendexTheme.spacingLg,
        right: SpendexTheme.spacingLg,
        top: SpendexTheme.spacingMd,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpendexTheme.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Text(
            'Select Investment Type',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: SpendexTheme.spacingMd,
              mainAxisSpacing: SpendexTheme.spacingMd,
              childAspectRatio: 0.85,
            ),
            itemCount: InvestmentType.values.length,
            itemBuilder: (context, index) {
              final type = InvestmentType.values[index];
              final isSelected = selectedType == type;
              return _InvestmentTypeTile(
                type: type,
                isSelected: isSelected,
                onTap: () {
                  onTypeSelected(type);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  static Future<InvestmentType?> show(
    BuildContext context, {
    InvestmentType? selectedType,
  }) {
    return showModalBottomSheet<InvestmentType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestmentTypePickerModal(
        selectedType: selectedType,
        onTypeSelected: (type) {},
      ),
    );
  }
}

class _InvestmentTypeTile extends StatelessWidget {
  const _InvestmentTypeTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final InvestmentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;
    final textPrimary = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? SpendexColors.primary.withValues(alpha: 0.1) : backgroundColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            border: Border.all(
              color: isSelected
                  ? SpendexColors.primary
                  : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(SpendexTheme.spacingMd),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getIconForType(type),
                size: 32,
                color: isSelected ? SpendexColors.primary : textPrimary,
              ),
              const SizedBox(height: SpendexTheme.spacingSm),
              Text(
                _getShortLabel(type),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? SpendexColors.primary : textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return Iconsax.chart;
      case InvestmentType.stock:
        return Iconsax.trend_up;
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return Iconsax.bank;
      case InvestmentType.ppf:
        return Iconsax.shield_tick;
      case InvestmentType.epf:
        return Iconsax.user_tick;
      case InvestmentType.nps:
        return Iconsax.security_user;
      case InvestmentType.gold:
        return Iconsax.medal_star;
      case InvestmentType.sovereignGoldBond:
        return Iconsax.medal_star;
      case InvestmentType.realEstate:
        return Iconsax.building;
      case InvestmentType.crypto:
        return Iconsax.coin;
      case InvestmentType.sukanyaSamriddhi:
      case InvestmentType.postOffice:
      case InvestmentType.other:
        return Iconsax.wallet_money;
    }
  }

  String _getShortLabel(InvestmentType type) {
    switch (type) {
      case InvestmentType.mutualFund:
        return 'Mutual\nFund';
      case InvestmentType.stock:
        return 'Stock';
      case InvestmentType.fixedDeposit:
        return 'Fixed\nDeposit';
      case InvestmentType.recurringDeposit:
        return 'Recurring\nDeposit';
      case InvestmentType.ppf:
        return 'PPF';
      case InvestmentType.epf:
        return 'EPF';
      case InvestmentType.nps:
        return 'NPS';
      case InvestmentType.gold:
        return 'Gold';
      case InvestmentType.sovereignGoldBond:
        return 'Gold\nBond';
      case InvestmentType.realEstate:
        return 'Real\nEstate';
      case InvestmentType.crypto:
        return 'Crypto';
      case InvestmentType.sukanyaSamriddhi:
        return 'Sukanya\nSamriddhi';
      case InvestmentType.postOffice:
        return 'Post\nOffice';
      case InvestmentType.other:
        return 'Other';
    }
  }
}
