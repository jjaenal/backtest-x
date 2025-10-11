import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:flutter/material.dart';

/// Debug helper to diagnose why backtest isn't generating trades
class BacktestDebugHelper {
  final _indicatorService = locator<IndicatorService>();

  void debugStrategy(List<Candle> candles, Strategy strategy) {
    debugPrint('\n🔍 DEBUG STRATEGY: ${strategy.name}');
    debugPrint('=' * 60);

    // 1. Check data
    debugPrint('\n📊 Data Info:');
    debugPrint('   Total candles: ${candles.length}');
    debugPrint('   First candle: ${candles.first.timestamp}');
    debugPrint('   Last candle: ${candles.last.timestamp}');
    debugPrint(
        '   Price range: ${candles.first.close} → ${candles.last.close}');

    // 2. Check indicators
    debugPrint('\n📈 Indicator Analysis:');
    _debugIndicators(candles, strategy);

    // 3. Check entry conditions
    debugPrint('\n🎯 Entry Rules Check:');
    _debugEntryRules(candles, strategy);

    // 4. Simulate first 100 candles
    debugPrint('\n🧪 Simulation (first 100 candles):');
    _simulateEntries(candles.take(100).toList(), strategy);
  }

  void _debugIndicators(List<Candle> candles, Strategy strategy) {
    // Check RSI
    if (_hasRSIRules(strategy)) {
      final rsi = _indicatorService.calculateRSI(candles, 14);
      final validRSI = rsi.where((r) => r != null).toList();

      debugPrint('   RSI(14):');
      debugPrint('      Valid values: ${validRSI.length}/${candles.length}');
      if (validRSI.isNotEmpty) {
        debugPrint(
            '      Range: ${validRSI.reduce((a, b) => a! < b! ? a : b)?.toStringAsFixed(2)} - ${validRSI.reduce((a, b) => a! > b! ? a : b)?.toStringAsFixed(2)}');
        debugPrint(
            '      Last 5: ${rsi.skip(rsi.length - 5).map((r) => r?.toStringAsFixed(2)).join(', ')}');

        // Count oversold/overbought
        final oversold = validRSI.where((r) => r! < 30).length;
        final overbought = validRSI.where((r) => r! > 70).length;
        debugPrint('      Oversold (< 30): $oversold times');
        debugPrint('      Overbought (> 70): $overbought times');
      }
    }

    // Check SMA
    if (_hasSMARules(strategy)) {
      final sma = _indicatorService.calculateSMA(candles, 20);
      final validSMA = sma.where((s) => s != null).toList();

      debugPrint('   SMA(20):');
      debugPrint('      Valid values: ${validSMA.length}/${candles.length}');
      if (validSMA.isNotEmpty) {
        debugPrint(
            '      Last 5: ${sma.skip(sma.length - 5).map((s) => s?.toStringAsFixed(2)).join(', ')}');
      }
    }
  }

  void _debugEntryRules(List<Candle> candles, Strategy strategy) {
    for (var i = 0; i < strategy.entryRules.length; i++) {
      final rule = strategy.entryRules[i];
      debugPrint(
          '   Rule ${i + 1}: ${rule.indicator.name} ${rule.operator.name} ${_formatValue(rule.value)}');
    }
  }

  void _simulateEntries(List<Candle> candles, Strategy strategy) {
    if (candles.length < 50) {
      debugPrint(
          '   ⚠️  Not enough data for simulation (need at least 50 candles)');
      return;
    }

    // Calculate indicators
    final rsi = _indicatorService.calculateRSI(candles, 14);
    // final sma = _indicatorService.calculateSMA(candles, 20);

    int potentialEntries = 0;

    for (var i = 50; i < candles.length; i++) {
      // Check RSI < 30 (simple oversold)
      if (rsi[i] != null && rsi[i]! < 30) {
        potentialEntries++;
        if (potentialEntries <= 3) {
          debugPrint(
              '   ✓ Candle $i: RSI = ${rsi[i]?.toStringAsFixed(2)} (< 30) → ENTRY SIGNAL');
        }
      }

      // Check RSI > 70 (simple overbought)
      if (rsi[i] != null && rsi[i]! > 70) {
        if (potentialEntries <= 3) {
          debugPrint(
              '   ✓ Candle $i: RSI = ${rsi[i]?.toStringAsFixed(2)} (> 70) → ENTRY SIGNAL');
        }
        potentialEntries++;
      }
    }

    debugPrint('\n   📊 Potential entries found: $potentialEntries');
    if (potentialEntries == 0) {
      debugPrint('   ❌ No entry signals detected! Check your strategy rules.');
    }
  }

  bool _hasRSIRules(Strategy strategy) {
    return strategy.entryRules.any((r) => r.indicator == IndicatorType.rsi) ||
        strategy.exitRules.any((r) => r.indicator == IndicatorType.rsi);
  }

  bool _hasSMARules(Strategy strategy) {
    return strategy.entryRules.any((r) => r.indicator == IndicatorType.sma) ||
        strategy.exitRules.any((r) => r.indicator == IndicatorType.sma);
  }

  String _formatValue(ConditionValue value) {
    return value.when(
      number: (n) => n.toString(),
      indicator: (type, period, anchorMode, anchorDate) {
        if (type == IndicatorType.anchoredVwap) {
          final anchorLabel =
              (anchorMode == AnchorMode.byDate && anchorDate != null)
                  ? 'date ${anchorDate.toIso8601String().split('T').first}'
                  : 'start';
          return '${type.name}($anchorLabel)';
        }
        return '${type.name}(${period ?? 14})';
      },
    );
  }
}

/// Usage in your test:
///
/// final debugHelper = BacktestDebugHelper(indicatorService);
/// debugHelper.debugStrategy(marketData.candles, strategy);
///
/// Then run backtest to see detailed info
