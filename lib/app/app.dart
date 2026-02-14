import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendex/l10n/app_localizations.dart';
import '../core/localization/locale_provider.dart';
import '../features/settings/presentation/providers/theme_provider.dart';
import '../shared/widgets/auto_lock_wrapper.dart';
import 'routes.dart';
import 'theme.dart';

class SpendexApp extends ConsumerWidget {
  const SpendexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Spendex',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: SpendexTheme.lightTheme,
      darkTheme: SpendexTheme.darkTheme,
      routerConfig: router,
      // Localization configuration
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: SupportedLocales.all,
      // Locale resolution callback
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        // Check if device locale is supported
        for (final supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == deviceLocale?.languageCode) {
            return supportedLocale;
          }
        }
        // Default to English
        return SupportedLocales.english;
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.noScaling,
          ),
          child: AutoLockWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
