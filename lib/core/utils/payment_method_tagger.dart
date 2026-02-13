/// Payment Method Auto-Tagging Utility
///
/// Automatically tags payment method (UPI, NEFT, RTGS, IMPS, etc.) based on:
/// - Transaction amount thresholds
/// - Transaction description keywords
/// - Time of transaction
/// - Transfer patterns
///
/// Based on Indian banking system rules:
/// - RTGS: For high-value transactions (₹2L+), banking hours only
/// - NEFT: For standard transfers (any amount), banking hours
/// - IMPS: For instant transfers (up to ₹5L), 24/7 available
/// - UPI: For small to medium transactions (up to ₹1L), instant, 24/7
class PaymentMethodTagger {
  PaymentMethodTagger._();

  // ============================================================================
  // Amount Thresholds (in paise)
  // ============================================================================

  /// Minimum amount for RTGS: ₹2,00,000
  static const int rtgsMinAmount = 20000000; // 2 lakh in paise

  /// Maximum amount for UPI: ₹1,00,000
  static const int upiMaxAmount = 10000000; // 1 lakh in paise

  /// Maximum amount for IMPS: ₹5,00,000
  static const int impsMaxAmount = 50000000; // 5 lakh in paise

  // ============================================================================
  // Banking Hours
  // ============================================================================

  /// NEFT banking hours start time
  static const int neftStartHour = 8;

  /// NEFT banking hours end time
  static const int neftEndHour = 19;

  /// RTGS banking hours start time
  static const int rtgsStartHour = 9;

  /// RTGS banking hours end time
  static const int rtgsEndHour = 16; // 4:30 PM for customer transactions

  // ============================================================================
  // Keywords for Detection
  // ============================================================================

  /// UPI keywords in transaction description
  static const List<String> upiKeywords = [
    'upi',
    'gpay',
    'google pay',
    'phonepe',
    'paytm',
    'bhim',
    'amazon pay',
    'whatsapp pay',
    '@',
    'vpa',
  ];

  /// NEFT keywords in transaction description
  static const List<String> neftKeywords = [
    'neft',
    'national electronic',
    'fund transfer',
  ];

  /// RTGS keywords in transaction description
  static const List<String> rtgsKeywords = [
    'rtgs',
    'real time gross',
    'rtg',
  ];

  /// IMPS keywords in transaction description
  static const List<String> impsKeywords = [
    'imps',
    'immediate payment',
    'instant transfer',
  ];

  /// Net Banking keywords
  static const List<String> netbankingKeywords = [
    'netbanking',
    'net banking',
    'internet banking',
    'online transfer',
  ];

  /// Card payment keywords
  static const List<String> cardKeywords = [
    'card',
    'debit card',
    'credit card',
    'pos',
    'point of sale',
    'swipe',
    'contactless',
    'tap',
  ];

  /// Cheque keywords
  static const List<String> chequeKeywords = [
    'cheque',
    'check',
    'chq',
  ];

  /// Cash keywords
  static const List<String> cashKeywords = [
    'cash',
    'atm withdrawal',
    'atm',
    'cash withdrawal',
  ];

  // ============================================================================
  // Auto-Tagging Method
  // ============================================================================

  /// Auto-tag payment method based on transaction details
  ///
  /// Parameters:
  /// - [amount]: Transaction amount in paise
  /// - [description]: Transaction description/remarks
  /// - [transactionTime]: Time of transaction
  /// - [isInstant]: Whether transfer was instant (optional hint)
  ///
  /// Returns: Detected payment method enum as string
  static String detectPaymentMethod({
    required int amount,
    required String description,
    DateTime? transactionTime,
    bool? isInstant,
  }) {
    final descriptionLower = description.toLowerCase();
    final time = transactionTime ?? DateTime.now();

    // 1. Check explicit keywords first (highest priority)
    if (_containsKeywords(descriptionLower, upiKeywords)) {
      return 'upi';
    }

    if (_containsKeywords(descriptionLower, rtgsKeywords)) {
      return 'rtgs';
    }

    if (_containsKeywords(descriptionLower, neftKeywords)) {
      return 'neft';
    }

    if (_containsKeywords(descriptionLower, impsKeywords)) {
      return 'imps';
    }

    if (_containsKeywords(descriptionLower, cardKeywords)) {
      return 'card';
    }

    if (_containsKeywords(descriptionLower, netbankingKeywords)) {
      return 'netbanking';
    }

    if (_containsKeywords(descriptionLower, chequeKeywords)) {
      return 'cheque';
    }

    if (_containsKeywords(descriptionLower, cashKeywords)) {
      return 'cash';
    }

    // 2. Detect based on amount thresholds and banking rules
    return _detectByAmountAndTime(amount, time, isInstant);
  }

  /// Detect payment method based on amount and time
  static String _detectByAmountAndTime(
    int amount,
    DateTime time,
    bool? isInstant,
  ) {
    final hour = time.hour;
    final isBankingHours = _isBankingHours(hour);
    final isRtgsHours = _isRtgsHours(hour);

    // RTGS: High amount (₹2L+) during RTGS hours
    if (amount >= rtgsMinAmount && isRtgsHours) {
      return 'rtgs';
    }

    // UPI: Small to medium amount (up to ₹1L), likely instant
    if (amount <= upiMaxAmount) {
      if (isInstant == true || !isBankingHours) {
        return 'upi';
      }
    }

    // IMPS: Up to ₹5L, instant transfer, 24/7
    if (amount <= impsMaxAmount && (isInstant == true || !isBankingHours)) {
      return 'imps';
    }

    // NEFT: Standard transfer during banking hours
    if (isBankingHours) {
      return 'neft';
    }

    // Default to IMPS for off-hours transactions
    if (!isBankingHours) {
      return 'imps';
    }

    // Default fallback
    return 'neft';
  }

  /// Check if keywords are present in description
  static bool _containsKeywords(String description, List<String> keywords) {
    return keywords.any((keyword) => description.contains(keyword));
  }

  /// Check if time is within NEFT banking hours (8 AM - 7 PM)
  static bool _isBankingHours(int hour) {
    return hour >= neftStartHour && hour < neftEndHour;
  }

  /// Check if time is within RTGS hours (9 AM - 4 PM)
  static bool _isRtgsHours(int hour) {
    return hour >= rtgsStartHour && hour < rtgsEndHour;
  }

  // ============================================================================
  // Validation Methods
  // ============================================================================

  /// Check if amount is valid for UPI (up to ₹1L)
  static bool isValidUpiAmount(int amount) {
    return amount > 0 && amount <= upiMaxAmount;
  }

  /// Check if amount is valid for IMPS (up to ₹5L)
  static bool isValidImpsAmount(int amount) {
    return amount > 0 && amount <= impsMaxAmount;
  }

  /// Check if amount requires RTGS (₹2L+)
  static bool requiresRtgs(int amount) {
    return amount >= rtgsMinAmount;
  }

  /// Check if time is valid for NEFT
  static bool isValidNeftTime(DateTime time) {
    return _isBankingHours(time.hour);
  }

  /// Check if time is valid for RTGS
  static bool isValidRtgsTime(DateTime time) {
    return _isRtgsHours(time.hour);
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Get suggested payment methods for given amount
  ///
  /// Returns list of suitable payment methods sorted by recommendation
  static List<String> getSuggestedMethods({
    required int amount,
    DateTime? time,
  }) {
    final methods = <String>[];
    final transactionTime = time ?? DateTime.now();

    // Always available methods
    methods.add('cash');
    methods.add('cheque');
    methods.add('card');

    // 24/7 instant methods
    methods.add('upi'); // Up to ₹1L
    methods.add('imps'); // Up to ₹5L

    // Banking hours methods
    if (_isBankingHours(transactionTime.hour)) {
      methods.add('neft'); // Any amount
      methods.add('netbanking');

      if (_isRtgsHours(transactionTime.hour)) {
        methods.add('rtgs'); // ₹2L+
      }
    }

    // Filter based on amount constraints
    final validMethods = methods.where((method) {
      switch (method) {
        case 'upi':
          return amount <= upiMaxAmount;
        case 'imps':
          return amount <= impsMaxAmount;
        case 'rtgs':
          return amount >= rtgsMinAmount;
        default:
          return true;
      }
    }).toList();

    return validMethods;
  }

  /// Get payment method display name
  static String getDisplayName(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'neft':
        return 'NEFT';
      case 'rtgs':
        return 'RTGS';
      case 'imps':
        return 'IMPS';
      case 'card':
        return 'Card';
      case 'netbanking':
        return 'Net Banking';
      case 'cash':
        return 'Cash';
      case 'cheque':
        return 'Cheque';
      default:
        return method;
    }
  }

  /// Get payment method description
  static String getDescription(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'Instant payment via UPI apps (up to ₹1L)';
      case 'neft':
        return 'National Electronic Funds Transfer (banking hours)';
      case 'rtgs':
        return 'Real Time Gross Settlement (₹2L+, banking hours)';
      case 'imps':
        return 'Immediate Payment Service (up to ₹5L, 24/7)';
      case 'card':
        return 'Credit/Debit Card payment';
      case 'netbanking':
        return 'Internet Banking transfer';
      case 'cash':
        return 'Cash payment or withdrawal';
      case 'cheque':
        return 'Cheque payment';
      default:
        return '';
    }
  }

  /// Get payment method icon identifier
  static String getIconName(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'upi';
      case 'neft':
        return 'bank_transfer';
      case 'rtgs':
        return 'bank_transfer';
      case 'imps':
        return 'instant_transfer';
      case 'card':
        return 'credit_card';
      case 'netbanking':
        return 'computer';
      case 'cash':
        return 'cash';
      case 'cheque':
        return 'receipt';
      default:
        return 'payment';
    }
  }

  /// Check if payment method is instant
  static bool isInstantMethod(String method) {
    return ['upi', 'imps'].contains(method.toLowerCase());
  }

  /// Check if payment method is available 24/7
  static bool is24x7Available(String method) {
    return ['upi', 'imps', 'card', 'cash'].contains(method.toLowerCase());
  }

  /// Check if payment method requires banking hours
  static bool requiresBankingHours(String method) {
    return ['neft', 'rtgs', 'netbanking'].contains(method.toLowerCase());
  }

  /// Get transaction charges information
  static String getChargesInfo(String method, int amount) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'Free (for personal use)';
      case 'neft':
        if (amount <= 1000000) {
          // Up to ₹10,000
          return 'Free or minimal charges';
        } else if (amount <= 10000000) {
          // Up to ₹1L
          return '₹2-5 approximately';
        } else if (amount <= 20000000) {
          // Up to ₹2L
          return '₹5-15 approximately';
        } else {
          return '₹15-25 approximately';
        }
      case 'rtgs':
        if (amount <= 20000000) {
          // Up to ₹2L
          return '₹25-30 approximately';
        } else if (amount <= 500000000) {
          // Up to ₹5L
          return '₹25-50 approximately';
        } else {
          return '₹50+ approximately';
        }
      case 'imps':
        if (amount <= 100000) {
          // Up to ₹1,000
          return '₹2-5 approximately';
        } else if (amount <= 1000000) {
          // Up to ₹10,000
          return '₹5-15 approximately';
        } else {
          return '₹15-25 approximately';
        }
      case 'card':
        return 'No charges for debit card, 1-3% for credit card';
      case 'netbanking':
        return 'Varies by bank';
      case 'cash':
        return 'Free';
      case 'cheque':
        return 'Free or ₹2-5 per leaf';
      default:
        return 'Varies';
    }
  }

  /// Get processing time information
  static String getProcessingTime(String method) {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'Instant (few seconds)';
      case 'imps':
        return 'Instant (few minutes)';
      case 'neft':
        return '2-3 hours (batch processing)';
      case 'rtgs':
        return '30 minutes (real-time)';
      case 'card':
        return 'Instant';
      case 'netbanking':
        return 'Instant to 24 hours';
      case 'cash':
        return 'Instant';
      case 'cheque':
        return '1-3 business days';
      default:
        return 'Varies';
    }
  }
}

/// Extension methods on String for payment method utilities
extension PaymentMethodExtension on String {
  /// Get display name for payment method
  String get paymentMethodDisplayName => PaymentMethodTagger.getDisplayName(this);

  /// Get description for payment method
  String get paymentMethodDescription => PaymentMethodTagger.getDescription(this);

  /// Check if payment method is instant
  bool get isInstantPaymentMethod => PaymentMethodTagger.isInstantMethod(this);

  /// Check if payment method is 24/7 available
  bool get is24x7PaymentMethod => PaymentMethodTagger.is24x7Available(this);

  /// Check if payment method requires banking hours
  bool get requiresBankingHoursPaymentMethod =>
      PaymentMethodTagger.requiresBankingHours(this);
}
