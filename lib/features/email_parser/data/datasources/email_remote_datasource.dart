import 'dart:io';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../models/email_account_model.dart';
import '../models/email_filter_model.dart';
import '../models/email_message_model.dart';

abstract class EmailRemoteDataSource {
  /// Connect email account and save to backend
  Future<Either<Failure, EmailAccountModel>> connectEmailAccount({
    required String email,
    required String password,
    required EmailProvider provider,
    String? imapServer,
    int? imapPort,
  });

  /// Fetch emails from backend (previously synced)
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmails({
    required String accountId,
    EmailFilterModel? filters,
  });

  /// Parse email to extract transaction
  Future<Either<Failure, ParsedTransactionModel?>> parseEmailTransaction({
    required String emailId,
  });

  /// Disconnect email account
  Future<Either<Failure, bool>> disconnectAccount({
    required String accountId,
  });

  /// Sync email account status
  Future<Either<Failure, EmailAccountModel>> syncAccountStatus({
    required String accountId,
  });

  /// Get all connected email accounts
  Future<Either<Failure, List<EmailAccountModel>>> getConnectedAccounts();

  /// Bulk import parsed transactions
  Future<Either<Failure, int>> bulkImportTransactions({
    required List<ParsedTransactionModel> transactions,
  });

  /// Import single parsed transaction
  Future<Either<Failure, bool>> importTransaction({
    required ParsedTransactionModel transaction,
  });

  /// Toggle email tracking
  Future<Either<Failure, bool>> toggleEmailTracking({
    required String accountId,
    required bool enabled,
  });

  /// Download email attachment
  Future<Either<Failure, File>> downloadAttachment({
    required String attachmentId,
    required String savePath,
    void Function(double progress)? onProgress,
  });
}

class EmailRemoteDataSourceImpl implements EmailRemoteDataSource {
  final ApiClient _apiClient;

  EmailRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Either<Failure, EmailAccountModel>> connectEmailAccount({
    required String email,
    required String password,
    required EmailProvider provider,
    String? imapServer,
    int? imapPort,
  }) async {
    return _apiClient.post<EmailAccountModel>(
      '/email/connect',
      data: {
        'email': email,
        'password': password,
        'provider': provider.name,
        'imapServer': imapServer,
        'imapPort': imapPort,
      },
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return EmailAccountModel.fromJson(json);
        }
        throw const FormatException('Invalid email account response format');
      },
    );
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmails({
    required String accountId,
    EmailFilterModel? filters,
  }) async {
    return _apiClient.post<List<EmailMessageModel>>(
      '/email/fetch',
      data: {
        'accountId': accountId,
        'filters': filters?.toJson(),
      },
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => EmailMessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, ParsedTransactionModel?>> parseEmailTransaction({
    required String emailId,
  }) async {
    return _apiClient.post<ParsedTransactionModel?>(
      '/email/parse',
      data: {
        'emailId': emailId,
      },
      fromJson: (json) {
        if (json == null) return null;
        if (json is Map<String, dynamic>) {
          return ParsedTransactionModel.fromJson(json);
        }
        return null;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> disconnectAccount({
    required String accountId,
  }) async {
    return _apiClient.delete<bool>(
      '/email/disconnect/$accountId',
      fromJson: (json) {
        if (json is bool) return json;
        if (json is Map<String, dynamic>) {
          return json['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  @override
  Future<Either<Failure, EmailAccountModel>> syncAccountStatus({
    required String accountId,
  }) async {
    return _apiClient.get<EmailAccountModel>(
      '/email/accounts/$accountId/sync',
      fromJson: (json) {
        if (json is Map<String, dynamic>) {
          return EmailAccountModel.fromJson(json);
        }
        throw const FormatException('Invalid email account response format');
      },
    );
  }

  @override
  Future<Either<Failure, List<EmailAccountModel>>> getConnectedAccounts() async {
    return _apiClient.get<List<EmailAccountModel>>(
      '/email/accounts',
      fromJson: (json) {
        final list = json as List<dynamic>;
        return list
            .map((e) => EmailAccountModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions({
    required List<ParsedTransactionModel> transactions,
  }) async {
    return _apiClient.post<int>(
      '/transactions/bulk-import',
      data: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'source': 'email',
      },
      fromJson: (json) {
        if (json is int) return json;
        if (json is Map<String, dynamic>) {
          return (json['count'] as num?)?.toInt() ?? 0;
        }
        return 0;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> importTransaction({
    required ParsedTransactionModel transaction,
  }) async {
    return _apiClient.post<bool>(
      '/transactions/import',
      data: {
        'transaction': transaction.toJson(),
        'source': 'email',
      },
      fromJson: (json) {
        if (json is bool) return json;
        if (json is Map<String, dynamic>) {
          return json['success'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  @override
  Future<Either<Failure, bool>> toggleEmailTracking({
    required String accountId,
    required bool enabled,
  }) async {
    return _apiClient.put<bool>(
      '/email/accounts/$accountId/tracking',
      data: {'enabled': enabled},
      fromJson: (json) {
        if (json is bool) return json;
        if (json is Map<String, dynamic>) {
          return json['enabled'] as bool? ?? false;
        }
        return enabled;
      },
    );
  }

  @override
  Future<Either<Failure, File>> downloadAttachment({
    required String attachmentId,
    required String savePath,
    void Function(double progress)? onProgress,
  }) async {
    return _apiClient.downloadFile(
      '/email/attachments/$attachmentId/download',
      savePath,
      onReceiveProgress: (received, total) {
        if (onProgress != null && total > 0) {
          final progress = received / total;
          onProgress(progress);
        }
      },
    );
  }
}
