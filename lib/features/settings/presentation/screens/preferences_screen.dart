import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/preference_tile.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  Timer? _debounceTimer;
  bool _isSaving = false;

  late String _theme;
  late String _currency;
  late String _locale;
  late String _dateFormat;
  late bool _notifications;
  late bool _budgetAlerts;
  late bool _emiReminders;
  late bool _goalMilestones;
  late bool _transactionAlerts;
  late bool _showBalanceBadge;
  late bool _requireAuth;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _initializePreferences(user.preferences);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initializePreferences(UserPreferences prefs) {
    _theme = prefs.theme;
    _currency = prefs.currency;
    _locale = prefs.locale;
    _dateFormat = prefs.dateFormat;
    _notifications = prefs.notifications;
    _budgetAlerts = prefs.budgetAlerts;
    _emiReminders = prefs.emiReminders;
    _goalMilestones = prefs.goalMilestones;
    _transactionAlerts = prefs.transactionAlerts;
    _showBalanceBadge = prefs.showBalanceBadge;
    _requireAuth = prefs.requireAuth;
  }

  Future<void> _updatePreference<T>(String key, T value) async {
    _debounceTimer?.cancel();

    setState(() {
      switch (key) {
        case 'theme':
          _theme = value as String;
        case 'currency':
          _currency = value as String;
        case 'locale':
          _locale = value as String;
        case 'dateFormat':
          _dateFormat = value as String;
        case 'notifications':
          _notifications = value as bool;
        case 'budgetAlerts':
          _budgetAlerts = value as bool;
        case 'emiReminders':
          _emiReminders = value as bool;
        case 'goalMilestones':
          _goalMilestones = value as bool;
        case 'transactionAlerts':
          _transactionAlerts = value as bool;
        case 'showBalanceBadge':
          _showBalanceBadge = value as bool;
        case 'requireAuth':
          _requireAuth = value as bool;
      }
      _isSaving = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final newPreferences = UserPreferences(
        theme: _theme,
        currency: _currency,
        locale: _locale,
        dateFormat: _dateFormat,
        notifications: _notifications,
        budgetAlerts: _budgetAlerts,
        emiReminders: _emiReminders,
        goalMilestones: _goalMilestones,
        transactionAlerts: _transactionAlerts,
        showBalanceBadge: _showBalanceBadge,
        requireAuth: _requireAuth,
      );

      final success = await ref.read(authStateProvider.notifier).updatePreferences(newPreferences);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (success) {
          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Preferences updated successfully'),
              backgroundColor: SpendexColors.income,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
            ),
          );
        } else {
          final user = ref.read(currentUserProvider);
          if (user != null && mounted) {
            setState(() {
              _initializePreferences(user.preferences);
            });
          }

          if (!mounted) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update preferences'),
              backgroundColor: SpendexColors.expense,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
              ),
            ),
          );
        }
      }
    });
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'system':
        return 'System';
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }

  String _getLanguageLabel(String locale) {
    switch (locale) {
      case 'en':
        return 'English';
      case 'hi':
        return 'Hindi';
      default:
        return 'English';
    }
  }

  void _showThemeSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.moon,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Text(
                    'Select Theme',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('System'),
              subtitle: const Text('Follow system settings'),
              value: 'system',
              // ignore: deprecated_member_use
              groupValue: _theme,
              activeColor: SpendexColors.primary,
              // ignore: deprecated_member_use
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updatePreference('theme', value);
                }
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Light'),
              subtitle: const Text('Light mode'),
              value: 'light',
              // ignore: deprecated_member_use
              groupValue: _theme,
              activeColor: SpendexColors.primary,
              // ignore: deprecated_member_use
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updatePreference('theme', value);
                }
              },
            ),
            // ignore: deprecated_member_use
            RadioListTile<String>(
              title: const Text('Dark'),
              subtitle: const Text('Dark mode'),
              value: 'dark',
              // ignore: deprecated_member_use
              groupValue: _theme,
              activeColor: SpendexColors.primary,
              // ignore: deprecated_member_use
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null) {
                  _updatePreference('theme', value);
                }
              },
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showCurrencySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencies = ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD'];
    final currencySymbols = {
      'INR': '₹',
      'USD': r'$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'AUD': r'A$',
      'CAD': r'C$',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.money,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Text(
                    'Select Currency',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...currencies.map(
              (currency) => RadioListTile<String>(
                title: Text('$currency (${currencySymbols[currency]})'),
                value: currency,
                // ignore: deprecated_member_use
                groupValue: _currency,
                activeColor: SpendexColors.primary,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    _updatePreference('currency', value);
                  }
                },
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languages = {
      'en': 'English',
      'hi': 'Hindi',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.language_square,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Text(
                    'Select Language',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...languages.entries.map(
              (entry) => RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                // ignore: deprecated_member_use
                groupValue: _locale,
                activeColor: SpendexColors.primary,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    _updatePreference('locale', value);
                  }
                },
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  void _showDateFormatSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formats = {
      'DD-MM-YYYY': 'DD-MM-YYYY',
      'MM-DD-YYYY': 'MM-DD-YYYY',
      'YYYY-MM-DD': 'YYYY-MM-DD',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpendexTheme.radiusLg),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.calendar,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: SpendexTheme.spacingMd),
                  Text(
                    'Select Date Format',
                    style: SpendexTheme.headlineMedium.copyWith(
                      color:
                          isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ...formats.entries.map(
              (entry) => RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                // ignore: deprecated_member_use
                groupValue: _dateFormat,
                activeColor: SpendexColors.primary,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  Navigator.pop(context);
                  if (value != null) {
                    _updatePreference('dateFormat', value);
                  }
                },
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpendexTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle(title: 'Appearance'),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.moon,
              title: 'Theme',
              subtitle: _getThemeLabel(_theme),
              showArrow: true,
              onTap: _showThemeSelector,
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            const _SectionTitle(title: 'Currency & Region'),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.money,
              title: 'Currency',
              subtitle: _currency,
              showArrow: true,
              onTap: _showCurrencySelector,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.language_square,
              title: 'Language',
              subtitle: _getLanguageLabel(_locale),
              showArrow: true,
              onTap: _showLanguageSelector,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.calendar,
              title: 'Date Format',
              subtitle: _dateFormat,
              showArrow: true,
              onTap: _showDateFormatSelector,
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            const _SectionTitle(title: 'Notifications'),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.notification,
              title: 'Enable Notifications',
              subtitle: 'Receive push notifications',
              showSwitch: true,
              switchValue: _notifications,
              onChanged: _isSaving ? null : (value) => _updatePreference('notifications', value),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.warning_2,
              title: 'Budget Alerts',
              subtitle: 'Alert when nearing budget limit',
              showSwitch: true,
              switchValue: _budgetAlerts,
              onChanged: _isSaving || !_notifications
                  ? null
                  : (value) => _updatePreference('budgetAlerts', value),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.clock,
              title: 'EMI Reminders',
              subtitle: 'Remind before EMI due date',
              showSwitch: true,
              switchValue: _emiReminders,
              onChanged: _isSaving || !_notifications
                  ? null
                  : (value) => _updatePreference('emiReminders', value),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.medal_star,
              title: 'Goal Milestones',
              subtitle: 'Celebrate goal achievements',
              showSwitch: true,
              switchValue: _goalMilestones,
              onChanged: _isSaving || !_notifications
                  ? null
                  : (value) => _updatePreference('goalMilestones', value),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.receipt_item,
              title: 'Transaction Alerts',
              subtitle: 'Notify on new transactions',
              showSwitch: true,
              switchValue: _transactionAlerts,
              onChanged: _isSaving || !_notifications
                  ? null
                  : (value) => _updatePreference('transactionAlerts', value),
            ),
            const SizedBox(height: SpendexTheme.spacing2xl),
            const _SectionTitle(title: 'Privacy & Security'),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.eye,
              title: 'Show Balance on App Icon',
              subtitle: 'Display balance as app badge',
              showSwitch: true,
              switchValue: _showBalanceBadge,
              onChanged: _isSaving ? null : (value) => _updatePreference('showBalanceBadge', value),
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            PreferenceTile(
              icon: Iconsax.shield_tick,
              title: 'Require Auth for Sensitive Screens',
              subtitle: 'Ask for PIN/biometric for reports',
              showSwitch: true,
              switchValue: _requireAuth,
              onChanged: _isSaving ? null : (value) => _updatePreference('requireAuth', value),
            ),
            const SizedBox(height: SpendexTheme.spacingXl),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: SpendexTheme.spacingXs),
      child: Text(
        title.toUpperCase(),
        style: SpendexTheme.labelMedium.copyWith(
          color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
