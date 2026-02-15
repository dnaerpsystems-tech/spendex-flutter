import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../providers/analytics_provider.dart';

/// Date range selector chip with preset options
class DateRangeSelector extends ConsumerWidget {
  const DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDateRangeOptions(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Iconsax.calendar,
              size: 16,
              color: SpendexColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              ref.watch(analyticsDateRangePresetProvider).label,
              style: SpendexTheme.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showDateRangeOptions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DateRangeBottomSheet(
        onPresetSelected: (preset) {
          ref.read(analyticsStateProvider.notifier).setDateRangePreset(preset);
          Navigator.pop(context);
        },
        onCustomSelected: () async {
          Navigator.pop(context);
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (range != null) {
            ref.read(analyticsStateProvider.notifier).setCustomDateRange(range);
          }
        },
      ),
    );
  }
}

/// Bottom sheet for date range presets
class DateRangeBottomSheet extends StatelessWidget {
  const DateRangeBottomSheet({
    required this.onPresetSelected,
    required this.onCustomSelected,
    super.key,
  });

  final void Function(DateRangePreset) onPresetSelected;
  final VoidCallback onCustomSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date Range',
            style: SpendexTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ...DateRangePreset.values.where((p) => p != DateRangePreset.custom).map(
                (preset) => ListTile(
                  title: Text(preset.label),
                  onTap: () => onPresetSelected(preset),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                ),
              ),
          ListTile(
            leading: const Icon(Iconsax.calendar_edit),
            title: const Text('Custom Range'),
            onTap: onCustomSelected,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
