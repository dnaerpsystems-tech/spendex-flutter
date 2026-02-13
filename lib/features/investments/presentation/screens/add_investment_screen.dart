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
import '../../data/models/investment_model.dart';
import '../providers/investments_provider.dart';
import '../widgets/investment_type_picker_modal.dart';

/// Add/Edit Investment Screen
///
/// Full form with dynamic type-specific fields for creating or editing investments.
/// Supports all investment types with conditional field rendering based on selected type.
/// Includes validation, auto-calculations, and tax saving options.
class AddInvestmentScreen extends ConsumerStatefulWidget {
  const AddInvestmentScreen({
    super.key,
    this.investmentId,
  });

  /// Optional investment ID for editing mode.
  /// If null, the screen operates in create mode.
  final String? investmentId;

  @override
  ConsumerState<AddInvestmentScreen> createState() =>
      _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Common controllers
  final _nameController = TextEditingController();
  final _investedAmountController = TextEditingController();
  final _purchaseDateController = TextEditingController();

  // Mutual Fund controllers
  final _schemeCodeController = TextEditingController();
  final _folioController = TextEditingController();
  final _unitsController = TextEditingController();
  final _navController = TextEditingController();

  // Stock controllers
  final _symbolController = TextEditingController();
  final _isinController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _brokerController = TextEditingController();

  // FD/RD controllers
  final _bankController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();
  final _maturityDateController = TextEditingController();
  final _maturityAmountController = TextEditingController();

  // PPF/EPF/NPS controllers
  final _accountNumberController = TextEditingController();
  final _yearlyContributionController = TextEditingController();

  // Gold/SGB controllers
  final _weightController = TextEditingController();
  final _pricePerGramController = TextEditingController();

  // Selected values
  InvestmentType? _selectedType;
  DateTime? _selectedPurchaseDate;
  DateTime? _selectedMaturityDate;
  bool _taxSaving = false;
  TaxSection? _selectedTaxSection;

  // State
  bool _isLoadingInvestment = false;
  bool _isFormDirty = false;

  bool get isEditing => widget.investmentId != null;

  @override
  void initState() {
    super.initState();
    _setupControllerListeners();

    if (isEditing) {
      _loadInvestmentForEditing();
    }
  }

  void _setupControllerListeners() {
    _nameController.addListener(_markFormDirty);
    _investedAmountController.addListener(_markFormDirty);

    // Auto-calculate invested amount for MF (units * NAV)
    _unitsController.addListener(_calculateMFInvestedAmount);
    _navController.addListener(_calculateMFInvestedAmount);

    // Auto-calculate invested amount for Stock (quantity * price)
    _quantityController.addListener(_calculateStockInvestedAmount);
    _priceController.addListener(_calculateStockInvestedAmount);

    // Auto-calculate maturity amount for FD/RD
    _interestRateController.addListener(_calculateMaturityAmount);
    _tenureController.addListener(_calculateMaturityAmount);

    // Auto-calculate invested amount for Gold (weight * price)
    _weightController.addListener(_calculateGoldInvestedAmount);
    _pricePerGramController.addListener(_calculateGoldInvestedAmount);
  }

  void _markFormDirty() {
    if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }

  void _calculateMFInvestedAmount() {
    if (_selectedType == InvestmentType.mutualFund) {
      final units = double.tryParse(_unitsController.text) ?? 0;
      final nav = double.tryParse(_navController.text) ?? 0;
      if (units > 0 && nav > 0) {
        final amount = units * nav;
        _investedAmountController.text = amount.toStringAsFixed(2);
      }
    }
  }

  void _calculateStockInvestedAmount() {
    if (_selectedType == InvestmentType.stock) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0;
      if (quantity > 0 && price > 0) {
        final amount = quantity * price;
        _investedAmountController.text = amount.toStringAsFixed(2);
      }
    }
  }

  void _calculateGoldInvestedAmount() {
    if (_selectedType == InvestmentType.gold ||
        _selectedType == InvestmentType.sovereignGoldBond) {
      final weight = double.tryParse(_weightController.text) ?? 0;
      final pricePerGram = double.tryParse(_pricePerGramController.text) ?? 0;
      if (weight > 0 && pricePerGram > 0) {
        final amount = weight * pricePerGram;
        _investedAmountController.text = amount.toStringAsFixed(2);
      }
    }
  }

  void _calculateMaturityAmount() {
    if (_selectedType == InvestmentType.fixedDeposit ||
        _selectedType == InvestmentType.recurringDeposit) {
      final principal = double.tryParse(
            _investedAmountController.text.replaceAll(',', ''),
          ) ??
          0;
      final rate = double.tryParse(_interestRateController.text) ?? 0;
      final tenureMonths = int.tryParse(_tenureController.text) ?? 0;

      if (principal > 0 && rate > 0 && tenureMonths > 0) {
        final actualYears = tenureMonths / 12;
        final rateDecimal = rate / 100;
        const n = 4;

        final maturityAmount =
            principal * math.pow(1 + rateDecimal / n, n * actualYears);

        _maturityAmountController.text = maturityAmount.toStringAsFixed(2);

        if (_selectedPurchaseDate != null) {
          _selectedMaturityDate = DateTime(
            _selectedPurchaseDate!.year,
            _selectedPurchaseDate!.month + tenureMonths,
            _selectedPurchaseDate!.day,
          );
          _maturityDateController.text =
              DateFormat('dd MMM yyyy').format(_selectedMaturityDate!);
        }
      }
    }
  }

  Future<void> _loadInvestmentForEditing() async {
    setState(() {
      _isLoadingInvestment = true;
    });

    final investment = await ref
        .read(investmentsStateProvider.notifier)
        .loadInvestmentById(widget.investmentId!);

    if (investment != null && mounted) {
      setState(() {
        _populateFields(investment);
        _isFormDirty = false;
        _isLoadingInvestment = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingInvestment = false;
      });
      _showErrorSnackBar('Investment not found');
      context.pop();
    }
  }

  void _populateFields(InvestmentModel investment) {
    _nameController.text = investment.name;
    _investedAmountController.text =
        investment.investedAmountInRupees.toStringAsFixed(2);
    _selectedType = investment.type;

    if (investment.purchaseDate != null) {
      _selectedPurchaseDate = investment.purchaseDate;
      _purchaseDateController.text =
          DateFormat('dd MMM yyyy').format(investment.purchaseDate!);
    }

    _taxSaving = investment.taxSaving;
    _selectedTaxSection = investment.taxSection;

    // Mutual Fund fields
    if (investment.type == InvestmentType.mutualFund) {
      _schemeCodeController.text = investment.symbol ?? '';
      _folioController.text = investment.folioNumber ?? '';
      if (investment.units != null) {
        _unitsController.text = investment.units!.toStringAsFixed(4);
      }
      if (investment.purchasePrice != null) {
        _navController.text =
            investment.purchasePriceInRupees!.toStringAsFixed(2);
      }
    }

    // Stock fields
    if (investment.type == InvestmentType.stock) {
      _symbolController.text = investment.symbol ?? '';
      _isinController.text = investment.isin ?? '';
      if (investment.units != null) {
        _quantityController.text = investment.units!.toInt().toString();
      }
      if (investment.purchasePrice != null) {
        _priceController.text =
            investment.purchasePriceInRupees!.toStringAsFixed(2);
      }
      _brokerController.text = investment.broker ?? '';
    }

    // FD/RD fields
    if (investment.type == InvestmentType.fixedDeposit ||
        investment.type == InvestmentType.recurringDeposit) {
      _bankController.text = investment.symbol ?? '';
      if (investment.interestRate != null) {
        _interestRateController.text =
            investment.interestRate!.toStringAsFixed(2);
      }
      if (investment.maturityDate != null) {
        _selectedMaturityDate = investment.maturityDate;
        _maturityDateController.text =
            DateFormat('dd MMM yyyy').format(investment.maturityDate!);

        // Calculate tenure in months
        if (_selectedPurchaseDate != null) {
          final months = (_selectedMaturityDate!.year -
                  _selectedPurchaseDate!.year) *
              12 +
              _selectedMaturityDate!.month -
              _selectedPurchaseDate!.month;
          _tenureController.text = months.toString();
        }
      }
      if (investment.maturityAmount != null) {
        _maturityAmountController.text =
            investment.maturityAmountInRupees!.toStringAsFixed(2);
      }
    }

    // PPF/EPF/NPS fields
    if (investment.type == InvestmentType.ppf ||
        investment.type == InvestmentType.epf ||
        investment.type == InvestmentType.nps) {
      _accountNumberController.text = investment.folioNumber ?? '';
    }

    // Gold/SGB fields
    if (investment.type == InvestmentType.gold ||
        investment.type == InvestmentType.sovereignGoldBond) {
      if (investment.units != null) {
        _weightController.text = investment.units!.toStringAsFixed(3);
      }
      if (investment.purchasePrice != null) {
        _pricePerGramController.text =
            investment.purchasePriceInRupees!.toStringAsFixed(2);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedAmountController.dispose();
    _purchaseDateController.dispose();
    _schemeCodeController.dispose();
    _folioController.dispose();
    _unitsController.dispose();
    _navController.dispose();
    _symbolController.dispose();
    _isinController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _brokerController.dispose();
    _bankController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    _maturityDateController.dispose();
    _maturityAmountController.dispose();
    _accountNumberController.dispose();
    _yearlyContributionController.dispose();
    _weightController.dispose();
    _pricePerGramController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_isFormDirty) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Discard',
              style: TextStyle(color: SpendexColors.expense),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleTypeSelection() async {
    if (isEditing) {
      _showInfoSnackBar('Investment type cannot be changed while editing');
      return;
    }

    await showModalBottomSheet<InvestmentType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvestmentTypePickerModal(
        selectedType: _selectedType,
        onTypeSelected: (type) {
          setState(() {
            _selectedType = type;
            _markFormDirty();
            _autoSetTaxSection(type);
          });
        },
      ),
    );
  }

  void _autoSetTaxSection(InvestmentType type) {
    switch (type) {
      case InvestmentType.ppf:
      case InvestmentType.epf:
        _taxSaving = true;
        _selectedTaxSection = TaxSection.section80C;
        break;
      case InvestmentType.nps:
        _taxSaving = true;
        _selectedTaxSection = TaxSection.section80CCD;
        break;
      default:
        break;
    }
  }

  Future<void> _selectPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedPurchaseDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
      setState(() {
        _selectedPurchaseDate = date;
        _purchaseDateController.text = DateFormat('dd MMM yyyy').format(date);
        _markFormDirty();
      });
    }
  }

  Future<void> _selectMaturityDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedMaturityDate ??
          DateTime.now().add(const Duration(days: 365)),
      firstDate: _selectedPurchaseDate ?? DateTime.now(),
      lastDate: DateTime(2050),
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
      setState(() {
        _selectedMaturityDate = date;
        _maturityDateController.text = DateFormat('dd MMM yyyy').format(date);
        _markFormDirty();
      });
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Investment name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    return null;
  }

  String? _validateInvestedAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Invested amount is required';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 99999999) {
      return 'Maximum amount is ₹9,99,99,999';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateInterestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Interest rate is required';
    }
    final rate = double.tryParse(value);
    if (rate == null) {
      return 'Please enter a valid rate';
    }
    if (rate < 1 || rate > 15) {
      return 'Rate must be between 1% and 15%';
    }
    return null;
  }

  String? _validateTenure(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tenure is required';
    }
    final tenure = int.tryParse(value);
    if (tenure == null) {
      return 'Please enter a valid tenure';
    }
    if (tenure < 1 || tenure > 120) {
      return 'Tenure must be between 1 and 120 months';
    }
    return null;
  }

  Future<void> _saveInvestment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      _showErrorSnackBar('Please select an investment type');
      return;
    }

    final investedAmount =
        double.parse(_investedAmountController.text.replaceAll(',', ''));
    final investedAmountInPaise = (investedAmount * 100).toInt();

    final request = CreateInvestmentRequest(
      name: _nameController.text.trim(),
      type: _selectedType!,
      investedAmount: investedAmountInPaise,
      purchaseDate: _selectedPurchaseDate,
      taxSaving: _taxSaving,
      taxSection: _taxSaving ? _selectedTaxSection : null,
      symbol: _getSymbolValue(),
      isin: _isinController.text.trim().isEmpty
          ? null
          : _isinController.text.trim(),
      folioNumber: _getFolioValue(),
      units: _getUnitsValue(),
      purchasePrice: _getPurchasePriceValue(),
      interestRate: _getInterestRateValue(),
      maturityDate: _selectedMaturityDate,
      maturityAmount: _getMaturityAmountValue(),
      broker: _brokerController.text.trim().isEmpty
          ? null
          : _brokerController.text.trim(),
    );

    final notifier = ref.read(investmentsStateProvider.notifier);
    InvestmentModel? result;

    if (isEditing) {
      result = await notifier.updateInvestment(
        widget.investmentId!,
        request,
      );
    } else {
      result = await notifier.createInvestment(request);
    }

    if (!mounted) return;

    if (result != null) {
      _showSuccessSnackBar(
        isEditing
            ? 'Investment updated successfully'
            : 'Investment created successfully',
      );
      context.pop();
    } else {
      final error = ref.read(investmentsStateProvider).error;
      _showErrorSnackBar(error ?? 'Failed to save investment');
    }
  }

  String? _getSymbolValue() {
    switch (_selectedType) {
      case InvestmentType.mutualFund:
        return _schemeCodeController.text.trim().isEmpty
            ? null
            : _schemeCodeController.text.trim();
      case InvestmentType.stock:
        return _symbolController.text.trim().isEmpty
            ? null
            : _symbolController.text.trim();
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return _bankController.text.trim().isEmpty
            ? null
            : _bankController.text.trim();
      default:
        return null;
    }
  }

  String? _getFolioValue() {
    if (_selectedType == InvestmentType.mutualFund) {
      return _folioController.text.trim().isEmpty
          ? null
          : _folioController.text.trim();
    } else if (_selectedType == InvestmentType.ppf ||
        _selectedType == InvestmentType.epf ||
        _selectedType == InvestmentType.nps) {
      return _accountNumberController.text.trim().isEmpty
          ? null
          : _accountNumberController.text.trim();
    }
    return null;
  }

  double? _getUnitsValue() {
    if (_selectedType == InvestmentType.mutualFund) {
      return double.tryParse(_unitsController.text);
    } else if (_selectedType == InvestmentType.stock) {
      return double.tryParse(_quantityController.text);
    } else if (_selectedType == InvestmentType.gold ||
        _selectedType == InvestmentType.sovereignGoldBond) {
      return double.tryParse(_weightController.text);
    }
    return null;
  }

  int? _getPurchasePriceValue() {
    String? priceText;

    if (_selectedType == InvestmentType.mutualFund) {
      priceText = _navController.text;
    } else if (_selectedType == InvestmentType.stock) {
      priceText = _priceController.text;
    } else if (_selectedType == InvestmentType.gold ||
        _selectedType == InvestmentType.sovereignGoldBond) {
      priceText = _pricePerGramController.text;
    }

    if (priceText != null && priceText.isNotEmpty) {
      final price = double.tryParse(priceText.replaceAll(',', ''));
      return price != null ? (price * 100).toInt() : null;
    }
    return null;
  }

  double? _getInterestRateValue() {
    if (_selectedType == InvestmentType.fixedDeposit ||
        _selectedType == InvestmentType.recurringDeposit) {
      return double.tryParse(_interestRateController.text);
    }
    return null;
  }

  int? _getMaturityAmountValue() {
    if (_selectedType == InvestmentType.fixedDeposit ||
        _selectedType == InvestmentType.recurringDeposit) {
      final amount = double.tryParse(
          _maturityAmountController.text.replaceAll(',', ''));
      return amount != null ? (amount * 100).toInt() : null;
    }
    return null;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
        children: [
          const Icon(Iconsax.tick_circle, color: Colors.white),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(child: Text(message)),
        ],
      ),
        backgroundColor: SpendexColors.income,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Colors.white),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.info_circle, color: Colors.white),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: SpendexColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(investmentsStateProvider).isCreating ||
        ref.watch(investmentsStateProvider).isUpdating;

    if (_isLoadingInvestment) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: !_isFormDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _isFormDirty) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            if (context.mounted) {
              context.pop();
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Investment' : 'Add Investment'),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () async {
              if (_isFormDirty) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommonSection(),
                const SizedBox(height: SpendexTheme.spacingXl),
                if (_selectedType != null) ...[
                  _buildTypeSpecificFields(),
                  const SizedBox(height: SpendexTheme.spacingXl),
                ],
                _buildTaxSavingSection(),
                const SizedBox(height: SpendexTheme.spacing2xl),
                _buildSaveButton(isLoading),
                const SizedBox(height: SpendexTheme.spacingXl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Basic Information'),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Investment Name',
            hintText: 'e.g., SBI FD, Reliance Stock, PPF Account',
            prefixIcon: Icon(Iconsax.edit),
          ),
          textCapitalization: TextCapitalization.words,
          validator: _validateName,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        InkWell(
          onTap: _handleTypeSelection,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Investment Type',
              hintText: 'Select investment type',
              prefixIcon: const Icon(Iconsax.category),
              suffixIcon: const Icon(Iconsax.arrow_down_1),
              enabled: !isEditing,
            ),
            child: Text(
              _selectedType?.label ?? 'Select type',
              style: _selectedType != null
                  ? null
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
            ),
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _investedAmountController,
          decoration: InputDecoration(
            labelText: 'Invested Amount',
            hintText: '0.00',
            prefixText: '${CurrencyFormatter.symbol} ',
            prefixIcon: const Icon(Iconsax.wallet_money),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          validator: _validateInvestedAmount,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        InkWell(
          onTap: _selectPurchaseDate,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Purchase Date (Optional)',
              hintText: 'Select date',
              prefixIcon: Icon(Iconsax.calendar),
            ),
            child: Text(
              _selectedPurchaseDate != null
                  ? DateFormat('dd MMM yyyy').format(_selectedPurchaseDate!)
                  : 'Select date',
              style: _selectedPurchaseDate != null
                  ? null
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificFields() {
    switch (_selectedType!) {
      case InvestmentType.mutualFund:
        return _buildMutualFundFields();
      case InvestmentType.stock:
        return _buildStockFields();
      case InvestmentType.fixedDeposit:
      case InvestmentType.recurringDeposit:
        return _buildFDFields();
      case InvestmentType.ppf:
      case InvestmentType.epf:
      case InvestmentType.nps:
        return _buildRetirementFields();
      case InvestmentType.gold:
      case InvestmentType.sovereignGoldBond:
        return _buildGoldFields();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMutualFundFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Mutual Fund Details'),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _schemeCodeController,
          decoration: InputDecoration(
            labelText: 'Scheme Code/Name',
            hintText: 'e.g., HDFC Top 100',
            prefixIcon: Icon(Iconsax.document_text),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _folioController,
          decoration: InputDecoration(
            labelText: 'Folio Number (Optional)',
            hintText: 'Enter folio number',
            prefixIcon: Icon(Iconsax.card),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _unitsController,
                decoration: InputDecoration(
                  labelText: 'Units',
                  hintText: '0.0000',
                  prefixIcon: Icon(Iconsax.note),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,4}')),
                ],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: TextFormField(
                controller: _navController,
                decoration: InputDecoration(
                  labelText: 'NAV/Price',
                  hintText: '0.00',
                  prefixText: '${CurrencyFormatter.symbol} ',
                  prefixIcon: const Icon(Iconsax.money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Stock Details'),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _symbolController,
          decoration: InputDecoration(
            labelText: 'Stock Symbol',
            hintText: 'e.g., RELIANCE, TCS, INFY',
            prefixIcon: Icon(Iconsax.chart_1),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: (value) => _validateRequired(value, 'Stock symbol'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _isinController,
          decoration: InputDecoration(
            labelText: 'ISIN (Optional)',
            hintText: 'Enter ISIN',
            prefixIcon: Icon(Iconsax.barcode),
          ),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: '0',
                  prefixIcon: Icon(Iconsax.note),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => _validateRequired(value, 'Quantity'),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Purchase Price',
                  hintText: '0.00',
                  prefixText: '${CurrencyFormatter.symbol} ',
                  prefixIcon: const Icon(Iconsax.money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) => _validateRequired(value, 'Price'),
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _brokerController,
          decoration: InputDecoration(
            labelText: 'Broker (Optional)',
            hintText: 'e.g., Zerodha, Groww, Upstox',
            prefixIcon: Icon(Iconsax.building),
          ),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildFDFields() {
    final isFD = _selectedType == InvestmentType.fixedDeposit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: isFD ? 'Fixed Deposit Details' : 'Recurring Deposit Details',
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _bankController,
          decoration: InputDecoration(
            labelText: 'Bank Name',
            hintText: 'e.g., SBI, HDFC, ICICI',
            prefixIcon: Icon(Iconsax.bank),
          ),
          textCapitalization: TextCapitalization.words,
          validator: (value) => _validateRequired(value, 'Bank name'),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _interestRateController,
                decoration: InputDecoration(
                  labelText: 'Interest Rate',
                  hintText: '0.00',
                  suffixText: '%',
                  prefixIcon: Icon(Iconsax.percentage_circle),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: _validateInterestRate,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: TextFormField(
                controller: _tenureController,
                decoration: InputDecoration(
                  labelText: 'Tenure',
                  hintText: '12',
                  suffixText: 'months',
                  prefixIcon: Icon(Iconsax.timer),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _validateTenure,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        InkWell(
          onTap: _selectMaturityDate,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Maturity Date',
              hintText: 'Auto-calculated or select',
              prefixIcon: Icon(Iconsax.calendar_1),
            ),
            child: Text(
              _selectedMaturityDate != null
                  ? DateFormat('dd MMM yyyy').format(_selectedMaturityDate!)
                  : 'Auto-calculated',
              style: _selectedMaturityDate != null
                  ? null
                  : Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
            ),
          ),
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _maturityAmountController,
          decoration: InputDecoration(
            labelText: 'Maturity Amount',
            hintText: 'Auto-calculated',
            prefixText: '${CurrencyFormatter.symbol} ',
            prefixIcon: const Icon(Iconsax.wallet_money),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          textInputAction: TextInputAction.next,
          readOnly: true,
          style: TextStyle(
            color: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.color
                ?.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildRetirementFields() {
    String title;
    switch (_selectedType!) {
      case InvestmentType.ppf:
        title = 'PPF Details';
        break;
      case InvestmentType.epf:
        title = 'EPF Details';
        break;
      case InvestmentType.nps:
        title = 'NPS Details';
        break;
      default:
        title = 'Retirement Account Details';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _accountNumberController,
          decoration: InputDecoration(
            labelText: 'Account Number (Optional)',
            hintText: 'Enter account number',
            prefixIcon: Icon(Iconsax.card),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: SpendexTheme.spacingMd),
        TextFormField(
          controller: _yearlyContributionController,
          decoration: InputDecoration(
            labelText: 'Yearly Contribution (Optional)',
            hintText: '0.00',
            prefixText: '${CurrencyFormatter.symbol} ',
            prefixIcon: const Icon(Iconsax.wallet_add),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildGoldFields() {
    final isSGB = _selectedType == InvestmentType.sovereignGoldBond;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: isSGB ? 'Gold Bond Details' : 'Gold Details'),
        const SizedBox(height: SpendexTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: isSGB ? 'Units' : 'Weight',
                  hintText: '0.000',
                  suffixText: isSGB ? 'units' : 'grams',
                  prefixIcon: const Icon(Iconsax.weight),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
                ],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: TextFormField(
                controller: _pricePerGramController,
                decoration: InputDecoration(
                  labelText: isSGB ? 'Price/Unit' : 'Price/Gram',
                  hintText: '0.00',
                  prefixText: '${CurrencyFormatter.symbol} ',
                  prefixIcon: const Icon(Iconsax.money),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaxSavingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Tax Saving'),
        const SizedBox(height: SpendexTheme.spacingMd),
        SwitchListTile(
          value: _taxSaving,
          onChanged: (value) {
            setState(() {
              _taxSaving = value;
              if (!value) {
                _selectedTaxSection = null;
              }
              _markFormDirty();
            });
          },
          title: const Text('Tax Saving Investment'),
          subtitle: const Text('Eligible for tax deduction'),
          contentPadding: EdgeInsets.zero,
        ),
        if (_taxSaving) ...[
          const SizedBox(height: SpendexTheme.spacingMd),
          DropdownButtonFormField<TaxSection>(
            initialValue: _selectedTaxSection,
            decoration: InputDecoration(
              labelText: 'Tax Section',
              hintText: 'Select tax section',
              prefixIcon: Icon(Iconsax.receipt_minus),
            ),
            items: TaxSection.values
                .where((section) => section != TaxSection.none)
                .map((section) {
              return DropdownMenuItem<TaxSection>(
                value: section,
                child: Text(section.label),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTaxSection = value;
                _markFormDirty();
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveInvestment,
        style: ElevatedButton.styleFrom(
          backgroundColor: SpendexColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                isEditing ? 'Update Investment' : 'Add Investment',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: SpendexColors.primary,
      ),
    );
  }
}
