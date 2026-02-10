import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/category_model.dart';
import '../providers/categories_provider.dart';
import '../widgets/category_color_picker.dart';
import '../widgets/category_icon_picker.dart';
import '../widgets/category_type_selector.dart';

/// Add/Edit Category Screen
///
/// Full form with validation for creating or editing categories.
/// Supports both income and expense category types with customizable
/// icons, colors, and optional parent category for subcategories.
class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({
    super.key,
    this.categoryId,
  });

  /// Optional category ID for editing mode.
  /// If null, the screen operates in create mode.
  final String? categoryId;

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  CategoryType _selectedType = CategoryType.expense;
  String? _selectedIcon;
  String? _selectedColor;
  String? _selectedParentId;

  bool _isFormDirty = false;
  bool _isLoadingCategory = false;
  CategoryModel? _editingCategory;

  /// Whether we are in editing mode
  bool get isEditing => widget.categoryId != null;

  /// Whether the category being edited is a system category
  bool get isSystemCategory => _editingCategory?.isSystem ?? false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_markFormDirty);

    if (isEditing) {
      _loadCategoryForEditing();
    } else {
      // Set default values for new categories
      _setDefaultValues();
    }
  }

  /// Sets default values for a new category based on type
  void _setDefaultValues() {
    final colorValue = SpendexColors.categoryColors.first;
    _selectedColor = (colorValue.r.toInt() << 16 | colorValue.g.toInt() << 8 | colorValue.b.toInt())
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();
  }

  /// Marks the form as dirty (modified)
  void _markFormDirty() {
    if (!_isFormDirty) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }

  /// Loads the category data for editing
  Future<void> _loadCategoryForEditing() async {
    setState(() {
      _isLoadingCategory = true;
    });

    final category = await ref
        .read(categoriesStateProvider.notifier)
        .getCategoryById(widget.categoryId!);

    if (category != null && mounted) {
      setState(() {
        _editingCategory = category;
        _nameController.text = category.name;
        _selectedType = category.type;
        _selectedIcon = category.icon;
        _selectedColor = category.color;
        _selectedParentId = category.parentId;
        _isFormDirty = false;
        _isLoadingCategory = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingCategory = false;
      });
      // Show error if category not found
      _showErrorSnackBar('Category not found');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Handles back navigation with unsaved changes check
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

  /// Handles form submission (create or update)
  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Category name is required');
      return;
    }

    final request = CreateCategoryRequest(
      name: name,
      type: _selectedType,
      icon: _selectedIcon,
      color: _selectedColor,
      parentId: _selectedParentId,
    );

    CategoryModel? result;
    if (isEditing) {
      result = await ref
          .read(categoriesStateProvider.notifier)
          .updateCategory(widget.categoryId!, request);
    } else {
      result = await ref
          .read(categoriesStateProvider.notifier)
          .createCategory(request);
    }

    if (result != null && mounted) {
      _showSuccessSnackBar(
        isEditing ? 'Category updated successfully' : 'Category created successfully',
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(categoriesStateProvider).error;
      _showErrorSnackBar(error ?? 'Failed to save category');
    }
  }

  /// Handles category deletion with confirmation
  Future<void> _handleDelete() async {
    if (_editingCategory == null) {
      return;
    }

    // System categories cannot be deleted
    if (isSystemCategory) {
      _showErrorSnackBar('System categories cannot be deleted');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${_editingCategory!.name}"? '
          'This action cannot be undone. Transactions using this category '
          'will need to be reassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: SpendexColors.expense),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(categoriesStateProvider.notifier)
          .deleteCategory(widget.categoryId!);

      if (success && mounted) {
        _showSuccessSnackBar('Category deleted successfully');
        context.pop();
      } else if (mounted) {
        final error = ref.read(categoriesStateProvider).error;
        _showErrorSnackBar(error ?? 'Failed to delete category');
      }
    }
  }

  /// Shows a success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Shows an error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Opens the icon picker modal
  Future<void> _openIconPicker() async {
    final result = await showCategoryIconPicker(
      context,
      selectedIcon: _selectedIcon,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedIcon = result;
        _isFormDirty = true;
      });
    }
  }

  /// Opens the color picker modal
  Future<void> _openColorPicker() async {
    final result = await showCategoryColorPicker(
      context,
      selectedColor: _selectedColor,
    );

    if (result != null && mounted) {
      setState(() {
        _selectedColor = result;
        _isFormDirty = true;
      });
    }
  }

  /// Gets the IconData for a given icon name
  IconData _getIconData(String? iconName) {
    if (iconName == null) {
      return _selectedType == CategoryType.income
          ? Iconsax.arrow_down
          : Iconsax.arrow_up;
    }

    // Map icon names to IconData
    final iconMap = <String, IconData>{
      'shopping_bag': Iconsax.shopping_bag,
      'shopping_cart': Iconsax.shopping_cart,
      'bag': Iconsax.bag,
      'bag_2': Iconsax.bag_2,
      'shop': Iconsax.shop,
      'tag': Iconsax.tag,
      'tag_2': Iconsax.tag_2,
      'coffee': Iconsax.coffee,
      'cake': Iconsax.cake,
      'cup': Iconsax.cup,
      'car': Iconsax.car,
      'bus': Iconsax.bus,
      'airplane': Iconsax.airplane,
      'ship': Iconsax.ship,
      'gas_station': Iconsax.gas_station,
      'routing': Iconsax.routing,
      'location': Iconsax.location,
      'home': Iconsax.home,
      'home_2': Iconsax.home_2,
      'building': Iconsax.building,
      'buildings': Iconsax.buildings,
      'lamp': Iconsax.lamp,
      'lamp_charge': Iconsax.lamp_charge,
      'electricity': Iconsax.electricity,
      'drop': Iconsax.drop,
      'health': Iconsax.health,
      'heart': Iconsax.heart,
      'hospital': Iconsax.hospital,
      'weight': Iconsax.weight,
      'activity': Iconsax.activity,
      'game': Iconsax.game,
      'gameboy': Iconsax.gameboy,
      'music': Iconsax.music,
      'video': Iconsax.video,
      'video_play': Iconsax.video_play,
      'ticket': Iconsax.ticket,
      'ticket_2': Iconsax.ticket_2,
      'book': Iconsax.book,
      'book_1': Iconsax.book_1,
      'teacher': Iconsax.teacher,
      'award': Iconsax.award,
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
      'percentage_square': Iconsax.percentage_square,
      'pet': Iconsax.pet,
      'scissor': Iconsax.scissor,
      'profile': Iconsax.profile,
      'user': Iconsax.user,
      'call': Iconsax.call,
      'sms': Iconsax.sms,
      'wifi': Iconsax.wifi,
      'mobile': Iconsax.mobile,
      'gift': Iconsax.gift,
      'calendar': Iconsax.calendar,
      'calendar_2': Iconsax.calendar_2,
      'briefcase': Iconsax.briefcase,
      'document': Iconsax.document,
      'document_text': Iconsax.document_text,
      'clipboard': Iconsax.clipboard,
      'people': Iconsax.people,
      'profile_2user': Iconsax.profile_2user,
      'star': Iconsax.star,
      'flash': Iconsax.flash,
      'setting': Iconsax.setting,
      'setting_2': Iconsax.setting_2,
      'more': Iconsax.more,
      'category': Iconsax.category,
      'category_2': Iconsax.category_2,
      'element': Iconsax.element_3,
      'box': Iconsax.box,
      'archive': Iconsax.archive,
      'safe_home': Iconsax.safe_home,
      'crown': Iconsax.crown,
      'flag': Iconsax.flag,
    };

    return iconMap[iconName] ?? Iconsax.category;
  }

  /// Parses a hex color string to Color
  Color _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return _selectedType == CategoryType.income
          ? SpendexColors.income
          : SpendexColors.expense;
    }

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

  /// Gets parent categories filtered by the current type
  List<CategoryModel> _getParentCategories() {
    final categories = ref.watch(categoriesStateProvider).categories;
    return categories
        .where((c) =>
            c.type == _selectedType &&
            c.parentId == null && // Only top-level categories can be parents
            c.id != widget.categoryId) // Exclude current category in edit mode
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesState = ref.watch(categoriesStateProvider);
    final isSubmitting = categoriesState.isCreating || categoriesState.isUpdating;
    final isDeleting = categoriesState.isDeleting;
    final isOperationInProgress = isSubmitting || isDeleting;

    return PopScope(
      canPop: !_isFormDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: isDark
                ? SpendexColors.darkBackground
                : SpendexColors.lightBackground,
            appBar: _buildAppBar(isDark, isSubmitting),
            body: _isLoadingCategory
                ? const Center(child: CircularProgressIndicator())
                : _buildBody(isDark, isSubmitting, isDeleting),
          ),
          // Loading overlay during operations
          if (isOperationInProgress)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the app bar with appropriate actions
  PreferredSizeWidget _buildAppBar(bool isDark, bool isSubmitting) {
    return AppBar(
      title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Iconsax.arrow_left),
        onPressed: () async {
          if (_isFormDirty) {
            final shouldPop = await _onWillPop();
            if (shouldPop && mounted) {
              context.pop();
            }
          } else {
            context.pop();
          }
        },
      ),
      actions: [
        if (isEditing && !isSystemCategory)
          IconButton(
            icon: Icon(
              Iconsax.trash,
              color: SpendexColors.expense,
            ),
            onPressed: _handleDelete,
            tooltip: 'Delete Category',
          ),
      ],
    );
  }

  /// Builds the main body content
  Widget _buildBody(bool isDark, bool isSubmitting, bool isDeleting) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System category warning
            if (isSystemCategory) _buildSystemCategoryWarning(isDark),

            // Category Type Selector
            _buildSectionLabel('Category Type', isRequired: true),
            const SizedBox(height: SpendexTheme.spacingMd),
            AbsorbPointer(
              absorbing: isSystemCategory,
              child: Opacity(
                opacity: isSystemCategory ? 0.6 : 1.0,
                child: CategoryTypeSelector(
                  selectedType: _selectedType,
                  onTypeChanged: (type) {
                    setState(() {
                      _selectedType = type;
                      _selectedParentId = null; // Reset parent when type changes
                      _isFormDirty = true;
                    });
                  },
                  enabled: !isSystemCategory,
                ),
              ),
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Category Name
            _buildSectionLabel('Category Name', isRequired: true),
            const SizedBox(height: SpendexTheme.spacingSm),
            AbsorbPointer(
              absorbing: isSystemCategory,
              child: Opacity(
                opacity: isSystemCategory ? 0.6 : 1.0,
                child: TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  enabled: !isSystemCategory,
                  maxLength: AppConstants.maxNameLength,
                  decoration: InputDecoration(
                    hintText: 'e.g., Groceries, Salary',
                    prefixIcon: Icon(
                      Iconsax.text,
                      color: isDark
                          ? SpendexColors.darkTextTertiary
                          : SpendexColors.lightTextTertiary,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Category name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    if (value.trim().length > AppConstants.maxNameLength) {
                      return 'Name cannot exceed ${AppConstants.maxNameLength} characters';
                    }
                    // Check for special characters (allow letters, numbers, spaces, and common punctuation)
                    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-&,\.\']+$');
                    if (!validPattern.hasMatch(value.trim())) {
                      return 'Name contains invalid characters';
                    }
                    return null;
                  },
                ),
              ),
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Icon and Color Pickers (side by side)
            Row(
              children: [
                // Icon Picker
                Expanded(
                  child: _buildPickerField(
                    label: 'Icon',
                    isDark: isDark,
                    onTap: isSystemCategory ? null : _openIconPicker,
                    child: Container(
                      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: _parseHexColor(_selectedColor).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                      ),
                      child: Icon(
                        _getIconData(_selectedIcon),
                        color: _parseHexColor(_selectedColor),
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: SpendexTheme.spacingLg),
                // Color Picker
                Expanded(
                  child: _buildPickerField(
                    label: 'Color',
                    isDark: isDark,
                    onTap: isSystemCategory ? null : _openColorPicker,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseHexColor(_selectedColor),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _parseHexColor(_selectedColor).withValues(alpha: 0.4),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: SpendexTheme.spacing2xl),

            // Parent Category (Optional)
            _buildSectionLabel('Parent Category'),
            const SizedBox(height: SpendexTheme.spacingSm),
            _buildParentCategoryDropdown(isDark),

            const SizedBox(height: SpendexTheme.spacing3xl),

            // Preview Section
            if (_nameController.text.isNotEmpty) ...[
              _buildSectionLabel('Preview'),
              const SizedBox(height: SpendexTheme.spacingMd),
              _buildPreviewCard(isDark),
              const SizedBox(height: SpendexTheme.spacing2xl),
            ],

            // Submit Button
            if (!isSystemCategory)
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
                      : Text(isEditing ? 'Update Category' : 'Add Category'),
                ),
              ),

            const SizedBox(height: SpendexTheme.spacing3xl),
          ],
        ),
      ),
    );
  }

  /// Builds a section label with optional required indicator
  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          label,
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text(
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

  /// Builds the system category warning banner
  Widget _buildSystemCategoryWarning(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpendexTheme.spacingLg),
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: SpendexColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: SpendexColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.warning_2,
            color: SpendexColors.warning,
            size: 20,
          ),
          const SizedBox(width: SpendexTheme.spacingMd),
          Expanded(
            child: Text(
              'This is a system category and cannot be modified or deleted.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextPrimary
                    : SpendexColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a picker field (for icon and color)
  Widget _buildPickerField({
    required String label,
    required bool isDark,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(label),
        const SizedBox(height: SpendexTheme.spacingSm),
        GestureDetector(
          onTap: onTap,
          child: AbsorbPointer(
            absorbing: onTap == null,
            child: Opacity(
              opacity: onTap == null ? 0.6 : 1.0,
              child: Container(
                padding: const EdgeInsets.all(SpendexTheme.spacingMd),
                decoration: BoxDecoration(
                  color: isDark
                      ? SpendexColors.darkCard
                      : SpendexColors.lightCard,
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    child,
                    const Spacer(),
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
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the parent category dropdown
  Widget _buildParentCategoryDropdown(bool isDark) {
    final parentCategories = _getParentCategories();

    return AbsorbPointer(
      absorbing: isSystemCategory,
      child: Opacity(
        opacity: isSystemCategory ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
            vertical: SpendexTheme.spacingXs,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? SpendexColors.darkSurface
                : SpendexColors.lightSurface,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            border: Border.all(
              color: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedParentId,
              isExpanded: true,
              hint: Text(
                'None (Top-level category)',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: isDark
                      ? SpendexColors.darkTextTertiary
                      : SpendexColors.lightTextTertiary,
                ),
              ),
              dropdownColor: isDark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
              icon: Icon(
                Iconsax.arrow_down_1,
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'None (Top-level category)',
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: isDark
                          ? SpendexColors.darkTextPrimary
                          : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ),
                ...parentCategories.map((category) {
                  return DropdownMenuItem<String?>(
                    value: category.id,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _parseHexColor(category.color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                          ),
                          child: Icon(
                            _getIconData(category.icon),
                            color: _parseHexColor(category.color),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: SpendexTheme.spacingMd),
                        Text(
                          category.name,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextPrimary
                                : SpendexColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: isSystemCategory
                  ? null
                  : (value) {
                      setState(() {
                        _selectedParentId = value;
                        _isFormDirty = true;
                      });
                    },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the preview card showing how the category will look
  Widget _buildPreviewCard(bool isDark) {
    final color = _parseHexColor(_selectedColor);
    final icon = _getIconData(_selectedIcon);
    final name = _nameController.text.isEmpty ? 'Category Name' : _nameController.text;

    // Find parent category name if selected
    String? parentName;
    if (_selectedParentId != null) {
      final categories = ref.watch(categoriesStateProvider).categories;
      final parent = categories.where((c) => c.id == _selectedParentId).firstOrNull;
      parentName = parent?.name;
    }

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
            child: Center(
              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingLg),
          // Category Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: SpendexTheme.titleMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpendexTheme.spacingSm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (_selectedType == CategoryType.income
                                ? SpendexColors.income
                                : SpendexColors.expense)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                      ),
                      child: Text(
                        _selectedType.label,
                        style: SpendexTheme.labelMedium.copyWith(
                          color: _selectedType == CategoryType.income
                              ? SpendexColors.income
                              : SpendexColors.expense,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (parentName != null) ...[
                      const SizedBox(width: SpendexTheme.spacingSm),
                      Icon(
                        Iconsax.arrow_right_3,
                        size: 12,
                        color: isDark
                            ? SpendexColors.darkTextTertiary
                            : SpendexColors.lightTextTertiary,
                      ),
                      const SizedBox(width: SpendexTheme.spacingSm),
                      Flexible(
                        child: Text(
                          parentName,
                          style: SpendexTheme.labelMedium.copyWith(
                            color: isDark
                                ? SpendexColors.darkTextSecondary
                                : SpendexColors.lightTextSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
