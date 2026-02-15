import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/paywall_service.dart';
import '../providers/paywall_provider.dart';

/// A compact widget showing the current subscription status.
///
/// Can be placed in the app bar, navigation drawer, or settings screen
/// to show users their current plan and encourage upgrades.
class SubscriptionStatusIndicator extends ConsumerWidget {
  const SubscriptionStatusIndicator({
    super.key,
    this.showUpgradeButton = true,
    this.compact = false,
  });

  /// Whether to show the upgrade button for free/pro users.
  final bool showUpgradeButton;

  /// Whether to use compact mode (smaller text, no button).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(paywallProvider);

    if (paywallState.isLoading) {
      return _buildLoading(context);
    }

    return _buildContent(context, paywallState);
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaywallState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final plan = state.currentPlan;

    final planConfig = _getPlanConfig(plan, colorScheme);

    if (compact) {
      return _buildCompact(context, plan, planConfig);
    }

    return _buildFull(context, state, plan, planConfig);
  }

  Widget _buildCompact(
    BuildContext context,
    SubscriptionPlan plan,
    _PlanConfig config,
  ) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.subscription),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [config.color, config.color.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              plan.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    PaywallState state,
    SubscriptionPlan plan,
    _PlanConfig config,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            config.color.withValues(alpha: 0.15),
            config.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Plan badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [config.color, config.color.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(config.icon, size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      plan.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Trial badge
              if (state.isOnTrial)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${state.trialDaysRemaining} days left',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Description
          Text(
            config.description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          // Upgrade button
          if (showUpgradeButton && plan != PaywallService.planPremium) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.push(AppRoutes.subscriptionPlans),
                icon: const Icon(Iconsax.crown, size: 18),
                label: Text(plan == PaywallService.planFree ? 'Start Free Trial' : 'Upgrade'),
                style: FilledButton.styleFrom(
                  backgroundColor: config.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _PlanConfig _getPlanConfig(SubscriptionPlan plan, ColorScheme colorScheme) {
    switch (plan) {
      case PaywallService.planFree:
        return _PlanConfig(
          color: colorScheme.outline,
          icon: Iconsax.user,
          description: 'Basic features with limited accounts and budgets.',
        );
      case PaywallService.planPro:
        return _PlanConfig(
          color: colorScheme.primary,
          icon: Iconsax.star,
          description: 'All features including AI insights and receipt scanning.',
        );
      case PaywallService.planPremium:
        return const _PlanConfig(
          color: Color(0xFFDAA520), // Gold
          icon: Iconsax.crown,
          description: 'Unlimited everything with family sharing and priority support.',
        );
      default:
        return _PlanConfig(
          color: colorScheme.outline,
          icon: Iconsax.user,
          description: 'Basic features with limited accounts and budgets.',
        );
    }
  }
}

class _PlanConfig {
  const _PlanConfig({
    required this.color,
    required this.icon,
    required this.description,
  });
  final Color color;
  final IconData icon;
  final String description;
}

/// A small badge showing just the plan name.
///
/// Useful for placing in the app bar or next to user profile.
class SubscriptionPlanBadge extends ConsumerWidget {
  const SubscriptionPlanBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paywallState = ref.watch(paywallProvider);

    if (paywallState.isLoading) {
      return const SizedBox.shrink();
    }

    final plan = paywallState.currentPlan;
    final color = _getColor(plan, Theme.of(context).colorScheme);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.subscription),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          plan.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Color _getColor(SubscriptionPlan plan, ColorScheme colorScheme) {
    switch (plan) {
      case PaywallService.planFree:
        return colorScheme.outline;
      case PaywallService.planPro:
        return colorScheme.primary;
      case PaywallService.planPremium:
        return const Color(0xFFDAA520);
      default:
        return colorScheme.outline;
    }
  }
}

/// A list tile version for settings/profile screens.
class SubscriptionListTile extends ConsumerWidget {
  const SubscriptionListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final paywallState = ref.watch(paywallProvider);

    final plan = paywallState.currentPlan;
    final isLoading = paywallState.isLoading;

    return ListTile(
      onTap: () => context.push(AppRoutes.subscription),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _getColor(plan, colorScheme).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getIcon(plan),
          color: _getColor(plan, colorScheme),
        ),
      ),
      title: const Text('Subscription'),
      subtitle: isLoading
          ? const Text('Loading...')
          : Text(
              paywallState.isOnTrial
                  ? '${plan.name} (${paywallState.trialDaysRemaining} days trial)'
                  : plan.name,
            ),
      trailing: plan != PaywallService.planPremium
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Upgrade',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.chevron_right),
    );
  }

  Color _getColor(SubscriptionPlan plan, ColorScheme colorScheme) {
    switch (plan) {
      case PaywallService.planFree:
        return colorScheme.outline;
      case PaywallService.planPro:
        return colorScheme.primary;
      case PaywallService.planPremium:
        return const Color(0xFFDAA520);
      default:
        return colorScheme.outline;
    }
  }

  IconData _getIcon(SubscriptionPlan plan) {
    switch (plan) {
      case PaywallService.planFree:
        return Iconsax.user;
      case PaywallService.planPro:
        return Iconsax.star;
      case PaywallService.planPremium:
        return Iconsax.crown;
      default:
        return Iconsax.user;
    }
  }
}
