import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/insight_model.dart';

/// Repository interface for managing financial insights and AI-generated recommendations.
///
/// This repository defines the contract for interacting with insights data,
/// including retrieving, generating, and managing insights. All methods return
/// [Either<Failure, T>] to handle errors gracefully using functional error handling.
abstract class InsightsRepository {
  /// Retrieves all available insights for the current user.
  ///
  /// This method fetches the complete list of insights, including both read
  /// and unread insights. The insights are typically ordered by creation date
  /// (newest first) or by priority.
  ///
  /// Returns:
  /// - [Right<List<InsightModel>>]: A list of all insights when successful.
  ///   The list may be empty if no insights are available.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [CacheFailure]: When local cache retrieval fails (if implemented).
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final result = await insightsRepository.getAll();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (insights) => print('Found ${insights.length} insights'),
  /// );
  /// ```
  Future<Either<Failure, List<InsightModel>>> getAll();

  /// Retrieves the top 3 most important insights for dashboard display.
  ///
  /// This method fetches a curated list of the most relevant insights to show
  /// on the dashboard. The selection is based on priority, recency, and whether
  /// the insight has been read or dismissed. Typically returns up to 3 insights.
  ///
  /// Returns:
  /// - [Right<List<InsightModel>>]: A list of up to 3 priority insights when successful.
  ///   The list may contain fewer than 3 items or be empty if insufficient insights exist.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [CacheFailure]: When local cache retrieval fails (if implemented).
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final result = await insightsRepository.getDashboardInsights();
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (insights) => displayOnDashboard(insights),
  /// );
  /// ```
  Future<Either<Failure, List<InsightModel>>> getDashboardInsights();

  /// Retrieves a specific insight by its unique identifier.
  ///
  /// This method fetches detailed information about a single insight using
  /// its ID. Useful for viewing full insight details or refreshing a specific
  /// insight's data.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the insight to retrieve. Must be a valid,
  ///   non-empty string representing an existing insight ID.
  ///
  /// Returns:
  /// - [Right<InsightModel>]: The requested insight when found successfully.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [NotFoundFailure]: When no insight exists with the given ID.
  /// - [ValidationFailure]: When the provided ID is invalid or empty.
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final result = await insightsRepository.getById('insight_123');
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (insight) => displayInsightDetails(insight),
  /// );
  /// ```
  Future<Either<Failure, InsightModel>> getById(String id);

  /// Triggers AI analysis to generate new insights based on user data.
  ///
  /// This method initiates an AI-powered analysis of the user's financial data
  /// to generate personalized insights and recommendations. The analysis can be
  /// customized through the request parameters (e.g., specific date ranges,
  /// categories, or analysis types).
  ///
  /// Parameters:
  /// - [request]: A [CreateInsightRequest] object containing parameters for
  ///   the insight generation process, such as date range, categories to analyze,
  ///   or specific insight types to generate.
  ///
  /// Returns:
  /// - [Right<List<InsightModel>>]: A list of newly generated insights when successful.
  ///   The list may be empty if no actionable insights were found.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [ValidationFailure]: When the request parameters are invalid.
  /// - [InsufficientDataFailure]: When there's not enough data to generate insights.
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  /// - [QuotaExceededFailure]: When AI generation limits have been reached.
  ///
  /// Example:
  /// ```dart
  /// final request = CreateInsightRequest(
  ///   startDate: DateTime.now().subtract(Duration(days: 30)),
  ///   endDate: DateTime.now(),
  /// );
  /// final result = await insightsRepository.generateInsights(request);
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (insights) => print('Generated ${insights.length} new insights'),
  /// );
  /// ```
  Future<Either<Failure, List<InsightModel>>> generateInsights(
    CreateInsightRequest request,
  );

  /// Marks a specific insight as read.
  ///
  /// This method updates the read status of an insight, typically updating
  /// the `isRead` flag and recording the timestamp when it was read. This helps
  /// track user engagement and prioritize unread insights.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the insight to mark as read. Must be a
  ///   valid, non-empty string representing an existing insight ID.
  ///
  /// Returns:
  /// - [Right<InsightModel>]: The updated insight with read status set to true.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [NotFoundFailure]: When no insight exists with the given ID.
  /// - [ValidationFailure]: When the provided ID is invalid or empty.
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final result = await insightsRepository.markAsRead('insight_123');
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (insight) => print('Insight marked as read at ${insight.readAt}'),
  /// );
  /// ```
  Future<Either<Failure, InsightModel>> markAsRead(String id);

  /// Dismisses an insight, removing it from the user's view.
  ///
  /// This method marks an insight as dismissed, effectively hiding it from
  /// the user's insight list. Dismissed insights are not deleted but are
  /// excluded from normal queries. This is useful when users want to hide
  /// insights that are not relevant to them.
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the insight to dismiss. Must be a valid,
  ///   non-empty string representing an existing insight ID.
  ///
  /// Returns:
  /// - [Right<bool>]: Returns `true` when the insight is successfully dismissed.
  /// - [Left<Failure>]: A failure object when the operation fails.
  ///
  /// Possible failures:
  /// - [ServerFailure]: When the server returns an error or is unreachable.
  /// - [NetworkFailure]: When there's no internet connection.
  /// - [NotFoundFailure]: When no insight exists with the given ID.
  /// - [ValidationFailure]: When the provided ID is invalid or empty.
  /// - [AuthFailure]: When the user's authentication token is invalid or expired.
  ///
  /// Example:
  /// ```dart
  /// final result = await insightsRepository.dismiss('insight_123');
  /// result.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (success) => print('Insight dismissed successfully'),
  /// );
  /// ```
  Future<Either<Failure, bool>> dismiss(String id);
}
