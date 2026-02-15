import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for connectivity monitoring
abstract class ConnectivityService {
  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Check if currently online
  Future<bool> get isOnline;

  /// Force check current connection
  Future<bool> checkConnection();

  /// Dispose resources
  void dispose();
}

/// Implementation of ConnectivityService using connectivity_plus
class ConnectivityServiceImpl implements ConnectivityService {
  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _lastKnownState = true;

  StreamController<bool> _getController() {
    if (_connectivityController == null || _connectivityController!.isClosed) {
      _connectivityController = StreamController<bool>.broadcast();
      _startListening();
    }
    return _connectivityController!;
  }

  void _startListening() {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = _isConnected(results);
      if (isConnected != _lastKnownState) {
        _lastKnownState = isConnected;
        _connectivityController?.add(isConnected);
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.any(
      (result) =>
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.ethernet,
    );
  }

  @override
  Stream<bool> get onConnectivityChanged => _getController().stream;

  @override
  Future<bool> get isOnline async {
    final results = await _connectivity.checkConnectivity();
    _lastKnownState = _isConnected(results);
    return _lastKnownState;
  }

  @override
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final isConnected = _isConnected(results);

      if (isConnected != _lastKnownState) {
        _lastKnownState = isConnected;
        _connectivityController?.add(isConnected);
      }

      return isConnected;
    } catch (e) {
      return _lastKnownState;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _connectivityController?.close();
    _connectivityController = null;
  }
}

/// Connectivity state for UI
class ConnectivityState {
  const ConnectivityState({
    required this.isOnline,
    this.lastOnlineAt,
    this.connectionType,
  });

  final bool isOnline;
  final DateTime? lastOnlineAt;
  final String? connectionType;

  ConnectivityState copyWith({
    bool? isOnline,
    DateTime? lastOnlineAt,
    String? connectionType,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      connectionType: connectionType ?? this.connectionType,
    );
  }
}
