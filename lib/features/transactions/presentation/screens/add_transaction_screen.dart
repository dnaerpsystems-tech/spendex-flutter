import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
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
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _type = TransactionType.values[_tabController.index];
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Submit transaction
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction added successfully'),
          backgroundColor: SpendexColors.income,
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Iconsax.close_square),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Transaction Type Tabs
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkSurface : SpendexColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: _getTypeColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                labelStyle: SpendexTheme.titleMedium,
                unselectedLabelStyle: SpendexTheme.titleMedium,
                tabs: const [
                  Tab(text: 'Expense'),
                  Tab(text: 'Income'),
                  Tab(text: 'Transfer'),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Field
                    _buildLabel('Amount'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: SpendexTheme.headlineMedium.copyWith(
                        color: _getTypeColor(),
                        fontSize: 32,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: SpendexTheme.headlineMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 32,
                        ),
                        prefixText: '\u20B9 ',
                        prefixStyle: SpendexTheme.headlineMedium.copyWith(
                          color: _getTypeColor(),
                          fontSize: 32,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Account Selector
                    _buildLabel(_type == TransactionType.transfer ? 'From Account' : 'Account'),
                    const SizedBox(height: 8),
                    _AccountSelector(
                      selectedId: _selectedAccountId,
                      isDark: isDark,
                      onSelect: (id) {
                        setState(() {
                          _selectedAccountId = id;
                        });
                      },
                    ),

                    if (_type == TransactionType.transfer) ...[
                      const SizedBox(height: 20),
                      _buildLabel('To Account'),
                      const SizedBox(height: 8),
                      _AccountSelector(
                        selectedId: _toAccountId,
                        isDark: isDark,
                        onSelect: (id) {
                          setState(() {
                            _toAccountId = id;
                          });
                        },
                      ),
                    ],

                    if (_type != TransactionType.transfer) ...[
                      const SizedBox(height: 20),
                      _buildLabel('Category'),
                      const SizedBox(height: 8),
                      _CategorySelector(
                        selectedId: _selectedCategoryId,
                        isDark: isDark,
                        type: _type,
                        onSelect: (id) {
                          setState(() {
                            _selectedCategoryId = id;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Description
                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'What was this for?',
                        prefixIcon: Icon(
                          Iconsax.note_text,
                          color: isDark
                              ? SpendexColors.darkTextTertiary
                              : SpendexColors.lightTextTertiary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Date
                    _buildLabel('Date'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? SpendexColors.darkSurface
                              : SpendexColors.lightSurface,
                          borderRadius: BorderRadius.circular(12),
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
                                  ? SpendexColors.darkTextTertiary
                                  : SpendexColors.lightTextTertiary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
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
                      decoration: InputDecoration(
                        hintText: 'Add any additional notes...',
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getTypeColor(),
                  ),
                  child: Text('Add ${_type.label}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: SpendexTheme.labelMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}

class _AccountSelector extends StatelessWidget {
  final String? selectedId;
  final bool isDark;
  final void Function(String) onSelect;

  const _AccountSelector({
    required this.selectedId,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Mock accounts
    final accounts = [
      {'id': '1', 'name': 'HDFC Savings', 'icon': Iconsax.bank},
      {'id': '2', 'name': 'Cash', 'icon': Iconsax.wallet_1},
      {'id': '3', 'name': 'ICICI Credit', 'icon': Iconsax.card},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          final isSelected = selectedId == account['id'];

          return GestureDetector(
            onTap: () => onSelect(account['id'] as String),
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? SpendexColors.primary.withValues(alpha: 0.1)
                    : isDark
                        ? SpendexColors.darkSurface
                        : SpendexColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? SpendexColors.primary
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
                    account['icon'] as IconData,
                    color: isSelected
                        ? SpendexColors.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    account['name'] as String,
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isSelected
                          ? SpendexColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
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

class _CategorySelector extends StatelessWidget {
  final String? selectedId;
  final bool isDark;
  final TransactionType type;
  final void Function(String) onSelect;

  const _CategorySelector({
    required this.selectedId,
    required this.isDark,
    required this.type,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Mock categories
    final categories = type == TransactionType.income
        ? [
            {'id': '1', 'name': 'Salary', 'icon': Iconsax.money_recive},
            {'id': '2', 'name': 'Freelance', 'icon': Iconsax.briefcase},
            {'id': '3', 'name': 'Investments', 'icon': Iconsax.chart},
            {'id': '4', 'name': 'Gifts', 'icon': Iconsax.gift},
            {'id': '5', 'name': 'Other', 'icon': Iconsax.more_circle},
          ]
        : [
            {'id': '1', 'name': 'Food', 'icon': Iconsax.coffee},
            {'id': '2', 'name': 'Transport', 'icon': Iconsax.car},
            {'id': '3', 'name': 'Shopping', 'icon': Iconsax.shopping_bag},
            {'id': '4', 'name': 'Bills', 'icon': Iconsax.receipt},
            {'id': '5', 'name': 'Entertainment', 'icon': Iconsax.video},
            {'id': '6', 'name': 'Health', 'icon': Iconsax.health},
          ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedId == category['id'];

        return GestureDetector(
          onTap: () => onSelect(category['id'] as String),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? SpendexColors.primary.withValues(alpha: 0.1)
                  : isDark
                      ? SpendexColors.darkSurface
                      : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? SpendexColors.primary
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
                  category['icon'] as IconData,
                  color: isSelected
                      ? SpendexColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  category['name'] as String,
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isSelected
                        ? SpendexColors.primary
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
