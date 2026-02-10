import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/constants/app_constants.dart';

/// Category Color Picker Widget
///
/// A color picker that displays SpendexColors.categoryColors as options
/// with support for custom color input via hex code.
/// Returns the selected color as a hex String (without #).
class CategoryColorPicker extends StatefulWidget {
  /// Currently selected color hex value (without #)
  final String? selectedColor;

  /// Callback when a color is selected
  final ValueChanged<String> onColorSelected;

  /// Whether to show the custom color input
  final bool showCustomColorInput;

  /// Whether to display in compact mode (single row)
  final bool compact;

  /// Preview size for color circles
  final double previewSize;

  const CategoryColorPicker({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.showCustomColorInput = true,
    this.compact = false,
    this.previewSize = 44,
  });

  @override
  State<CategoryColorPicker> createState() => _CategoryColorPickerState();
}

class _CategoryColorPickerState extends State<CategoryColorPicker> {
  late TextEditingController _hexController;
  String? _customColorError;
  bool _isCustomColorSelected = false;

  /// Convert SpendexColors.categoryColors to hex strings
  static final List<String> _predefinedColors = SpendexColors.categoryColors
      .map((c) => c.value.toRadixString(16).substring(2).toUpperCase())
      .toList();

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController();

    // Check if selected color is custom (not in predefined list)
    if (widget.selectedColor != null) {
      final normalized = widget.selectedColor!.toUpperCase().replaceFirst('#', '');
      if (!_predefinedColors.contains(normalized)) {
        _isCustomColorSelected = true;
        _hexController.text = normalized;
      }
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  /// Validates and parses a hex color string
  Color? _parseHexColor(String hex) {
    try {
      final cleanHex = hex.replaceFirst('#', '').toUpperCase();
      if (cleanHex.length != 6) return null;

      final colorValue = int.parse(cleanHex, radix: 16);
      return Color(colorValue | 0xFF000000);
    } catch (_) {
      return null;
    }
  }

  /// Checks if the provided hex string matches the selected color
  bool _isColorSelected(String hex) {
    if (widget.selectedColor == null) return false;
    final normalizedSelected = widget.selectedColor!.toUpperCase().replaceFirst('#', '');
    final normalizedHex = hex.toUpperCase().replaceFirst('#', '');
    return normalizedSelected == normalizedHex;
  }

  /// Handles custom color submission
  void _onCustomColorSubmit() {
    final hex = _hexController.text.trim();
    final color = _parseHexColor(hex);

    if (color == null) {
      setState(() {
        _customColorError = 'Invalid hex color';
      });
      return;
    }

    setState(() {
      _customColorError = null;
      _isCustomColorSelected = true;
    });

    widget.onColorSelected(hex.toUpperCase().replaceFirst('#', ''));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.compact) {
      return _buildCompactLayout(isDark);
    }

    return _buildExpandedLayout(isDark);
  }

  /// Builds the compact layout (single scrollable row)
  Widget _buildCompactLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.previewSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _predefinedColors.length + (widget.showCustomColorInput ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: SpendexTheme.spacingMd),
            itemBuilder: (context, index) {
              if (widget.showCustomColorInput && index == _predefinedColors.length) {
                return _buildCustomColorButton(isDark);
              }
              return _buildColorCircle(_predefinedColors[index], isDark);
            },
          ),
        ),
        if (widget.showCustomColorInput && _isCustomColorSelected) ...[
          const SizedBox(height: SpendexTheme.spacingMd),
          _buildHexInput(isDark),
        ],
      ],
    );
  }

  /// Builds the expanded layout (grid)
  Widget _buildExpandedLayout(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color Grid
        Wrap(
          spacing: SpendexTheme.spacingMd,
          runSpacing: SpendexTheme.spacingMd,
          children: [
            ..._predefinedColors.map((hex) => _buildColorCircle(hex, isDark)),
            if (widget.showCustomColorInput) _buildCustomColorButton(isDark),
          ],
        ),

        // Custom Color Input
        if (widget.showCustomColorInput && _isCustomColorSelected) ...[
          const SizedBox(height: SpendexTheme.spacingLg),
          _buildHexInput(isDark),
        ],

        // Selected Color Preview
        if (widget.selectedColor != null) ...[
          const SizedBox(height: SpendexTheme.spacingLg),
          _buildSelectedColorPreview(isDark),
        ],
      ],
    );
  }

  /// Builds a color circle button
  Widget _buildColorCircle(String hex, bool isDark) {
    final color = _parseHexColor(hex);
    if (color == null) return const SizedBox.shrink();

    final isSelected = _isColorSelected(hex);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isCustomColorSelected = false;
          _hexController.clear();
        });
        widget.onColorSelected(hex);
      },
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        width: widget.previewSize,
        height: widget.previewSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? (isDark ? Colors.white : SpendexColors.lightTextPrimary)
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }

  /// Builds the custom color button
  Widget _buildCustomColorButton(bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCustomColorSelected = true;
        });
      },
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        width: widget.previewSize,
        height: widget.previewSize,
        decoration: BoxDecoration(
          color: isDark
              ? SpendexColors.darkSurface
              : SpendexColors.lightSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: _isCustomColorSelected
                ? SpendexColors.primary
                : isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
            width: _isCustomColorSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Icon(
            Iconsax.colorfilter,
            color: _isCustomColorSelected
                ? SpendexColors.primary
                : isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Builds the hex color input field
  Widget _buildHexInput(bool isDark) {
    final currentColor = _parseHexColor(_hexController.text);

    return Row(
      children: [
        // Color Preview
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor ?? (isDark
                ? SpendexColors.darkBorder
                : SpendexColors.lightBorder),
            borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            border: Border.all(
              color: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
            ),
          ),
          child: currentColor == null
              ? Center(
                  child: Icon(
                    Iconsax.colorfilter,
                    color: isDark
                        ? SpendexColors.darkTextTertiary
                        : SpendexColors.lightTextTertiary,
                    size: 18,
                  ),
                )
              : null,
        ),
        const SizedBox(width: SpendexTheme.spacingMd),

        // Hex Input
        Expanded(
          child: TextField(
            controller: _hexController,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              prefixText: '# ',
              prefixStyle: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              hintText: 'Enter hex color',
              hintStyle: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
              errorText: _customColorError,
              counterText: '',
              filled: true,
              fillColor: isDark
                  ? SpendexColors.darkSurface
                  : SpendexColors.lightSurface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
                vertical: SpendexTheme.spacingMd,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                borderSide: BorderSide(
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                borderSide: BorderSide(
                  color: isDark
                      ? SpendexColors.darkBorder
                      : SpendexColors.lightBorder,
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
                _customColorError = null;
              });
              if (value.length == 6) {
                _onCustomColorSubmit();
              }
            },
            onSubmitted: (_) => _onCustomColorSubmit(),
          ),
        ),
      ],
    );
  }

  /// Builds the selected color preview
  Widget _buildSelectedColorPreview(bool isDark) {
    final color = _parseHexColor(widget.selectedColor!);
    if (color == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark
            ? SpendexColors.darkSurface
            : SpendexColors.lightBackground,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        border: Border.all(
          color: isDark
              ? SpendexColors.darkBorder
              : SpendexColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          // Large Color Preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpendexTheme.spacingLg),

          // Color Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Color',
                  style: SpendexTheme.labelMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextSecondary
                        : SpendexColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${widget.selectedColor!.toUpperCase()}',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: isDark
                        ? SpendexColors.darkTextPrimary
                        : SpendexColors.lightTextPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          // Copy Button
          IconButton(
            icon: Icon(
              Iconsax.copy,
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
              size: 20,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '#${widget.selectedColor}'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Color code copied!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: SpendexColors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Text formatter that converts input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Shows the category color picker in a modal bottom sheet
///
/// Returns the selected color hex or null if dismissed.
Future<String?> showCategoryColorPicker(
  BuildContext context, {
  String? selectedColor,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      String? currentSelection = selectedColor;

      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? SpendexColors.darkCard
                  : SpendexColors.lightCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(SpendexTheme.radiusXl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  margin: const EdgeInsets.only(top: SpendexTheme.spacingMd),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder,
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
                        'Select Color',
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

                // Color Picker
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpendexTheme.spacingLg,
                  ),
                  child: CategoryColorPicker(
                    selectedColor: currentSelection,
                    onColorSelected: (color) {
                      setState(() {
                        currentSelection = color;
                      });
                    },
                  ),
                ),

                const SizedBox(height: SpendexTheme.spacing2xl),
              ],
            ),
          );
        },
      );
    },
  );
}
