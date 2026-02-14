import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:iconsax/iconsax.dart";
import "../../../../app/routes.dart";
import "../../../../core/services/paywall_service.dart";
import "../../data/models/subscription_models.dart";

/// A dialog that prompts users to upgrade their subscription.
///
/// This dialog is shown when a user tries to access a feature that
/// requires a higher subscription tier.
class PaywallDialog extends StatelessWidget {
  /// Creates a new [PaywallDialog].
  const PaywallDialog({
    super.key,
    required this.feature,
    required this.gateResult,
    this.title,
    this.description,
  });

  /// The feature that was blocked.
  final GatedFeature feature;

  /// The gate result with details about the limit.
  final FeatureGateResult gateResult;

  /// Custom title for the dialog.
  final String? title;

  /// Custom description for the dialog.
  final String? description;

  /// Shows the paywall dialog.
  static Future<bool?> show({
    required BuildContext context,
    required GatedFeature feature,
    required FeatureGateResult gateResult,
    String? title,
    String? description,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => PaywallDialog(
        feature: feature,
        gateResult: gateResult,
        title: title,
        description: description,
      ),
    );
  }

  String _getDefaultTitle() {
    if (gateResult.isAtLimit) {
      return "Limit Reached";
    }
    return "Upgrade Required";
  }

  String _getDefaultDescription() {
    if (gateResult.message != null) {
      return gateResult.message!;
    }

    final planName = gateResult.requiredPlan?.name ?? "Pro";
    return "Upgrade to $planName to unlock this feature and get access to premium capabilities.";
  }

  IconData _getFeatureIcon() {
    switch (feature) {
      case GatedFeature.unlimitedAccounts:
        return Iconsax.bank;
      case GatedFeature.unlimitedBudgets:
        return Iconsax.wallet;
      case GatedFeature.unlimitedGoals:
        return Iconsax.flag;
      case GatedFeature.advancedAnalytics:
        return Iconsax.chart;
      case GatedFeature.aiInsights:
        return Iconsax.cpu;
      case GatedFeature.receiptScanning:
        return Iconsax.receipt;
      case GatedFeature.voiceInput:
        return Iconsax.microphone;
      case GatedFeature.accountAggregator:
        return Iconsax.link;
      case GatedFeature.emailParsing:
        return Iconsax.sms;
      case GatedFeature.familySharing:
        return Iconsax.people;
      case GatedFeature.investmentTracking:
        return Iconsax.chart_2;
      case GatedFeature.loanTracking:
        return Iconsax.money_send;
      case GatedFeature.exportReports:
        return Iconsax.document_download;
      case GatedFeature.prioritySupport:
        return Iconsax.headphone;
      case GatedFeature.taxReports:
        return Iconsax.receipt_text;
    }
  }

  List<String> _getPlanBenefits() {
    final plan = gateResult.requiredPlan ?? SubscriptionPlan.pro;

    if (plan == SubscriptionPlan.premium) {
      return [
        "Unlimited accounts, budgets & goals",
        "Advanced AI-powered insights",
        "Family sharing with up to 6 members",
        "Priority support",
        "Tax reports & export",
        "All Pro features included",
      ];
    }

    return [
      "Up to 10 accounts, 10 budgets & 5 goals",
      "AI-powered spending insights",
      "Receipt scanning & voice input",
      "Bank account aggregation",
      "Investment & loan tracking",
      "Export reports to PDF/CSV",
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final planName = gateResult.requiredPlan?.name ?? "Pro";
    final isLimit = gateResult.isAtLimit;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gateResult.requiredPlan == SubscriptionPlan.premium
                        ? [
                            const Color(0xFFB8860B),
                            const Color(0xFFDAA520),
                            const Color(0xFFFFD700),
                          ]
                        : [
                            colorScheme.primary,
                            colorScheme.primary.withValues(alpha: 0.8),
                          ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLimit ? Iconsax.warning_2 : _getFeatureIcon(),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      title ?? _getDefaultTitle(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Description
                    Text(
                      description ?? _getDefaultDescription(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Usage info (for count-based limits)
              if (isLimit && gateResult.currentCount != null && gateResult.limit != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "You are using ${gateResult.currentCount} of ${gateResult.limit}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Benefits list
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$planName includes:",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._getPlanBenefits().map((benefit) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Iconsax.tick_circle,
                                  color: colorScheme.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  benefit,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),

              // Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Upgrade button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          context.push(AppRoutes.subscriptionPlans);
                        },
                        icon: const Icon(Iconsax.crown),
                        label: Text("Upgrade to $planName"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Maybe later button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Maybe Later"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact paywall banner for inline display.
class PaywallBanner extends StatelessWidget {
  const PaywallBanner({
    super.key,
    required this.feature,
    required this.gateResult,
    this.onUpgrade,
    this.compact = false,
  });

  final GatedFeature feature;
  final FeatureGateResult gateResult;
  final VoidCallback? onUpgrade;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.crown,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              gateResult.requiredPlan?.name ?? "Pro",
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
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
                  gateResult.message ?? "Upgrade to unlock",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (gateResult.isAtLimit)
                  Text(
                    "${gateResult.currentCount}/${gateResult.limit} used",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpgrade ?? () => context.push(AppRoutes.subscriptionPlans),
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }
}

/// Extension to easily show paywall dialog from any context.
extension PaywallDialogExtension on BuildContext {
  /// Shows a paywall dialog for the given feature.
  Future<bool?> showPaywallDialog({
    required GatedFeature feature,
    required FeatureGateResult gateResult,
    String? title,
    String? description,
  }) {
    return PaywallDialog.show(
      context: this,
      feature: feature,
      gateResult: gateResult,
      title: title,
      description: description,
    );
  }
}
