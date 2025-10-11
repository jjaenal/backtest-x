import 'package:backtestx/models/strategy.dart';

/// Predefined strategy templates to speed up strategy creation.
class StrategyTemplates {
  static Map<String, StrategyTemplate> all = {
    'breakout_basic': StrategyTemplate(
      name: 'Breakout — SMA Range',
      description:
          'Entry saat harga menembus di atas SMA, exit saat kembali di bawah.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.sma,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.sma,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    'mean_reversion_rsi': StrategyTemplate(
      name: 'Mean Reversion — RSI',
      description: 'Entry saat RSI < 30 (oversold), exit saat RSI > 50.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.0,
        stopLoss: 100,
        takeProfit: 150,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(30),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(50),
          logicalOperator: null,
        ),
      ],
    ),
    'macd_signal': StrategyTemplate(
      name: 'MACD Signal',
      description: 'Entry saat MACD crossAbove Signal, exit crossBelow.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // ————————————————————————————————————————————————————————————————
    // Tambahan template siap pakai (4 template)
    'trend_ema_cross': StrategyTemplate(
      name: 'Trend Follow — EMA(20/50) Cross',
      description:
          'Entry saat EMA(20) crossAbove EMA(50), exit saat crossBelow.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 50,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 50,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    'momentum_rsi_macd': StrategyTemplate(
      name: 'Momentum — RSI & MACD',
      description:
          'Entry RSI > 55 dan MACD crossAbove Signal; exit RSI < 45 atau MACD crossBelow Signal.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(55),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(45),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    'macd_hist_momentum': StrategyTemplate(
      name: 'MACD Momentum — Signal + Histogram Filter',
      description:
          'Entry: MACD crossAbove Signal + Histogram > ambang; Exit: MACD crossBelow Signal atau Histogram < −ambang.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(0.0005),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(-0.0005),
          logicalOperator: null,
        ),
      ],
    ),
    'mean_reversion_bb_rsi': StrategyTemplate(
      name: 'Mean Reversion — BB Lower + RSI',
      description:
          'Entry saat Close < BB Lower (20) dan RSI < 35; exit RSI > 50.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.0,
        stopLoss: 100,
        takeProfit: 150,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.bollingerBands,
            period: 20,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(35),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(50),
          logicalOperator: null,
        ),
      ],
    ),
    'ema_vs_sma_cross': StrategyTemplate(
      name: 'EMA vs SMA — Cross',
      description:
          'Entry saat EMA crossAbove SMA(50), exit saat crossBelow SMA(50).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 50,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    'macd_hist_rising_filter': StrategyTemplate(
      name: 'MACD Momentum — Histogram Rising + Signal + Filter',
      description:
          'Entry: Histogram Rising + MACD crossAbove Signal + Histogram > ambang; Exit: Histogram Falling atau MACD crossBelow Signal atau Histogram < −ambang.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.rising,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(0.0005),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.falling,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.macd,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.macdSignal,
            period: 9,
          ),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.macdHistogram,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(-0.0005),
          logicalOperator: null,
        ),
      ],
    ),
    'rsi_rising_50_filter': StrategyTemplate(
      name: 'RSI Momentum — Rising + 50 Filter',
      description:
          'Entry: RSI Rising + RSI > 50; Exit: RSI Falling atau RSI < 50.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.rising,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(50),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.falling,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.rsi,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(50),
          logicalOperator: null,
        ),
      ],
    ),
    'ema_rising_price_filter': StrategyTemplate(
      name: 'EMA Momentum — EMA Rising + Price Filter',
      description:
          'Entry: EMA Rising + Close > EMA(20); Exit: EMA Falling atau Close < EMA(20).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.rising,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.ema,
          operator: ComparisonOperator.falling,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.or,
        ),
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.ema,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // New: EMA Ribbon stacking strategy template
    'ema_ribbon_stack': StrategyTemplate(
      name: 'Trend Follow — EMA Ribbon (8/13/21/34/55)',
      description:
          'Entry saat EMA(8)>EMA(13)>EMA(21)>EMA(34)>EMA(55) dan Close > EMA(21); Exit saat Close < EMA(21).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        // Stack EMAs in ascending order (short above long)
        const StrategyRule(
          indicator: IndicatorType.ema,
          period: 8,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 13),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.ema,
          period: 13,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 21),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.ema,
          period: 21,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 34),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.ema,
          period: 34,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 55),
          logicalOperator: LogicalOperator.and,
        ),
        // Price above mid ribbon for confirmation
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 21),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        // Simple exit: close falls below EMA(21)
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(type: IndicatorType.ema, period: 21),
          logicalOperator: null,
        ),
      ],
    ),
  };
}

class StrategyTemplate {
  final String name;
  final String description;
  final double initialCapital;
  final RiskManagement risk;
  final List<StrategyRule> entryRules;
  final List<StrategyRule> exitRules;

  StrategyTemplate({
    required this.name,
    required this.description,
    required this.initialCapital,
    required this.risk,
    required this.entryRules,
    required this.exitRules,
  });
}
