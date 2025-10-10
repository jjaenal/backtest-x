import 'dart:math';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/helpers/timeframe_helper.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class BacktestEngineService {
  // Allow DI so we can construct this inside isolate without locator
  final IndicatorService _indicatorService;
  BacktestEngineService({IndicatorService? indicatorService})
      : _indicatorService = indicatorService ?? locator<IndicatorService>();
  final _uuid = const Uuid();
  // Last-run per-timeframe stats (preview-friendly, not persisted)
  Map<String, int> _lastTfSignals = {};
  Map<String, int> _lastTfTrades = {};
  Map<String, int> _lastTfWins = {};
  Map<String, double> _lastTfWinRate = {};

  Map<String, Map<String, num>> get lastTfStats => {
        for (final tf in {
          ..._lastTfSignals.keys,
          ..._lastTfTrades.keys,
          ..._lastTfWins.keys,
        })
          tf: {
            'signals': (_lastTfSignals[tf] ?? 0),
            'trades': (_lastTfTrades[tf] ?? 0),
            'wins': (_lastTfWins[tf] ?? 0),
            'winRate': (_lastTfWinRate[tf] ?? 0.0),
          }
      };

  /// Run backtest
  Future<BacktestResult> runBacktest({
    required MarketData marketData,
    required Strategy strategy,
    DateTime? startDate, // Optional: limit by start date
    DateTime? endDate, // Optional: limit by end date
    bool debug = false, // Add debug flag
  }) async {
    // Reset last-run per‑TF stats
    _lastTfSignals = {};
    _lastTfTrades = {};
    _lastTfWins = {};
    _lastTfWinRate = {};
    final trades = <Trade>[];
    // Optionally slice candles by date range to reduce memory/CPU on large datasets
    final List<Candle> candles = () {
      final all = marketData.candles;
      if (startDate == null && endDate == null) return all;
      return all.where((c) {
        final ts = c.timestamp;
        final afterStart = startDate == null || ts.isAfter(startDate!) || ts.isAtSameMomentAs(startDate!);
        final beforeEnd = endDate == null || ts.isBefore(endDate!) || ts.isAtSameMomentAs(endDate!);
        return afterStart && beforeEnd;
      }).toList(growable: false);
    }();
    final baseTimeframe = marketData.timeframe;

    // Guard: empty or too-short data
    if (candles.isEmpty) {
      throw StateError(
        'Backtest gagal: market data kosong. Unggah CSV valid atau pilih data lain.',
      );
    }
    if (candles.length < 2) {
      // Early return dengan hasil kosong yang aman
      final summary = _calculateSummary(
        [],
        strategy.initialCapital,
        tfStats: {},
      );
      return BacktestResult(
        id: _uuid.v4(),
        strategyId: strategy.id,
        marketDataId: marketData.id,
        executedAt: DateTime.now(),
        trades: const [],
        summary: summary,
        equityCurve: const [],
      );
    }

    // Prepare multi-timeframe context
    final ruleTimeframes = <String>{};
    for (final r in [...strategy.entryRules, ...strategy.exitRules]) {
      if (r.timeframe != null && r.timeframe!.isNotEmpty) {
        ruleTimeframes.add(r.timeframe!);
      }
    }

    final tfCandles = <String, List<Candle>>{baseTimeframe: candles};
    for (final tf in ruleTimeframes) {
      if (tf != baseTimeframe) {
        tfCandles[tf] = resampleCandlesToTimeframe(candles, tf);
      }
    }

    // Pre-calculate indicators per timeframe
    final tfIndicators = <String, Map<String, List<double?>>>{};
    tfIndicators[baseTimeframe] =
        _precalculateIndicators(tfCandles[baseTimeframe]!, strategy);
    for (final tf in ruleTimeframes) {
      tfIndicators[tf] = _precalculateIndicators(tfCandles[tf]!, strategy);
    }

    // Map base index to index in each timeframe
    final tfIndexMap = <String, List<int?>>{};
    tfIndexMap[baseTimeframe] = List<int?>.generate(candles.length, (i) => i);
    for (final tf in ruleTimeframes) {
      final target = tfCandles[tf]!;
      final tsToIdx = <DateTime, int>{};
      for (var j = 0; j < target.length; j++) {
        tsToIdx[target[j].timestamp] = j;
      }
      // Prepare sorted timestamps for fallback lookup
      final tsKeys = tsToIdx.keys.toList()..sort((a, b) => a.compareTo(b));
      int? _findIndexAtOrBefore(DateTime t) {
        // Binary search for the last timestamp <= t
        int lo = 0, hi = tsKeys.length - 1;
        int ans = -1;
        while (lo <= hi) {
          final mid = (lo + hi) >> 1;
          final midTs = tsKeys[mid];
          if (midTs.isBefore(t) || midTs.isAtSameMomentAs(t)) {
            ans = mid;
            lo = mid + 1;
          } else {
            hi = mid - 1;
          }
        }
        if (ans >= 0) {
          return tsToIdx[tsKeys[ans]];
        }
        return null;
      }

      final mapList = List<int?>.filled(candles.length, null);
      for (var i = 0; i < candles.length; i++) {
        final bucketTs = floorToTimeframe(candles[i].timestamp, tf);
        mapList[i] = tsToIdx[bucketTs] ?? _findIndexAtOrBefore(bucketTs);
      }
      tfIndexMap[tf] = mapList;
    }

    if (debug) {
      debugPrint('\n🔍 Debug Mode - First 100 candles:');
      final indKeys = tfIndicators[baseTimeframe]!.keys.join(", ");
      debugPrint('Precalculated indicators (base TF=$baseTimeframe): $indKeys');
      if (ruleTimeframes.isNotEmpty) {
        for (final tf in ruleTimeframes) {
          debugPrint('TF $tf indicators: ${tfIndicators[tf]!.keys.join(", ")}');
        }
      }
    }

    Trade? openTrade;
    final equityCurve = <EquityPoint>[];
    double currentEquity = strategy.initialCapital;
    double peakEquity = strategy.initialCapital;

    int entryChecks = 0;
    int entrySignals = 0;
    // Map trade ID → contributing timeframes on entry
    final Map<String, Set<String>> _tradeEntryTfs = {};

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Check exit first if trade is open
      if (openTrade != null) {
        final exitResult = _checkExit(
          openTrade,
          candle,
          tfIndicators,
          tfIndexMap,
          i,
          baseTimeframe,
          strategy,
        );

        if (exitResult != null) {
          final closedTrade = openTrade.copyWith(
            exitTime: candle.timestamp,
            exitPrice: exitResult['price'],
            status: TradeStatus.closed,
            pnl: exitResult['pnl'],
            pnlPercentage: exitResult['pnlPercentage'],
            exitReason: exitResult['reason'],
          );

          trades.add(closedTrade);
          currentEquity += closedTrade.pnl!;
          // Update per‑TF trade/win stats for this closed trade
          final contributing =
              _tradeEntryTfs[closedTrade.id] ?? {baseTimeframe};
          final isWin = (closedTrade.pnl ?? 0) > 0;
          for (final tf in contributing) {
            _lastTfTrades[tf] = (_lastTfTrades[tf] ?? 0) + 1;
            if (isWin) {
              _lastTfWins[tf] = (_lastTfWins[tf] ?? 0) + 1;
            }
          }
          openTrade = null;
        }
      }

      // Check entry if no open trade
      if (openTrade == null) {
        final shouldEnter = _checkEntryMTF(
          candle,
          tfIndicators,
          tfIndexMap,
          i,
          baseTimeframe,
          strategy,
        );
        entryChecks++;

        if (shouldEnter) {
          entrySignals++;
          // Count signals per timeframe based on contributing rules at this index
          final contributingTfs = <String>{};
          for (final rule in strategy.entryRules) {
            final tf = (rule.timeframe == null || rule.timeframe!.isEmpty)
                ? baseTimeframe
                : rule.timeframe!;
            // Re-evaluate rule to determine contribution
            final ok = _evaluateRuleMTF(
              rule,
              tfIndicators,
              tfIndexMap,
              i,
              baseTimeframe,
            );
            if (ok) contributingTfs.add(tf);
          }
          for (final tf in contributingTfs) {
            _lastTfSignals[tf] = (_lastTfSignals[tf] ?? 0) + 1;
          }

          if (debug && entrySignals <= 5) {
            debugPrint('Entry signal #$entrySignals at index $i:');
            debugPrint('  Time: ${candle.timestamp}');
            debugPrint('  Close: ${candle.close}');
            // Print indicator values at this point
            for (final key in tfIndicators[baseTimeframe]!.keys) {
              debugPrint('  $key: ${tfIndicators[baseTimeframe]![key]![i]}');
            }
          }

          openTrade = _openTrade(
            candle: candle,
            strategy: strategy,
            currentEquity: currentEquity,
          );
          // Tie contributing TFs to this open trade
          _tradeEntryTfs[openTrade.id] =
              contributingTfs.isEmpty ? {baseTimeframe} : contributingTfs;
        }
      }

      // Update equity curve
      if (openTrade != null) {
        final unrealizedPnl = _calculateUnrealizedPnl(openTrade, candle.close);
        currentEquity = strategy.initialCapital +
            trades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0)) +
            unrealizedPnl;
      }

      peakEquity = max(peakEquity, currentEquity);
      final drawdown = peakEquity - currentEquity;

      equityCurve.add(EquityPoint(
        timestamp: candle.timestamp,
        equity: currentEquity,
        drawdown: drawdown,
      ));
    }

    if (debug) {
      debugPrint('\n📊 Entry Check Summary:');
      debugPrint('Total checks: $entryChecks');
      debugPrint('Entry signals: $entrySignals');
      debugPrint(
          'Signal rate: ${(entrySignals / entryChecks * 100).toStringAsFixed(2)}%');
    }

    // Close open trade at end of data
    if (openTrade != null) {
      final lastCandle = candles.last;
      final exitPnl = _calculatePnl(
        openTrade.direction,
        openTrade.entryPrice,
        lastCandle.close,
        openTrade.lotSize,
      );

      trades.add(openTrade.copyWith(
        exitTime: lastCandle.timestamp,
        exitPrice: lastCandle.close,
        status: TradeStatus.closed,
        pnl: exitPnl,
        pnlPercentage: (exitPnl / openTrade.entryPrice) * 100,
        exitReason: 'End of Data',
      ));
      // Update per‑TF trade/win stats for forced close at end of data
      final isWinForced = exitPnl > 0;
      final contributing = _tradeEntryTfs[openTrade.id] ?? {baseTimeframe};
      for (final tf in contributing) {
        _lastTfTrades[tf] = (_lastTfTrades[tf] ?? 0) + 1;
        if (isWinForced) {
          _lastTfWins[tf] = (_lastTfWins[tf] ?? 0) + 1;
        }
      }
    }

    // Calculate per‑TF win rates
    final tfSet = {
      ..._lastTfTrades.keys,
      ..._lastTfWins.keys,
      ..._lastTfSignals.keys,
    };
    for (final tf in tfSet) {
      final t = _lastTfTrades[tf] ?? 0;
      final w = _lastTfWins[tf] ?? 0;
      _lastTfWinRate[tf] = t > 0 ? (w / t) * 100.0 : 0.0;
    }

    final summary = _calculateSummary(
      trades,
      strategy.initialCapital,
      tfStats: lastTfStats,
    );

    return BacktestResult(
      id: _uuid.v4(),
      strategyId: strategy.id,
      marketDataId: marketData.id,
      executedAt: DateTime.now(),
      trades: trades,
      summary: summary,
      equityCurve: equityCurve,
    );
  }

  /// Precalculate all indicators needed
  Map<String, List<double?>> _precalculateIndicators(
    List<Candle> candles,
    Strategy strategy,
  ) {
    final indicators = <String, List<double?>>{};

    // Always add Close, Open, High, Low (used frequently)
    indicators['close'] = candles.map((c) => c.close as double?).toList();
    indicators['open'] = candles.map((c) => c.open as double?).toList();
    indicators['high'] = candles.map((c) => c.high as double?).toList();
    indicators['low'] = candles.map((c) => c.low as double?).toList();

    // Get all unique indicators from rules
    final allRules = [...strategy.entryRules, ...strategy.exitRules];

    for (final rule in allRules) {
      // Calculate the main indicator
      final mainKey =
          _getIndicatorKeyForType(rule.indicator, 14); // Default period
      if (!indicators.containsKey(mainKey)) {
        indicators[mainKey] =
            _calculateIndicatorByType(candles, rule.indicator, 14);
      }

      // Calculate comparison indicator if it's an indicator comparison
      rule.value.when(
        number: (_) {
          // No additional indicator needed
        },
        indicator: (type, period) {
          final compareKey =
              _getIndicatorKeyForType(type, period ?? _getDefaultPeriod(type));
          if (!indicators.containsKey(compareKey)) {
            indicators[compareKey] = _calculateIndicatorByType(
                candles, type, period ?? _getDefaultPeriod(type));
          }
        },
      );
    }

    return indicators;
  }

  /// Get indicator key for a specific type and period
  String _getIndicatorKeyForType(IndicatorType type, int period) {
    switch (type) {
      case IndicatorType.close:
        return 'close';
      case IndicatorType.open:
        return 'open';
      case IndicatorType.high:
        return 'high';
      case IndicatorType.low:
        return 'low';
      case IndicatorType.rsi:
        return 'rsi_$period';
      case IndicatorType.sma:
        return 'sma_$period';
      case IndicatorType.ema:
        return 'ema_$period';
      case IndicatorType.atr:
        return 'atr_$period';
      case IndicatorType.macd:
        return 'macd_$period';
      case IndicatorType.bollingerBands:
        return 'bb_lower_$period';
    }
  }

  /// Calculate indicator by type and period
  List<double?> _calculateIndicatorByType(
      List<Candle> candles, IndicatorType type, int period) {
    switch (type) {
      case IndicatorType.close:
        return candles.map((c) => c.close as double?).toList();
      case IndicatorType.open:
        return candles.map((c) => c.open as double?).toList();
      case IndicatorType.high:
        return candles.map((c) => c.high as double?).toList();
      case IndicatorType.low:
        return candles.map((c) => c.low as double?).toList();
      case IndicatorType.rsi:
        return _indicatorService.calculateRSI(candles, period);
      case IndicatorType.sma:
        return _indicatorService.calculateSMA(candles, period);
      case IndicatorType.ema:
        return _indicatorService.calculateEMA(candles, period);
      case IndicatorType.atr:
        return _indicatorService.calculateATR(candles, period);
      case IndicatorType.macd:
        final macd = _indicatorService.calculateMACD(candles);
        return macd['macd']!;
      case IndicatorType.bollingerBands:
        final bb =
            _indicatorService.calculateBollingerBands(candles, period, 2.0);
        return bb['lower']!;
    }
  }

  int _getDefaultPeriod(IndicatorType type) {
    switch (type) {
      case IndicatorType.rsi:
        return 14;
      case IndicatorType.sma:
      case IndicatorType.ema:
        return 20;
      case IndicatorType.macd:
        return 12;
      case IndicatorType.atr:
        return 14;
      case IndicatorType.bollingerBands:
        return 20;
      default:
        return 14;
    }
  }

  /// Check entry conditions
  bool _checkEntryMTF(
    Candle candle,
    Map<String, Map<String, List<double?>>> tfIndicators,
    Map<String, List<int?>> tfIndexMap,
    int baseIndex,
    String baseTimeframe,
    Strategy strategy,
  ) {
    if (strategy.entryRules.isEmpty) return false;

    // Start with first rule result
    bool result = _evaluateRuleMTF(
      strategy.entryRules[0],
      tfIndicators,
      tfIndexMap,
      baseIndex,
      baseTimeframe,
    );

    // Apply subsequent rules with their logical operators
    for (var i = 1; i < strategy.entryRules.length; i++) {
      final rule = strategy.entryRules[i];
      final ruleResult = _evaluateRuleMTF(
        rule,
        tfIndicators,
        tfIndexMap,
        baseIndex,
        baseTimeframe,
      );

      // Get the logical operator from PREVIOUS rule (connects to current)
      final prevOperator = strategy.entryRules[i - 1].logicalOperator;

      if (prevOperator == LogicalOperator.and) {
        result = result && ruleResult;
      } else if (prevOperator == LogicalOperator.or) {
        result = result || ruleResult;
      } else {
        // No operator means AND by default
        result = result && ruleResult;
      }
    }

    return result;
  }

  /// Evaluate single rule
  bool _evaluateRuleMTF(
    StrategyRule rule,
    Map<String, Map<String, List<double?>>> tfIndicators,
    Map<String, List<int?>> tfIndexMap,
    int baseIndex,
    String baseTimeframe,
  ) {
    // Use rule timeframe if provided, otherwise fall back to base timeframe
    final tf = (rule.timeframe == null || rule.timeframe!.isEmpty)
        ? baseTimeframe
        : rule.timeframe!;

    // Get main indicator key
    final mainKey = _getIndicatorKeyForType(rule.indicator, 14);
    final indicators = tfIndicators[tf];
    if (indicators == null) return false;
    final indicatorValues = indicators[mainKey];

    final tfIndex =
        tf == baseTimeframe ? baseIndex : (tfIndexMap[tf]?[baseIndex] ?? -1);
    if (tfIndex < 0) return false;

    if (indicatorValues == null ||
        tfIndex >= indicatorValues.length ||
        indicatorValues[tfIndex] == null) {
      return false;
    }

    final currentValue = indicatorValues[tfIndex]!;

    // Check if we're comparing against an indicator or a number
    bool isIndicatorComparison = false;
    rule.value.when(
      number: (_) => isIndicatorComparison = false,
      indicator: (_, __) => isIndicatorComparison = true,
    );

    // Get comparison value
    final compareValue = rule.value.when(
      number: (number) => number,
      indicator: (type, period) {
        final compareKey =
            _getIndicatorKeyForType(type, period ?? _getDefaultPeriod(type));
        final compareIndicator = indicators[compareKey];
        if (compareIndicator == null ||
            tfIndex >= compareIndicator.length ||
            compareIndicator[tfIndex] == null) {
          return double.nan;
        }
        return compareIndicator[tfIndex]!;
      },
    );

    // Skip if comparison value is invalid
    if (compareValue.isNaN || compareValue.isInfinite) {
      return false;
    }

    switch (rule.operator) {
      case ComparisonOperator.greaterThan:
        return currentValue > compareValue;
      case ComparisonOperator.lessThan:
        return currentValue < compareValue;
      case ComparisonOperator.greaterThanOrEqual:
        return currentValue >= compareValue;
      case ComparisonOperator.lessThanOrEqual:
        return currentValue <= compareValue;
      case ComparisonOperator.equals:
        return (currentValue - compareValue).abs() < 0.0001;
      case ComparisonOperator.crossAbove:
        if (tfIndex == 0) return false;
        final prevValue = indicatorValues[tfIndex - 1];
        if (prevValue == null) return false;

        // For crossAbove with indicator comparison
        if (isIndicatorComparison) {
          final compareKey = rule.value.when(
            number: (_) => '',
            indicator: (type, period) => _getIndicatorKeyForType(
                type, period ?? _getDefaultPeriod(type)),
          );
          final compareIndicator = indicators[compareKey];
          if (compareIndicator == null || tfIndex >= compareIndicator.length) {
            return false;
          }
          final prevCompare = compareIndicator[tfIndex - 1];
          final currCompare = compareIndicator[tfIndex];
          if (prevCompare == null || currCompare == null) return false;
          return prevValue <= prevCompare && currentValue > currCompare;
        }

        return prevValue <= compareValue && currentValue > compareValue;

      case ComparisonOperator.crossBelow:
        if (tfIndex == 0) return false;
        final prevValue = indicatorValues[tfIndex - 1];
        if (prevValue == null) return false;

        // For crossBelow with indicator comparison
        if (isIndicatorComparison) {
          final compareKey = rule.value.when(
            number: (_) => '',
            indicator: (type, period) => _getIndicatorKeyForType(
                type, period ?? _getDefaultPeriod(type)),
          );
          final compareIndicator = indicators[compareKey];
          if (compareIndicator == null || tfIndex >= compareIndicator.length) {
            return false;
          }
          final prevCompare = compareIndicator[tfIndex - 1];
          final currCompare = compareIndicator[tfIndex];
          if (prevCompare == null || currCompare == null) return false;
          return prevValue >= prevCompare && currentValue < currCompare;
        }

        return prevValue >= compareValue && currentValue < compareValue;
    }
  }

  /// Check exit conditions
  Map<String, dynamic>? _checkExit(
    Trade trade,
    Candle candle,
    Map<String, Map<String, List<double?>>> tfIndicators,
    Map<String, List<int?>> tfIndexMap,
    int baseIndex,
    String baseTimeframe,
    Strategy strategy,
  ) {
    // Check SL/TP first
    if (trade.stopLoss != null) {
      if (trade.direction == TradeDirection.buy &&
          candle.low <= trade.stopLoss!) {
        return {
          'price': trade.stopLoss,
          'pnl': _calculatePnl(trade.direction, trade.entryPrice,
              trade.stopLoss!, trade.lotSize),
          'pnlPercentage':
              ((trade.stopLoss! - trade.entryPrice) / trade.entryPrice) * 100,
          'reason': 'Stop Loss',
        };
      } else if (trade.direction == TradeDirection.sell &&
          candle.high >= trade.stopLoss!) {
        return {
          'price': trade.stopLoss,
          'pnl': _calculatePnl(trade.direction, trade.entryPrice,
              trade.stopLoss!, trade.lotSize),
          'pnlPercentage':
              ((trade.entryPrice - trade.stopLoss!) / trade.entryPrice) * 100,
          'reason': 'Stop Loss',
        };
      }
    }

    if (trade.takeProfit != null) {
      if (trade.direction == TradeDirection.buy &&
          candle.high >= trade.takeProfit!) {
        return {
          'price': trade.takeProfit,
          'pnl': _calculatePnl(trade.direction, trade.entryPrice,
              trade.takeProfit!, trade.lotSize),
          'pnlPercentage':
              ((trade.takeProfit! - trade.entryPrice) / trade.entryPrice) * 100,
          'reason': 'Take Profit',
        };
      } else if (trade.direction == TradeDirection.sell &&
          candle.low <= trade.takeProfit!) {
        return {
          'price': trade.takeProfit,
          'pnl': _calculatePnl(trade.direction, trade.entryPrice,
              trade.takeProfit!, trade.lotSize),
          'pnlPercentage':
              ((trade.entryPrice - trade.takeProfit!) / trade.entryPrice) * 100,
          'reason': 'Take Profit',
        };
      }
    }

    // Check exit rules
    if (strategy.exitRules.isNotEmpty) {
      bool shouldExit = true;
      LogicalOperator? prevOperator;

      for (final rule in strategy.exitRules) {
        final conditionMet = _evaluateRuleMTF(
          rule,
          tfIndicators,
          tfIndexMap,
          baseIndex,
          baseTimeframe,
        );

        if (prevOperator == null) {
          shouldExit = conditionMet;
        } else if (prevOperator == LogicalOperator.and) {
          shouldExit = shouldExit && conditionMet;
        } else if (prevOperator == LogicalOperator.or) {
          shouldExit = shouldExit || conditionMet;
        }

        prevOperator = rule.logicalOperator;
      }

      if (shouldExit) {
        final pnl = _calculatePnl(
            trade.direction, trade.entryPrice, candle.close, trade.lotSize);
        return {
          'price': candle.close,
          'pnl': pnl,
          'pnlPercentage': (pnl / trade.entryPrice) * 100,
          'reason': 'Exit Signal',
        };
      }
    }

    return null;
  }

  /// Open new trade
  Trade _openTrade({
    required Candle candle,
    required Strategy strategy,
    required double currentEquity,
  }) {
    // Determine direction based on entry rules
    TradeDirection direction = _determineTradeDirection(strategy.entryRules);

    double lotSize = 0.01; // Default
    if (strategy.riskManagement.riskType == RiskType.percentageRisk) {
      final riskAmount =
          currentEquity * (strategy.riskManagement.riskValue / 100);
      // Simplified lot calculation based on SL distance
      final slDistance = strategy.riskManagement.stopLoss ?? 50;
      lotSize = riskAmount / slDistance;
      lotSize = (lotSize * 100).roundToDouble() / 100; // Round to 2 decimals
      lotSize = lotSize.clamp(0.01, 10.0); // Min 0.01, Max 10 lots
    } else {
      lotSize = strategy.riskManagement.riskValue;
    }

    double? sl;
    double? tp;

    if (strategy.riskManagement.stopLoss != null) {
      // Auto-detect instrument type and calculate SL/TP accordingly
      final slPoints = strategy.riskManagement.stopLoss!;
      final pointValue = _calculatePointValue(candle.close);

      sl = direction == TradeDirection.buy
          ? candle.close - (slPoints * pointValue)
          : candle.close + (slPoints * pointValue);
    }

    if (strategy.riskManagement.takeProfit != null) {
      final tpPoints = strategy.riskManagement.takeProfit!;
      final pointValue = _calculatePointValue(candle.close);

      tp = direction == TradeDirection.buy
          ? candle.close + (tpPoints * pointValue)
          : candle.close - (tpPoints * pointValue);
    }

    return Trade(
      id: _uuid.v4(),
      direction: direction,
      entryTime: candle.timestamp,
      entryPrice: candle.close,
      lotSize: lotSize,
      stopLoss: sl,
      takeProfit: tp,
      status: TradeStatus.open,
    );
  }

  /// Calculate point value based on instrument price
  /// Auto-detects Forex (< 10) vs Metals/Indices (> 10)
  double _calculatePointValue(double price) {
    if (price < 10) {
      // Forex pairs (EURUSD, GBPUSD, etc) - 1 pip = 0.0001
      return 0.0001;
    } else if (price < 200) {
      // JPY pairs or special instruments - 1 point = 0.01
      return 0.01;
    } else {
      // Gold, Indices, etc - 1 point = 0.1 or 1.0
      // For Gold (800-3600), use 0.1
      return 0.1;
    }
  }

  /// Determine trade direction from entry rules
  TradeDirection _determineTradeDirection(List<StrategyRule> entryRules) {
    // Simple heuristic:
    // - If checking for oversold (RSI < 30, price < lower BB) → BUY
    // - If checking for overbought (RSI > 70, price > upper BB) → SELL
    // - Default: BUY

    for (final rule in entryRules) {
      // Check RSI conditions
      if (rule.indicator == IndicatorType.rsi) {
        final threshold = rule.value.when(
          number: (n) => n,
          indicator: (_, __) => 50.0,
        );

        if (rule.operator == ComparisonOperator.lessThan && threshold <= 35) {
          return TradeDirection.buy; // Oversold → Buy
        }
        if (rule.operator == ComparisonOperator.greaterThan &&
            threshold >= 65) {
          return TradeDirection.sell; // Overbought → Sell
        }
      }

      // Check price vs MA crossovers
      if (rule.operator == ComparisonOperator.crossAbove) {
        return TradeDirection.buy;
      }
      if (rule.operator == ComparisonOperator.crossBelow) {
        return TradeDirection.sell;
      }
    }

    return TradeDirection.buy; // Default
  }

  /// Calculate PnL
  double _calculatePnl(
    TradeDirection direction,
    double entryPrice,
    double exitPrice,
    double lotSize,
  ) {
    if (direction == TradeDirection.buy) {
      return (exitPrice - entryPrice) * lotSize;
    } else {
      return (entryPrice - exitPrice) * lotSize;
    }
  }

  /// Calculate unrealized PnL
  double _calculateUnrealizedPnl(Trade trade, double currentPrice) {
    return _calculatePnl(
        trade.direction, trade.entryPrice, currentPrice, trade.lotSize);
  }

  /// Calculate summary statistics
  BacktestSummary _calculateSummary(
    List<Trade> trades,
    double initialCapital, {
    Map<String, Map<String, num>>? tfStats,
  }) {
    if (trades.isEmpty) {
      return const BacktestSummary(
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
        tfStats: null,
      );
    }

    final closedTrades =
        trades.where((t) => t.status == TradeStatus.closed).toList();
    final winningTrades = closedTrades.where((t) => (t.pnl ?? 0) > 0).toList();
    final losingTrades = closedTrades.where((t) => (t.pnl ?? 0) < 0).toList();

    final totalPnl = closedTrades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0));
    final grossProfit = winningTrades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0));
    final grossLoss =
        losingTrades.fold(0.0, (sum, t) => sum + (t.pnl ?? 0).abs());

    final profitFactor = grossLoss == 0 ? 0.0 : grossProfit / grossLoss;
    final winRate = closedTrades.isEmpty
        ? 0.0
        : (winningTrades.length / closedTrades.length) * 100;

    final averageWin =
        winningTrades.isEmpty ? 0.0 : grossProfit / winningTrades.length;
    final averageLoss =
        losingTrades.isEmpty ? 0.0 : grossLoss / losingTrades.length;

    final largestWin = winningTrades.isEmpty
        ? 0.0
        : winningTrades.map((t) => t.pnl!).reduce(max);
    final largestLoss = losingTrades.isEmpty
        ? 0.0
        : losingTrades.map((t) => t.pnl!.abs()).reduce(max);

    final expectancy =
        closedTrades.isEmpty ? 0.0 : totalPnl / closedTrades.length;

    // Max Drawdown
    double peak = initialCapital;
    double maxDD = 0;
    double currentEquity = initialCapital;

    for (final trade in closedTrades) {
      currentEquity += trade.pnl ?? 0;
      peak = max(peak, currentEquity);
      final dd = peak - currentEquity;
      maxDD = max(maxDD, dd);
    }

    final maxDDPercent = peak == 0 ? 0.0 : (maxDD / peak) * 100;

    // Simplified Sharpe Ratio
    final returns =
        closedTrades.map((t) => (t.pnl ?? 0) / initialCapital).toList();
    final avgReturn = returns.isEmpty
        ? 0.0
        : returns.reduce((a, b) => a + b) / returns.length;
    final variance = returns.isEmpty
        ? 0.0
        : returns.map((r) => pow(r - avgReturn, 2)).reduce((a, b) => a + b) /
            returns.length;
    final stdDev = sqrt(variance);
    final sharpeRatio = stdDev == 0 ? 0.0 : avgReturn / stdDev;

    return BacktestSummary(
      totalTrades: closedTrades.length,
      winningTrades: winningTrades.length,
      losingTrades: losingTrades.length,
      winRate: winRate,
      totalPnl: totalPnl,
      totalPnlPercentage: (totalPnl / initialCapital) * 100,
      profitFactor: profitFactor,
      maxDrawdown: maxDD,
      maxDrawdownPercentage: maxDDPercent,
      sharpeRatio: sharpeRatio,
      averageWin: averageWin,
      averageLoss: averageLoss,
      largestWin: largestWin,
      largestLoss: largestLoss,
      expectancy: expectancy,
      tfStats: tfStats,
    );
  }
}
