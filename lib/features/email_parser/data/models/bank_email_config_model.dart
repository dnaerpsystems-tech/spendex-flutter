import 'package:equatable/equatable.dart';

/// Bank email configuration for parsing transaction emails
class BankEmailConfigModel extends Equatable {
  final String bankName;
  final String bankCode;
  final List<String> emailDomains;
  final List<String> senderPatterns;
  final List<String> subjectPatterns;
  final EmailParsingRules parsingRules;

  const BankEmailConfigModel({
    required this.bankName,
    required this.bankCode,
    required this.emailDomains,
    required this.senderPatterns,
    required this.subjectPatterns,
    required this.parsingRules,
  });

  @override
  List<Object?> get props => [
        bankName,
        bankCode,
        emailDomains,
        senderPatterns,
        subjectPatterns,
        parsingRules,
      ];
}

/// Email parsing rules for extracting transaction details
class EmailParsingRules extends Equatable {
  final List<RegExp> amountPatterns;
  final List<RegExp> datePatterns;
  final List<RegExp> merchantPatterns;
  final List<RegExp> accountPatterns;
  final List<String> debitKeywords;
  final List<String> creditKeywords;
  final List<String> transactionKeywords;

  const EmailParsingRules({
    required this.amountPatterns,
    required this.datePatterns,
    required this.merchantPatterns,
    required this.accountPatterns,
    required this.debitKeywords,
    required this.creditKeywords,
    required this.transactionKeywords,
  });

  @override
  List<Object?> get props => [
        amountPatterns,
        datePatterns,
        merchantPatterns,
        accountPatterns,
        debitKeywords,
        creditKeywords,
        transactionKeywords,
      ];
}

/// Pre-configured bank email patterns for major Indian banks
class BankEmailConfigs {
  BankEmailConfigs._();

  /// State Bank of India email configuration
  static final sbi = BankEmailConfigModel(
    bankName: 'State Bank of India',
    bankCode: 'SBI',
    emailDomains: ['sbi.co.in', 'onlinesbi.com'],
    senderPatterns: [
      'alerts@sbi.co.in',
      'noreply@sbi.co.in',
      'statement@sbi.co.in',
    ],
    subjectPatterns: [
      'transaction alert',
      'account statement',
      'debit alert',
      'credit alert',
      'sbi alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
        RegExp(r'amount[:\s]+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
        RegExp(r'on\s+(\d{1,2}\s+[a-z]{3}\s+\d{4})', caseSensitive: false),
      ],
      merchantPatterns: [
        RegExp(r'at\s+([a-z0-9\s]+?)(?:\s+on|\s+dated)', caseSensitive: false),
        RegExp(r'merchant[:\s]+([a-z0-9\s]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'a/c\s+(?:no[.:]?)?\s*[xX*]*(\d{4,6})', caseSensitive: false),
        RegExp(r'account\s+(?:no[.:]?)?\s*[xX*]*(\d{4,6})',
            caseSensitive: false),
      ],
      debitKeywords: ['debited', 'debit', 'withdrawn', 'withdrawal', 'paid'],
      creditKeywords: ['credited', 'credit', 'received', 'deposit'],
      transactionKeywords: ['transaction', 'txn', 'payment', 'transfer'],
    ),
  );

  /// HDFC Bank email configuration
  static final hdfc = BankEmailConfigModel(
    bankName: 'HDFC Bank',
    bankCode: 'HDFC',
    emailDomains: ['hdfcbank.net', 'hdfcbank.com'],
    senderPatterns: [
      'alerts@hdfcbank.net',
      'noreply@hdfcbank.net',
      'statement@hdfcbank.net',
    ],
    subjectPatterns: [
      'transaction alert',
      'account statement',
      'info: update on your hdfc bank',
      'hdfc bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
        RegExp(r'for\s+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
        RegExp(r'on\s+(\d{1,2}-[a-z]{3}-\d{4})', caseSensitive: false),
      ],
      merchantPatterns: [
        RegExp(r'at\s+([a-z0-9\s]+?)(?:\s+on|\s+dated)', caseSensitive: false),
        RegExp(r'to\s+([a-z0-9\s]+?)(?:\s+on)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'xx(\d{4})', caseSensitive: false),
        RegExp(r'account\s+(?:no[.:]?)?\s*[xX*]*(\d{4,6})',
            caseSensitive: false),
      ],
      debitKeywords: ['debited', 'debit', 'spent', 'paid'],
      creditKeywords: ['credited', 'credit', 'received', 'deposit'],
      transactionKeywords: ['transaction', 'txn', 'payment', 'transfer'],
    ),
  );

  /// ICICI Bank email configuration
  static final icici = BankEmailConfigModel(
    bankName: 'ICICI Bank',
    bankCode: 'ICICI',
    emailDomains: ['icicibank.com', 'icicibank.net'],
    senderPatterns: [
      'alerts@icicibank.com',
      'noreply@icicibank.com',
      'statement@icicibank.com',
    ],
    subjectPatterns: [
      'transaction alert',
      'account statement',
      'icici bank alert',
      'account activity',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
        RegExp(r'amt[:\s]+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
        RegExp(r'on\s+(\d{1,2}\s+[a-z]{3})', caseSensitive: false),
      ],
      merchantPatterns: [
        RegExp(r'at\s+([a-z0-9\s]+?)(?:\s+on|\s+info)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'a/c\s+[xX*]*(\d{4})', caseSensitive: false),
      ],
      debitKeywords: ['debited', 'debit', 'withdrawn', 'spent'],
      creditKeywords: ['credited', 'credit', 'received'],
      transactionKeywords: ['transaction', 'txn', 'payment'],
    ),
  );

  /// Axis Bank email configuration
  static final axis = BankEmailConfigModel(
    bankName: 'Axis Bank',
    bankCode: 'AXIS',
    emailDomains: ['axisbank.com', 'axisbank.net'],
    senderPatterns: [
      'alerts@axisbank.com',
      'noreply@axisbank.com',
      'statement@axisbank.com',
    ],
    subjectPatterns: [
      'transaction alert',
      'account statement',
      'axis bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      ],
      merchantPatterns: [
        RegExp(r'at\s+([a-z0-9\s]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'xx(\d{4})', caseSensitive: false),
      ],
      debitKeywords: ['debited', 'debit'],
      creditKeywords: ['credited', 'credit'],
      transactionKeywords: ['transaction', 'payment'],
    ),
  );

  /// Kotak Mahindra Bank email configuration
  static final kotak = BankEmailConfigModel(
    bankName: 'Kotak Mahindra Bank',
    bankCode: 'KOTAK',
    emailDomains: ['kotak.com', 'kotakbank.com'],
    senderPatterns: [
      'alerts@kotak.com',
      'noreply@kotak.com',
      'statement@kotak.com',
    ],
    subjectPatterns: [
      'transaction alert',
      'account statement',
      'kotak bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      ],
      merchantPatterns: [
        RegExp(r'at\s+([a-z0-9\s]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'xx(\d{4})', caseSensitive: false),
      ],
      debitKeywords: ['debited', 'debit'],
      creditKeywords: ['credited', 'credit'],
      transactionKeywords: ['transaction', 'payment'],
    ),
  );

  /// Payment Gateway configs (Paytm, PhonePe, GPay, Razorpay)
  static final paytm = BankEmailConfigModel(
    bankName: 'Paytm',
    bankCode: 'PAYTM',
    emailDomains: ['paytm.com'],
    senderPatterns: [
      'alerts@paytm.com',
      'noreply@paytm.com',
    ],
    subjectPatterns: [
      'payment confirmation',
      'transaction successful',
      'paytm transaction',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      ],
      merchantPatterns: [
        RegExp(r'to\s+([a-z0-9\s]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'wallet\s+[xX*]*(\d{4})', caseSensitive: false),
      ],
      debitKeywords: ['paid', 'sent', 'transferred'],
      creditKeywords: ['received', 'added'],
      transactionKeywords: ['transaction', 'payment', 'transfer'],
    ),
  );

  static final phonepe = BankEmailConfigModel(
    bankName: 'PhonePe',
    bankCode: 'PHONEPE',
    emailDomains: ['phonepe.com'],
    senderPatterns: [
      'alerts@phonepe.com',
      'noreply@phonepe.com',
    ],
    subjectPatterns: [
      'payment confirmation',
      'transaction successful',
      'phonepe transaction',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      ],
      merchantPatterns: [
        RegExp(r'to\s+([a-z0-9\s]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'\d{10}'),
      ],
      debitKeywords: ['paid', 'sent'],
      creditKeywords: ['received'],
      transactionKeywords: ['payment', 'transaction'],
    ),
  );

  static final gpay = BankEmailConfigModel(
    bankName: 'Google Pay',
    bankCode: 'GPAY',
    emailDomains: ['google.com', 'googlepay.com'],
    senderPatterns: [
      'googlepay-noreply@google.com',
      'payments-noreply@google.com',
    ],
    subjectPatterns: [
      'you sent',
      'you received',
      'payment',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false),
      ],
      datePatterns: [
        RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4})'),
      ],
      merchantPatterns: [
        RegExp(r'to\s+([a-z0-9\s@]+)', caseSensitive: false),
      ],
      accountPatterns: [
        RegExp(r'[\w.]+@[\w.]+'),
      ],
      debitKeywords: ['sent', 'paid'],
      creditKeywords: ['received'],
      transactionKeywords: ['payment', 'transaction'],
    ),
  );

  /// Get all bank configurations
  static List<BankEmailConfigModel> get all => [
        sbi,
        hdfc,
        icici,
        axis,
        kotak,
        paytm,
        phonepe,
        gpay,
      ];

  /// Get bank config by code
  static BankEmailConfigModel? getByCode(String code) {
    try {
      return all.firstWhere(
        (bank) => bank.bankCode.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get bank config by email domain
  static BankEmailConfigModel? getByEmailDomain(String email) {
    final domain = email.split('@').last.toLowerCase();
    try {
      return all.firstWhere(
        (bank) => bank.emailDomains.any(
          (d) => domain.contains(d.toLowerCase()),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if email matches any bank sender pattern
  static BankEmailConfigModel? identifyBank(String fromEmail, String subject) {
    final lowerEmail = fromEmail.toLowerCase();
    final lowerSubject = subject.toLowerCase();

    for (final bank in all) {
      // Check sender patterns
      final matchesSender = bank.senderPatterns.any(
        (pattern) => lowerEmail.contains(pattern.toLowerCase()),
      );

      // Check subject patterns
      final matchesSubject = bank.subjectPatterns.any(
        (pattern) => lowerSubject.contains(pattern.toLowerCase()),
      );

      if (matchesSender || matchesSubject) {
        return bank;
      }
    }

    return null;
  }
}
