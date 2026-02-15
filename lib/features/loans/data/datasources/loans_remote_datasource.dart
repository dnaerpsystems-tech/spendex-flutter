import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/loan_model.dart';

/// Loans Remote Data Source Interface
abstract class LoansRemoteDataSource {
  /// Get all loans
  Future<Either<Failure, List<LoanModel>>> getLoans();

  /// Get loans summary
  Future<Either<Failure, LoansSummary>> getLoansSummary();

  /// Get a specific loan by ID
  Future<Either<Failure, LoanModel>> getLoanById(String id);

  /// Create a new loan
  Future<Either<Failure, LoanModel>> createLoan(CreateLoanRequest request);

  /// Update an existing loan
  Future<Either<Failure, LoanModel>> updateLoan(String id, CreateLoanRequest request);

  /// Delete a loan
  Future<Either<Failure, void>> deleteLoan(String id);

  /// Record EMI payment for a loan
  Future<Either<Failure, LoanModel>> recordEmiPayment(String id, EmiPaymentRequest request);
}

/// Loans Remote Data Source Implementation
class LoansRemoteDataSourceImpl implements LoansRemoteDataSource {
  LoansRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<LoanModel>>> getLoans() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.loans,
    );

    return result.fold(
      Left.new,
      (data) {
        final loans = data.map((json) => LoanModel.fromJson(json as Map<String, dynamic>)).toList();
        return Right(loans);
      },
    );
  }

  @override
  Future<Either<Failure, LoansSummary>> getLoansSummary() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.loansSummary,
    );

    return result.fold(
      Left.new,
      (data) {
        final summary = LoansSummary.fromJson(data);
        return Right(summary);
      },
    );
  }

  @override
  Future<Either<Failure, LoanModel>> getLoanById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.loanById(id),
    );

    return result.fold(
      Left.new,
      (data) {
        final loan = LoanModel.fromJson(data);
        return Right(loan);
      },
    );
  }

  @override
  Future<Either<Failure, LoanModel>> createLoan(CreateLoanRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.loans,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final loan = LoanModel.fromJson(data);
        return Right(loan);
      },
    );
  }

  @override
  Future<Either<Failure, LoanModel>> updateLoan(String id, CreateLoanRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.loanById(id),
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final loan = LoanModel.fromJson(data);
        return Right(loan);
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteLoan(String id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.loanById(id),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, LoanModel>> recordEmiPayment(String id, EmiPaymentRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.loanEmiPayment(id),
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final loan = LoanModel.fromJson(data);
        return Right(loan);
      },
    );
  }
}
