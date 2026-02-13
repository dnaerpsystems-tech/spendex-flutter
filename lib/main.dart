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
    debugPrint('Main: Flutter initialized');
  }

  // Load environment variables
  try {
    await dotenv.load();
    if (kDebugMode) {
      debugPrint('Main: Dotenv loaded');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Main: Dotenv error: $e');
    }
  }

  // Initialize Hive for local storage
  await Hive.initFlutter();
  if (kDebugMode) {
    debugPrint('Main: Hive initialized');
  }

  // Initialize dependency injection
  await configureDependencies();
  if (kDebugMode) {
    debugPrint('Main: Dependencies configured');
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
    debugPrint('Main: Running app');
  }
  runApp(
    const ProviderScope(
      child: SpendexApp(),
    ),
  );
}
