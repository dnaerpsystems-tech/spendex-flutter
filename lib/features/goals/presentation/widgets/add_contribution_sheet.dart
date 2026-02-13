import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../providers/goals_provider.dart';

/// A modal bottom sheet for adding a contribution to a goal.
///
/// This widget displays a form where users can:
/// - Enter the contribution amount
/// - Add optional notes about the contribution
/// - Submit the contribution to the goal
class AddContributionSheet extends ConsumerStatefulWidget {
  /// Creates an add contribution sheet.
  ///
  /// The [goalId] parameter specifies which goal to add the contribution to.
  const AddContributionSheet({
    required this.goalId,
    super.key,
  });

  /// The ID of the goal to add the contribution to.
  final String goalId;

  @override
  ConsumerState<AddContributionSheet> createState() =>
      _AddContributionSheetState();
}

class _AddContributionSheetState extends ConsumerState<AddContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_amountController.text);
    final amountInPaise = (amount * 100).toInt();
    final notes = _notesController.text.trim();

    final result = await ref.read(goalsStateProvider.notifier).addContribution(
          widget.goalId,
          amountInPaise,
          notes.isEmpty ? null : notes,
        );

    if (mounted) {
      if (result != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contribution added'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add contribution'),
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
    final isUpdating = ref.watch(goalsStateProvider).isUpdating;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpendexTheme.radiusXl),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
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
                      Iconsax.add,
                      color: SpendexColors.income,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Contribution',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount in ₹',
                  prefixIcon: const Icon(Iconsax.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                ),
                validator: _validateAmount,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLength: 200,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add a note about this contribution',
                  prefixIcon: const Icon(Iconsax.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isUpdating ? null : _handleSubmit,
                  child: isUpdating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Add Contribution'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
