import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/loan_model.dart';
import '../providers/loans_provider.dart';
import '../widgets/emi_breakdown_card.dart';
import '../widgets/loan_type_picker_modal.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  const AddLoanScreen({super.key, this.loanId});

  final String? loanId;

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _lenderController = TextEditingController();
  final _accountController = TextEditingController();

  LoanType? _selectedType;
  DateTime? _selectedStartDate;

  int _emiAmount = 0;
  int _totalInterest = 0;
  int _totalAmount = 0;

  bool _isLoading = false;
  bool _isLoadingLoan = false;
  bool _isEditMode = false;
  LoanModel? _existingLoan;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.loanId != null;

    _principalController.addListener(_calculateEmi);
    _rateController.addListener(_calculateEmi);
    _tenureController.addListener(_calculateEmi);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditMode) {
        _loadLoan();
      }
    });
  }

  Future<void> _loadLoan() async {
    setState(() => _isLoadingLoan = true);

    final loan = await ref.read(loansStateProvider.notifier).loadLoanById(widget.loanId!);

    if (loan != null && mounted) {
      setState(() {
        _existingLoan = loan;
        _nameController.text = loan.name;
        _principalController.text = loan.principalAmountInRupees.toStringAsFixed(0);
        _rateController.text = loan.interestRate.toStringAsFixed(2);
        _tenureController.text = loan.tenure.toString();
        _selectedType = loan.type;
        _selectedStartDate = loan.startDate;
        if (loan.lender != null) {
          _lenderController.text = loan.lender!;
        }
        if (loan.accountNumber != null) {
          _accountController.text = loan.accountNumber!;
        }
        _isLoadingLoan = false;
      });
      _calculateEmi();
    } else {
      setState(() => _isLoadingLoan = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _principalController.dispose();
    _rateController.dispose();
    _tenureController.dispose();
    _lenderController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _calculateEmi() {
    final principalStr = _principalController.text.replaceAll(',', '');
    final rateStr = _rateController.text;
    final tenureStr = _tenureController.text;

    if (principalStr.isEmpty || rateStr.isEmpty || tenureStr.isEmpty) {
      setState(() {
        _emiAmount = 0;
        _totalInterest = 0;
        _totalAmount = 0;
      });
      return;
    }

    final principal = double.tryParse(principalStr);
    final rate = double.tryParse(rateStr);
    final tenure = int.tryParse(tenureStr);

    if (principal == null ||
        rate == null ||
        tenure == null ||
        principal <= 0 ||
        rate < 0.1 ||
        rate > 36 ||
        tenure < 1 ||
        tenure > 360) {
      setState(() {
        _emiAmount = 0;
        _totalInterest = 0;
        _totalAmount = 0;
      });
      return;
    }

    final monthlyRate = rate / 12 / 100;
    final numerator = principal * monthlyRate * math.pow(1 + monthlyRate, tenure);
    final denominator = math.pow(1 + monthlyRate, tenure) - 1;
    final emi = numerator / denominator;

    final totalPayable = emi * tenure;
    final interest = totalPayable - principal;

    setState(() {
      _emiAmount = (emi * 100).round();
      _totalInterest = (interest * 100).round();
      _totalAmount = (totalPayable * 100).round();
    });
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Loan name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  String? _validatePrincipal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Principal amount is required';
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

  String? _validateRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Interest rate is required';
    }
    final rate = double.tryParse(value);
    if (rate == null || rate < 0.1 || rate > 36) {
      return 'Rate must be between 0.1% and 36%';
    }
    return null;
  }

  String? _validateTenure(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tenure is required';
    }
    final tenure = int.tryParse(value);
    if (tenure == null || tenure < 1 || tenure > 360) {
      return 'Tenure must be between 1 and 360 months';
    }
    return null;
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final initialDate = _selectedStartDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? now : initialDate,
      firstDate: DateTime(now.year - 30),
      lastDate: now,
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
      setState(() => _selectedStartDate = date);
    }
  }

  Future<void> _openLoanTypePicker() async {
    final result = await showModalBottomSheet<LoanType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoanTypePickerModal(selectedType: _selectedType),
    );

    if (result != null && mounted) {
      setState(() => _selectedType = result);
    }
  }

  IconData _getLoanTypeIcon(LoanType type) {
    switch (type) {
      case LoanType.home:
        return Iconsax.home;
      case LoanType.vehicle:
        return Iconsax.car;
      case LoanType.personal:
        return Iconsax.wallet_money;
      case LoanType.education:
        return Iconsax.book;
      case LoanType.gold:
        return Iconsax.medal_star;
      case LoanType.business:
        return Iconsax.brifecase_tick;
      case LoanType.other:
        return Iconsax.receipt_item;
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a loan type'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final principalInRupees = CurrencyFormatter.parse(_principalController.text) ?? 0;
    final principalInPaise = (principalInRupees * 100).toInt();
    final rate = double.parse(_rateController.text);
    final tenure = int.parse(_tenureController.text);

    final request = CreateLoanRequest(
      name: _nameController.text.trim(),
      type: _selectedType!,
      principalAmount: principalInPaise,
      interestRate: rate,
      tenure: tenure,
      startDate: _selectedStartDate!,
      lender: _lenderController.text.trim().isEmpty ? null : _lenderController.text.trim(),
      accountNumber: _accountController.text.trim().isEmpty ? null : _accountController.text.trim(),
    );

    LoanModel? result;

    if (_isEditMode) {
      result = await ref.read(loansStateProvider.notifier).updateLoan(widget.loanId!, request);
    } else {
      result = await ref.read(loansStateProvider.notifier).createLoan(request);
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Loan updated' : 'Loan created'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(loansErrorProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save loan'),
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
    final loansState = ref.watch(loansStateProvider);
    final isOperationInProgress = loansState.isCreating || loansState.isUpdating;

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Loan' : 'Add Loan'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoadingLoan && _isEditMode && _existingLoan == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      title: 'Basic Details',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Loan Name',
                        hintText: 'e.g., Home Loan - HDFC',
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
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: isOperationInProgress ? null : _openLoanTypePicker,
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
                            if (_selectedType != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getLoanTypeIcon(_selectedType!),
                                  color: const Color(0xFF7C3AED),
                                  size: 20,
                                ),
                              )
                            else
                              Icon(
                                Iconsax.category,
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedType?.label ?? 'Select loan type',
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: _selectedType == null
                                      ? (isDark
                                          ? SpendexColors.darkTextTertiary
                                          : SpendexColors.lightTextTertiary)
                                      : (isDark
                                          ? SpendexColors.darkTextPrimary
                                          : SpendexColors.lightTextPrimary),
                                ),
                              ),
                            ),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _lenderController,
                      decoration: InputDecoration(
                        labelText: 'Lender Name (Optional)',
                        hintText: 'e.g., HDFC Bank, SBI',
                        prefixIcon: const Icon(Iconsax.bank),
                        filled: true,
                        fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                      ),
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      enabled: !isOperationInProgress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountController,
                      decoration: InputDecoration(
                        labelText: 'Account Number (Optional)',
                        hintText: 'e.g., 1234567890',
                        prefixIcon: const Icon(Iconsax.card),
                        filled: true,
                        fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !isOperationInProgress,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      title: 'EMI Calculator',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _principalController,
                      decoration: InputDecoration(
                        labelText: 'Principal Amount',
                        hintText: '5,00,000',
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
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ThousandsSeparatorFormatter(),
                      ],
                      validator: _validatePrincipal,
                      enabled: !isOperationInProgress,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rateController,
                            decoration: InputDecoration(
                              labelText: 'Interest Rate',
                              hintText: '8.50',
                              suffixText: '%',
                              prefixIcon: const Icon(Iconsax.percentage_circle),
                              filled: true,
                              fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            validator: _validateRate,
                            enabled: !isOperationInProgress,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _tenureController,
                            decoration: InputDecoration(
                              labelText: 'Tenure',
                              hintText: '240',
                              suffixText: 'months',
                              prefixIcon: const Icon(Iconsax.calendar),
                              filled: true,
                              fillColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                            ),
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: _validateTenure,
                            enabled: !isOperationInProgress,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_emiAmount > 0)
                      EmiBreakdownCard(
                        emiAmount: _emiAmount,
                        principalAmount: (CurrencyFormatter.parse(
                                  _principalController.text,
                                ) ??
                                0) *
                            100,
                        totalInterest: _totalInterest,
                        totalAmount: _totalAmount,
                        isDark: isDark,
                      ),
                    const SizedBox(height: 20),
                    _SectionTitle(
                      title: 'Start Date',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: isOperationInProgress ? null : _selectStartDate,
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
                                _selectedStartDate == null
                                    ? 'Select start date'
                                    : DateFormat('dd MMM yyyy').format(_selectedStartDate!),
                                style: SpendexTheme.bodyMedium.copyWith(
                                  color: _selectedStartDate == null
                                      ? (isDark
                                          ? SpendexColors.darkTextTertiary
                                          : SpendexColors.lightTextTertiary)
                                      : (isDark
                                          ? SpendexColors.darkTextPrimary
                                          : SpendexColors.lightTextPrimary),
                                ),
                              ),
                            ),
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
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isOperationInProgress || _isLoading ? null : _saveLoan,
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
                                _isEditMode ? 'Update Loan' : 'Create Loan',
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
