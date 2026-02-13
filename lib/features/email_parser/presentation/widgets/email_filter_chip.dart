import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Active filter chip with remove action
class EmailFilterChip extends StatelessWidget {
  const EmailFilterChip({
    required this.label,
    required this.onRemove,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onRemove;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SpendexColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: SpendexColors.primary,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Iconsax.close_circle,
              size: 16,
              color: SpendexColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
