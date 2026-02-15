/// Offline-first architecture module
///
/// This module provides complete offline support for the Spendex app:
/// - Hive-based local caching
/// - Connectivity monitoring
/// - Background sync
/// - Conflict resolution
/// - Pending mutation queue
///
/// ## Usage
///
/// 1. Initialize in main.dart:
/// ```dart
/// await OfflineModule.initialize();
/// ```
///
/// 2. Use offline providers in widgets:
/// ```dart
/// final isOnline = ref.watch(connectivityStreamProvider);
/// final syncState = ref.watch(syncStatusProvider);
/// ```
///
/// 3. Add offline support to repositories:
/// ```dart
/// class MyRepository with OfflineRepositoryMixin<MyModel> {
///   // ...
/// }
/// ```
library offline;

// Adapters
export 'adapters/adapters.dart';
// Mixins
export 'mixins/offline_repository_mixin.dart';
// Models
export 'models/models.dart';
// Providers
export 'providers/offline_provider.dart';
// Services
export 'services/cache_service.dart';
export 'services/connectivity_service.dart';
export 'services/sync_service.dart';
// Widgets
export 'widgets/conflict_resolution_dialog.dart';
export 'widgets/offline_banner.dart';
export 'widgets/sync_status_indicator.dart';
