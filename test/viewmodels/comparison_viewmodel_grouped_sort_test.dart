import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/views/comparison/comparison_viewmodel.dart';
import 'package:backtestx/app/app.locator.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
  });

  tearDownAll(() async {
    await locator.reset();
  });

  BacktestResult makeResult(String id, Map<String, Map<String, num>> tfStats) {
    return BacktestResult(
      id: id,
      strategyId: 'S$id',
      marketDataId: 'MD$id',
      executedAt: DateTime.now(),
      trades: const [],
      summary: BacktestSummary(
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
        tfStats: tfStats,
      ),
      equityCurve: const [],
    );
  }

  test(
      'Grouped sorting places invalid (NaN) timeframe last with avg aggregation',
      () {
    final r1 = makeResult('1', {
      'M15': {'winRate': 50},
      'H1': {'winRate': 60},
      'TFX': {'winRate': double.nan},
    });
    final r2 = makeResult('2', {
      'M15': {'winRate': 40},
      'H1': {'winRate': 30},
      'TFX': {'winRate': double.nan},
    });

    final model = ComparisonViewModel([r1, r2]);
    model.setSelectedTfMetric('winRate');
    model.setGroupedTfAgg('avg');
    model.setGroupedTfSort('valueAsc');

    final order = model.getTimeframeOrderForGrouped();
    // H1 avg = 45, M15 avg = 45 (tie -> key ascending), TFX invalid -> last
    expect(order, ['H1', 'M15', 'TFX']);
  });

  test('Grouped sorting stable tie-breaking by key for equal values (desc)',
      () {
    final r1 = makeResult('1', {
      'M15': {'winRate': 50},
      'H1': {'winRate': 50},
    });
    final r2 = makeResult('2', {
      'M15': {'winRate': 50},
      'H1': {'winRate': 50},
    });

    final model = ComparisonViewModel([r1, r2]);
    model.setSelectedTfMetric('winRate');
    model.setGroupedTfAgg('avg');
    model.setGroupedTfSort('valueDesc');

    final order = model.getTimeframeOrderForGrouped();
    // Equal values -> timeframe key ascending for deterministic order
    expect(order, ['H1', 'M15']);
  });

  test('Grouped sorting returns empty order when no data', () {
    final r1 = makeResult('1', {});
    final r2 = makeResult('2', {});
    final model = ComparisonViewModel([r1, r2]);
    model.setSelectedTfMetric('winRate');
    model.setGroupedTfAgg('avg');
    model.setGroupedTfSort('valueAsc');

    final order = model.getTimeframeOrderForGrouped();
    expect(order, isEmpty);
  });
}
