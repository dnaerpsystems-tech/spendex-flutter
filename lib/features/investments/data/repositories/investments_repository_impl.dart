import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/investments_repository.dart';
import '../datasources/investments_remote_datasource.dart';
import '../models/investment_model.dart';

/// Investments Repository Implementation
class InvestmentsRepositoryImpl implements InvestmentsRepository {
  InvestmentsRepositoryImpl(this._remoteDataSource);
  final InvestmentsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<InvestmentModel>>> getInvestments() {
    return _remoteDataSource.getInvestments();
  }

  @override
  Future<Either<Failure, InvestmentSummary>> getInvestmentsSummary() {
    return _remoteDataSource.getInvestmentsSummary();
  }

  @override
  Future<Either<Failure, InvestmentModel>> getInvestmentById(String id) {
    return _remoteDataSource.getInvestmentById(id);
  }

  @override
  Future<Either<Failure, InvestmentModel>> createInvestment(CreateInvestmentRequest request) {
    return _remoteDataSource.createInvestment(request);
  }

  @override
  Future<Either<Failure, InvestmentModel>> updateInvestment(
      String id, CreateInvestmentRequest request,) {
    return _remoteDataSource.updateInvestment(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteInvestment(String id) {
    return _remoteDataSource.deleteInvestment(id);
  }

  @override
  Future<Either<Failure, TaxSavingsSummary>> getTaxSavings(String year) {
    return _remoteDataSource.getTaxSavings(year);
  }

  @override
  Future<Either<Failure, void>> syncPrices() {
    return _remoteDataSource.syncPrices();
  }
}
