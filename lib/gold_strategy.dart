import 'package:backtestx/models/strategy.dart';
import 'package:uuid/uuid.dart';

/// Strategies optimized for GOLD (XAUUSD) and high-value instruments
class GoldStrategies {
  static const _uuid = Uuid();

  /// Strategy 1: RSI Mean Reversion for Gold
  /// Gold tends to bounce at extreme RSI levels
  static Strategy rsiMeanReversion() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold RSI Mean Reversion',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 200, // 20 USD for Gold
        takeProfit: 400, // 40 USD target
      ),
      entryRules: [
        // Buy when RSI oversold (more lenient for H4)
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(35), // Changed from 30
        ),
      ],
      exitRules: [
        // Exit when RSI back to normal
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(60), // Changed from 55
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 2: Bollinger Bands Squeeze (Best for Gold)
  /// Gold respects BB levels well
  static Strategy bollingerBounce() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold BB Bounce',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.5,
        stopLoss: 250, // 25 USD
        takeProfit: 500, // 50 USD
      ),
      entryRules: [
        // Buy at lower BB
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThanOrEqual,
          value: ConditionValue.indicator(
            type: IndicatorType.bollingerBands,
            period: 20,
          ),
        ),
      ],
      exitRules: [
        // Exit at middle BB
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThanOrEqual,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 20,
          ),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 3: Trend Following with SMA
  /// Gold trends well on H4 timeframe
  static Strategy smaTrend() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold SMA Trend',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 300, // 30 USD
        takeProfit: 600, // 60 USD (2:1 RR)
      ),
      entryRules: [
        // Price above SMA(50) - uptrend
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        // RSI pullback (not overbought)
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(65),
        ),
      ],
      exitRules: [
        // Exit when breaks below SMA(20)
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 20,
          ),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 4: EMA Crossover (Fast)
  /// Catch quick moves in Gold
  static Strategy emaCrossover() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold EMA Cross (10/20)',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.fixedLot,
        riskValue: 0.1,
        stopLoss: 200,
        takeProfit: 400,
      ),
      entryRules: [
        // EMA(10) > EMA(20) - simple trend check
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 20,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        // RSI not overbought
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(70),
        ),
      ],
      exitRules: [
        // EMA(10) < EMA(20)
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 20,
          ),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 5: Conservative Multi-Filter (RECOMMENDED)
  /// Multiple conditions reduce false signals
  static Strategy conservativeGold() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold Conservative (Recommended)',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 350, // 35 USD
        takeProfit: 700, // 70 USD (2:1)
      ),
      entryRules: [
        // 1. Uptrend: Above 50 EMA
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 50,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        // 2. Pullback: RSI 40-55 (not extreme)
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(40),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(55),
        ),
      ],
      exitRules: [
        // Exit when RSI overbought
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(70),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 6: Aggressive Scalping
  /// More trades, smaller targets
  static Strategy aggressiveScalp() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Gold Aggressive Scalp',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.fixedLot,
        riskValue: 0.2,
        stopLoss: 150, // 15 USD
        takeProfit: 250, // 25 USD
      ),
      entryRules: [
        // Quick RSI dip
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(40),
        ),
      ],
      exitRules: [
        // Quick exit at RSI 60
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(60),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Get all Gold strategies
  static List<Strategy> getAllGoldStrategies() {
    return [
      conservativeGold(), // Start with this
      bollingerBounce(),
      rsiMeanReversion(),
      smaTrend(),
      emaCrossover(),
      aggressiveScalp(),
    ];
  }
}

/// Usage for XAUUSD H4 data:
/// 
/// final strategies = GoldStrategies.getAllGoldStrategies();
/// for (final strategy in strategies) {
///   final result = await engine.runBacktest(
///     marketData: xauusdData,
///     strategy: strategy,
///   );
///   print('${strategy.name}: WR=${result.summary.winRate}%, PnL=\$${result.summary.totalPnl}');
/// }