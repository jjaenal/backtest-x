import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

/// Cache for full backtest results (in-memory)
class ResultCache {
  static final Map<String, BacktestResult> _cache = {};

  static void cache(BacktestResult result) {
    _cache[result.id] = result;
    debugPrint('✅ Cached full result: ${result.id}');
  }

  static BacktestResult? get(String id) {
    return _cache[id];
  }

  static void clear() {
    _cache.clear();
  }
}

/// Helper class for running backtests with cached data
class BacktestHelper {
  final _backtestEngine = locator<BacktestEngineService>();
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _dataManager = DataManager();

  /// Run backtest with cached market data
  Future<BacktestResult?> runBacktestWithCachedData({
    required String marketDataId,
    required Strategy strategy,
    bool saveToDatabase = true,
    bool navigateToResult = false,
  }) async {
    // Get data from cache
    final marketData = _dataManager.getData(marketDataId);

    if (marketData == null) {
      debugPrint('❌ Market data not found in cache: $marketDataId');
      debugPrint('💡 Make sure to upload data first!');
      return null;
    }

    debugPrint('🚀 Running backtest...');
    debugPrint('   Strategy: ${strategy.name}');
    debugPrint('   Data: ${marketData.symbol} ${marketData.timeframe}');
    debugPrint('   Candles: ${marketData.candles.length}');

    // Run backtest
    final result = await _backtestEngine.runBacktest(
      marketData: marketData,
      strategy: strategy,
    );

    debugPrint('✅ Backtest complete!');
    debugPrint('   Trades: ${result.summary.totalTrades}');
    debugPrint('   Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
    debugPrint('   PnL: \${result.summary.totalPnl.toStringAsFixed(2)}');

    // Cache FULL result in memory for viewing
    ResultCache.cache(result);

    // Save to database if requested (summary only for performance)
    if (saveToDatabase) {
      // Save strategy first
      final existingStrategy = await _storageService.getStrategy(strategy.id);
      if (existingStrategy == null) {
        await _storageService.saveStrategy(strategy);
      }

      // Save result (summary only in DB, full result in cache)
      await _storageService.saveBacktestResult(result);
      debugPrint('💾 Saved to database');
    }

    // Navigate to result view if requested
    if (navigateToResult) {
      _navigationService.navigateToBacktestResultView(resultId: result.id);
    }

    return result;
  }

  /// Run backtest on all cached data
  Future<Map<String, BacktestResult>> runBacktestOnAllData({
    required Strategy strategy,
  }) async {
    final allData = _dataManager.getAllData();
    final results = <String, BacktestResult>{};

    for (final data in allData) {
      debugPrint('\n📊 Testing on ${data.symbol} ${data.timeframe}...');
      final result = await _backtestEngine.runBacktest(
        marketData: data,
        strategy: strategy,
      );
      results[data.id] = result;

      // Cache full result
      ResultCache.cache(result);

      debugPrint('   Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
      debugPrint('   PnL: \${result.summary.totalPnl.toStringAsFixed(2)}');
    }

    return results;
  }

  /// Get list of available market data
  List<MarketData> getAvailableData() {
    return _dataManager.getAllData();
  }

  /// Check if data is cached
  bool isDataCached(String marketDataId) {
    return _dataManager.hasData(marketDataId);
  }

  /// Get cached data info
  String getCacheInfo() {
    return _dataManager.getCacheInfo();
  }
}

/// Usage examples:
/// 
/// // Run backtest with cached data
/// final helper = BacktestHelper();
/// final result = await helper.runBacktestWithCachedData(
///   marketDataId: 'your-data-id',
///   strategy: yourStrategy,
///   saveToDatabase: true,
///   navigateToResult: true,
/// );
/// 
/// // Check available data
/// final availableData = helper.getAvailableData();
/// for (final data in availableData) {
///   debugPrint('${data.symbol} ${data.timeframe}: ${data.candles.length} candles');
/// }
/// 
/// // Test strategy on all cached data
/// final results = await helper.runBacktestOnAllData(strategy: strategy);