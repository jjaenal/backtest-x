import 'package:backtestx/models/candle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/helpers/isolate_backtest.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Stress: Isolate 100k candles', () {
    test('Backtest 100k via isolate finishes under 15s', () async {
      final candles = generateSyntheticCandles(count: 100000);

      final marketData = MarketData(
        id: 'synthetic-iso-100k',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: candles,
        uploadedAt: DateTime.now(),
      );

      // Use SMA crossover to exercise indicator precalculation
      final strategy = Strategy(
        id: 'sma-close-14-100k',
        name: 'Close vs SMA(14) 100k',
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

      final sw = Stopwatch()..start();
      final result =
          await IsolateBacktest.run(marketData: marketData, strategy: strategy);
      sw.stop();

      expect(result.trades.isNotEmpty, true,
          reason: 'Should produce trades on large dataset');
      expect(sw.elapsed.inSeconds, lessThanOrEqualTo(15),
          reason: 'Isolate backtest should complete under 15 seconds');
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
