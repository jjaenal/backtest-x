import 'dart:convert';
import 'dart:io';
import 'package:backtestx/models/candle.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton class to manage market data with persistent file caching
/// Data survives app restarts!
class DataManager {
  // TRUE Singleton pattern - static instance
  static final DataManager _instance = DataManager._internal();

  // Factory returns the same instance always
  factory DataManager() => _instance;

  // Private constructor
  DataManager._internal() {
    debugPrint('🔧 DataManager initialized (singleton with file caching)');
    _initializeCacheDir();
  }

  // In-memory cache for fast access (static to ensure persistence during session)
  static final Map<String, MarketData> _memoryCache = {};

  // Cache directory
  Directory? _cacheDir;

  /// Initialize cache directory
  Future<void> _initializeCacheDir() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${appDir.path}/market_data_cache');

      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
        debugPrint('📁 Created cache directory: ${_cacheDir!.path}');
      } else {
        debugPrint('📁 Cache directory exists: ${_cacheDir!.path}');
      }

      // Auto-load cached data on startup
      await _loadAllFromDisk();
    } catch (e) {
      debugPrint('❌ Error initializing cache directory: $e');
    }
  }

  /// Cache market data (memory + disk)
  Future<void> cacheData(MarketData data) async {
    // Cache in memory first (fast access)
    _memoryCache[data.id] = data;
    debugPrint(
        '✅ Cached in memory: ${data.symbol} (${data.candles.length} candles)');

    // Save to disk (persistent)
    await _saveToDisk(data);

    debugPrint('   Total cached datasets: ${_memoryCache.length}');
  }

  /// Save market data to disk
  Future<void> _saveToDisk(MarketData data) async {
    try {
      if (_cacheDir == null) {
        await _initializeCacheDir();
      }

      final file = File('${_cacheDir!.path}/${data.id}.json');
      final json = jsonEncode(data.toJson());
      await file.writeAsString(json);

      debugPrint('💾 Saved to disk: ${data.id}');
    } catch (e) {
      debugPrint('❌ Error saving to disk: $e');
    }
  }

  /// Load all cached data from disk on startup
  Future<void> _loadAllFromDisk() async {
    try {
      if (_cacheDir == null || !await _cacheDir!.exists()) {
        debugPrint('⚠️  Cache directory not ready');
        return;
      }

      final files = _cacheDir!
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      if (files.isEmpty) {
        debugPrint('📂 No cached data files found');
        return;
      }

      debugPrint('📂 Loading ${files.length} cached dataset(s) from disk...');

      for (final file in files) {
        try {
          final json = await file.readAsString();
          final data = MarketData.fromJson(jsonDecode(json));
          _memoryCache[data.id] = data;
          debugPrint(
              '   ✅ Loaded: ${data.symbol} ${data.timeframe} (${data.candles.length} candles)');
        } catch (e) {
          debugPrint('   ❌ Error loading ${file.path}: $e');
        }
      }

      debugPrint('✅ Loaded ${_memoryCache.length} dataset(s) from disk cache');
    } catch (e) {
      debugPrint('❌ Error loading from disk: $e');
    }
  }

  /// Get cached market data by ID
  MarketData? getData(String id) {
    final data = _memoryCache[id];
    if (data != null) {
      debugPrint('✅ Found data in cache: ${data.symbol} ${data.timeframe}');
    } else {
      debugPrint('❌ Data not found in cache: $id');
      debugPrint('   Available IDs: ${_memoryCache.keys.join(", ")}');
    }
    return data;
  }

  /// Get all cached data
  List<MarketData> getAllData() {
    debugPrint('📊 Getting all data from cache...');
    debugPrint('   Cache size: ${_memoryCache.length}');
    return _memoryCache.values.toList();
  }

  /// Find data by symbol and timeframe
  MarketData? findData(String symbol, String timeframe) {
    try {
      return _memoryCache.values.firstWhere(
        (data) => data.symbol == symbol && data.timeframe == timeframe,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if data exists in cache
  bool hasData(String id) {
    return _memoryCache.containsKey(id);
  }

  /// Remove data from cache (memory + disk)
  Future<void> removeData(String id) async {
    // Remove from memory
    _memoryCache.remove(id);
    debugPrint('🗑️  Removed from memory: $id');

    // Remove from disk
    try {
      if (_cacheDir != null) {
        final file = File('${_cacheDir!.path}/$id.json');
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️  Removed from disk: $id');
        }
      }
    } catch (e) {
      debugPrint('❌ Error removing from disk: $e');
    }

    debugPrint('   Remaining datasets: ${_memoryCache.length}');
  }

  /// Clear all cached data (memory + disk)
  Future<void> clearAll() async {
    // Clear memory
    _memoryCache.clear();
    debugPrint('🗑️  Cleared memory cache');

    // Clear disk
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = _cacheDir!.listSync().whereType<File>();
        for (final file in files) {
          await file.delete();
        }
        debugPrint('🗑️  Cleared disk cache');
      }
    } catch (e) {
      debugPrint('❌ Error clearing disk cache: $e');
    }
  }

  /// Get cache info
  String getCacheInfo() {
    if (_memoryCache.isEmpty) return 'No data cached';

    final buffer = StringBuffer();
    buffer.writeln('📊 Cached Data (${_memoryCache.length} datasets):');
    for (final data in _memoryCache.values) {
      buffer.writeln(
          '  - ${data.id}: ${data.symbol} ${data.timeframe} (${data.candles.length} candles)');
    }
    return buffer.toString();
  }

  /// Get total memory usage estimate (rough)
  int getEstimatedMemoryUsage() {
    int total = 0;
    for (final data in _memoryCache.values) {
      // Rough estimate: each candle ~100 bytes
      total += data.candles.length * 100;
    }
    return total; // bytes
  }

  String getMemoryUsageFormatted() {
    final bytes = getEstimatedMemoryUsage();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get disk usage
  Future<int> getDiskUsage() async {
    int total = 0;
    try {
      if (_cacheDir != null && await _cacheDir!.exists()) {
        final files = _cacheDir!.listSync().whereType<File>();
        for (final file in files) {
          total += await file.length();
        }
      }
    } catch (e) {
      debugPrint('Error calculating disk usage: $e');
    }
    return total;
  }

  Future<String> getDiskUsageFormatted() async {
    final bytes = await getDiskUsage();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Debug: Print all cache keys
  void debugPrintCache() {
    debugPrint('\n🔍 DEBUG: DataManager Cache State');
    debugPrint('   Instance: ${identityHashCode(this)}');
    debugPrint('   Memory cache size: ${_memoryCache.length}');
    debugPrint('   Cache directory: ${_cacheDir?.path ?? "not initialized"}');
    debugPrint('   Memory keys: ${_memoryCache.keys.join(", ")}');
    for (final entry in _memoryCache.entries) {
      debugPrint(
          '   - ${entry.key}: ${entry.value.symbol} ${entry.value.timeframe}');
    }
    debugPrint('');
  }

  /// Force reload from disk (useful after app restart)
  Future<void> reloadFromDisk() async {
    debugPrint('🔄 Reloading cache from disk...');
    _memoryCache.clear();
    await _loadAllFromDisk();
  }
}

/// Extension for easy access
extension MarketDataCaching on MarketData {
  /// Cache this market data
  Future<void> cache() async {
    await DataManager().cacheData(this);
  }
}

/// Usage examples:
///
/// // After upload - automatically saved to disk
/// final marketData = await dataParser.parseCsvFile(...);
/// await DataManager().cacheData(marketData);
///
/// // Data persists across app restarts!
/// // On app startup, data is auto-loaded from disk
///
/// // When running backtest (after restart)
/// final data = DataManager().getData(dataId);
/// if (data != null) {
///   final result = await backtestEngine.runBacktest(
///     marketData: data,
///     strategy: strategy,
///   );
/// }
///
/// // Check storage
/// debugPrint('Memory: ${DataManager().getMemoryUsageFormatted()}');
/// debugPrint('Disk: ${await DataManager().getDiskUsageFormatted()}');
