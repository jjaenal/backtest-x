import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/models/candle.dart';
import 'package:flutter/material.dart';

/// Test a single rule in isolation
void testSingleRule(List<Candle> candles) {
  debugPrint('\n🧪 TESTING SINGLE RULES');
  debugPrint('=' * 50);

  final indicatorService = IndicatorService();

  // Test 1: RSI < 35
  debugPrint('\n1️⃣  Testing: RSI < 35');
  final rsi = indicatorService.calculateRSI(candles, 14);
  int matches = 0;
  for (var i = 0; i < candles.length; i++) {
    if (rsi[i] != null && rsi[i]! < 35) {
      matches++;
      if (matches <= 3) {
        debugPrint('   ✓ Match at $i: RSI = ${rsi[i]!.toStringAsFixed(2)}');
      }
    }
  }
  debugPrint('   Total matches: $matches');

  // Test 2: Close > SMA(50)
  debugPrint('\n2️⃣  Testing: Close > SMA(50)');
  final sma50 = indicatorService.calculateSMA(candles, 50);
  matches = 0;
  for (var i = 0; i < candles.length; i++) {
    if (sma50[i] != null && candles[i].close > sma50[i]!) {
      matches++;
      if (matches <= 3) {
        debugPrint(
            '   ✓ Match at $i: Close=${candles[i].close.toStringAsFixed(2)}, SMA50=${sma50[i]!.toStringAsFixed(2)}');
      }
    }
  }
  debugPrint('   Total matches: $matches');

  // Test 3: Combined (Close > SMA50 AND RSI < 60)
  debugPrint('\n3️⃣  Testing: Close > SMA(50) AND RSI < 60');
  matches = 0;
  for (var i = 0; i < candles.length; i++) {
    if (sma50[i] != null && rsi[i] != null) {
      if (candles[i].close > sma50[i]! && rsi[i]! < 60) {
        matches++;
        if (matches <= 3) {
          debugPrint('   ✓ Match at $i:');
          debugPrint('      Close: ${candles[i].close.toStringAsFixed(2)}');
          debugPrint('      SMA50: ${sma50[i]!.toStringAsFixed(2)}');
          debugPrint('      RSI: ${rsi[i]!.toStringAsFixed(2)}');
        }
      }
    }
  }
  debugPrint('   Total matches: $matches');

  // Test 4: The exact Conservative Gold strategy
  debugPrint('\n4️⃣  Testing: Close > SMA(50) AND RSI > 35 AND RSI < 60');
  matches = 0;
  for (var i = 50; i < candles.length; i++) {
    if (sma50[i] != null && rsi[i] != null) {
      final condition1 = candles[i].close > sma50[i]!;
      final condition2 = rsi[i]! > 35;
      final condition3 = rsi[i]! < 60;

      if (condition1 && condition2 && condition3) {
        matches++;
        if (matches <= 3) {
          debugPrint('   ✓ Match at $i:');
          debugPrint(
              '      Close > SMA50: $condition1 (${candles[i].close.toStringAsFixed(2)} > ${sma50[i]!.toStringAsFixed(2)})');
          debugPrint(
              '      RSI > 35: $condition2 (${rsi[i]!.toStringAsFixed(2)})');
          debugPrint('      RSI < 60: $condition3');
        }
      }
    }
  }
  debugPrint('   Total matches: $matches');

  if (matches > 0) {
    debugPrint('\n✅ Strategy conditions CAN be met!');
    debugPrint(
        '💡 If backtest still shows 0 trades, the problem is in backtest engine logic.');
  } else {
    debugPrint('\n❌ Strategy conditions are NEVER met with this data!');
  }
}
