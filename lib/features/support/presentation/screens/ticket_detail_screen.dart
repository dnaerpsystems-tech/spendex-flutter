import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme.dart';
import '../../data/datasources/support_local_datasource.dart';
import '../../data/models/ticket_model.dart';

/// Ticket Detail Screen
///
/// Shows details for a specific ticket:
/// - Ticket details (subject, category, priority, status, dates)
/// - Description
/// - Message history (if any)
/// - Option to add follow-up via email
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    required this.ticketId, super.key,
  });

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  Ticket? _ticket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    setState(() => _isLoading = true);
    try {
      final ticket =
          await SupportLocalDataSource.instance.getTicketById(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading ticket: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _sendFollowUpEmail() async {
    if (_ticket == null) {
      return;
    }

    final subject = Uri.encodeComponent(
      'Re: [Spendex Support] ${_ticket!.category.label}: ${_ticket!.subject}',
    );
    final body = Uri.encodeComponent('''


---
Original Ticket ID: ${_ticket!.id}
Category: ${_ticket!.category.label}
Priority: ${_ticket!.priority.label}
Created: ${DateFormat.yMMMd().add_jm().format(_ticket!.createdAt)}
''');

    final emailUri = Uri.parse(
      'mailto:support@spendex.in?subject=$subject&body=$body',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email client'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _deleteTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket?'),
        content: const Text(
          'This will permanently delete this ticket from your local storage. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: SpendexColors.expense,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if ((confirm ?? false) && mounted) {
      await SupportLocalDataSource.instance.deleteTicket(widget.ticketId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    }
  }

  void _copyTicketId() {
    if (_ticket == null) {
      return;
    }
    Clipboard.setData(ClipboardData(text: _ticket!.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ticket ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
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
    final borderColor =
        isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Ticket Details'),
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_ticket == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Ticket Details'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.ticket,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Ticket not found',
                style: SpendexTheme.headlineMedium.copyWith(
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This ticket may have been deleted',
                style: SpendexTheme.bodyMedium.copyWith(
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final ticket = _ticket!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Ticket Details'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Iconsax.more),
            onSelected: (value) {
              switch (value) {
                case 'copy':
                  _copyTicketId();
                  break;
                case 'delete':
                  _deleteTicket();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Iconsax.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copy Ticket ID'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Iconsax.trash,
                      size: 20,
                      color: SpendexColors.expense,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Delete Ticket',
                      style: TextStyle(color: SpendexColors.expense),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendFollowUpEmail,
        backgroundColor: SpendexColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.send_1),
        label: const Text('Follow Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ticket.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ticket.category.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.category.label,
                              style: SpendexTheme.bodySmall.copyWith(
                                color: ticket.category.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.subject,
                              style: SpendexTheme.headlineMedium.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatusBadge(ticket.status),
                      const SizedBox(width: 8),
                      _buildPriorityBadge(ticket.priority),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Ticket ID',
                    ticket.id.substring(0, 8).toUpperCase(),
                    textColor,
                    secondaryTextColor,
                    onTap: _copyTicketId,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    'Created',
                    DateFormat.yMMMd().add_jm().format(ticket.createdAt),
                    textColor,
                    secondaryTextColor,
                  ),
                  if (ticket.updatedAt != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Last Updated',
                      DateFormat.yMMMd().add_jm().format(ticket.updatedAt!),
                      textColor,
                      secondaryTextColor,
                    ),
                  ],
                  if (ticket.deviceInfo != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Device',
                      ticket.deviceInfo!,
                      textColor,
                      secondaryTextColor,
                    ),
                  ],
                  if (ticket.appVersion != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'App Version',
                      ticket.appVersion!,
                      textColor,
                      secondaryTextColor,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Description Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: SpendexTheme.titleMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.description,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: secondaryTextColor,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Messages Section (if any)
            if (ticket.messages.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Messages',
                          style: SpendexTheme.titleMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: SpendexColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${ticket.messages.length}',
                            style: SpendexTheme.bodySmall.copyWith(
                              color: SpendexColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...ticket.messages.map((message) => _buildMessageItem(
                          message,
                          textColor,
                          secondaryTextColor,
                          cardColor,
                        ),),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Info Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SpendexColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.info_circle,
                    color: SpendexColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap "Follow Up" to send a reply via email. Our support team typically responds within 24-48 hours.',
                      style: SpendexTheme.bodySmall.copyWith(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color secondaryTextColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: SpendexTheme.bodySmall.copyWith(
                color: secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: SpendexTheme.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Iconsax.copy,
                    size: 14,
                    color: secondaryTextColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status.color.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.label,
            style: SpendexTheme.labelMedium.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(TicketPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: 14,
            color: priority.color,
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: SpendexTheme.labelMedium.copyWith(
              color: priority.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    TicketMessage message,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    final isSupport = message.isFromSupport;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSupport
            ? SpendexColors.primary.withValues(alpha: 0.05)
            : cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSupport
              ? SpendexColors.primary.withValues(alpha: 0.2)
              : SpendexColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSupport
                      ? SpendexColors.primary.withValues(alpha: 0.1)
                      : SpendexColors.income.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSupport ? Iconsax.support : Iconsax.user,
                  size: 16,
                  color:
                      isSupport ? SpendexColors.primary : SpendexColors.income,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isSupport ? 'Support Team' : 'You',
                style: SpendexTheme.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat.MMMd().add_jm().format(message.createdAt),
                style: SpendexTheme.bodySmall.copyWith(
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.content,
            style: SpendexTheme.bodyMedium.copyWith(
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
