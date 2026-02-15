import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing auto-lock functionality.
///
/// Tracks user activity and determines when the app should be locked
/// after a period of inactivity.
///
/// Features:
/// - Configurable timeout duration (default 5 minutes)
/// - Persists timeout preference to SharedPreferences
/// - Activity tracking with timestamp recording
/// - Lock state management
abstract class AutoLockService {
  /// Record user activity to reset the inactivity timer.
  void recordActivity();

  /// Check if the app should be locked due to inactivity.
  ///
  /// Returns true if the inactivity timeout has been exceeded.
  bool shouldLock();

  /// Set the inactivity timeout duration.
  ///
  /// [duration] - The timeout duration.
  Future<void> setTimeout(Duration duration);

  /// Get the current timeout duration.
  Duration get timeout;

  /// Reset the auto-lock state.
  void reset();

  /// Get the time remaining before lock.
  ///
  /// Returns null if no activity has been recorded.
  Duration? get timeUntilLock;

  /// Check if auto-lock is enabled.
  bool get isEnabled;

  /// Enable or disable auto-lock.
  Future<void> setEnabled({required bool enabled});
}

/// Implementation of [AutoLockService] using SharedPreferences.
///
/// Stores the timeout preference persistently and tracks activity
/// timestamps in memory for fast access.
class AutoLockServiceImpl implements AutoLockService {
  /// Creates a new AutoLockServiceImpl instance.
  ///
  /// [_prefs] - SharedPreferences instance for persistent storage.
  AutoLockServiceImpl(this._prefs) {
    _loadSettings();
  }

  final SharedPreferences _prefs;

  /// Default timeout duration (5 minutes).
  static const Duration _defaultTimeout = Duration(minutes: 5);

  /// Storage key for timeout setting.
  static const String _timeoutKey = 'spendex_auto_lock_timeout_seconds';

  /// Storage key for enabled setting.
  static const String _enabledKey = 'spendex_auto_lock_enabled';

  /// Timestamp of the last recorded activity.
  DateTime? _lastActivity;

  /// Current timeout duration.
  Duration _timeout = _defaultTimeout;

  /// Whether auto-lock is enabled.
  bool _enabled = true;

  /// Load settings from SharedPreferences.
  void _loadSettings() {
    final timeoutSeconds = _prefs.getInt(_timeoutKey);
    if (timeoutSeconds != null) {
      _timeout = Duration(seconds: timeoutSeconds);
    }

    _enabled = _prefs.getBool(_enabledKey) ?? true;
  }

  @override
  void recordActivity() {
    _lastActivity = DateTime.now();
  }

  @override
  bool shouldLock() {
    if (_enabled == false) {
      return false;
    }

    if (_lastActivity == null) {
      return false;
    }

    final elapsed = DateTime.now().difference(_lastActivity!);
    return elapsed > _timeout;
  }

  @override
  Future<void> setTimeout(Duration duration) async {
    _timeout = duration;
    await _prefs.setInt(_timeoutKey, duration.inSeconds);
  }

  @override
  Duration get timeout => _timeout;

  @override
  void reset() {
    _lastActivity = null;
  }

  @override
  Duration? get timeUntilLock {
    if (_lastActivity == null) {
      return null;
    }

    final lockTime = _lastActivity!.add(_timeout);
    final remaining = lockTime.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    _enabled = enabled;
    await _prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      // Reset activity when enabling
      recordActivity();
    } else {
      // Clear activity when disabling
      reset();
    }
  }
}

/// Available auto-lock timeout options.
enum AutoLockTimeout {
  /// 30 seconds - for high security needs.
  thirtySeconds(Duration(seconds: 30), '30 seconds'),

  /// 1 minute - for high security needs.
  oneMinute(Duration(minutes: 1), '1 minute'),

  /// 2 minutes - for moderate security needs.
  twoMinutes(Duration(minutes: 2), '2 minutes'),

  /// 5 minutes - default, balanced security.
  fiveMinutes(Duration(minutes: 5), '5 minutes'),

  /// 10 minutes - for convenience.
  tenMinutes(Duration(minutes: 10), '10 minutes'),

  /// 30 minutes - for low security needs.
  thirtyMinutes(Duration(minutes: 30), '30 minutes'),

  /// Never - disables auto-lock.
  never(Duration(days: 365), 'Never');

  const AutoLockTimeout(this.duration, this.label);

  /// The duration for this timeout option.
  final Duration duration;

  /// Human-readable label for this option.
  final String label;

  /// Get the timeout option matching a duration.
  static AutoLockTimeout fromDuration(Duration duration) {
    return AutoLockTimeout.values.firstWhere(
      (t) => t.duration == duration,
      orElse: () => AutoLockTimeout.fiveMinutes,
    );
  }
}
