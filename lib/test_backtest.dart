/// Example strategies untuk testing backtest engine
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/debug/debug_helper.dart';
import 'package:backtestx/debug/quick_debug.dart';
import 'package:backtestx/debug/strategy_debuger.dart';
import 'package:backtestx/gold_strategy.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/test_single_rule.dart';
import 'package:backtestx/test_strategy.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  debugPrint('🚀 Starting Backtest Test...\n');

  // Create services
  // final indicatorService = IndicatorService();
  // final backtestEngine = BacktestEngineService();
  // final debugHelper = BacktestDebugHelper();
  // final debugger = StrategyDebugger();

  // Generate realistic test data (200 candles trending up)
  // final storageService = locator<StorageService>();
  // final marketData = await storageService.getAllMarketData();
  // final marketFakeData = _generateTestData();
  // debugPrint('✅ Generated ${marketData.first.candles.length} candles');
  // debugPrint(
  //     '   Price range: ${marketData.first.candles.first.close} → ${marketData.first.candles.last.close}\n');

  // final bestStrategy = ExampleStrategies.getAllExamples();
  // final strategies = GoldStrategies.getAllGoldStrategies();

  // quickDebug(marketData.first.candles);
  // testSingleRule(marketData.first.candles);

  // for (var strategy in strategies) {
  // for (final rule in strategy.entryRules) {
  //   print('Rule: ${rule.indicator.name} ${rule.operator.name}');
  //   rule.value.when(
  //     number: (n) => print('  Compare with: $n'),
  //     indicator: (type, period) =>
  //         print('  Compare with: ${type.name}($period)'),
  //   );
  // }

  // debugger.debugStrategy(marketData.first.candles, strategy);
  // debugPrint('📊 Test ${strategy.name} Strategy');
  // await _runTest(backtestEngine, marketData.first, strategy);
  //   debugPrint('\n🧪 Testing: ${strategy.name}');
  //   final result = await backtestEngine.runBacktest(
  //     marketData: marketData.first,
  //     strategy: strategy,
  //     debug: true,
  //   );
  //   debugPrint('Trades: ${result.summary.totalTrades}');
  //   debugPrint('Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
  //   debugPrint('PnL: \$${result.summary.totalPnl.toStringAsFixed(2)}');
  // }

  // // Test 1: Simple RSI Strategy (easier to trigger)
  // debugPrint('📊 Test 1: Simple RSI Oversold/Overbought Strategy');
  // final rsiStrategy = _createSimpleRSIStrategy();
  // debugHelper.debugStrategy(marketData.first.candles, rsiStrategy);
  // await _runTest(backtestEngine, marketData.first, rsiStrategy);

  // // Test 2: SMA Crossover (with shorter period)
  // debugPrint('\n📊 Test 2: SMA Crossover Strategy (Short Period)');
  // final smaStrategy = _createSMACrossStrategy();
  // debugHelper.debugStrategy(marketData.first.candles, smaStrategy);
  // await _runTest(backtestEngine, marketData.first, smaStrategy);

  // // Test 3: Debug indicators
  // debugPrint('\n🔍 Debug: Checking Indicator Values');
  // _debugIndicators(indicatorService, marketData.first.candles);
}

Future<void> _runTest(
  BacktestEngineService engine,
  MarketData marketData,
  Strategy strategy,
) async {
  try {
    debugPrint('Strategy: ${strategy.name}');
    debugPrint('Initial Capital: \$${strategy.initialCapital}');

    final result = await engine.runBacktest(
      marketData: marketData,
      strategy: strategy,
    );

    debugPrint('\n📈 Results:');
    debugPrint('   Total Trades: ${result.summary.totalTrades}');
    debugPrint('   Winning Trades: ${result.summary.winningTrades}');
    debugPrint('   Losing Trades: ${result.summary.losingTrades}');
    debugPrint('   Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
    debugPrint('   Total PnL: \$${result.summary.totalPnl.toStringAsFixed(2)}');
    debugPrint(
        '   PnL %: ${result.summary.totalPnlPercentage.toStringAsFixed(2)}%');
    debugPrint(
        '   Profit Factor: ${result.summary.profitFactor.toStringAsFixed(2)}');
    debugPrint(
        '   Max Drawdown: \$${result.summary.maxDrawdown.toStringAsFixed(2)} (${result.summary.maxDrawdownPercentage.toStringAsFixed(2)}%)');
    debugPrint(
        '   Sharpe Ratio: ${result.summary.sharpeRatio.toStringAsFixed(2)}');
    debugPrint(
        '   Expectancy: \$${result.summary.expectancy.toStringAsFixed(2)}');

    if (result.trades.isNotEmpty) {
      debugPrint('\n   First 3 trades:');
      for (var i = 0; i < result.trades.length && i < 3; i++) {
        final trade = result.trades[i];
        debugPrint(
            '   ${i + 1}. ${trade.direction.name.toUpperCase()} @ ${trade.entryPrice} → ${trade.exitPrice} | PnL: \$${trade.pnl?.toStringAsFixed(2)} (${trade.exitReason})');
      }
    } else {
      debugPrint('   ⚠️  No trades executed!');
    }
  } catch (e, stackTrace) {
    debugPrint('❌ Error running backtest: $e');
    debugPrint(stackTrace.toString());
  }
}

void _debugIndicators(IndicatorService service, List<Candle> candles) {
  // Check RSI
  final rsi = service.calculateRSI(candles, 14);
  final validRSI = rsi.where((r) => r != null).toList();
  if (validRSI.isNotEmpty) {
    debugPrint(
        'RSI(14): First valid = ${validRSI.first?.toStringAsFixed(2)}, Last = ${validRSI.last?.toStringAsFixed(2)}');
    debugPrint(
        '         Min = ${validRSI.reduce((a, b) => a! < b! ? a : b)?.toStringAsFixed(2)}, Max = ${validRSI.reduce((a, b) => a! > b! ? a : b)?.toStringAsFixed(2)}');
  }

  // Check SMA
  final sma20 = service.calculateSMA(candles, 20);
  final validSMA = sma20.where((s) => s != null).toList();
  if (validSMA.isNotEmpty) {
    debugPrint(
        'SMA(20): First valid = ${validSMA.first?.toStringAsFixed(4)}, Last = ${validSMA.last?.toStringAsFixed(4)}');
  }

  // Check closes
  debugPrint(
      'Close: First = ${candles.first.close}, Last = ${candles.last.close}');
}

// Generate trending test data with volatility
MarketData _generateTestData() {
  final candles = <Candle>[];
  var price = 1.0500;
  final startDate = DateTime(2024, 1, 1);

  for (var i = 0; i < 200; i++) {
    // Add some volatility and trend
    final change = (i % 10 < 6) ? 0.0002 : -0.0001; // More ups than downs
    final noise = (i % 3) * 0.00005;

    price += change + noise;

    final open = price - 0.00005;
    final close = price + 0.00005;
    final high = close + 0.0001;
    final low = open - 0.0001;

    candles.add(Candle(
      timestamp: startDate.add(Duration(hours: i)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 1000.0 + (i * 10),
    ));
  }

  return MarketData(
    id: const Uuid().v4(),
    symbol: 'EURUSD',
    timeframe: 'H1',
    candles: candles,
    uploadedAt: DateTime.now(),
  );
}

// Simple RSI Strategy that should trigger easily
Strategy _createSimpleRSIStrategy() {
  return Strategy(
    id: const Uuid().v4(),
    name: 'Simple RSI 30/70',
    initialCapital: 10000,
    riskManagement: const RiskManagement(
      riskType: RiskType.fixedLot,
      riskValue: 0.1,
      stopLoss: 50,
      takeProfit: 100,
    ),
    entryRules: [
      const StrategyRule(
        indicator: IndicatorType.rsi,
        operator: ComparisonOperator.lessThan,
        value: ConditionValue.number(40),
      ),
    ],
    exitRules: [
      const StrategyRule(
        indicator: IndicatorType.rsi,
        operator: ComparisonOperator.greaterThan,
        value: ConditionValue.number(70),
      ),
    ],
    createdAt: DateTime.now(),
  );
}

// SMA Crossover with shorter period
Strategy _createSMACrossStrategy() {
  return Strategy(
    id: const Uuid().v4(),
    name: 'SMA(20) Crossover',
    initialCapital: 10000,
    riskManagement: const RiskManagement(
      riskType: RiskType.percentageRisk,
      riskValue: 2.0,
      stopLoss: 30,
      takeProfit: 60,
    ),
    entryRules: [
      const StrategyRule(
        indicator: IndicatorType.close,
        operator: ComparisonOperator.crossAbove,
        value: ConditionValue.indicator(
          type: IndicatorType.sma,
          period: 20,
        ),
      ),
    ],
    exitRules: [
      const StrategyRule(
        indicator: IndicatorType.close,
        operator: ComparisonOperator.crossBelow,
        value: ConditionValue.indicator(
          type: IndicatorType.sma,
          period: 20,
        ),
      ),
    ],
    createdAt: DateTime.now(),
  );
}
