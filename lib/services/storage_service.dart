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
  // Save-result performance guards (run schema checks/normalization only once)
  bool _backtestResultsColumnChecked = false;
  bool _backtestResultsNormalized = false;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;
    try {
      if (kIsWeb) {
        // On web, use a simple name stored in IndexedDB
        path = 'backtestx.db';
      } else {
        final dbPath = await getDatabasesPath();
        path = join(dbPath, 'backtestx.db');
      }
    } catch (_) {
      // Fallback to in-memory path if resolving DB path fails
      path = inMemoryDatabasePath;
    }

    try {
      final db = await openDatabase(
        path,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      // Post-open schema validation & repair for extra safety
      await _validateAndRepairSchema(db);
      return db;
    } catch (_) {
      // Fallback: open in-memory database to avoid crashing
      final db = await openDatabase(
        inMemoryDatabasePath,
        version: 4,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      await _validateAndRepairSchema(db);
      return db;
    }
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

    // Strategy drafts table for autosave
    await db.execute('''
      CREATE TABLE strategy_drafts (
        id TEXT PRIMARY KEY,
        strategy_id TEXT,
        data TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_strategy_created ON strategies(created_at DESC)');
    await db.execute(
        'CREATE INDEX idx_backtest_strategy ON backtest_results(strategy_id, created_at DESC)');
    await db.execute(
        'CREATE INDEX idx_market_symbol ON market_data(symbol, timeframe)');
    await db.execute(
        'CREATE INDEX idx_draft_updated ON strategy_drafts(updated_at DESC)');
    await db.execute(
        'CREATE INDEX idx_market_uploaded ON market_data(uploaded_at DESC)');
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
    // Add drafts table for autosave in v3
    if (oldVersion < 3) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS strategy_drafts (
            id TEXT PRIMARY KEY,
            strategy_id TEXT,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_draft_updated ON strategy_drafts(updated_at DESC)');
      } catch (_) {
        // Non-critical
      }
    }
    // Add index on uploaded_at in v4 for faster ordering
    if (oldVersion < 4) {
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_market_uploaded ON market_data(uploaded_at DESC)');
      } catch (_) {
        // Non-critical
      }
    }
  }

  /// Validate existence of required tables/columns and repair if needed.
  /// This complements onCreate/onUpgrade to cover legacy DBs created outside
  /// expected lifecycle or partially migrated instances.
  Future<void> _validateAndRepairSchema(Database db) async {
    try {
      // Gather existing tables
      final tableRows = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final existingTables =
          tableRows.map((e) => (e['name'] as String?) ?? '').toSet();

      // Strategies
      if (!existingTables.contains('strategies')) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS strategies (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            config TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');
      }

      // Backtest results (summary only)
      if (!existingTables.contains('backtest_results')) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS backtest_results (
            id TEXT PRIMARY KEY,
            strategy_id TEXT NOT NULL,
            market_data_id TEXT,
            summary TEXT NOT NULL,
            trades_count INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE
          )
        ''');
      }

      // Market data metadata
      if (!existingTables.contains('market_data')) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS market_data (
            id TEXT PRIMARY KEY,
            symbol TEXT NOT NULL,
            timeframe TEXT NOT NULL,
            candles_count INTEGER NOT NULL,
            first_date INTEGER NOT NULL,
            last_date INTEGER NOT NULL,
            uploaded_at INTEGER NOT NULL
          )
        ''');
      }

      // Strategy drafts (autosave)
      if (!existingTables.contains('strategy_drafts')) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS strategy_drafts (
            id TEXT PRIMARY KEY,
            strategy_id TEXT,
            data TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      }

      // Ensure required column exists in backtest_results
      await _ensureBacktestResultsMarketDataIdColumn(db);

      // Create indexes defensively
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_strategy_created ON strategies(created_at DESC)');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_backtest_strategy ON backtest_results(strategy_id, created_at DESC)');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_market_symbol ON market_data(symbol, timeframe)');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_draft_updated ON strategy_drafts(updated_at DESC)');
      } catch (_) {}
      try {
        await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_market_uploaded ON market_data(uploaded_at DESC)');
      } catch (_) {}
    } catch (_) {
      // Non-fatal; keep DB usable even if validation fails
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
    if (!_backtestResultsColumnChecked) {
      await _ensureBacktestResultsMarketDataIdColumn(db);
      _backtestResultsColumnChecked = true;
    }
    // Normalize any existing rows missing market_data_id
    if (!_backtestResultsNormalized) {
      try {
        await db.rawUpdate(
          "UPDATE backtest_results SET market_data_id = 'unknown' WHERE market_data_id IS NULL OR TRIM(market_data_id) = ''",
        );
      } catch (_) {
        // Safe to ignore if the column just got added and table has no rows yet
      }
      _backtestResultsNormalized = true;
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
      executedAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      summary: BacktestSummary.fromJson(
        jsonDecode(map['summary'] as String),
      ),
      trades: [],
      equityCurve: [],
    );
  }

  /// Get total count of backtest results (fast COUNT query)
  Future<int> getTotalBacktestResultsCount() async {
    final db = await database;
    final res =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM backtest_results');
    if (res.isEmpty) return 0;
    final value = res.first['cnt'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
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

    // Note: Avoid DB writes during read for performance; normalize in-memory

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
    // Avoid DB writes during read; normalize in-memory
    final rawMarketId = map['market_data_id'] as String?;
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
    await db.delete('strategy_drafts');

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

  // ============ STRATEGY DRAFTS (AUTOSAVE) ============

  /// Save a strategy draft. If [strategyId] is provided, the draft is scoped to that strategy.
  /// Otherwise it is treated as the latest unsaved builder draft.
  Future<void> saveStrategyDraft({
    String? strategyId,
    required Map<String, dynamic> draftJson,
  }) async {
    final db = await database;
    final id = strategyId ?? 'builder_draft';
    await db.insert(
      'strategy_drafts',
      {
        'id': id,
        'strategy_id': strategyId,
        'data': jsonEncode(draftJson),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a strategy draft, either for a specific [strategyId] or the latest unsaved builder draft.
  Future<Map<String, dynamic>?> getStrategyDraft({String? strategyId}) async {
    final db = await database;
    if (strategyId != null) {
      final maps = await db.query(
        'strategy_drafts',
        where: 'strategy_id = ?',
        whereArgs: [strategyId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
    } else {
      final maps = await db.query(
        'strategy_drafts',
        where: 'id = ?',
        whereArgs: ['builder_draft'],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return jsonDecode(maps.first['data'] as String) as Map<String, dynamic>;
    }
  }

  /// Clear a strategy draft.
  Future<void> clearStrategyDraft({String? strategyId}) async {
    final db = await database;
    if (strategyId != null) {
      await db.delete(
        'strategy_drafts',
        where: 'strategy_id = ?',
        whereArgs: [strategyId],
      );
    } else {
      await db.delete(
        'strategy_drafts',
        where: 'id = ?',
        whereArgs: ['builder_draft'],
      );
    }
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
