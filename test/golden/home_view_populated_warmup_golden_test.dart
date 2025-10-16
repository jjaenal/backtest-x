import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';

import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
    // Silence info/debug logs in tests
    silenceInfoLogsForTests();
  });
  tearDownAll(() => locator.reset());

  testGoldens('HomeView - populated + warm-up indicator', (tester) async {
    await loadAppFonts();

    // Deterministic viewport
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.view.devicePixelRatio = 1.0;

    // Mock path_provider to avoid MissingPluginException in tests
    mockPathProviderForTests();

    // Register mocks and stub StorageService
    registerServices();
    final storage = locator<StorageService>() as MockStorageService;

    final strategy = Strategy(
      id: 'strat1',
      name: 'Test Strategy',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.fixedLot,
        riskValue: 1.0,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.equals,
          value: ConditionValue.number(0),
        ),
      ],
      exitRules: const [],
      createdAt: DateTime(2023, 1, 1),
    );

    when(storage.getAllStrategies()).thenAnswer((_) async => [strategy]);

    final mdInfo = MarketDataInfo(
      id: 'mkt1',
      symbol: 'EURUSD',
      timeframe: 'H1',
      candlesCount: 120,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime(2023, 1, 10),
      uploadedAt: DateTime(2023, 1, 10),
    );
    when(storage.getAllMarketDataInfo()).thenAnswer((_) async => [mdInfo]);
    when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 1);

    const summary = BacktestSummary(
      totalTrades: 10,
      winningTrades: 6,
      losingTrades: 4,
      winRate: 60.0,
      totalPnl: 1234.0,
      totalPnlPercentage: 12.34,
      profitFactor: 1.5,
      maxDrawdown: -200.0,
      maxDrawdownPercentage: -2.0,
      sharpeRatio: 1.2,
      averageWin: 200.0,
      averageLoss: -150.0,
      largestWin: 500.0,
      largestLoss: -300.0,
      expectancy: 12.0,
      tfStats: {},
    );
    final latest = BacktestResult(
      id: 'res1',
      strategyId: strategy.id,
      marketDataId: mdInfo.id,
      executedAt: DateTime(2023, 1, 11),
      trades: const [],
      summary: summary,
      equityCurve: const [],
    );
    when(storage.getLatestBacktestResult()).thenAnswer((_) async => latest);
    when(storage.getStrategy(strategy.id)).thenAnswer((_) async => strategy);

    // Prepare DataManager: disable background warm-up; force warm-up indicator ON
    final dm = locator<DataManager>();
    dm.setBackgroundWarmupEnabled(false);
    dm.warmupNotifier.value = true;

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(393, 852), devicePixelRatio: 1.0),
        child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
      ),
    );

    // Pump beberapa frame agar layout stabil tanpa menunggu animasi/stream selesai
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    await expectLater(
      find.byType(HomeView),
      matchesGoldenFile('goldens/home_view_populated_warmup.png'),
    );
  });
}
