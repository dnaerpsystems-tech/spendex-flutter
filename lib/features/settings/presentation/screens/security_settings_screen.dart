import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/security/auto_lock_service.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/pin_service.dart';
import '../../../../core/security/security_provider.dart';
import '../widgets/security_option_card.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  String _autoLockDuration = 'never';
  bool _biometricAvailable = false;
  final int _activeSessions = 1;
  bool _isLoading = false;

  late final PinService _pinService;
  late final BiometricService _biometricService;
  late final AutoLockService _autoLockService;

  @override
  void initState() {
    super.initState();
    _pinService = getIt<PinService>();
    _biometricService = getIt<BiometricService>();
    _autoLockService = getIt<AutoLockService>();
    _initSecuritySettings();
  }

  Future<void> _initSecuritySettings() async {
    await Future.wait([
      _checkBiometricAvailability(),
      _loadSecuritySettings(),
    ]);
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (mounted) {
        setState(() {
          _biometricAvailable = isAvailable;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _biometricAvailable = false;
        });
      }
    }
  }

  Future<void> _loadSecuritySettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final isPinSet = await _pinService.isPinSet();
      final isBiometricEnabled = await _biometricService.isBiometricEnabled();
      final autoLockTimeout = _autoLockService.timeout;
      final autoLockEnabled = _autoLockService.isEnabled;

      if (mounted) {
        setState(() {
          _pinEnabled = isPinSet;
          _biometricEnabled = isBiometricEnabled;
          _autoLockDuration = _durationToString(autoLockTimeout, autoLockEnabled);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Convert Duration and enabled state to string representation.
  String _durationToString(Duration duration, bool enabled) {
    if (!enabled) {
      return 'never';
    }
    if (duration.inSeconds <= 0) {
      return 'immediate';
    }
    if (duration.inMinutes == 1) {
      return '1';
    }
    if (duration.inMinutes == 5) {
      return '5';
    }
    if (duration.inMinutes == 15) {
      return '15';
    }
    return 'never';
  }

  /// Convert string representation to Duration.
  Duration _stringToDuration(String value) {
    switch (value) {
      case 'immediate':
        return Duration.zero;
      case '1':
        return const Duration(minutes: 1);
      case '5':
        return const Duration(minutes: 5);
      case '15':
        return const Duration(minutes: 15);
      default:
        return const Duration(minutes: 5);
    }
  }

  Future<void> _togglePinLock(bool value) async {
    if (value) {
      final result = await context.push<bool>('/settings/set-pin');
      if ((result ?? false) || result == null) {
        await _loadSecuritySettings();
        // Refresh the pinAuthStateProvider
        unawaited(ref.read(pinAuthStateProvider.notifier).refresh());
      }
    } else {
      await _showRemovePinDialog();
    }
  }

  Future<void> _showRemovePinDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN?'),
        content: const Text(
          'This will disable PIN lock and biometric authentication. '
          'Your app will no longer require authentication to access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _removePin();
    }
  }

  Future<void> _removePin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _pinService.clearPin();
      await _biometricService.disableBiometric();
      await _autoLockService.setEnabled(enabled: false);

      // Refresh the pinAuthStateProvider
      unawaited(ref.read(pinAuthStateProvider.notifier).refresh());

      if (mounted) {
        setState(() {
          _pinEnabled = false;
          _biometricEnabled = false;
          _autoLockDuration = 'never';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN removed successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove PIN. Please try again.'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (value) {
        // Require biometric verification before enabling
        final authenticated = await _biometricService.authenticateWithBiometric(
          reason: 'Verify your identity to enable biometric authentication',
        );
        if (!authenticated) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }
        await _biometricService.enableBiometric();
      } else {
        await _biometricService.disableBiometric();
      }

      if (mounted) {
        setState(() {
          _biometricEnabled = value;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Biometric authentication enabled' : 'Biometric authentication disabled',
            ),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update biometric setting'),
            backgroundColor: SpendexColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAutoLockSelector() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AutoLockSelectorSheet(
        currentSelection: _autoLockDuration,
      ),
    );

    if (result != null && result != _autoLockDuration) {
      setState(() {
        _isLoading = true;
      });
      try {
        if (result == 'never') {
          await _autoLockService.setEnabled(enabled: false);
        } else {
          await _autoLockService.setEnabled(enabled: true);
          await _autoLockService.setTimeout(_stringToDuration(result));
        }
        if (mounted) {
          setState(() {
            _autoLockDuration = result;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Auto-lock set to ${_getAutoLockLabel(result)}'),
              backgroundColor: SpendexColors.income,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update auto-lock setting'),
              backgroundColor: SpendexColors.expense,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
            ),
          );
        }
      }
    }
  }

  String _getAutoLockLabel(String value) {
    switch (value) {
      case 'never':
        return 'Never';
      case 'immediate':
        return 'Immediately';
      case '1':
        return '1 minute';
      case '5':
        return '5 minutes';
      case '15':
        return '15 minutes';
      default:
        return 'Never';
    }
  }

  Future<void> _changePin() async {
    final result = await context.push<bool>('/settings/set-pin');
    if ((result ?? false) || result == null) {
      // Refresh the pinAuthStateProvider
      unawaited(ref.read(pinAuthStateProvider.notifier).refresh());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN changed successfully'),
            backgroundColor: SpendexColors.income,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(
                    title: 'PIN Security',
                    isDark: isDark,
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.lock,
                    title: 'PIN Lock',
                    description: 'Secure your app with a PIN code',
                    isEnabled: _pinEnabled,
                    onToggle: _togglePinLock,
                  ),
                  if (_pinEnabled) ...[
                    const SizedBox(height: SpendexTheme.spacingSm),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
                        side: BorderSide(
                          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                        ),
                      ),
                      color: cardColor,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(
                              Iconsax.edit,
                              color: SpendexColors.primary,
                            ),
                            title: Text(
                              'Change PIN',
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: secondaryTextColor,
                            ),
                            onTap: _changePin,
                          ),
                          Divider(
                            height: 1,
                            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                          ),
                          ListTile(
                            leading: const Icon(
                              Iconsax.trash,
                              color: SpendexColors.expense,
                            ),
                            title: Text(
                              'Remove PIN',
                              style: SpendexTheme.bodyMedium.copyWith(
                                color: SpendexColors.expense,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: secondaryTextColor,
                            ),
                            onTap: _showRemovePinDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  _SectionTitle(
                    title: 'Biometric Authentication',
                    isDark: isDark,
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.finger_scan,
                    title: 'Biometric Authentication',
                    description: _getBiometricDescription(),
                    isEnabled: _biometricEnabled && _pinEnabled,
                    showSwitch: _pinEnabled && _biometricAvailable,
                    onToggle: _pinEnabled && _biometricAvailable ? _toggleBiometric : null,
                  ),
                  if (!_pinEnabled || !_biometricAvailable) ...[
                    const SizedBox(height: SpendexTheme.spacingSm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpendexTheme.spacingMd,
                      ),
                      child: Text(
                        _getBiometricHelperText(),
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: SpendexColors.warning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  _SectionTitle(
                    title: 'Auto-Lock',
                    isDark: isDark,
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.timer,
                    title: 'Auto-Lock',
                    description: _getAutoLockLabel(_autoLockDuration),
                    isEnabled: _pinEnabled || _biometricEnabled,
                    showSwitch: false,
                    showArrow: true,
                    onTap: (_pinEnabled || _biometricEnabled) ? _showAutoLockSelector : null,
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  _SectionTitle(
                    title: 'Sessions & Devices',
                    isDark: isDark,
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.devices,
                    title: 'Active Sessions',
                    description: 'Manage logged-in devices',
                    showSwitch: false,
                    showArrow: true,
                    onTap: () {
                      context.push('/security/devices');
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: SpendexColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                          ),
                          child: Text(
                            '$_activeSessions',
                            style: SpendexTheme.labelMedium.copyWith(
                              color: SpendexColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Icon(
                          Icons.chevron_right,
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                  _SectionTitle(
                    title: 'Additional Security',
                    isDark: isDark,
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.security,
                    title: 'Two-Factor Authentication',
                    description: 'Add an extra layer of security',
                    isEnabled: false,
                    showSwitch: false,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: SpendexColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                        border: Border.all(
                          color: SpendexColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: SpendexTheme.labelMedium.copyWith(
                          color: SpendexColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpendexTheme.spacingMd),
                  SecurityOptionCard(
                    icon: Iconsax.document_text,
                    title: 'Security Log',
                    description: 'View recent security events',
                    showSwitch: false,
                    showArrow: true,
                    onTap: () {
                      context.push('/security/log');
                    },
                  ),
                  const SizedBox(height: SpendexTheme.spacing2xl),
                ],
              ),
            ),
    );
  }

  String _getBiometricDescription() {
    if (!_pinEnabled) {
      return 'PIN must be set first';
    }
    if (!_biometricAvailable) {
      return 'Not available on this device';
    }
    return 'Use fingerprint or face to unlock';
  }

  String _getBiometricHelperText() {
    if (!_pinEnabled) {
      return 'Set up a PIN first to enable biometric authentication';
    }
    if (!_biometricAvailable) {
      return 'Biometric authentication is not available on this device';
    }
    return '';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.isDark,
  });

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpendexTheme.spacingSm),
      child: Text(
        title,
        style: SpendexTheme.titleMedium.copyWith(
          color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _AutoLockSelectorSheet extends StatelessWidget {
  const _AutoLockSelectorSheet({
    required this.currentSelection,
  });

  final String currentSelection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    final options = [
      {'value': 'never', 'label': 'Never'},
      {'value': 'immediate', 'label': 'Immediately'},
      {'value': '1', 'label': '1 minute'},
      {'value': '5', 'label': '5 minutes'},
      {'value': '15', 'label': '15 minutes'},
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: SpendexTheme.spacingMd),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpendexTheme.spacingLg,
              ),
              child: Text(
                'Auto-Lock Timer',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option['value'] == currentSelection;

                return ListTile(
                  title: Text(
                    option['label']!,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Iconsax.tick_circle,
                          color: SpendexColors.primary,
                          size: 24,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context, option['value']);
                  },
                );
              },
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}
