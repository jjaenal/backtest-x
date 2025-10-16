import 'package:flutter/material.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class IndicatorFormatter {
  static String format(IndicatorType indicator) {
    final map = {
      IndicatorType.close: 'Close',
      IndicatorType.open: 'Open',
      IndicatorType.high: 'High',
      IndicatorType.low: 'Low',
      IndicatorType.rsi: 'RSI',
      IndicatorType.sma: 'SMA',
      IndicatorType.ema: 'EMA',
      IndicatorType.macd: 'MACD',
      IndicatorType.macdSignal: 'MACD Signal',
      IndicatorType.macdHistogram: 'MACD Histogram',
      IndicatorType.atr: 'ATR',
      IndicatorType.atrPct: 'ATR%',
      IndicatorType.adx: 'ADX',
      IndicatorType.bollingerBands: 'Bollinger Bands',
      IndicatorType.bollingerWidth: 'Bollinger Width',
      IndicatorType.vwap: 'VWAP',
      IndicatorType.anchoredVwap: 'Anchored VWAP',
      IndicatorType.stochasticK: 'Stochastic %K',
      IndicatorType.stochasticD: 'Stochastic %D',
    };
    return map[indicator] ?? indicator.name;
  }

  static String formatOperator(BuildContext context, ComparisonOperator op) {
    final l10n = AppLocalizations.of(context)!;
    switch (op) {
      case ComparisonOperator.greaterThan:
        return l10n.sbOperatorNameGreaterThan;
      case ComparisonOperator.lessThan:
        return l10n.sbOperatorNameLessThan;
      case ComparisonOperator.greaterThanOrEqual:
        return l10n.sbOperatorNameGreaterOrEqual;
      case ComparisonOperator.lessThanOrEqual:
        return l10n.sbOperatorNameLessOrEqual;
      case ComparisonOperator.equals:
        return l10n.sbOperatorNameEquals;
      case ComparisonOperator.crossAbove:
        return l10n.sbOperatorNameCrossAbove;
      case ComparisonOperator.crossBelow:
        return l10n.sbOperatorNameCrossBelow;
      case ComparisonOperator.rising:
        return l10n.sbOperatorNameRising;
      case ComparisonOperator.falling:
        return l10n.sbOperatorNameFalling;
    }
  }

  static String formatRiskType(RiskType type) {
    switch (type) {
      case RiskType.fixedLot:
        return 'Fixed Lot Size';
      case RiskType.percentageRisk:
        return 'Percentage Risk';
      case RiskType.atrBased:
        return 'ATR-Based Sizing';
    }
  }

  static String operatorTooltip(BuildContext context, ComparisonOperator op) {
    final l10n = AppLocalizations.of(context)!;
    switch (op) {
      case ComparisonOperator.rising:
        return l10n.sbOperatorTooltipRising;
      case ComparisonOperator.falling:
        return l10n.sbOperatorTooltipFalling;
      case ComparisonOperator.crossAbove:
        return l10n.sbOperatorTooltipCrossAbove;
      case ComparisonOperator.crossBelow:
        return l10n.sbOperatorTooltipCrossBelow;
      default:
        return l10n.sbOperatorTooltipDefault;
    }
  }
}
