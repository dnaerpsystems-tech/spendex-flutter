import 'package:dartz/dartz.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/investment_model.dart';

/// Investments Remote Data Source Interface
abstract class InvestmentsRemoteDataSource {
  /// Get all investments
  Future<Either<Failure, List<InvestmentModel>>> getInvestments();

  /// Get investments summary
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

/// Investments Remote Data Source Implementation
class InvestmentsRemoteDataSourceImpl implements InvestmentsRemoteDataSource {

  InvestmentsRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<Either<Failure, List<InvestmentModel>>> getInvestments() async {
    final result = await _apiClient.get<List<dynamic>>(
      ApiEndpoints.investments,
    );

    return result.fold(
      Left.new,
      (data) {
        final investments = data
            .map((json) => InvestmentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(investments);
      },
    );
  }

  @override
  Future<Either<Failure, InvestmentSummary>> getInvestmentsSummary() async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.investmentsSummary,
    );

    return result.fold(
      Left.new,
      (data) {
        final summary = InvestmentSummary.fromJson(data);
        return Right(summary);
      },
    );
  }

  @override
  Future<Either<Failure, InvestmentModel>> getInvestmentById(String id) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.investmentById(id),
    );

    return result.fold(
      Left.new,
      (data) {
        final investment = InvestmentModel.fromJson(data);
        return Right(investment);
      },
    );
  }

  @override
  Future<Either<Failure, InvestmentModel>> createInvestment(CreateInvestmentRequest request) async {
    final result = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.investments,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final investment = InvestmentModel.fromJson(data);
        return Right(investment);
      },
    );
  }

  @override
  Future<Either<Failure, InvestmentModel>> updateInvestment(String id, CreateInvestmentRequest request) async {
    final result = await _apiClient.put<Map<String, dynamic>>(
      ApiEndpoints.investmentById(id),
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (data) {
        final investment = InvestmentModel.fromJson(data);
        return Right(investment);
      },
    );
  }

  @override
  Future<Either<Failure, void>> deleteInvestment(String id) async {
    final result = await _apiClient.delete<dynamic>(
      ApiEndpoints.investmentById(id),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, TaxSavingsSummary>> getTaxSavings(String year) async {
    final result = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.investmentsTax(year),
    );

    return result.fold(
      Left.new,
      (data) {
        final taxSavings = TaxSavingsSummary.fromJson(data);
        return Right(taxSavings);
      },
    );
  }

  @override
  Future<Either<Failure, void>> syncPrices() async {
    final result = await _apiClient.post<dynamic>(
      ApiEndpoints.investmentsSyncPrices,
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }
}
