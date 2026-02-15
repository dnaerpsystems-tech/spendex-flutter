import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme.dart';
import '../providers/analytics_provider.dart';

/// Tab bar for analytics screen
class AnalyticsTabBar extends ConsumerWidget {
  const AnalyticsTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTab = ref.watch(analyticsCurrentTabProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsTab.values.map((tab) {
          final isSelected = tab == currentTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _TabChip(
              label: tab.label,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => ref.read(analyticsStateProvider.notifier).setTab(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? SpendexColors.primary
              : (isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface),
          borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? SpendexColors.primary
                : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
