import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// A modal bottom sheet for selecting a goal color.
///
/// This widget displays a grid of predefined colors that users can select
/// for their goals. The currently selected color is highlighted with a checkmark.
class ColorPickerModal extends StatelessWidget {
  /// Creates a color picker modal.
  ///
  /// The [selectedColor] parameter indicates which color is currently selected (hex string).
  const ColorPickerModal({
    required this.selectedColor,
    super.key,
  });

  /// The currently selected color as a hex string (e.g., "10B981").
  final String selectedColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colors = <String, Color>{
      'EF4444': const Color(0xFFEF4444),
      'EC4899': const Color(0xFFEC4899),
      '8B5CF6': const Color(0xFF8B5CF6),
      '6366F1': const Color(0xFF6366F1),
      '3B82F6': const Color(0xFF3B82F6),
      '06B6D4': const Color(0xFF06B6D4),
      '14B8A6': const Color(0xFF14B8A6),
      '10B981': const Color(0xFF10B981),
      '84CC16': const Color(0xFF84CC16),
      'EAB308': const Color(0xFFEAB308),
      'F59E0B': const Color(0xFFF59E0B),
      'F97316': const Color(0xFFF97316),
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
                'Select Color',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
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
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final entry = colors.entries.elementAt(index);
              final isSelected = entry.key == selectedColor;

              return InkWell(
                onTap: () => Navigator.pop(context, entry.key),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: entry.value,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: entry.value.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: isSelected
                        ? Border.all(
                            color: Colors.white,
                            width: 3,
                          )
                        : null,
                  ),
                  child: isSelected
                      ? const Center(
                          child: Icon(
                            Iconsax.tick_circle,
                            color: Colors.white,
                            size: 24,
                          ),
                        )
                      : null,
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
