import 'package:backtestx/models/strategy.dart';
import 'package:uuid/uuid.dart';

/// Example strategies untuk testing backtest engine
class ExampleStrategies {
  static const _uuid = Uuid();

  /// Strategy 1: Simple SMA Cross (IMPROVED - Less trades)
  /// Buy when Close > SMA(50) AND RSI < 40 (lenient oversold)
  /// Exit when RSI > 70 OR Close < SMA(20)
  static Strategy simpleSMACross() {
    return Strategy(
      id: _uuid.v4(),
      name: 'SMA Cross + RSI Filter',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0, // 2% risk per trade
        stopLoss: 100, // Increased from 50
        takeProfit: 200, // Better R:R ratio
      ),
      entryRules: [
        // Close > SMA(50)
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        // RSI < 40 (pullback filter)
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(40),
        ),
      ],
      exitRules: [
        // RSI > 70
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(70),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 2: RSI Oversold/Overbought (IMPROVED)
  /// Buy when RSI < 30 (true oversold)
  /// Sell when RSI > 70 (true overbought)
  static Strategy rsiOversoldOverbought() {
    return Strategy(
      id: _uuid.v4(),
      name: 'RSI Mean Reversion',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.fixedLot,
        riskValue: 0.1, // Fixed 0.1 lot
        stopLoss: 80,
        takeProfit: 150,
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

  /// Strategy 3: Trend Following (Less trades, higher quality)
  /// Buy when SMA(20) crosses above SMA(50) (golden cross)
  /// Exit when SMA(20) crosses below SMA(50) (death cross)
  static Strategy trendFollowing() {
    return Strategy(
      id: _uuid.v4(),
      name: 'SMA Golden Cross',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 3.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        // SMA(20) > SMA(50)
        const StrategyRule(
          indicator: IndicatorType.sma,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
        ),
      ],
      exitRules: [
        // SMA(20) < SMA(50)
        const StrategyRule(
          indicator: IndicatorType.sma,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 4: Bollinger Bands Bounce (FIXED)
  /// Buy when Close touches Lower Band
  /// Exit when Close touches Upper Band
  static Strategy bollingerBandsBounce() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Bollinger Bands Bounce',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 70,
        takeProfit: 140,
      ),
      entryRules: [
        // Close < BB Lower (oversold)
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
        // Close > BB Middle (target)
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

  /// Strategy 5: MACD Cross (SIMPLIFIED)
  /// Buy when MACD crosses above Signal line
  /// Exit when MACD crosses below Signal line
  static Strategy macdCross() {
    return Strategy(
      id: _uuid.v4(),
      name: 'MACD Cross',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.5,
        stopLoss: 100,
        takeProfit: 200,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.macd,
            period: 9, // Signal line
          ),
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.macd,
            period: 9,
          ),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Strategy 6: Conservative Swing Trading (RECOMMENDED)
  /// Multi-condition: Trend + Pullback + Momentum
  /// Fewer trades, higher quality
  static Strategy conservativeSwing() {
    return Strategy(
      id: _uuid.v4(),
      name: 'Conservative Swing (Recommended)',
      initialCapital: 10000,
      riskManagement: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 120,
        takeProfit: 240, // 2:1 R:R
      ),
      entryRules: [
        // 1. Uptrend: Close > SMA(50)
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        // 2. Pullback: RSI 35-50 (not too oversold)
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(35),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(50),
        ),
      ],
      exitRules: [
        // Exit when RSI overbought
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(75),
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// Get all example strategies
  static List<Strategy> getAllExamples() {
    return [
      conservativeSwing(), // Best for most cases
      simpleSMACross(),
      rsiOversoldOverbought(),
      trendFollowing(),
      bollingerBandsBounce(),
      macdCross(),
    ];
  }
}

/// Example usage in your app
/*
void main() async {
  final engine = BacktestEngineService(IndicatorService());
  final marketData = ...; // Load your market data
  
  // Test recommended strategy
  final bestStrategy = ExampleStrategies.conservativeSwing();
  print('Testing: ${bestStrategy.name}');
  
  final result = await engine.runBacktest(
    marketData: marketData,
    strategy: bestStrategy,
  );
  
  print('Win Rate: ${result.summary.winRate}%');
  print('Total PnL: \${result.summary.totalPnl}');
  print('Total Trades: ${result.summary.totalTrades}');
  print('Profit Factor: ${result.summary.profitFactor}');
  print('---');
}
*/
