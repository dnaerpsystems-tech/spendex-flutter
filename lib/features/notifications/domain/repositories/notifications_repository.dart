import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';

/// Notifications Repository Interface
/// Defines the contract for notification data operations
abstract class NotificationsRepository {
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
