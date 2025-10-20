import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/models/candle.dart';

import 'test_helpers.dart';
import 'test_helpers.mocks.dart';

/// Standar ukuran viewport untuk golden test
const Size kGoldenViewportSize = Size(393, 852);
const double kGoldenDevicePixelRatio = 1.0;

/// Setup dasar untuk semua golden test
Future<void> setupGoldenTest() async {
  await setupLocator();
  
  // Use in-memory SharedPreferences for tests
  SharedPreferences.setMockInitialValues({});
  
  // Initialize Supabase with dummy values for tests
  try {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'local_test_anon_key',
    );
  } catch (e) {
    // Ignore if already initialized
    if (!e.toString().contains('already initialized')) {
      rethrow;
    }
  }
  
  // Silence info/debug logs in tests
  silenceInfoLogsForTests();
  
  // Mock path_provider to avoid MissingPluginException in tests
  mockPathProviderForTests();
  
  // Disable background warmup to avoid async churn in tests
  DataManager().setBackgroundWarmupEnabled(false);
}

/// Setup viewport dengan ukuran standar untuk golden test
Future<void> setupGoldenViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(kGoldenViewportSize);
  tester.view.devicePixelRatio = kGoldenDevicePixelRatio;
}

/// Pump widget untuk golden test dengan konfigurasi standar
Future<void> pumpWidgetForGolden(
  WidgetTester tester, 
  Widget widget, {
  bool tickerEnabled = false,
}) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: kGoldenViewportSize, 
        devicePixelRatio: kGoldenDevicePixelRatio
      ),
      child: TickerMode(
        enabled: tickerEnabled,
        child: MaterialApp(
          debugShowCheckedModeBanner: false, 
          home: widget,
        ),
      ),
    ),
  );

  // Pump beberapa frame untuk stabilisasi layout tanpa pumpAndSettle
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pump(const Duration(milliseconds: 16));
  await tester.pump(const Duration(milliseconds: 16));
}

/// Setup StorageService dengan data kosong
MockStorageService setupEmptyStorageService() {
  registerServices();
  final storage = locator<StorageService>() as MockStorageService;
  
  when(storage.getAllStrategies()).thenAnswer((_) async => []);
  when(storage.getAllMarketDataInfo()).thenAnswer((_) async => []);
  when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 0);
  when(storage.getLatestBacktestResult()).thenAnswer((_) async => null);
  
  return storage;
}

/// Setup StorageService dengan data strategi dan market data
MockStorageService setupPopulatedStorageService({bool withBacktestResults = true}) {
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

  final mdInfo = MarketDataInfo(
    id: 'mkt1',
    symbol: 'EURUSD',
    timeframe: 'H1',
    candlesCount: 120,
    firstDate: DateTime(2023, 1, 1),
    lastDate: DateTime(2023, 1, 10),
    uploadedAt: DateTime(2023, 1, 10),
  );

  when(storage.getAllStrategies()).thenAnswer((_) async => [strategy]);
  when(storage.getAllMarketDataInfo()).thenAnswer((_) async => [mdInfo]);
  
  if (withBacktestResults) {
    final backtestResult = BacktestResult(
      id: 'bt1',
      strategyId: strategy.id,
      marketDataId: mdInfo.id,
      executedAt: DateTime(2023, 1, 10),
      trades: [
        Trade(
          id: 'trade1',
          entryTime: DateTime(2023, 1, 2),
          entryPrice: 1.1000,
          direction: TradeDirection.buy,
          lotSize: 1.0,
          exitTime: DateTime(2023, 1, 3),
          exitPrice: 1.1100,
          pnl: 100,
          pnlPercentage: 1.0,
        ),
      ],
      summary: const BacktestSummary(
        totalTrades: 10,
        winningTrades: 7,
        losingTrades: 3,
        winRate: 70,
        totalPnl: 2000,
        totalPnlPercentage: 20,
        profitFactor: 2.5,
        maxDrawdown: -500,
        maxDrawdownPercentage: -5,
        sharpeRatio: 1.2,
        averageWin: 400,
        averageLoss: -200,
        largestWin: 800,
        largestLoss: -300,
        expectancy: 200,
        tfStats: {},
      ),
      equityCurve: [
        EquityPoint(
          timestamp: DateTime(2023, 1, 1),
          equity: 10000,
          drawdown: 0,
        ),
        EquityPoint(
          timestamp: DateTime(2023, 1, 10),
          equity: 12000,
          drawdown: -200,
        ),
      ],
    );
    
    when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 1);
    when(storage.getLatestBacktestResult()).thenAnswer((_) async => backtestResult);
  } else {
    when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 0);
    when(storage.getLatestBacktestResult()).thenAnswer((_) async => null);
  }
  
  // Siapkan candles untuk DataManager
  final candles = List.generate(
    120,
    (i) => Candle(
      timestamp: DateTime(2023, 1, 1).add(Duration(hours: i)),
      open: 1.1000 + (i * 0.0001),
      high: 1.1010 + (i * 0.0001),
      low: 0.9990 + (i * 0.0001),
      close: 1.1005 + (i * 0.0001),
      volume: 100,
    ),
  );
  
  // Cache market data di DataManager
  final dm = DataManager();
  final marketData = MarketData(
    id: mdInfo.id,
    symbol: mdInfo.symbol,
    timeframe: mdInfo.timeframe,
    candles: candles,
    uploadedAt: mdInfo.uploadedAt,
  );
  dm.cacheData(marketData);
  
  return storage;
}

/// Verifikasi golden test dengan nama file yang diberikan
Future<void> verifyGolden(WidgetTester tester, Finder finder, String goldenFileName) async {
  await expectLater(
    finder,
    matchesGoldenFile('goldens/$goldenFileName.png'),
  );
}