import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Icon category for grouping icons in the picker
enum IconCategory {
  all('All'),
  shopping('Shopping'),
  food('Food & Dining'),
  transport('Transport'),
  home('Home & Utilities'),
  health('Health'),
  entertainment('Entertainment'),
  education('Education'),
  finance('Finance'),
  personal('Personal'),
  work('Work'),
  misc('Miscellaneous');

  const IconCategory(this.label);
  final String label;
}

/// Icon entry containing the icon data and its name
class IconEntry {
  const IconEntry({
    required this.name,
    required this.icon,
    required this.category,
  });
  final String name;
  final IconData icon;
  final IconCategory category;
}

/// Category Icon Picker Widget
///
/// A comprehensive icon picker that displays a searchable grid of Iconsax icons
/// organized by categories. Returns the selected icon name as a String.
class CategoryIconPicker extends StatefulWidget {
  const CategoryIconPicker({
    required this.onIconSelected,
    super.key,
    this.selectedIcon,
    this.showSearch = true,
    this.showCategories = true,
    this.maxHeight,
  });

  /// Currently selected icon name
  final String? selectedIcon;

  /// Callback when an icon is selected
  final ValueChanged<String> onIconSelected;

  /// Whether to show the search bar
  final bool showSearch;

  /// Whether to show category filter tabs
  final bool showCategories;

  /// Maximum height of the picker (useful for bottom sheets)
  final double? maxHeight;

  @override
  State<CategoryIconPicker> createState() => _CategoryIconPickerState();
}

class _CategoryIconPickerState extends State<CategoryIconPicker> {
  late TextEditingController _searchController;
  IconCategory _selectedCategory = IconCategory.all;
  String _searchQuery = '';

  /// All available icons with their metadata
  static const List<IconEntry> _allIcons = [
    // Shopping & Retail
    IconEntry(name: 'shopping_bag', icon: Iconsax.shopping_bag, category: IconCategory.shopping),
    IconEntry(name: 'shopping_cart', icon: Iconsax.shopping_cart, category: IconCategory.shopping),
    IconEntry(name: 'bag', icon: Iconsax.bag, category: IconCategory.shopping),
    IconEntry(name: 'bag_2', icon: Iconsax.bag_2, category: IconCategory.shopping),
    IconEntry(name: 'shop', icon: Iconsax.shop, category: IconCategory.shopping),
    IconEntry(name: 'tag', icon: Iconsax.tag, category: IconCategory.shopping),
    IconEntry(name: 'tag_2', icon: Iconsax.tag_2, category: IconCategory.shopping),

    // Food & Dining
    IconEntry(name: 'coffee', icon: Iconsax.coffee, category: IconCategory.food),
    IconEntry(name: 'cake', icon: Iconsax.cake, category: IconCategory.food),
    IconEntry(name: 'cup', icon: Iconsax.cup, category: IconCategory.food),

    // Transportation
    IconEntry(name: 'car', icon: Iconsax.car, category: IconCategory.transport),
    IconEntry(name: 'bus', icon: Iconsax.bus, category: IconCategory.transport),
    IconEntry(name: 'airplane', icon: Iconsax.airplane, category: IconCategory.transport),
    IconEntry(name: 'ship', icon: Iconsax.ship, category: IconCategory.transport),
    IconEntry(name: 'gas_station', icon: Iconsax.gas_station, category: IconCategory.transport),
    IconEntry(name: 'routing', icon: Iconsax.routing, category: IconCategory.transport),
    IconEntry(name: 'location', icon: Iconsax.location, category: IconCategory.transport),

    // Home & Utilities
    IconEntry(name: 'home', icon: Iconsax.home, category: IconCategory.home),
    IconEntry(name: 'home_2', icon: Iconsax.home_2, category: IconCategory.home),
    IconEntry(name: 'building', icon: Iconsax.building, category: IconCategory.home),
    IconEntry(name: 'buildings', icon: Iconsax.buildings, category: IconCategory.home),
    IconEntry(name: 'lamp', icon: Iconsax.lamp, category: IconCategory.home),
    IconEntry(name: 'lamp_charge', icon: Iconsax.lamp_charge, category: IconCategory.home),
    IconEntry(name: 'electricity', icon: Iconsax.electricity, category: IconCategory.home),
    IconEntry(name: 'drop', icon: Iconsax.drop, category: IconCategory.home),

    // Health & Fitness
    IconEntry(name: 'health', icon: Iconsax.health, category: IconCategory.health),
    IconEntry(name: 'heart', icon: Iconsax.heart, category: IconCategory.health),
    IconEntry(name: 'hospital', icon: Iconsax.hospital, category: IconCategory.health),
    IconEntry(name: 'weight', icon: Iconsax.weight, category: IconCategory.health),
    IconEntry(name: 'activity', icon: Iconsax.activity, category: IconCategory.health),

    // Entertainment
    IconEntry(name: 'game', icon: Iconsax.game, category: IconCategory.entertainment),
    IconEntry(name: 'gameboy', icon: Iconsax.gameboy, category: IconCategory.entertainment),
    IconEntry(name: 'music', icon: Iconsax.music, category: IconCategory.entertainment),
    IconEntry(name: 'video', icon: Iconsax.video, category: IconCategory.entertainment),
    IconEntry(name: 'video_play', icon: Iconsax.video_play, category: IconCategory.entertainment),
    IconEntry(name: 'ticket', icon: Iconsax.ticket, category: IconCategory.entertainment),
    IconEntry(name: 'ticket_2', icon: Iconsax.ticket_2, category: IconCategory.entertainment),

    // Education
    IconEntry(name: 'book', icon: Iconsax.book, category: IconCategory.education),
    IconEntry(name: 'book_1', icon: Iconsax.book_1, category: IconCategory.education),
    IconEntry(name: 'teacher', icon: Iconsax.teacher, category: IconCategory.education),
    IconEntry(name: 'award', icon: Iconsax.award, category: IconCategory.education),

    // Finance & Business
    IconEntry(name: 'wallet', icon: Iconsax.wallet, category: IconCategory.finance),
    IconEntry(name: 'wallet_2', icon: Iconsax.wallet_2, category: IconCategory.finance),
    IconEntry(name: 'wallet_3', icon: Iconsax.wallet_3, category: IconCategory.finance),
    IconEntry(name: 'money', icon: Iconsax.money, category: IconCategory.finance),
    IconEntry(name: 'money_2', icon: Iconsax.money_2, category: IconCategory.finance),
    IconEntry(name: 'money_3', icon: Iconsax.money_3, category: IconCategory.finance),
    IconEntry(name: 'money_4', icon: Iconsax.money_4, category: IconCategory.finance),
    IconEntry(name: 'card', icon: Iconsax.card, category: IconCategory.finance),
    IconEntry(name: 'card_add', icon: Iconsax.card_add, category: IconCategory.finance),
    IconEntry(name: 'bank', icon: Iconsax.bank, category: IconCategory.finance),
    IconEntry(name: 'chart', icon: Iconsax.chart, category: IconCategory.finance),
    IconEntry(name: 'chart_2', icon: Iconsax.chart_2, category: IconCategory.finance),
    IconEntry(name: 'receipt', icon: Iconsax.receipt, category: IconCategory.finance),
    IconEntry(name: 'receipt_2', icon: Iconsax.receipt_2, category: IconCategory.finance),
    IconEntry(
        name: 'percentage_square', icon: Iconsax.percentage_square, category: IconCategory.finance,),

    // Personal Care
    IconEntry(name: 'pet', icon: Iconsax.pet, category: IconCategory.personal),
    IconEntry(name: 'scissor', icon: Iconsax.scissor, category: IconCategory.personal),
    IconEntry(name: 'profile', icon: Iconsax.profile, category: IconCategory.personal),
    IconEntry(name: 'user', icon: Iconsax.user, category: IconCategory.personal),

    // Communication
    IconEntry(name: 'call', icon: Iconsax.call, category: IconCategory.misc),
    IconEntry(name: 'sms', icon: Iconsax.sms, category: IconCategory.misc),
    IconEntry(name: 'wifi', icon: Iconsax.wifi, category: IconCategory.misc),
    IconEntry(name: 'mobile', icon: Iconsax.mobile, category: IconCategory.misc),

    // Gifts & Events
    IconEntry(name: 'gift', icon: Iconsax.gift, category: IconCategory.misc),
    IconEntry(name: 'calendar', icon: Iconsax.calendar, category: IconCategory.misc),
    IconEntry(name: 'calendar_2', icon: Iconsax.calendar_2, category: IconCategory.misc),

    // Work & Office
    IconEntry(name: 'briefcase', icon: Iconsax.briefcase, category: IconCategory.work),
    IconEntry(name: 'document', icon: Iconsax.document, category: IconCategory.work),
    IconEntry(name: 'document_text', icon: Iconsax.document_text, category: IconCategory.work),
    IconEntry(name: 'clipboard', icon: Iconsax.clipboard, category: IconCategory.work),
    IconEntry(name: 'people', icon: Iconsax.people, category: IconCategory.work),
    IconEntry(name: 'profile_2user', icon: Iconsax.profile_2user, category: IconCategory.work),

    // Miscellaneous
    IconEntry(name: 'star', icon: Iconsax.star, category: IconCategory.misc),
    IconEntry(name: 'flash', icon: Iconsax.flash, category: IconCategory.misc),
    IconEntry(name: 'setting', icon: Iconsax.setting, category: IconCategory.misc),
    IconEntry(name: 'setting_2', icon: Iconsax.setting_2, category: IconCategory.misc),
    IconEntry(name: 'more', icon: Iconsax.more, category: IconCategory.misc),
    IconEntry(name: 'category', icon: Iconsax.category, category: IconCategory.misc),
    IconEntry(name: 'category_2', icon: Iconsax.category_2, category: IconCategory.misc),
    IconEntry(name: 'element_3', icon: Iconsax.element_3, category: IconCategory.misc),
    IconEntry(name: 'box', icon: Iconsax.box, category: IconCategory.misc),
    IconEntry(name: 'archive', icon: Iconsax.archive, category: IconCategory.misc),
    IconEntry(name: 'safe_home', icon: Iconsax.safe_home, category: IconCategory.misc),
    IconEntry(name: 'crown', icon: Iconsax.crown, category: IconCategory.misc),
    IconEntry(name: 'flag', icon: Iconsax.flag, category: IconCategory.misc),
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filters icons based on search query and selected category
  List<IconEntry> get _filteredIcons {
    return _allIcons.where((entry) {
      // Filter by category
      if (_selectedCategory != IconCategory.all && entry.category != _selectedCategory) {
        return false;
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return entry.name.toLowerCase().contains(query) ||
            entry.category.label.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: widget.maxHeight != null ? BoxConstraints(maxHeight: widget.maxHeight!) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Bar
          if (widget.showSearch) ...[
            _buildSearchBar(isDark),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],

          // Category Filter Tabs
          if (widget.showCategories) ...[
            _buildCategoryTabs(isDark),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],

          // Icons Grid
          Flexible(
            child: _buildIconsGrid(isDark),
          ),
        ],
      ),
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar(bool isDark) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search icons...',
        hintStyle: SpendexTheme.bodyMedium.copyWith(
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
        ),
        prefixIcon: Icon(
          Iconsax.search_normal,
          color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
          size: 20,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Iconsax.close_circle,
                  color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
        filled: true,
        fillColor: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpendexTheme.spacingLg,
          vertical: SpendexTheme.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          borderSide: BorderSide(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          borderSide: BorderSide(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
          borderSide: const BorderSide(
            color: SpendexColors.primary,
            width: 2,
          ),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  /// Builds the category filter tabs
  Widget _buildCategoryTabs(bool isDark) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: IconCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: SpendexTheme.spacingSm),
        itemBuilder: (context, index) {
          final category = IconCategory.values[index];
          final isSelected = category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
                vertical: SpendexTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? SpendexColors.primary
                    : isDark
                        ? SpendexColors.darkSurface
                        : SpendexColors.lightSurface,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                border: Border.all(
                  color: isSelected
                      ? SpendexColors.primary
                      : isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                ),
              ),
              child: Text(
                category.label,
                style: SpendexTheme.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the icons grid
  Widget _buildIconsGrid(bool isDark) {
    final icons = _filteredIcons;

    if (icons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.search_status,
                size: 48,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              Text(
                'No icons found',
                style: SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: SpendexTheme.spacingMd,
        mainAxisSpacing: SpendexTheme.spacingMd,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final entry = icons[index];
        final isSelected = widget.selectedIcon == entry.name;

        return GestureDetector(
          onTap: () => widget.onIconSelected(entry.name),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            decoration: BoxDecoration(
              color: isSelected
                  ? SpendexColors.primary.withValues(alpha: 0.15)
                  : isDark
                      ? SpendexColors.darkSurface
                      : SpendexColors.lightSurface,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              border: Border.all(
                color: isSelected
                    ? SpendexColors.primary
                    : isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                entry.icon,
                size: 24,
                color: isSelected
                    ? SpendexColors.primary
                    : isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows the category icon picker in a modal bottom sheet
///
/// Returns the selected icon name or null if dismissed.
Future<String?> showCategoryIconPicker(
  BuildContext context, {
  String? selectedIcon,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      var currentSelection = selectedIcon;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SpendexTheme.radiusXl),
              ),
            ),
            child: Column(
              children: [
                // Handle Bar
                Container(
                  margin: const EdgeInsets.only(top: SpendexTheme.spacingMd),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(SpendexTheme.spacingLg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Icon',
                        style: SpendexTheme.headlineMedium.copyWith(
                          color: isDark
                              ? SpendexColors.darkTextPrimary
                              : SpendexColors.lightTextPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, currentSelection);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                ),

                // Icon Picker
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpendexTheme.spacingLg,
                    ),
                    child: CategoryIconPicker(
                      selectedIcon: currentSelection,
                      onIconSelected: (iconName) {
                        setState(() {
                          currentSelection = iconName;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
