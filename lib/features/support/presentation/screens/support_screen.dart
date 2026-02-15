import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../data/models/ticket_model.dart';

/// Help & Support Screen
///
/// Main hub for support features:
/// - Quick action cards for common issues
/// - FAQ section
/// - Contact options
/// - Create ticket functionality
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail({
    String subject = '',
    String body = '',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@spendex.in',
      query: Uri.encodeFull('subject=$subject&body=$body'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleQuickAction(TicketCategory category) {
    final subject = '[Spendex] ${category.label}';
    final body = '''
Hello Spendex Support,

Category: ${category.label}

Please describe your issue here:


---
Device Info: (auto-filled)
App Version: (auto-filled)
''';
    _sendEmail(subject: subject, body: body);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SpendexColors.primary,
                    SpendexColors.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.message_question,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get help with your account, billing, or technical issues.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: SpendexTheme.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionCard(
                  icon: Iconsax.warning_2,
                  title: 'Report Bug',
                  color: SpendexColors.expense,
                  onTap: () => _handleQuickAction(TicketCategory.bugReport),
                  isDark: isDark,
                ),
                _buildQuickActionCard(
                  icon: Iconsax.magic_star,
                  title: 'Feature Request',
                  color: SpendexColors.primary,
                  onTap: () => _handleQuickAction(TicketCategory.featureRequest),
                  isDark: isDark,
                ),
                _buildQuickActionCard(
                  icon: Iconsax.card,
                  title: 'Billing Issue',
                  color: SpendexColors.transfer,
                  onTap: () => _handleQuickAction(TicketCategory.billingIssue),
                  isDark: isDark,
                ),
                _buildQuickActionCard(
                  icon: Iconsax.shield_tick,
                  title: 'Account & Security',
                  color: SpendexColors.income,
                  onTap: () => _handleQuickAction(TicketCategory.accountSecurity),
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: SpendexTheme.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFaqItem(
              question: 'How do I add a new transaction?',
              answer: 'Tap the + button on the home screen to add a new income or expense transaction.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'How do I set up a budget?',
              answer: 'Go to More > Budgets and tap "Create Budget" to set spending limits for categories.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'Can I export my data?',
              answer: 'Yes! Go to More > Settings > Export Data to download your transactions as CSV or PDF.',
              isDark: isDark,
            ),
            _buildFaqItem(
              question: 'How do I cancel my subscription?',
              answer: 'Go to More > Profile > Subscription and tap "Cancel Subscription". You can continue using premium features until the end of your billing period.',
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Contact Section
            Text(
              'Contact Us',
              style: SpendexTheme.titleMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildContactOption(
                    icon: Iconsax.sms,
                    title: 'Email Support',
                    subtitle: 'support@spendex.in',
                    onTap: () => _sendEmail(),
                    isDark: isDark,
                  ),
                  const Divider(height: 24),
                  _buildContactOption(
                    icon: Iconsax.message_text,
                    title: 'Live Chat',
                    subtitle: 'Available 9 AM - 6 PM IST',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Live chat coming soon!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Emergency Support
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpendexColors.expense.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SpendexColors.expense.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.warning_2,
                      color: SpendexColors.expense,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Compromised?',
                          style: SpendexTheme.labelMedium.copyWith(
                            color: SpendexColors.expense,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Contact us immediately if you suspect unauthorized access.',
                          style: SpendexTheme.bodySmall.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: SpendexTheme.labelMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          question,
          style: SpendexTheme.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: SpendexColors.primary,
        collapsedIconColor: secondaryTextColor,
        children: [
          Text(
            answer,
            style: SpendexTheme.bodySmall.copyWith(
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final textColor = isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpendexColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: SpendexColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SpendexTheme.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: SpendexTheme.bodySmall.copyWith(
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Iconsax.arrow_right_3,
            color: secondaryTextColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
