import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/account_model.dart';
import '../providers/accounts_provider.dart';
import '../widgets/account_card.dart';
import '../widgets/account_type_selector.dart';

/// Add/Edit Account Screen
/// Full form with validation for creating or editing accounts
class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({
    super.key,
    this.accountId,
  });
  final String? accountId;

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _balanceController = TextEditingController();
  final _creditLimitController = TextEditingController();

  AccountType? _selectedType;
  bool _isDefault = false;
  bool _isFormDirty = false;
  bool _isLoadingAccount = false;

  bool get isEditing => widget.accountId != null;

  @override
  void initState() {
    super.initState();
    _setupListeners();

    if (isEditing) {
      _loadAccountForEditing();
    }
  }

  void _setupListeners() {
    _nameController.addListener(_markFormDirty);
    _bankNameController.addListener(_markFormDirty);
    _accountNumberController.addListener(_markFormDirty);
    _balanceController.addListener(_markFormDirty);
    _creditLimitController.addListener(_markFormDirty);
  }

  void _markFormDirty() {
    if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }

  Future<void> _loadAccountForEditing() async {
    setState(() {
      _isLoadingAccount = true;
    });

    final account =
        await ref.read(accountsStateProvider.notifier).getAccountById(widget.accountId!);

    if (account != null && mounted) {
      setState(() {
        _nameController.text = account.name;
        _selectedType = account.type;
        _bankNameController.text = account.bankName ?? '';
        _accountNumberController.text = account.accountNumber ?? '';
        _balanceController.text = account.balanceInRupees.toStringAsFixed(2);
        if (account.creditLimit != null) {
          _creditLimitController.text = account.creditLimitInRupees!.toStringAsFixed(2);
        }
        _isDefault = account.isDefault;
        _isFormDirty = false;
        _isLoadingAccount = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingAccount = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _balanceController.dispose();
    _creditLimitController.dispose();
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

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an account type'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Parse balance (convert rupees to paise)
    int? balanceInPaise;
    if (_balanceController.text.isNotEmpty) {
      final balance = double.tryParse(_balanceController.text);
      if (balance != null) {
        balanceInPaise = (balance * 100).round();
      }
    }

    // Parse credit limit (convert rupees to paise)
    int? creditLimitInPaise;
    if (_selectedType == AccountType.creditCard && _creditLimitController.text.isNotEmpty) {
      final creditLimit = double.tryParse(_creditLimitController.text);
      if (creditLimit != null) {
        creditLimitInPaise = (creditLimit * 100).round();
      }
    }

    final request = CreateAccountRequest(
      name: _nameController.text.trim(),
      type: _selectedType!,
      balance: balanceInPaise,
      bankName: _bankNameController.text.isNotEmpty ? _bankNameController.text.trim() : null,
      accountNumber:
          _accountNumberController.text.isNotEmpty ? _accountNumberController.text.trim() : null,
      creditLimit: creditLimitInPaise,
      isDefault: _isDefault,
    );

    AccountModel? result;

    if (isEditing) {
      result =
          await ref.read(accountsStateProvider.notifier).updateAccount(widget.accountId!, request);
    } else {
      result = await ref.read(accountsStateProvider.notifier).createAccount(request);
    }

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Account updated successfully' : 'Account created successfully',
          ),
          backgroundColor: SpendexColors.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(accountsStateProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to save account'),
          backgroundColor: SpendexColors.expense,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accountsState = ref.watch(accountsStateProvider);
    final isSubmitting = accountsState.isCreating || accountsState.isUpdating;

    return PopScope(
      canPop: !_isFormDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Account' : 'Add Account'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () async {
              if (_isFormDirty) {
                final shouldPop = await _onWillPop();
                if (shouldPop && context.mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
        ),
        body: _isLoadingAccount
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Name
                      _buildSectionLabel('Account Name', isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'e.g., HDFC Savings',
                          prefixIcon: Icon(
                            Iconsax.bank,
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Account name is required';
                          }
                          if (value.trim().length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          if (value.trim().length > AppConstants.maxNameLength) {
                            return 'Name cannot exceed ${AppConstants.maxNameLength} characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Account Type
                      _buildSectionLabel('Account Type', isRequired: true),
                      const SizedBox(height: 12),
                      AccountTypeSelector(
                        selectedType: _selectedType,
                        onTypeSelected: (type) {
                          setState(() {
                            _selectedType = type;
                            _isFormDirty = true;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Bank Name (Optional)
                      _buildSectionLabel('Bank Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _bankNameController,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'e.g., HDFC Bank',
                          prefixIcon: Icon(
                            Iconsax.building,
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Account Number (Optional)
                      _buildSectionLabel('Account Number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Last 4 digits will be shown',
                          prefixIcon: Icon(
                            Iconsax.card,
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Initial Balance
                      _buildSectionLabel(
                        isEditing ? 'Current Balance' : 'Initial Balance',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _balanceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: '0.00',
                          prefixIcon: Container(
                            width: 48,
                            alignment: Alignment.center,
                            child: Text(
                              '₹',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final amount = double.tryParse(value);
                            if (amount == null) {
                              return 'Please enter a valid amount';
                            }
                            if (amount < 0) {
                              return 'Amount cannot be negative';
                            }
                            if (amount > 9999999999) {
                              return 'Amount exceeds maximum limit';
                            }
                          }
                          return null;
                        },
                      ),

                      // Credit Limit (Only for Credit Cards)
                      if (_selectedType == AccountType.creditCard) ...[
                        const SizedBox(height: 24),
                        _buildSectionLabel('Credit Limit', isRequired: true),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _creditLimitController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: Container(
                              width: 48,
                              alignment: Alignment.center,
                              child: Text(
                                '₹',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: isDark
                                      ? SpendexColors.darkTextSecondary
                                      : SpendexColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedType == AccountType.creditCard) {
                              if (value == null || value.isEmpty) {
                                return 'Credit limit is required for credit cards';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'Please enter a valid credit limit';
                              }
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Set as Default Toggle
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: SpendexColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.star,
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
                                    'Set as Default',
                                    style: SpendexTheme.titleMedium.copyWith(
                                      color: isDark
                                          ? SpendexColors.darkTextPrimary
                                          : SpendexColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Use this account for transactions by default',
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
                              value: _isDefault,
                              onChanged: (value) {
                                setState(() {
                                  _isDefault = value;
                                  _isFormDirty = true;
                                });
                              },
                              activeTrackColor: SpendexColors.primary,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Preview Card
                      if (_selectedType != null && _nameController.text.isNotEmpty) ...[
                        _buildSectionLabel('Preview'),
                        const SizedBox(height: 12),
                        _buildPreviewCard(),
                        const SizedBox(height: 24),
                      ],

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _handleSubmit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(isEditing ? 'Update Account' : 'Add Account'),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: SpendexColors.expense,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard() {
    // Create a preview account model
    int? balanceInPaise;
    if (_balanceController.text.isNotEmpty) {
      final balance = double.tryParse(_balanceController.text);
      if (balance != null) {
        balanceInPaise = (balance * 100).round();
      }
    }

    int? creditLimitInPaise;
    if (_creditLimitController.text.isNotEmpty) {
      final creditLimit = double.tryParse(_creditLimitController.text);
      if (creditLimit != null) {
        creditLimitInPaise = (creditLimit * 100).round();
      }
    }

    final previewAccount = AccountModel(
      id: 'preview',
      name: _nameController.text.isEmpty ? 'Account Name' : _nameController.text,
      type: _selectedType ?? AccountType.savings,
      balance: balanceInPaise ?? 0,
      bankName: _bankNameController.text.isNotEmpty ? _bankNameController.text : null,
      accountNumber:
          _accountNumberController.text.isNotEmpty ? _accountNumberController.text : null,
      creditLimit: creditLimitInPaise,
      isDefault: _isDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return AccountCard(
      account: previewAccount,
    );
  }
}
