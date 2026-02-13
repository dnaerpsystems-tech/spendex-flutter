import 'dart:math' as math;

/// A comprehensive Indian currency formatting utility.
///
/// Supports the Indian numbering system (Lakh/Crore grouping),
/// compact notation, negative amounts, and paise (decimal places).
///
/// The Indian numbering system groups digits as follows:
/// - First group (from right): 3 digits (hundreds)
/// - Subsequent groups: 2 digits each (thousands, lakhs, crores, etc.)
///
/// Examples:
/// ```dart
/// CurrencyFormatter.format(150000);        // ₹1,50,000
/// CurrencyFormatter.formatCompact(2500000); // ₹25.00L
/// CurrencyFormatter.formatWithCode(1000);   // INR 1,000.00
/// ```
class CurrencyFormatter {
  CurrencyFormatter._();

  /// The Unicode INR symbol.
  static const String symbol = '\u20B9';

  /// The ISO 4217 currency code for Indian Rupee.
  static const String code = 'INR';

  /// Number of paise in one rupee.
  static const int _paisePerRupee = 100;

  /// Formats an amount in rupees using the Indian numbering system.
  ///
  /// [amount] is the value in rupees (can be negative).
  /// [decimalDigits] controls the number of decimal places (default: 2).
  /// [showSymbol] prepends the INR symbol when true (default: true).
  ///
  /// Returns a formatted string like "₹1,50,000.00" or "-₹42,500.00".
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.format(150000);                    // ₹1,50,000.00
  /// CurrencyFormatter.format(150000, decimalDigits: 0);  // ₹1,50,000
  /// CurrencyFormatter.format(-2500);                     // -₹2,500.00
  /// CurrencyFormatter.format(99.5, showSymbol: false);   // 99.50
  /// ```
  static String format(
    num amount, {
    int decimalDigits = 2,
    bool showSymbol = true,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final formatted = _formatIndian(absAmount, decimalDigits);
    final prefix = '${isNegative ? '-' : ''}${showSymbol ? symbol : ''}';

    return '$prefix$formatted';
  }

  /// Formats an amount with the ISO currency code instead of the symbol.
  ///
  /// [amount] is the value in rupees.
  /// [decimalDigits] controls the number of decimal places (default: 2).
  ///
  /// Returns a formatted string like "INR 1,50,000.00".
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatWithCode(250000);   // INR 2,50,000.00
  /// CurrencyFormatter.formatWithCode(-1500.75); // INR -1,500.75
  /// ```
  static String formatWithCode(
    num amount, {
    int decimalDigits = 2,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = _formatIndian(absAmount, decimalDigits);
    final sign = isNegative ? '-' : '';

    return '$code $sign$formatted';
  }

  /// Formats an amount in compact Indian notation.
  ///
  /// Uses standard Indian abbreviations:
  /// - **K** for Thousands (1,000+)
  /// - **L** for Lakhs (1,00,000+)
  /// - **Cr** for Crores (1,00,00,000+)
  ///
  /// [amount] is the value in rupees.
  /// [decimalDigits] controls decimal places in the compact value (default: 2).
  /// [showSymbol] prepends the INR symbol when true (default: true).
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatCompact(1500);       // ₹1.50K
  /// CurrencyFormatter.formatCompact(150000);      // ₹1.50L
  /// CurrencyFormatter.formatCompact(25000000);    // ₹2.50Cr
  /// CurrencyFormatter.formatCompact(500);         // ₹500.00
  /// CurrencyFormatter.formatCompact(-3500000);    // -₹35.00L
  /// ```
  static String formatCompact(
    num amount, {
    int decimalDigits = 2,
    bool showSymbol = true,
  }) {
    final isNegative = amount < 0;
    final absAmount = amount.abs().toDouble();

    String compactValue;
    String suffix;

    if (absAmount >= 10000000) {
      // Crores: 1,00,00,000+
      compactValue = _toFixed(absAmount / 10000000, decimalDigits);
      suffix = 'Cr';
    } else if (absAmount >= 100000) {
      // Lakhs: 1,00,000+
      compactValue = _toFixed(absAmount / 100000, decimalDigits);
      suffix = 'L';
    } else if (absAmount >= 1000) {
      // Thousands: 1,000+
      compactValue = _toFixed(absAmount / 1000, decimalDigits);
      suffix = 'K';
    } else {
      compactValue = _toFixed(absAmount, decimalDigits);
      suffix = '';
    }

    final prefix = '${isNegative ? '-' : ''}${showSymbol ? symbol : ''}';
    return '$prefix$compactValue$suffix';
  }

  /// Converts a paise value to a formatted rupee string.
  ///
  /// [paise] is the amount in paise (1 rupee = 100 paise).
  /// [decimalDigits] controls the number of decimal places (default: 2).
  /// [showSymbol] prepends the INR symbol when true (default: true).
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatPaise(15000);   // ₹150.00
  /// CurrencyFormatter.formatPaise(99);      // ₹0.99
  /// CurrencyFormatter.formatPaise(-5075);   // -₹50.75
  /// ```
  static String formatPaise(
    int paise, {
    int decimalDigits = 2,
    bool showSymbol = true,
  }) {
    final rupees = paise / _paisePerRupee;
    return format(rupees, decimalDigits: decimalDigits, showSymbol: showSymbol);
  }

  /// Converts a paise value to a compact formatted rupee string.
  ///
  /// [paise] is the amount in paise.
  /// [decimalDigits] controls decimal places in the compact value (default: 2).
  /// [showSymbol] prepends the INR symbol when true (default: true).
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.formatPaiseCompact(15000000); // ₹1.50L
  /// ```
  static String formatPaiseCompact(
    int paise, {
    int decimalDigits = 2,
    bool showSymbol = true,
  }) {
    final rupees = paise / _paisePerRupee;
    return formatCompact(
      rupees,
      decimalDigits: decimalDigits,
      showSymbol: showSymbol,
    );
  }

  /// Parses an Indian-formatted currency string back to a numeric value.
  ///
  /// Strips the currency symbol, code, commas, and whitespace, then parses
  /// the remaining numeric string.
  ///
  /// Returns `null` if the string cannot be parsed.
  ///
  /// Examples:
  /// ```dart
  /// CurrencyFormatter.parse('₹1,50,000.00');  // 150000.0
  /// CurrencyFormatter.parse('INR 2,500');      // 2500.0
  /// CurrencyFormatter.parse('-₹42.50');        // -42.5
  /// CurrencyFormatter.parse('invalid');        // null
  /// ```
  static double? parse(String value) {
    if (value.isEmpty) {
      return null;
    }

    final cleaned = value
        .replaceAll(symbol, '')
        .replaceAll(code, '')
        .replaceAll(',', '')
        .replaceAll('Cr', '')
        .replaceAll('L', '')
        .replaceAll('K', '')
        .trim();

    return double.tryParse(cleaned);
  }

  /// Formats a number using the Indian grouping system.
  ///
  /// Indian grouping: the first group is 3 digits, every subsequent group
  /// is 2 digits. For example, 10000000 becomes "1,00,00,000".
  static String _formatIndian(num amount, int decimalDigits) {
    // Split into integer and decimal parts
    final parts = _toFixed(amount, decimalDigits).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Apply Indian grouping to the integer part
    final grouped = _applyIndianGrouping(integerPart);

    return '$grouped$decimalPart';
  }

  /// Applies Indian comma grouping to an integer string.
  ///
  /// The rightmost 3 digits form the first group, and every subsequent
  /// group of 2 digits gets a comma separator.
  static String _applyIndianGrouping(String integerStr) {
    if (integerStr.length <= 3) {
      return integerStr;
    }

    // Last 3 digits
    final lastThree = integerStr.substring(integerStr.length - 3);
    final remaining = integerStr.substring(0, integerStr.length - 3);

    // Group the remaining digits in pairs from right to left
    final buffer = StringBuffer();
    for (var i = remaining.length; i > 0; i -= 2) {
      final start = math.max(0, i - 2);
      if (buffer.isNotEmpty) {
        final chunk = remaining.substring(start, i);
        buffer.write(',$chunk');
      } else {
        buffer.write(remaining.substring(start, i));
      }
    }

    // Reverse the comma-separated groups so they read left to right
    final groups = buffer.toString().split(',');
    final reversed = groups.reversed.join(',');

    return '$reversed,$lastThree';
  }

  /// Converts a number to a fixed-point string without floating-point artifacts.
  static String _toFixed(num value, int decimalDigits) {
    return value.toStringAsFixed(decimalDigits);
  }
}

/// Extension on [num] for convenient currency formatting.
///
/// Examples:
/// ```dart
/// 150000.toINR();         // ₹1,50,000.00
/// 2500000.toINRCompact(); // ₹25.00L
/// 150000.toINR(decimalDigits: 0); // ₹1,50,000
/// ```
extension CurrencyFormatExtension on num {
  /// Formats this number as Indian Rupees.
  ///
  /// See [CurrencyFormatter.format] for full documentation.
  String toINR({int decimalDigits = 2, bool showSymbol = true}) {
    return CurrencyFormatter.format(
      this,
      decimalDigits: decimalDigits,
      showSymbol: showSymbol,
    );
  }

  /// Formats this number as Indian Rupees in compact notation.
  ///
  /// See [CurrencyFormatter.formatCompact] for full documentation.
  String toINRCompact({int decimalDigits = 2, bool showSymbol = true}) {
    return CurrencyFormatter.formatCompact(
      this,
      decimalDigits: decimalDigits,
      showSymbol: showSymbol,
    );
  }

  /// Formats this number as Indian Rupees with the ISO currency code.
  ///
  /// See [CurrencyFormatter.formatWithCode] for full documentation.
  String toINRWithCode({int decimalDigits = 2}) {
    return CurrencyFormatter.formatWithCode(
      this,
      decimalDigits: decimalDigits,
    );
  }
}
