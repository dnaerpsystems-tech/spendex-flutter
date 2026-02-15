import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/subscription_models.dart';

/// A bottom sheet widget for subscription cancellation flow.
class CancelSubscriptionSheet extends StatefulWidget {
  const CancelSubscriptionSheet({
    required this.subscription,
    super.key,
    this.onCancel,
    this.isLoading = false,
  });

  final SubscriptionModel subscription;
  final void Function(String reason, {required bool cancelImmediately})? onCancel;
  final bool isLoading;

  @override
  State<CancelSubscriptionSheet> createState() => _CancelSubscriptionSheetState();
}

class _CancelSubscriptionSheetState extends State<CancelSubscriptionSheet> {
  String? _selectedReason;
  bool _cancelImmediately = false;

  static const List<String> _cancellationReasons = [
    'Too expensive',
    'Not using the features',
    'Found a better alternative',
    'Missing features I need',
    'Technical issues',
    'Temporary pause',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: SpendexTheme.spacingMd),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: SpendexColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                        child: const Icon(
                          Iconsax.warning_2,
                          color: SpendexColors.expense,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: SpendexTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cancel Subscription',
                              style: SpendexTheme.headlineMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextPrimary
                                    : SpendexColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              "We're sorry to see you go",
                              style: SpendexTheme.bodySmall.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  Container(
                    padding: const EdgeInsets.all(SpendexTheme.spacingLg),
                    decoration: BoxDecoration(
                      color: SpendexColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      border: Border.all(
                        color: SpendexColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Iconsax.info_circle,
                          color: SpendexColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: SpendexTheme.spacingMd),
                        Expanded(
                          child: Text(
                            'Your subscription will remain active until the end of your current billing period. You can continue using all features until then.',
                            style: SpendexTheme.bodySmall.copyWith(
                              color: SpendexColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  Text(
                    'Why are you cancelling?',
                    style: SpendexTheme.titleMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  Wrap(
                    spacing: SpendexTheme.spacingSm,
                    runSpacing: SpendexTheme.spacingSm,
                    children: _cancellationReasons.map((reason) {
                      final isSelected = _selectedReason == reason;
                      return ChoiceChip(
                        label: Text(reason),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedReason = selected ? reason : null;
                          });
                        },
                        selectedColor: SpendexColors.primary.withValues(alpha: 0.2),
                        backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                        side: BorderSide(
                          color: isSelected
                              ? SpendexColors.primary
                              : isDark
                                  ? SpendexColors.darkBorder
                                  : SpendexColors.lightBorder,
                        ),
                        labelStyle: SpendexTheme.labelMedium.copyWith(
                          color: isSelected
                              ? SpendexColors.primary
                              : isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  Container(
                    padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                      borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      border: Border.all(
                        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cancel immediately',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextPrimary
                                      : SpendexColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                'End subscription now without refund',
                                style: SpendexTheme.bodySmall.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextTertiary
                                      : SpendexColors.lightTextTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _cancelImmediately,
                          onChanged: (value) {
                            setState(() => _cancelImmediately = value);
                          },
                          activeThumbColor: SpendexColors.expense,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  Text(
                    "Features you'll lose",
                    style: SpendexTheme.titleMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  ...(widget.subscription.plan?.features.take(5) ?? []).map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: SpendexTheme.spacingSm,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: SpendexColors.expense.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.close_circle5,
                              size: 14,
                              color: SpendexColors.expense,
                            ),
                          ),
                          const SizedBox(width: SpendexTheme.spacingSm),
                          Expanded(
                            child: Text(
                              feature,
                              style: SpendexTheme.bodySmall.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                            side: BorderSide(
                              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                          child: const Text('Keep Subscription'),
                        ),
                      ),
                      const SizedBox(width: SpendexTheme.spacingMd),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selectedReason == null || widget.isLoading
                              ? null
                              : () {
                                  widget.onCancel?.call(
                                    _selectedReason ?? '',
                                    cancelImmediately: _cancelImmediately,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SpendexColors.expense,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 48),
                          ),
                          child: widget.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Cancel Subscription'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpendexTheme.spacingLg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the cancel subscription bottom sheet.
Future<void> showCancelSubscriptionSheet(
  BuildContext context, {
  required SubscriptionModel subscription,
  void Function(String reason, {required bool cancelImmediately})? onCancel,
  bool isLoading = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => CancelSubscriptionSheet(
        subscription: subscription,
        onCancel: onCancel,
        isLoading: isLoading,
      ),
    ),
  );
}
