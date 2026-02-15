import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../data/datasources/support_local_datasource.dart';
import '../../data/models/ticket_model.dart';

/// Help & Support Screen
///
/// Main hub for support features:
/// - Quick action cards for common issues
/// - FAQ section with expandable items
/// - My Tickets section
/// - Contact options
/// - Create ticket functionality
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  List<Ticket> _recentTickets = [];
  bool _isLoadingTickets = true;

  @override
  void initState() {
    super.initState();
    _loadRecentTickets();
  }

  Future<void> _loadRecentTickets() async {
    try {
      final tickets = await SupportLocalDataSource.instance.getTickets();
      if (mounted) {
        setState(() {
          _recentTickets = tickets.take(3).toList();
          _isLoadingTickets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTickets = false;
        });
      }
    }
  }

  Future<void> _sendEmail({
    String subject = '',
    String body = '',
  }) async {
    final emailUri = Uri(
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

  void _navigateToCreateTicket(TicketCategory category) {
    context.push(
      AppRoutes.createTicket,
      extra: {'category': category},
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground;
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.ticket),
            tooltip: 'My Tickets',
            onPressed: () => context.push(AppRoutes.ticketList),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createTicket),
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add),
        label: const Text('New Ticket'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentTickets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    onTap: () => _navigateToCreateTicket(TicketCategory.bugReport),
                    isDark: isDark,
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.magic_star,
                    title: 'Feature Request',
                    color: SpendexColors.primary,
                    onTap: () =>
                        _navigateToCreateTicket(TicketCategory.featureRequest),
                    isDark: isDark,
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.card,
                    title: 'Billing Issue',
                    color: SpendexColors.transfer,
                    onTap: () =>
                        _navigateToCreateTicket(TicketCategory.billingIssue),
                    isDark: isDark,
                  ),
                  _buildQuickActionCard(
                    icon: Iconsax.shield_tick,
                    title: 'Account & Security',
                    color: SpendexColors.income,
                    onTap: () =>
                        _navigateToCreateTicket(TicketCategory.accountSecurity),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // My Tickets Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Tickets',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_recentTickets.isNotEmpty)
                    TextButton(
                      onPressed: () => context.push(AppRoutes.ticketList),
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTicketsSection(isDark, cardColor, textColor, secondaryTextColor),
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
                answer:
                    'Tap the + button on the home screen to add a new income or expense transaction. You can also import transactions from your bank statements.',
                isDark: isDark,
              ),
              _buildFaqItem(
                question: 'How do I set up a budget?',
                answer:
                    'Go to More > Budgets and tap "Create Budget" to set spending limits for categories. You can create multiple budgets for different categories or time periods.',
                isDark: isDark,
              ),
              _buildFaqItem(
                question: 'Can I export my data?',
                answer:
                    'Yes! Go to More > Settings > Export Data to download your transactions as CSV or PDF. You can also sync your data across devices.',
                isDark: isDark,
              ),
              _buildFaqItem(
                question: 'How do I connect my bank account?',
                answer:
                    'Go to More > Bank Import to connect your bank account or import bank statements. We support PDF statements and SMS parsing for transactions.',
                isDark: isDark,
              ),
              _buildFaqItem(
                question: 'How do I cancel my subscription?',
                answer:
                    'Go to More > Profile > Subscription and tap "Cancel Subscription". You can continue using premium features until the end of your billing period.',
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
                    color:
                        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _buildContactOption(
                      icon: Iconsax.sms,
                      title: 'Email Support',
                      subtitle: 'support@spendex.in',
                      onTap: () => _sendEmail(
                        subject: '[Spendex Support] General Inquiry',
                      ),
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
              const SizedBox(height: 24),

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
                    IconButton(
                      onPressed: () => _sendEmail(
                        subject: '[URGENT] Account Security Issue',
                        body: 'I suspect my account has been compromised. Please help.',
                      ),
                      icon: const Icon(
                        Iconsax.send_1,
                        color: SpendexColors.expense,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsSection(
    bool isDark,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    if (_isLoadingTickets) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_recentTickets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Iconsax.ticket,
              size: 48,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 12),
            Text(
              'No tickets yet',
              style: SpendexTheme.titleMedium.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your support tickets will appear here',
              style: SpendexTheme.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _recentTickets.map((ticket) {
        return GestureDetector(
          onTap: () => context.push('${AppRoutes.ticketDetail}/${ticket.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ticket.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    ticket.category.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: SpendexTheme.bodyMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ticket.status.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ticket.status.label,
                              style: SpendexTheme.bodySmall.copyWith(
                                color: ticket.status.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(ticket.createdAt),
                            style: SpendexTheme.bodySmall.copyWith(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
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
          ),
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final cardColor = isDark ? SpendexColors.darkCard : SpendexColors.lightCard;
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;

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
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

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
    final textColor =
        isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? SpendexColors.darkTextSecondary
        : SpendexColors.lightTextSecondary;

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
            child: Icon(
              icon,
              color: SpendexColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: SpendexTheme.bodyMedium.copyWith(
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
