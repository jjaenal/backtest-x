import 'dart:math';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:uuid/uuid.dart';

class BacktestEngineService {
  // final IndicatorService _indicatorService;
  final IndicatorService _indicatorService = locator<IndicatorService>();
  final _uuid = const Uuid();

  /// Run backtest
  Future<BacktestResult> runBacktest({
    required MarketData marketData,
    required Strategy strategy,
  }) async {
    final trades = <Trade>[];
    final candles = marketData.candles;

    // Pre-calculate indicators
    final indicators = _precalculateIndicators(candles, strategy);

    Trade? openTrade;
    final equityCurve = <EquityPoint>[];
    double currentEquity = strategy.initialCapital;
    double peakEquity = strategy.initialCapital;

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
      if (openTrade == null && _checkEntry(candle, indicators, i, strategy)) {
        openTrade = _openTrade(
          candle: candle,
          strategy: strategy,
          currentEquity: currentEquity,
        );
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

    // Get all unique indicators from rules
    final allRules = [...strategy.entryRules, ...strategy.exitRules];

    for (final rule in allRules) {
      final key = _getIndicatorKey(rule.indicator, rule.value);
      if (!indicators.containsKey(key)) {
        indicators[key] =
            _calculateIndicator(candles, rule.indicator, rule.value);
      }
    }

    return indicators;
  }

  /// Calculate single indicator
  List<double?> _calculateIndicator(
    List<Candle> candles,
    IndicatorType type,
    ConditionValue value,
  ) {
    return value.when(
      number: (num) => candles.map((c) => c.close).toList(),
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
          case IndicatorType.close:
            return candles.map((c) => c.close as double?).toList();
          case IndicatorType.open:
            return candles.map((c) => c.open as double?).toList();
          case IndicatorType.high:
            return candles.map((c) => c.high as double?).toList();
          case IndicatorType.low:
            return candles.map((c) => c.low as double?).toList();
          default:
            return List.filled(candles.length, null);
        }
      },
    );
  }

  String _getIndicatorKey(IndicatorType type, ConditionValue value) {
    return value.when(
      number: (num) => '${type.name}_$num',
      indicator: (indicatorType, period) => '${type.name}_${period ?? 14}',
    );
  }

  /// Check entry conditions
  bool _checkEntry(
    Candle candle,
    Map<String, List<double?>> indicators,
    int index,
    Strategy strategy,
  ) {
    if (strategy.entryRules.isEmpty) return false;

    bool result = true;
    LogicalOperator? prevOperator;

    for (final rule in strategy.entryRules) {
      final conditionMet = _evaluateRule(rule, indicators, index);

      if (prevOperator == null) {
        result = conditionMet;
      } else if (prevOperator == LogicalOperator.and) {
        result = result && conditionMet;
      } else if (prevOperator == LogicalOperator.or) {
        result = result || conditionMet;
      }

      prevOperator = rule.logicalOperator;
    }

    return result;
  }

  /// Evaluate single rule
  bool _evaluateRule(
    StrategyRule rule,
    Map<String, List<double?>> indicators,
    int index,
  ) {
    final key = _getIndicatorKey(rule.indicator, rule.value);
    final indicatorValues = indicators[key];

    if (indicatorValues == null || indicatorValues[index] == null) {
      return false;
    }

    final currentValue = indicatorValues[index]!;
    final compareValue = rule.value.when(
      number: (num) => num,
      indicator: (type, period) {
        final compareKey = _getIndicatorKey(type, rule.value);
        final compareIndicator = indicators[compareKey];
        return compareIndicator?[index] ?? 0.0;
      },
    );

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
        return prevValue != null &&
            prevValue <= compareValue &&
            currentValue > compareValue;
      case ComparisonOperator.crossBelow:
        if (index == 0) return false;
        final prevValue = indicatorValues[index - 1];
        return prevValue != null &&
            prevValue >= compareValue &&
            currentValue < compareValue;
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
    final direction = TradeDirection.buy; // Simplified, bisa dikembangkan

    double lotSize = 0.01; // Default
    if (strategy.riskManagement.riskType == RiskType.percentageRisk) {
      final riskAmount =
          currentEquity * (strategy.riskManagement.riskValue / 100);
      // Simplified lot calculation
      lotSize = riskAmount / (candle.close * 0.1); // Rough estimate
    } else {
      lotSize = strategy.riskManagement.riskValue;
    }

    double? sl;
    double? tp;

    if (strategy.riskManagement.stopLoss != null) {
      sl = direction == TradeDirection.buy
          ? candle.close - strategy.riskManagement.stopLoss!
          : candle.close + strategy.riskManagement.stopLoss!;
    }

    if (strategy.riskManagement.takeProfit != null) {
      tp = direction == TradeDirection.buy
          ? candle.close + strategy.riskManagement.takeProfit!
          : candle.close - strategy.riskManagement.takeProfit!;
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
