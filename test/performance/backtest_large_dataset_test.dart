@Timeout(Duration(seconds: 10))
import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  silenceInfoLogsForTests();

  group('Performance - Backtest large dataset', () {
    test('runs backtest on 12k candles under 5s', () async {
      final candles = generateSyntheticCandles(count: 12000);
      final data = MarketData(
        id: 'synthetic-12k',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: candles,
        uploadedAt: DateTime.now(),
      );

      final strategy = Strategy(
        id: 'sma-close',
        name: 'Close vs SMA(14)',
        initialCapital: 10000.0,
        riskManagement: const RiskManagement(
          riskType: RiskType.fixedLot,
          riskValue: 0.1,
          stopLoss: 50,
          takeProfit: 100,
          useTrailingStop: false,
        ),
        entryRules: const [
          StrategyRule(
            indicator: IndicatorType.close,
            operator: ComparisonOperator.crossAbove,
            value:
                ConditionValue.indicator(type: IndicatorType.sma, period: 14),
          ),
        ],
        exitRules: const [
          StrategyRule(
            indicator: IndicatorType.close,
            operator: ComparisonOperator.crossBelow,
            value:
                ConditionValue.indicator(type: IndicatorType.sma, period: 14),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final engine =
          BacktestEngineService(indicatorService: IndicatorService());
      final sw = Stopwatch()..start();
      final result = await engine.runBacktest(
        marketData: data,
        strategy: strategy,
      );
      sw.stop();

      // Basic invariants
      expect(result.summary.totalTrades, isNotNull);
      expect(result.summary.totalTrades, greaterThanOrEqualTo(0));
      expect(result.trades.length, equals(result.summary.totalTrades));
      expect(result.equityCurve.length, equals(candles.length));

      // Performance expectation (non-strict, to avoid flakiness on CI)
      expect(sw.elapsed.inSeconds, lessThanOrEqualTo(5));
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
