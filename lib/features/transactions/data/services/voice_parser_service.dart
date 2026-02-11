import '../../../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

/// Service to parse voice text into transaction data
class VoiceParserService {
  VoiceParserService._();
  static final VoiceParserService _instance = VoiceParserService._();
  static VoiceParserService get instance => _instance;

  // Expense keywords
  static const List<String> _expenseKeywords = [
    'spent',
    'paid',
    'bought',
    'purchased',
    'expense',
    'expenses',
    'cost',
    'pay',
    'buying',
    'spent on',
    'paid for',
  ];

  // Income keywords
  static const List<String> _incomeKeywords = [
    'received',
    'got',
    'earned',
    'income',
    'salary',
    'credited',
    'deposited',
    'earning',
    'bonus',
    'refund',
  ];

  // Transfer keywords
  static const List<String> _transferKeywords = [
    'transfer',
    'transferred',
    'moved',
    'sent to',
    'send to',
    'sending',
  ];

  // Category keyword mappings
  static const Map<String, String> _categoryKeywords = {
    'food': 'Food & Dining',
    'grocery': 'Groceries',
    'groceries': 'Groceries',
    'restaurant': 'Food & Dining',
    'eating': 'Food & Dining',
    'lunch': 'Food & Dining',
    'dinner': 'Food & Dining',
    'breakfast': 'Food & Dining',
    'coffee': 'Food & Dining',
    'travel': 'Transportation',
    'uber': 'Transportation',
    'ola': 'Transportation',
    'cab': 'Transportation',
    'taxi': 'Transportation',
    'bus': 'Transportation',
    'train': 'Transportation',
    'metro': 'Transportation',
    'petrol': 'Transportation',
    'fuel': 'Transportation',
    'diesel': 'Transportation',
    'shopping': 'Shopping',
    'clothes': 'Shopping',
    'amazon': 'Shopping',
    'flipkart': 'Shopping',
    'myntra': 'Shopping',
    'bills': 'Bills & Utilities',
    'electricity': 'Bills & Utilities',
    'water': 'Bills & Utilities',
    'gas': 'Bills & Utilities',
    'internet': 'Bills & Utilities',
    'wifi': 'Bills & Utilities',
    'mobile': 'Bills & Utilities',
    'phone': 'Bills & Utilities',
    'recharge': 'Bills & Utilities',
    'rent': 'Rent',
    'medicine': 'Healthcare',
    'medical': 'Healthcare',
    'doctor': 'Healthcare',
    'hospital': 'Healthcare',
    'pharmacy': 'Healthcare',
    'health': 'Healthcare',
    'gym': 'Health & Fitness',
    'fitness': 'Health & Fitness',
    'entertainment': 'Entertainment',
    'movie': 'Entertainment',
    'movies': 'Entertainment',
    'netflix': 'Entertainment',
    'spotify': 'Entertainment',
    'gaming': 'Entertainment',
    'education': 'Education',
    'course': 'Education',
    'books': 'Education',
    'book': 'Education',
    'tuition': 'Education',
    'insurance': 'Insurance',
    'emi': 'EMI',
    'loan': 'EMI',
    'salary': 'Salary',
    'bonus': 'Bonus',
    'freelance': 'Freelance',
    'investment': 'Investment',
    'dividend': 'Investment',
    'interest': 'Interest',
  };

  // Amount patterns (regex for numbers)
  static final RegExp _amountPattern = RegExp(
    r'(\d+(?:,\d{3})*(?:\.\d{1,2})?)\s*(?:rupees?|rs\.?|₹|inr|hundred|thousand|lakh|crore|k|l|cr)?',
    caseSensitive: false,
  );

  // Word to number mapping
  static const Map<String, int> _wordNumbers = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
  };

  /// Parse natural language to transaction request
  CreateTransactionRequest? parseVoiceInput(String text, {String? defaultAccountId}) {
    if (text.trim().isEmpty) return null;

    final normalizedText = text.toLowerCase().trim();

    // Extract transaction type
    final type = detectType(normalizedText);

    // Extract amount
    final amount = extractAmount(normalizedText);
    if (amount == null || amount <= 0) return null;

    // Extract category
    final category = extractCategory(normalizedText);

    // Extract description
    final description = extractDescription(normalizedText, type);

    // Extract payee/merchant
    final payee = extractPayee(normalizedText, type);

    return CreateTransactionRequest(
      type: type,
      amount: amount,
      accountId: defaultAccountId ?? '',
      categoryId: null, // Would need to map category name to ID
      description: description.isNotEmpty ? description : null,
      payee: payee,
      date: DateTime.now(),
    );
  }

  /// Extract amount from text (returns amount in paise)
  int? extractAmount(String text) {
    final normalizedText = text.toLowerCase();

    // First try to extract numeric amount
    final match = _amountPattern.firstMatch(normalizedText);
    if (match != null) {
      String amountStr = match.group(1)?.replaceAll(',', '') ?? '';
      double? amount = double.tryParse(amountStr);

      if (amount != null) {
        // Check for multipliers
        final suffix = match.group(0)?.toLowerCase() ?? '';
        if (suffix.contains('hundred')) {
          amount *= 100;
        } else if (suffix.contains('thousand') || suffix.contains('k')) {
          amount *= 1000;
        } else if (suffix.contains('lakh') || suffix.contains('l')) {
          amount *= 100000;
        } else if (suffix.contains('crore') || suffix.contains('cr')) {
          amount *= 10000000;
        }

        // Convert to paise
        return (amount * 100).round();
      }
    }

    // Try to find word numbers
    for (final entry in _wordNumbers.entries) {
      if (normalizedText.contains(entry.key)) {
        int multiplier = 1;
        if (normalizedText.contains('hundred')) {
          multiplier = 100;
        } else if (normalizedText.contains('thousand')) {
          multiplier = 1000;
        }
        return entry.value * multiplier * 100; // Convert to paise
      }
    }

    return null;
  }

  /// Detect transaction type from keywords
  TransactionType detectType(String text) {
    final normalizedText = text.toLowerCase();

    // Check for transfer keywords first (most specific)
    for (final keyword in _transferKeywords) {
      if (normalizedText.contains(keyword)) {
        return TransactionType.transfer;
      }
    }

    // Check for income keywords
    for (final keyword in _incomeKeywords) {
      if (normalizedText.contains(keyword)) {
        return TransactionType.income;
      }
    }

    // Check for expense keywords
    for (final keyword in _expenseKeywords) {
      if (normalizedText.contains(keyword)) {
        return TransactionType.expense;
      }
    }

    // Default to expense (most common transaction type)
    return TransactionType.expense;
  }

  /// Extract category from keywords
  String? extractCategory(String text) {
    final normalizedText = text.toLowerCase();

    for (final entry in _categoryKeywords.entries) {
      if (normalizedText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Extract description from text
  String extractDescription(String text, TransactionType type) {
    String normalizedText = text.toLowerCase();

    // Remove common filler words and keywords
    final wordsToRemove = [
      'rupees', 'rs', 'inr', '₹',
      ..._expenseKeywords,
      ..._incomeKeywords,
      ..._transferKeywords,
      'on', 'for', 'from', 'to', 'the', 'a', 'an',
    ];

    for (final word in wordsToRemove) {
      normalizedText = normalizedText.replaceAll(RegExp('\\b$word\\b'), ' ');
    }

    // Remove amount
    normalizedText = normalizedText.replaceAll(_amountPattern, ' ');

    // Clean up whitespace
    normalizedText = normalizedText.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Capitalize first letter
    if (normalizedText.isNotEmpty) {
      normalizedText = normalizedText[0].toUpperCase() +
          (normalizedText.length > 1 ? normalizedText.substring(1) : '');
    }

    return normalizedText;
  }

  /// Extract payee/merchant name
  String? extractPayee(String text, TransactionType type) {
    final normalizedText = text.toLowerCase();

    // Look for patterns like "from X", "to X", "at X"
    final patterns = [
      RegExp(r'(?:from|at|to)\s+(\w+(?:\s+\w+)?)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(normalizedText);
      if (match != null && match.groupCount >= 1) {
        final payee = match.group(1)?.trim();
        if (payee != null && payee.isNotEmpty && payee.length > 2) {
          return payee[0].toUpperCase() + payee.substring(1);
        }
      }
    }

    return null;
  }

  /// Get example voice commands
  List<String> getExampleCommands() {
    return [
      'Spent 500 rupees on groceries',
      'Paid 2000 for electricity bill',
      'Received 50000 salary',
      'Got 1000 bonus from work',
      'Bought coffee for 150 rupees',
      'Transfer 5000 to savings',
      'Paid 200 for uber',
      'Spent 1500 on shopping',
    ];
  }

  /// Validate parsed transaction
  bool isValidTransaction(CreateTransactionRequest? request) {
    if (request == null) return false;
    if (request.amount <= 0) return false;
    return true;
  }
}
