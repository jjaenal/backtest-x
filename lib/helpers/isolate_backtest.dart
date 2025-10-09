import 'dart:isolate';
import 'dart:convert';

import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';

/// Run backtest in a background isolate to avoid blocking UI.
/// Uses JSON serialization to ensure isolate-safe message passing.
class IsolateBacktest {
  static Future<BacktestResult> run({
    required Strategy strategy,
    required MarketData marketData,
  }) async {
    // Use JSON strings to ensure nested Freezed objects are serialized into Maps
    final strategyJsonStr = jsonEncode(strategy.toJson());
    final marketJsonStr = jsonEncode(marketData.toJson());

    String resultJsonStr;
    try {
      resultJsonStr = await Isolate.run(() async {
        final st = Strategy.fromJson(
            jsonDecode(strategyJsonStr) as Map<String, dynamic>);
        final md = MarketData.fromJson(
            jsonDecode(marketJsonStr) as Map<String, dynamic>);
        // Construct engine with local IndicatorService, no locator dependency
        final engine = BacktestEngineService(
          indicatorService: IndicatorService(),
        );
        final result = await engine.runBacktest(
          marketData: md,
          strategy: st,
        );
        return jsonEncode(result.toJson());
      });
    } catch (_) {
      // Fallback: execute on main isolate if Isolate.run is unavailable
      final st = Strategy.fromJson(
          jsonDecode(strategyJsonStr) as Map<String, dynamic>);
      final md = MarketData.fromJson(
          jsonDecode(marketJsonStr) as Map<String, dynamic>);
      final engine = BacktestEngineService();
      final result = await engine.runBacktest(
        marketData: md,
        strategy: st,
      );
      resultJsonStr = jsonEncode(result.toJson());
    }
    final resultJson = jsonDecode(resultJsonStr) as Map<String, dynamic>;
    return BacktestResult.fromJson(resultJson);
  }
}
