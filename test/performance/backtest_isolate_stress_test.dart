import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/helpers/isolate_backtest.dart';
import '../helpers/test_helpers.dart';

@Timeout(Duration(seconds: 20))
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  silenceInfoLogsForTests();

  group('Performance - Isolate Backtest stress test', () {
    test('runs isolate backtest on 50k candles under 8s', () async {
      // Generate large synthetic dataset
      final candles = generateSyntheticCandles(count: 50000);
      final data = MarketData(
        id: 'synthetic-50k',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: candles,
        uploadedAt: DateTime.now(),
      );

      // Simple SMA crossover strategy to exercise indicator precalc and rule eval
      final strategy = Strategy(
        id: 'sma-close-20',
        name: 'Close vs SMA(20)',
        initialCapital: 10000.0,
        riskManagement: const RiskManagement(
          riskType: RiskType.percentageRisk,
          riskValue: 1.0,
          stopLoss: 50,
          takeProfit: 100,
          useTrailingStop: false,
        ),
        entryRules: const [
          StrategyRule(
            indicator: IndicatorType.close,
            operator: ComparisonOperator.crossAbove,
            value:
                ConditionValue.indicator(type: IndicatorType.sma, period: 20),
          ),
        ],
        exitRules: const [
          StrategyRule(
            indicator: IndicatorType.close,
            operator: ComparisonOperator.crossBelow,
            value:
                ConditionValue.indicator(type: IndicatorType.sma, period: 20),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final sw = Stopwatch()..start();
      final result =
          await IsolateBacktest.run(strategy: strategy, marketData: data);
      sw.stop();

      // Basic invariants
      expect(result.summary.totalTrades, isNotNull);
      expect(result.summary.totalTrades, greaterThanOrEqualTo(0));
      expect(result.trades.length, equals(result.summary.totalTrades));
      expect(result.equityCurve.length, equals(candles.length));

      // Performance expectation (isolate should be able to handle 50k under 8s)
      expect(sw.elapsed.inSeconds, lessThanOrEqualTo(8));
    }, timeout: const Timeout(Duration(seconds: 20)));
  });
}
