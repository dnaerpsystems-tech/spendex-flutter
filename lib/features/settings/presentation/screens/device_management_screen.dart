import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/device_session_model.dart';
import '../providers/settings_provider.dart';
import '../widgets/device_tile.dart';

/// Device Management Screen for managing active sessions and devices.
///
/// Features:
/// - View all active device sessions from API
/// - Remove individual devices (logout remote sessions)
/// - Logout all other devices except current
/// - Current device highlighted with badge
/// - Pull-to-refresh to reload device list
/// - Real API integration via settingsStateProvider
/// - Shimmer loading states
/// - Error and empty states
/// - Automatic device detection with device_info_plus
///
/// API Endpoints:
/// - GET /user/sessions: Fetch all active sessions
/// - DELETE /user/sessions/:id: Revoke specific session
/// - DELETE /user/sessions/all: Logout all except current
class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load device sessions on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevices();
    });
  }

  Future<void> _loadDevices() async {
    await ref.read(settingsStateProvider.notifier).loadDeviceSessions();
  }

  Future<void> _removeDevice(String deviceId) async {
    final confirmed = await _showRemoveDeviceDialog();
    if (confirmed != true) {
      return;
    }

    final success = await ref.read(settingsStateProvider.notifier).revokeDeviceSession(deviceId);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device removed successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SpendexColors.income,
        ),
      );
    } else {
      final error = ref.read(settingsErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to remove device'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SpendexColors.expense,
        ),
      );
    }
  }

  Future<bool?> _showRemoveDeviceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: Text(
          'Remove Device?',
          style: SpendexTheme.headlineMedium.copyWith(
            color: textColor,
          ),
        ),
        content: Text(
          'This device will be logged out immediately.',
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
      ),
    );
  }

  Future<void> _logoutAllDevices() async {
    final confirmed = await _showLogoutAllDialog();
    if (confirmed != true) {
      return;
    }

    final success = await ref.read(settingsStateProvider.notifier).revokeAllDeviceSessions();

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out all other devices'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SpendexColors.income,
        ),
      );
    } else {
      final error = ref.read(settingsErrorProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to logout devices'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: SpendexColors.expense,
        ),
      );
    }
  }

  Future<bool?> _showLogoutAllDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
        ),
        title: Text(
          'Logout All Devices?',
          style: SpendexTheme.headlineMedium.copyWith(
            color: textColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will logout all devices except this one.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SpendexColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                border: Border.all(
                  color: SpendexColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.warning_2,
                    color: SpendexColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "You'll need to login again on those devices.",
                      style: SpendexTheme.labelMedium.copyWith(
                        color: SpendexColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            child: const Text('Logout All'),
          ),
        ],
      ),
    );
  }

  DeviceType _mapStringToDeviceType(String deviceType) {
    switch (deviceType.toLowerCase()) {
      case 'mobile':
        return DeviceType.mobile;
      case 'tablet':
        return DeviceType.tablet;
      case 'desktop':
        return DeviceType.desktop;
      case 'web':
      case 'browser':
        return DeviceType.browser;
      default:
        return DeviceType.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    final deviceSessions = ref.watch(deviceSessionsProvider);
    final isLoading = ref.watch(settingsLoadingProvider);
    final error = ref.watch(settingsErrorProvider);
    final otherDevices = ref.watch(otherDeviceSessionsProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        centerTitle: true,
        title: Text(
          'Active Sessions',
          style: SpendexTheme.headlineMedium.copyWith(
            color: textColor,
          ),
        ),
        actions: [
          if (otherDevices.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.logout),
              tooltip: 'Logout All',
              onPressed: _logoutAllDevices,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDevices,
        child: _buildBody(
          isDark: isDark,
          deviceSessions: deviceSessions,
          isLoading: isLoading,
          error: error,
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isDark,
    required List<DeviceSessionModel> deviceSessions,
    required bool isLoading,
    required String? error,
  }) {
    if (isLoading && deviceSessions.isEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: SpendexTheme.spacingMd),
        itemBuilder: (context, index) => _DeviceSessionSkeleton(isDark: isDark),
      );
    }

    if (error != null && deviceSessions.isEmpty) {
      return ErrorStateWidget(
        message: error,
        icon: Iconsax.warning_2,
        onRetry: _loadDevices,
      );
    }

    if (deviceSessions.isEmpty) {
      return const EmptyStateWidget(
        icon: Iconsax.devices,
        title: 'No active sessions',
        subtitle: "You don't have any active device sessions.",
      );
    }

    final currentDevice = deviceSessions.firstWhere(
      (device) => device.isCurrent,
      orElse: () => deviceSessions.first,
    );
    final otherDevices = deviceSessions.where((device) => !device.isCurrent).toList()
      ..sort((a, b) => b.lastActive.compareTo(a.lastActive));

    return ListView(
      padding: const EdgeInsets.all(SpendexTheme.spacingLg),
      children: [
        DeviceTile(
          deviceType: _mapStringToDeviceType(currentDevice.deviceType),
          deviceName: currentDevice.deviceName,
          osInfo: currentDevice.os,
          browserInfo: (currentDevice.browser?.isNotEmpty ?? false) ? currentDevice.browser : null,
          lastActive: currentDevice.lastActive,
          isCurrentDevice: true,
        ),
        if (otherDevices.isNotEmpty) ...[
          const SizedBox(height: SpendexTheme.spacingMd),
          ...otherDevices.map(
            (device) => Padding(
              padding: const EdgeInsets.only(bottom: SpendexTheme.spacingMd),
              child: DeviceTile(
                deviceType: _mapStringToDeviceType(device.deviceType),
                deviceName: device.deviceName,
                osInfo: device.os,
                browserInfo: (device.browser?.isNotEmpty ?? false) ? device.browser : null,
                lastActive: device.lastActive,
                onRemove: () => _removeDevice(device.id),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Skeleton loading widget for device session list.
///
/// Displays a shimmer placeholder while device sessions are being loaded.
class _DeviceSessionSkeleton extends StatefulWidget {
  const _DeviceSessionSkeleton({
    required this.isDark,
  });

  final bool isDark;

  @override
  State<_DeviceSessionSkeleton> createState() => _DeviceSessionSkeletonState();
}

class _DeviceSessionSkeletonState extends State<_DeviceSessionSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final borderColor = widget.isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;
    final shimmerBaseColor = widget.isDark
        ? SpendexColors.darkTextSecondary.withValues(alpha: 0.1)
        : SpendexColors.lightTextSecondary.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: shimmerBaseColor.withValues(alpha: _animation.value),
                    borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
                  ),
                ),
                const SizedBox(width: SpendexTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: shimmerBaseColor.withValues(
                            alpha: _animation.value,
                          ),
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingSm),
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: shimmerBaseColor.withValues(
                            alpha: _animation.value,
                          ),
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                      ),
                      const SizedBox(height: SpendexTheme.spacingSm),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: shimmerBaseColor.withValues(
                            alpha: _animation.value,
                          ),
                          borderRadius: BorderRadius.circular(SpendexTheme.radiusSm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
