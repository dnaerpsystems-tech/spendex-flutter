import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

/// Notifications Repository Implementation
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remoteDataSource);

  final NotificationsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, NotificationsResponse>> getNotifications({
    int page = 1,
    int pageSize = 20,
    NotificationType? type,
  }) {
    return _remoteDataSource.getNotifications(
      page: page,
      pageSize: pageSize,
      type: type,
    );
  }

  @override
  Future<Either<Failure, UnreadCountResponse>> getUnreadCount() {
    return _remoteDataSource.getUnreadCount();
  }

  @override
  Future<Either<Failure, NotificationModel>> markAsRead(String notificationId) {
    return _remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() {
    return _remoteDataSource.markAllAsRead();
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) {
    return _remoteDataSource.deleteNotification(notificationId);
  }

  @override
  Future<Either<Failure, void>> registerPushToken(RegisterPushTokenRequest request) {
    return _remoteDataSource.registerPushToken(request);
  }
}
