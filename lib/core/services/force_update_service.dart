import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_logger.dart';

/// Service for checking if app update is required
class ForceUpdateService {
  ForceUpdateService._();

  static String? _currentVersion;
  static String? _minRequiredVersion;

  /// Initialize the service
  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    AppLogger.d('ForceUpdateService: Current version: $_currentVersion');
  }

  /// Check if update is required
  /// [minVersion] - Minimum required version from backend/remote config
  static bool isUpdateRequired(String minVersion) {
    _minRequiredVersion = minVersion;

    if (_currentVersion == null) return false;

    final current = _parseVersion(_currentVersion!);
    final required = _parseVersion(minVersion);

    // Compare versions
    for (int i = 0; i < 3; i++) {
      if (current[i] < required[i]) return true;
      if (current[i] > required[i]) return false;
    }

    return false;
  }

  /// Parse version string to list of integers
  static List<int> _parseVersion(String version) {
    final parts = version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }

  /// Show force update dialog
  static Future<void> showUpdateDialog(BuildContext context, {bool mandatory = false}) async {
    await showDialog(
      context: context,
      barrierDismissible: !mandatory,
      builder: (context) => AlertDialog(
        title: const Text('Update Required'),
        content: Text(
          mandatory
              ? 'A new version of Spendex is available. Please update to continue using the app.'
              : 'A new version of Spendex is available. Would you like to update now?',
        ),
        actions: [
          if (!mandatory)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () => _openStore(),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  /// Open app store
  static Future<void> _openStore() async {
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=in.spendex.app';
    const appStoreUrl = 'https://apps.apple.com/app/spendex/id0000000000';

    final Uri url;
    if (Theme.of(NavigatorState().context).platform == TargetPlatform.iOS) {
      url = Uri.parse(appStoreUrl);
    } else {
      url = Uri.parse(playStoreUrl);
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
