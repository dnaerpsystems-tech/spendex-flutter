import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    // =========================================================================
    // format() Tests
    // =========================================================================
    group('format()', () {
      test('formats date with default DD-MM-YYYY pattern', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.format(date), equals('25-12-2023'));
      });

      test('formats date with custom pattern', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.format(date, DateFormatter.ddSlashMmSlashYyyy), equals('25/12/2023'));
      });

      test('formats date with ISO 8601 pattern', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.format(date, DateFormatter.iso8601), equals('2023-12-25'));
      });
    });

    // =========================================================================
    // formatSlash() Tests
    // =========================================================================
    group('formatSlash()', () {
      test('formats date with slash separator', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatSlash(date), equals('25/12/2023'));
      });

      test('formats single digit day/month with leading zeros', () {
        final date = DateTime(2023, 1, 5);
        expect(DateFormatter.formatSlash(date), equals('05/01/2023'));
      });
    });

    // =========================================================================
    // formatDisplay() Tests
    // =========================================================================
    group('formatDisplay()', () {
      test('formats date with abbreviated month', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatDisplay(date), equals('25 Dec 2023'));
      });

      test('formats January correctly', () {
        final date = DateTime(2023, 1, 15);
        expect(DateFormatter.formatDisplay(date), equals('15 Jan 2023'));
      });
    });

    // =========================================================================
    // formatFull() Tests
    // =========================================================================
    group('formatFull()', () {
      test('formats date with full month name', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatFull(date), equals('25 December 2023'));
      });

      test('formats February correctly', () {
        final date = DateTime(2023, 2, 14);
        expect(DateFormatter.formatFull(date), equals('14 February 2023'));
      });
    });

    // =========================================================================
    // formatShort() Tests
    // =========================================================================
    group('formatShort()', () {
      test('formats date with 2-digit year', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatShort(date), equals('25-12-23'));
      });
    });

    // =========================================================================
    // formatWithTime() Tests
    // =========================================================================
    group('formatWithTime()', () {
      test('formats date with 24-hour time', () {
        final date = DateTime(2023, 12, 25, 14, 30);
        expect(DateFormatter.formatWithTime(date), equals('25-12-2023 14:30'));
      });

      test('formats midnight correctly', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatWithTime(date), equals('25-12-2023 00:00'));
      });
    });

    // =========================================================================
    // formatTime() Tests
    // =========================================================================
    group('formatTime()', () {
      test('formats time in 24-hour format', () {
        final date = DateTime(2023, 12, 25, 14, 30);
        expect(DateFormatter.formatTime(date), equals('14:30'));
      });

      test('formats morning time correctly', () {
        final date = DateTime(2023, 12, 25, 9, 5);
        expect(DateFormatter.formatTime(date), equals('09:05'));
      });
    });

    // =========================================================================
    // formatTime12Hour() Tests
    // =========================================================================
    group('formatTime12Hour()', () {
      test('formats afternoon time with PM', () {
        final date = DateTime(2023, 12, 25, 14, 30);
        expect(DateFormatter.formatTime12Hour(date), equals('02:30 PM'));
      });

      test('formats morning time with AM', () {
        final date = DateTime(2023, 12, 25, 9, 15);
        expect(DateFormatter.formatTime12Hour(date), equals('09:15 AM'));
      });

      test('formats noon correctly', () {
        final date = DateTime(2023, 12, 25, 12);
        expect(DateFormatter.formatTime12Hour(date), equals('12:00 PM'));
      });

      test('formats midnight correctly', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatTime12Hour(date), equals('12:00 AM'));
      });
    });

    // =========================================================================
    // formatMonthYear() Tests
    // =========================================================================
    group('formatMonthYear()', () {
      test('formats month and year with abbreviated month', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatMonthYear(date), equals('Dec 2023'));
      });
    });

    // =========================================================================
    // formatMonthYearFull() Tests
    // =========================================================================
    group('formatMonthYearFull()', () {
      test('formats month and year with full month name', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatMonthYearFull(date), equals('December 2023'));
      });
    });

    // =========================================================================
    // formatIso() Tests
    // =========================================================================
    group('formatIso()', () {
      test('formats date in ISO 8601 format', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatIso(date), equals('2023-12-25'));
      });
    });

    // =========================================================================
    // parse() Tests
    // =========================================================================
    group('parse()', () {
      test('parses DD-MM-YYYY format', () {
        final result = DateFormatter.parse('25-12-2023');
        expect(result, isNotNull);
        expect(result?.month, equals(12));
        expect(result?.year, equals(2023));
      });

      test('returns null for invalid date string', () {
        expect(DateFormatter.parse('invalid'), isNull);
      });

      test('returns null for empty string', () {
        expect(DateFormatter.parse(''), isNull);
      });

      test('parses with custom pattern', () {
        final result = DateFormatter.parse('2023-12-25', DateFormatter.iso8601);
        expect(result, isNotNull);
      });
    });

    // =========================================================================
    // parseSlash() Tests
    // =========================================================================
    group('parseSlash()', () {
      test('parses DD/MM/YYYY format', () {
        final result = DateFormatter.parseSlash('25/12/2023');
        expect(result, isNotNull);
        expect(result?.month, equals(12));
        expect(result?.year, equals(2023));
      });

      test('returns null for invalid format', () {
        expect(DateFormatter.parseSlash('25-12-2023'), isNull);
      });
    });

    // =========================================================================
    // parseIso() Tests
    // =========================================================================
    group('parseIso()', () {
      test('parses ISO 8601 format', () {
        final result = DateFormatter.parseIso('2023-12-25');
        expect(result, isNotNull);
        expect(result?.month, equals(12));
        expect(result?.day, equals(25));
      });

      test('parses ISO 8601 with time', () {
        final result = DateFormatter.parseIso('2023-12-25T14:30:00');
        expect(result, isNotNull);
        expect(result?.minute, equals(30));
      });

      test('returns null for invalid ISO string', () {
        expect(DateFormatter.parseIso('invalid'), isNull);
      });
    });

    // =========================================================================
    // parseAny() Tests
    // =========================================================================
    group('parseAny()', () {
      test('parses DD-MM-YYYY format', () {
        final result = DateFormatter.parseAny('25-12-2023');
        expect(result, isNotNull);
      });

      test('parses DD/MM/YYYY format', () {
        final result = DateFormatter.parseAny('25/12/2023');
        expect(result, isNotNull);
      });

      test('parses ISO 8601 format', () {
        final result = DateFormatter.parseAny('2023-12-25');
        expect(result, isNotNull);
      });

      test('parses DD MMM YYYY format', () {
        final result = DateFormatter.parseAny('25 Dec 2023');
        expect(result, isNotNull);
      });

      test('returns null for completely invalid string', () {
        expect(DateFormatter.parseAny('not a date'), isNull);
      });
    });

    // =========================================================================
    // formatRelative() Tests
    // =========================================================================
    group('formatRelative()', () {
      test('returns Today for current date', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day, 12);
        expect(DateFormatter.formatRelative(today, relativeTo: now), equals('Today'));
      });

      test('returns Yesterday for previous day', () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1, 12);
        expect(DateFormatter.formatRelative(yesterday, relativeTo: now), equals('Yesterday'));
      });

      test('returns Tomorrow for next day', () {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 12);
        expect(DateFormatter.formatRelative(tomorrow, relativeTo: now), equals('Tomorrow'));
      });

      test('returns X days ago for dates within a week', () {
        final now = DateTime(2023, 12, 25);
        final fiveDaysAgo = DateTime(2023, 12, 20);
        expect(DateFormatter.formatRelative(fiveDaysAgo, relativeTo: now), equals('5 days ago'));
      });

      test('returns Last week for 7-14 days ago', () {
        final now = DateTime(2023, 12, 25);
        final lastWeek = DateTime(2023, 12, 18);
        expect(DateFormatter.formatRelative(lastWeek, relativeTo: now), equals('Last week'));
      });

      test('returns X weeks ago for older dates', () {
        final now = DateTime(2023, 12, 25);
        final threeWeeksAgo = DateTime(2023, 12, 4);
        expect(DateFormatter.formatRelative(threeWeeksAgo, relativeTo: now), equals('3 weeks ago'));
      });

      test('returns In X days for future dates within a week', () {
        final now = DateTime(2023, 12, 25);
        final inThreeDays = DateTime(2023, 12, 28);
        expect(DateFormatter.formatRelative(inThreeDays, relativeTo: now), equals('In 3 days'));
      });
    });

    // =========================================================================
    // getFinancialYear() Tests
    // =========================================================================
    group('getFinancialYear()', () {
      test('returns correct FY for date in April', () {
        final date = DateTime(2024, 4, 15);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2024-25'));
      });

      test('returns correct FY for date in March', () {
        final date = DateTime(2024, 3, 15);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2023-24'));
      });

      test('returns correct FY for date in January', () {
        final date = DateTime(2024, 1, 15);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2023-24'));
      });

      test('returns correct FY for date in December', () {
        final date = DateTime(2023, 12, 31);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2023-24'));
      });

      test('returns correct FY for first day of FY', () {
        final date = DateTime(2024, 4);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2024-25'));
      });

      test('returns correct FY for last day of FY', () {
        final date = DateTime(2024, 3, 31);
        expect(DateFormatter.getFinancialYear(date), equals('FY 2023-24'));
      });
    });

    // =========================================================================
    // getFinancialYearStart() Tests
    // =========================================================================
    group('getFinancialYearStart()', () {
      test('returns April 1 of current FY for May date', () {
        final date = DateTime(2024, 5, 15);
        final fyStart = DateFormatter.getFinancialYearStart(date);
        expect(fyStart.year, equals(2024));
        expect(fyStart.month, equals(4));
        expect(fyStart.day, equals(1));
      });

      test('returns April 1 of previous year for Feb date', () {
        final date = DateTime(2024, 2, 15);
        final fyStart = DateFormatter.getFinancialYearStart(date);
        expect(fyStart.year, equals(2023));
        expect(fyStart.month, equals(4));
        expect(fyStart.day, equals(1));
      });
    });

    // =========================================================================
    // getFinancialYearEnd() Tests
    // =========================================================================
    group('getFinancialYearEnd()', () {
      test('returns March 31 of next year for May date', () {
        final date = DateTime(2024, 5, 15);
        final fyEnd = DateFormatter.getFinancialYearEnd(date);
        expect(fyEnd.year, equals(2025));
        expect(fyEnd.month, equals(3));
        expect(fyEnd.day, equals(31));
      });

      test('returns March 31 of current year for Feb date', () {
        final date = DateTime(2024, 2, 15);
        final fyEnd = DateFormatter.getFinancialYearEnd(date);
        expect(fyEnd.year, equals(2024));
        expect(fyEnd.month, equals(3));
        expect(fyEnd.day, equals(31));
      });
    });

    // =========================================================================
    // Utility Methods Tests
    // =========================================================================
    group('Utility Methods', () {
      group('isToday()', () {
        test('returns true for today', () {
          final now = DateTime.now();
          expect(DateFormatter.isToday(now), isTrue);
        });

        test('returns false for yesterday', () {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          expect(DateFormatter.isToday(yesterday), isFalse);
        });
      });

      group('isYesterday()', () {
        test('returns true for yesterday', () {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          expect(DateFormatter.isYesterday(yesterday), isTrue);
        });

        test('returns false for today', () {
          expect(DateFormatter.isYesterday(DateTime.now()), isFalse);
        });
      });

      group('isTomorrow()', () {
        test('returns true for tomorrow', () {
          final tomorrow = DateTime.now().add(const Duration(days: 1));
          expect(DateFormatter.isTomorrow(tomorrow), isTrue);
        });

        test('returns false for today', () {
          expect(DateFormatter.isTomorrow(DateTime.now()), isFalse);
        });
      });

      group('isThisYear()', () {
        test('returns true for current year', () {
          expect(DateFormatter.isThisYear(DateTime.now()), isTrue);
        });

        test('returns false for last year', () {
          final lastYear = DateTime(DateTime.now().year - 1, 6, 15);
          expect(DateFormatter.isThisYear(lastYear), isFalse);
        });
      });

      group('daysBetween()', () {
        test('returns correct days between dates', () {
          final start = DateTime(2023, 12);
          final end = DateTime(2023, 12, 25);
          expect(DateFormatter.daysBetween(start, end), equals(24));
        });

        test('returns zero for same date', () {
          final date = DateTime(2023, 12, 25);
          expect(DateFormatter.daysBetween(date, date), equals(0));
        });

        test('returns negative for reversed dates', () {
          final start = DateTime(2023, 12, 25);
          final end = DateTime(2023, 12);
          expect(DateFormatter.daysBetween(start, end), equals(-24));
        });
      });

      group('getFirstDayOfMonth()', () {
        test('returns first day of month', () {
          final date = DateTime(2023, 12, 15);
          final firstDay = DateFormatter.getFirstDayOfMonth(date);
          expect(firstDay.day, equals(1));
          expect(firstDay.month, equals(12));
          expect(firstDay.year, equals(2023));
        });
      });

      group('getLastDayOfMonth()', () {
        test('returns last day of December', () {
          final date = DateTime(2023, 12, 15);
          final lastDay = DateFormatter.getLastDayOfMonth(date);
          expect(lastDay.day, equals(31));
          expect(lastDay.month, equals(12));
        });

        test('returns last day of February (non-leap year)', () {
          final date = DateTime(2023, 2, 15);
          final lastDay = DateFormatter.getLastDayOfMonth(date);
          expect(lastDay.day, equals(28));
        });

        test('returns last day of February (leap year)', () {
          final date = DateTime(2024, 2, 15);
          final lastDay = DateFormatter.getLastDayOfMonth(date);
          expect(lastDay.day, equals(29));
        });
      });
    });

    // =========================================================================
    // Date Range Formatting Tests
    // =========================================================================
    group('formatDateRange()', () {
      test('formats same day range', () {
        final date = DateTime(2023, 12, 25);
        expect(DateFormatter.formatDateRange(date, date), equals('25 Dec 2023'));
      });

      test('formats same month range', () {
        final start = DateTime(2023, 12, 25);
        final end = DateTime(2023, 12, 27);
        expect(DateFormatter.formatDateRange(start, end), equals('25-27 Dec 2023'));
      });

      test('formats same year range', () {
        final start = DateTime(2023, 12, 25);
        final end = DateTime(2024, 1, 5);
        expect(DateFormatter.formatDateRange(start, end), equals('25 Dec - 05 Jan 2024'));
      });

      test('formats different years range', () {
        final start = DateTime(2023, 12, 25);
        final end = DateTime(2024, 1, 5);
        // Since 2023 != 2024, should use full format
        final result = DateFormatter.formatDateRange(start, end);
        expect(result, contains('Dec'));
        expect(result, contains('Jan'));
      });
    });

    // =========================================================================
    // Constants Tests
    // =========================================================================
    group('Constants', () {
      test('ddMmYyyy constant is correct', () {
        expect(DateFormatter.ddMmYyyy, equals('dd-MM-yyyy'));
      });

      test('iso8601 constant is correct', () {
        expect(DateFormatter.iso8601, equals('yyyy-MM-dd'));
      });

      test('hhMm constant is correct', () {
        expect(DateFormatter.hhMm, equals('HH:mm'));
      });
    });
  });
}
