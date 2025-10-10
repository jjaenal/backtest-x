import 'package:backtestx/models/trade.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';

import '../helpers/test_helpers.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/clipboard_service.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';
import 'package:mockito/mockito.dart';

class TestClipboardService implements ClipboardService {
  String? lastText;
  @override
  Future<void> copyText(String text) async {
    lastText = text;
  }
}

void main() {
  group('BacktestResultViewModel redaction', () {
    setUp(() {
      registerServices();
      // Inject test clipboard
      getAndRegisterClipboardServiceInstance(TestClipboardService());
      // Silence logs, path provider
      silenceInfoLogsForTests();
      mockPathProviderForTests();
    });

    test('copySummaryToClipboard redacts email in strategy name', () async {
      final storage = getAndRegisterStorageService();
      // Strategy name contains email
      final strategy = Strategy(
        id: 'strat-1',
        name: 'Momentum - john.doe@example.com',
        initialCapital: 10000,
        createdAt: DateTime.now(),
        entryRules: const [],
        exitRules: const [],
        riskManagement: const RiskManagement(
          riskType: RiskType.fixedLot,
          riskValue: 100,
        ),
      );
      when(storage.getStrategy('strat-1')).thenAnswer((_) async => strategy);

      // Minimal backtest result stub
      final result = BacktestResult(
        id: 'res-1',
        strategyId: 'strat-1',
        marketDataId: 'EURUSD-H1',
        executedAt: DateTime.now(),
        trades: const [],
        summary: const BacktestSummary(
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
        ),
        equityCurve: const [],
      );

      final vm = BacktestResultViewModel(result);
      await vm.copySummaryToClipboard();

      final clip = locator<ClipboardService>() as TestClipboardService;
      expect(clip.lastText, isNotNull);
      expect(clip.lastText!.contains('example.com'), isFalse);
      expect(clip.lastText!.contains('[email_redacted]'), isTrue);
    });
  });
}
