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

  test('exportTfStats shares text that includes BacktestResult deep link',
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
        open: 1,
        high: 1,
        low: 1,
        close: 1,
        volume: 0,
      ),
    ];
    final md = MarketData(
      id: 'md-tf',
      symbol: 'EURUSD',
      timeframe: 'H1',
      candles: candles,
      uploadedAt: DateTime(2024, 1, 1),
    );
    await dm.cacheData(md);

    // Summary with per-timeframe stats available
    final summary = const BacktestSummary(
      totalTrades: 2,
      winningTrades: 1,
      losingTrades: 1,
      winRate: 50,
      totalPnl: 10,
      totalPnlPercentage: 1.0,
      profitFactor: 1.1,
      maxDrawdown: 5,
      maxDrawdownPercentage: 0.5,
      sharpeRatio: 0.0,
      averageWin: 12,
      averageLoss: -10,
      largestWin: 20,
      largestLoss: -15,
      expectancy: 1.0,
      tfStats: {
        'H1': {
          'signals': 3,
          'trades': 2,
          'wins': 1,
          'winRate': 50.0,
          'profitFactor': 1.2,
          'expectancy': 0.5,
          'avgWin': 12.0,
          'avgLoss': -10.0,
          'rr': 1.3,
        },
      },
    );

    final result = BacktestResult(
      id: 'r-tf-123',
      strategyId: 's-abc',
      marketDataId: 'md-tf',
      executedAt: DateTime(2025, 1, 1, 12, 0, 0),
      trades: const [],
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
    await vm.exportTfStats(format: 'csv');

    // Validate shared text contains deep link
    final deepLinks = locator<DeepLinkService>();
    final expectedLink = deepLinks.buildBacktestResultLink(resultId: result.id);
    expect(capturedText, isNotNull);
    expect(capturedText!.contains(expectedLink), isTrue);

    // Ensure file got written (path_provider mocked to temp dir)
    // We can't easily know the exact path here, but the operation should succeed without throwing.
  });
}
