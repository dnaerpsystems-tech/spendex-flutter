import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';

/// Reusable progress indicator for import operations
class ImportProgressIndicator extends StatelessWidget {
  const ImportProgressIndicator({
    required this.progress,
    required this.message,
    this.showPercentage = true,
    super.key,
  });

  final double progress;
  final String message;
  final bool showPercentage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor:
                          SpendexColors.primary.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        SpendexColors.primary,
                      ),
                    ),
                  ),
                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: SpendexColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Iconsax.document_upload,
                        size: 32,
                        color: SpendexColors.primary,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Message
          Text(
            message,
            style: SpendexTheme.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          // Percentage
          if (showPercentage) ...[
            const SizedBox(height: 8),
            Text(
              '$percentage%',
              style: SpendexTheme.headlineMedium.copyWith(
                color: SpendexColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: SpendexColors.primary.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                SpendexColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple loading indicator with message
class SimpleLoadingIndicator extends StatelessWidget {
  const SimpleLoadingIndicator({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: SpendexColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark
                  ? SpendexColors.darkTextSecondary
                  : SpendexColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
