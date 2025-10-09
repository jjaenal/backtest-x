import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/models/candle.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StorageService {
  Database? _database;

  // Cache untuk mengurangi database queries
  final Map<String, Strategy> _strategyCache = {};
  final Map<String, List<BacktestResult>> _resultCache = {};
  bool _strategiesCacheValid = false;
  List<Strategy>? _allStrategiesCache;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (kIsWeb) {
      // On web, use a simple name stored in IndexedDB
      path = 'backtestx.db';
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'backtestx.db');
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Strategies table
    await db.execute('''
      CREATE TABLE strategies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        config TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // Backtest results table - Optimized (no full trade storage)
    await db.execute('''
      CREATE TABLE backtest_results (
        id TEXT PRIMARY KEY,
        strategy_id TEXT NOT NULL,
        market_data_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        trades_count INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE
      )
    ''');

    // Market data table - Optimized
    await db.execute('''
      CREATE TABLE market_data (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        timeframe TEXT NOT NULL,
        candles_count INTEGER NOT NULL,
        first_date INTEGER NOT NULL,
        last_date INTEGER NOT NULL,
        uploaded_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_strategy_created ON strategies(created_at DESC)');
    await db.execute(
        'CREATE INDEX idx_backtest_strategy ON backtest_results(strategy_id, created_at DESC)');
    await db.execute(
        'CREATE INDEX idx_market_symbol ON market_data(symbol, timeframe)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle incremental upgrades
    if (oldVersion < 2) {
      // Ensure backtest_results has market_data_id column
      try {
        final info = await db.rawQuery('PRAGMA table_info(backtest_results)');
        final hasColumn = info.any((row) => row['name'] == 'market_data_id');
        if (!hasColumn) {
          await db.execute(
              'ALTER TABLE backtest_results ADD COLUMN market_data_id TEXT');
        }
      } catch (_) {
        // Ignore pragma errors; ALTER TABLE may still succeed
      }

      // Normalize existing rows to avoid null/empty market_data_id
      try {
        await db.rawUpdate(
            "UPDATE backtest_results SET market_data_id = 'unknown' WHERE market_data_id IS NULL OR TRIM(market_data_id) = ''");
      } catch (_) {
        // Safe to ignore if table has no rows or column just added
      }

      // Recreate indexes if needed
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_backtest_strategy ON backtest_results(strategy_id, created_at DESC)');
      } catch (_) {
        // Non-critical; continue
      }
    }
  }

  // ============ STRATEGIES ============

  Future<void> saveStrategy(Strategy strategy) async {
    final db = await database;
    await db.insert(
      'strategies',
      {
        'id': strategy.id,
        'name': strategy.name,
        'config': jsonEncode(strategy.toJson()),
        'created_at': strategy.createdAt.millisecondsSinceEpoch,
        'updated_at': strategy.updatedAt?.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Invalidate cache
    _strategyCache[strategy.id] = strategy;
    _strategiesCacheValid = false;
    _allStrategiesCache = null;
  }

  Future<List<Strategy>> getAllStrategies() async {
    // Return from cache if valid
    if (_strategiesCacheValid && _allStrategiesCache != null) {
      return _allStrategiesCache!;
    }

    final db = await database;
    final maps = await db.query(
      'strategies',
      orderBy: 'created_at DESC',
      limit: 50, // Limit untuk performa
    );

    _allStrategiesCache = maps.map((map) {
      final config = jsonDecode(map['config'] as String);
      final strategy = Strategy.fromJson(config);
      _strategyCache[strategy.id] = strategy;
      return strategy;
    }).toList();

    _strategiesCacheValid = true;
    return _allStrategiesCache!;
  }

  Future<Strategy?> getStrategy(String id) async {
    // Check cache first
    if (_strategyCache.containsKey(id)) {
      return _strategyCache[id];
    }

    final db = await database;
    final maps = await db.query(
      'strategies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final config = jsonDecode(maps.first['config'] as String);
    final strategy = Strategy.fromJson(config);
    _strategyCache[id] = strategy;
    return strategy;
  }

  Future<void> deleteStrategy(String id) async {
    final db = await database;
    await db.delete(
      'strategies',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Clear cache
    _strategyCache.remove(id);
    _strategiesCacheValid = false;
    _allStrategiesCache = null;
    _resultCache.remove(id);
  }

  // ============ BACKTEST RESULTS ============

  Future<void> saveBacktestResult(BacktestResult result) async {
    final db = await database;

    // Ensure legacy databases have the expected column before inserting
    await _ensureBacktestResultsMarketDataIdColumn(db);
    // Normalize any existing rows missing market_data_id
    try {
      await db.rawUpdate(
        "UPDATE backtest_results SET market_data_id = 'unknown' WHERE market_data_id IS NULL OR TRIM(market_data_id) = ''",
      );
    } catch (_) {
      // Safe to ignore if the column just got added and table has no rows yet
    }

    // Save summary only, not full trade list (optimization!)
    await db.insert(
      'backtest_results',
      {
        'id': result.id,
        'strategy_id': result.strategyId,
        'market_data_id': result.marketDataId,
        'summary': jsonEncode(result.summary.toJson()),
        'trades_count': result.trades.length,
        'created_at': result.executedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Cache invalidation
    _resultCache.remove(result.strategyId);

    // Store full result in memory cache for quick access
    if (!_resultCache.containsKey(result.strategyId)) {
      _resultCache[result.strategyId] = [];
    }
    _resultCache[result.strategyId]!.insert(0, result);
  }

  /// Get the latest backtest result across all strategies
  Future<BacktestResult?> getLatestBacktestResult() async {
    final db = await database;
    final maps = await db.query(
      'backtest_results',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final rawMarketId = map['market_data_id'] as String?;
    final normalizedMarketId =
        (rawMarketId == null || rawMarketId.trim().isEmpty)
            ? 'unknown'
            : rawMarketId;

    return BacktestResult(
      id: map['id'] as String,
      strategyId: map['strategy_id'] as String,
      marketDataId: normalizedMarketId,
      executedAt:
          DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      summary: BacktestSummary.fromJson(
        jsonDecode(map['summary'] as String),
      ),
      trades: [],
      equityCurve: [],
    );
  }

  // Lightweight schema compatibility: add market_data_id if missing
  Future<void> _ensureBacktestResultsMarketDataIdColumn(Database db) async {
    try {
      final info = await db.rawQuery('PRAGMA table_info(backtest_results)');
      final hasColumn = info.any((row) {
        final name = row['name'];
        return name == 'market_data_id';
      });
      if (!hasColumn) {
        await db.execute(
          'ALTER TABLE backtest_results ADD COLUMN market_data_id TEXT',
        );
      }
    } catch (_) {
      // If pragma fails for any reason, proceed without blocking; insert may still work
    }
  }

  Future<List<BacktestResult>> getBacktestResultsByStrategy(
      String strategyId) async {
    // Check cache first (only return if non-empty, otherwise load from DB)
    final cached = _resultCache[strategyId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    final db = await database;
    final maps = await db.query(
      'backtest_results',
      where: 'strategy_id = ?',
      whereArgs: [strategyId],
      orderBy: 'created_at DESC',
      limit: 20, // Limit for performance
    );

    // Lightweight migration: ensure market_data_id is non-null/non-empty
    for (final map in maps) {
      final rawMarketId = map['market_data_id'] as String?;
      if (rawMarketId == null || rawMarketId.trim().isEmpty) {
        // Update DB to keep data consistent going forward
        try {
          await db.update(
            'backtest_results',
            {'market_data_id': 'unknown'},
            where: 'id = ?',
            whereArgs: [map['id']],
          );
        } catch (_) {
          // Safe fallback if update fails; proceed with in-memory default
        }
      }
    }

    final results = maps.map((map) {
      final rawMarketId = map['market_data_id'] as String?;
      final normalizedMarketId =
          (rawMarketId == null || rawMarketId.trim().isEmpty)
              ? 'unknown'
              : rawMarketId;
      return BacktestResult(
        id: map['id'] as String,
        strategyId: map['strategy_id'] as String,
        marketDataId: normalizedMarketId,
        executedAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        summary: BacktestSummary.fromJson(jsonDecode(map['summary'] as String)),
        trades: [], // Empty trades list - load separately if needed
        equityCurve: [], // Empty equity curve
      );
    }).toList();

    _resultCache[strategyId] = results;
    return results;
  }

  Future<BacktestResult?> getBacktestResult(String id) async {
    final db = await database;
    final maps = await db.query(
      'backtest_results',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    // Lightweight migration: ensure market_data_id is non-null/non-empty
    final rawMarketId = map['market_data_id'] as String?;
    if (rawMarketId == null || rawMarketId.trim().isEmpty) {
      try {
        await db.update(
          'backtest_results',
          {'market_data_id': 'unknown'},
          where: 'id = ?',
          whereArgs: [map['id']],
        );
      } catch (_) {
        // Ignore migration failure; continue with default value
      }
    }
    final normalizedMarketId =
        (rawMarketId == null || rawMarketId.trim().isEmpty)
            ? 'unknown'
            : rawMarketId;
    return BacktestResult(
      id: map['id'] as String,
      strategyId: map['strategy_id'] as String,
      marketDataId: normalizedMarketId,
      executedAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      summary: BacktestSummary.fromJson(jsonDecode(map['summary'] as String)),
      trades: [], // Trades not stored anymore for performance
      equityCurve: [], // Equity curve not stored
    );
  }

  Future<void> deleteBacktestResult(String id) async {
    final db = await database;
    await db.delete(
      'backtest_results',
      where: 'id = ?',
      whereArgs: [id],
    );

    // Clear relevant cache
    _resultCache.clear();
  }

  // ============ MARKET DATA ============

  Future<void> saveMarketData(MarketData data) async {
    final db = await database;

    // Store metadata only, not actual candles (too big!)
    await db.insert(
      'market_data',
      {
        'id': data.id,
        'symbol': data.symbol,
        'timeframe': data.timeframe,
        'candles_count': data.candles.length,
        'first_date': data.candles.first.timestamp.millisecondsSinceEpoch,
        'last_date': data.candles.last.timestamp.millisecondsSinceEpoch,
        'uploaded_at': data.uploadedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Note: Actual candles NOT stored in DB for performance!
    // They should be kept in memory or re-loaded from CSV when needed
  }

  Future<List<MarketDataInfo>> getAllMarketDataInfo() async {
    final db = await database;
    final maps = await db.query(
      'market_data',
      orderBy: 'uploaded_at DESC',
    );

    return maps.map((map) {
      return MarketDataInfo(
        id: map['id'] as String,
        symbol: map['symbol'] as String,
        timeframe: map['timeframe'] as String,
        candlesCount: map['candles_count'] as int,
        firstDate:
            DateTime.fromMillisecondsSinceEpoch(map['first_date'] as int),
        lastDate: DateTime.fromMillisecondsSinceEpoch(map['last_date'] as int),
        uploadedAt:
            DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int),
      );
    }).toList();
  }

  Future<void> deleteMarketData(String id) async {
    final db = await database;
    await db.delete(
      'market_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('strategies');
    await db.delete('backtest_results');
    await db.delete('market_data');

    // Clear all caches
    _strategyCache.clear();
    _resultCache.clear();
    _strategiesCacheValid = false;
    _allStrategiesCache = null;
  }

  // Clear caches manually
  void clearCache() {
    _strategyCache.clear();
    _resultCache.clear();
    _strategiesCacheValid = false;
    _allStrategiesCache = null;
  }
}

// Lightweight market data info (without actual candles)
class MarketDataInfo {
  final String id;
  final String symbol;
  final String timeframe;
  final int candlesCount;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime uploadedAt;

  MarketDataInfo({
    required this.id,
    required this.symbol,
    required this.timeframe,
    required this.candlesCount,
    required this.firstDate,
    required this.lastDate,
    required this.uploadedAt,
  });
}
