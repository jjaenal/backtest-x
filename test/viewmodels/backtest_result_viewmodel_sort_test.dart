import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
  });

  tearDownAll(() async {
    await locator.reset();
  });

  BacktestResult buildResultWithTfStats(Map<String, Map<String, num>> tfStats) {
    return BacktestResult(
      id: 'r1',
      strategyId: 's1',
      marketDataId: 'm1',
      executedAt: DateTime.now(),
      trades: const [],
      equityCurve: const [],
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
    );
  }

  group('BacktestResultViewModel per‑TF sorting', () {
    test('sorts by value ascending and descending', () {
      final tfStats = {
        '1m': {'winRate': 45},
        '5m': {'winRate': 55},
        '15m': {'winRate': 40},
      };
      final vm = BacktestResultViewModel(buildResultWithTfStats(tfStats));
      vm.setSelectedTfChartMetric('winRate');

      vm.setTfChartSort(TfChartSort.valueAsc);
      final ascKeys = vm.getTfMetricSeries().keys.toList();
      expect(ascKeys, ['15m', '1m', '5m']);

      vm.setTfChartSort(TfChartSort.valueDesc);
      final descKeys = vm.getTfMetricSeries().keys.toList();
      expect(descKeys, ['5m', '1m', '15m']);
    });

    test('sorts by timeframe key when selected', () {
      final tfStats = {
        '1m': {'winRate': 45},
        '5m': {'winRate': 55},
        '15m': {'winRate': 40},
      };
      final vm = BacktestResultViewModel(buildResultWithTfStats(tfStats));
      vm.setSelectedTfChartMetric('winRate');
      vm.setTfChartSort(TfChartSort.timeframe);

      final sortedByKey = vm.getTfMetricSeries().keys.toList();
      final expected = tfStats.keys.toList()..sort();
      expect(sortedByKey, expected);
    });

    test('places NaN values at the end (asc/desc)', () {
      final tfStats = {
        '1m': {'rr': double.nan},
        '5m': {'rr': 2.0},
        '15m': {'rr': 1.0},
      };
      final vm = BacktestResultViewModel(buildResultWithTfStats(tfStats));
      vm.setSelectedTfChartMetric('rr');

      vm.setTfChartSort(TfChartSort.valueAsc);
      final ascKeys = vm.getTfMetricSeries().keys.toList();
      expect(ascKeys, ['15m', '5m', '1m']);

      vm.setTfChartSort(TfChartSort.valueDesc);
      final descKeys = vm.getTfMetricSeries().keys.toList();
      expect(descKeys, ['5m', '15m', '1m']);
    });

    test('tie‑break by key for equal values (asc/desc)', () {
      final tfStats = {
        '1m': {'winRate': 50},
        '5m': {'winRate': 50},
        '15m': {'winRate': 40},
      };
      final vm = BacktestResultViewModel(buildResultWithTfStats(tfStats));
      vm.setSelectedTfChartMetric('winRate');

      vm.setTfChartSort(TfChartSort.valueAsc);
      final ascKeys = vm.getTfMetricSeries().keys.toList();
      expect(ascKeys, ['15m', '1m', '5m']);

      vm.setTfChartSort(TfChartSort.valueDesc);
      final descKeys = vm.getTfMetricSeries().keys.toList();
      expect(descKeys, ['1m', '5m', '15m']);
    });

    test('returns empty series for empty tfStats', () {
      final tfStats = <String, Map<String, num>>{};
      final vm = BacktestResultViewModel(buildResultWithTfStats(tfStats));
      vm.setSelectedTfChartMetric('winRate');
      vm.setTfChartSort(TfChartSort.valueAsc);
      final keys = vm.getTfMetricSeries().keys.toList();
      expect(keys.isEmpty, true);
    });
  });
}