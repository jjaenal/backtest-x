import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/models/candle.dart';

class StorageService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'backtest_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
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

    // Backtest results table
    await db.execute('''
      CREATE TABLE backtest_results (
        id TEXT PRIMARY KEY,
        strategy_id TEXT NOT NULL,
        summary TEXT NOT NULL,
        trades TEXT NOT NULL,
        equity_curve TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE
      )
    ''');

    // Market data table
    await db.execute('''
      CREATE TABLE market_data (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        timeframe TEXT NOT NULL,
        candles TEXT NOT NULL,
        uploaded_at INTEGER NOT NULL
      )
    ''');

    // Create indexes
    await db
        .execute('CREATE INDEX idx_strategy_created ON strategies(created_at)');
    await db.execute(
        'CREATE INDEX idx_backtest_strategy ON backtest_results(strategy_id)');
    await db.execute(
        'CREATE INDEX idx_market_symbol ON market_data(symbol, timeframe)');
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
  }

  Future<List<Strategy>> getAllStrategies() async {
    final db = await database;
    final maps = await db.query(
      'strategies',
      orderBy: 'created_at DESC',
    );

    return maps.map((map) {
      final config = jsonDecode(map['config'] as String);
      return Strategy.fromJson(config);
    }).toList();
  }

  Future<Strategy?> getStrategy(String id) async {
    final db = await database;
    final maps = await db.query(
      'strategies',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final config = jsonDecode(maps.first['config'] as String);
    return Strategy.fromJson(config);
  }

  Future<void> deleteStrategy(String id) async {
    final db = await database;
    await db.delete(
      'strategies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ BACKTEST RESULTS ============

  Future<void> saveBacktestResult(BacktestResult result) async {
    final db = await database;
    await db.insert(
      'backtest_results',
      {
        'id': result.id,
        'strategy_id': result.strategyId,
        'summary': jsonEncode(result.summary.toJson()),
        'trades': jsonEncode(result.trades.map((t) => t.toJson()).toList()),
        'equity_curve':
            jsonEncode(result.equityCurve.map((e) => e.toJson()).toList()),
        'created_at': result.executedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BacktestResult>> getBacktestResultsByStrategy(
      String strategyId) async {
    final db = await database;
    final maps = await db.query(
      'backtest_results',
      where: 'strategy_id = ?',
      whereArgs: [strategyId],
      orderBy: 'created_at DESC',
    );

    return maps.map((map) {
      return BacktestResult(
        id: map['id'] as String,
        strategyId: map['strategy_id'] as String,
        executedAt:
            DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        summary: BacktestSummary.fromJson(jsonDecode(map['summary'] as String)),
        trades: (jsonDecode(map['trades'] as String) as List)
            .map((t) => Trade.fromJson(t))
            .toList(),
        equityCurve: (jsonDecode(map['equity_curve'] as String) as List)
            .map((e) => EquityPoint.fromJson(e))
            .toList(),
      );
    }).toList();
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
    return BacktestResult(
      id: map['id'] as String,
      strategyId: map['strategy_id'] as String,
      executedAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      summary: BacktestSummary.fromJson(jsonDecode(map['summary'] as String)),
      trades: (jsonDecode(map['trades'] as String) as List)
          .map((t) => Trade.fromJson(t))
          .toList(),
      equityCurve: (jsonDecode(map['equity_curve'] as String) as List)
          .map((e) => EquityPoint.fromJson(e))
          .toList(),
    );
  }

  Future<void> deleteBacktestResult(String id) async {
    final db = await database;
    await db.delete(
      'backtest_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============ MARKET DATA ============

  Future<void> saveMarketData(MarketData data) async {
    final db = await database;
    await db.insert(
      'market_data',
      {
        'id': data.id,
        'symbol': data.symbol,
        'timeframe': data.timeframe,
        'candles': jsonEncode(data.candles.map((c) => c.toJson()).toList()),
        'uploaded_at': data.uploadedAt.millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<MarketData>> getAllMarketData() async {
    final db = await database;
    final maps = await db.query(
      'market_data',
      orderBy: 'uploaded_at DESC',
    );

    return maps.map((map) {
      return MarketData(
        id: map['id'] as String,
        symbol: map['symbol'] as String,
        timeframe: map['timeframe'] as String,
        candles: (jsonDecode(map['candles'] as String) as List)
            .map((c) => Candle.fromJson(c))
            .toList(),
        uploadedAt:
            DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int),
      );
    }).toList();
  }

  Future<MarketData?> getMarketData(String id) async {
    final db = await database;
    final maps = await db.query(
      'market_data',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return MarketData(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      timeframe: map['timeframe'] as String,
      candles: (jsonDecode(map['candles'] as String) as List)
          .map((c) => Candle.fromJson(c))
          .toList(),
      uploadedAt:
          DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int),
    );
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
  }
}
