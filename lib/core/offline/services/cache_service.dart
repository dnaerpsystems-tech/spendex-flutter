import 'dart:async';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/sync_status.dart';

/// Box names for different entity types
class CacheBoxNames {
  CacheBoxNames._();

  static const String transactions = 'transactions_cache';
  static const String accounts = 'accounts_cache';
  static const String budgets = 'budgets_cache';
  static const String categories = 'categories_cache';
  static const String goals = 'goals_cache';
  static const String pendingMutations = 'pending_mutations';
  static const String syncMetadata = 'sync_metadata';
}

/// Abstract interface for cache operations
abstract class CacheService {
  /// Initialize the cache service
  Future<void> initialize();

  /// Store an entity in cache
  Future<void> put<T>(String boxName, String key, T value);

  /// Retrieve an entity from cache
  Future<T?> get<T>(String boxName, String key);

  /// Retrieve all entities from a box
  Future<List<T>> getAll<T>(String boxName);

  /// Delete an entity from cache
  Future<void> delete(String boxName, String key);

  /// Clear all entities in a box
  Future<void> clear(String boxName);

  /// Clear all cache data
  Future<void> clearAll();

  /// Get count of entities in a box
  Future<int> count(String boxName);

  /// Watch for changes in a box
  Stream<BoxEvent> watch(String boxName);

  /// Store JSON data
  Future<void> putJson(String boxName, String key, Map<String, dynamic> json);

  /// Retrieve JSON data
  Future<Map<String, dynamic>?> getJson(String boxName, String key);

  /// Get all JSON entries from a box
  Future<List<Map<String, dynamic>>> getAllJson(String boxName);

  /// Check if key exists
  Future<bool> containsKey(String boxName, String key);

  /// Get sync status for an entity
  Future<SyncStatus?> getSyncStatus(String boxName, String key);

  /// Set sync status for an entity
  Future<void> setSyncStatus(String boxName, String key, SyncStatus status);

  /// Get all entities with specific sync status
  Future<List<String>> getKeysBySyncStatus(String boxName, SyncStatus status);

  /// Close all boxes
  Future<void> close();
}

/// Implementation of CacheService using Hive
class CacheServiceImpl implements CacheService {
  CacheServiceImpl();

  final Map<String, Box<String>> _jsonBoxes = {};
  final Map<String, Box<dynamic>> _dynamicBoxes = {};
  Box<String>? _syncStatusBox;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    // Open sync status box
    _syncStatusBox = await Hive.openBox<String>('sync_status_cache');

    _isInitialized = true;
  }

  Future<Box<String>> _getJsonBox(String boxName) async {
    final existingBox = _jsonBoxes[boxName];
    if (existingBox == null || existingBox.isOpen == false) {
      _jsonBoxes[boxName] = await Hive.openBox<String>('${boxName}_json');
    }
    return _jsonBoxes[boxName]!;
  }

  Future<Box<dynamic>> _getDynamicBox(String boxName) async {
    final existingBox = _dynamicBoxes[boxName];
    if (existingBox == null || existingBox.isOpen == false) {
      _dynamicBoxes[boxName] = await Hive.openBox<dynamic>(boxName);
    }
    return _dynamicBoxes[boxName]!;
  }

  @override
  Future<void> put<T>(String boxName, String key, T value) async {
    final box = await _getDynamicBox(boxName);
    await box.put(key, value);
  }

  @override
  Future<T?> get<T>(String boxName, String key) async {
    final box = await _getDynamicBox(boxName);
    return box.get(key) as T?;
  }

  @override
  Future<List<T>> getAll<T>(String boxName) async {
    final box = await _getDynamicBox(boxName);
    return box.values.whereType<T>().toList();
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _getDynamicBox(boxName);
    await box.delete(key);
    // Also delete sync status
    await _syncStatusBox?.delete('${boxName}_$key');
  }

  @override
  Future<void> clear(String boxName) async {
    final box = await _getDynamicBox(boxName);
    await box.clear();
    // Clear sync statuses for this box
    final keysToDelete =
        _syncStatusBox?.keys.where((key) => key.toString().startsWith('${boxName}_')).toList() ??
            [];
    for (final key in keysToDelete) {
      await _syncStatusBox?.delete(key);
    }
  }

  @override
  Future<void> clearAll() async {
    for (final box in _jsonBoxes.values) {
      if (box.isOpen) {
        await box.clear();
      }
    }
    for (final box in _dynamicBoxes.values) {
      if (box.isOpen) {
        await box.clear();
      }
    }
    await _syncStatusBox?.clear();
  }

  @override
  Future<int> count(String boxName) async {
    final box = await _getDynamicBox(boxName);
    return box.length;
  }

  @override
  Stream<BoxEvent> watch(String boxName) {
    final box = _dynamicBoxes[boxName];
    if (box == null) {
      return const Stream.empty();
    }
    return box.watch();
  }

  @override
  Future<void> putJson(String boxName, String key, Map<String, dynamic> json) async {
    final box = await _getJsonBox(boxName);
    await box.put(key, jsonEncode(json));
  }

  @override
  Future<Map<String, dynamic>?> getJson(String boxName, String key) async {
    final box = await _getJsonBox(boxName);
    final jsonString = box.get(key);
    if (jsonString == null) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllJson(String boxName) async {
    final box = await _getJsonBox(boxName);
    final results = <Map<String, dynamic>>[];
    for (final jsonString in box.values) {
      try {
        results.add(jsonDecode(jsonString) as Map<String, dynamic>);
      } catch (_) {
        // Skip invalid JSON entries
      }
    }
    return results;
  }

  @override
  Future<bool> containsKey(String boxName, String key) async {
    final box = await _getDynamicBox(boxName);
    return box.containsKey(key);
  }

  @override
  Future<SyncStatus?> getSyncStatus(String boxName, String key) async {
    final statusKey = '${boxName}_$key';
    final statusValue = _syncStatusBox?.get(statusKey);
    if (statusValue == null) {
      return null;
    }
    return SyncStatusExtension.fromValue(statusValue);
  }

  @override
  Future<void> setSyncStatus(String boxName, String key, SyncStatus status) async {
    final statusKey = '${boxName}_$key';
    await _syncStatusBox?.put(statusKey, status.value);
  }

  @override
  Future<List<String>> getKeysBySyncStatus(String boxName, SyncStatus status) async {
    final results = <String>[];
    final prefix = '${boxName}_';

    for (final entry in _syncStatusBox?.toMap().entries ?? <MapEntry<dynamic, String>>[]) {
      if (entry.key.toString().startsWith(prefix) && entry.value == status.value) {
        results.add(entry.key.toString().substring(prefix.length));
      }
    }

    return results;
  }

  @override
  Future<void> close() async {
    for (final box in _jsonBoxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    for (final box in _dynamicBoxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    if (_syncStatusBox?.isOpen ?? false) {
      await _syncStatusBox?.close();
    }
    _jsonBoxes.clear();
    _dynamicBoxes.clear();
    _isInitialized = false;
  }
}
