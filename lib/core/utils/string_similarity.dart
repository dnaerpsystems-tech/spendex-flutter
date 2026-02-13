/// String similarity utilities for duplicate detection
///
/// Provides Levenshtein distance algorithm and normalized similarity scoring
/// for comparing transaction descriptions and merchant names.
library;

/// Calculates the Levenshtein distance between two strings.
///
/// The Levenshtein distance is the minimum number of single-character edits
/// (insertions, deletions, or substitutions) required to change one string
/// into another.
///
/// Example:
/// ```dart
/// levenshteinDistance('kitten', 'sitting') // Returns 3
/// levenshteinDistance('saturday', 'sunday') // Returns 3
/// ```
int levenshteinDistance(String s1, String s2) {
  if (s1 == s2) {
    return 0;
  }
  if (s1.isEmpty) {
    return s2.length;
  }
  if (s2.isEmpty) {
    return s1.length;
  }

  // Create a 2D matrix to store distances
  final len1 = s1.length;
  final len2 = s2.length;

  // Use only two rows instead of full matrix for space optimization
  var previousRow = List<int>.generate(len2 + 1, (i) => i);
  var currentRow = List<int>.filled(len2 + 1, 0);

  for (var i = 1; i <= len1; i++) {
    currentRow[0] = i;

    for (var j = 1; j <= len2; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;

      currentRow[j] = _min3(
        previousRow[j] + 1,      // Deletion
        currentRow[j - 1] + 1,   // Insertion
        previousRow[j - 1] + cost, // Substitution
      );
    }

    // Swap rows
    final temp = previousRow;
    previousRow = currentRow;
    currentRow = temp;
  }

  return previousRow[len2];
}

/// Returns the minimum of three integers
int _min3(int a, int b, int c) {
  return a < b ? (a < c ? a : c) : (b < c ? b : c);
}

/// Calculates normalized similarity score between two strings (0.0 to 1.0).
///
/// Returns 1.0 for identical strings and approaches 0.0 for completely different strings.
/// The score is calculated as: 1 - (levenshtein_distance / max_length)
///
/// Example:
/// ```dart
/// stringSimilarity('hello', 'hello') // Returns 1.0
/// stringSimilarity('hello', 'hallo') // Returns 0.8
/// stringSimilarity('abc', 'xyz') // Returns 0.0
/// ```
double stringSimilarity(String s1, String s2) {
  if (s1 == s2) {
    return 1;
  }
  if (s1.isEmpty || s2.isEmpty) {
    return 0;
  }

  final distance = levenshteinDistance(s1, s2);
  final maxLength = s1.length > s2.length ? s1.length : s2.length;

  return 1 - (distance / maxLength);
}

/// Calculates case-insensitive similarity score between two strings.
///
/// Converts both strings to lowercase before comparison.
///
/// Example:
/// ```dart
/// caseInsensitiveSimilarity('Hello', 'HELLO') // Returns 1.0
/// caseInsensitiveSimilarity('Swiggy', 'SWIGGY') // Returns 1.0
/// ```
double caseInsensitiveSimilarity(String s1, String s2) {
  return stringSimilarity(s1.toLowerCase(), s2.toLowerCase());
}

/// Calculates token-based similarity for transaction descriptions.
///
/// This method:
/// 1. Normalizes both strings (lowercase, trim)
/// 2. Tokenizes into words
/// 3. Removes common stop words
/// 4. Compares unique tokens
/// 5. Returns a similarity score based on common tokens
///
/// This is more effective for transaction descriptions that may have
/// different word orders or extra words.
///
/// Example:
/// ```dart
/// tokenBasedSimilarity(
///   'Payment to Swiggy Food Delivery',
///   'Swiggy Food Payment'
/// ) // Returns high score despite different word order
/// ```
double tokenBasedSimilarity(String s1, String s2) {
  if (s1 == s2) {
    return 1;
  }
  if (s1.isEmpty || s2.isEmpty) {
    return 0;
  }

  // Normalize strings
  final normalized1 = _normalizeString(s1);
  final normalized2 = _normalizeString(s2);

  // Tokenize into words
  final tokens1 = _tokenize(normalized1);
  final tokens2 = _tokenize(normalized2);

  if (tokens1.isEmpty || tokens2.isEmpty) {
    return 0;
  }

  // Calculate Jaccard similarity (intersection over union)
  final set1 = tokens1.toSet();
  final set2 = tokens2.toSet();

  final intersection = set1.intersection(set2).length;
  final union = set1.union(set2).length;

  if (union == 0) {
    return 0;
  }

  final jaccardScore = intersection / union;

  // Also calculate average token similarity for matched tokens
  var totalSimilarity = 0.0;
  var comparisons = 0;

  for (final token1 in tokens1) {
    for (final token2 in tokens2) {
      final similarity = stringSimilarity(token1, token2);
      if (similarity > 0.7) { // Only count strong matches
        totalSimilarity += similarity;
        comparisons++;
      }
    }
  }

  final avgTokenSimilarity = comparisons > 0 ? totalSimilarity / comparisons : 0.0;

  // Combine Jaccard score with average token similarity (weighted)
  return (jaccardScore * 0.6) + (avgTokenSimilarity * 0.4);
}

/// Normalizes a string by:
/// - Converting to lowercase
/// - Removing extra whitespace
/// - Removing special characters (keeping alphanumeric and spaces)
String _normalizeString(String s) {
  return s
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), ' ') // Replace special chars with space
      .replaceAll(RegExp(r'\s+'), ' ')      // Normalize whitespace
      .trim();
}

/// Tokenizes a string into words, removing common stop words
List<String> _tokenize(String s) {
  final words = s.split(' ').where((w) => w.isNotEmpty).toList();

  // Remove common stop words that don't add meaning
  const stopWords = {
    'to', 'from', 'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at',
    'by', 'for', 'with', 'is', 'was', 'are', 'were', 'been', 'be', 'has',
    'have', 'had', 'payment', 'transaction', 'transfer', 'upi', 'imps', 'neft'
  };

  return words.where((w) => !stopWords.contains(w) && w.length > 1).toList();
}

/// Calculates the best similarity score using multiple algorithms.
///
/// Tries different similarity methods and returns the highest score:
/// - Exact match
/// - Case-insensitive match
/// - Token-based similarity
/// - Regular Levenshtein similarity
///
/// This provides the most accurate similarity score for transaction matching.
///
/// Example:
/// ```dart
/// bestSimilarity('Swiggy Food', 'SWIGGY FOOD DELIVERY') // Returns high score
/// ```
double bestSimilarity(String s1, String s2) {
  if (s1 == s2) {
    return 1;
  }
  if (s1.isEmpty || s2.isEmpty) {
    return 0;
  }

  // Try different similarity algorithms and return the best score
  final caseInsensitive = caseInsensitiveSimilarity(s1, s2);
  final tokenBased = tokenBasedSimilarity(s1, s2);
  final regular = stringSimilarity(s1.toLowerCase(), s2.toLowerCase());

  // Return the maximum score from all algorithms
  return [
    caseInsensitive,
    tokenBased,
    regular,
  ].reduce((a, b) => a > b ? a : b);
}
