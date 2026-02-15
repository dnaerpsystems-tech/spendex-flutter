import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Represents different device types for display
enum DeviceType {
  mobile('Mobile', Iconsax.mobile),
  tablet('Tablet', Iconsax.mobile),
  desktop('Desktop', Iconsax.monitor),
  browser('Browser', Iconsax.global);

  const DeviceType(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Device information tile that displays logged-in device details.
///
/// Features:
/// - Device type icon (phone/tablet/laptop/desktop/browser)
/// - Device name and model
/// - OS and browser information
/// - Last active timestamp with relative time formatting
/// - Current device badge chip
/// - Remove button with confirmation
/// - Card styling with elevation and borders
/// - Dark mode support
///
/// Example:
/// ```dart
/// DeviceTile(
///   deviceType: DeviceType.mobile,
///   deviceName: 'iPhone 13',
///   osInfo: 'iOS 16.2',
///   browserInfo: 'Safari',
///   lastActive: DateTime.now().subtract(Duration(hours: 2)),
///   isCurrentDevice: true,
///   onRemove: () {
///     // Handle device removal
///   },
/// )
/// ```
class DeviceTile extends StatelessWidget {
  /// Creates a device tile widget.
  ///
  /// [deviceType] indicates the type of device.
  /// [deviceName] is the name or model of the device.
  /// [osInfo] describes the operating system (e.g., "iOS 16", "Windows 11").
  /// [browserInfo] is optional browser information.
  /// [lastActive] is the timestamp of last activity.
  /// [isCurrentDevice] marks this as the active device.
  /// [onRemove] callback triggered when remove button is tapped.
  const DeviceTile({
    required this.deviceType,
    required this.deviceName,
    required this.osInfo,
    required this.lastActive,
    super.key,
    this.browserInfo,
    this.isCurrentDevice = false,
    this.onRemove,
  });

  final DeviceType deviceType;
  final String deviceName;
  final String osInfo;
  final String? browserInfo;
  final DateTime lastActive;
  final bool isCurrentDevice;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final borderColor = isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        side: BorderSide(color: borderColor),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceIcon(isDark),
            const SizedBox(width: SpendexTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          deviceName,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isCurrentDevice) _buildCurrentBadge(),
                    ],
                  ),
                  const SizedBox(height: SpendexTheme.spacingXs),
                  Text(
                    _buildDeviceInfo(),
                    style: SpendexTheme.labelMedium.copyWith(
                      color: secondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingXs),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatLastActive(lastActive),
                        style: SpendexTheme.labelMedium.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCurrentDevice && onRemove != null) ...[
              const SizedBox(width: SpendexTheme.spacingSm),
              _buildRemoveButton(context, isDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(bool isDark) {
    const iconColor = SpendexColors.primary;
    final backgroundColor = iconColor.withValues(alpha: 0.1);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
      ),
      child: Icon(
        deviceType.icon,
        color: iconColor,
        size: 24,
      ),
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpendexTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: SpendexColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        border: Border.all(
          color: SpendexColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        'This device',
        style: SpendexTheme.labelMedium.copyWith(
          color: SpendexColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showRemoveConfirmation(context),
        borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(SpendexTheme.spacingSm),
          child: const Icon(
            Iconsax.trash,
            color: SpendexColors.expense,
            size: 18,
          ),
        ),
      ),
    );
  }

  String _buildDeviceInfo() {
    final parts = <String>[osInfo];
    if (browserInfo != null && browserInfo!.isNotEmpty) {
      parts.add(browserInfo!);
    }
    return parts.join(' • ');
  }

  String _formatLastActive(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours > 1 ? "s" : ""} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _showRemoveConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
        final secondaryTextColor =
            isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
          ),
          title: Text(
            'Remove Device',
            style: SpendexTheme.headlineMedium.copyWith(
              color: textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to remove this device? You will be logged out from this device.',
            style: SpendexTheme.bodyMedium.copyWith(
              color: secondaryTextColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.expense,
                foregroundColor: Colors.white,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if ((result ?? false) && onRemove != null) {
      onRemove!();
    }
  }
}
