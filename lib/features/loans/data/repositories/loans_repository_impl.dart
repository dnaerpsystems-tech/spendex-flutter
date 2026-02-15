import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/repositories/loans_repository.dart';
import '../datasources/loans_remote_datasource.dart';
import '../models/loan_model.dart';

/// Loans Repository Implementation
class LoansRepositoryImpl implements LoansRepository {
  LoansRepositoryImpl(this._remoteDataSource);
  final LoansRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, List<LoanModel>>> getLoans() {
    return _remoteDataSource.getLoans();
  }

  @override
  Future<Either<Failure, LoansSummary>> getLoansSummary() {
    return _remoteDataSource.getLoansSummary();
  }

  @override
  Future<Either<Failure, LoanModel>> getLoanById(String id) {
    return _remoteDataSource.getLoanById(id);
  }

  @override
  Future<Either<Failure, LoanModel>> createLoan(CreateLoanRequest request) {
    return _remoteDataSource.createLoan(request);
  }

  @override
  Future<Either<Failure, LoanModel>> updateLoan(String id, CreateLoanRequest request) {
    return _remoteDataSource.updateLoan(id, request);
  }

  @override
  Future<Either<Failure, void>> deleteLoan(String id) {
    return _remoteDataSource.deleteLoan(id);
  }

  @override
  Future<Either<Failure, LoanModel>> recordEmiPayment(String id, EmiPaymentRequest request) {
    return _remoteDataSource.recordEmiPayment(id, request);
  }
}
