import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupLocator();
  });

  tearDown(() {
    locator.reset();
  });

  test('generateExportFilename formats and sanitizes properly', () async {
    // Prepare market data in DataManager cache
    final dm = locator<DataManager>();
    final candles = [
      Candle(
        timestamp: DateTime(2024, 1, 1),
        open: 1,
        high: 1,
        low: 1,
        close: 1,
        volume: 0,
      ),
    ];
    final md = MarketData(
      id: 'md1',
      symbol: 'EUR/USD',
      timeframe: 'H4',
      candles: candles,
      uploadedAt: DateTime(2024, 1, 1),
    );
    await dm.cacheData(md);

    const summary = BacktestSummary(
      totalTrades: 0,
      winningTrades: 0,
      losingTrades: 0,
      winRate: 0,
      totalPnl: 0,
      totalPnlPercentage: 0,
      profitFactor: 0,
      maxDrawdown: 0,
      maxDrawdownPercentage: 0,
      sharpeRatio: 0,
      averageWin: 0,
      averageLoss: 0,
      largestWin: 0,
      largestLoss: 0,
      expectancy: 0,
      tfStats: {},
    );

    final result = BacktestResult(
      id: 'r1',
      strategyId: 's1',
      marketDataId: 'md1',
      executedAt: DateTime(2025, 1, 1, 12, 0, 0),
      trades: const [],
      summary: summary,
      equityCurve: const [],
    );

    final vm = BacktestResultViewModel(result);
    final fixedTs = DateTime(2025, 1, 1, 12, 0, 0);

    // Disallowed characters should be replaced and collapsed
    final fname = vm.generateExportFilename(
      baseLabel: 'My:Strategy?*',
      ext: 'pdf',
      timestamp: fixedTs,
    );
    expect(fname, 'EUR_USD_H4_My_Strategy_20250101_120000.pdf');

    // Simple label
    final fname2 = vm.generateExportFilename(
      baseLabel: 'report',
      ext: 'pdf',
      timestamp: fixedTs,
    );
    expect(fname2, 'EUR_USD_H4_report_20250101_120000.pdf');
  });
}
