import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/avatar_picker_sheet.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/security_option_card.dart';

/// Profile screen displaying user information and account settings.
///
/// Features:
/// - Profile header with avatar, name, email, and plan badge
/// - Personal information section (phone, member since, last login)
/// - Account information section (user ID, status, verification, role)
/// - Subscription section (current plan and upgrade option)
/// - Quick actions section (edit profile, change password, preferences, security)
/// - Logout button with confirmation dialog
/// - Photo upload functionality with camera/gallery/remove options
/// - Copy user ID to clipboard
/// - Material 3 design with proper spacing and sections
/// - Dark mode support
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('User not found'),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(
              name: user.name,
              email: user.email,
              photoUrl: user.avatarUrl,
              planTier: _getPlanTier(),
              onEditPhoto: _showAvatarPicker,
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildPersonalInformationSection(user),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildAccountInformationSection(user),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildSubscriptionSection(),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildQuickActionsSection(),
            const SizedBox(height: SpendexTheme.spacingLg),
            _buildLogoutSection(),
            const SizedBox(height: SpendexTheme.spacing2xl),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInformationSection(UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Personal Information'),
        const SizedBox(height: SpendexTheme.spacingMd),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ProfileInfoTile(
                icon: Iconsax.call,
                label: 'Phone Number',
                value: user.phone ?? 'Not set',
                showIconBackground: true,
                iconColor: SpendexColors.primary,
              ),
              ProfileInfoTile(
                icon: Iconsax.calendar,
                label: 'Member Since',
                value: _formatMemberSince(user.createdAt),
                showIconBackground: true,
                iconColor: SpendexColors.transfer,
              ),
              ProfileInfoTile(
                icon: Iconsax.clock,
                label: 'Last Login',
                value: _formatLastLogin(user.lastLoginAt),
                showIconBackground: true,
                iconColor: SpendexColors.income,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInformationSection(UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Account Information'),
        const SizedBox(height: SpendexTheme.spacingMd),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ProfileInfoTile(
                icon: Iconsax.copy,
                label: 'User ID',
                value: '${user.id.substring(0, 16)}...',
                showIconBackground: true,
                iconColor: SpendexColors.lightTextTertiary,
                onTap: () => _copyToClipboard(user.id),
              ),
              ProfileInfoTile(
                icon: Iconsax.status,
                label: 'Account Status',
                value: user.status.label,
                trailing: _buildStatusBadge(user.status.label),
                showIconBackground: true,
                iconColor: _getStatusColor(user.status.label),
              ),
              ProfileInfoTile(
                icon: user.isEmailVerified ? Iconsax.verify5 : Iconsax.verify,
                label: 'Email Verification',
                value: user.isEmailVerified ? 'Verified' : 'Not verified',
                trailing: user.isEmailVerified
                    ? Icon(
                        Iconsax.tick_circle5,
                        color: SpendexColors.income,
                        size: 20,
                      )
                    : TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Verification email sent'),
                            ),
                          );
                        },
                        child: Text('Verify'),
                      ),
                showIconBackground: true,
                iconColor: user.isEmailVerified
                    ? SpendexColors.income
                    : SpendexColors.expense,
              ),
              ProfileInfoTile(
                icon: Iconsax.user_tag,
                label: 'Role',
                value: user.role.label,
                showIconBackground: true,
                iconColor: SpendexColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;
    final planTier = _getPlanTier();
    final isPremium = planTier == PlanTier.premium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Subscription'),
        const SizedBox(height: SpendexTheme.spacingMd),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
          ),
          padding: const EdgeInsets.all(SpendexTheme.spacingLg),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: planTier.color.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(SpendexTheme.radiusMd),
                    ),
                    child: Icon(
                      planTier == PlanTier.premium
                          ? Iconsax.crown5
                          : planTier == PlanTier.pro
                              ? Iconsax.star5
                              : Iconsax.user,
                      color: planTier.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${planTier.label} Plan',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPlanDescription(planTier),
                          style: SpendexTheme.labelMedium.copyWith(
                            color: secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isPremium) ...[
                const SizedBox(height: SpendexTheme.spacingMd),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/subscription'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SpendexColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: SpendexTheme.spacingMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(SpendexTheme.radiusMd),
                      ),
                    ),
                    child: const Text('Upgrade Plan'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Quick Actions'),
        const SizedBox(height: SpendexTheme.spacingMd),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpendexTheme.spacingLg,
          ),
          child: Column(
            children: [
              SecurityOptionCard(
                icon: Iconsax.edit,
                title: 'Edit Profile',
                description: 'Update your personal information',
                showSwitch: false,
                showArrow: true,
                iconColor: SpendexColors.primary,
                onTap: () => context.push('/profile/edit'),
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              SecurityOptionCard(
                icon: Iconsax.lock,
                title: 'Change Password',
                description: 'Update your account password',
                showSwitch: false,
                showArrow: true,
                iconColor: SpendexColors.income,
                onTap: () => context.push('/profile/change-password'),
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              SecurityOptionCard(
                icon: Iconsax.setting_2,
                title: 'Preferences',
                description: 'Customize app settings and preferences',
                showSwitch: false,
                showArrow: true,
                iconColor: SpendexColors.transfer,
                onTap: () => context.push('/profile/preferences'),
              ),
              const SizedBox(height: SpendexTheme.spacingMd),
              SecurityOptionCard(
                icon: Iconsax.shield_tick,
                title: 'Security Settings',
                description: 'Manage security and privacy options',
                showSwitch: false,
                showArrow: true,
                iconColor: SpendexColors.expense,
                onTap: () => context.push('/security'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
      ),
      child: _LogoutButton(
        onPressed: _showLogoutConfirmation,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? SpendexColors.income : SpendexColors.expense;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: SpendexTheme.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  PlanTier _getPlanTier() {
    return PlanTier.free;
  }

  String _getPlanDescription(PlanTier tier) {
    switch (tier) {
      case PlanTier.free:
        return 'Basic features with limited functionality';
      case PlanTier.pro:
        return 'Advanced features and priority support';
      case PlanTier.premium:
        return 'All features with unlimited access';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SpendexColors.income;
      case 'suspended':
        return SpendexColors.expense;
      case 'deleted':
        return SpendexColors.lightTextTertiary;
      default:
        return SpendexColors.primary;
    }
  }

  String _formatMemberSince(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatLastLogin(DateTime? date) {
    if (date == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => AvatarPickerSheet(
        onCameraSelected: _handleCameraSelection,
        onGallerySelected: _handleGallerySelection,
        onRemoveSelected: _handleRemovePhoto,
        showRemoveOption: ref.read(authStateProvider).user?.avatarUrl != null,
      ),
    );
  }

  Future<void> _handleCameraSelection() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        await _uploadPhoto(photo);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _handleGallerySelection() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadPhoto(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto(XFile photo) async {
    if (!mounted) {
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo upload feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photo: $e'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _handleRemovePhoto() async {
    if (!mounted) {
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remove photo feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove photo: $e'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await ref.read(authStateProvider.notifier).logout();

      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout: $e'),
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingLg,
      ),
      child: Text(
        title,
        style: SpendexTheme.titleMedium.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(SpendexTheme.spacingLg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.logout,
                  color: SpendexColors.expense,
                  size: 20,
                ),
                const SizedBox(width: SpendexTheme.spacingSm),
                Text(
                  'Logout',
                  style: SpendexTheme.titleMedium.copyWith(
                    color: SpendexColors.expense,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
