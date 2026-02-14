import 'package:flutter/material.dart';
import 'package:spendex/l10n/app_localizations.dart';

/// Extension on BuildContext to provide easy access to localization
extension L10nExtension on BuildContext {
  /// Get AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Shorthand alias for l10n
  AppLocalizations get tr => AppLocalizations.of(this);
}

/// Extension on AppLocalizations for common formatting helpers
extension AppLocalizationsExtensions on AppLocalizations {
  /// Format currency amount with rupee symbol
  String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    return amountFormatted(formatted);
  }

  /// Format currency amount without decimals
  String formatCurrencyWhole(int amount) {
    return amountFormatted(amount.toString());
  }

  /// Get appropriate time-based greeting
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return goodMorning;
    } else if (hour < 17) {
      return goodAfternoon;
    } else {
      return goodEvening;
    }
  }

  /// Get greeting with name
  String getGreetingWithName(String name) {
    final greeting = getGreeting();
    return '$greeting, $name!';
  }
}
