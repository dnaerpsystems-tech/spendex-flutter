import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:enough_mail/enough_mail.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/email_account_model.dart';
import '../models/email_filter_model.dart';
import '../models/email_message_model.dart';

abstract class EmailLocalDataSource {
  /// Cache email accounts locally
  Future<Either<Failure, bool>> cacheEmailAccounts(
    List<EmailAccountModel> accounts,
  );

  /// Get cached email accounts
  Future<Either<Failure, List<EmailAccountModel>>> getCachedAccounts();

  /// Cache emails locally
  Future<Either<Failure, bool>> cacheEmails(
    List<EmailMessageModel> emails,
  );

  /// Get cached emails
  Future<Either<Failure, List<EmailMessageModel>>> getCachedEmails({
    String? accountId,
  });

  /// Clear all cached data
  Future<Either<Failure, bool>> clearCache();

  /// Clear cached emails for specific account
  Future<Either<Failure, bool>> clearEmailsForAccount(String accountId);

  /// Connect to IMAP server and fetch emails
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmailsFromImap({
    required EmailAccountModel account,
    required String password,
    EmailFilterModel? filters,
  });

  /// Save encrypted password for email account
  Future<Either<Failure, bool>> saveAccountPassword({
    required String accountId,
    required String password,
  });

  /// Get decrypted password for email account
  Future<Either<Failure, String?>> getAccountPassword({
    required String accountId,
  });

  /// Delete account password
  Future<Either<Failure, bool>> deleteAccountPassword({
    required String accountId,
  });
}

class EmailLocalDataSourceImpl implements EmailLocalDataSource {
  EmailLocalDataSourceImpl(this._secureStorage);
  final SecureStorageService _secureStorage;

  static const String _accountsCacheKey = 'email_accounts_cache';
  static const String _emailsCacheKey = 'email_messages_cache';
  static const String _passwordKeyPrefix = 'email_password_';

  @override
  Future<Either<Failure, bool>> cacheEmailAccounts(
    List<EmailAccountModel> accounts,
  ) async {
    try {
      final accountsJson = accounts.map((a) => a.toJson()).toList();
      await _secureStorage.save(
        _accountsCacheKey,
        json.encode(accountsJson),
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to cache email accounts: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmailAccountModel>>> getCachedAccounts() async {
    try {
      final accountsString = await _secureStorage.read(_accountsCacheKey);

      if (accountsString == null || accountsString.isEmpty) {
        return const Right([]);
      }

      final accountsList = json.decode(accountsString) as List<dynamic>;
      final accounts =
          accountsList.map((e) => EmailAccountModel.fromJson(e as Map<String, dynamic>)).toList();

      return Right(accounts);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached accounts: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> cacheEmails(
    List<EmailMessageModel> emails,
  ) async {
    try {
      final emailsJson = emails.map((e) => e.toJson()).toList();
      await _secureStorage.save(
        _emailsCacheKey,
        json.encode(emailsJson),
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to cache emails: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> getCachedEmails({
    String? accountId,
  }) async {
    try {
      final emailsString = await _secureStorage.read(_emailsCacheKey);

      if (emailsString == null || emailsString.isEmpty) {
        return const Right([]);
      }

      final emailsList = json.decode(emailsString) as List<dynamic>;
      var emails =
          emailsList.map((e) => EmailMessageModel.fromJson(e as Map<String, dynamic>)).toList();

      // Filter by account ID if provided
      if (accountId != null) {
        emails = emails.where((e) => e.accountId == accountId).toList();
      }

      return Right(emails);
    } catch (e) {
      return Left(CacheFailure('Failed to get cached emails: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearCache() async {
    try {
      await Future.wait([
        _secureStorage.delete(_accountsCacheKey),
        _secureStorage.delete(_emailsCacheKey),
      ]);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> clearEmailsForAccount(String accountId) async {
    try {
      final result = await getCachedEmails();

      return result.fold(
        Left.new,
        (emails) async {
          final filteredEmails = emails.where((e) => e.accountId != accountId).toList();
          return cacheEmails(filteredEmails);
        },
      );
    } catch (e) {
      return Left(CacheFailure('Failed to clear emails for account: $e'));
    }
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmailsFromImap({
    required EmailAccountModel account,
    required String password,
    EmailFilterModel? filters,
  }) async {
    try {
      // Create IMAP client
      final client = ImapClient();

      // Connect to IMAP server
      await client.connectToServer(
        account.imapServer,
        account.imapPort,
        isSecure: account.useSsl,
      );

      // Login
      await client.login(account.username, password);

      // Select INBOX
      await client.selectInbox();

      // For simplicity, fetch recent messages (last 100)
      // In production, you would implement proper search with filters
      final mailbox = await client.selectInbox();

      if (mailbox.messagesExists == 0) {
        await client.logout();
        return const Right([]);
      }

      // Fetch recent messages
      final fetchLimit = filters?.maxResults ?? 100;
      final startSeq =
          mailbox.messagesExists > fetchLimit ? mailbox.messagesExists - fetchLimit + 1 : 1;

      final sequence = MessageSequence.fromRange(startSeq, mailbox.messagesExists);
      final fetchResult = await client.fetchMessages(
        sequence,
        '(ENVELOPE BODY.PEEK[])',
      );

      // Convert to EmailMessageModel
      final emails = <EmailMessageModel>[];

      for (final message in fetchResult.messages) {
        try {
          final emailMessage = _convertMimeMessageToEmailMessage(
            message,
            account.id,
          );
          emails.add(emailMessage);
        } catch (e) {
          // Skip messages that fail to parse
          continue;
        }
      }

      // Logout
      await client.logout();

      // Apply additional filters if needed
      var filteredEmails = emails;

      if (filters != null) {
        filteredEmails = _applyLocalFilters(emails, filters);
      }

      // Limit results if specified
      if (filters?.maxResults != null) {
        filteredEmails = filteredEmails.take(filters!.maxResults!).toList();
      }

      return Right(filteredEmails);
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch emails from IMAP: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveAccountPassword({
    required String accountId,
    required String password,
  }) async {
    try {
      await _secureStorage.save(
        '$_passwordKeyPrefix$accountId',
        password,
      );
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to save account password: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getAccountPassword({
    required String accountId,
  }) async {
    try {
      final password = await _secureStorage.read('$_passwordKeyPrefix$accountId');
      return Right(password);
    } catch (e) {
      return Left(CacheFailure('Failed to get account password: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccountPassword({
    required String accountId,
  }) async {
    try {
      await _secureStorage.delete('$_passwordKeyPrefix$accountId');
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete account password: $e'));
    }
  }

  /// Build IMAP search query from filters
  // ignore: unused_element
  String __buildSearchQuery(EmailFilterModel? filters) {
    if (filters == null) {
      return 'ALL';
    }

    final criteria = <String>[];

    // Date range filter
    if (filters.dateRange != null) {
      final sinceDate = filters.dateRange!.start;
      final beforeDate = filters.dateRange!.end.add(const Duration(days: 1));

      criteria
        ..add('SINCE ${sinceDate.day}-${_getMonthName(sinceDate.month)}-${sinceDate.year}')
        ..add('BEFORE ${beforeDate.day}-${_getMonthName(beforeDate.month)}-${beforeDate.year}');
    }

    // Search query filter
    if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
      criteria.add('OR SUBJECT "${filters.searchQuery}" BODY "${filters.searchQuery}"');
    }

    return criteria.isEmpty ? 'ALL' : criteria.join(' ');
  }

  /// Get month name for IMAP date format
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Convert MimeMessage to EmailMessageModel
  EmailMessageModel _convertMimeMessageToEmailMessage(
    MimeMessage mimeMessage,
    String accountId,
  ) {
    // Extract basic info
    final from = mimeMessage.from?.isNotEmpty ?? false
        ? mimeMessage.from!.first.email
        : 'unknown@example.com';
    final subject = mimeMessage.decodeSubject() ?? '(No Subject)';
    final date = mimeMessage.decodeDate() ?? DateTime.now();

    // Extract body (prefer plain text, fallback to HTML)
    final body = mimeMessage.decodeTextPlainPart() ?? mimeMessage.decodeTextHtmlPart() ?? '';

    // Extract attachments
    final attachments = <EmailAttachment>[];
    final parts = mimeMessage.allPartsFlat;

    for (final part in parts) {
      // Check if part is an attachment
      final contentDisposition = part.getHeaderValue('content-disposition');
      final isAttachment = contentDisposition?.toLowerCase().contains('attachment') ?? false;

      if (isAttachment) {
        final filename = part.decodeFileName() ?? 'attachment';
        final mimeType = part.mediaType.toString();
        final size = part.decodeContentText()?.length ?? 0;

        attachments.add(
          EmailAttachment(
            id: '${mimeMessage.guid ?? "email"}_${attachments.length}',
            fileName: filename,
            mimeType: mimeType,
            sizeInBytes: size,
          ),
        );
      }
    }

    // Detect email type and bank
    final emailType = _detectEmailType(subject, body);
    final bankName = _detectBankName(from, subject, body);

    // Generate unique ID from guid or use timestamp
    final emailId =
        mimeMessage.guid?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

    return EmailMessageModel(
      id: emailId,
      from: from,
      subject: subject,
      body: body,
      date: date,
      hasAttachment: attachments.isNotEmpty,
      attachments: attachments,
      isRead: mimeMessage.isSeen,
      emailType: emailType,
      bankName: bankName,
      accountId: accountId,
    );
  }

  /// Apply local filters to emails
  List<EmailMessageModel> _applyLocalFilters(
    List<EmailMessageModel> emails,
    EmailFilterModel filters,
  ) {
    var filtered = emails;

    // Filter by selected banks
    if (filters.selectedBanks.isNotEmpty) {
      filtered = filtered
          .where(
            (e) => e.bankName != null && filters.selectedBanks.contains(e.bankName),
          )
          .toList();
    }

    // Filter by email types
    if (filters.emailTypes.isNotEmpty) {
      filtered = filtered.where((e) => filters.emailTypes.contains(e.emailType)).toList();
    }

    // Filter by attachment
    if (!filters.includeAttachments) {
      filtered = filtered.where((e) => !e.hasAttachment).toList();
    }

    // Filter by unparsed only
    if (filters.onlyUnparsed) {
      filtered = filtered.where((e) => !e.isParsed).toList();
    }

    return filtered;
  }

  /// Detect email type from subject and body
  EmailType _detectEmailType(String subject, String body) {
    final lowerSubject = subject.toLowerCase();
    final lowerBody = body.toLowerCase();

    if (lowerSubject.contains('statement') || lowerBody.contains('statement')) {
      return EmailType.statement;
    }

    if (lowerSubject.contains('receipt') ||
        lowerSubject.contains('invoice') ||
        lowerBody.contains('receipt')) {
      return EmailType.receipt;
    }

    if (lowerSubject.contains('transaction') ||
        lowerSubject.contains('payment') ||
        lowerSubject.contains('debit') ||
        lowerSubject.contains('credit')) {
      return EmailType.notification;
    }

    return EmailType.other;
  }

  /// Detect bank name from sender, subject, and body
  String? _detectBankName(String from, String subject, String body) {
    final lowerFrom = from.toLowerCase();
    final lowerSubject = subject.toLowerCase();
    final lowerBody = body.toLowerCase();

    final bankPatterns = {
      'State Bank of India': ['sbi', 'statebankofindia'],
      'HDFC Bank': ['hdfc', 'hdfcbank'],
      'ICICI Bank': ['icici', 'icicibank'],
      'Axis Bank': ['axis', 'axisbank'],
      'Kotak Mahindra Bank': ['kotak', 'kotakbank'],
      'Bank of Baroda': ['baroda', 'bankofbaroda', 'bob'],
      'Punjab National Bank': ['pnb', 'punjabnationalbank'],
      'Canara Bank': ['canara', 'canarabank'],
      'Union Bank of India': ['union', 'unionbank'],
      'Yes Bank': ['yes', 'yesbank'],
      'IndusInd Bank': ['indusind', 'indusindbank'],
      'IDFC First Bank': ['idfc', 'idfcfirst'],
    };

    for (final entry in bankPatterns.entries) {
      for (final pattern in entry.value) {
        if (lowerFrom.contains(pattern) ||
            lowerSubject.contains(pattern) ||
            lowerBody.contains(pattern)) {
          return entry.key;
        }
      }
    }

    return null;
  }
}
