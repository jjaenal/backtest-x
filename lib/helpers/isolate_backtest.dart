import 'dart:isolate';
import 'dart:convert';
import 'dart:async';

import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/app/app.locator.dart';

/// Run backtest in a background isolate to avoid blocking UI.
/// Uses JSON serialization to ensure isolate-safe message passing.
class IsolateBacktest {
  static Future<BacktestResult> run({
    required Strategy strategy,
    required MarketData marketData,
  }) async {
    // Serialize inputs to isolate-safe strings
    final strategyJsonStr = jsonEncode(strategy.toJson());
    final marketJsonStr = jsonEncode(marketData.toJson());

    // ReceivePort for progress and final result messages
    final rp = ReceivePort();
    final completer = Completer<BacktestResult>();

    try {
      await Isolate.spawn(_isolateEntry, {
        'strategy': strategyJsonStr,
        'marketData': marketJsonStr,
        'sendPort': rp.sendPort,
      });

      final storage = locator<StorageService>();
      rp.listen((message) {
        if (message is Map) {
          final type = message['type'] as String?;
          if (type == 'progress') {
            final p = (message['progress'] as num).toDouble();
            final tfStatsRaw = message['tfStats'];
            Map<String, Map<String, num>>? tfStats;
            if (tfStatsRaw is Map) {
              tfStats = tfStatsRaw.map((tf, metrics) {
                if (metrics is Map) {
                  final casted = metrics
                      .map((mk, mv) => MapEntry(mk.toString(), (mv as num)));
                  return MapEntry(tf.toString(), casted);
                }
                return MapEntry(tf.toString(), <String, num>{});
              });
            }
            storage.emitBacktestProgress(
              BacktestProgressEvent(
                strategyId: strategy.id,
                marketDataId: marketData.id,
                progress: p,
                tfStats: tfStats,
              ),
            );
          } else if (type == 'result') {
            final resultJsonStr = message['data'] as String;
            final resultJson =
                jsonDecode(resultJsonStr) as Map<String, dynamic>;
            completer.complete(BacktestResult.fromJson(resultJson));
            rp.close();
          }
        }
      });
    } catch (_) {
      // Fallback: run on main isolate with progress directly
      final engine =
          BacktestEngineService(indicatorService: IndicatorService());
      StorageService? storageSafe;
      try {
        storageSafe = locator<StorageService>();
      } catch (_) {
        storageSafe = null;
      }
      final result = await engine.runBacktest(
        marketData: marketData,
        strategy: strategy,
        onProgress: (p) {
          final s = storageSafe;
          if (s != null) {
            s.emitBacktestProgress(
              BacktestProgressEvent(
                strategyId: strategy.id,
                marketDataId: marketData.id,
                progress: p,
                tfStats: engine.lastTfStats,
              ),
            );
          }
        },
      );
      return result;
    }

    return completer.future;
  }
}

// Isolate entry function
void _isolateEntry(Map args) async {
  final sendPort = args['sendPort'] as SendPort;
  final strategyJsonStr = args['strategy'] as String;
  final marketJsonStr = args['marketData'] as String;

  final st =
      Strategy.fromJson(jsonDecode(strategyJsonStr) as Map<String, dynamic>);
  final md =
      MarketData.fromJson(jsonDecode(marketJsonStr) as Map<String, dynamic>);

  final engine = BacktestEngineService(indicatorService: IndicatorService());
  final result = await engine.runBacktest(
    marketData: md,
    strategy: st,
    onProgress: (p) {
      try {
        sendPort.send({
          'type': 'progress',
          'progress': p,
          'tfStats': engine.lastTfStats,
        });
      } catch (_) {}
    },
  );
  sendPort.send({
    'type': 'result',
    'data': jsonEncode(result.toJson()),
  });
}
