import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';

/// Category Details Screen
///
/// Displays comprehensive category information including:
/// - Category header with icon and type badge
/// - Monthly spending/earning statistics
/// - Monthly trend chart showing last 6 months
/// - Recent transactions list
/// - Subcategories (if parent category)
/// - Quick action buttons for common operations
class CategoryDetailsScreen extends ConsumerStatefulWidget {
  /// The ID of the category to display
  final String categoryId;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryDetailsScreen> createState() =>
      _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends ConsumerState<CategoryDetailsScreen> {
  /// Mock data for monthly trend (in a real app, this would come from the API)
  final List<_MonthlyData> _monthlyTrend = [];

  /// Mock recent transactions (in a real app, this would come from the API)
  final List<_MockTransaction> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _initializeMockData();
  }

  /// Initializes mock data for demonstration
  void _initializeMockData() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Generate last 6 months of mock data
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthIndex = date.month - 1;
      _monthlyTrend.add(_MonthlyData(
        month: months[monthIndex],
        amount: (5000 + (i * 1500) + (i % 3) * 800).toDouble(),
        isCurrentMonth: i == 0,
      ));
    }

    // Mock recent transactions
    _recentTransactions.addAll([
      _MockTransaction(
        id: '1',
        description: 'Grocery Shopping',
        amount: 2450.00,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _MockTransaction(
        id: '2',
        description: 'Online Purchase',
        amount: 1899.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      _MockTransaction(
        id: '3',
        description: 'Restaurant Bill',
        amount: 750.00,
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      _MockTransaction(
        id: '4',
        description: 'Monthly Subscription',
        amount: 499.00,
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      _MockTransaction(
        id: '5',
        description: 'Fuel Purchase',
        amount: 3200.00,
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);
  }

  /// Loads category data from the provider
  Future<void> _loadCategory() async {
    await ref.read(categoriesStateProvider.notifier).getCategoryById(widget.categoryId);
  }

  /// Handles category deletion with confirmation dialog
  Future<void> _handleDelete() async {
    final category = ref.read(selectedCategoryProvider);
    if (category == null) return;

    // System categories cannot be deleted
    if (category.isSystem) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('System categories cannot be deleted'),
          backgroundColor: SpendexColors.warning,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\n'
          'This action cannot be undone. Transactions using this category will need to be reassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(categoriesStateProvider.notifier)
          .deleteCategory(widget.categoryId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Category deleted successfully'),
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
        final error = ref.read(categoriesStateProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to delete category'),
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesState = ref.watch(categoriesStateProvider);
    final category = ref.watch(selectedCategoryProvider);
    final isDeleting = categoriesState.isDeleting;

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: Text(category?.name ?? 'Category Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (category != null) ...[
            IconButton(
              icon: const Icon(Iconsax.edit_2),
              onPressed: () {
                context.push('/categories/add?id=${widget.categoryId}');
              },
              tooltip: 'Edit',
            ),
            if (category.canDelete)
              IconButton(
                icon: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Iconsax.trash),
                onPressed: isDeleting ? null : _handleDelete,
                tooltip: 'Delete',
              ),
          ],
        ],
      ),
      body: _buildBody(isDark, category, categoriesState),
    );
  }

  /// Builds the main body content based on state
  Widget _buildBody(bool isDark, CategoryModel? category, CategoriesState state) {
    if (state.isLoading && category == null) {
      return _buildLoadingSkeleton(isDark);
    }

    if (state.error != null && category == null) {
      return _buildErrorState(state.error!);
    }

    if (category == null) {
      return _buildNotFoundState();
    }

    return RefreshIndicator(
      onRefresh: _loadCategory,
      color: SpendexColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(isDark, category),
            const SizedBox(height: 24),

            // Stats Section
            _buildSectionTitle('This Month', isDark),
            const SizedBox(height: 12),
            _buildStatsSection(isDark, category),
            const SizedBox(height: 24),

            // Monthly Trend Section
            _buildSectionTitle('Monthly Trend', isDark),
            const SizedBox(height: 12),
            _buildMonthlyTrendSection(isDark, category),
            const SizedBox(height: 24),

            // Recent Transactions Section
            _buildRecentTransactionsHeader(isDark),
            const SizedBox(height: 12),
            _buildRecentTransactionsSection(isDark, category),
            const SizedBox(height: 24),

            // Subcategories Section (if has children)
            _buildSubcategoriesSection(isDark, category),

            // Quick Actions Section
            _buildSectionTitle('Quick Actions', isDark),
            const SizedBox(height: 12),
            _buildQuickActions(isDark, category),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with icon, name, and badges
  Widget _buildHeaderSection(bool isDark, CategoryModel category) {
    final categoryColor = _getCategoryColor(category);
    final categoryIcon = getCategoryIconByName(category.icon) ?? getDefaultCategoryIcon(category.name);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: categoryColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Large Icon Container
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  categoryColor,
                  categoryColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              categoryIcon,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Category Name
          Text(
            category.name,
            style: SpendexTheme.displayLarge.copyWith(
              fontSize: 24,
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              // Type Badge
              _buildBadge(
                isDark,
                label: category.type.label,
                color: category.isIncome ? SpendexColors.income : SpendexColors.expense,
                icon: category.isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
              ),

              // System Badge
              if (category.isSystem)
                _buildBadge(
                  isDark,
                  label: 'System',
                  color: SpendexColors.transfer,
                  icon: Iconsax.shield_tick,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Color Indicator Bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColor.withValues(alpha: 0.3),
                  categoryColor,
                  categoryColor.withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a badge widget
  Widget _buildBadge(
    bool isDark, {
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: SpendexTheme.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the stats section with 3 cards
  Widget _buildStatsSection(bool isDark, CategoryModel category) {
    // Mock stats data - in a real app, this would come from the API
    final totalAmount = category.isIncome ? 45000.0 : 28500.0;
    final transactionCount = 12;
    final percentage = category.isIncome ? 35.5 : 22.3;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: category.isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
            label: category.isIncome ? 'Earned' : 'Spent',
            value: _formatCurrency(totalAmount),
            color: category.isIncome ? SpendexColors.income : SpendexColors.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: Iconsax.receipt_item,
            label: 'Transactions',
            value: transactionCount.toString(),
            color: SpendexColors.transfer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            icon: Iconsax.percentage_circle,
            label: 'Of Total',
            value: '${percentage.toStringAsFixed(1)}%',
            color: SpendexColors.primary,
          ),
        ),
      ],
    );
  }

  /// Builds a single stat card
  Widget _buildStatCard(
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: SpendexTheme.titleMedium.copyWith(
              fontSize: 16,
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the monthly trend chart section
  Widget _buildMonthlyTrendSection(bool isDark, CategoryModel category) {
    if (_monthlyTrend.isEmpty) {
      return _buildEmptyTrendState(isDark);
    }

    final maxAmount = _monthlyTrend.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final categoryColor = _getCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _monthlyTrend.asMap().entries.map((entry) {
                final data = entry.value;
                final barHeight = maxAmount > 0 ? (data.amount / maxAmount) * 120 : 0.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Amount label
                        Text(
                          _formatCurrencyCompact(data.amount),
                          style: SpendexTheme.labelMedium.copyWith(
                            fontSize: 10,
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: data.isCurrentMonth
                                ? LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      categoryColor,
                                      categoryColor.withValues(alpha: 0.7),
                                    ],
                                  )
                                : null,
                            color: data.isCurrentMonth
                                ? null
                                : categoryColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Month label
                        Text(
                          data.month,
                          style: SpendexTheme.labelMedium.copyWith(
                            fontSize: 11,
                            color: data.isCurrentMonth
                                ? categoryColor
                                : isDark
                                    ? SpendexColors.darkTextTertiary
                                    : SpendexColors.lightTextTertiary,
                            fontWeight:
                                data.isCurrentMonth ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty trend state
  Widget _buildEmptyTrendState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.chart,
            size: 40,
            color: isDark
                ? SpendexColors.darkTextTertiary
                : SpendexColors.lightTextTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No trend data available',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the recent transactions header with "See All" button
  Widget _buildRecentTransactionsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Recent Transactions', isDark),
        TextButton(
          onPressed: () {
            // Navigate to transactions filtered by this category
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('View all transactions feature coming soon'),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Text(
            'See All',
            style: SpendexTheme.labelMedium.copyWith(
              color: SpendexColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the recent transactions section
  Widget _buildRecentTransactionsSection(bool isDark, CategoryModel category) {
    if (_recentTransactions.isEmpty) {
      return _buildEmptyTransactionsState(isDark);
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentTransactions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
        ),
        itemBuilder: (context, index) {
          final transaction = _recentTransactions[index];
          return _buildTransactionItem(isDark, transaction, category);
        },
      ),
    );
  }

  /// Builds a single transaction item
  Widget _buildTransactionItem(bool isDark, _MockTransaction transaction, CategoryModel category) {
    final dateFormat = DateFormat('dd MMM');
    final categoryColor = _getCategoryColor(category);

    return InkWell(
      onTap: () {
        // Navigate to transaction details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction details feature coming soon'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.receipt_item,
                color: categoryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: SpendexTheme.titleMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: SpendexTheme.labelMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextTertiary
                          : SpendexColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '${category.isExpense ? '-' : '+'}${_formatCurrency(transaction.amount)}',
              style: SpendexTheme.titleMedium.copyWith(
                color: category.isIncome ? SpendexColors.income : SpendexColors.expense,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty transactions state
  Widget _buildEmptyTransactionsState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Iconsax.receipt_2,
              color: SpendexColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: SpendexTheme.titleMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextPrimary
                  : SpendexColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Transactions in this category will appear here',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.addTransaction),
            icon: const Icon(Iconsax.add, size: 18),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the subcategories section
  Widget _buildSubcategoriesSection(bool isDark, CategoryModel category) {
    // Get subcategories from the provider
    final allCategories = ref.watch(categoriesListProvider);
    final subcategories = allCategories.where((c) => c.parentId == category.id).toList();

    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Subcategories', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            border: Border.all(
              color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subcategories.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? SpendexColors.darkDivider : SpendexColors.lightDivider,
            ),
            itemBuilder: (context, index) {
              final subcat = subcategories[index];
              return _buildSubcategoryItem(isDark, subcat);
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Builds a single subcategory item
  Widget _buildSubcategoryItem(bool isDark, CategoryModel subcategory) {
    final subcatColor = _getCategoryColor(subcategory);
    final subcatIcon = getCategoryIconByName(subcategory.icon) ?? Iconsax.category;

    return InkWell(
      onTap: () {
        // Navigate to subcategory details
        context.push('/categories/${subcategory.id}');
      },
      borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: subcatColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(subcatIcon, color: subcatColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subcategory.name,
                style: SpendexTheme.titleMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: isDark
                  ? SpendexColors.darkTextTertiary
                  : SpendexColors.lightTextTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the quick actions section
  Widget _buildQuickActions(bool isDark, CategoryModel category) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                isDark,
                icon: Iconsax.add,
                label: 'Add Transaction',
                color: SpendexColors.primary,
                onTap: () {
                  context.push(AppRoutes.addTransaction);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                isDark,
                icon: Iconsax.wallet_check,
                label: 'Set Budget',
                color: SpendexColors.warning,
                onTap: () {
                  context.push(AppRoutes.addBudget);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFullWidthActionButton(
          isDark,
          icon: Iconsax.receipt_search,
          label: 'View All Transactions',
          color: SpendexColors.transfer,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Filtered transactions view coming soon'),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds an action button
  Widget _buildActionButton(
    bool isDark, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: SpendexTheme.labelMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a full-width action button
  Widget _buildFullWidthActionButton(
    bool isDark, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: SpendexTheme.titleMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section title
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: SpendexTheme.titleMedium.copyWith(
        color: isDark
            ? SpendexColors.darkTextPrimary
            : SpendexColors.lightTextPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Builds the loading skeleton
  Widget _buildLoadingSkeleton(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
            ),
            child: Column(
              children: [
                _buildShimmerBox(88, 88, 24, isDark),
                const SizedBox(height: 20),
                _buildShimmerBox(160, 24, 8, isDark),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildShimmerBox(80, 28, 14, isDark),
                    const SizedBox(width: 8),
                    _buildShimmerBox(80, 28, 14, isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats skeleton
          _buildShimmerBox(100, 16, 4, isDark),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildShimmerBox(double.infinity, 100, 12, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(double.infinity, 100, 12, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _buildShimmerBox(double.infinity, 100, 12, isDark)),
            ],
          ),
          const SizedBox(height: 24),

          // Chart skeleton
          _buildShimmerBox(120, 16, 4, isDark),
          const SizedBox(height: 12),
          _buildShimmerBox(double.infinity, 180, 16, isDark),
        ],
      ),
    );
  }

  /// Builds a shimmer placeholder box
  Widget _buildShimmerBox(double width, double height, double radius, bool isDark) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkBorder.withValues(alpha: 0.5)
            : SpendexColors.lightBorder.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState(String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Iconsax.warning_2,
                color: SpendexColors.expense,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load category',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCategory,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the not found state
  Widget _buildNotFoundState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Iconsax.search_status,
                color: SpendexColors.warning,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Category Not Found',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The category you\'re looking for doesn\'t exist or has been deleted.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Iconsax.arrow_left),
              label: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets the category color from the model or returns a default
  Color _getCategoryColor(CategoryModel category) {
    if (category.color != null && category.color!.isNotEmpty) {
      try {
        final colorValue = int.parse(
          category.color!.replaceFirst('#', ''),
          radix: 16,
        );
        return Color(colorValue | 0xFF000000);
      } catch (_) {
        // Fall through to default
      }
    }
    return category.type == CategoryType.income
        ? SpendexColors.income
        : SpendexColors.primary;
  }

  /// Formats currency in Indian Rupee format
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  /// Formats currency in compact form (K, L, Cr)
  String _formatCurrencyCompact(double amount) {
    if (amount.abs() >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount.abs() >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount.abs() >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }
}

/// Helper class for monthly trend data
class _MonthlyData {
  final String month;
  final double amount;
  final bool isCurrentMonth;

  const _MonthlyData({
    required this.month,
    required this.amount,
    this.isCurrentMonth = false,
  });
}

/// Helper class for mock transaction data
class _MockTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  const _MockTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}
