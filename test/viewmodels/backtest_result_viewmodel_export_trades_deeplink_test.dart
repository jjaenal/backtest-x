import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:mockito/mockito.dart';
import '../helpers/test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupLocator();
    registerServices();
    // Mock path_provider to avoid MissingPluginException in VM tests
    mockPathProviderForTests();
  });

  tearDown(() {
    locator.reset();
  });

  test('exportTradeHistory shares text that includes BacktestResult deep link',
      () async {
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
        open: 1.1,
        high: 1.2,
        low: 0.9,
        close: 1.15,
        volume: 0,
      ),
    ];
    final md = MarketData(
      id: 'md-trades',
      symbol: 'EURUSD',
      timeframe: 'H1',
      candles: candles,
      uploadedAt: DateTime(2024, 1, 1),
    );
    await dm.cacheData(md);

    // One closed trade so export has data
    final trade = Trade(
      id: 't1',
      direction: TradeDirection.buy,
      entryTime: DateTime(2024, 1, 1),
      exitTime: DateTime(2024, 1, 2),
      entryPrice: 1.0000,
      exitPrice: 1.1000,
      lotSize: 1,
      stopLoss: 0.9000,
      takeProfit: 1.2000,
      pnl: 100.0,
      pnlPercentage: 10.0,
      status: TradeStatus.closed,
      entryTimeframes: const ['H1'],
    );

    final summary = const BacktestSummary(
      totalTrades: 1,
      winningTrades: 1,
      losingTrades: 0,
      winRate: 100,
      totalPnl: 100,
      totalPnlPercentage: 10.0,
      profitFactor: 2.0,
      maxDrawdown: 0,
      maxDrawdownPercentage: 0.0,
      sharpeRatio: 0.0,
      averageWin: 100,
      averageLoss: 0,
      largestWin: 100,
      largestLoss: 0,
      expectancy: 100,
      tfStats: {
        'H1': {
          'signals': 1,
          'trades': 1,
          'wins': 1,
          'winRate': 100.0,
          'profitFactor': 2.0,
          'expectancy': 100.0,
          'avgWin': 100.0,
          'avgLoss': 0.0,
          'rr': 2.0,
        },
      },
    );

    final result = BacktestResult(
      id: 'r-tr-999',
      strategyId: 's-xyz',
      marketDataId: 'md-trades',
      executedAt: DateTime(2025, 1, 1, 12, 0, 0),
      trades: [trade],
      summary: summary,
      equityCurve: const [],
    );

    final vm = BacktestResultViewModel(result);

    // Stub ShareService to capture shared text
    final mockShare = getAndRegisterShareService();
    String? capturedText;
    when(mockShare.shareFilePath(
      any,
      text: anyNamed('text'),
      mimeType: anyNamed('mimeType'),
      filename: anyNamed('filename'),
    )).thenAnswer((invocation) {
      final named = invocation.namedArguments;
      capturedText = named[const Symbol('text')] as String?;
      return Future.value();
    });

    // Execute export
    await vm.exportTradeHistory(format: 'csv');

    // Validate shared text contains deep link
    final deepLinks = locator<DeepLinkService>();
    final expectedLink = deepLinks.buildBacktestResultLink(resultId: result.id);
    expect(capturedText, isNotNull);
    expect(capturedText!.contains(expectedLink), isTrue);
  });
}
