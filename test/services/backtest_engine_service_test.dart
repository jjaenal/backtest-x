import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BacktestEngineServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('Throws StateError when market data is empty', () async {
      final service = BacktestEngineService();
      final md = MarketData(
        id: 'md-empty',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: const [],
        uploadedAt: DateTime.now(),
      );
      final strategy = Strategy(
        id: 's-empty',
        name: 'Empty Strategy',
        initialCapital: 10000,
        riskManagement: const RiskManagement(
          riskType: RiskType.fixedLot,
          riskValue: 1,
        ),
        entryRules: const [],
        exitRules: const [],
        createdAt: DateTime.now(),
      );

      expect(
        () => service.runBacktest(marketData: md, strategy: strategy),
        throwsA(isA<StateError>()),
      );
    });

    test('Returns safe empty result when only a single candle is provided', () async {
      final service = BacktestEngineService();
      final now = DateTime.now();
      final md = MarketData(
        id: 'md-one',
        symbol: 'TEST',
        timeframe: 'M1',
        candles: [
          Candle(
            timestamp: now,
            open: 100.0,
            high: 101.0,
            low: 99.5,
            close: 100.5,
            volume: 1000,
          ),
        ],
        uploadedAt: now,
      );
      final strategy = Strategy(
        id: 's-one',
        name: 'Single Candle Strategy',
        initialCapital: 10000,
        riskManagement: const RiskManagement(
          riskType: RiskType.fixedLot,
          riskValue: 1,
        ),
        entryRules: const [],
        exitRules: const [],
        createdAt: now,
      );

      final result = await service.runBacktest(marketData: md, strategy: strategy);

      expect(result.trades, isEmpty);
      expect(result.equityCurve, isEmpty);
      expect(result.summary.totalTrades, 0);
      expect(result.summary.winningTrades, 0);
      expect(result.summary.losingTrades, 0);
      expect(result.summary.totalPnl, 0);
      expect(result.summary.totalPnlPercentage, 0);
      expect(result.summary.profitFactor, 0);
      expect(result.summary.maxDrawdown, 0);
      expect(result.summary.maxDrawdownPercentage, 0);
      expect(result.summary.sharpeRatio, 0);
      expect(result.summary.expectancy, 0);
    });
  });
}
