import 'package:connectivity_plus/connectivity_plus.dart';

/// Utility class for checking network connectivity.
class ConnectivityChecker {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has network connectivity
  static Future<bool> hasConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  /// Stream of connectivity changes
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) => results.any((r) => r != ConnectivityResult.none),
    );
  }
}
