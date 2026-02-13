import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// A modal bottom sheet for selecting a goal icon.
///
/// This widget displays a grid of available icons that users can select
/// for their goals. The currently selected icon is highlighted.
class IconPickerModal extends StatelessWidget {
  /// Creates an icon picker modal.
  ///
  /// The [selectedIcon] parameter indicates which icon is currently selected.
  const IconPickerModal({
    required this.selectedIcon,
    super.key,
  });

  /// The currently selected icon identifier.
  final String selectedIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final icons = <String, IconData>{
      'flag': Iconsax.flag,
      'home': Iconsax.home,
      'car': Iconsax.car,
      'airplane': Iconsax.airplane,
      'graduation': Iconsax.teacher,
      'rings': Iconsax.heart,
      'gift': Iconsax.gift,
      'piggy_bank': Iconsax.wallet,
      'medical': Iconsax.health,
      'phone': Iconsax.mobile,
      'laptop': Iconsax.monitor,
      'bicycle': Iconsax.routing,
      'camera': Iconsax.camera,
      'sport': Iconsax.activity,
      'tree': Iconsax.safe_home,
      'trophy': Iconsax.award,
    };

    return Container(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SpendexTheme.radiusXl),
          topRight: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Select Icon',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) {
              final entry = icons.entries.elementAt(index);
              final isSelected = entry.key == selectedIcon;

              return InkWell(
                onTap: () => Navigator.pop(context, entry.key),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SpendexColors.primary.withValues(alpha: 0.15)
                        : (isDark
                            ? SpendexColors.darkSurface
                            : SpendexColors.lightSurface),
                    borderRadius:
                        BorderRadius.circular(SpendexTheme.radiusMd),
                    border: Border.all(
                      color: isSelected
                          ? SpendexColors.primary
                          : (isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    entry.value,
                    color: isSelected
                        ? SpendexColors.primary
                        : (isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary),
                    size: 28,
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
