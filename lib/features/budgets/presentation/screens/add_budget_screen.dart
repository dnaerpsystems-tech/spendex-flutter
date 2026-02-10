import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../data/models/budget_model.dart';
import '../providers/budgets_provider.dart';
import '../widgets/budget_card.dart';
import '../widgets/budget_period_selector.dart';

/// Add/Edit Budget Screen
class AddBudgetScreen extends ConsumerStatefulWidget {

  const AddBudgetScreen({super.key, this.budgetId});
  final String? budgetId;

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  CategoryModel? _selectedCategory;
  int _alertThreshold = 80;
  bool _rollover = false;
  bool _isActive = true;
  DateTime _startDate = DateTime.now();

  bool _isLoading = false;
  bool _isEditMode = false;
  BudgetModel? _existingBudget;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.budgetId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load categories
      ref.read(categoriesStateProvider.notifier).loadExpenseCategories();

      // Load existing budget if editing
      if (_isEditMode) {
        _loadBudget();
      }
    });
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);

    final budget = await ref
        .read(budgetsStateProvider.notifier)
        .getBudgetById(widget.budgetId!);

    if (budget != null && mounted) {
      setState(() {
        _existingBudget = budget;
        _nameController.text = budget.name;
        _amountController.text = budget.amountInRupees.toStringAsFixed(0);
        _selectedPeriod = budget.period;
        _selectedCategory = budget.category;
        _alertThreshold = budget.alertThreshold;
        _rollover = budget.rollover;
        _isActive = budget.isActive;
        _startDate = budget.startDate;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  DateTime _calculateEndDate() {
    switch (_selectedPeriod) {
      case BudgetPeriod.weekly:
        return _startDate.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(
          _startDate.year,
          _startDate.month + 1,
          _startDate.day,
        );
      case BudgetPeriod.quarterly:
        return DateTime(
          _startDate.year,
          _startDate.month + 3,
          _startDate.day,
        );
      case BudgetPeriod.yearly:
        return DateTime(
          _startDate.year + 1,
          _startDate.month,
          _startDate.day,
        );
    }
  }

  BudgetModel _createPreviewBudget() {
    final amount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final amountInPaise = amount * 100;
    final spent = _existingBudget?.spent ?? 0;
    final remaining = amountInPaise - spent;
    final percentage = amountInPaise > 0 ? (spent / amountInPaise) * 100 : 0.0;

    return BudgetModel(
      id: widget.budgetId ?? 'preview',
      name: _nameController.text.isEmpty ? 'Budget Name' : _nameController.text,
      amount: amountInPaise,
      spent: spent,
      remaining: remaining,
      percentage: percentage,
      categoryId: _selectedCategory?.id,
      period: _selectedPeriod,
      startDate: _startDate,
      endDate: _calculateEndDate(),
      alertThreshold: _alertThreshold,
      isActive: _isActive,
      rollover: _rollover,
      category: _selectedCategory,
      createdAt: _existingBudget?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Budget name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = int.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount < 100) {
      return 'Minimum budget is ₹100';
    }
    if (amount > 9999999) {
      return 'Maximum budget is ₹99,99,999';
    }
    return null;
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: SpendexColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      setState(() => _startDate = date);
    }
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = int.parse(_amountController.text.replaceAll(',', '')) * 100;

    final request = CreateBudgetRequest(
      name: _nameController.text.trim(),
      amount: amount,
      categoryId: _selectedCategory?.id,
      period: _selectedPeriod,
      alertThreshold: _alertThreshold,
      rollover: _rollover,
    );

    BudgetModel? result;

    if (_isEditMode) {
      result = await ref
          .read(budgetsStateProvider.notifier)
          .updateBudget(widget.budgetId!, request);
    } else {
      result = await ref.read(budgetsStateProvider.notifier).createBudget(request);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Budget updated' : 'Budget created'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(budgetsStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save budget'),
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
    final categoriesState = ref.watch(categoriesStateProvider);

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Budget' : 'Add Budget'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Iconsax.trash, color: SpendexColors.expense),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: _isLoading && _isEditMode && _existingBudget == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Preview
                    Text(
                      'Preview',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    BudgetCard(
                      budget: _createPreviewBudget(),
                      compact: false,
                    ),

                    const SizedBox(height: 24),

                    // Budget Name
                    _SectionTitle(title: 'Budget Name', isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Groceries, Entertainment',
                        prefixIcon: const Icon(Iconsax.text),
                        filled: true,
                        fillColor: isDark
                            ? SpendexColors.darkCard
                            : SpendexColors.lightCard,
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // Amount
                    _SectionTitle(title: 'Budget Amount', isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: '5,000',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 16, right: 8),
                          child: Text(
                            '₹',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? SpendexColors.darkCard
                            : SpendexColors.lightCard,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorFormatter(),
                      ],
                      validator: _validateAmount,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 20),

                    // Period Selector
                    _SectionTitle(title: 'Budget Period', isDark: isDark),
                    const SizedBox(height: 8),
                    BudgetPeriodSelector(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        if (period != null) {
                          setState(() => _selectedPeriod = period);
                        }
                      },
                      showAllOption: false,
                    ),

                    const SizedBox(height: 20),

                    // Start Date
                    _SectionTitle(title: 'Start Date', isDark: isDark),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectStartDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SpendexColors.darkCard
                              : SpendexColors.lightCard,
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? SpendexColors.darkBorder
                                : SpendexColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.calendar,
                              color: isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('dd MMM yyyy').format(_startDate),
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextPrimary
                                    : SpendexColors.lightTextPrimary,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Iconsax.arrow_right_3,
                              size: 18,
                              color: isDark
                                  ? SpendexColors.darkTextTertiary
                                  : SpendexColors.lightTextTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'Ends on ${DateFormat('dd MMM yyyy').format(_calculateEndDate())}',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextTertiary
                              : SpendexColors.lightTextTertiary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Category (Optional)
                    _SectionTitle(
                      title: 'Category (Optional)',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _CategorySelector(
                      categories: categoriesState.expenseCategories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                      isDark: isDark,
                    ),

                    const SizedBox(height: 20),

                    // Alert Threshold
                    _SectionTitle(
                      title: 'Alert Threshold',
                      subtitle: 'Get notified when spending reaches this level',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkCard
                            : SpendexColors.lightCard,
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                        border: Border.all(
                          color: isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alert at',
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: isDark
                                      ? SpendexColors.darkTextPrimary
                                      : SpendexColors.lightTextPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: SpendexColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$_alertThreshold%',
                                  style: SpendexTheme.titleMedium.copyWith(
                                    color: SpendexColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: SpendexColors.warning,
                              inactiveTrackColor:
                                  SpendexColors.warning.withValues(alpha: 0.2),
                              thumbColor: SpendexColors.warning,
                              overlayColor: SpendexColors.warning.withValues(alpha: 0.1),
                            ),
                            child: Slider(
                              value: _alertThreshold.toDouble(),
                              min: 50,
                              max: 100,
                              divisions: 10,
                              onChanged: (value) {
                                setState(() => _alertThreshold = value.toInt());
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rollover Toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? SpendexColors.darkCard
                            : SpendexColors.lightCard,
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                        border: Border.all(
                          color: isDark
                              ? SpendexColors.darkBorder
                              : SpendexColors.lightBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: SpendexColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Iconsax.refresh_2,
                              color: SpendexColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rollover',
                                  style: SpendexTheme.titleMedium.copyWith(
                                    color: isDark
                                        ? SpendexColors.darkTextPrimary
                                        : SpendexColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  'Carry remaining balance to next period',
                                  style: SpendexTheme.labelMedium.copyWith(
                                    color: isDark
                                        ? SpendexColors.darkTextSecondary
                                        : SpendexColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _rollover,
                            onChanged: (value) => setState(() => _rollover = value),
                            activeColor: SpendexColors.primary,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpendexColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SpendexTheme.radiusMd),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Budget' : 'Create Budget',
                                style: SpendexTheme.titleMedium.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  void _showDeleteConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Iconsax.trash,
                color: SpendexColors.expense,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Budget'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_existingBudget?.name}"? This action cannot be undone.',
          style: SpendexTheme.bodyMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              final success = await ref
                  .read(budgetsStateProvider.notifier)
                  .deleteBudget(widget.budgetId!);

              if (mounted) {
                setState(() => _isLoading = false);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget deleted'),
                      backgroundColor: SpendexColors.income,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  context.pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete budget'),
                      backgroundColor: SpendexColors.expense,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SpendexColors.expense,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {

  const _SectionTitle({
    required this.title,
    this.subtitle,
    required this.isDark,
  });
  final String title;
  final String? subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {

  const _CategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.isDark,
  });
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final ValueChanged<CategoryModel?> onCategorySelected;
  final bool isDark;

  Color _parseColor(String? colorString) {
    try {
      if (colorString == null || colorString.isEmpty) return SpendexColors.primary;
      final color = colorString.replaceAll('#', '');
      return Color(int.parse('FF$color', radix: 16));
    } catch (_) {
      return SpendexColors.primary;
    }
  }

  IconData _parseIcon(String? iconName) {
    if (iconName == null) return Iconsax.category;
    final iconMap = {
      'shopping-cart': Iconsax.shopping_cart,
      'restaurant': Iconsax.reserve,
      'car': Iconsax.car,
      'home': Iconsax.home,
      'medical': Iconsax.health,
      'education': Iconsax.book,
      'entertainment': Iconsax.game,
      'travel': Iconsax.airplane,
      'gift': Iconsax.gift,
      'bills': Iconsax.receipt,
      'groceries': Iconsax.shopping_bag,
      'fitness': Iconsax.weight,
      'personal': Iconsax.user,
    };
    return iconMap[iconName] ?? Iconsax.category;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // None option
        GestureDetector(
          onTap: () => onCategorySelected(null),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selectedCategory == null
                  ? SpendexColors.primary
                  : isDark
                      ? SpendexColors.darkCard
                      : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectedCategory == null
                    ? SpendexColors.primary
                    : isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.category,
                  size: 16,
                  color: selectedCategory == null
                      ? Colors.white
                      : isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'All Categories',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: selectedCategory == null
                        ? Colors.white
                        : isDark
                            ? SpendexColors.darkTextPrimary
                            : SpendexColors.lightTextPrimary,
                    fontWeight: selectedCategory == null
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Category chips
        ...categories.map((category) {
          final isSelected = selectedCategory?.id == category.id;
          final color = _parseColor(category.color);

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color
                    : isDark
                        ? SpendexColors.darkCard
                        : SpendexColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? color
                      : isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _parseIcon(category.icon),
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.name,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Input formatter for thousands separator
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final numericValue = newValue.text.replaceAll(',', '');
    if (int.tryParse(numericValue) == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,##,###', 'en_IN');
    final newText = formatter.format(int.parse(numericValue));

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
