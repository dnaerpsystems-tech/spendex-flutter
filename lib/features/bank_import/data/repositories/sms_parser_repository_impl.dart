import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/sms_parser_repository.dart';
import '../datasources/sms_parser_local_datasource.dart';
import '../datasources/sms_parser_remote_datasource.dart';
import '../models/bank_config_model.dart';
import '../models/parsed_transaction_model.dart';
import '../models/sms_message_model.dart';

class SmsParserRepositoryImpl implements SmsParserRepository {
  SmsParserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );
  final SmsParserRemoteDataSource _remoteDataSource;
  final SmsParserLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, bool>> checkSmsPermissions() async {
    try {
      return await _localDataSource.checkPermissions();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestSmsPermissions() async {
    try {
      return await _localDataSource.requestPermissions();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SmsMessageModel>>> readSmsMessages(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final localResult = await _localDataSource.readSmsMessages(
        startDate,
        endDate,
      );

      return localResult.fold(
        Left.new,
        (messages) async {
          if (messages.isEmpty) {
            return Right(messages);
          }

          final syncResult = await _remoteDataSource.syncSmsMessages(messages);
          return syncResult.fold(
            (failure) => Right(messages),
            Right.new,
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParsedTransactionModel?>> parseSmsMessage(
    SmsMessageModel sms,
  ) async {
    try {
      return Right(sms.parsedTransaction);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  ) async {
    try {
      return await _remoteDataSource.bulkImportTransactions(transactions);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BankConfigModel>>> getBankConfigs() async {
    try {
      return await _remoteDataSource.getBankConfigs();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleSmsTracking({required bool enabled}) async {
    try {
      final localResult = await _localDataSource.setTrackingStatus(enabled: enabled);

      return localResult.fold(
        Left.new,
        (success) async {
          final remoteResult = await _remoteDataSource.toggleSmsTracking(
            enabled: enabled,
          );
          return remoteResult.fold(
            (failure) => Right(success),
            Right.new,
          );
        },
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
