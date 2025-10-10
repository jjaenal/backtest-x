import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/clipboard_service.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';
import '../helpers/test_helpers.dart';

class TestClipboardService extends ClipboardService {
  String? capturedText;
  @override
  Future<void> copyText(String text) async {
    capturedText = text;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await setupLocator();
    registerServices();
  });

  tearDown(() {
    locator.reset();
  });

  test(
      'copySummaryToClipboard writes summary including BacktestResult deep link',
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
    ];
    final md = MarketData(
      id: 'md-copy',
      symbol: 'EURUSD',
      timeframe: 'H1',
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
      averageLoss: -5,
      largestWin: 10,
      largestLoss: -5,
      expectancy: 5,
      tfStats: const {},
    );

    final result = BacktestResult(
      id: 'r-copy-1',
      strategyId: 's-abc',
      marketDataId: 'md-copy',
      executedAt: DateTime(2024, 1, 1, 12, 0, 0),
      trades: const <Trade>[],
      summary: summary,
      equityCurve: const [],
    );

    final vm = BacktestResultViewModel(result);

    // Register a test clipboard service instance to capture writes
    final clipboard = TestClipboardService();
    getAndRegisterClipboardServiceInstance(clipboard);

    await vm.copySummaryToClipboard();

    // Validate clipboard text contains deep link
    final deepLinks = locator<DeepLinkService>();
    final expectedLink = deepLinks.buildBacktestResultLink(resultId: result.id);
    expect(clipboard.capturedText, isNotNull);
    expect(clipboard.capturedText!.contains(expectedLink), isTrue);
  });
}
