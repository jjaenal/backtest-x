import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import '../helpers/test_helpers.dart';

@Timeout(Duration(seconds: 12))
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  silenceInfoLogsForTests();

  group('Performance - EMA crossover 20k', () {
    test('runs backtest on 20k candles under 7s', () async {
      final candles = generateSyntheticCandles(count: 20000);
      final data = MarketData(
        id: 'synthetic-20k',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: candles,
        uploadedAt: DateTime.now(),
      );

      final strategy = Strategy(
        id: 'ema-close-20',
        name: 'Close vs EMA(20)',
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
            value: ConditionValue.indicator(type: IndicatorType.ema, period: 20),
          ),
        ],
        exitRules: const [
          StrategyRule(
            indicator: IndicatorType.close,
            operator: ComparisonOperator.crossBelow,
            value: ConditionValue.indicator(type: IndicatorType.ema, period: 20),
          ),
        ],
        createdAt: DateTime.now(),
      );

      final engine = BacktestEngineService(indicatorService: IndicatorService());
      final sw = Stopwatch()..start();
      final result = await engine.runBacktest(
        marketData: data,
        strategy: strategy,
      );
      sw.stop();

      expect(result.summary.totalTrades, isNotNull);
      expect(result.summary.totalTrades, greaterThanOrEqualTo(0));
      expect(result.trades.length, equals(result.summary.totalTrades));
      expect(result.equityCurve.length, equals(candles.length));

      expect(sw.elapsed.inSeconds, lessThanOrEqualTo(7));
    }, timeout: const Timeout(Duration(seconds: 12)));
  });
}