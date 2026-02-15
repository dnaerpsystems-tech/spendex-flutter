import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/security/auto_lock_service.dart';
import '../../core/security/pin_service.dart';
import '../../core/utils/app_logger.dart';

/// Wrapper widget that implements auto-lock functionality.
///
/// This widget should wrap the main app content and monitors:
/// - App lifecycle changes (background/foreground)
/// - User interactions (taps, gestures)
///
/// When the app returns from background after the timeout period,
/// it navigates to the PIN entry screen.
///
/// Features:
/// - Configurable inactivity timeout
/// - Lifecycle-aware locking
/// - User interaction tracking
/// - PIN verification integration
class AutoLockWrapper extends ConsumerStatefulWidget {
  /// Creates a new AutoLockWrapper.
  ///
  /// [child] - The widget to wrap (typically the app content).
  const AutoLockWrapper({
    required this.child,
    this.onLock,
    super.key,
  });

  /// The child widget to wrap.
  final Widget child;

  /// Optional callback when the app is locked.
  final VoidCallback? onLock;

  @override
  ConsumerState<AutoLockWrapper> createState() => _AutoLockWrapperState();
}

class _AutoLockWrapperState extends ConsumerState<AutoLockWrapper> with WidgetsBindingObserver {
  /// Auto-lock service instance.
  late final AutoLockService _autoLockService;

  /// PIN service for checking if PIN is set.
  late final PinService _pinService;

  /// Whether the app is currently in the background.
  bool _isInBackground = false;

  /// Whether we're currently showing the lock screen.
  bool _isShowingLockScreen = false;

  @override
  void initState() {
    super.initState();

    // Get services from DI
    _autoLockService = getIt<AutoLockService>();
    _pinService = getIt<PinService>();

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Record initial activity
    _autoLockService.recordActivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;

      case AppLifecycleState.paused:
        _handleAppPaused();
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // No action needed for these states
        break;
    }
  }

  /// Handle app returning to foreground.
  Future<void> _handleAppResumed() async {
    _isInBackground = false;

    // Check if PIN is enabled
    final isPinSet = await _pinService.isPinSet();
    if (isPinSet == false) {
      // No PIN set, record activity and continue
      _autoLockService.recordActivity();
      return;
    }

    // Check if auto-lock is enabled
    if (_autoLockService.isEnabled == false) {
      _autoLockService.recordActivity();
      return;
    }

    // Check if we should lock
    if (_autoLockService.shouldLock() && _isShowingLockScreen == false) {
      _navigateToLockScreen();
    } else {
      // Record activity for the resume
      _autoLockService.recordActivity();
    }
  }

  /// Handle app going to background.
  void _handleAppPaused() {
    _isInBackground = true;
    _autoLockService.recordActivity();

    AppLogger.d('AutoLockWrapper: App paused, activity recorded');
  }

  /// Navigate to the PIN entry screen.
  void _navigateToLockScreen() {
    _isShowingLockScreen = true;

    // Call the optional onLock callback
    widget.onLock?.call();

    // Navigate to PIN entry screen
    // Using a post-frame callback to ensure the context is valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Reset the auto-lock service
        _autoLockService.reset();

        // Navigate to lock screen
        context.go('/security/pin-entry');

        // Reset the flag after navigation
        Future.delayed(const Duration(milliseconds: 500), () {
          _isShowingLockScreen = false;
        });
      }
    });

    AppLogger.d('AutoLockWrapper: Navigating to lock screen');
  }

  /// Record user activity on interaction.
  void _recordActivity() {
    if (_isInBackground == false) {
      _autoLockService.recordActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the child in a gesture detector to track user activity
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _recordActivity,
      onScaleStart: (_) => _recordActivity(),
      onScaleUpdate: (_) => _recordActivity(),
      child: Listener(
        // Use Listener for lower-level pointer events
        onPointerDown: (_) => _recordActivity(),
        onPointerMove: (_) => _recordActivity(),
        child: widget.child,
      ),
    );
  }
}

/// Provider for tracking app lock state.
final appLockStateProvider = StateProvider<bool>((ref) => false);

/// Extension for easy integration with GoRouter.
extension AutoLockRouterExtension on GoRouter {
  /// Check if the current route is a lock screen.
  bool get isOnLockScreen {
    final location = routeInformationProvider.value.uri.path;
    return location.contains('pin-entry') || location.contains('pin-lock');
  }
}
