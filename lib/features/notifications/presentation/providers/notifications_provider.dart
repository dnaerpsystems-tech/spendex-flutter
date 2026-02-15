import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/notification_model.dart';
import '../../domain/repositories/notifications_repository.dart';

/// Notifications State
/// Manages the complete state for notifications feature
class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isMarkingRead = false,
    this.isMarkingAllRead = false,
    this.isDeleting = false,
    this.currentPage = 1,
    this.hasMore = true,
    this.filterType,
    this.error,
    this.successMessage,
  });

  const NotificationsState.initial()
      : notifications = const [],
        unreadCount = 0,
        isLoading = false,
        isLoadingMore = false,
        isMarkingRead = false,
        isMarkingAllRead = false,
        isDeleting = false,
        currentPage = 1,
        hasMore = true,
        filterType = null,
        error = null,
        successMessage = null;

  /// List of notifications
  final List<NotificationModel> notifications;

  /// Unread notification count
  final int unreadCount;

  /// Loading states
  final bool isLoading;
  final bool isLoadingMore;
  final bool isMarkingRead;
  final bool isMarkingAllRead;
  final bool isDeleting;

  /// Pagination
  final int currentPage;
  final bool hasMore;

  /// Filter by notification type
  final NotificationType? filterType;

  /// Error message
  final String? error;

  /// Success message for feedback
  final String? successMessage;

  /// Check if there are any notifications
  bool get hasNotifications => notifications.isNotEmpty;

  /// Check if there are unread notifications
  bool get hasUnread => unreadCount > 0;

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications =>
      notifications.where((n) => n.isRead == false).toList();

  /// Get read notifications
  List<NotificationModel> get readNotifications => notifications.where((n) => n.isRead).toList();

  /// Get high priority notifications
  List<NotificationModel> get highPriorityNotifications =>
      notifications.where((n) => n.isHighPriority).toList();

  /// Check if any operation is in progress
  bool get isOperationInProgress => isMarkingRead || isMarkingAllRead || isDeleting;

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isMarkingRead,
    bool? isMarkingAllRead,
    bool? isDeleting,
    int? currentPage,
    bool? hasMore,
    NotificationType? filterType,
    String? error,
    String? successMessage,
    bool clearFilterType = false,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMarkingRead: isMarkingRead ?? this.isMarkingRead,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      isDeleting: isDeleting ?? this.isDeleting,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        isLoading,
        isLoadingMore,
        isMarkingRead,
        isMarkingAllRead,
        isDeleting,
        currentPage,
        hasMore,
        filterType,
        error,
        successMessage,
      ];
}

/// Notifications State Notifier
/// Handles all notification-related operations and state management
class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier(this._repository) : super(const NotificationsState.initial());

  final NotificationsRepository _repository;

  /// Load notifications (initial load or with new filter)
  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.isLoading && refresh == false) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      currentPage: 1,
      hasMore: true,
      notifications: refresh ? [] : state.notifications,
    );

    final result = await _repository.getNotifications(
      type: state.filterType,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isLoading: false,
          notifications: response.notifications,
          currentPage: 1,
          hasMore: response.hasMore,
        );
      },
    );

    // Also refresh unread count
    unawaited(_loadUnreadCount());
  }

  /// Load more notifications (pagination)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasMore == false || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getNotifications(
      page: nextPage,
      type: state.filterType,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoadingMore: false,
          error: failure.message,
        );
      },
      (response) {
        state = state.copyWith(
          isLoadingMore: false,
          notifications: [...state.notifications, ...response.notifications],
          currentPage: nextPage,
          hasMore: response.hasMore,
        );
      },
    );
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Load unread count
  Future<void> _loadUnreadCount() async {
    final result = await _repository.getUnreadCount();

    result.fold(
      (failure) {
        // Silently fail for unread count
      },
      (response) {
        state = state.copyWith(unreadCount: response.count);
      },
    );
  }

  /// Refresh unread count (public method)
  Future<void> refreshUnreadCount() async {
    await _loadUnreadCount();
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    if (state.isMarkingRead) {
      return false;
    }

    // Find the notification
    final notificationIndex = state.notifications.indexWhere((n) => n.id == notificationId);
    if (notificationIndex == -1) {
      return false;
    }

    final notification = state.notifications[notificationIndex];
    if (notification.isRead) {
      return true; // Already read
    }

    state = state.copyWith(isMarkingRead: true, clearError: true);

    final result = await _repository.markAsRead(notificationId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMarkingRead: false,
          error: failure.message,
        );
        return false;
      },
      (updatedNotification) {
        final updatedNotifications = List<NotificationModel>.from(state.notifications);
        updatedNotifications[notificationIndex] = updatedNotification;

        state = state.copyWith(
          isMarkingRead: false,
          notifications: updatedNotifications,
          unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
        );
        return true;
      },
    );
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    if (state.isMarkingAllRead || state.unreadCount == 0) {
      return false;
    }

    state = state.copyWith(isMarkingAllRead: true, clearError: true);

    final result = await _repository.markAllAsRead();

    return result.fold(
      (failure) {
        state = state.copyWith(
          isMarkingAllRead: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final updatedNotifications = state.notifications
            .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();

        state = state.copyWith(
          isMarkingAllRead: false,
          notifications: updatedNotifications,
          unreadCount: 0,
          successMessage: 'All notifications marked as read',
        );
        return true;
      },
    );
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    if (state.isDeleting) {
      return false;
    }

    state = state.copyWith(isDeleting: true, clearError: true);

    final result = await _repository.deleteNotification(notificationId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isDeleting: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        final notification = state.notifications.firstWhere((n) => n.id == notificationId);
        final updatedNotifications =
            state.notifications.where((n) => n.id != notificationId).toList();
        final newUnreadCount = notification.isRead == false && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount;

        state = state.copyWith(
          isDeleting: false,
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
          successMessage: 'Notification deleted',
        );
        return true;
      },
    );
  }

  /// Set filter type
  void setFilter(NotificationType? type) {
    if (state.filterType == type) {
      return;
    }

    state = state.copyWith(
      filterType: type,
      clearFilterType: type == null,
    );

    loadNotifications(refresh: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear success message
  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }
}

/// Provider for notifications state
final notificationsStateProvider =
    StateNotifierProvider.autoDispose<NotificationsNotifier, NotificationsState>((ref) {
  final repository = getIt<NotificationsRepository>();
  return NotificationsNotifier(repository);
});

/// Provider for unread notification count
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsStateProvider.select((s) => s.unreadCount));
});

/// Provider to check if there are unread notifications
final hasUnreadProvider = Provider<bool>((ref) {
  return ref.watch(unreadCountProvider) > 0;
});

/// Provider for filtered notifications
final filteredNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  final state = ref.watch(notificationsStateProvider);
  return state.notifications;
});
