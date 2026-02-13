import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/loan_model.dart';

/// Loans Repository Interface
/// Defines the contract for loans data operations
abstract class LoansRepository {
  /// Get all loans for the current user
  Future<Either<Failure, List<LoanModel>>> getLoans();

  /// Get loans summary (totals, overall stats, etc.)
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
