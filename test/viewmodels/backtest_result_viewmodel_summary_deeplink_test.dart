import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';
import '../helpers/test_helpers.dart';
import 'package:mockito/mockito.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupLocator();
    registerServices();
    // Override DeepLinkService to produce deterministic links
    if (locator.isRegistered<DeepLinkService>()) {
      locator.unregister<DeepLinkService>();
    }
    locator.registerSingleton<DeepLinkService>(
      DeepLinkService(
        baseUrlOverride: 'http://example.com',
        useHashRoutingOverride: false,
      ),
    );
  });

  tearDown(() {
    locator.reset();
  });

  test('summary text includes deep link to backtest result', () async {
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
      Candle(
        timestamp: DateTime(2024, 1, 2),
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
      totalTrades: 1,
      winningTrades: 1,
      losingTrades: 0,
      winRate: 100,
      totalPnl: 10,
      totalPnlPercentage: 1.5,
      profitFactor: 2.0,
      maxDrawdown: 0,
      maxDrawdownPercentage: 0,
      sharpeRatio: 1.0,
      averageWin: 10,
      averageLoss: 0,
      largestWin: 10,
      largestLoss: 0,
      expectancy: 10,
      tfStats: {},
    );

    final result = BacktestResult(
      id: 'res-123',
      strategyId: 's1',
      marketDataId: 'md1',
      executedAt: DateTime(2025, 1, 1, 12, 0, 0),
      trades: const [],
      summary: summary,
      equityCurve: const [],
    );

    final vm = BacktestResultViewModel(result);

    // Capture shared text via ShareService mock
    final mockShare = getAndRegisterShareService();
    String? capturedText;
    when(mockShare.shareText(any, subject: anyNamed('subject')))
        .thenAnswer((invocation) async {
      capturedText = invocation.positionalArguments[0] as String;
      return Future.value();
    });

    await vm.shareResults();

    expect(capturedText, isNotNull);
    expect(
      capturedText!,
      contains('http://example.com/backtest-result-view?id=res-123'),
    );
    expect(
      capturedText!,
      contains('🔗 View full results:'),
    );
  });
}
