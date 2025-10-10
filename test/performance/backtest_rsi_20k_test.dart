import 'package:backtestx/models/candle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  silenceInfoLogsForTests();

  group('Performance: RSI 20k candles', () {
    test('RSI threshold strategy executes under 7s', () async {
      final candles = generateSyntheticCandles(count: 20000);

      final marketData = MarketData(
        id: 'synthetic-rsi-20k',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: candles,
        uploadedAt: DateTime.now(),
      );

      // Simple RSI threshold strategy: enter when RSI < 30, exit when RSI > 70
      final strategy = Strategy(
        id: 'rsi-threshold-20k',
        name: 'RSI Threshold 20k',
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
            indicator: IndicatorType.rsi,
            operator: ComparisonOperator.lessThan,
            value: ConditionValue.number(30),
          ),
        ],
        exitRules: const [
          StrategyRule(
            indicator: IndicatorType.rsi,
            operator: ComparisonOperator.greaterThan,
            value: ConditionValue.number(70),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final engine =
          BacktestEngineService(indicatorService: IndicatorService());

      final sw = Stopwatch()..start();
      final result =
          await engine.runBacktest(marketData: marketData, strategy: strategy);
      sw.stop();

      expect(result.trades.isNotEmpty, true,
          reason: 'Should generate trades with RSI thresholds');
      // Performance target: under 7 seconds
      expect(sw.elapsed.inSeconds, lessThanOrEqualTo(7),
          reason: 'Backtest should complete under 7 seconds');
    }, timeout: const Timeout(Duration(seconds: 20)));
  });
}
