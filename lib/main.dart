import 'core/config/environment.dart';
import 'core/security/device_security.dart';
import 'core/security/screen_security.dart';
import 'core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    AppLogger.d('Main: Flutter initialized');
  }

  // Load environment variables
  try {
    await dotenv.load();
    if (kDebugMode) {
      AppLogger.d('Main: Dotenv loaded');
    }
  } catch (e) {
    if (kDebugMode) {
      AppLogger.d('Main: Dotenv error: $e');
    }
  }

  // Initialize environment configuration
  EnvironmentConfig.initialize();
  if (kDebugMode) {
    AppLogger.d('Main: Environment: ${EnvironmentConfig.current.name}');
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  if (kDebugMode) {
    AppLogger.d('Main: Hive initialized');
  }

  // Initialize dependency injection
  await configureDependencies();
  if (kDebugMode) {
    AppLogger.d('Main: Dependencies configured');
  }

  // Enable screen security (screenshot prevention) in production
  if (EnvironmentConfig.current == Environment.production) {
    await ScreenSecurity.enableSecureMode();
    if (kDebugMode) {
      AppLogger.d('Main: Screen security enabled');
    }
  }

  // Perform device security check
  final securityResult = await DeviceSecurity.performSecurityCheck();
  if (kDebugMode) {
    AppLogger.d('Main: Device security - isSecure: ${securityResult.isSecure}');
    if (securityResult.isSecure == false) {
      AppLogger.w('Main: Security warning - rooted/jailbroken detected');
    }
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  if (kDebugMode) {
    AppLogger.d('Main: Running app');
  }
  runApp(
    const ProviderScope(
      child: SpendexApp(),
    ),
  );
}
