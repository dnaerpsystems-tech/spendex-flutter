import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';

/// Category Card Widget
///
/// A beautiful card displaying category information with customizable appearance.
/// Supports compact and expanded modes, loading skeleton, and spending info display.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.category,
    super.key,
    this.spendingInfo,
    this.onTap,
    this.compact = false,
    this.showSpendingInfo = false,
  });

  /// The category to display
  final CategoryModel category;

  /// Optional spending information for the category
  final CategoryWithSpending? spendingInfo;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Whether to display in compact mode
  final bool compact;

  /// Whether to show spending information (amount, percentage, transaction count)
  final bool showSpendingInfo;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();

    if (compact) {
      return _buildCompactCard(context, isDark, categoryColor);
    }

    return _buildExpandedCard(context, isDark, categoryColor);
  }

  /// Builds the expanded version of the card
  Widget _buildExpandedCard(BuildContext context, bool isDark, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Icon and Type Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category Icon Container
                  _buildIconContainer(color, size: 52, iconSize: 26),
                  // Type Badge
                  _buildTypeBadge(isDark),
                ],
              ),
              const SizedBox(height: SpendexTheme.spacingLg),

              // Category Name
              Text(
                category.name,
                style: SpendexTheme.headlineMedium.copyWith(
                  color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Spending Info Section
              if (showSpendingInfo && spendingInfo != null) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                _buildSpendingInfoSection(isDark, color),
              ],

              // System Category Badge
              if (category.isSystem) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                _buildSystemBadge(isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the compact version of the card
  Widget _buildCompactCard(BuildContext context, bool isDark, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SpendexTheme.spacingMd),
        decoration: BoxDecoration(
          color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            // Icon Container
            _buildIconContainer(color, size: 44, iconSize: 22),
            const SizedBox(width: SpendexTheme.spacingMd),

            // Category Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: SpendexTheme.titleMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (category.isSystem) ...[
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Icon(
                          Iconsax.lock1,
                          color: isDark
                              ? SpendexColors.darkTextTertiary
                              : SpendexColors.lightTextTertiary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _buildCompactTypeBadge(isDark),
                      if (showSpendingInfo && spendingInfo != null) ...[
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Text(
                          '${spendingInfo!.transactionCount} txns',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextTertiary
                                : SpendexColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Spending Amount (if applicable)
            if (showSpendingInfo && spendingInfo != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCurrency(spendingInfo!.totalSpentInRupees),
                    style: SpendexTheme.titleMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${spendingInfo!.percentage.toStringAsFixed(1)}%',
                    style: SpendexTheme.labelMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(width: SpendexTheme.spacingSm),

            // Arrow Icon
            Icon(
              Iconsax.arrow_right_3,
              color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the icon container with background
  Widget _buildIconContainer(Color color, {required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Icon(
        _getCategoryIcon(),
        color: color,
        size: iconSize,
      ),
    );
  }

  /// Builds the type badge for expanded view
  Widget _buildTypeBadge(bool isDark) {
    final isIncome = category.type == CategoryType.income;
    final badgeColor = isIncome ? SpendexColors.income : SpendexColors.expense;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isIncome ? Iconsax.arrow_down : Iconsax.arrow_up,
            color: badgeColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            category.type.label,
            style: SpendexTheme.labelMedium.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the compact type badge
  Widget _buildCompactTypeBadge(bool isDark) {
    final isIncome = category.type == CategoryType.income;
    final badgeColor = isIncome ? SpendexColors.income : SpendexColors.expense;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
      ),
      child: Text(
        category.type.label,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds the spending info section for expanded view
  Widget _buildSpendingInfoSection(bool isDark, Color color) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Column(
        children: [
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusXs),
            child: LinearProgressIndicator(
              value: (spendingInfo!.percentage / 100).clamp(0.0, 1.0),
              backgroundColor: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: SpendexTheme.spacingMd),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                'Total Spent',
                _formatCurrency(spendingInfo!.totalSpentInRupees),
                isDark,
              ),
              _buildStatItem(
                'Percentage',
                '${spendingInfo!.percentage.toStringAsFixed(1)}%',
                isDark,
              ),
              _buildStatItem(
                'Transactions',
                spendingInfo!.transactionCount.toString(),
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a stat item for the spending info section
  Widget _buildStatItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: SpendexTheme.titleMedium.copyWith(
            color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Builds the system category badge
  Widget _buildSystemBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.lock1,
            color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            'System Category',
            style: SpendexTheme.labelMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the category color from the model or returns a default
  Color _getCategoryColor() {
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

    // Default color based on category type
    return category.type == CategoryType.income ? SpendexColors.income : SpendexColors.primary;
  }

  /// Gets the category icon from the model or returns a default
  IconData _getCategoryIcon() {
    return getCategoryIconByName(category.icon) ?? Iconsax.category;
  }

  /// Formats currency in Indian format
  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}

/// Category Card Skeleton
///
/// A loading skeleton placeholder for the CategoryCard widget.
class CategoryCardSkeleton extends StatelessWidget {
  const CategoryCardSkeleton({
    super.key,
    this.compact = false,
  });

  /// Whether to display in compact mode
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) {
      return _buildCompactSkeleton(isDark);
    }

    return _buildExpandedSkeleton(isDark);
  }

  Widget _buildExpandedSkeleton(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShimmerBox(52, 52, SpendexTheme.radiusMd, isDark),
                _buildShimmerBox(80, 28, SpendexTheme.radiusFull, isDark),
              ],
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildShimmerBox(150, 24, SpendexTheme.radiusSm, isDark),
            const SizedBox(height: SpendexTheme.spacingMd),
            _buildShimmerBox(double.infinity, 80, SpendexTheme.radiusMd, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          _buildShimmerBox(44, 44, SpendexTheme.radiusMd, isDark),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(120, 16, SpendexTheme.radiusXs, isDark),
                const SizedBox(height: 6),
                _buildShimmerBox(60, 12, SpendexTheme.radiusXs, isDark),
              ],
            ),
          ),
          _buildShimmerBox(18, 18, SpendexTheme.radiusXs, isDark),
        ],
      ),
    );
  }

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
}

/// Maps icon names to Iconsax IconData
///
/// Returns the corresponding IconData for a given icon name string,
/// or null if the icon name is not recognized.
IconData? getCategoryIconByName(String? iconName) {
  if (iconName == null || iconName.isEmpty) {
    return null;
  }

  const iconMap = <String, IconData>{
    // Shopping & Retail
    'shopping_bag': Iconsax.shopping_bag,
    'shopping_cart': Iconsax.shopping_cart,
    'bag': Iconsax.bag,
    'bag_2': Iconsax.bag_2,
    'shop': Iconsax.shop,
    'tag': Iconsax.tag,
    'tag_2': Iconsax.tag_2,

    // Food & Dining
    'coffee': Iconsax.coffee,
    'cake': Iconsax.cake,
    'cup': Iconsax.cup,

    // Transportation
    'car': Iconsax.car,
    'bus': Iconsax.bus,
    'airplane': Iconsax.airplane,
    'ship': Iconsax.ship,
    'gas_station': Iconsax.gas_station,
    'routing': Iconsax.routing,
    'location': Iconsax.location,

    // Home & Utilities
    'home': Iconsax.home,
    'home_2': Iconsax.home_2,
    'building': Iconsax.building,
    'buildings': Iconsax.buildings,
    'lamp': Iconsax.lamp,
    'lamp_charge': Iconsax.lamp_charge,
    'electricity': Iconsax.electricity,
    'drop': Iconsax.drop,

    // Health & Fitness
    'health': Iconsax.health,
    'heart': Iconsax.heart,
    'hospital': Iconsax.hospital,
    'weight': Iconsax.weight,
    'activity': Iconsax.activity,

    // Entertainment
    'game': Iconsax.game,
    'gameboy': Iconsax.gameboy,
    'music': Iconsax.music,
    'video': Iconsax.video,
    'video_play': Iconsax.video_play,
    'ticket': Iconsax.ticket,
    'ticket_2': Iconsax.ticket_2,

    // Education
    'book': Iconsax.book,
    'book_1': Iconsax.book_1,
    'teacher': Iconsax.teacher,
    'award': Iconsax.award,
    'graduation': Iconsax.teacher,

    // Finance & Business
    'wallet': Iconsax.wallet,
    'wallet_2': Iconsax.wallet_2,
    'wallet_3': Iconsax.wallet_3,
    'money': Iconsax.money,
    'money_2': Iconsax.money_2,
    'money_3': Iconsax.money_3,
    'money_4': Iconsax.money_4,
    'card': Iconsax.card,
    'card_add': Iconsax.card_add,
    'bank': Iconsax.bank,
    'chart': Iconsax.chart,
    'chart_2': Iconsax.chart_2,
    'receipt': Iconsax.receipt,
    'receipt_2': Iconsax.receipt_2,

    // Personal Care
    'pet': Iconsax.pet,
    'scissor': Iconsax.scissor,

    // Communication
    'call': Iconsax.call,
    'sms': Iconsax.sms,
    'wifi': Iconsax.wifi,
    'mobile': Iconsax.mobile,

    // Gifts & Events
    'gift': Iconsax.gift,
    'calendar': Iconsax.calendar,
    'calendar_2': Iconsax.calendar_2,

    // Work & Office
    'briefcase': Iconsax.briefcase,
    'document': Iconsax.document,
    'document_text': Iconsax.document_text,
    'clipboard': Iconsax.clipboard,
    'people': Iconsax.people,
    'profile_2user': Iconsax.profile_2user,

    // Miscellaneous
    'star': Iconsax.star,
    'flash': Iconsax.flash,
    'setting': Iconsax.setting,
    'setting_2': Iconsax.setting_2,
    'more': Iconsax.more,
    'category': Iconsax.category,
    'category_2': Iconsax.category_2,
    'element': Iconsax.element_3,
  };

  return iconMap[iconName.toLowerCase()];
}

/// Gets the default icon for a category based on its name
IconData getDefaultCategoryIcon(String categoryName) {
  final nameLower = categoryName.toLowerCase();

  // Try to match common category names
  if (nameLower.contains('food') ||
      nameLower.contains('restaurant') ||
      nameLower.contains('dining')) {
    return Iconsax.coffee;
  }
  if (nameLower.contains('shop') || nameLower.contains('retail')) {
    return Iconsax.shopping_bag;
  }
  if (nameLower.contains('transport') ||
      nameLower.contains('travel') ||
      nameLower.contains('fuel')) {
    return Iconsax.car;
  }
  if (nameLower.contains('health') || nameLower.contains('medical')) {
    return Iconsax.health;
  }
  if (nameLower.contains('entertainment') || nameLower.contains('movie')) {
    return Iconsax.video_play;
  }
  if (nameLower.contains('education') || nameLower.contains('school')) {
    return Iconsax.book;
  }
  if (nameLower.contains('bill') || nameLower.contains('utility')) {
    return Iconsax.receipt;
  }
  if (nameLower.contains('salary') || nameLower.contains('income')) {
    return Iconsax.money;
  }
  if (nameLower.contains('gift')) {
    return Iconsax.gift;
  }
  if (nameLower.contains('home') || nameLower.contains('rent')) {
    return Iconsax.home;
  }

  return Iconsax.category;
}
