import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendex/l10n/app_localizations.dart';
import '../locale_provider.dart';

/// A tile widget for language selection in settings
class LanguageSelectorTile extends ConsumerWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.language,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(l10n.language),
      subtitle: Text(SupportedLocales.getDisplayName(currentLocale)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: const LanguageSelectionList(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}

/// List of language options for selection
class LanguageSelectionList extends ConsumerWidget {
  const LanguageSelectionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: SupportedLocales.all.map((locale) {
        final isSelected = currentLocale.languageCode == locale.languageCode;

        return ListTile(
          leading: Text(
            _getFlagEmoji(locale.languageCode),
            style: const TextStyle(fontSize: 24),
          ),
          title: Text(SupportedLocales.getNativeName(locale)),
          trailing: isSelected
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : null,
          selected: isSelected,
          onTap: () async {
            await ref.read(localeProvider.notifier).setLocale(locale);
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.languageChanged),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      }).toList(),
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return '🇮🇳';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}

/// A compact language toggle button
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({
    super.key,
    this.showLabel = true,
    this.iconSize = 20,
  });
  final bool showLabel;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getFlagEmoji(currentLocale.languageCode),
              style: TextStyle(fontSize: iconSize),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Text(
                SupportedLocales.getDisplayName(currentLocale),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.swap_horiz,
              size: iconSize,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return '🇮🇳';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}

/// A dropdown button for language selection
class LanguageDropdown extends ConsumerWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return DropdownButton<Locale>(
      value: currentLocale,
      underline: const SizedBox.shrink(),
      icon: Icon(
        Icons.arrow_drop_down,
        color: theme.colorScheme.onSurface,
      ),
      items: SupportedLocales.all.map((locale) {
        return DropdownMenuItem<Locale>(
          value: locale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getFlagEmoji(locale.languageCode),
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(SupportedLocales.getDisplayName(locale)),
            ],
          ),
        );
      }).toList(),
      onChanged: (locale) {
        if (locale != null) {
          ref.read(localeProvider.notifier).setLocale(locale);
        }
      },
    );
  }

  String _getFlagEmoji(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return '🇮🇳';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}

/// An animated language switch widget
class AnimatedLanguageSwitch extends ConsumerWidget {
  const AnimatedLanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isHindi = currentLocale.languageCode == 'hi';

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isHindi
                ? [Colors.orange.shade400, Colors.green.shade400]
                : [Colors.blue.shade400, Colors.red.shade400],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: (isHindi ? Colors.orange : Colors.blue).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                isHindi ? '🇮🇳' : '🇺🇸',
                key: ValueKey(currentLocale.languageCode),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                SupportedLocales.getDisplayName(currentLocale),
                key: ValueKey(currentLocale.languageCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
