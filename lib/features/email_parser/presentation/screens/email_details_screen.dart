import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../app/theme.dart';
import '../../../duplicate_detection/presentation/providers/duplicate_detection_provider.dart';
import '../../data/models/email_message_model.dart';
import '../providers/email_parser_provider.dart';
import '../widgets/parsed_transaction_card.dart';

/// Email details screen showing full email content
class EmailDetailsScreen extends ConsumerWidget {
  const EmailDetailsScreen({
    required this.emailId,
    super.key,
  });

  final String emailId;

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  String _getEmailTypeLabel(EmailMessageModel email) {
    switch (email.emailType) {
      case EmailType.notification:
        return 'Transaction Notification';
      case EmailType.statement:
        return 'Account Statement';
      case EmailType.receipt:
        return 'Payment Receipt';
      case EmailType.other:
        return 'Other';
      case null:
        return 'Unknown';
    }
  }

  IconData _getEmailTypeIcon(EmailMessageModel email) {
    switch (email.emailType) {
      case EmailType.notification:
        return Iconsax.notification;
      case EmailType.statement:
        return Iconsax.document_text;
      case EmailType.receipt:
        return Iconsax.receipt;
      case EmailType.other:
        return Iconsax.sms;
      case null:
        return Iconsax.sms;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emailState = ref.watch(emailParserProvider);

    // Find the email by ID
    final email = emailState.emails.firstWhere(
      (e) => e.id == emailId,
      orElse: () => throw Exception('Email not found'),
    );

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Email Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (email.parsedTransaction != null)
            IconButton(
              icon: const Icon(Iconsax.tick_circle),
              tooltip: 'Import Transaction',
              onPressed: () async {
                final parsedTransaction = email.parsedTransaction!;
                final duplicateNotifier =
                    ref.read(duplicateDetectionProvider.notifier);

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Checking for duplicates...'),
                    backgroundColor: SpendexColors.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 1),
                  ),
                );

                // Step 1: Check for duplicates
                await duplicateNotifier.detectDuplicates(
                  transactions: [parsedTransaction],
                );

                if (!context.mounted) return;

                final duplicateState = ref.read(duplicateDetectionProvider);

                // Step 2: Handle duplicates if found
                if (duplicateState.result != null &&
                    duplicateState.result!.duplicateMatches.isNotEmpty) {
                  final result = await context.push<bool>(
                    '/bank-import/duplicate-resolution',
                    extra: {
                      'importId': 'email_${email.id}',
                      'transactions': [parsedTransaction],
                    },
                  );

                  if (!context.mounted) return;

                  // If user resolved duplicates successfully
                  if (result == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction imported successfully'),
                        backgroundColor: SpendexColors.income,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    // Pop back to email list
                    context.pop();
                  }
                  // If user clicked "Review Later", stay on this screen
                  return;
                }

                // Step 3: No duplicates, import directly
                final emailNotifier = ref.read(emailParserProvider.notifier);
                final success = await emailNotifier.importSingleTransaction(
                  transaction: parsedTransaction,
                );

                if (!context.mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction imported successfully'),
                      backgroundColor: SpendexColors.income,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );

                  // Pop back to email list
                  context.pop();
                } else {
                  final error = ref.read(emailParserProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Failed to import transaction'),
                      backgroundColor: SpendexColors.expense,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Email header card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject
                Text(
                  email.subject,
                  style: SpendexTheme.headlineMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // From
                _DetailRow(
                  icon: Iconsax.user,
                  label: 'From',
                  value: email.from,
                ),
                const SizedBox(height: 12),

                // Date
                _DetailRow(
                  icon: Iconsax.calendar,
                  label: 'Date',
                  value: _formatDate(email.date),
                ),
                const SizedBox(height: 12),

                // Email type
                _DetailRow(
                  icon: _getEmailTypeIcon(email),
                  label: 'Type',
                  value: _getEmailTypeLabel(email),
                ),

                // Bank name
                if (email.bankName != null) ...[
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Iconsax.bank,
                    label: 'Bank',
                    value: email.bankName!,
                  ),
                ],

                // Read status
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      email.isRead ? Iconsax.eye : Iconsax.eye_slash,
                      size: 16,
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      email.isRead ? 'Read' : 'Unread',
                      style: SpendexTheme.labelMedium.copyWith(
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parsed transaction (if available)
          if (email.parsedTransaction != null) ...[
            Text(
              'Parsed Transaction',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ParsedTransactionCard(
              transaction: email.parsedTransaction!,
              bankName: email.bankName,
            ),
            const SizedBox(height: 20),
          ],

          // Email body
          Text(
            'Email Content',
            style: SpendexTheme.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? SpendexColors.darkBorder
                    : SpendexColors.lightBorder,
              ),
            ),
            child: SelectableText(
              email.body,
              style: SpendexTheme.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Attachments (if any)
          if (email.hasAttachment && email.attachments.isNotEmpty) ...[
            Text(
              'Attachments',
              style: SpendexTheme.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...email.attachments.map((attachment) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? SpendexColors.darkCard
                        : SpendexColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? SpendexColors.darkBorder
                          : SpendexColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: SpendexColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            _getAttachmentIcon(attachment.mimeType),
                            color: SpendexColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              style: SpendexTheme.titleMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatBytes(attachment.sizeInBytes),
                              style: SpendexTheme.labelMedium.copyWith(
                                color: isDark
                                    ? SpendexColors.darkTextSecondary
                                    : SpendexColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.arrow_down_1),
                        onPressed: () {
                          // TODO: Implement download
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Download coming soon'),
                              backgroundColor: SpendexColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  IconData _getAttachmentIcon(String mimeType) {
    if (mimeType.contains('pdf')) {
      return Iconsax.document;
    } else if (mimeType.contains('csv')) {
      return Iconsax.document_text;
    } else if (mimeType.contains('image')) {
      return Iconsax.gallery;
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Iconsax.archive_1;
    } else {
      return Iconsax.document_1;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<void> _downloadAttachment(
    BuildContext context,
    WidgetRef ref,
    EmailAttachment attachment,
  ) async {
    final notifier = ref.read(emailParserProvider.notifier);

    // Show initial feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing download...'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Download with progress
    final file = await notifier.downloadAttachment(
      attachmentId: attachment.id,
      fileName: attachment.fileName,
    );

    if (!context.mounted) return;

    if (file != null) {
      // Success - show success dialog with option to open
      _showDownloadSuccessDialog(context, file, attachment.fileName);
    } else {
      // Check for error
      final error = ref.read(emailParserProvider).error;
      if (error != null) {
        _showErrorSnackBar(context, error);
      }
      // else user cancelled - no message needed
    }
  }

  void _showDownloadSuccessDialog(
    BuildContext context,
    File file,
    String fileName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Iconsax.tick_circle,
          color: SpendexColors.income,
          size: 48,
        ),
        title: const Text('Download Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              fileName,
              style: SpendexTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Saved to: ${file.path}',
              style: SpendexTheme.bodySmall.copyWith(
                color: SpendexColors.darkTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // Open file using open_filex
              await OpenFilex.open(file.path);
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: SpendexTheme.labelMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextSecondary
                : SpendexColors.lightTextSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: SpendexTheme.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
