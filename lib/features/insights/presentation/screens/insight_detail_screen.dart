import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../data/models/insight_model.dart';
import '../providers/insights_provider.dart';
import '../widgets/insight_type_icon.dart';
import '../../../../core/firebase/analytics_service.dart';

/// Extension to provide display labels for InsightPriority
extension InsightPriorityExtension on InsightPriority {
  String get label {
    switch (this) {
      case InsightPriority.high:
        return 'High Priority';
      case InsightPriority.medium:
        return 'Medium Priority';
      case InsightPriority.low:
        return 'Low Priority';
    }
  }
}

/// Extension to provide display labels for InsightActionType
extension InsightActionTypeExtension on InsightActionType {
  String get label {
    switch (this) {
      case InsightActionType.viewTransactions:
        return 'View Transactions';
      case InsightActionType.setBudget:
        return 'Set Budget';
      case InsightActionType.setGoal:
        return 'Set Goal';
      case InsightActionType.viewCategory:
        return 'View Category';
      case InsightActionType.viewMerchant:
        return 'View Merchant';
      case InsightActionType.viewAccount:
        return 'View Account';
      case InsightActionType.viewLoan:
        return 'View Loan';
      case InsightActionType.none:
        return 'No Action';
    }
  }
}

class InsightDetailScreen extends ConsumerStatefulWidget {
  const InsightDetailScreen({
    required this.insightId,
    super.key,
  });
  final String insightId;

  @override
  ConsumerState<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends ConsumerState<InsightDetailScreen> {
  bool _autoMarkAsReadExecuted = false;

  @override
  void initState() {
    super.initState();
    // Analytics screen view
    AnalyticsService.logScreenView(screenName: 'insight_detail');
    // Auto-mark as read after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_autoMarkAsReadExecuted) {
        _autoMarkAsReadExecuted = true;
        try {
          final insight = ref.read(insightsStateProvider).allInsights.firstWhere(
                (i) => i.id == widget.insightId,
              );
          if (!insight.isRead) {
            ref.read(insightsStateProvider.notifier).markAsRead(widget.insightId);
          }
        } catch (e) {
          // Insight not found, do nothing
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsStateProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Find the insight
    InsightModel? insightOrNull;
    try {
      insightOrNull = state.allInsights.firstWhere(
        (i) => i.id == widget.insightId,
      );
    } catch (e) {
      // Insight not found
    }

    if (insightOrNull == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Insight Details'),
        ),
        body: ErrorStateWidget(
          message: 'Insight not found',
          onRetry: () => context.pop(),
        ),
      );
    }

    final insight = insightOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: () => _shareInsight(insight),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Iconsax.close_circle),
            onPressed: () => _showDismissDialog(context, insight.id),
            tooltip: 'Dismiss',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Icon Section
            _buildHeroIconSection(insight, isDark),

            const SizedBox(height: 24),

            // Priority Badge
            Center(
              child: _buildPriorityBadge(insight, theme),
            ),

            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                insight.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Timestamp
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _getTimestampText(insight.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                insight.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 24),

            // Metadata Section
            if (insight.metadata != null && insight.metadata!.isNotEmpty) ...[
              _buildMetadataSection(insight, theme),
              const SizedBox(height: 16),
            ],

            // Valid Until Section
            if (insight.validUntil != null) ...[
              _buildValidUntilSection(insight, theme),
              const SizedBox(height: 16),
            ],

            // Action Buttons Section
            if (insight.actionType != InsightActionType.none) ...[
              _buildActionButtonSection(insight, theme),
              const SizedBox(height: 16),
            ],

            // Bottom spacing for fixed bar
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(insight, theme, isDark),
    );
  }

  Widget _buildHeroIconSection(InsightModel insight, bool isDark) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        gradient: _getGradientForType(insight.type, isDark),
      ),
      child: Center(
        child: InsightTypeIcon(
          type: insight.type,
          size: 80,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(InsightModel insight, ThemeData theme) {
    Color backgroundColor;
    Color textColor;

    switch (insight.priority) {
      case InsightPriority.high:
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
      case InsightPriority.medium:
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        break;
      case InsightPriority.low:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        break;
    }

    if (theme.brightness == Brightness.dark) {
      backgroundColor = backgroundColor.withValues(alpha: 0.2);
      textColor = backgroundColor.withValues(alpha: 1);
    }

    return Chip(
      label: Text(
        insight.priority.label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildMetadataSection(InsightModel insight, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...insight.metadata!.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatMetadataKey(entry.key),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _formatMetadataValue(entry.key, entry.value),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidUntilSection(InsightModel insight, ThemeData theme) {
    final validUntil = insight.validUntil!;
    final now = DateTime.now();
    final daysUntilExpiry = validUntil.difference(now).inDays;
    final isExpiringSoon = daysUntilExpiry <= 3;

    final backgroundColor = isExpiringSoon
        ? (theme.brightness == Brightness.dark
            ? Colors.orange.shade900.withValues(alpha: 0.2)
            : Colors.orange.shade50)
        : null;

    final textColor = isExpiringSoon
        ? (theme.brightness == Brightness.dark ? Colors.orange.shade300 : Colors.orange.shade900)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Iconsax.clock,
                color: textColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      daysUntilExpiry > 0
                          ? 'Expires in $daysUntilExpiry ${daysUntilExpiry == 1 ? 'day' : 'days'}'
                          : 'Expired',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valid until ${Jiffy.parseFromDateTime(validUntil).format(pattern: 'MMM dd, yyyy')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor?.withValues(alpha: 0.8) ??
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonSection(InsightModel insight, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton.icon(
        onPressed: () => _handleAction(insight),
        icon: Icon(_getActionIcon(insight.actionType)),
        label: Text(insight.actionType.label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }

  Widget _buildBottomBar(InsightModel insight, ThemeData theme, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _toggleReadStatus(insight),
                icon: Icon(
                  insight.isRead ? Iconsax.eye_slash : Iconsax.eye,
                ),
                label: Text(insight.isRead ? 'Mark as Unread' : 'Mark as Read'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showDismissDialog(context, insight.id),
                icon: const Icon(Iconsax.close_circle),
                label: const Text('Dismiss'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isDark ? Colors.red.shade900 : Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForType(InsightType type, bool isDark) {
    List<Color> colors;

    switch (type) {
      case InsightType.spendingPattern:
        colors = isDark
            ? [Colors.red.shade900, Colors.red.shade700]
            : [Colors.red.shade400, Colors.red.shade600];
        break;
      case InsightType.savingsOpportunity:
        colors = isDark
            ? [Colors.green.shade900, Colors.green.shade700]
            : [Colors.green.shade400, Colors.green.shade600];
        break;
      case InsightType.budgetRecommendation:
        colors = isDark
            ? [Colors.orange.shade900, Colors.orange.shade700]
            : [Colors.orange.shade400, Colors.orange.shade600];
        break;
      case InsightType.categoryTrend:
        colors = isDark
            ? [Colors.blue.shade900, Colors.blue.shade700]
            : [Colors.blue.shade400, Colors.blue.shade600];
        break;
      case InsightType.goalAchievability:
        colors = isDark
            ? [Colors.purple.shade900, Colors.purple.shade700]
            : [Colors.purple.shade400, Colors.purple.shade600];
        break;
      case InsightType.billPrediction:
        colors = isDark
            ? [Colors.teal.shade900, Colors.teal.shade700]
            : [Colors.teal.shade400, Colors.teal.shade600];
        break;
      case InsightType.loanInsight:
        colors = isDark
            ? [Colors.deepOrange.shade900, Colors.deepOrange.shade700]
            : [Colors.deepOrange.shade400, Colors.deepOrange.shade600];
        break;
      case InsightType.anomalyDetection:
        colors = isDark
            ? [Colors.amber.shade900, Colors.amber.shade700]
            : [Colors.amber.shade400, Colors.amber.shade600];
        break;
      case InsightType.merchantAnalysis:
        colors = isDark
            ? [Colors.cyan.shade900, Colors.cyan.shade700]
            : [Colors.cyan.shade400, Colors.cyan.shade600];
        break;
      case InsightType.cashFlowForecast:
        colors = isDark
            ? [Colors.indigo.shade900, Colors.indigo.shade700]
            : [Colors.indigo.shade400, Colors.indigo.shade600];
        break;
    }

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  String _getTimestampText(DateTime timestamp) {
    final jiffy = Jiffy.parseFromDateTime(timestamp);
    return 'Generated ${jiffy.fromNow()}';
  }

  String _formatMetadataKey(String key) {
    // Convert camelCase or snake_case to Title Case
    final words = key
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ');

    return words.map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  String _formatMetadataValue(String key, value) {
    if (value == null) {
      return 'N/A';
    }

    // Format currency values
    if (key.toLowerCase().contains('amount') ||
        key.toLowerCase().contains('balance') ||
        key.toLowerCase().contains('limit')) {
      if (value is num) {
        return CurrencyFormatter.format(value.toDouble());
      }
    }

    // Format dates
    if (value is DateTime) {
      return Jiffy.parseFromDateTime(value).format(pattern: 'MMM dd, yyyy');
    }

    // Format lists
    if (value is List) {
      return value.join(', ');
    }

    return value.toString();
  }

  IconData _getActionIcon(InsightActionType actionType) {
    switch (actionType) {
      case InsightActionType.viewCategory:
        return Iconsax.category;
      case InsightActionType.viewMerchant:
        return Iconsax.shop;
      case InsightActionType.viewAccount:
        return Iconsax.wallet;
      case InsightActionType.viewLoan:
        return Iconsax.money_send;
      case InsightActionType.viewTransactions:
        return Iconsax.receipt;
      case InsightActionType.setBudget:
        return Iconsax.add_circle;
      case InsightActionType.setGoal:
        return Iconsax.add_circle;
      case InsightActionType.none:
        return Iconsax.arrow_right;
    }
  }

  void _handleAction(InsightModel insight) {
    switch (insight.actionType) {
      case InsightActionType.viewCategory:
        if (insight.actionData != null && insight.actionData!.containsKey('categoryId')) {
          context.push(
            '${AppRoutes.categoryDetails}?id=${insight.actionData!['categoryId']}',
          );
        }
        break;
      case InsightActionType.viewTransactions:
        context.push(AppRoutes.transactions);
        break;
      case InsightActionType.setBudget:
        context.push(AppRoutes.addBudget);
        break;
      case InsightActionType.setGoal:
        context.push(AppRoutes.addGoal);
        break;
      case InsightActionType.viewMerchant:
        // Navigate to merchant when available
        break;
      case InsightActionType.viewAccount:
        // Navigate to account when available
        break;
      case InsightActionType.viewLoan:
        context.push(AppRoutes.loans);
        break;
      case InsightActionType.none:
        break;
    }
  }

  void _toggleReadStatus(InsightModel insight) {
    if (!insight.isRead) {
      ref.read(insightsStateProvider.notifier).markAsRead(widget.insightId);
    }
    // Note: markAsUnread is not implemented in the provider
  }

  void _shareInsight(InsightModel insight) {
    final text = '''
${insight.title}

${insight.description}

Generated by Spendex - Personal Finance Manager
''';

    Share.share(text, subject: insight.title);
  }

  void _showDismissDialog(BuildContext context, String insightId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dismiss Insight?'),
        content: const Text('This insight will be hidden from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(insightsStateProvider.notifier).dismiss(insightId);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
