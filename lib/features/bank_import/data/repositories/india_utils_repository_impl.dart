import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/india_utils_repository.dart';
import '../datasources/india_utils_remote_datasource.dart';
import '../models/ifsc_details_model.dart';

class IndiaUtilsRepositoryImpl implements IndiaUtilsRepository {

  IndiaUtilsRepositoryImpl(this._remoteDataSource);
  final IndiaUtilsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, IfscDetailsModel>> lookupIfsc(String ifscCode) async {
    try {
      if (ifscCode.isEmpty || ifscCode.length != 11) {
        return const Left(
          ValidationFailure(
            'Invalid IFSC code. It should be 11 characters long.',
            code: 'INVALID_IFSC',
          ),
        );
      }

      return await _remoteDataSource.lookupIfsc(ifscCode.toUpperCase());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> validateUpi(String upiId) async {
    try {
      if (upiId.isEmpty || !upiId.contains('@')) {
        return const Left(
          ValidationFailure(
            'Invalid UPI ID format. It should contain @ symbol.',
            code: 'INVALID_UPI',
          ),
        );
      }

      return await _remoteDataSource.validateUpi(upiId.toLowerCase());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods() async {
    try {
      return await _remoteDataSource.getPaymentMethods();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
