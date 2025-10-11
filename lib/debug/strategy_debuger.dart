// import 'package:backtestx/app/app.locator.dart';
// import 'package:backtestx/models/candle.dart';
// import 'package:backtestx/models/strategy.dart';
// import 'package:backtestx/services/indicator_service.dart';
// import 'package:flutter/material.dart';

// /// Debug helper to see WHY strategies aren't triggering
// class StrategyDebugger {
//   final _indicatorService = locator<IndicatorService>();

//   /// Debug a specific strategy against data
//   void debugStrategy(List<Candle> candles, Strategy strategy) {
//     debugPrint('\n${'=' * 70}');
//     debugPrint('🔍 DEBUGGING STRATEGY: ${strategy.name}');
//     debugPrint('=' * 70);

//     // 1. Check data basics
//     debugPrint('\n📊 DATA INFO:');
//     debugPrint('   Total Candles: ${candles.length}');
//     debugPrint(
//         '   Price Range: ${candles.first.close.toStringAsFixed(2)} → ${candles.last.close.toStringAsFixed(2)}');
//     debugPrint(
//         '   Date Range: ${candles.first.timestamp} → ${candles.last.timestamp}');

//     // 2. Analyze indicators used in rules
//     debugPrint('\n📈 INDICATORS ANALYSIS:');
//     final usedIndicators = _getUsedIndicators(strategy);

//     for (final indicatorType in usedIndicators) {
//       _analyzeIndicator(candles, indicatorType);
//     }

//     // 3. Check entry rules in detail
//     debugPrint('\n🎯 ENTRY RULES ANALYSIS:');
//     debugPrint('   Total Rules: ${strategy.entryRules.length}');
//     for (var i = 0; i < strategy.entryRules.length; i++) {
//       final rule = strategy.entryRules[i];
//       debugPrint('\n   Rule ${i + 1}:');
//       debugPrint('      Indicator: ${rule.indicator.name}');
//       debugPrint('      Operator: ${rule.operator.name}');
//       debugPrint('      Value: ${_formatValue(rule.value)}');
//       if (rule.logicalOperator != null) {
//         debugPrint('      Logic: ${rule.logicalOperator!.name.toUpperCase()}');
//       }

//       // Test this rule
//       _testRule(candles, rule);
//     }

//     // 4. Simulate on sample data
//     debugPrint('\n🧪 SIMULATION (Sample 100 candles from middle):');
//     final sampleStart = candles.length ~/ 2;
//     final sampleEnd = (sampleStart + 100).clamp(0, candles.length);
//     final sampleCandles = candles.sublist(sampleStart, sampleEnd);

//     _simulateStrategy(sampleCandles, strategy);
//   }

//   Set<IndicatorType> _getUsedIndicators(Strategy strategy) {
//     final indicators = <IndicatorType>{};

//     for (final rule in [...strategy.entryRules, ...strategy.exitRules]) {
//       indicators.add(rule.indicator);

//       rule.value.when(
//         number: (_) {},
//         indicator: (type, _) => indicators.add(type),
//       );
//     }

//     return indicators;
//   }

//   void _analyzeIndicator(List<Candle> candles, IndicatorType type) {
//     switch (type) {
//       case IndicatorType.rsi:
//         final rsi = _indicatorService.calculateRSI(candles, 14);
//         final valid = rsi.where((v) => v != null).toList();
//         if (valid.isNotEmpty) {
//           debugPrint('   RSI(14):');
//           debugPrint('      Valid: ${valid.length}/${candles.length}');
//           debugPrint(
//               '      Range: ${valid.reduce((a, b) => a! < b! ? a : b)?.toStringAsFixed(2)} - ${valid.reduce((a, b) => a! > b! ? a : b)?.toStringAsFixed(2)}');
//           debugPrint('      < 30: ${valid.where((v) => v! < 30).length} times');
//           debugPrint('      < 35: ${valid.where((v) => v! < 35).length} times');
//           debugPrint('      < 40: ${valid.where((v) => v! < 40).length} times');
//           debugPrint('      > 70: ${valid.where((v) => v! > 70).length} times');
//         }
//         break;

//       case IndicatorType.sma:
//         final sma20 = _indicatorService.calculateSMA(candles, 20);
//         final sma50 = _indicatorService.calculateSMA(candles, 50);
//         debugPrint('   SMA:');
//         debugPrint(
//             '      SMA(20) valid: ${sma20.where((v) => v != null).length}/${candles.length}');
//         debugPrint(
//             '      SMA(50) valid: ${sma50.where((v) => v != null).length}/${candles.length}');
//         break;

//       case IndicatorType.ema:
//         final ema20 = _indicatorService.calculateEMA(candles, 20);
//         final ema50 = _indicatorService.calculateEMA(candles, 50);
//         debugPrint('   EMA:');
//         debugPrint(
//             '      EMA(20) valid: ${ema20.where((v) => v != null).length}/${candles.length}');
//         debugPrint(
//             '      EMA(50) valid: ${ema50.where((v) => v != null).length}/${candles.length}');
//         break;

//       case IndicatorType.close:
//         debugPrint('   Close: Always valid (${candles.length} values)');
//         break;

//       default:
//         debugPrint('   ${type.name}: Not analyzed');
//     }
//   }

//   void _testRule(List<Candle> candles, StrategyRule rule) {
//     // Calculate indicator values
//     List<double?> indicatorValues;

//     if (rule.indicator == IndicatorType.close) {
//       indicatorValues = candles.map((c) => c.close as double?).toList();
//     } else if (rule.indicator == IndicatorType.rsi) {
//       indicatorValues = _indicatorService.calculateRSI(candles, 14);
//     } else if (rule.indicator == IndicatorType.sma) {
//       final period = rule.value.when(
//         number: (_) => 20,
//         indicator: (_, p) => p ?? 20,
//       );
//       indicatorValues = _indicatorService.calculateSMA(candles, period);
//     } else {
//       debugPrint('      ⚠️  Indicator not implemented in debug');
//       return;
//     }

//     // Get comparison value
//     final compareValue = rule.value.when(
//       number: (n) => n,
//       indicator: (type, period) {
//         if (type == IndicatorType.sma) {
//           final p = period ?? 50;
//           final sma = _indicatorService.calculateSMA(candles, p);
//           return sma.last ?? 0.0;
//         }
//         return 0.0;
//       },
//     );

//     // Count how many times condition would be true
//     int trueCount = 0;
//     final validValues = indicatorValues.where((v) => v != null).toList();

//     for (final value in validValues) {
//       bool conditionMet = false;

//       switch (rule.operator) {
//         case ComparisonOperator.lessThan:
//           conditionMet = value! < compareValue;
//           break;
//         case ComparisonOperator.greaterThan:
//           conditionMet = value! > compareValue;
//           break;
//         case ComparisonOperator.lessThanOrEqual:
//           conditionMet = value! <= compareValue;
//           break;
//         case ComparisonOperator.greaterThanOrEqual:
//           conditionMet = value! >= compareValue;
//           break;
//         default:
//           break;
//       }

//       if (conditionMet) trueCount++;
//     }

//     debugPrint(
//         '      ✓ Condition met: $trueCount/${validValues.length} times (${(trueCount / validValues.length * 100).toStringAsFixed(1)}%)');

//     if (trueCount == 0) {
//       debugPrint('      ❌ PROBLEM: Condition NEVER met!');
//       debugPrint('      💡 Suggestion: Adjust threshold or check data');
//     }
//   }

//   void _simulateStrategy(List<Candle> candles, Strategy strategy) {
//     final rsi = _indicatorService.calculateRSI(candles, 14);
//     final sma50 = _indicatorService.calculateSMA(candles, 50);

//     int potentialEntries = 0;

//     for (var i = 50; i < candles.length; i++) {
//       if (rsi[i] == null) continue;

//       // Simple simulation for common patterns
//       bool wouldEnter = false;

//       // Check RSI oversold
//       if (rsi[i]! < 35) {
//         wouldEnter = true;
//       }

//       // Check SMA trend
//       if (sma50[i] != null && candles[i].close > sma50[i]! && rsi[i]! < 60) {
//         wouldEnter = true;
//       }

//       if (wouldEnter) {
//         potentialEntries++;
//         if (potentialEntries <= 3) {
//           debugPrint('   Candle $i (${candles[i].timestamp}):');
//           debugPrint('      Close: ${candles[i].close.toStringAsFixed(2)}');
//           debugPrint('      RSI: ${rsi[i]!.toStringAsFixed(2)}');
//           if (sma50[i] != null) {
//             debugPrint('      SMA50: ${sma50[i]!.toStringAsFixed(2)}');
//           }
//         }
//       }
//     }

//     debugPrint('\n   📊 Potential Entries: $potentialEntries');

//     if (potentialEntries == 0) {
//       debugPrint('   ❌ NO POTENTIAL ENTRIES FOUND!');
//       debugPrint('   💡 This strategy won\'t work with this data.');
//     }
//   }

//   String _formatValue(ConditionValue value) {
//     return value.when(
//       number: (n) => n.toString(),
//       indicator: (type, period) => '${type.name}(${period ?? 14})',
//     );
//   }
// }

// /// Usage:
// ///
// /// final debugger = StrategyDebugger(_indicatorService);
// /// debugger.debugStrategy(xauusdData.candles, strategy);
