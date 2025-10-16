import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/helpers/isolate_backtest.dart';
import 'package:backtestx/helpers/strategy_templates.dart';

/// Quick script to run EMA Ribbon (8/13/21/34/55) on synthetic uptrend data.
/// Usage: dart run tool/ema_ribbon_quick_backtest.dart
void main() async {
  final marketData = _generateTrendData();

  final template = StrategyTemplates.all['ema_ribbon_stack']!;
  final strategy = Strategy(
    id: const Uuid().v4(),
    name: template.name,
    initialCapital: template.initialCapital,
    riskManagement: template.risk,
    entryRules: template.entryRules,
    exitRules: template.exitRules,
    createdAt: DateTime.now(),
  );

  debugPrint('🚀 Running EMA Ribbon quick backtest...');
  debugPrint(
      '   Data: ${marketData.symbol} ${marketData.timeframe} (${marketData.candles.length} candles)');
  debugPrint('   Strategy: ${strategy.name}');

  final result = await IsolateBacktest.run(
    marketData: marketData,
    strategy: strategy,
  );

  debugPrint('✅ Backtest complete');
  debugPrint('   Trades: ${result.summary.totalTrades}');
  debugPrint('   Win Rate: ${result.summary.winRate.toStringAsFixed(2)}%');
  debugPrint('   Total PnL: \\${result.summary.totalPnl.toStringAsFixed(2)}');

  // Print first few signals if any trades executed
  final trades = result.trades;
  if (trades.isNotEmpty) {
    final count = trades.length < 5 ? trades.length : 5;
    debugPrint('   First $count trades:');
    for (var i = 0; i < count; i++) {
      final t = trades[i];
      debugPrint(
          '   ${i + 1}. ${t.direction.name.toUpperCase()} @ ${t.entryPrice} → ${t.exitPrice} | PnL: \\${t.pnl?.toStringAsFixed(2)}');
    }
  } else {
    debugPrint('   ⚠️  No trades detected on synthetic dataset.');
  }
}

// Generate synthetic H1 uptrend data with mild volatility
MarketData _generateTrendData() {
  final candles = <Candle>[];
  var price = 1800.0; // starting price (e.g., Gold)
  final startDate = DateTime(2024, 1, 1);

  for (var i = 0; i < 500; i++) {
    // Uptrend bias with noise
    final bias = (i % 12 < 8) ? 1.8 : -1.0; // more ups than downs
    final noise = ((i % 5) - 2) * 0.4; // small oscillations

    price += bias + noise;

    final open = price - 0.8;
    final close = price + 0.8;
    final high = close + 1.2;
    final low = open - 1.2;

    candles.add(Candle(
      timestamp: startDate.add(Duration(hours: i)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: 1000.0 + (i * 5),
    ));
  }

  return MarketData(
    id: const Uuid().v4(),
    symbol: 'XAUUSD',
    timeframe: 'H1',
    candles: candles,
    uploadedAt: DateTime.now(),
  );
}
