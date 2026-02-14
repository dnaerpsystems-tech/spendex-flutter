import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax/iconsax.dart";
import "../../../../app/routes.dart";
import "../../../../core/services/paywall_service.dart";
import "../providers/paywall_provider.dart";

/// A banner that shows when a premium feature is being used by free users.
///
/// Displays a subtle upgrade prompt while still allowing limited access.
class FeatureGateBanner extends ConsumerWidget {
  const FeatureGateBanner({
    super.key,
    required this.feature,
    this.title,
    this.description,
    this.showWhenAllowed = false,
  });

  /// The feature being gated.
  final GatedFeature feature;

  /// Custom title for the banner.
  final String? title;

  /// Custom description for the banner.
  final String? description;

  /// Whether to show even when feature is allowed (for trial reminders).
  final bool showWhenAllowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureGateAsync = ref.watch(featureGateProvider(feature));

    return featureGateAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (gateResult) {
        if (gateResult.isAllowed && !showWhenAllowed) {
          return const SizedBox.shrink();
        }

        final paywallState = ref.watch(paywallProvider);
        
        // Show trial reminder for allowed features
        if (gateResult.isAllowed && paywallState.isOnTrial) {
          return _buildTrialBanner(context, paywallState);
        }

        // Show upgrade banner for blocked features
        if (!gateResult.isAllowed) {
          return _buildUpgradeBanner(context, gateResult);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTrialBanner(BuildContext context, PaywallState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiaryContainer,
            colorScheme.tertiaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.timer_1,
              color: colorScheme.tertiary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Trial ends in ${state.trialDaysRemaining} days",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Subscribe to keep access to premium features",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.subscriptionPlans),
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, FeatureGateResult gateResult) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final planName = gateResult.requiredPlan?.name ?? "Pro";

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.crown,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? "$planName Feature",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description ?? "Upgrade to $planName to unlock this feature",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => context.push(AppRoutes.subscriptionPlans),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }
}

/// A sliver version of the feature gate banner for use in CustomScrollView.
class SliverFeatureGateBanner extends StatelessWidget {
  const SliverFeatureGateBanner({
    super.key,
    required this.feature,
    this.title,
    this.description,
  });

  final GatedFeature feature;
  final String? title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FeatureGateBanner(
        feature: feature,
        title: title,
        description: description,
      ),
    );
  }
}

/// A locked feature overlay that shows when a feature is completely blocked.
class LockedFeatureOverlay extends ConsumerWidget {
  const LockedFeatureOverlay({
    super.key,
    required this.feature,
    required this.child,
    this.blurAmount = 3.0,
  });

  final GatedFeature feature;
  final Widget child;
  final double blurAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featureGateAsync = ref.watch(featureGateProvider(feature));

    return featureGateAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (gateResult) {
        if (gateResult.isAllowed) {
          return child;
        }

        return Stack(
          children: [
            // Blurred content
            ImageFiltered(
              imageFilter: ColorFilter.mode(
                Colors.grey.withValues(alpha: 0.3),
                BlendMode.saturation,
              ),
              child: child,
            ),
            // Lock overlay
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: _buildLockCard(context, gateResult),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLockCard(BuildContext context, FeatureGateResult gateResult) {
    final theme = Theme.of(context);
    final planName = gateResult.requiredPlan?.name ?? "Pro";

    return Card(
      margin: const EdgeInsets.all(32),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.lock,
                size: 32,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "$planName Feature",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Upgrade to $planName to access this feature",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.subscriptionPlans),
              icon: const Icon(Iconsax.crown),
              label: Text("Upgrade to $planName"),
            ),
          ],
        ),
      ),
    );
  }
}
