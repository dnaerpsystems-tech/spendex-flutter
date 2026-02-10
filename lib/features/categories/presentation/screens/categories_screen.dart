import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_card.dart';

/// Categories Screen
///
/// Displays all categories organized by type (Income/Expense) with management options.
/// Features include:
/// - Tab-based filtering between Income and Expense categories
/// - Pull-to-refresh functionality
/// - Loading skeletons while fetching data
/// - Empty states with helpful messaging
/// - Navigation to category details and add category screens
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesStateProvider.notifier).loadAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Refreshes all categories data
  Future<void> _refresh() async {
    await ref.read(categoriesStateProvider.notifier).loadAll();
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
        title: const Text('Categories'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: categoriesState.isLoading ? null : _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: SpendexColors.primary,
        child: CustomScrollView(
          slivers: [
            // Tabs Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTabs(isDark),
              ),
            ),

            // Content based on tab and loading state
            if (categoriesState.isLoading ||
                categoriesState.isIncomeLoading ||
                categoriesState.isExpenseLoading)
              _buildLoadingSkeleton()
            else if (categoriesState.error != null)
              _buildErrorState(categoriesState.error!)
            else
              _buildCategoriesList(categoriesState, isDark),

            // Bottom padding for FAB clearance
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/categories/add'),
        icon: const Icon(Iconsax.add),
        label: const Text('Add Category'),
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Builds the tab bar for filtering between Income and Expense categories
  Widget _buildTabs(bool isDark) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: SpendexColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: isDark
            ? SpendexColors.darkTextSecondary
            : SpendexColors.lightTextSecondary,
        labelStyle: SpendexTheme.titleMedium,
        unselectedLabelStyle: SpendexTheme.titleMedium,
        tabs: const [
          Tab(text: 'Income'),
          Tab(text: 'Expense'),
        ],
        onTap: (_) {
          setState(() {});
        },
      ),
    );
  }

  /// Builds loading skeleton placeholders
  Widget _buildLoadingSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: CategoryCardSkeleton(compact: true),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  /// Builds error state with retry button
  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
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
                'Failed to load categories',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the categories list based on selected tab
  Widget _buildCategoriesList(CategoriesState state, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        List<CategoryModel> categories;

        switch (_tabController.index) {
          case 0:
            categories = state.incomeCategories;
            break;
          case 1:
            categories = state.expenseCategories;
            break;
          default:
            categories = state.incomeCategories;
        }

        if (categories.isEmpty) {
          return _buildEmptyState(_tabController.index);
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CategoryCard(
                    category: category,
                    compact: true,
                    onTap: () {
                      context.push('/categories/${category.id}');
                    },
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        );
      },
    );
  }

  /// Builds empty state with appropriate messaging for each tab
  Widget _buildEmptyState(int tabIndex) {
    String title;
    String subtitle;
    IconData icon;
    Color iconColor;

    switch (tabIndex) {
      case 0:
        title = 'No Income Categories';
        subtitle = 'Add an income category to organize your earnings';
        icon = Iconsax.arrow_down;
        iconColor = SpendexColors.income;
        break;
      case 1:
        title = 'No Expense Categories';
        subtitle = 'Add an expense category to track your spending';
        icon = Iconsax.arrow_up;
        iconColor = SpendexColors.expense;
        break;
      default:
        title = 'No Categories Yet';
        subtitle = 'Add your first category to start organizing your finances';
        icon = Iconsax.category;
        iconColor = SpendexColors.primary;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextPrimary
                      : SpendexColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.push('/categories/add'),
                icon: const Icon(Iconsax.add),
                label: const Text('Add Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
