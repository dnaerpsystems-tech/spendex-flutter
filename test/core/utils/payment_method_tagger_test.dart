import 'package:flutter_test/flutter_test.dart';
import 'package:spendex/core/utils/payment_method_tagger.dart';

void main() {
  group('PaymentMethodTagger', () {
    // =========================================================================
    // detectPaymentMethod() Tests - Keyword Detection
    // =========================================================================
    group('detectPaymentMethod() - Keyword Detection', () {
      test('detects UPI from description containing upi', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 500000, // 5K paise
          description: 'Payment via UPI to merchant',
        );
        expect(result, equals('upi'));
      });

      test('detects UPI from description containing gpay', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 500000,
          description: 'GPay transfer to friend',
        );
        expect(result, equals('upi'));
      });

      test('detects UPI from description containing paytm', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 500000,
          description: 'Paytm payment for groceries',
        );
        expect(result, equals('upi'));
      });

      test('detects UPI from description containing @', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 500000,
          description: 'Payment to merchant@ybl',
        );
        expect(result, equals('upi'));
      });

      test('detects NEFT from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 10000000,
          description: 'NEFT Transfer to Account',
        );
        expect(result, equals('neft'));
      });

      test('detects RTGS from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 50000000,
          description: 'RTGS payment for property',
        );
        expect(result, equals('rtgs'));
      });

      test('detects IMPS from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 10000000,
          description: 'IMPS instant transfer',
        );
        expect(result, equals('imps'));
      });

      test('detects card payment from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 5000000,
          description: 'POS debit card purchase at store',
        );
        expect(result, equals('card'));
      });

      test('detects net banking from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 10000000,
          description: 'Net Banking transfer',
        );
        expect(result, equals('netbanking'));
      });

      test('detects cheque from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 50000000,
          description: 'Cheque payment for rent',
        );
        expect(result, equals('cheque'));
      });

      test('detects cash from description', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 200000,
          description: 'ATM withdrawal',
        );
        expect(result, equals('cash'));
      });
    });

    // =========================================================================
    // detectPaymentMethod() Tests - Amount-based Detection
    // =========================================================================
    group('detectPaymentMethod() - Amount-based Detection', () {
      test('detects RTGS for high-value during RTGS hours', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 20000000, // 2 lakh in paise
          description: 'Transfer to account',
          transactionTime: DateTime(2023, 12, 25, 10, 0), // 10 AM
        );
        expect(result, equals('rtgs'));
      });

      test('detects UPI for small amount', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 500000, // 5K in paise
          description: 'Transfer',
          isInstant: true,
        );
        expect(result, equals('upi'));
      });

      test('detects IMPS for medium amount instant transfer', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 30000000, // 3 lakh in paise
          description: 'Transfer to friend',
          isInstant: true,
        );
        expect(result, equals('imps'));
      });

      test('detects NEFT during banking hours', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 15000000, // 1.5 lakh in paise
          description: 'Bank transfer',
          transactionTime: DateTime(2023, 12, 25, 14, 0), // 2 PM
          isInstant: false,
        );
        expect(result, equals('neft'));
      });

      test('detects IMPS for off-hours transaction', () {
        final result = PaymentMethodTagger.detectPaymentMethod(
          amount: 1000000, // 10K in paise
          description: 'Late night transfer',
          transactionTime: DateTime(2023, 12, 25, 22, 0), // 10 PM
        );
        expect(result, equals('imps'));
      });
    });

    // =========================================================================
    // Validation Methods Tests
    // =========================================================================
    group('Validation Methods', () {
      group('isValidUpiAmount()', () {
        test('returns true for amount under 1 lakh', () {
          expect(PaymentMethodTagger.isValidUpiAmount(5000000), isTrue);
        });

        test('returns true for amount at 1 lakh limit', () {
          expect(PaymentMethodTagger.isValidUpiAmount(10000000), isTrue);
        });

        test('returns false for amount over 1 lakh', () {
          expect(PaymentMethodTagger.isValidUpiAmount(15000000), isFalse);
        });

        test('returns false for zero amount', () {
          expect(PaymentMethodTagger.isValidUpiAmount(0), isFalse);
        });

        test('returns false for negative amount', () {
          expect(PaymentMethodTagger.isValidUpiAmount(-1000), isFalse);
        });
      });

      group('isValidImpsAmount()', () {
        test('returns true for amount under 5 lakh', () {
          expect(PaymentMethodTagger.isValidImpsAmount(30000000), isTrue);
        });

        test('returns true for amount at 5 lakh limit', () {
          expect(PaymentMethodTagger.isValidImpsAmount(50000000), isTrue);
        });

        test('returns false for amount over 5 lakh', () {
          expect(PaymentMethodTagger.isValidImpsAmount(60000000), isFalse);
        });
      });

      group('requiresRtgs()', () {
        test('returns true for amount at 2 lakh', () {
          expect(PaymentMethodTagger.requiresRtgs(20000000), isTrue);
        });

        test('returns true for amount over 2 lakh', () {
          expect(PaymentMethodTagger.requiresRtgs(50000000), isTrue);
        });

        test('returns false for amount under 2 lakh', () {
          expect(PaymentMethodTagger.requiresRtgs(15000000), isFalse);
        });
      });

      group('isValidNeftTime()', () {
        test('returns true during banking hours', () {
          final time = DateTime(2023, 12, 25, 10, 0); // 10 AM
          expect(PaymentMethodTagger.isValidNeftTime(time), isTrue);
        });

        test('returns false before banking hours', () {
          final time = DateTime(2023, 12, 25, 6, 0); // 6 AM
          expect(PaymentMethodTagger.isValidNeftTime(time), isFalse);
        });

        test('returns false after banking hours', () {
          final time = DateTime(2023, 12, 25, 20, 0); // 8 PM
          expect(PaymentMethodTagger.isValidNeftTime(time), isFalse);
        });
      });

      group('isValidRtgsTime()', () {
        test('returns true during RTGS hours', () {
          final time = DateTime(2023, 12, 25, 10, 0); // 10 AM
          expect(PaymentMethodTagger.isValidRtgsTime(time), isTrue);
        });

        test('returns false before RTGS hours', () {
          final time = DateTime(2023, 12, 25, 8, 0); // 8 AM
          expect(PaymentMethodTagger.isValidRtgsTime(time), isFalse);
        });

        test('returns false after RTGS hours', () {
          final time = DateTime(2023, 12, 25, 17, 0); // 5 PM
          expect(PaymentMethodTagger.isValidRtgsTime(time), isFalse);
        });
      });
    });

    // =========================================================================
    // Helper Methods Tests
    // =========================================================================
    group('Helper Methods', () {
      group('getDisplayName()', () {
        test('returns UPI for upi', () {
          expect(PaymentMethodTagger.getDisplayName('upi'), equals('UPI'));
        });

        test('returns NEFT for neft', () {
          expect(PaymentMethodTagger.getDisplayName('neft'), equals('NEFT'));
        });

        test('returns RTGS for rtgs', () {
          expect(PaymentMethodTagger.getDisplayName('rtgs'), equals('RTGS'));
        });

        test('returns IMPS for imps', () {
          expect(PaymentMethodTagger.getDisplayName('imps'), equals('IMPS'));
        });

        test('returns Card for card', () {
          expect(PaymentMethodTagger.getDisplayName('card'), equals('Card'));
        });

        test('returns Net Banking for netbanking', () {
          expect(PaymentMethodTagger.getDisplayName('netbanking'), equals('Net Banking'));
        });

        test('returns original for unknown method', () {
          expect(PaymentMethodTagger.getDisplayName('unknown'), equals('unknown'));
        });
      });

      group('getDescription()', () {
        test('returns correct description for UPI', () {
          final desc = PaymentMethodTagger.getDescription('upi');
          expect(desc, contains('UPI'));
          expect(desc, contains('1L'));
        });

        test('returns correct description for RTGS', () {
          final desc = PaymentMethodTagger.getDescription('rtgs');
          expect(desc, contains('Real Time'));
          expect(desc, contains('2L'));
        });
      });

      group('isInstantMethod()', () {
        test('returns true for UPI', () {
          expect(PaymentMethodTagger.isInstantMethod('upi'), isTrue);
        });

        test('returns true for IMPS', () {
          expect(PaymentMethodTagger.isInstantMethod('imps'), isTrue);
        });

        test('returns false for NEFT', () {
          expect(PaymentMethodTagger.isInstantMethod('neft'), isFalse);
        });

        test('returns false for RTGS', () {
          expect(PaymentMethodTagger.isInstantMethod('rtgs'), isFalse);
        });
      });

      group('is24x7Available()', () {
        test('returns true for UPI', () {
          expect(PaymentMethodTagger.is24x7Available('upi'), isTrue);
        });

        test('returns true for IMPS', () {
          expect(PaymentMethodTagger.is24x7Available('imps'), isTrue);
        });

        test('returns true for card', () {
          expect(PaymentMethodTagger.is24x7Available('card'), isTrue);
        });

        test('returns false for NEFT', () {
          expect(PaymentMethodTagger.is24x7Available('neft'), isFalse);
        });

        test('returns false for RTGS', () {
          expect(PaymentMethodTagger.is24x7Available('rtgs'), isFalse);
        });
      });

      group('requiresBankingHours()', () {
        test('returns true for NEFT', () {
          expect(PaymentMethodTagger.requiresBankingHours('neft'), isTrue);
        });

        test('returns true for RTGS', () {
          expect(PaymentMethodTagger.requiresBankingHours('rtgs'), isTrue);
        });

        test('returns true for netbanking', () {
          expect(PaymentMethodTagger.requiresBankingHours('netbanking'), isTrue);
        });

        test('returns false for UPI', () {
          expect(PaymentMethodTagger.requiresBankingHours('upi'), isFalse);
        });
      });
    });

    // =========================================================================
    // getSuggestedMethods() Tests
    // =========================================================================
    group('getSuggestedMethods()', () {
      test('returns UPI for small amount', () {
        final methods = PaymentMethodTagger.getSuggestedMethods(amount: 500000);
        expect(methods, contains('upi'));
      });

      test('returns IMPS for medium amount', () {
        final methods = PaymentMethodTagger.getSuggestedMethods(amount: 30000000);
        expect(methods, contains('imps'));
      });

      test('excludes UPI for amount over 1 lakh', () {
        final methods = PaymentMethodTagger.getSuggestedMethods(amount: 15000000);
        expect(methods, isNot(contains('upi')));
      });

      test('includes NEFT during banking hours', () {
        final methods = PaymentMethodTagger.getSuggestedMethods(
          amount: 10000000,
          time: DateTime(2023, 12, 25, 10, 0),
        );
        expect(methods, contains('neft'));
      });

      test('includes cash and card always', () {
        final methods = PaymentMethodTagger.getSuggestedMethods(amount: 500000);
        expect(methods, contains('cash'));
        expect(methods, contains('card'));
      });
    });

    // =========================================================================
    // Constants Tests
    // =========================================================================
    group('Constants', () {
      test('RTGS minimum amount is 2 lakh paise', () {
        expect(PaymentMethodTagger.rtgsMinAmount, equals(20000000));
      });

      test('UPI max amount is 1 lakh paise', () {
        expect(PaymentMethodTagger.upiMaxAmount, equals(10000000));
      });

      test('IMPS max amount is 5 lakh paise', () {
        expect(PaymentMethodTagger.impsMaxAmount, equals(50000000));
      });

      test('NEFT start hour is 8', () {
        expect(PaymentMethodTagger.neftStartHour, equals(8));
      });

      test('NEFT end hour is 19', () {
        expect(PaymentMethodTagger.neftEndHour, equals(19));
      });

      test('RTGS start hour is 9', () {
        expect(PaymentMethodTagger.rtgsStartHour, equals(9));
      });

      test('RTGS end hour is 16', () {
        expect(PaymentMethodTagger.rtgsEndHour, equals(16));
      });
    });
  });
}
