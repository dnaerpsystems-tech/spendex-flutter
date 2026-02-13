import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/providers/accounts_provider.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/presentation/providers/categories_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transactions_provider.dart';

/// Formatter for Indian number system (e.g., 1,00,000)
class IndianNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Format with Indian number system
    final formatted = _formatIndianNumber(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatIndianNumber(String value) {
    if (value.length <= 3) return value;

    final reversed = value.split('').reversed.toList();
    final result = <String>[];

    for (var i = 0; i < reversed.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) {
        result.add(',');
      }
      result.add(reversed[i]);
    }

    return result.reversed.join();
  }
}

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.transactionId});

  final String? transactionId;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedAccountId;
  String? _selectedCategoryId;
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isInitialized = false;
  // ignore: unused_field
  TransactionModel? _existingTransaction;

  bool get isEditMode => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load accounts and categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final accountsNotifier = ref.read(accountsStateProvider.notifier);
    final categoriesNotifier = ref.read(categoriesStateProvider.notifier);

    // Load accounts and categories in parallel
    await Future.wait([
      accountsNotifier.loadAccounts(),
      categoriesNotifier.loadAll(),
    ]);

    // If edit mode, load existing transaction
    if (isEditMode) {
      await _loadExistingTransaction();
    } else {
      // Set default account if available
      final defaultAccount = ref.read(defaultAccountProvider);
      if (defaultAccount != null) {
        setState(() {
          _selectedAccountId = defaultAccount.id;
        });
      }
    }

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadExistingTransaction() async {
    final transactionsNotifier = ref.read(transactionsStateProvider.notifier);
    final transaction =
        await transactionsNotifier.getTransactionById(widget.transactionId!);

    if (transaction != null) {
      setState(() {
        _existingTransaction = transaction;
        _type = transaction.type;
        _tabController.index = TransactionType.values.indexOf(_type);
        _amountController.text = _formatAmount(transaction.amount);
        _selectedAccountId = transaction.accountId;
        _selectedCategoryId = transaction.categoryId;
        _toAccountId = transaction.toAccountId;
        _selectedDate = transaction.date;
        _descriptionController.text = transaction.description ?? '';
        _notesController.text = transaction.notes ?? '';
      });
    }
  }

  String _formatAmount(int amountInPaise) {
    final rupees = (amountInPaise / 100).round();
    return _formatWithCommas(rupees.toString());
  }

  String _formatWithCommas(String value) {
    if (value.length <= 3) return value;

    final reversed = value.split('').reversed.toList();
    final result = <String>[];

    for (var i = 0; i < reversed.length; i++) {
      if (i == 3 || (i > 3 && (i - 3) % 2 == 0)) {
        result.add(',');
      }
      result.add(reversed[i]);
    }

    return result.reversed.join();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _type = TransactionType.values[_tabController.index];
        // Clear category when switching between income/expense and transfer
        if (_type == TransactionType.transfer) {
          _selectedCategoryId = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _getTypeColor() {
    switch (_type) {
      case TransactionType.income:
        return SpendexColors.income;
      case TransactionType.expense:
        return SpendexColors.expense;
      case TransactionType.transfer:
        return SpendexColors.transfer;
    }
  }

  int _parseAmount(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return 0;
    return int.parse(digitsOnly) * 100; // Convert to paise
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final amount = _parseAmount(value);
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > AppConstants.maxTransactionAmount) {
      return 'Amount exceeds maximum limit';
    }
    return null;
  }

  String? _validateAccount() {
    if (_selectedAccountId == null) {
      return 'Please select an account';
    }
    return null;
  }

  String? _validateToAccount() {
    if (_type == TransactionType.transfer) {
      if (_toAccountId == null) {
        return 'Please select destination account';
      }
      if (_toAccountId == _selectedAccountId) {
        return 'From and To accounts must be different';
      }
    }
    return null;
  }

  String? _validateCategory() {
    if (_type != TransactionType.transfer && _selectedCategoryId == null) {
      return 'Please select a category';
    }
    return null;
  }

  bool _validateForm() {
    final isFormValid = _formKey.currentState?.validate() ?? false;
    final accountError = _validateAccount();
    final toAccountError = _validateToAccount();
    final categoryError = _validateCategory();

    if (!isFormValid) return false;

    if (accountError != null) {
      _showErrorSnackBar(accountError);
      return false;
    }

    if (toAccountError != null) {
      _showErrorSnackBar(toAccountError);
      return false;
    }

    if (categoryError != null) {
      _showErrorSnackBar(categoryError);
      return false;
    }

    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.income,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionsNotifier =
          ref.read(transactionsStateProvider.notifier);

      final request = CreateTransactionRequest(
        type: _type,
        amount: _parseAmount(_amountController.text),
        accountId: _selectedAccountId!,
        categoryId: _type != TransactionType.transfer ? _selectedCategoryId : null,
        toAccountId: _type == TransactionType.transfer ? _toAccountId : null,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        date: _selectedDate,
      );

      TransactionModel? result;

      if (isEditMode) {
        result = await transactionsNotifier.updateTransaction(
          widget.transactionId!,
          request,
        );
      } else {
        result = await transactionsNotifier.createTransaction(request);
      }

      if (result != null) {
        _showSuccessSnackBar(
          isEditMode
              ? 'Transaction updated successfully'
              : 'Transaction added successfully',
        );

        // Refresh accounts to update balances
        ref.read(accountsStateProvider.notifier).loadAll();

        if (mounted) {
          context.go(AppRoutes.transactions);
        }
      } else {
        final error = ref.read(transactionsStateProvider).error;
        _showErrorSnackBar(error ?? 'Failed to save transaction');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _getTypeColor(),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      children: [
        Text(
          text,
          style: SpendexTheme.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (isRequired)
          Text(
            ' *',
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.expense,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsState = ref.watch(accountsStateProvider);
    final categoriesState = ref.watch(categoriesStateProvider);
    final transactionsState = ref.watch(transactionsStateProvider);

    final isOperationInProgress = _isLoading ||
        transactionsState.isCreating ||
        transactionsState.isUpdating;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Iconsax.close_square),
          onPressed: isOperationInProgress
              ? null
              : () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: !_isInitialized
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Transaction Type Tabs
                  _buildTypeTabs(isDark),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Amount Field
                          _buildAmountField(isDark),

                          const SizedBox(height: 24),

                          // Account Selector
                          _buildLabel(
                            _type == TransactionType.transfer
                                ? 'From Account'
                                : 'Account',
                            isRequired: true,
                          ),
                          const SizedBox(height: 8),
                          _AccountSelector(
                            accounts: accountsState.accounts,
                            selectedId: _selectedAccountId,
                            excludeId: _type == TransactionType.transfer
                                ? _toAccountId
                                : null,
                            isDark: isDark,
                            isLoading: accountsState.isLoading,
                            typeColor: _getTypeColor(),
                            onSelect: (id) {
                              setState(() {
                                _selectedAccountId = id;
                              });
                            },
                          ),

                          // To Account (for transfers)
                          if (_type == TransactionType.transfer) ...[
                            const SizedBox(height: 20),
                            _buildLabel('To Account', isRequired: true),
                            const SizedBox(height: 8),
                            _AccountSelector(
                              accounts: accountsState.accounts,
                              selectedId: _toAccountId,
                              excludeId: _selectedAccountId,
                              isDark: isDark,
                              isLoading: accountsState.isLoading,
                              typeColor: _getTypeColor(),
                              onSelect: (id) {
                                setState(() {
                                  _toAccountId = id;
                                });
                              },
                            ),
                          ],

                          // Category Selector (for income/expense)
                          if (_type != TransactionType.transfer) ...[
                            const SizedBox(height: 20),
                            _buildLabel('Category', isRequired: true),
                            const SizedBox(height: 8),
                            _CategorySelector(
                              categories: _type == TransactionType.income
                                  ? categoriesState.incomeCategories
                                  : categoriesState.expenseCategories,
                              selectedId: _selectedCategoryId,
                              isDark: isDark,
                              isLoading: _type == TransactionType.income
                                  ? categoriesState.isIncomeLoading
                                  : categoriesState.isExpenseLoading,
                              typeColor: _getTypeColor(),
                              onSelect: (id) {
                                setState(() {
                                  _selectedCategoryId = id;
                                });
                              },
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Date Picker
                          _buildLabel('Date', isRequired: true),
                          const SizedBox(height: 8),
                          _buildDatePicker(isDark),

                          const SizedBox(height: 20),

                          // Description
                          _buildLabel('Description'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            textInputAction: TextInputAction.next,
                            maxLength: AppConstants.maxDescriptionLength,
                            decoration: InputDecoration(
                              hintText: 'What was this for?',
                              counterText: '',
                              prefixIcon: Icon(
                                Iconsax.note_text,
                                color: isDark
                                    ? SpendexColors.darkTextTertiary
                                    : SpendexColors.lightTextTertiary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Notes (Optional)
                          _buildLabel('Notes (Optional)'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            maxLength: AppConstants.maxNoteLength,
                            decoration: InputDecoration(
                              hintText: 'Add any additional notes...',
                              counterText: '',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 48),
                                child: Icon(
                                  Iconsax.document_text,
                                  color: isDark
                                      ? SpendexColors.darkTextTertiary
                                      : SpendexColors.lightTextTertiary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  _buildSubmitButton(isOperationInProgress),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: _getTypeColor(),
            borderRadius: BorderRadius.circular(12),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
          labelStyle: SpendexTheme.titleMedium,
          unselectedLabelStyle: SpendexTheme.titleMedium,
          tabs: const [
            Tab(text: 'Expense'),
            Tab(text: 'Income'),
            Tab(text: 'Transfer'),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Amount', isRequired: true),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            ),
          ),
          child: TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            style: SpendexTheme.displayLarge.copyWith(
              color: _getTypeColor(),
              fontSize: 36,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              IndianNumberFormatter(),
            ],
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: SpendexTheme.displayLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 36,
              ),
              prefixText: '${AppConstants.currencySymbol} ',
              prefixStyle: SpendexTheme.displayLarge.copyWith(
                color: _getTypeColor(),
                fontSize: 36,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: _validateAmount,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar,
              color: _getTypeColor(),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
              style: SpendexTheme.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Iconsax.arrow_down_1,
              size: 16,
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isOperationInProgress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isOperationInProgress ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getTypeColor(),
            disabledBackgroundColor: _getTypeColor().withValues(alpha: 0.5),
          ),
          child: isOperationInProgress
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  isEditMode
                      ? 'Update ${_type.label}'
                      : 'Add ${_type.label}',
                ),
        ),
      ),
    );
  }
}

/// Account Selector Widget
class _AccountSelector extends StatelessWidget {
  const _AccountSelector({
    required this.accounts,
    required this.selectedId,
    required this.isDark,
    required this.isLoading,
    required this.typeColor,
    required this.onSelect,
    this.excludeId,
  });

  final List<AccountModel> accounts;
  final String? selectedId;
  final String? excludeId;
  final bool isDark;
  final bool isLoading;
  final Color typeColor;
  final void Function(String) onSelect;

  IconData _getAccountIcon(AccountType type) {
    switch (type) {
      case AccountType.savings:
        return Iconsax.bank;
      case AccountType.current:
        return Iconsax.building;
      case AccountType.creditCard:
        return Iconsax.card;
      case AccountType.cash:
        return Iconsax.money;
      case AccountType.wallet:
        return Iconsax.wallet_1;
      case AccountType.investment:
        return Iconsax.chart;
      case AccountType.loan:
        return Iconsax.receipt_item;
      case AccountType.other:
        return Iconsax.more_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filteredAccounts = excludeId != null
        ? accounts.where((a) => a.id != excludeId).toList()
        : accounts;

    if (filteredAccounts.isEmpty) {
      return Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Center(
          child: Text(
            'No accounts available',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filteredAccounts.length,
        itemBuilder: (context, index) {
          final account = filteredAccounts[index];
          final isSelected = selectedId == account.id;

          return GestureDetector(
            onTap: () => onSelect(account.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? typeColor.withValues(alpha: 0.1)
                    : isDark
                        ? SpendexColors.darkSurface
                        : SpendexColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? typeColor
                      : isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getAccountIcon(account.type),
                    color: isSelected
                        ? typeColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    account.name,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isSelected
                          ? typeColor
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${NumberFormat('#,##,###').format(account.balanceInRupees)}',
                    style: SpendexTheme.labelMedium.copyWith(
                      fontSize: 10,
                      color: isDark
                          ? SpendexColors.darkTextTertiary
                          : SpendexColors.lightTextTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Category Selector Widget
class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.isDark,
    required this.isLoading,
    required this.typeColor,
    required this.onSelect,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final bool isDark;
  final bool isLoading;
  final Color typeColor;
  final void Function(String) onSelect;

  IconData _getCategoryIcon(String? iconName) {
    // Map category icon names to Iconsax icons
    final iconMap = <String, IconData>{
      'salary': Iconsax.money_recive,
      'freelance': Iconsax.briefcase,
      'investments': Iconsax.chart,
      'gifts': Iconsax.gift,
      'refunds': Iconsax.refresh,
      'rental': Iconsax.home,
      'food': Iconsax.coffee,
      'transport': Iconsax.car,
      'shopping': Iconsax.shopping_bag,
      'bills': Iconsax.receipt,
      'entertainment': Iconsax.video,
      'health': Iconsax.health,
      'education': Iconsax.book,
      'travel': Iconsax.airplane,
      'groceries': Iconsax.shopping_cart,
      'utilities': Iconsax.flash,
      'insurance': Iconsax.shield_tick,
      'subscriptions': Iconsax.document,
      'other': Iconsax.more_circle,
    };

    if (iconName != null && iconMap.containsKey(iconName.toLowerCase())) {
      return iconMap[iconName.toLowerCase()]!;
    }

    return Iconsax.category;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Center(
          child: Text(
            'No categories available',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedId == category.id;

        return GestureDetector(
          onTap: () => onSelect(category.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? typeColor.withValues(alpha: 0.1)
                  : isDark
                      ? SpendexColors.darkSurface
                      : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? typeColor
                    : isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  color: isSelected
                      ? typeColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category.name,
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isSelected
                        ? typeColor
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
