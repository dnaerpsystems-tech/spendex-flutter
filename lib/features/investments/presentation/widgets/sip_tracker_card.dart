import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';

/// A card widget that displays SIP (Systematic Investment Plan) schedule and status.
///
/// This widget shows:
/// - Next SIP date
/// - SIP amount
/// - Frequency (monthly/quarterly)
/// - Status indicator (active/paused)
/// - Gradient card background
///
/// Features:
/// - Material 3 design
/// - Gradient background (purple/pink theme)
/// - Status-based color coding
/// - Dark mode support
/// - Placeholder implementation for future SIP model integration
class SipTrackerCard extends StatelessWidget {
  const SipTrackerCard({
    required this.nextSipDate,
    required this.sipAmount,
    required this.frequency,
    required this.isActive,
    this.investmentName,
    super.key,
  });

  final DateTime nextSipDate;
  final int sipAmount;
  final String frequency;
  final bool isActive;
  final String? investmentName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.purple.shade900.withOpacity(0.3),
                  Colors.pink.shade900.withOpacity(0.3),
                ]
              : [
                  Colors.purple.shade400,
                  Colors.pink.shade400,
                ],
        ),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark
              ? SpendexColors.darkBorder
              : Colors.white.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(SpendexTheme.spacingSm),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        SpendexTheme.radiusSm,
                      ),
                    ),
                    child: const Icon(
                      Iconsax.calendar,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIP Schedule',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingXs),
                      Text(
                        investmentName ?? 'Active SIP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpendexTheme.spacingMd,
                  vertical: SpendexTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                  border: Border.all(
                    color: isActive
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SpendexTheme.spacingSm),
                    Text(
                      isActive ? 'Active' : 'Paused',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Divider(
            color: Colors.white.withOpacity(0.2),
            height: 1,
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _SipInfoItem(
                  label: 'Next SIP Date',
                  value: DateFormat(AppConstants.dateFormat).format(nextSipDate),
                  icon: Iconsax.calendar_1,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _SipInfoItem(
                  label: 'Amount',
                  value: CurrencyFormatter.formatPaise(
                    sipAmount,
                    decimalDigits: 0,
                  ),
                  icon: Iconsax.money_send,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _SipInfoItem(
                  label: 'Frequency',
                  value: frequency,
                  icon: Iconsax.refresh,
                ),
              ),
            ],
          ),
          if (!isActive) ...[
            const SizedBox(height: SpendexTheme.spacingMd),
            Container(
              padding: const EdgeInsets.all(SpendexTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: SpendexTheme.spacingSm),
                  Expanded(
                    child: Text(
                      'SIP is currently paused. Resume to continue investments.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SipInfoItem extends StatelessWidget {
  const _SipInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: SpendexTheme.spacingSm),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: SpendexTheme.spacingXs),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
