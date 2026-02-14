import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// A card widget displaying feature usage with a progress bar.
///
/// Color-coded indicators: Green (<50%), Yellow (50-80%), Red (>80%)
class UsageProgressCard extends StatelessWidget {
  const UsageProgressCard({
    required this.featureName,
    required this.icon,
    required this.currentUsage,
    required this.limit,
    super.key,
    this.subtitle,
    this.onTap,
  });

  final String featureName;
  final IconData icon;
  final int currentUsage;
  final int limit;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUnlimited = limit == -1;
    final percentage =
        isUnlimited ? 0.0 : (currentUsage / limit).clamp(0.0, 1.0);
    final progressColor = _getProgressColor(percentage);

    return Material(
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
              color: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusSm),
                    ),
                    child: Icon(icon, size: 20, color: progressColor),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          featureName,
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle ?? '',
                            style: SpendexTheme.bodySmall.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextTertiary
                                  : SpendexColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (isUnlimited)
                        Row(
                          children: [
                            const Icon(
                              Iconsax.unlimited,
                              size: 16,
                              color: SpendexColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Unlimited',
                              style: SpendexTheme.titleMedium.copyWith(
                                color: SpendexColors.primary,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          '$currentUsage / $limit',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (!isUnlimited) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${(percentage * 100).toInt()}% used',
                          style: SpendexTheme.labelSmall.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (!isUnlimited) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                _buildProgressBar(isDark, percentage, progressColor),
              ],
              if (!isUnlimited && percentage >= 0.8) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                _buildWarningMessage(isDark, percentage),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(bool isDark, double percentage, Color color) {
    return Stack(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color:
                isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningMessage(bool isDark, double percentage) {
    final isOverLimit = percentage >= 1.0;
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: (isOverLimit ? SpendexColors.expense : SpendexColors.warning)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: (isOverLimit ? SpendexColors.expense : SpendexColors.warning)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOverLimit ? Iconsax.warning_2 : Iconsax.info_circle,
            size: 16,
            color: isOverLimit ? SpendexColors.expense : SpendexColors.warning,
          ),
          const SizedBox(width: SpendexTheme.spacingSm),
          Expanded(
            child: Text(
              isOverLimit
                  ? 'Limit reached. Upgrade to continue.'
                  : 'Approaching limit. Consider upgrading.',
              style: SpendexTheme.bodySmall.copyWith(
                color:
                    isOverLimit ? SpendexColors.expense : SpendexColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 0.8) return SpendexColors.expense;
    if (percentage >= 0.5) return SpendexColors.warning;
    return SpendexColors.income;
  }
}

/// Skeleton loading widget for the usage progress card.
class UsageProgressCardSkeleton extends StatelessWidget {
  const UsageProgressCardSkeleton({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
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
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: skeletonColor,
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusSm),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: skeletonColor,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: skeletonColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            ),
          ),
        ],
      ),
    );
  }
}
