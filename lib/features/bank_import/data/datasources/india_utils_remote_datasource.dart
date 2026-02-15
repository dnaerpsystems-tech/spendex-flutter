import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/repositories/india_utils_repository.dart';
import '../models/ifsc_details_model.dart';

abstract class IndiaUtilsRemoteDataSource {
  Future<Either<Failure, IfscDetailsModel>> lookupIfsc(String ifscCode);

  Future<Either<Failure, bool>> validateUpi(String upiId);

  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();
}

class IndiaUtilsRemoteDataSourceImpl implements IndiaUtilsRemoteDataSource {
  IndiaUtilsRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, IfscDetailsModel>> lookupIfsc(String ifscCode) async {
    return _apiClient.get<IfscDetailsModel>(
      '/utils/ifsc/$ifscCode',
      fromJson: (json) => IfscDetailsModel.fromJson(
        json! as Map<String, dynamic>,
      ),
    );
  }

  @override
  Future<Either<Failure, bool>> validateUpi(String upiId) async {
    return _apiClient.post<bool>(
      '/utils/upi/validate',
      data: {'upiId': upiId},
      fromJson: (json) {
        if (json is bool) {
          return json;
        }
        if (json is Map<String, dynamic>) {
          return json['valid'] as bool? ?? false;
        }
        return false;
      },
    );
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    return _apiClient.get<List<PaymentMethod>>(
      '/utils/payment-methods',
      fromJson: (json) {
        if (json is List<dynamic>) {
          return json.map((e) {
            final name = e.toString();
            return PaymentMethod.values.firstWhere(
              (method) => method.name == name,
              orElse: () => PaymentMethod.cash,
            );
          }).toList();
        }
        return PaymentMethod.values;
      },
    );
  }
}
