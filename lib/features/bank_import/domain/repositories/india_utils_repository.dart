import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/ifsc_details_model.dart';

enum PaymentMethod {
  upi,
  neft,
  rtgs,
  imps,
  card,
  netbanking,
  cash,
}

abstract class IndiaUtilsRepository {
  Future<Either<Failure, IfscDetailsModel>> lookupIfsc(String ifscCode);

  Future<Either<Failure, bool>> validateUpi(String upiId);

  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods();
}
