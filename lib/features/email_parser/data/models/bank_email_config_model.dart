import 'package:equatable/equatable.dart';

/// Bank email configuration for parsing transaction emails
class BankEmailConfigModel extends Equatable {

  const BankEmailConfigModel({
    required this.bankName,
    required this.bankCode,
    required this.emailDomains,
    required this.senderPatterns,
    required this.subjectPatterns,
    required this.parsingRules,
  });
  final String bankName;
  final String bankCode;
  final List<String> emailDomains;
  final List<String> senderPatterns;
  final List<String> subjectPatterns;
  final EmailParsingRules parsingRules;

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

  const EmailParsingRules({
    required this.amountPatterns,
    required this.datePatterns,
    required this.merchantPatterns,
    required this.accountPatterns,
    required this.debitKeywords,
    required this.creditKeywords,
    required this.transactionKeywords,
  });
  final List<RegExp> amountPatterns;
  final List<RegExp> datePatterns;
  final List<RegExp> merchantPatterns;
  final List<RegExp> accountPatterns;
  final List<String> debitKeywords;
  final List<String> creditKeywords;
  final List<String> transactionKeywords;

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
    emailDomains: const ['sbi.co.in', 'onlinesbi.com'],
    senderPatterns: const [
      'alerts@sbi.co.in',
      'noreply@sbi.co.in',
      'statement@sbi.co.in',
    ],
    subjectPatterns: const [
      'transaction alert',
      'account statement',
      'debit alert',
      'credit alert',
      'sbi alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
        RegExp(r'amount[:\s]+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
            caseSensitive: false,),
      ],
      debitKeywords: const ['debited', 'debit', 'withdrawn', 'withdrawal', 'paid'],
      creditKeywords: const ['credited', 'credit', 'received', 'deposit'],
      transactionKeywords: const ['transaction', 'txn', 'payment', 'transfer'],
    ),
  );

  /// HDFC Bank email configuration
  static final hdfc = BankEmailConfigModel(
    bankName: 'HDFC Bank',
    bankCode: 'HDFC',
    emailDomains: const ['hdfcbank.net', 'hdfcbank.com'],
    senderPatterns: const [
      'alerts@hdfcbank.net',
      'noreply@hdfcbank.net',
      'statement@hdfcbank.net',
    ],
    subjectPatterns: const [
      'transaction alert',
      'account statement',
      'info: update on your hdfc bank',
      'hdfc bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
        RegExp(r'for\s+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
            caseSensitive: false,),
      ],
      debitKeywords: const ['debited', 'debit', 'spent', 'paid'],
      creditKeywords: const ['credited', 'credit', 'received', 'deposit'],
      transactionKeywords: const ['transaction', 'txn', 'payment', 'transfer'],
    ),
  );

  /// ICICI Bank email configuration
  static final icici = BankEmailConfigModel(
    bankName: 'ICICI Bank',
    bankCode: 'ICICI',
    emailDomains: const ['icicibank.com', 'icicibank.net'],
    senderPatterns: const [
      'alerts@icicibank.com',
      'noreply@icicibank.com',
      'statement@icicibank.com',
    ],
    subjectPatterns: const [
      'transaction alert',
      'account statement',
      'icici bank alert',
      'account activity',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
        RegExp(r'amt[:\s]+(?:rs|inr|₹)?[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['debited', 'debit', 'withdrawn', 'spent'],
      creditKeywords: const ['credited', 'credit', 'received'],
      transactionKeywords: const ['transaction', 'txn', 'payment'],
    ),
  );

  /// Axis Bank email configuration
  static final axis = BankEmailConfigModel(
    bankName: 'Axis Bank',
    bankCode: 'AXIS',
    emailDomains: const ['axisbank.com', 'axisbank.net'],
    senderPatterns: const [
      'alerts@axisbank.com',
      'noreply@axisbank.com',
      'statement@axisbank.com',
    ],
    subjectPatterns: const [
      'transaction alert',
      'account statement',
      'axis bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['debited', 'debit'],
      creditKeywords: const ['credited', 'credit'],
      transactionKeywords: const ['transaction', 'payment'],
    ),
  );

  /// Kotak Mahindra Bank email configuration
  static final kotak = BankEmailConfigModel(
    bankName: 'Kotak Mahindra Bank',
    bankCode: 'KOTAK',
    emailDomains: const ['kotak.com', 'kotakbank.com'],
    senderPatterns: const [
      'alerts@kotak.com',
      'noreply@kotak.com',
      'statement@kotak.com',
    ],
    subjectPatterns: const [
      'transaction alert',
      'account statement',
      'kotak bank alert',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['debited', 'debit'],
      creditKeywords: const ['credited', 'credit'],
      transactionKeywords: const ['transaction', 'payment'],
    ),
  );

  /// Payment Gateway configs (Paytm, PhonePe, GPay, Razorpay)
  static final paytm = BankEmailConfigModel(
    bankName: 'Paytm',
    bankCode: 'PAYTM',
    emailDomains: const ['paytm.com'],
    senderPatterns: const [
      'alerts@paytm.com',
      'noreply@paytm.com',
    ],
    subjectPatterns: const [
      'payment confirmation',
      'transaction successful',
      'paytm transaction',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['paid', 'sent', 'transferred'],
      creditKeywords: const ['received', 'added'],
      transactionKeywords: const ['transaction', 'payment', 'transfer'],
    ),
  );

  static final phonepe = BankEmailConfigModel(
    bankName: 'PhonePe',
    bankCode: 'PHONEPE',
    emailDomains: const ['phonepe.com'],
    senderPatterns: const [
      'alerts@phonepe.com',
      'noreply@phonepe.com',
    ],
    subjectPatterns: const [
      'payment confirmation',
      'transaction successful',
      'phonepe transaction',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['paid', 'sent'],
      creditKeywords: const ['received'],
      transactionKeywords: const ['payment', 'transaction'],
    ),
  );

  static final gpay = BankEmailConfigModel(
    bankName: 'Google Pay',
    bankCode: 'GPAY',
    emailDomains: const ['google.com', 'googlepay.com'],
    senderPatterns: const [
      'googlepay-noreply@google.com',
      'payments-noreply@google.com',
    ],
    subjectPatterns: const [
      'you sent',
      'you received',
      'payment',
    ],
    parsingRules: EmailParsingRules(
      amountPatterns: [
        RegExp(r'(?:rs|inr|₹)[\s.]?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)',
            caseSensitive: false,),
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
      debitKeywords: const ['sent', 'paid'],
      creditKeywords: const ['received'],
      transactionKeywords: const ['payment', 'transaction'],
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
