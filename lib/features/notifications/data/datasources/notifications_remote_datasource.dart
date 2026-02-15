import 'package:dartz/dartz.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

/// Notifications Remote DataSource Interface
/// Defines the contract for notification-related API operations
abstract class NotificationsRemoteDataSource {
  /// Get paginated notifications
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    int page = 1,
    int pageSize = 20,
    NotificationType? type,
  });

  /// Get unread notification count
  Future<Either<Failure, UnreadCountResponse>> getUnreadCount();

  /// Mark a notification as read
  Future<Either<Failure, NotificationModel>> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllAsRead();

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Register push notification token
  Future<Either<Failure, void>> registerPushToken(RegisterPushTokenRequest request);
}

/// Notifications Remote DataSource Implementation
class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  NotificationsRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    int page = 1,
    int pageSize = 20,
    NotificationType? type,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      if (type != null) 'type': type.value,
    };

    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.notifications,
      queryParameters: queryParams,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(NotificationsResponse.fromJson(data));
        }
        if (data is List) {
          return Right(
            NotificationsResponse(
              notifications:
                  data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList(),
              total: data.length,
              page: page,
              pageSize: pageSize,
              hasMore: false,
            ),
          );
        }
        return const Right(
          NotificationsResponse(
            notifications: [],
            total: 0,
            page: 1,
            pageSize: 20,
            hasMore: false,
          ),
        );
      },
    );
  }

  @override
  Future<Either<Failure, UnreadCountResponse>> getUnreadCount() async {
    final result = await _apiClient.get<dynamic>(
      ApiEndpoints.notificationsUnreadCount,
    );

    return result.fold(
      Left.new,
      (data) {
        if (data is Map<String, dynamic>) {
          return Right(UnreadCountResponse.fromJson(data));
        }
        return const Right(UnreadCountResponse(count: 0));
      },
    );
  }

  @override
  Future<Either<Failure, NotificationModel>> markAsRead(String notificationId) async {
    return _apiClient.post<NotificationModel>(
      ApiEndpoints.notificationRead(notificationId),
      fromJson: (json) => NotificationModel.fromJson(json! as Map<String, dynamic>),
    );
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    final result = await _apiClient.post(
      ApiEndpoints.notificationsReadAll,
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    final result = await _apiClient.delete(
      ApiEndpoints.notificationDelete(notificationId),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }

  @override
  Future<Either<Failure, void>> registerPushToken(RegisterPushTokenRequest request) async {
    final result = await _apiClient.post(
      ApiEndpoints.notificationsRegisterPush,
      data: request.toJson(),
    );

    return result.fold(
      Left.new,
      (_) => const Right(null),
    );
  }
}
