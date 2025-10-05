import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/gold_strategy.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

/// Helper to run backtest and navigate to result view
class BacktestTestHelper {
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _backtestEngine = locator<BacktestEngineService>();

  /// Run backtest, save it, and navigate to result view
  Future<void> runAndShowBacktest({
    required MarketData marketData,
    required Strategy strategy,
  }) async {
    debugPrint('🚀 Running backtest for: ${strategy.name}');

    // 1. Run backtest
    final result = await _backtestEngine.runBacktest(
      marketData: marketData,
      strategy: strategy,
    );

    debugPrint('✅ Backtest completed:');
    debugPrint('   Trades: ${result.summary.totalTrades}');
    debugPrint('   Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
    debugPrint('   PnL: \$${result.summary.totalPnl.toStringAsFixed(2)}');

    // 2. Save strategy if not exists
    final existingStrategy = await _storageService.getStrategy(strategy.id);
    if (existingStrategy == null) {
      await _storageService.saveStrategy(strategy);
      debugPrint('✅ Strategy saved');
    }

    // 3. Save result
    await _storageService.saveBacktestResult(result);
    debugPrint('✅ Result saved with ID: ${result.id}');

    // 4. Navigate to result view
    _navigationService.navigateToBacktestResultView(resultId: result.id);
    debugPrint('✅ Navigated to result view');
  }

  Future<void> testEmaCrossover(MarketData marketData) async {
    final strategy = GoldStrategies.emaCrossover();
    await runAndShowBacktest(
      marketData: marketData,
      strategy: strategy,
    );
  }

  /// Quick test with Gold Conservative strategy
  Future<void> testGoldConservative(MarketData xauusdData) async {
    final strategy = Strategy(
      id: 'test-gold-conservative',
      name: 'Gold Conservative Test',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 350,
        takeProfit: 700,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(35),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(60),
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(75),
        ),
      ],
      createdAt: DateTime.now(),
    );

    await runAndShowBacktest(
      marketData: xauusdData,
      strategy: strategy,
    );
  }
}

/// Usage in your main app or test:
///
/// // After loading data
/// final helper = BacktestTestHelper();
/// await helper.testGoldConservative(xauusdData);
///
/// // This will automatically navigate to the result view!
