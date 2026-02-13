import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../../data/models/email_account_model.dart';
import '../../data/models/email_filter_model.dart';
import '../../data/models/email_message_model.dart';

abstract class EmailParserRepository {
  /// Connect email account
  Future<Either<Failure, EmailAccountModel>> connectAccount({
    required String email,
    required String password,
    EmailProvider? provider,
    String? imapServer,
    int? imapPort,
  });

  /// Disconnect email account
  Future<Either<Failure, bool>> disconnectAccount({
    required String accountId,
  });

  /// Get all connected email accounts
  Future<Either<Failure, List<EmailAccountModel>>> getAccounts();

  /// Fetch emails from account
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmails({
    required String accountId,
    EmailFilterModel? filters,
  });

  /// Parse single email to extract transaction
  Future<Either<Failure, ParsedTransactionModel?>> parseEmail({
    required String emailId,
  });

  /// Bulk parse multiple emails
  Future<Either<Failure, List<EmailMessageModel>>> bulkParseEmails({
    required List<EmailMessageModel> emails,
  });

  /// Get current filters
  Future<Either<Failure, EmailFilterModel>> getFilters();

  /// Update filters
  Future<Either<Failure, bool>> updateFilters({
    required EmailFilterModel filters,
  });

  /// Bulk import parsed transactions
  Future<Either<Failure, int>> bulkImportTransactions({
    required List<ParsedTransactionModel> transactions,
  });

  /// Import single parsed transaction
  Future<Either<Failure, bool>> importTransaction({
    required ParsedTransactionModel transaction,
  });

  /// Sync account status from backend
  Future<Either<Failure, EmailAccountModel>> syncAccountStatus({
    required String accountId,
  });

  /// Toggle email tracking for account
  Future<Either<Failure, bool>> toggleEmailTracking({
    required String accountId,
    required bool enabled,
  });

  /// Get cached emails
  Future<Either<Failure, List<EmailMessageModel>>> getCachedEmails({
    String? accountId,
  });

  /// Clear cache
  Future<Either<Failure, bool>> clearCache();

  /// Download email attachment
  Future<Either<Failure, File>> downloadAttachment({
    required String attachmentId,
    required String savePath,
    void Function(double progress)? onProgress,
  });
}
