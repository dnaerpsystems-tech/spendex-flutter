import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service for managing in-app reviews
class InAppReviewService {
  InAppReviewService._();

  static const String _keyReviewRequested = 'review_requested';
  static const String _keyLastReviewPrompt = 'last_review_prompt';
  static const String _keyTransactionCount = 'transaction_count_for_review';

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Check if in-app review is available
  static Future<bool> isAvailable() async {
    return _inAppReview.isAvailable();
  }

  /// Request in-app review
  static Future<void> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await _inAppReview.requestReview();

        // Mark as requested
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyReviewRequested, true);
        await prefs.setInt(_keyLastReviewPrompt, DateTime.now().millisecondsSinceEpoch);

        AppLogger.d('InAppReviewService: Review requested');
      }
    } catch (e) {
      AppLogger.e('InAppReviewService: Failed to request review', e);
    }
  }

  /// Open store listing for manual review
  static Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '0000000000', // Replace with actual App Store ID
      );
    } catch (e) {
      AppLogger.e('InAppReviewService: Failed to open store listing', e);
    }
  }

  /// Increment transaction count and check if should prompt
  static Future<bool> shouldPromptAfterTransaction() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if already reviewed
    final reviewed = prefs.getBool(_keyReviewRequested) ?? false;
    if (reviewed) {
      return false;
    }

    // Check last prompt time (don't prompt more than once per week)
    final lastPrompt = prefs.getInt(_keyLastReviewPrompt) ?? 0;
    final daysSinceLastPrompt = DateTime.now()
        .difference(
          DateTime.fromMillisecondsSinceEpoch(lastPrompt),
        )
        .inDays;
    if (daysSinceLastPrompt < 7 && lastPrompt > 0) {
      return false;
    }

    // Increment transaction count
    var count = prefs.getInt(_keyTransactionCount) ?? 0;
    count++;
    await prefs.setInt(_keyTransactionCount, count);

    // Prompt after 10, 25, 50 transactions
    return count == 10 || count == 25 || count == 50;
  }

  /// Reset review prompt state (for testing)
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReviewRequested);
    await prefs.remove(_keyLastReviewPrompt);
    await prefs.remove(_keyTransactionCount);
  }
}
