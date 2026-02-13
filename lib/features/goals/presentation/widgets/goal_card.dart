import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/goal_model.dart';
import 'goal_progress_ring.dart';

/// A reusable card widget for displaying goal information.
///
/// This widget displays goal details including:
/// - Circular progress ring with icon
/// - Goal name and completion status
/// - Current amount vs target amount
/// - Target date and days remaining (if applicable)
class GoalCard extends StatelessWidget {
  /// Creates a goal card.
  ///
  /// The [goal] parameter is required and specifies the goal to display.
  /// The [onTap] callback is triggered when the card is tapped.
  const GoalCard({
    required this.goal,
    required this.onTap,
    super.key,
  });

  /// The goal to display.
  final GoalModel goal;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  Color _getGoalColor() {
    if (goal.color != null) {
      try {
        return Color(int.parse(goal.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        return SpendexColors.primary;
      }
    }
    return SpendexColors.primary;
  }

  IconData _getGoalIcon() {
    if (goal.icon == null) {
      return Iconsax.flag;
    }

    final iconMap = {
      'home': Iconsax.home,
      'car': Iconsax.car,
      'airplane': Iconsax.airplane,
      'shopping_bag': Iconsax.shopping_bag,
      'wallet': Iconsax.wallet_3,
      'heart': Iconsax.heart,
      'gift': Iconsax.gift,
      'briefcase': Iconsax.briefcase,
      'crown': Iconsax.crown,
      'medal': Iconsax.medal,
      'money': Iconsax.money,
      'bank': Iconsax.bank,
      'safe': Iconsax.safe_home,
      'graduation': Iconsax.book,
      'flag': Iconsax.flag,
    };

    return iconMap[goal.icon] ?? Iconsax.flag;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalColor = _getGoalColor();
    final goalIcon = _getGoalIcon();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
              border: Border.all(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                GoalProgressRing(
                  progress: goal.progress / 100,
                  color: goalColor,
                  child: Icon(
                    goalIcon,
                    color: goalColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: SpendexTheme.titleMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextPrimary
                                    : SpendexColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (goal.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: SpendexColors.income
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                  SpendexTheme.radiusSm,
                                ),
                              ),
                              child: Text(
                                'Completed',
                                style: SpendexTheme.labelMedium.copyWith(
                                  color: SpendexColors.income,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.formatPaise(goal.currentAmount),
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: goalColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' / ${CurrencyFormatter.formatPaise(goal.targetAmount)}',
                            style: SpendexTheme.bodyMedium.copyWith(
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (goal.targetDate != null)
                        Row(
                          children: [
                            Icon(
                              Iconsax.calendar,
                              size: 12,
                              color: isDark
                                  ? SpendexColors.darkTextTertiary
                                  : SpendexColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTargetDate(goal.targetDate!),
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextTertiary
                                    : SpendexColors.lightTextTertiary,
                              ),
                            ),
                            if (goal.daysRemaining != null &&
                                goal.daysRemaining! > 0)
                              Text(
                                ' (${goal.daysRemaining} days)',
                                style: SpendexTheme.labelMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextTertiary
                                      : SpendexColors.lightTextTertiary,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTargetDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
