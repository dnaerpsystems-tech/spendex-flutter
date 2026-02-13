import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Bottom sheet widget for selecting avatar/profile photo options.
///
/// Features:
/// - Three action options: Camera, Gallery, Remove
/// - Each option displayed as a ListTile with icon and label
/// - Remove option styled in red color
/// - Rounded top corners for sheet
/// - Callbacks for each action
/// - Material 3 bottom sheet design
/// - Dark mode support
///
/// Example:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   builder: (context) => AvatarPickerSheet(
///     onCameraSelected: () {
///       // Open camera
///     },
///     onGallerySelected: () {
///       // Open gallery
///     },
///     onRemoveSelected: () {
///       // Remove photo
///     },
///   ),
/// );
/// ```
class AvatarPickerSheet extends StatelessWidget {
  /// Creates an avatar picker bottom sheet.
  ///
  /// [onCameraSelected] callback triggered when camera option is tapped.
  /// [onGallerySelected] callback triggered when gallery option is tapped.
  /// [onRemoveSelected] callback triggered when remove option is tapped.
  /// [showRemoveOption] controls visibility of remove option (defaults to true).
  const AvatarPickerSheet({
    super.key,
    this.onCameraSelected,
    this.onGallerySelected,
    this.onRemoveSelected,
    this.showRemoveOption = true,
  });

  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;
  final VoidCallback? onRemoveSelected;
  final bool showRemoveOption;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SpendexTheme.spacingMd),
            _buildHandle(isDark),
            const SizedBox(height: SpendexTheme.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacing2xl,
              ),
              child: Text(
                'Change Profile Photo',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
            _buildOptionTile(
              context: context,
              icon: Iconsax.camera,
              title: 'Take Photo',
              subtitle: 'Use camera to take a new photo',
              color: SpendexColors.primary,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                onCameraSelected?.call();
              },
            ),
            _buildOptionTile(
              context: context,
              icon: Iconsax.gallery,
              title: 'Choose from Gallery',
              subtitle: 'Select photo from your gallery',
              color: SpendexColors.transfer,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              onTap: () {
                Navigator.of(context).pop();
                onGallerySelected?.call();
              },
            ),
            if (showRemoveOption)
              _buildOptionTile(
                context: context,
                icon: Iconsax.trash,
                title: 'Remove Photo',
                subtitle: 'Remove current profile photo',
                color: SpendexColors.expense,
                textColor: SpendexColors.expense,
                secondaryTextColor: secondaryTextColor,
                isDestructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  onRemoveSelected?.call();
                },
              ),
            const SizedBox(height: SpendexTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(bool isDark) {
    final handleColor = isDark
        ? SpendexColors.darkTextTertiary
        : SpendexColors.lightTextTertiary;

    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: handleColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hoverColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        hoverColor: hoverColor,
        splashColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacing2xl,
            vertical: SpendexTheme.spacingMd,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: SpendexTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: SpendexTheme.labelMedium.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
