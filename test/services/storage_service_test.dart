import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    // Consolidated sqflite init for tests (VM/Web)
    initSqfliteFfiForTests();
  });

  group('StorageService schema validation & repair', () {
    test('adds market_data_id if missing and allows inserts', () async {
      final service = StorageService();
      final db = await service.database;

      // Ensure a strategy exists to satisfy potential FK (if enabled)
      final strategy = Strategy(
        id: 's-test-1',
        name: 'Test Strategy',
        initialCapital: 10000,
        riskManagement: const RiskManagement(
          riskType: RiskType.percentageRisk,
          riskValue: 1.0,
          stopLoss: 100,
          takeProfit: 200,
        ),
        entryRules: const [],
        exitRules: const [],
        createdAt: DateTime.now(),
      );
      await service.saveStrategy(strategy);

      // Simulate legacy table missing market_data_id
      await db.execute('DROP TABLE IF EXISTS backtest_results');
      await db.execute('''
        CREATE TABLE backtest_results (
          id TEXT PRIMARY KEY,
          strategy_id TEXT NOT NULL,
          summary TEXT NOT NULL,
          trades_count INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (strategy_id) REFERENCES strategies (id) ON DELETE CASCADE
        )
      ''');

      // Attempt to save a result; service should repair schema before insert
      final result = BacktestResult(
        id: 'r-test-1',
        strategyId: strategy.id,
        marketDataId: 'm-1',
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

      await service.saveBacktestResult(result);

      // Validate the column exists after operation
      final info = await db.rawQuery('PRAGMA table_info(backtest_results)');
      final hasColumn = info.any((row) => row['name'] == 'market_data_id');
      expect(hasColumn, isTrue);

      // And count increased to 1
      final count = await service.getTotalBacktestResultsCount();
      expect(count, 1);
    });
  });
}
