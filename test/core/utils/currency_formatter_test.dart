import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    // =========================================================================
    // format() Tests
    // =========================================================================
    group('format()', () {
      test('formats zero amount correctly', () {
        expect(CurrencyFormatter.format(0), equals('₹0.00'));
      });

      test('formats small amount correctly', () {
        expect(CurrencyFormatter.format(500), equals('₹500.00'));
      });

      test('formats amount under 1000 correctly', () {
        expect(CurrencyFormatter.format(999), equals('₹999.00'));
      });

      test('formats thousands with Indian grouping (1,000)', () {
        expect(CurrencyFormatter.format(1000), equals('₹1,000.00'));
      });

      test('formats ten thousands with Indian grouping (10,000)', () {
        expect(CurrencyFormatter.format(10000), equals('₹10,000.00'));
      });

      test('formats lakh amount with Indian grouping (1,00,000)', () {
        expect(CurrencyFormatter.format(100000), equals('₹1,00,000.00'));
      });

      test('formats multiple lakhs with Indian grouping (15,00,000)', () {
        expect(CurrencyFormatter.format(1500000), equals('₹15,00,000.00'));
      });

      test('formats crore amount with Indian grouping (1,00,00,000)', () {
        expect(CurrencyFormatter.format(10000000), equals('₹1,00,00,000.00'));
      });

      test('formats multiple crores correctly (25,00,00,000)', () {
        expect(CurrencyFormatter.format(250000000), equals('₹25,00,00,000.00'));
      });

      test('formats negative amount correctly', () {
        expect(CurrencyFormatter.format(-42500), equals('-₹42,500.00'));
      });

      test('formats decimal amount correctly', () {
        expect(CurrencyFormatter.format(99.5), equals('₹99.50'));
      });

      test('formats with zero decimal digits', () {
        expect(CurrencyFormatter.format(150000, decimalDigits: 0), equals('₹1,50,000'));
      });

      test('formats without symbol when showSymbol is false', () {
        expect(CurrencyFormatter.format(99.5, showSymbol: false), equals('99.50'));
      });

      test('formats with one decimal digit', () {
        expect(CurrencyFormatter.format(1234.567, decimalDigits: 1), equals('₹1,234.6'));
      });

      test('handles very large amounts correctly', () {
        expect(CurrencyFormatter.format(9999999999), equals('₹9,99,99,99,999.00'));
      });
    });

    // =========================================================================
    // formatWithCode() Tests
    // =========================================================================
    group('formatWithCode()', () {
      test('formats with INR code', () {
        expect(CurrencyFormatter.formatWithCode(250000), equals('INR 2,50,000.00'));
      });

      test('formats negative amount with INR code', () {
        expect(CurrencyFormatter.formatWithCode(-1500.75), equals('INR -1,500.75'));
      });

      test('formats with custom decimal digits', () {
        expect(CurrencyFormatter.formatWithCode(1000, decimalDigits: 0), equals('INR 1,000'));
      });
    });

    // =========================================================================
    // formatCompact() Tests
    // =========================================================================
    group('formatCompact()', () {
      test('formats amounts under 1000 without suffix', () {
        expect(CurrencyFormatter.formatCompact(500), equals('₹500.00'));
      });

      test('formats thousands with K suffix', () {
        expect(CurrencyFormatter.formatCompact(1500), equals('₹1.50K'));
      });

      test('formats larger thousands with K suffix', () {
        expect(CurrencyFormatter.formatCompact(75000), equals('₹75.00K'));
      });

      test('formats lakhs with L suffix', () {
        expect(CurrencyFormatter.formatCompact(150000), equals('₹1.50L'));
      });

      test('formats multiple lakhs with L suffix', () {
        expect(CurrencyFormatter.formatCompact(3500000), equals('₹35.00L'));
      });

      test('formats crores with Cr suffix', () {
        expect(CurrencyFormatter.formatCompact(25000000), equals('₹2.50Cr'));
      });

      test('formats multiple crores with Cr suffix', () {
        expect(CurrencyFormatter.formatCompact(150000000), equals('₹15.00Cr'));
      });

      test('formats negative lakhs correctly', () {
        expect(CurrencyFormatter.formatCompact(-3500000), equals('-₹35.00L'));
      });

      test('formats without symbol when showSymbol is false', () {
        expect(CurrencyFormatter.formatCompact(150000, showSymbol: false), equals('1.50L'));
      });

      test('formats with custom decimal digits', () {
        expect(CurrencyFormatter.formatCompact(1500, decimalDigits: 1), equals('₹1.5K'));
      });

      test('formats with zero decimal digits', () {
        expect(CurrencyFormatter.formatCompact(25000000, decimalDigits: 0), equals('₹3Cr'));
      });
    });

    // =========================================================================
    // formatPaise() Tests
    // =========================================================================
    group('formatPaise()', () {
      test('formats paise to rupees correctly', () {
        expect(CurrencyFormatter.formatPaise(15000), equals('₹150.00'));
      });

      test('formats small paise amount correctly', () {
        expect(CurrencyFormatter.formatPaise(99), equals('₹0.99'));
      });

      test('formats negative paise correctly', () {
        expect(CurrencyFormatter.formatPaise(-5075), equals('-₹50.75'));
      });

      test('formats lakh paise correctly', () {
        expect(CurrencyFormatter.formatPaise(15000000), equals('₹1,50,000.00'));
      });
    });

    // =========================================================================
    // formatPaiseCompact() Tests
    // =========================================================================
    group('formatPaiseCompact()', () {
      test('formats large paise to compact rupees', () {
        expect(CurrencyFormatter.formatPaiseCompact(15000000), equals('₹1.50L'));
      });

      test('formats crore paise to compact rupees', () {
        expect(CurrencyFormatter.formatPaiseCompact(2500000000), equals('₹2.50Cr'));
      });
    });

    // =========================================================================
    // parse() Tests
    // =========================================================================
    group('parse()', () {
      test('parses formatted currency string', () {
        expect(CurrencyFormatter.parse('₹1,50,000.00'), equals(150000.0));
      });

      test('parses INR code format', () {
        expect(CurrencyFormatter.parse('INR 2,500'), equals(2500.0));
      });

      test('parses negative formatted string', () {
        expect(CurrencyFormatter.parse('-₹42.50'), equals(-42.5));
      });

      test('parses compact K format', () {
        expect(CurrencyFormatter.parse('₹1.50K'), equals(1.5));
      });

      test('parses compact L format', () {
        expect(CurrencyFormatter.parse('₹35.00L'), equals(35.0));
      });

      test('parses compact Cr format', () {
        expect(CurrencyFormatter.parse('₹2.50Cr'), equals(2.5));
      });

      test('returns null for empty string', () {
        expect(CurrencyFormatter.parse(''), isNull);
      });

      test('returns null for invalid string', () {
        expect(CurrencyFormatter.parse('invalid'), isNull);
      });

      test('parses plain number string', () {
        expect(CurrencyFormatter.parse('12345.67'), equals(12345.67));
      });
    });

    // =========================================================================
    // Constants Tests
    // =========================================================================
    group('Constants', () {
      test('symbol is correct Unicode INR symbol', () {
        expect(CurrencyFormatter.symbol, equals('₹'));
      });

      test('code is INR', () {
        expect(CurrencyFormatter.code, equals('INR'));
      });
    });
  });

  // ===========================================================================
  // CurrencyFormatExtension Tests
  // ===========================================================================
  group('CurrencyFormatExtension', () {
    test('toINR() formats number as INR', () {
      expect(150000.toINR(), equals('₹1,50,000.00'));
    });

    test('toINR() with custom decimal digits', () {
      expect(150000.toINR(decimalDigits: 0), equals('₹1,50,000'));
    });

    test('toINR() without symbol', () {
      expect(150000.toINR(showSymbol: false), equals('1,50,000.00'));
    });

    test('toINRCompact() formats number compactly', () {
      expect(2500000.toINRCompact(), equals('₹25.00L'));
    });

    test('toINRCompact() with custom decimal digits', () {
      expect(2500000.toINRCompact(decimalDigits: 1), equals('₹25.0L'));
    });

    test('toINRWithCode() formats with INR code', () {
      expect(250000.toINRWithCode(), equals('INR 2,50,000.00'));
    });

    test('works with int values', () {
      expect(1500.toINR(), equals('₹1,500.00'));
    });

    test('works with double values', () {
      expect(1500.75.toINR(), equals('₹1,500.75'));
    });
  });
}
