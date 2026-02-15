import '../../../transactions/presentation/widgets/receipt_scanner_sheet.dart';

/// Service for parsing receipt text into structured data
class ReceiptParserService {
  ReceiptParserService._();
  static final ReceiptParserService _instance = ReceiptParserService._();
  static ReceiptParserService get instance => _instance;

  // Regex patterns
  static final RegExp _amountPattern = RegExp(
    r'(?:total|amount|bill|grand\s*total|net\s*amount)[\s:]*(?:rs\.?|₹)?\s*(\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})?)',
    caseSensitive: false,
    multiLine: true,
  );

  static final RegExp _datePattern = RegExp(
    r'(?:date|bill\s*date|invoice\s*date)[\s:]*(\d{1,2}[\/\-\.]\d{1,2}[\/\-\.]\d{2,4})',
    caseSensitive: false,
    multiLine: true,
  );

  static final RegExp _numberOnlyPattern = RegExp(r'^\d+(?:\.\d{2})?$');

  // Business name indicators
  static final List<String> _businessSuffixes = [
    'pvt ltd',
    'private limited',
    'llp',
    'llc',
    'inc',
    'mart',
    'store',
    'shop',
    'supermarket',
    'restaurant',
    'cafe',
    'hotel',
    'india',
    'co',
  ];

  // Words to filter out from merchant names
  static final List<String> _filterWords = [
    'invoice',
    'receipt',
    'bill',
    'tax',
    'gst',
    'tin',
    'welcome',
    'thank',
    'visit',
  ];

  // Category keywords
  static final Map<String, List<String>> _categoryKeywords = {
    'Groceries': [
      'dmart',
      'big bazaar',
      'reliance fresh',
      'more',
      'supermarket',
      'grocery',
      'provisions',
      'milk',
      'bread',
      'rice',
      'dal',
    ],
    'Food & Dining': [
      'restaurant',
      'cafe',
      'swiggy',
      'zomato',
      'dominos',
      'pizza',
      'burger',
      'mcdonald',
      'kfc',
      'food',
      'dining',
    ],
    'Shopping': [
      'amazon',
      'flipkart',
      'myntra',
      'lifestyle',
      'westside',
      'max',
      'pantaloons',
      'clothing',
      'fashion',
    ],
    'Electronics': [
      'croma',
      'reliance digital',
      'vijay sales',
      'electronics',
      'mobile',
      'laptop',
      'computer',
    ],
    'Transportation': [
      'uber',
      'ola',
      'rapido',
      'metro',
      'taxi',
      'cab',
      'transport',
    ],
    'Entertainment': [
      'pvr',
      'inox',
      'bookmyshow',
      'cinema',
      'movie',
      'theatre',
    ],
  };

  /// Parse receipt text into structured data
  ExtractedReceiptData parseReceiptText(String text) {
    if (text.trim().isEmpty) {
      return const ExtractedReceiptData();
    }

    // Clean up text
    final cleanText = _preprocessText(text);

    // Extract components
    final amount = extractAmount(cleanText);
    final merchant = extractMerchant(cleanText);
    final date = extractDate(cleanText);
    final items = extractLineItems(cleanText);
    final category = detectCategory(merchant, items);

    return ExtractedReceiptData(
      merchantName: merchant,
      amount: amount,
      date: date,
      items: items,
      category: category,
    );
  }

  /// Preprocess OCR text to improve parsing
  String _preprocessText(String text) {
    // Normalize whitespace
    var cleaned = text.replaceAll(RegExp(r'\s+'), ' ');

    // Fix common OCR errors
    cleaned = cleaned
        .replaceAll(RegExp(r'[Oo](?=\d)'), '0') // O followed by digit → 0
        .replaceAll(RegExp(r'(?<=\d)[IlL]'), '1') // I/l/L after digit → 1
        .replaceAll(RegExp(r'[Ss](?=\d)'), '5'); // S before digit → 5

    return cleaned;
  }

  /// Extract total amount from text
  int? extractAmount(String text) {
    final matches = _amountPattern.allMatches(text);
    double maxAmount = 0;

    for (final match in matches) {
      final amountStr = match.group(1);
      if (amountStr != null) {
        // Remove commas and spaces
        final cleanAmount = amountStr.replaceAll(RegExp(r'[,\s]'), '');
        final amount = double.tryParse(cleanAmount);
        if (amount != null && amount > maxAmount) {
          maxAmount = amount;
        }
      }
    }

    // If no amount found with keywords, look for standalone large numbers
    if (maxAmount == 0) {
      final lines = text.split('\n');
      for (final line in lines.reversed) {
        final trimmed = line.trim();
        if (_numberOnlyPattern.hasMatch(trimmed)) {
          final amount = double.tryParse(trimmed);
          if (amount != null && amount > 10) {
            // Likely the total
            maxAmount = amount;
            break;
          }
        }
      }
    }

    if (maxAmount > 0) {
      // Convert to paise
      return (maxAmount * 100).toInt();
    }

    return null;
  }

  /// Extract merchant name from text
  String? extractMerchant(String text) {
    final lines = text.split('\n');

    // Check first 5 lines for merchant name
    for (var i = 0; i < (lines.length < 5 ? lines.length : 5); i++) {
      final line = lines[i].trim();

      // Skip if too short or all numbers
      if (line.length < 3 || RegExp(r'^\d+$').hasMatch(line)) {
        continue;
      }

      // Skip if contains filter words
      if (_containsFilterWords(line.toLowerCase())) {
        continue;
      }

      // Likely merchant name if:
      // 1. Contains business suffix
      // 2. Is in ALL CAPS
      // 3. Contains "M/s" prefix
      if (_containsBusinessSuffix(line.toLowerCase()) ||
          _isAllCaps(line) ||
          line.toLowerCase().startsWith('m/s')) {
        return _cleanMerchantName(line);
      }
    }

    // Fallback: return first non-empty line if nothing found
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length >= 3 && !RegExp(r'^\d+$').hasMatch(trimmed)) {
        return _cleanMerchantName(trimmed);
      }
    }

    return null;
  }

  /// Extract date from text
  DateTime? extractDate(String text) {
    final match = _datePattern.firstMatch(text);
    if (match != null) {
      final dateStr = match.group(1);
      if (dateStr != null) {
        return _parseIndianDate(dateStr);
      }
    }
    return null;
  }

  /// Extract line items from text
  List<String> extractLineItems(String text) {
    final items = <String>[];
    final lines = text.split('\n');
    var foundItems = false;

    for (final line in lines) {
      final trimmed = line.trim();

      // Skip header lines
      if (_containsFilterWords(trimmed.toLowerCase())) {
        continue;
      }

      // Start collecting items after header
      if (!foundItems && trimmed.length > 3) {
        foundItems = true;
      }

      // Stop at total
      if (RegExp('total|subtotal|amount', caseSensitive: false).hasMatch(trimmed)) {
        break;
      }

      // Add line if it looks like an item (has text and possibly numbers)
      if (foundItems && trimmed.length > 2 && !RegExp(r'^\d+$').hasMatch(trimmed)) {
        items.add(trimmed);
      }

      // Limit to 10 items
      if (items.length >= 10) {
        break;
      }
    }

    return items;
  }

  /// Detect category from merchant name and items
  String? detectCategory(String? merchant, List<String> items) {
    final searchText = '${merchant ?? ''} ${items.join(' ')}'.toLowerCase();

    for (final entry in _categoryKeywords.entries) {
      for (final keyword in entry.value) {
        if (searchText.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return null;
  }

  // Helper methods

  bool _containsBusinessSuffix(String text) {
    return _businessSuffixes.any((suffix) => text.contains(suffix));
  }

  bool _containsFilterWords(String text) {
    return _filterWords.any((word) => text.contains(word));
  }

  bool _isAllCaps(String text) {
    final letters = text.replaceAll(RegExp('[^a-zA-Z]'), '');
    if (letters.isEmpty) {
      return false;
    }
    return letters == letters.toUpperCase() && letters.length >= 3;
  }

  String _cleanMerchantName(String name) {
    var cleaned = name.trim();

    // Remove M/s prefix
    cleaned = cleaned.replaceAll(RegExp(r'^m/s\s*', caseSensitive: false), '');

    // Convert to title case if all caps
    if (_isAllCaps(cleaned)) {
      cleaned = _toTitleCase(cleaned);
    }

    return cleaned;
  }

  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) {
        return word;
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  DateTime? _parseIndianDate(String dateStr) {
    try {
      // Try DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
      final parts = dateStr.split(RegExp(r'[\/\-\.]'));
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        var year = int.parse(parts[2]);

        // Handle 2-digit years
        if (year < 100) {
          year += (year > 50 ? 1900 : 2000);
        }

        final date = DateTime(year, month, day);

        // Validate date is not in future
        if (date.isAfter(DateTime.now())) {
          return null;
        }

        return date;
      }
    } catch (e) {
      // Invalid date format
    }
    return null;
  }
}
