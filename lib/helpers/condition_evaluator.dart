import 'package:backtestx/models/strategy.dart';

/// Modular evaluator for strategy rules (multi-timeframe aware).
/// Extracted for testing and reusability outside the engine.
class ConditionEvaluator {
  /// Evaluate a single rule against precomputed indicators and index maps.
  static bool evaluateRuleMTF(
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

    // Get main indicator key using rule.period or default
    final mainPeriod = rule.period ?? _getDefaultPeriod(rule.indicator);
    final mainKey = _getIndicatorKeyForType(rule.indicator, mainPeriod);
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
      indicator: (_, __, ___, ____) => isIndicatorComparison = true,
    );

    // Get comparison value
    final compareValue = rule.value.when(
      number: (number) => number,
      indicator: (type, period, anchorMode, anchorDate) {
        String compareKey;
        if (type == IndicatorType.anchoredVwap) {
          if (anchorMode == AnchorMode.byDate && anchorDate != null) {
            compareKey = _avwapKeyByDate(anchorDate);
          } else {
            compareKey = _avwapKeyStart();
          }
        } else {
          compareKey =
              _getIndicatorKeyForType(type, period ?? _getDefaultPeriod(type));
        }
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
            indicator: (type, period, anchorMode, anchorDate) {
              if (type == IndicatorType.anchoredVwap) {
                if (anchorMode == AnchorMode.byDate && anchorDate != null) {
                  return _avwapKeyByDate(anchorDate);
                }
                return _avwapKeyStart();
              }
              return _getIndicatorKeyForType(
                  type, period ?? _getDefaultPeriod(type));
            },
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
            indicator: (type, period, anchorMode, anchorDate) {
              if (type == IndicatorType.anchoredVwap) {
                if (anchorMode == AnchorMode.byDate && anchorDate != null) {
                  return _avwapKeyByDate(anchorDate);
                }
                return _avwapKeyStart();
              }
              return _getIndicatorKeyForType(
                  type, period ?? _getDefaultPeriod(type));
            },
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
      case ComparisonOperator.rising:
        if (tfIndex == 0) return false;
        final prevValueR = indicatorValues[tfIndex - 1];
        if (prevValueR == null) return false;
        return currentValue > prevValueR;
      case ComparisonOperator.falling:
        if (tfIndex == 0) return false;
        final prevValueF = indicatorValues[tfIndex - 1];
        if (prevValueF == null) return false;
        return currentValue < prevValueF;
    }
  }

  // ---- Helpers duplicated for standalone evaluation ----
  static String _getIndicatorKeyForType(IndicatorType type, int period) {
    switch (type) {
      case IndicatorType.close:
        return 'close';
      case IndicatorType.open:
        return 'open';
      case IndicatorType.high:
        return period <= 1 ? 'high' : 'hh_$period';
      case IndicatorType.low:
        return period <= 1 ? 'low' : 'll_$period';
      case IndicatorType.rsi:
        return 'rsi_$period';
      case IndicatorType.sma:
        return 'sma_$period';
      case IndicatorType.ema:
        return 'ema_$period';
      case IndicatorType.atr:
        return 'atr_$period';
      case IndicatorType.atrPct:
        return 'atr_pct_$period';
      case IndicatorType.adx:
        return 'adx_$period';
      case IndicatorType.macd:
        return 'macd_$period';
      case IndicatorType.macdSignal:
        return 'macd_signal_$period';
      case IndicatorType.macdHistogram:
        return 'macd_histogram_$period';
      case IndicatorType.bollingerBands:
        return 'bb_lower_$period';
      case IndicatorType.bollingerWidth:
        return 'bb_width_$period';
      case IndicatorType.vwap:
        return 'vwap_$period';
      case IndicatorType.anchoredVwap:
        return 'avwap_anchor0';
      case IndicatorType.stochasticK:
        return 'stoch_k_$period';
      case IndicatorType.stochasticD:
        return 'stoch_d_$period';
    }
  }

  static String _avwapKeyStart() => 'avwap_anchor0';
  static String _avwapKeyByDate(DateTime date) =>
      'avwap_date_${date.toIso8601String()}';

  static int _getDefaultPeriod(IndicatorType type) {
    switch (type) {
      case IndicatorType.rsi:
        return 14;
      case IndicatorType.sma:
      case IndicatorType.ema:
        return 20;
      case IndicatorType.macd:
        return 12;
      case IndicatorType.macdSignal:
        return 9;
      case IndicatorType.macdHistogram:
        return 9;
      case IndicatorType.atr:
        return 14;
      case IndicatorType.atrPct:
        return 14;
      case IndicatorType.adx:
        return 14;
      case IndicatorType.bollingerBands:
        return 20;
      case IndicatorType.bollingerWidth:
        return 20;
      case IndicatorType.vwap:
        return 20;
      case IndicatorType.stochasticK:
      case IndicatorType.stochasticD:
        return 14;
      default:
        return 14;
    }
  }
}