import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/bank_config_model.dart';

/// Bottom sheet for selecting banks
class BankSelectorSheet extends StatefulWidget {
  const BankSelectorSheet({
    required this.banks,
    required this.selectedBanks,
    required this.onSelectionChanged,
    super.key,
  });

  final List<BankConfigModel> banks;
  final Set<String> selectedBanks;
  final ValueChanged<Set<String>> onSelectionChanged;

  @override
  State<BankSelectorSheet> createState() => _BankSelectorSheetState();
}

class _BankSelectorSheetState extends State<BankSelectorSheet> {
  late Set<String> _selectedBanks;

  @override
  void initState() {
    super.initState();
    _selectedBanks = Set.from(widget.selectedBanks);
  }

  void _toggleBank(String bankName) {
    setState(() {
      if (_selectedBanks.contains(bankName)) {
        _selectedBanks.remove(bankName);
      } else {
        _selectedBanks.add(bankName);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedBanks = widget.banks.map((b) => b.bankName).toSet();
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedBanks.clear();
    });
  }

  void _apply() {
    widget.onSelectionChanged(_selectedBanks);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Banks',
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      child: Text(
                        'Select All',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: SpendexColors.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _deselectAll,
                      child: Text(
                        'Clear',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: SpendexColors.expense,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Selected count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.bank,
                    size: 16,
                    color: SpendexColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedBanks.length} of ${widget.banks.length} banks selected',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: SpendexColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bank list
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.banks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final bank = widget.banks[index];
                final isSelected = _selectedBanks.contains(bank.bankName);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleBank(bank.bankName),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? SpendexColors.primary
                              : (isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Checkbox
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleBank(bank.bankName),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Bank icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: SpendexColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(
                                Iconsax.bank,
                                color: SpendexColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Bank name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.bankName,
                                  style: SpendexTheme.titleMedium.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${bank.smsPatterns.length} SMS patterns',
                                  style: SpendexTheme.labelMedium.copyWith(
                                    color: isDark
                                        ? SpendexColors.darkTextSecondary
                                        : SpendexColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Checkmark icon if selected
                          if (isSelected)
                            const Icon(
                              Iconsax.tick_circle5,
                              color: SpendexColors.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Apply button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedBanks.isEmpty ? null : _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpendexColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: SpendexColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Apply Selection',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
