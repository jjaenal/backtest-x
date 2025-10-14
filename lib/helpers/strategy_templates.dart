import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/l10n/app_localizations.dart';

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
    // Breakout using Highest High / Lowest Low window + ATR filter
    'breakout_hh_range_atr': StrategyTemplate(
      name: 'Breakout — HH/HL Range + ATR Filter',
      description:
          'Entry saat Close crossAbove HighestHigh(20) bila ATR(14) < ambang (default longgar); Exit saat Close crossBelow LowestLow(20).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        // Volatility/range filter: ATR di bawah ambang (sesuaikan instrument)
        const StrategyRule(
          indicator: IndicatorType.atr,
          period: 14,
          operator: ComparisonOperator.lessThan,
          // Default longgar agar tidak memblok sinyal; sesuaikan sesuai skala harga
          value: ConditionValue.number(100000),
          logicalOperator: LogicalOperator.and,
        ),
        // Breakout: Close menembus Highest High dari 20 candle terakhir
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.high,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        // Exit: Close menembus ke bawah Lowest Low dari 20 candle terakhir
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.low,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // Breakout using HH/LL with ATR% filter for instrument-agnostic volatility
    'breakout_hh_range_atr_pct': StrategyTemplate(
      name: 'Breakout — HH/HL Range + ATR% Filter',
      description:
          'Entry saat Close crossAbove HighestHigh(20) bila ATR%(14) < 2%; Exit saat Close crossBelow LowestLow(20). ATR% = ATR/Close, konsisten lintas instrumen.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        // Volatility filter: ATR% di bawah ambang 2%
        const StrategyRule(
          indicator: IndicatorType.atrPct,
          period: 14,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(0.02),
          logicalOperator: LogicalOperator.and,
        ),
        // Breakout: Close menembus Highest High dari 20 candle terakhir
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.high,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        // Exit: Close menembus ke bawah Lowest Low dari 20 candle terakhir
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.low,
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
    // Trend with ADX filter for stronger trend confirmation
    'trend_ema_adx_filter': StrategyTemplate(
      name: 'Trend Follow — EMA Cross + ADX Filter',
      description:
          'Entry: EMA(20) crossAbove EMA(50) dengan ADX(14) > 20; Exit: EMA(20) crossBelow EMA(50).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.adx,
          period: 14,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(20),
          logicalOperator: LogicalOperator.and,
        ),
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
    // Trend with ATR% filter for instrument-agnostic volatility
    'trend_ema_atr_pct_filter': StrategyTemplate(
      name: 'Trend Follow — EMA Cross + ATR% Filter',
      description:
          'Entry: ATR%(14) < 2.0 dan EMA(20) crossAbove EMA(50); Exit: EMA(20) crossBelow EMA(50).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.atrPct,
          period: 14,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.number(2.0),
          logicalOperator: LogicalOperator.and,
        ),
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
    // Volatility squeeze breakout using ATR% proxy + BB Lower breakout
    'bb_squeeze_breakout': StrategyTemplate(
      name: 'Bollinger Squeeze — Width Rising + Breakout',
      description:
          'Entry utama: Bollinger Width(20) rising dan Close crossAbove BB Lower(20). Fallback: Close crossAbove SMA(20). Exit saat Close < SMA(20). (Lebih longgar: tanpa filter ATR%)',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.bollingerWidth,
          period: 20,
          operator: ComparisonOperator.rising,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.bollingerBands,
            period: 20,
          ),
          logicalOperator: LogicalOperator.or,
        ),
        // Fallback momentum: Close break above SMA(20)
        const StrategyRule(
          indicator: IndicatorType.close,
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
          indicator: IndicatorType.close,
          operator: ComparisonOperator.lessThan,
          value: ConditionValue.indicator(
            type: IndicatorType.sma,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // Approximate RSI divergence: RSI rising while price falling (bullish)
    'rsi_divergence_approx': StrategyTemplate(
      name: 'RSI Divergence (Approx) — Rising RSI, Falling Price',
      description:
          'Entry utama: RSI rising dan Close falling (indikasi divergensi bullish sederhana). Fallback: RSI crossAbove 50 ATAU Close crossAbove SMA(20). Exit saat RSI > 60.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 200,
        takeProfit: 400,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.rsi,
          period: 14,
          operator: ComparisonOperator.rising,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.falling,
          value: ConditionValue.number(0),
          logicalOperator: LogicalOperator.or,
        ),
        // Fallback momentum 1: RSI crossAbove 50
        const StrategyRule(
          indicator: IndicatorType.rsi,
          period: 14,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.number(50),
          logicalOperator: LogicalOperator.or,
        ),
        // Fallback momentum 2: Close break above SMA(20)
        const StrategyRule(
          indicator: IndicatorType.close,
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
          indicator: IndicatorType.rsi,
          period: 14,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(60),
          logicalOperator: null,
        ),
      ],
    ),
    // VWAP Pullback breakout: Close crossAbove VWAP, exit crossBelow
    'vwap_pullback_breakout': StrategyTemplate(
      name: 'VWAP Pullback — Close CrossAbove VWAP',
      description:
          'Entry saat Close crossAbove VWAP(20) setelah konsolidasi; Exit saat Close crossBelow VWAP(20).',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.vwap,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.vwap,
            period: 20,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // Anchored VWAP Pullback/Cross: Close crossAbove Anchored VWAP, exit crossBelow
    'anchored_vwap_pullback_cross': StrategyTemplate(
      name: 'Anchored VWAP — Pullback Cross',
      description:
          'Entry saat Close crossAbove Anchored VWAP (anchor = awal backtest); Exit saat Close crossBelow Anchored VWAP.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 2.0,
        stopLoss: 150,
        takeProfit: 300,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.anchoredVwap,
            period: 1,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.close,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.anchoredVwap,
            period: 1,
          ),
          logicalOperator: null,
        ),
      ],
    ),
    // Stochastic K/D cross with ADX filter
    'stoch_kd_cross_adx': StrategyTemplate(
      name: 'Stochastic Cross — K/D + ADX Filter',
      description:
          'Entry saat %K(14) crossAbove %D(3) dengan ADX(14) > 20; Exit saat %K crossBelow %D.',
      initialCapital: 10000,
      risk: const RiskManagement(
        riskType: RiskType.percentageRisk,
        riskValue: 1.5,
        stopLoss: 120,
        takeProfit: 240,
      ),
      entryRules: [
        const StrategyRule(
          indicator: IndicatorType.adx,
          period: 14,
          operator: ComparisonOperator.greaterThan,
          value: ConditionValue.number(20),
          logicalOperator: LogicalOperator.and,
        ),
        const StrategyRule(
          indicator: IndicatorType.stochasticK,
          period: 14,
          operator: ComparisonOperator.crossAbove,
          value: ConditionValue.indicator(
            type: IndicatorType.stochasticD,
            period: 14,
          ),
          logicalOperator: null,
        ),
      ],
      exitRules: [
        const StrategyRule(
          indicator: IndicatorType.stochasticK,
          period: 14,
          operator: ComparisonOperator.crossBelow,
          value: ConditionValue.indicator(
            type: IndicatorType.stochasticD,
            period: 14,
          ),
          logicalOperator: null,
        ),
      ],
    ),
  };

  /// Localized variants of templates: returns copies of [all] with
  /// `name` and `description` resolved via AppLocalizations for current locale.
  static Map<String, StrategyTemplate> localized(AppLocalizations l10n) {
    StrategyTemplate _copyWithLocalized(
      String key,
      StrategyTemplate t,
    ) {
      final name = _localizedName(l10n, key, t.name);
      final desc = _localizedDesc(l10n, key, t.description);
      return StrategyTemplate(
        name: name,
        description: desc,
        initialCapital: t.initialCapital,
        risk: t.risk,
        entryRules: t.entryRules,
        exitRules: t.exitRules,
      );
    }

    final map = <String, StrategyTemplate>{};
    all.forEach((key, value) {
      map[key] = _copyWithLocalized(key, value);
    });
    return map;
  }

  static String _localizedName(
      AppLocalizations l10n, String key, String fallback) {
    switch (key) {
      case 'breakout_basic':
        return l10n.templateBreakoutBasicName;
      case 'breakout_hh_range_atr':
        return l10n.templateBreakoutHhRangeAtrName;
      case 'breakout_hh_range_atr_pct':
        return l10n.templateBreakoutHhRangeAtrPctName;
      case 'mean_reversion_rsi':
        return l10n.templateMeanReversionRsiName;
      case 'macd_signal':
        return l10n.templateMacdSignalName;
      case 'trend_ema_cross':
        return l10n.templateTrendEmaCrossName;
      case 'trend_ema_adx_filter':
        return l10n.templateTrendEmaAdxFilterName;
      case 'trend_ema_atr_pct_filter':
        return l10n.templateTrendEmaAtrPctFilterName;
      case 'momentum_rsi_macd':
        return l10n.templateMomentumRsiMacdName;
      case 'macd_hist_momentum':
        return l10n.templateMacdHistMomentumName;
      case 'mean_reversion_bb_rsi':
        return l10n.templateMeanReversionBbRsiName;
      case 'ema_vs_sma_cross':
        return l10n.templateEmaVsSmaCrossName;
      case 'macd_hist_rising_filter':
        return l10n.templateMacdHistRisingFilterName;
      case 'rsi_rising_50_filter':
        return l10n.templateRsiRising50FilterName;
      case 'ema_rising_price_filter':
        return l10n.templateEmaRisingPriceFilterName;
      case 'ema_ribbon_stack':
        return l10n.templateEmaRibbonStackName;
      case 'vwap_pullback_breakout':
        return l10n.templateVwapPullbackBreakoutName;
      case 'anchored_vwap_pullback_cross':
        return l10n.templateAnchoredVwapPullbackCrossName;
      case 'stoch_kd_cross_adx':
        return l10n.templateStochKdCrossAdxName;
      default:
        return fallback;
    }
  }

  static String _localizedDesc(
      AppLocalizations l10n, String key, String fallback) {
    switch (key) {
      case 'breakout_basic':
        return l10n.templateBreakoutBasicDesc;
      case 'breakout_hh_range_atr':
        return l10n.templateBreakoutHhRangeAtrDesc;
      case 'breakout_hh_range_atr_pct':
        return l10n.templateBreakoutHhRangeAtrPctDesc;
      case 'mean_reversion_rsi':
        return l10n.templateMeanReversionRsiDesc;
      case 'macd_signal':
        return l10n.templateMacdSignalDesc;
      case 'trend_ema_cross':
        return l10n.templateTrendEmaCrossDesc;
      case 'trend_ema_adx_filter':
        return l10n.templateTrendEmaAdxFilterDesc;
      case 'trend_ema_atr_pct_filter':
        return l10n.templateTrendEmaAtrPctFilterDesc;
      case 'momentum_rsi_macd':
        return l10n.templateMomentumRsiMacdDesc;
      case 'macd_hist_momentum':
        return l10n.templateMacdHistMomentumDesc;
      case 'mean_reversion_bb_rsi':
        return l10n.templateMeanReversionBbRsiDesc;
      case 'ema_vs_sma_cross':
        return l10n.templateEmaVsSmaCrossDesc;
      case 'macd_hist_rising_filter':
        return l10n.templateMacdHistRisingFilterDesc;
      case 'rsi_rising_50_filter':
        return l10n.templateRsiRising50FilterDesc;
      case 'ema_rising_price_filter':
        return l10n.templateEmaRisingPriceFilterDesc;
      case 'ema_ribbon_stack':
        return l10n.templateEmaRibbonStackDesc;
      case 'vwap_pullback_breakout':
        return l10n.templateVwapPullbackBreakoutDesc;
      case 'anchored_vwap_pullback_cross':
        return l10n.templateAnchoredVwapPullbackCrossDesc;
      case 'stoch_kd_cross_adx':
        return l10n.templateStochKdCrossAdxDesc;
      default:
        return fallback;
    }
  }
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
