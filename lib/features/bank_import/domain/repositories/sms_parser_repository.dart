import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/bank_config_model.dart';
import '../../data/models/parsed_transaction_model.dart';
import '../../data/models/sms_message_model.dart';

abstract class SmsParserRepository {
  Future<Either<Failure, bool>> checkSmsPermissions();

  Future<Either<Failure, bool>> requestSmsPermissions();

  Future<Either<Failure, List<SmsMessageModel>>> readSmsMessages(
    DateTime startDate,
    DateTime endDate,
  );

  Future<Either<Failure, ParsedTransactionModel?>> parseSmsMessage(
    SmsMessageModel sms,
  );

  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  );

  Future<Either<Failure, List<BankConfigModel>>> getBankConfigs();

  Future<Either<Failure, bool>> toggleSmsTracking(bool enabled);
}
