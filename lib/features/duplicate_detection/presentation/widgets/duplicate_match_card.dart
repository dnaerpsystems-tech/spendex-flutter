import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendex/app/theme.dart';
import 'package:spendex/features/duplicate_detection/domain/models/duplicate_match_model.dart';
import 'package:spendex/features/duplicate_detection/presentation/widgets/resolution_action_selector.dart';

/// Card widget displaying a potential duplicate match
///
/// Shows side-by-side comparison of imported and existing transactions
/// with confidence score and resolution action selector.
class DuplicateMatchCard extends StatefulWidget {
  const DuplicateMatchCard({
    required this.match,
    required this.onResolutionChanged,
    super.key,
    this.isExpanded = false,
    this.onExpandToggle,
  });

  /// The duplicate match to display
  final DuplicateMatchModel match;

  /// Callback when resolution action is selected
  final ValueChanged<DuplicateResolutionAction> onResolutionChanged;

  /// Whether the card is expanded to show full details
  final bool isExpanded;

  /// Callback when expand/collapse is toggled
  final VoidCallback? onExpandToggle;

  @override
  State<DuplicateMatchCard> createState() => _DuplicateMatchCardState();
}

class _DuplicateMatchCardState extends State<DuplicateMatchCard> {
  final _dateFormatter = DateFormat('dd MMM yyyy');
  final _currencyFormatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  Color get _confidenceColor {
    if (widget.match.isHighConfidence) {
      return SpendexColors.expense; // Red for high confidence (likely duplicate)
    } else if (widget.match.isMediumConfidence) {
      return SpendexColors.warning; // Orange for medium confidence
    } else {
      return const Color(0xFF64748B); // Gray for low confidence
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
        vertical: SpendexTheme.spacingSm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        side: BorderSide(
          color: widget.match.isResolved
              ? SpendexColors.primary
              : _confidenceColor.withValues(alpha: 0.2),
          width: widget.match.isResolved ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with confidence badge
          _buildHeader(colorScheme),

          const Divider(height: 1),

          // Side-by-side comparison
          Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imported transaction
                    Expanded(
                      child: _buildTransactionColumn(
                        title: 'Importing',
                        amount: widget.match.importedTransaction.amount,
                        date: widget.match.importedTransaction.date,
                        description: widget.match.importedTransaction.description,
                        merchant: widget.match.importedTransaction.merchant,
                        isImported: true,
                        colorScheme: colorScheme,
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingMd),
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),

                    // Existing transaction
                    Expanded(
                      child: _buildTransactionColumn(
                        title: 'Existing',
                        amount: widget.match.existingTransaction.amountInRupees,
                        date: widget.match.existingTransaction.date,
                        description: widget.match.existingTransaction.description ?? '',
                        merchant: widget.match.existingTransaction.payee,
                        isImported: false,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ),

                if (widget.isExpanded) ...[
                  const SizedBox(height: SpendexTheme.spacingMd),
                  _buildMatchReasons(),
                ],
              ],
            ),
          ),

          const Divider(height: 1),

          // Resolution action selector
          Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingMd),
            child: ResolutionActionSelector(
              selectedAction: widget.match.resolution,
              onActionSelected: widget.onResolutionChanged,
            ),
          ),

          // Expand/collapse button
          if (widget.onExpandToggle != null)
            InkWell(
              onTap: widget.onExpandToggle,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: SpendexTheme.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(SpendexTheme.radiusMd),
                    bottomRight: Radius.circular(SpendexTheme.radiusMd),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.isExpanded ? 'Show less' : 'Show details',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: SpendexColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      widget.isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: SpendexColors.primary,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: _confidenceColor.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SpendexTheme.radiusMd),
          topRight: Radius.circular(SpendexTheme.radiusMd),
        ),
      ),
      child: Row(
        children: [
          // Confidence badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpendexTheme.spacingSm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _confidenceColor,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.match.confidencePercentage}% ${widget.match.confidenceLevel}',
                  style: SpendexTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: SpendexTheme.spacingMd),

          // Title
          Expanded(
            child: Text(
              'Potential Duplicate',
              style: SpendexTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          // Resolution indicator
          if (widget.match.isResolved)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingSm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: SpendexColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Resolved',
                    style: SpendexTheme.labelSmall.copyWith(
                      color: SpendexColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionColumn({
    required String title,
    required double amount,
    required DateTime date,
    required String description,
    required bool isImported, required ColorScheme colorScheme, String? merchant,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          title,
          style: SpendexTheme.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingSm),

        // Amount
        Text(
          _currencyFormatter.format(amount),
          style: SpendexTheme.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),

        // Date
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              _dateFormatter.format(date),
              style: SpendexTheme.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingSm),

        // Description
        Text(
          description,
          style: SpendexTheme.bodySmall.copyWith(
            color: colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Merchant (if available)
        if (merchant != null && merchant.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.store,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  merchant,
                  style: SpendexTheme.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildMatchReasons() {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: _confidenceColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: _confidenceColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Reasons',
            style: SpendexTheme.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingSm),
          Wrap(
            spacing: SpendexTheme.spacingSm,
            runSpacing: SpendexTheme.spacingSm,
            children: widget.match.reasons.map((reason) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpendexTheme.spacingSm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                  border: Border.all(
                    color: _confidenceColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      reason.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reason.label,
                      style: SpendexTheme.labelSmall.copyWith(
                        color: _confidenceColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
