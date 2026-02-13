import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/bank_config_model.dart';
import '../models/parsed_transaction_model.dart';
import '../models/sms_message_model.dart';

abstract class SmsParserRemoteDataSource {
  Future<Either<Failure, List<SmsMessageModel>>> syncSmsMessages(
    List<SmsMessageModel> messages,
  );

  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  );

  Future<Either<Failure, List<BankConfigModel>>> getBankConfigs();

  Future<Either<Failure, bool>> toggleSmsTracking(bool enabled);
}

class SmsParserRemoteDataSourceImpl implements SmsParserRemoteDataSource {

  SmsParserRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<SmsMessageModel>>> syncSmsMessages(
    List<SmsMessageModel> messages,
  ) async {
    return _apiClient.post<List<SmsMessageModel>>(
      '/sms/sync',
      data: {
        'messages': messages.map((m) => m.toJson()).toList(),
      },
      fromJson: (json) {
        final list = json! as List<dynamic>;
        return list
            .map((e) => SmsMessageModel.fromJson(
                  e as Map<String, dynamic>,
                ),)
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, int>> bulkImportTransactions(
    List<ParsedTransactionModel> transactions,
  ) async {
    return _apiClient.post<int>(
      '/transactions/bulk-import',
      data: {
        'transactions': transactions.map((t) => t.toJson()).toList(),
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
  Future<Either<Failure, List<BankConfigModel>>> getBankConfigs() async {
    return _apiClient.get<List<BankConfigModel>>(
      '/sms/bank-configs',
      fromJson: (json) {
        final list = json! as List<dynamic>;
        return list
            .map((e) => BankConfigModel.fromJson(
                  e as Map<String, dynamic>,
                ),)
            .toList();
      },
    );
  }

  @override
  Future<Either<Failure, bool>> toggleSmsTracking(bool enabled) async {
    return _apiClient.put<bool>(
      '/sms/tracking',
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
}
