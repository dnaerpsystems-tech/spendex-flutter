import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/goal_model.dart';
import '../providers/goals_provider.dart';
import '../widgets/color_picker_modal.dart';
import '../widgets/icon_picker_modal.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key, this.goalId});

  final String? goalId;

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedIcon = 'flag';
  String _selectedColor = '10B981';

  bool _isLoading = false;
  bool _isEditMode = false;
  GoalModel? _existingGoal;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.goalId != null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditMode) {
        _loadGoal();
      }
    });
  }

  Future<void> _loadGoal() async {
    setState(() => _isLoading = true);

    final goal = await ref.read(goalsStateProvider.notifier).loadGoalById(widget.goalId!);

    if (goal != null && mounted) {
      setState(() {
        _existingGoal = goal;
        _nameController.text = goal.name;
        _amountController.text = goal.targetAmountInRupees.toStringAsFixed(0);
        _selectedDate = goal.targetDate;
        _selectedIcon = goal.icon ?? 'flag';
        _selectedColor = goal.color ?? '10B981';
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Goal name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Target amount is required';
    }
    final amount = CurrencyFormatter.parse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount greater than 0';
    }
    if (amount > 99999999) {
      return 'Maximum amount is ₹9,99,99,999';
    }
    return null;
  }

  Future<void> _selectTargetDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now.add(const Duration(days: 30));

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
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
      setState(() => _selectedDate = date);
    }
  }

  void _clearTargetDate() {
    setState(() => _selectedDate = null);
  }

  Future<void> _openIconPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IconPickerModal(selectedIcon: _selectedIcon),
    );

    if (result != null && mounted) {
      setState(() => _selectedIcon = result);
    }
  }

  Future<void> _openColorPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ColorPickerModal(selectedColor: _selectedColor),
    );

    if (result != null && mounted) {
      setState(() => _selectedColor = result);
    }
  }

  IconData _getIconData(String iconName) {
    final iconMap = <String, IconData>{
      'flag': Iconsax.flag,
      'home': Iconsax.home,
      'car': Iconsax.car,
      'airplane': Iconsax.airplane,
      'graduation': Iconsax.teacher,
      'rings': Iconsax.heart,
      'gift': Iconsax.gift,
      'piggy_bank': Iconsax.wallet,
      'medical': Iconsax.health,
      'phone': Iconsax.mobile,
      'laptop': Iconsax.monitor,
      'bicycle': Iconsax.routing,
      'camera': Iconsax.camera,
      'sport': Iconsax.activity,
      'tree': Iconsax.safe_home,
      'trophy': Iconsax.award,
    };
    return iconMap[iconName] ?? Iconsax.flag;
  }

  Color _parseHexColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '').toUpperCase();
      if (cleanHex.length != 6) {
        return SpendexColors.primary;
      }
      final colorValue = int.parse(cleanHex, radix: 16);
      return Color(colorValue | 0xFF000000);
    } catch (_) {
      return SpendexColors.primary;
    }
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final amountInRupees = CurrencyFormatter.parse(_amountController.text) ?? 0;
    final amountInPaise = (amountInRupees * 100).toInt();

    final request = CreateGoalRequest(
      name: _nameController.text.trim(),
      targetAmount: amountInPaise,
      targetDate: _selectedDate,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    GoalModel? result;

    if (_isEditMode) {
      result = await ref.read(goalsStateProvider.notifier).updateGoal(widget.goalId!, request);
    } else {
      result = await ref.read(goalsStateProvider.notifier).createGoal(request);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Goal updated' : 'Goal created'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(goalsErrorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save goal'),
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
    final goalsState = ref.watch(goalsStateProvider);
    final isOperationInProgress = goalsState.isCreating || goalsState.isUpdating;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Goal' : 'Add Goal'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && _isEditMode && _existingGoal == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'Goal Name', isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Emergency Fund, New Car',
                        prefixIcon: const Icon(Iconsax.text),
                        filled: true,
                        fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      validator: _validateName,
                      enabled: !isOperationInProgress,
                      buildCounter: (
                        context, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) =>
                          null,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'Target Amount', isDark: isDark),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        hintText: '50,000',
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
                        prefixIconConstraints: const BoxConstraints(),
                        filled: true,
                        fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorFormatter(),
                      ],
                      validator: _validateAmount,
                      enabled: !isOperationInProgress,
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Target Date (Optional)',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: isOperationInProgress ? null : _selectTargetDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                          border: Border.all(
                            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
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
                            Expanded(
                              child: Text(
                                _selectedDate == null
                                    ? 'Select target date'
                                    : DateFormat('dd MMM yyyy').format(_selectedDate!),
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: _selectedDate == null
                                      ? (isDark
                                          ? SpendexColors.darkTextTertiary
                                          : SpendexColors.lightTextTertiary)
                                      : (isDark
                                          ? SpendexColors.darkTextPrimary
                                          : SpendexColors.lightTextPrimary),
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              GestureDetector(
                                onTap: isOperationInProgress ? null : _clearTargetDate,
                                child: Icon(
                                  Iconsax.close_circle,
                                  size: 20,
                                  color: isDark
                                      ? SpendexColors.darkTextTertiary
                                      : SpendexColors.lightTextTertiary,
                                ),
                              )
                            else
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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(title: 'Icon', isDark: isDark),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: isOperationInProgress ? null : _openIconPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                                    borderRadius: BorderRadius.circular(
                                      SpendexTheme.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? SpendexColors.darkBorder
                                          : SpendexColors.lightBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _parseHexColor(_selectedColor)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            SpendexTheme.radiusMd,
                                          ),
                                        ),
                                        child: Icon(
                                          _getIconData(_selectedIcon),
                                          color: _parseHexColor(_selectedColor),
                                          size: 24,
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle(title: 'Color', isDark: isDark),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: isOperationInProgress ? null : _openColorPicker,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                                    borderRadius: BorderRadius.circular(
                                      SpendexTheme.radiusMd,
                                    ),
                                    border: Border.all(
                                      color: isDark
                                          ? SpendexColors.darkBorder
                                          : SpendexColors.lightBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: _parseHexColor(_selectedColor),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: _parseHexColor(_selectedColor)
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Iconsax.tick_circle,
                                            color: Colors.white,
                                            size: 20,
                                          ),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isOperationInProgress || _isLoading ? null : _saveGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SpendexColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                          ),
                        ),
                        child: isOperationInProgress || _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isEditMode ? 'Update Goal' : 'Create Goal',
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
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.isDark,
  });

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: SpendexTheme.labelMedium.copyWith(
        color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

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
