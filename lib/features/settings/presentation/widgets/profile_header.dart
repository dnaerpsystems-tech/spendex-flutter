import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Represents a user subscription plan tier
enum PlanTier {
  free('Free', SpendexColors.lightTextTertiary),
  pro('Pro', Color(0xFF3B82F6)),
  premium('Premium', Color(0xFF8B5CF6));

  const PlanTier(this.label, this.color);

  final String label;
  final Color color;
}

/// Profile header widget that displays user avatar, name, email, and plan badge.
///
/// Features:
/// - Circular avatar with user photo or initials fallback
/// - Overlay edit button with camera icon for photo upload
/// - User name displayed in headline style with bold weight
/// - User email shown in smaller gray text
/// - Plan badge chip with color-coded tier (Free/Pro/Premium)
/// - Material 3 design with proper spacing and alignment
/// - Dark mode support
///
/// Example:
/// ```dart
/// ProfileHeader(
///   name: 'John Doe',
///   email: 'john.doe@example.com',
///   photoUrl: 'https://example.com/avatar.jpg',
///   planTier: PlanTier.premium,
///   onEditPhoto: () {
///     // Handle photo edit
///   },
/// )
/// ```
class ProfileHeader extends StatelessWidget {
  /// Creates a profile header widget.
  ///
  /// [name] is the user's display name.
  /// [email] is the user's email address.
  /// [photoUrl] is optional URL to user's profile photo.
  /// [planTier] indicates the subscription level (defaults to free).
  /// [onEditPhoto] callback triggered when edit button is tapped.
  /// [avatarSize] controls the diameter of the avatar circle (defaults to 90).
  const ProfileHeader({
    required this.name,
    required this.email,
    super.key,
    this.photoUrl,
    this.planTier = PlanTier.free,
    this.onEditPhoto,
    this.avatarSize = 90,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final PlanTier planTier;
  final VoidCallback? onEditPhoto;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(SpendexTheme.spacing2xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  SpendexColors.darkSurface,
                  SpendexColors.darkSurface.withValues(alpha: 0.8),
                ]
              : [
                  SpendexColors.lightSurface,
                  SpendexColors.lightSurface.withValues(alpha: 0.95),
                ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              _buildAvatar(isDark),
              if (onEditPhoto != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildEditButton(isDark),
                ),
            ],
          ),
          const SizedBox(height: SpendexTheme.spacingLg),
          Text(
            name,
            style: SpendexTheme.headlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacingXs),
          Text(
            email,
            style: SpendexTheme.bodyMedium.copyWith(
              color: secondaryTextColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpendexTheme.spacingMd),
          _buildPlanBadge(isDark),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isDark) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasPhoto
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  SpendexColors.primary,
                  SpendexColors.primaryDark,
                ],
              ),
        border: Border.all(
          color: isDark
              ? SpendexColors.darkBorder
              : SpendexColors.lightBorder,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: hasPhoto
          ? ClipOval(
              child: Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitials();
                },
              ),
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(name);
    return Center(
      child: Text(
        initials,
        style: SpendexTheme.displayLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: avatarSize * 0.4,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  Widget _buildEditButton(bool isDark) {
    return Material(
      color: SpendexColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: SpendexColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: onEditPhoto,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.camera,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingMd,
        vertical: SpendexTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: planTier.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
        border: Border.all(
          color: planTier.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            planTier == PlanTier.premium
                ? Iconsax.crown5
                : planTier == PlanTier.pro
                    ? Iconsax.star5
                    : Iconsax.user,
            color: planTier.color,
            size: 16,
          ),
          const SizedBox(width: SpendexTheme.spacingXs),
          Text(
            '${planTier.label} Plan',
            style: SpendexTheme.labelMedium.copyWith(
              color: planTier.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
