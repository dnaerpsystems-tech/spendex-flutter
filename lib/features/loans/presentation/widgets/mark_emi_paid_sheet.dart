import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/loan_model.dart';
import '../providers/loans_provider.dart';
import 'loan_info_card.dart';

class MarkEmiPaidSheet extends ConsumerStatefulWidget {
  const MarkEmiPaidSheet({
    required this.loanId,
    required this.emi,
    super.key,
  });

  final String loanId;
  final EmiSchedule emi;

  @override
  ConsumerState<MarkEmiPaidSheet> createState() => _MarkEmiPaidSheetState();
}

class _MarkEmiPaidSheetState extends ConsumerState<MarkEmiPaidSheet> {
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.emi.dueDate.subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _markAsPaid() async {
    setState(() {
      _isLoading = true;
    });

    final request = EmiPaymentRequest(
      month: widget.emi.month,
      paidDate: _selectedDate,
    );

    final result = await ref
        .read(loansStateProvider.notifier)
        .recordEmiPayment(widget.loanId, request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('EMI marked as paid'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark EMI as paid'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(SpendexTheme.radiusXl),
          topRight: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: SpendexColors.income.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.tick_circle,
                    color: SpendexColors.income,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mark EMI as Paid',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Iconsax.close_circle),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
              child: Column(
                children: [
                  InfoRow(
                    label: 'EMI Month',
                    value: 'Month ${widget.emi.month}',
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    label: 'Due Date',
                    value: DateFormat('dd MMM yyyy').format(widget.emi.dueDate),
                  ),
                  const SizedBox(height: 8),
                  InfoRow(
                    label: 'EMI Amount',
                    value: CurrencyFormatter.formatPaise(widget.emi.emiAmount),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Date',
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  border: Border.all(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.calendar,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextPrimary
                            : SpendexColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _markAsPaid,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.income,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
