import 'package:equatable/equatable.dart';

class BankConfigModel extends Equatable {

  const BankConfigModel({
    required this.bankName,
    required this.smsPatterns,
    required this.keywords,
    required this.supportedTypes,
  });

  factory BankConfigModel.fromJson(Map<String, dynamic> json) {
    return BankConfigModel(
      bankName: json['bankName'] as String,
      smsPatterns: (json['smsPatterns'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keywords: (json['keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      supportedTypes: (json['supportedTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }
  final String bankName;
  final List<String> smsPatterns;
  final List<String> keywords;
  final List<String> supportedTypes;

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'smsPatterns': smsPatterns,
      'keywords': keywords,
      'supportedTypes': supportedTypes,
    };
  }

  BankConfigModel copyWith({
    String? bankName,
    List<String>? smsPatterns,
    List<String>? keywords,
    List<String>? supportedTypes,
  }) {
    return BankConfigModel(
      bankName: bankName ?? this.bankName,
      smsPatterns: smsPatterns ?? this.smsPatterns,
      keywords: keywords ?? this.keywords,
      supportedTypes: supportedTypes ?? this.supportedTypes,
    );
  }

  @override
  List<Object?> get props => [
        bankName,
        smsPatterns,
        keywords,
        supportedTypes,
      ];

  static List<BankConfigModel> getIndianBanks() {
    return [
      const BankConfigModel(
        bankName: 'State Bank of India',
        smsPatterns: [
          r'SBI.*debited.*INR\s*([\d,]+\.?\d*)',
          r'SBI.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*credited.*Rs\.?\s*([\d,]+\.?\d*)',
        ],
        keywords: ['SBI', 'SBIINB', 'SBIATM', 'debited', 'credited'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm'],
      ),
      const BankConfigModel(
        bankName: 'HDFC Bank',
        smsPatterns: [
          r'HDFC.*debited.*INR\s*([\d,]+\.?\d*)',
          r'HDFC.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited.*XX(\d{4})',
          r'Rs\.?\s*([\d,]+\.?\d*).*credited.*XX(\d{4})',
        ],
        keywords: ['HDFC', 'HDFCBK', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
      const BankConfigModel(
        bankName: 'ICICI Bank',
        smsPatterns: [
          r'ICICI.*debited.*INR\s*([\d,]+\.?\d*)',
          r'ICICI.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited',
          r'Rs\.?\s*([\d,]+\.?\d*).*credited',
        ],
        keywords: ['ICICI', 'iMobile', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'neft', 'imps'],
      ),
      const BankConfigModel(
        bankName: 'Axis Bank',
        smsPatterns: [
          r'Axis.*debited.*INR\s*([\d,]+\.?\d*)',
          r'Axis.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited.*XX(\d{4})',
        ],
        keywords: ['AXIS', 'AXISBK', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
      const BankConfigModel(
        bankName: 'Kotak Mahindra Bank',
        smsPatterns: [
          r'Kotak.*debited.*INR\s*([\d,]+\.?\d*)',
          r'Kotak.*credited.*INR\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited',
          r'Rs\.?\s*([\d,]+\.?\d*).*credited',
        ],
        keywords: ['Kotak', 'KOTAKBK', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
      const BankConfigModel(
        bankName: 'Bank of Baroda',
        smsPatterns: [
          r'BOB.*debited.*INR\s*([\d,]+\.?\d*)',
          r'BOB.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
        ],
        keywords: ['BOB', 'Baroda', 'debited', 'credited'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm'],
      ),
      const BankConfigModel(
        bankName: 'Punjab National Bank',
        smsPatterns: [
          r'PNB.*debited.*INR\s*([\d,]+\.?\d*)',
          r'PNB.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*XX(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
        ],
        keywords: ['PNB', 'PNBSMS', 'debited', 'credited'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm'],
      ),
      const BankConfigModel(
        bankName: 'Canara Bank',
        smsPatterns: [
          r'Canara.*debited.*INR\s*([\d,]+\.?\d*)',
          r'Canara.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
        ],
        keywords: ['Canara', 'CNRB', 'debited', 'credited'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm'],
      ),
      const BankConfigModel(
        bankName: 'Union Bank of India',
        smsPatterns: [
          r'Union.*debited.*INR\s*([\d,]+\.?\d*)',
          r'Union.*credited.*INR\s*([\d,]+\.?\d*)',
          r'A/c.*(\d{4}).*debited.*Rs\.?\s*([\d,]+\.?\d*)',
        ],
        keywords: ['Union', 'UBOI', 'debited', 'credited'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm'],
      ),
      const BankConfigModel(
        bankName: 'Yes Bank',
        smsPatterns: [
          r'YES.*debited.*INR\s*([\d,]+\.?\d*)',
          r'YES.*credited.*INR\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited',
        ],
        keywords: ['YES', 'YESBNK', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
      const BankConfigModel(
        bankName: 'IndusInd Bank',
        smsPatterns: [
          r'IndusInd.*debited.*INR\s*([\d,]+\.?\d*)',
          r'IndusInd.*credited.*INR\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited',
        ],
        keywords: ['IndusInd', 'INDBNK', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
      const BankConfigModel(
        bankName: 'IDFC First Bank',
        smsPatterns: [
          r'IDFC.*debited.*INR\s*([\d,]+\.?\d*)',
          r'IDFC.*credited.*INR\s*([\d,]+\.?\d*)',
          r'Rs\.?\s*([\d,]+\.?\d*).*debited',
        ],
        keywords: ['IDFC', 'IDFCFB', 'debited', 'credited', 'UPI'],
        supportedTypes: ['debit', 'credit', 'upi', 'atm', 'pos'],
      ),
    ];
  }
}
