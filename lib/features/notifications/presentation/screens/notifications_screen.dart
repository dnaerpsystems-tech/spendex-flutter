import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../../data/models/notification_model.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notification_tile.dart';

/// Notifications screen with filtering and infinite scroll
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsStateProvider.notifier).loadNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsStateProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(notificationsStateProvider);

    // Listen for success messages
    ref.listen<NotificationsState>(notificationsStateProvider, (prev, next) {
      if (next.successMessage != null &&
          prev?.successMessage != next.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? ''),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.primary,
          ),
        );
        ref.read(notificationsStateProvider.notifier).clearSuccessMessage();
      }

      if (next.error != null && prev?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error ?? ''),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SpendexColors.expense,
          ),
        );
        ref.read(notificationsStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark
          ? SpendexColors.darkBackground
          : SpendexColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? SpendexColors.darkSurface
            : SpendexColors.lightSurface,
        elevation: 0,
        title: Text(
          'Notifications',
          style: SpendexTheme.headlineMedium.copyWith(
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left,
            color: isDark
                ? SpendexColors.darkTextPrimary
                : SpendexColors.lightTextPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Filter button
          PopupMenuButton<NotificationType?>(
            icon: Icon(
              state.filterType != null ? Iconsax.filter5 : Iconsax.filter,
              color: state.filterType != null
                  ? SpendexColors.primary
                  : (isDark
                      ? SpendexColors.darkTextSecondary
                      : SpendexColors.lightTextSecondary),
            ),
            tooltip: 'Filter by type',
            onSelected: (type) {
              ref.read(notificationsStateProvider.notifier).setFilter(type);
            },
            itemBuilder: (context) => [
              PopupMenuItem<NotificationType?>(
                value: null,
                child: Row(
                  children: [
                    Icon(
                      Iconsax.category,
                      size: 20,
                      color: state.filterType == null
                          ? SpendexColors.primary
                          : (isDark
                              ? SpendexColors.darkTextSecondary
                              : SpendexColors.lightTextSecondary),
                    ),
                    const SizedBox(width: SpendexTheme.spacingSm),
                    Text(
                      'All notifications',
                      style: SpendexTheme.bodyMedium.copyWith(
                        color: state.filterType == null
                            ? SpendexColors.primary
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...NotificationType.values.map((type) => PopupMenuItem<NotificationType>(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          _getIconForType(type),
                          size: 20,
                          color: state.filterType == type
                              ? SpendexColors.primary
                              : (isDark
                                  ? SpendexColors.darkTextSecondary
                                  : SpendexColors.lightTextSecondary),
                        ),
                        const SizedBox(width: SpendexTheme.spacingSm),
                        Text(
                          type.label,
                          style: SpendexTheme.bodyMedium.copyWith(
                            color: state.filterType == type
                                ? SpendexColors.primary
                                : null,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),

          // Mark all as read
          if (state.hasUnread)
            IconButton(
              icon: state.isMarkingAllRead
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isDark
                            ? SpendexColors.darkTextSecondary
                            : SpendexColors.lightTextSecondary,
                      ),
                    )
                  : Icon(
                      Iconsax.tick_circle,
                      color: isDark
                          ? SpendexColors.darkTextSecondary
                          : SpendexColors.lightTextSecondary,
                    ),
              tooltip: 'Mark all as read',
              onPressed: state.isMarkingAllRead
                  ? null
                  : () {
                      ref
                          .read(notificationsStateProvider.notifier)
                          .markAllAsRead();
                    },
            ),
          const SizedBox(width: SpendexTheme.spacingSm),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: SpendexColors.primary,
          unselectedLabelColor: isDark
              ? SpendexColors.darkTextSecondary
              : SpendexColors.lightTextSecondary,
          indicatorColor: SpendexColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('All'),
                  if (state.notifications.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SpendexColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${state.notifications.length}',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: SpendexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unread'),
                  if (state.unreadCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SpendexColors.expense.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${state.unreadCount}',
                        style: SpendexTheme.labelSmall.copyWith(
                          color: SpendexColors.expense,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All notifications tab
          _buildNotificationsList(
            state: state,
            notifications: state.notifications,
            isDark: isDark,
          ),

          // Unread notifications tab
          _buildNotificationsList(
            state: state,
            notifications: state.unreadNotifications,
            isDark: isDark,
            emptyMessage: 'No unread notifications',
            emptyIcon: Iconsax.tick_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList({
    required NotificationsState state,
    required List<NotificationModel> notifications,
    required bool isDark,
    String? emptyMessage,
    IconData? emptyIcon,
  }) {
    // Initial loading state
    if (state.isLoading && notifications.isEmpty) {
      return ListView.builder(
        itemCount: 8,
        itemBuilder: (context, index) => const NotificationTileSkeleton(),
      );
    }

    // Empty state
    if (notifications.isEmpty) {
      return _buildEmptyState(
        isDark: isDark,
        message: emptyMessage ?? 'No notifications yet',
        icon: emptyIcon ?? Iconsax.notification_bing,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationsStateProvider.notifier).refresh();
      },
      color: SpendexColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index == notifications.length) {
            return Padding(
              padding: const EdgeInsets.all(SpendexTheme.spacingLg),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark
                        ? SpendexColors.darkTextTertiary
                        : SpendexColors.lightTextTertiary,
                  ),
                ),
              ),
            );
          }

          final notification = notifications[index];
          return NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
            onDismissed: () {
              ref
                  .read(notificationsStateProvider.notifier)
                  .deleteNotification(notification.id);
            },
            onMarkAsRead: () {
              ref
                  .read(notificationsStateProvider.notifier)
                  .markAsRead(notification.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required bool isDark,
    required String message,
    required IconData icon,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpendexTheme.spacing3xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark
                        ? SpendexColors.darkBorder
                        : SpendexColors.lightBorder)
                    .withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: SpendexTheme.spacingLg),
            Text(
              message,
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark
                    ? SpendexColors.darkTextSecondary
                    : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpendexTheme.spacingSm),
            Text(
              "We'll notify you when something important happens",
              style: SpendexTheme.bodySmall.copyWith(
                color: isDark
                    ? SpendexColors.darkTextTertiary
                    : SpendexColors.lightTextTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification action
    if (notification.action == null ||
        notification.action == NotificationAction.none) {
      return;
    }

    // Deep link handling would go here
    // For now, just mark as read
    if (notification.isRead == false) {
      ref
          .read(notificationsStateProvider.notifier)
          .markAsRead(notification.id);
    }
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return Iconsax.receipt_2;
      case NotificationType.budget:
        return Iconsax.chart;
      case NotificationType.goal:
        return Iconsax.flag;
      case NotificationType.family:
        return Iconsax.people;
      case NotificationType.loan:
        return Iconsax.bank;
      case NotificationType.investment:
        return Iconsax.trend_up;
      case NotificationType.system:
        return Iconsax.setting_2;
      case NotificationType.reminder:
        return Iconsax.clock;
      case NotificationType.alert:
        return Iconsax.notification;
    }
  }
}
