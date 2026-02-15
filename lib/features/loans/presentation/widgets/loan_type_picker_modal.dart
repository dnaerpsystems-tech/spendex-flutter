import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

class LoanTypePickerModal extends StatelessWidget {
  const LoanTypePickerModal({this.selectedType, super.key});

  final LoanType? selectedType;

  IconData _getLoanTypeIcon(LoanType type) {
    switch (type) {
      case LoanType.home:
        return Iconsax.home;
      case LoanType.vehicle:
        return Iconsax.car;
      case LoanType.personal:
        return Iconsax.wallet_money;
      case LoanType.education:
        return Iconsax.book;
      case LoanType.gold:
        return Iconsax.medal_star;
      case LoanType.business:
        return Iconsax.brifecase_tick;
      case LoanType.other:
        return Iconsax.receipt_item;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Loan Type',
                  style: SpendexTheme.titleMedium.copyWith(
                    fontSize: 20,
                    color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () => Navigator.of(context).pop(),
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: LoanType.values.length,
            itemBuilder: (context, index) {
              final type = LoanType.values[index];
              final isSelected = selectedType == type;

              return InkWell(
                onTap: () => Navigator.of(context).pop(type),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7C3AED).withValues(alpha: 0.12)
                        : (isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF7C3AED)
                          : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getLoanTypeIcon(type),
                        color: isSelected
                            ? const Color(0xFF7C3AED)
                            : (isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.label,
                        style: SpendexTheme.labelMedium.copyWith(
                          fontSize: 12,
                          color: isSelected
                              ? const Color(0xFF7C3AED)
                              : (isDark
                                  ? SpendexColors.darkTextPrimary
                                  : SpendexColors.lightTextPrimary),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
