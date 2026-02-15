import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../../bank_import/data/models/parsed_transaction_model.dart';
import '../../../bank_import/data/models/sms_message_model.dart';
import '../../domain/repositories/email_parser_repository.dart';
import '../datasources/email_local_datasource.dart';
import '../datasources/email_remote_datasource.dart';
import '../models/email_account_model.dart';
import '../models/email_filter_model.dart';
import '../models/email_message_model.dart';

class EmailParserRepositoryImpl implements EmailParserRepository {
  EmailParserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );
  final EmailRemoteDataSource _remoteDataSource;
  final EmailLocalDataSource _localDataSource;
  // ignore: unused_field
  final Uuid _uuid = const Uuid();

  // ignore: unused_field
  static const String _filtersKey = 'email_parser_filters';

  @override
  Future<Either<Failure, EmailAccountModel>> connectAccount({
    required String email,
    required String password,
    EmailProvider? provider,
    String? imapServer,
    int? imapPort,
  }) async {
    try {
      // Auto-detect provider if not specified
      final detectedProvider = provider ?? EmailAccountModel.detectProvider(email);

      // Get default IMAP config if not provided
      final defaultConfig = EmailAccountModel.getDefaultImapConfig(detectedProvider);

      final finalImapServer = imapServer ?? defaultConfig['imapServer'] as String;
      final finalImapPort = imapPort ?? defaultConfig['imapPort'] as int;

      // Connect to backend first
      final remoteResult = await _remoteDataSource.connectEmailAccount(
        email: email,
        password: password,
        provider: detectedProvider,
        imapServer: finalImapServer,
        imapPort: finalImapPort,
      );

      return remoteResult.fold(
        Left.new,
        (account) async {
          // Save password locally for IMAP access
          await _localDataSource.saveAccountPassword(
            accountId: account.id,
            password: password,
          );

          // Cache account locally
          final cachedAccountsResult = await _localDataSource.getCachedAccounts();

          await cachedAccountsResult.fold(
            (failure) => Future.value(),
            (cachedAccounts) async {
              final updatedAccounts = [...cachedAccounts, account];
              await _localDataSource.cacheEmailAccounts(updatedAccounts);
            },
          );

          return Right(account);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectAccount({
    required String accountId,
  }) async {
    try {
      // Disconnect from backend
      final remoteResult = await _remoteDataSource.disconnectAccount(
        accountId: accountId,
      );

      return remoteResult.fold(
        Left.new,
        (success) async {
          // Delete password
          await _localDataSource.deleteAccountPassword(accountId: accountId);

          // Clear cached emails for this account
          await _localDataSource.clearEmailsForAccount(accountId);

          // Remove from cached accounts
          final cachedAccountsResult = await _localDataSource.getCachedAccounts();

          await cachedAccountsResult.fold(
            (failure) => Future.value(),
            (cachedAccounts) async {
              final updatedAccounts = cachedAccounts.where((a) => a.id != accountId).toList();
              await _localDataSource.cacheEmailAccounts(updatedAccounts);
            },
          );

          return Right(success);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmailAccountModel>>> getAccounts() async {
    try {
      // Try to get from backend first
      final remoteResult = await _remoteDataSource.getConnectedAccounts();

      return remoteResult.fold(
        (failure) async {
          // If remote fails, try to get from cache
          final cachedResult = await _localDataSource.getCachedAccounts();
          return cachedResult.fold(
            (cacheFailure) => Left(failure), // Return original failure
            Right.new,
          );
        },
        (accounts) async {
          // Cache the accounts
          await _localDataSource.cacheEmailAccounts(accounts);
          return Right(accounts);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> fetchEmails({
    required String accountId,
    EmailFilterModel? filters,
  }) async {
    try {
      // Get account details
      final accountsResult = await getAccounts();

      return accountsResult.fold(
        Left.new,
        (accounts) async {
          final account = accounts.where((a) => a.id == accountId).firstOrNull;

          if (account == null) {
            return const Left(
              ValidationFailure(
                'Account not found',
                code: 'ACCOUNT_NOT_FOUND',
              ),
            );
          }

          // Get password
          final passwordResult = await _localDataSource.getAccountPassword(
            accountId: accountId,
          );

          return passwordResult.fold(
            Left.new,
            (password) async {
              if (password == null) {
                return const Left(
                  AuthFailure(
                    'Account password not found',
                    code: 'PASSWORD_NOT_FOUND',
                  ),
                );
              }

              // Fetch from IMAP directly
              final imapResult = await _localDataSource.fetchEmailsFromImap(
                account: account,
                password: password,
                filters: filters,
              );

              return imapResult.fold(
                Left.new,
                (emails) async {
                  // Cache emails
                  await _localDataSource.cacheEmails(emails);
                  return Right(emails);
                },
              );
            },
          );
        },
      );
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsedTransactionModel?>> parseEmail({
    required String emailId,
  }) async {
    try {
      return await _remoteDataSource.parseEmailTransaction(
        emailId: emailId,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> bulkParseEmails({
    required List<EmailMessageModel> emails,
  }) async {
    try {
      final parsedEmails = <EmailMessageModel>[];

      for (final email in emails) {
        // Skip already parsed
        if (email.isParsed) {
          parsedEmails.add(email);
          continue;
        }

        // Parse email
        final parseResult = await parseEmail(emailId: email.id);

        final parsedEmail = parseResult.fold(
          (failure) => email.copyWith(
            parseStatus: ParseStatus.failed,
            isParsed: true,
          ),
          (transaction) {
            if (transaction != null) {
              return email.copyWith(
                parseStatus: ParseStatus.parsed,
                isParsed: true,
                parsedTransaction: transaction,
              );
            } else {
              return email.copyWith(
                parseStatus: ParseStatus.failed,
                isParsed: true,
              );
            }
          },
        );

        parsedEmails.add(parsedEmail);
      }

      // Update cache
      await _localDataSource.cacheEmails(parsedEmails);

      return Right(parsedEmails);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmailFilterModel>> getFilters() async {
    try {
      // For now, return default filter
      // In future, can load from local storage or backend
      return Right(EmailFilterModel.defaultFilter());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateFilters({
    required EmailFilterModel filters,
  }) async {
    try {
      // For now, just return success
      // In future, can save to local storage or backend
      return const Right(true);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions({
    required List<ParsedTransactionModel> transactions,
  }) async {
    try {
      return await _remoteDataSource.bulkImportTransactions(
        transactions: transactions,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> importTransaction({
    required ParsedTransactionModel transaction,
  }) async {
    try {
      return await _remoteDataSource.importTransaction(
        transaction: transaction,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmailAccountModel>> syncAccountStatus({
    required String accountId,
  }) async {
    try {
      final remoteResult = await _remoteDataSource.syncAccountStatus(
        accountId: accountId,
      );

      return remoteResult.fold(
        Left.new,
        (account) async {
          // Update cache
          final cachedAccountsResult = await _localDataSource.getCachedAccounts();

          await cachedAccountsResult.fold(
            (failure) => Future.value(),
            (cachedAccounts) async {
              final updatedAccounts = cachedAccounts.map((a) {
                return a.id == accountId ? account : a;
              }).toList();
              await _localDataSource.cacheEmailAccounts(updatedAccounts);
            },
          );

          return Right(account);
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleEmailTracking({
    required String accountId,
    required bool enabled,
  }) async {
    try {
      return await _remoteDataSource.toggleEmailTracking(
        accountId: accountId,
        enabled: enabled,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<EmailMessageModel>>> getCachedEmails({
    String? accountId,
  }) async {
    try {
      return await _localDataSource.getCachedEmails(accountId: accountId);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> clearCache() async {
    try {
      return await _localDataSource.clearCache();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, File>> downloadAttachment({
    required String attachmentId,
    required String savePath,
    void Function(double progress)? onProgress,
  }) async {
    try {
      return await _remoteDataSource.downloadAttachment(
        attachmentId: attachmentId,
        savePath: savePath,
        onProgress: onProgress,
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
