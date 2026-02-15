import 'package:intl/intl.dart';

/// Date formatting utility for Indian date formats and conventions
///
/// Provides comprehensive date formatting, parsing, and manipulation
/// utilities tailored for the Indian market.
class DateFormatter {
  DateFormatter._();

  // ============================================================================
  // Date Format Constants
  // ============================================================================

  /// DD-MM-YYYY format (e.g., 25-12-2023)
  static const String ddMmYyyy = 'dd-MM-yyyy';

  /// DD/MM/YYYY format (e.g., 25/12/2023)
  static const String ddSlashMmSlashYyyy = 'dd/MM/yyyy';

  /// DD MMM YYYY format (e.g., 25 Dec 2023)
  static const String ddMmmYyyy = 'dd MMM yyyy';

  /// DD MMMM YYYY format (e.g., 25 December 2023)
  static const String ddMmmmYyyy = 'dd MMMM yyyy';

  /// DD-MM-YY format (e.g., 25-12-23)
  static const String ddMmYy = 'dd-MM-yy';

  /// DD/MM/YY format (e.g., 25/12/23)
  static const String ddSlashMmSlashYy = 'dd/MM/yy';

  /// MMM DD, YYYY format (e.g., Dec 25, 2023)
  static const String mmmDdYyyy = 'MMM dd, yyyy';

  /// MMMM DD, YYYY format (e.g., December 25, 2023)
  static const String mmmmDdYyyy = 'MMMM dd, yyyy';

  /// DD-MM-YYYY HH:MM format (e.g., 25-12-2023 14:30)
  static const String ddMmYyyyHhMm = 'dd-MM-yyyy HH:mm';

  /// DD/MM/YYYY HH:MM format (e.g., 25/12/2023 14:30)
  static const String ddSlashMmSlashYyyyHhMm = 'dd/MM/yyyy HH:mm';

  /// DD MMM YYYY, HH:MM format (e.g., 25 Dec 2023, 14:30)
  static const String ddMmmYyyyHhMm = 'dd MMM yyyy, HH:mm';

  /// DD MMM YYYY, hh:mm a format (e.g., 25 Dec 2023, 02:30 PM)
  static const String ddMmmYyyyHhMmA = 'dd MMM yyyy, hh:mm a';

  /// Time format HH:MM (e.g., 14:30)
  static const String hhMm = 'HH:mm';

  /// Time format hh:mm a (e.g., 02:30 PM)
  static const String hhMmA = 'hh:mm a';

  /// Month Year format (e.g., Dec 2023)
  static const String mmmYyyy = 'MMM yyyy';

  /// Month Year format (e.g., December 2023)
  static const String mmmmYyyy = 'MMMM yyyy';

  /// ISO 8601 format (e.g., 2023-12-25)
  static const String iso8601 = 'yyyy-MM-dd';

  /// ISO 8601 with time (e.g., 2023-12-25T14:30:00)
  static const String iso8601WithTime = "yyyy-MM-dd'T'HH:mm:ss";

  // ============================================================================
  // Primary Formatting Methods
  // ============================================================================

  /// Format date to DD-MM-YYYY format (Indian standard)
  ///
  /// Example: `25-12-2023`
  static String format(DateTime date, [String? pattern]) {
    return DateFormat(pattern ?? ddMmYyyy).format(date);
  }

  /// Format date to DD/MM/YYYY format (Alternative Indian format)
  ///
  /// Example: `25/12/2023`
  static String formatSlash(DateTime date) {
    return DateFormat(ddSlashMmSlashYyyy).format(date);
  }

  /// Format date to DD MMM YYYY format (Display format)
  ///
  /// Example: `25 Dec 2023`
  static String formatDisplay(DateTime date) {
    return DateFormat(ddMmmYyyy).format(date);
  }

  /// Format date to DD MMMM YYYY format (Full display format)
  ///
  /// Example: `25 December 2023`
  static String formatFull(DateTime date) {
    return DateFormat(ddMmmmYyyy).format(date);
  }

  /// Format date to short format DD-MM-YY
  ///
  /// Example: `25-12-23`
  static String formatShort(DateTime date) {
    return DateFormat(ddMmYy).format(date);
  }

  /// Format date with time to DD-MM-YYYY HH:MM format
  ///
  /// Example: `25-12-2023 14:30`
  static String formatWithTime(DateTime date) {
    return DateFormat(ddMmYyyyHhMm).format(date);
  }

  /// Format date with time to DD/MM/YYYY HH:MM format
  ///
  /// Example: `25/12/2023 14:30`
  static String formatWithTimeSlash(DateTime date) {
    return DateFormat(ddSlashMmSlashYyyyHhMm).format(date);
  }

  /// Format date with time to DD MMM YYYY, hh:mm a format
  ///
  /// Example: `25 Dec 2023, 02:30 PM`
  static String formatDisplayWithTime(DateTime date) {
    return DateFormat(ddMmmYyyyHhMmA).format(date);
  }

  /// Format time only to HH:MM format
  ///
  /// Example: `14:30`
  static String formatTime(DateTime date) {
    return DateFormat(hhMm).format(date);
  }

  /// Format time only to hh:mm a format
  ///
  /// Example: `02:30 PM`
  static String formatTime12Hour(DateTime date) {
    return DateFormat(hhMmA).format(date);
  }

  /// Format month and year to MMM YYYY format
  ///
  /// Example: `Dec 2023`
  static String formatMonthYear(DateTime date) {
    return DateFormat(mmmYyyy).format(date);
  }

  /// Format month and year to MMMM YYYY format
  ///
  /// Example: `December 2023`
  static String formatMonthYearFull(DateTime date) {
    return DateFormat(mmmmYyyy).format(date);
  }

  /// Format date to ISO 8601 format
  ///
  /// Example: `2023-12-25`
  static String formatIso(DateTime date) {
    return DateFormat(iso8601).format(date);
  }

  /// Format date to ISO 8601 with time
  ///
  /// Example: `2023-12-25T14:30:00`
  static String formatIsoWithTime(DateTime date) {
    return DateFormat(iso8601WithTime).format(date);
  }

  // ============================================================================
  // Parsing Methods
  // ============================================================================

  /// Parse DD-MM-YYYY format to DateTime
  ///
  /// Example: `25-12-2023` → DateTime
  static DateTime? parse(String dateString, [String? pattern]) {
    try {
      return DateFormat(pattern ?? ddMmYyyy).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse DD/MM/YYYY format to DateTime
  ///
  /// Example: `25/12/2023` → DateTime
  static DateTime? parseSlash(String dateString) {
    try {
      return DateFormat(ddSlashMmSlashYyyy).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse ISO 8601 format to DateTime
  ///
  /// Example: `2023-12-25` → DateTime
  static DateTime? parseIso(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Try parsing date from multiple formats
  ///
  /// Attempts to parse date from common Indian formats
  static DateTime? parseAny(String dateString) {
    // Try various formats
    final formats = [
      ddMmYyyy, // 25-12-2023
      ddSlashMmSlashYyyy, // 25/12/2023
      ddMmmYyyy, // 25 Dec 2023
      ddMmmmYyyy, // 25 December 2023
      iso8601, // 2023-12-25
      mmmDdYyyy, // Dec 25, 2023
      mmmmDdYyyy, // December 25, 2023
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {
        continue;
      }
    }

    // Try default DateTime.parse
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // ============================================================================
  // Relative Date Formatting
  // ============================================================================

  /// Format date relative to now
  ///
  /// Examples:
  /// - Today → "Today"
  /// - Yesterday → "Yesterday"
  /// - 2 days ago → "2 days ago"
  /// - Last week → "Last week"
  /// - Older → "25 Dec 2023"
  static String formatRelative(DateTime date, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference <= 7) {
      return '$difference days ago';
    } else if (difference < -1 && difference >= -7) {
      return 'In ${-difference} days';
    } else if (difference > 7 && difference <= 30) {
      final weeks = (difference / 7).floor();
      return weeks == 1 ? 'Last week' : '$weeks weeks ago';
    } else if (difference < -7 && difference >= -30) {
      final weeks = (-difference / 7).floor();
      return weeks == 1 ? 'Next week' : 'In $weeks weeks';
    } else if (difference > 30 && difference <= 365) {
      final months = (difference / 30).floor();
      return months == 1 ? 'Last month' : '$months months ago';
    } else if (difference < -30 && difference >= -365) {
      final months = (-difference / 30).floor();
      return months == 1 ? 'Next month' : 'In $months months';
    } else if (difference > 365) {
      final years = (difference / 365).floor();
      return years == 1 ? 'Last year' : '$years years ago';
    } else {
      final years = (-difference / 365).floor();
      return years == 1 ? 'Next year' : 'In $years years';
    }
  }

  /// Format date with relative prefix if recent
  ///
  /// Examples:
  /// - Today → "Today, 14:30"
  /// - Yesterday → "Yesterday, 14:30"
  /// - Older → "25 Dec 2023, 14:30"
  static String formatRelativeWithTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return 'Today, ${formatTime12Hour(date)}';
    } else if (difference == 1) {
      return 'Yesterday, ${formatTime12Hour(date)}';
    } else {
      return formatDisplayWithTime(date);
    }
  }

  // ============================================================================
  // Date Range Formatting
  // ============================================================================

  /// Format date range to readable string
  ///
  /// Examples:
  /// - Same day → "25 Dec 2023"
  /// - Same month → "25-27 Dec 2023"
  /// - Same year → "25 Dec - 5 Jan 2023"
  /// - Different years → "25 Dec 2023 - 5 Jan 2024"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      // Same day
      return formatDisplay(start);
    } else if (start.year == end.year && start.month == end.month) {
      // Same month
      return '${start.day}-${end.day} ${DateFormat('MMM yyyy').format(start)}';
    } else if (start.year == end.year) {
      // Same year
      return '${DateFormat('dd MMM').format(start)} - ${formatDisplay(end)}';
    } else {
      // Different years
      return '${formatDisplay(start)} - ${formatDisplay(end)}';
    }
  }

  /// Format date range for display in filters
  ///
  /// Examples:
  /// - "25 Dec - 31 Dec"
  /// - "25 Dec 2023 - 5 Jan 2024"
  static String formatDateRangeShort(DateTime start, DateTime end) {
    if (start.year == end.year) {
      return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM').format(end)}';
    } else {
      return '${DateFormat('dd MMM yy').format(start)} - ${DateFormat('dd MMM yy').format(end)}';
    }
  }

  // ============================================================================
  // Financial Year Formatting (April - March)
  // ============================================================================

  /// Get financial year for a given date (Indian FY: April - March)
  ///
  /// Examples:
  /// - 15 May 2023 → "FY 2023-24"
  /// - 15 Feb 2024 → "FY 2023-24"
  /// - 15 Apr 2024 → "FY 2024-25"
  static String getFinancialYear(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    return 'FY $year-${(year + 1).toString().substring(2)}';
  }

  /// Get financial year range for a given date
  ///
  /// Example: `FY 2023-24 (01 Apr 2023 - 31 Mar 2024)`
  static String getFinancialYearRange(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    final startDate = DateTime(year, 4);
    final endDate = DateTime(year + 1, 3, 31);

    return '${getFinancialYear(date)} (${formatDisplay(startDate)} - ${formatDisplay(endDate)})';
  }

  /// Get start date of financial year for a given date
  ///
  /// Example: 15 May 2023 → 01 Apr 2023
  static DateTime getFinancialYearStart(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    return DateTime(year, 4);
  }

  /// Get end date of financial year for a given date
  ///
  /// Example: 15 May 2023 → 31 Mar 2024
  static DateTime getFinancialYearEnd(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    return DateTime(year + 1, 3, 31, 23, 59, 59);
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Check if date is in current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if date is in current year
  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Check if date is in current financial year
  static bool isCurrentFinancialYear(DateTime date) {
    final now = DateTime.now();
    final fyStart = getFinancialYearStart(now);
    final fyEnd = getFinancialYearEnd(now);

    return date.isAfter(fyStart.subtract(const Duration(days: 1))) &&
        date.isBefore(fyEnd.add(const Duration(days: 1)));
  }

  /// Get number of days between two dates
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// Get first day of month for a given date
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }

  /// Get last day of month for a given date
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// Get first day of year for a given date
  static DateTime getFirstDayOfYear(DateTime date) {
    return DateTime(date.year);
  }

  /// Get last day of year for a given date
  static DateTime getLastDayOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }
}

/// Extension methods on DateTime for convenient formatting
extension DateTimeFormatterExtension on DateTime {
  /// Format to DD-MM-YYYY
  String toIndianFormat() => DateFormatter.format(this);

  /// Format to DD/MM/YYYY
  String toIndianFormatSlash() => DateFormatter.formatSlash(this);

  /// Format to DD MMM YYYY
  String toDisplayFormat() => DateFormatter.formatDisplay(this);

  /// Format to DD MMMM YYYY
  String toFullDisplayFormat() => DateFormatter.formatFull(this);

  /// Format to DD-MM-YY
  String toShortFormat() => DateFormatter.formatShort(this);

  /// Format with time to DD-MM-YYYY HH:MM
  String toIndianFormatWithTime() => DateFormatter.formatWithTime(this);

  /// Format with time to DD MMM YYYY, hh:mm a
  String toDisplayFormatWithTime() => DateFormatter.formatDisplayWithTime(this);

  /// Format relative to now
  String toRelativeFormat() => DateFormatter.formatRelative(this);

  /// Format relative with time
  String toRelativeFormatWithTime() => DateFormatter.formatRelativeWithTime(this);

  /// Get financial year
  String toFinancialYear() => DateFormatter.getFinancialYear(this);

  /// Check if today
  bool get isToday => DateFormatter.isToday(this);

  /// Check if yesterday
  bool get isYesterday => DateFormatter.isYesterday(this);

  /// Check if tomorrow
  bool get isTomorrow => DateFormatter.isTomorrow(this);

  /// Check if this week
  bool get isThisWeek => DateFormatter.isThisWeek(this);

  /// Check if this month
  bool get isThisMonth => DateFormatter.isThisMonth(this);

  /// Check if this year
  bool get isThisYear => DateFormatter.isThisYear(this);

  /// Check if current financial year
  bool get isCurrentFinancialYear => DateFormatter.isCurrentFinancialYear(this);
}
