import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/paywall_service.dart';
import '../providers/paywall_provider.dart';
import 'paywall_dialog.dart';

/// A mixin that provides paywall checking functionality to screens.
///
/// Use this mixin in screens that need to check feature gates before
/// allowing users to perform actions.
mixin PaywallCheckMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  /// Checks if a feature is allowed and shows paywall dialog if not.
  ///
  /// Returns `true` if the feature is allowed, `false` if blocked.
  /// If blocked, automatically shows the paywall dialog.
  Future<bool> checkFeatureWithDialog(
    GatedFeature feature, {
    String? title,
    String? description,
  }) async {
    final service = ref.read(paywallServiceProvider);
    final result = await service.checkFeature(feature);

    if (!result.isAllowed) {
      if (mounted) {
        await context.showPaywallDialog(
          feature: feature,
          gateResult: result,
          title: title,
          description: description,
        );
      }
      return false;
    }

    return true;
  }

  /// Checks if user can add more of a count-based resource.
  ///
  /// Returns `true` if allowed, `false` if at limit.
  /// Shows paywall dialog if at limit.
  Future<bool> canAddMoreWithDialog(
    GatedFeature feature, {
    String? title,
    String? description,
  }) async {
    final service = ref.read(paywallServiceProvider);
    final result = await service.canAddMore(feature);

    if (!result.isAllowed) {
      if (mounted) {
        await context.showPaywallDialog(
          feature: feature,
          gateResult: result,
          title: title,
          description: description,
        );
      }
      return false;
    }

    return true;
  }

  /// Gets the feature gate result without showing dialog.
  Future<FeatureGateResult> checkFeatureSilent(GatedFeature feature) async {
    final service = ref.read(paywallServiceProvider);
    return service.checkFeature(feature);
  }

  /// Refreshes the paywall state.
  Future<void> refreshPaywall() async {
    await ref.read(paywallProvider.notifier).refresh();
  }
}

/// Helper function to check paywall from anywhere with context and ref.
Future<bool> checkPaywall({
  required BuildContext context,
  required WidgetRef ref,
  required GatedFeature feature,
  String? title,
  String? description,
}) async {
  final service = ref.read(paywallServiceProvider);
  final result = await service.checkFeature(feature);

  if (!result.isAllowed) {
    if (!context.mounted) {
      return false;
    }
    await context.showPaywallDialog(
      feature: feature,
      gateResult: result,
      title: title,
      description: description,
    );
    return false;
  }

  return true;
}

/// Extension on BuildContext for easy paywall checks.
extension PaywallContextExtension on BuildContext {
  /// Checks a feature and shows dialog if blocked.
  Future<bool> checkPaywall({
    required WidgetRef ref,
    required GatedFeature feature,
    String? title,
    String? description,
  }) async {
    final service = ref.read(paywallServiceProvider);
    final result = await service.checkFeature(feature);

    if (!result.isAllowed) {
      await showPaywallDialog(
        feature: feature,
        gateResult: result,
        title: title,
        description: description,
      );
      return false;
    }

    return true;
  }
}
