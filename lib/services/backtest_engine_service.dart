import 'dart:math';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:uuid/uuid.dart';

class BacktestEngineService {
  final _indicatorService = locator<IndicatorService>();
  final _uuid = const Uuid();

  /// Run backtest
  Future<BacktestResult> runBacktest({
    required MarketData marketData,
    required Strategy strategy,
    bool debug = false, // Add debug flag
  }) async {
    final trades = <Trade>[];
    final candles = marketData.candles;

    // Pre-calculate indicators
    final indicators = _precalculateIndicators(candles, strategy);

    if (debug) {
      print('\n🔍 Debug Mode - First 100 candles:');
      print('Precalculated indicators: ${indicators.keys.join(", ")}');
    }

    Trade? openTrade;
    final equityCurve = <EquityPoint>[];
    double currentEquity = strategy.initialCapital;
    double peakEquity = strategy.initialCapital;

    int entryChecks = 0;
    int entrySignals = 0;

    for (var i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Check exit first if trade is open
      if (openTrade != null) {
        final exitResult = _checkExit(
          openTrade,
          candle,
          indicators,
          i,
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
          openTrade = null;
        }
      }

      // Check entry if no open trade
      if (openTrade == null) {
        final shouldEnter = _checkEntry(candle, indicators, i, strategy);
        entryChecks++;

        if (shouldEnter) {
          entrySignals++;

          if (debug && entrySignals <= 5) {
            print('Entry signal #$entrySignals at index $i:');
            print('  Time: ${candle.timestamp}');
            print('  Close: ${candle.close}');
            // Print indicator values at this point
            for (final key in indicators.keys) {
              print('  $key: ${indicators[key]![i]}');
            }
          }

          openTrade = _openTrade(
            candle: candle,
            strategy: strategy,
            currentEquity: currentEquity,
          );
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
      print('\n📊 Entry Check Summary:');
      print('Total checks: $entryChecks');
      print('Entry signals: $entrySignals');
      print(
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
    }

    final summary = _calculateSummary(trades, strategy.initialCapital);

    return BacktestResult(
      id: _uuid.v4(),
      strategyId: strategy.id,
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
        return 'bb_lower_$period'; // Default to lower band
      default:
        return '${type.name}_$period';
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
      default:
        return List.filled(candles.length, null);
    }
  }

  /// Calculate single indicator
  List<double?> _calculateIndicator(
    List<Candle> candles,
    IndicatorType type,
    ConditionValue value,
  ) {
    // For direct price types, return immediately
    if (type == IndicatorType.close) {
      return candles.map((c) => c.close as double?).toList();
    }
    if (type == IndicatorType.open) {
      return candles.map((c) => c.open as double?).toList();
    }
    if (type == IndicatorType.high) {
      return candles.map((c) => c.high as double?).toList();
    }
    if (type == IndicatorType.low) {
      return candles.map((c) => c.low as double?).toList();
    }

    // For indicators that need period
    return value.when(
      number: (num) => candles.map((c) => c.close as double?).toList(),
      indicator: (indicatorType, period) {
        final p = period ?? 14; // Default period

        switch (type) {
          case IndicatorType.sma:
            return _indicatorService.calculateSMA(candles, p);
          case IndicatorType.ema:
            return _indicatorService.calculateEMA(candles, p);
          case IndicatorType.rsi:
            return _indicatorService.calculateRSI(candles, p);
          case IndicatorType.atr:
            return _indicatorService.calculateATR(candles, p);
          case IndicatorType.macd:
            final macd = _indicatorService.calculateMACD(candles);
            return macd['macd']!;
          case IndicatorType.bollingerBands:
            final bb =
                _indicatorService.calculateBollingerBands(candles, p, 2.0);
            return bb['lower']!; // For entry check
          default:
            return candles.map((c) => c.close as double?).toList();
        }
      },
    );
  }

  String _getIndicatorKey(IndicatorType type, ConditionValue value) {
    return value.when(
      number: (num) => '${type.name}_static',
      indicator: (indicatorType, period) =>
          '${type.name}_${period ?? _getDefaultPeriod(type)}',
    );
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
  bool _checkEntry(
    Candle candle,
    Map<String, List<double?>> indicators,
    int index,
    Strategy strategy,
  ) {
    if (strategy.entryRules.isEmpty) return false;

    // Start with first rule result
    bool result = _evaluateRule(strategy.entryRules[0], indicators, index);

    // Apply subsequent rules with their logical operators
    for (var i = 1; i < strategy.entryRules.length; i++) {
      final rule = strategy.entryRules[i];
      final ruleResult = _evaluateRule(rule, indicators, index);

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
  bool _evaluateRule(
    StrategyRule rule,
    Map<String, List<double?>> indicators,
    int index,
  ) {
    // Get main indicator key
    final mainKey = _getIndicatorKeyForType(rule.indicator, 14);
    final indicatorValues = indicators[mainKey];

    if (indicatorValues == null ||
        index >= indicatorValues.length ||
        indicatorValues[index] == null) {
      return false;
    }

    final currentValue = indicatorValues[index]!;

    // Check if we're comparing against an indicator or a number
    bool isIndicatorComparison = false;
    rule.value.when(
      number: (_) => isIndicatorComparison = false,
      indicator: (_, __) => isIndicatorComparison = true,
    );

    // Get comparison value
    final compareValue = rule.value.when(
      number: (num) => num,
      indicator: (type, period) {
        final compareKey =
            _getIndicatorKeyForType(type, period ?? _getDefaultPeriod(type));
        final compareIndicator = indicators[compareKey];
        if (compareIndicator == null ||
            index >= compareIndicator.length ||
            compareIndicator[index] == null) {
          return double.nan;
        }
        return compareIndicator[index]!;
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
        if (index == 0) return false;
        final prevValue = indicatorValues[index - 1];
        if (prevValue == null) return false;

        // For crossAbove with indicator comparison
        if (isIndicatorComparison) {
          final compareKey = rule.value.when(
            number: (_) => '',
            indicator: (type, period) => _getIndicatorKeyForType(
                type, period ?? _getDefaultPeriod(type)),
          );
          final compareIndicator = indicators[compareKey];
          if (compareIndicator == null || index >= compareIndicator.length)
            return false;
          final prevCompare = compareIndicator[index - 1];
          final currCompare = compareIndicator[index];
          if (prevCompare == null || currCompare == null) return false;
          return prevValue <= prevCompare && currentValue > currCompare;
        }

        return prevValue <= compareValue && currentValue > compareValue;

      case ComparisonOperator.crossBelow:
        if (index == 0) return false;
        final prevValue = indicatorValues[index - 1];
        if (prevValue == null) return false;

        // For crossBelow with indicator comparison
        if (isIndicatorComparison) {
          final compareKey = rule.value.when(
            number: (_) => '',
            indicator: (type, period) => _getIndicatorKeyForType(
                type, period ?? _getDefaultPeriod(type)),
          );
          final compareIndicator = indicators[compareKey];
          if (compareIndicator == null || index >= compareIndicator.length)
            return false;
          final prevCompare = compareIndicator[index - 1];
          final currCompare = compareIndicator[index];
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
    Map<String, List<double?>> indicators,
    int index,
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
        final conditionMet = _evaluateRule(rule, indicators, index);

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
  BacktestSummary _calculateSummary(List<Trade> trades, double initialCapital) {
    if (trades.isEmpty) {
      return BacktestSummary(
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
    );
  }
}
