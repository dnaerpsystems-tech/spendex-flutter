import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_logger.dart';

/// Service for handling deep links and universal links
class DeepLinkService {
  DeepLinkService._();

  static const _channel = MethodChannel('spendex/deep_link');
  static StreamSubscription? _subscription;
  static GoRouter? _router;

  /// Initialize deep link handling
  static Future<void> initialize(GoRouter router) async {
    _router = router;

    // Handle initial link (app opened via link)
    try {
      final initialLink = await _channel.invokeMethod<String>('getInitialLink');
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e) {
      AppLogger.d('DeepLinkService: No initial link');
    }

    // Listen for incoming links while app is running
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink') {
        final link = call.arguments as String?;
        if (link != null) {
          _handleLink(link);
        }
      }
    });
  }

  /// Handle incoming deep link
  static void _handleLink(String link) {
    if (kDebugMode) {
      AppLogger.d('DeepLinkService: Received link: $link');
    }

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    // Handle different paths
    final path = uri.path;
    final params = uri.queryParameters;

    String? routePath;

    // Transaction deep link: spendex://transaction/123
    if (path.startsWith('/transaction/')) {
      final id = path.split('/').last;
      routePath = '/transactions/$id';
    }
    // Account deep link: spendex://account/123
    else if (path.startsWith('/account/')) {
      final id = path.split('/').last;
      routePath = '/accounts/$id';
    }
    // Budget deep link: spendex://budget/123
    else if (path.startsWith('/budget/')) {
      final id = path.split('/').last;
      routePath = '/budgets/$id';
    }
    // Goal deep link: spendex://goal/123
    else if (path.startsWith('/goal/')) {
      final id = path.split('/').last;
      routePath = '/goals/$id';
    }
    // Invite deep link: spendex://invite?code=ABC123
    else if (path == '/invite' && params['code'] != null) {
      routePath = '/family/join?code=${params['code']}';
    }
    // Payment callback: spendex://payment/success
    else if (path.startsWith('/payment/')) {
      final status = path.split('/').last;
      routePath = '/subscription?payment=$status';
    }
    // Reset password: spendex://reset-password?token=xyz
    else if (path == '/reset-password' && params['token'] != null) {
      routePath = '/auth/reset-password?token=${params['token']}';
    }

    // Navigate if we have a valid route
    if (routePath != null && _router != null) {
      _router!.go(routePath);
    }
  }

  /// Generate a shareable deep link
  static String generateLink({
    required String type,
    required String id,
    Map<String, String>? params,
  }) {
    var link = 'https://spendex.in/app/$type/$id';

    if (params != null && params.isNotEmpty) {
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      link += '?$query';
    }

    return link;
  }

  /// Dispose of listeners
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
