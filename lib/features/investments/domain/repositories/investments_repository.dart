import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/investment_model.dart';

/// Investments Repository Interface
/// Defines the contract for investments data operations
abstract class InvestmentsRepository {
  /// Get all investments for the current user
  Future<Either<Failure, List<InvestmentModel>>> getInvestments();

  /// Get investments summary (totals, overall returns, etc.)
  Future<Either<Failure, InvestmentSummary>> getInvestmentsSummary();

  /// Get a specific investment by ID
  Future<Either<Failure, InvestmentModel>> getInvestmentById(String id);

  /// Create a new investment
  Future<Either<Failure, InvestmentModel>> createInvestment(CreateInvestmentRequest request);

  /// Update an existing investment
  Future<Either<Failure, InvestmentModel>> updateInvestment(String id, CreateInvestmentRequest request);

  /// Delete an investment
  Future<Either<Failure, void>> deleteInvestment(String id);

  /// Get tax savings summary for a specific year
  Future<Either<Failure, TaxSavingsSummary>> getTaxSavings(String year);

  /// Sync current prices for market-linked investments
  Future<Either<Failure, void>> syncPrices();
}
