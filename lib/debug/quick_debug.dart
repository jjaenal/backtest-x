import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/models/candle.dart';
import 'package:flutter/material.dart';

/// Quick debug - paste this in your test
void quickDebug(List<Candle> candles) {
  debugPrint('\n🔍 QUICK DEBUG');
  debugPrint('=' * 50);

  final indicatorService = IndicatorService();

  // Check RSI
  debugPrint('\n📊 RSI Analysis:');
  final rsi = indicatorService.calculateRSI(candles, 14);
  final validRSI = rsi.where((r) => r != null).toList();

  if (validRSI.isEmpty) {
    debugPrint('❌ NO VALID RSI VALUES!');
    return;
  }

  debugPrint('Valid RSI: ${validRSI.length}/${candles.length}');
  debugPrint('Min RSI: ${validRSI.reduce((a, b) => a! < b! ? a : b)}');
  debugPrint('Max RSI: ${validRSI.reduce((a, b) => a! > b! ? a : b)}');

  // Count occurrences
  final below30 = validRSI.where((r) => r! < 30).length;
  final below35 = validRSI.where((r) => r! < 35).length;
  final below40 = validRSI.where((r) => r! < 40).length;
  final below45 = validRSI.where((r) => r! < 45).length;

  debugPrint('\nRSI Thresholds:');
  debugPrint(
      '   < 30: $below30 times (${(below30 / validRSI.length * 100).toStringAsFixed(1)}%)');
  debugPrint(
      '   < 35: $below35 times (${(below35 / validRSI.length * 100).toStringAsFixed(1)}%)');
  debugPrint(
      '   < 40: $below40 times (${(below40 / validRSI.length * 100).toStringAsFixed(1)}%)');
  debugPrint(
      '   < 45: $below45 times (${(below45 / validRSI.length * 100).toStringAsFixed(1)}%)');

  // Show some examples
  debugPrint('\nExample RSI values (last 10):');
  for (var i = candles.length - 10; i < candles.length; i++) {
    if (rsi[i] != null) {
      debugPrint(
          '   Candle $i: RSI = ${rsi[i]!.toStringAsFixed(2)}, Close = ${candles[i].close.toStringAsFixed(2)}');
    }
  }

  // Check SMA
  debugPrint('\n📊 SMA Analysis:');
  final sma20 = indicatorService.calculateSMA(candles, 20);
  final sma50 = indicatorService.calculateSMA(candles, 50);

  final validSMA20 = sma20.where((s) => s != null).length;
  final validSMA50 = sma50.where((s) => s != null).length;

  debugPrint('Valid SMA(20): $validSMA20/${candles.length}');
  debugPrint('Valid SMA(50): $validSMA50/${candles.length}');

  // Check how often Close > SMA50
  int aboveSMA50 = 0;
  for (var i = 0; i < candles.length; i++) {
    if (sma50[i] != null && candles[i].close > sma50[i]!) {
      aboveSMA50++;
    }
  }
  debugPrint('Close > SMA(50): $aboveSMA50 times');

  // Combined condition test
  debugPrint('\n🎯 Combined Condition Test:');
  debugPrint('   Close > SMA(50) AND RSI < 60:');
  int combined = 0;
  for (var i = 50; i < candles.length; i++) {
    if (sma50[i] != null && rsi[i] != null) {
      if (candles[i].close > sma50[i]! && rsi[i]! < 60) {
        combined++;
        if (combined <= 3) {
          debugPrint(
              '      ✓ Candle $i: Close=${candles[i].close.toStringAsFixed(2)}, SMA50=${sma50[i]!.toStringAsFixed(2)}, RSI=${rsi[i]!.toStringAsFixed(2)}');
        }
      }
    }
  }
  debugPrint('   Total matches: $combined');

  if (combined == 0) {
    debugPrint('\n❌ PROBLEM: Combined condition NEVER met!');
    debugPrint('💡 Try simpler conditions or adjust thresholds');
  }
}
