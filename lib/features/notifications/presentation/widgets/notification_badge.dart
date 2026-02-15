import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../app/theme.dart';
import '../providers/notifications_provider.dart';

/// Notification badge widget showing unread count
class NotificationBadge extends ConsumerWidget {
  const NotificationBadge({
    required this.child,
    super.key,
    this.offset = Offset.zero,
    this.showZero = false,
  });

  final Widget child;
  final Offset offset;
  final bool showZero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);

    if (unreadCount == 0 && showZero == false) {
      return child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: offset.dx,
          top: offset.dy,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            decoration: BoxDecoration(
              color: SpendexColors.expense,
              borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: SpendexColors.expense.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: SpendexTheme.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Notification icon button for AppBar
class NotificationIconButton extends ConsumerWidget {
  const NotificationIconButton({
    super.key,
    this.onPressed,
    this.color,
  });

  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = ref.watch(hasUnreadProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            hasUnread ? Iconsax.notification5 : Iconsax.notification,
            color:
                color ?? (isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary),
          ),
          tooltip: 'Notifications',
        ),
        if (hasUnread)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: BoxDecoration(
                color: SpendexColors.expense,
                borderRadius: BorderRadius.circular(SpendexTheme.radiusFull),
                border: Border.all(
                  color: isDark ? SpendexColors.darkSurface : SpendexColors.lightSurface,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : unreadCount.toString(),
                  style: SpendexTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Mini notification dot indicator
class NotificationDot extends ConsumerWidget {
  const NotificationDot({
    super.key,
    this.size = 8,
    this.color,
    this.showWhenZero = false,
  });

  final double size;
  final Color? color;
  final bool showWhenZero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadProvider);

    if (hasUnread == false && showWhenZero == false) {
      return const SizedBox.shrink();
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? SpendexColors.expense,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (color ?? SpendexColors.expense).withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

/// Animated notification indicator with pulse effect
class AnimatedNotificationDot extends ConsumerStatefulWidget {
  const AnimatedNotificationDot({
    super.key,
    this.size = 8,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  ConsumerState<AnimatedNotificationDot> createState() => _AnimatedNotificationDotState();
}

class _AnimatedNotificationDotState extends ConsumerState<AnimatedNotificationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = ref.watch(hasUnreadProvider);

    if (hasUnread == false) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * _animation.value,
          height: widget.size * _animation.value,
          decoration: BoxDecoration(
            color: (widget.color ?? SpendexColors.expense).withValues(alpha: 2 - _animation.value),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color ?? SpendexColors.expense,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
