import 'package:freezed_annotation/freezed_annotation.dart';

part 'strategy.freezed.dart';
part 'strategy.g.dart';

@freezed
class Strategy with _$Strategy {
  const factory Strategy({
    required String id,
    required String name,
    required double initialCapital,
    required RiskManagement riskManagement,
    required List<StrategyRule> entryRules,
    required List<StrategyRule> exitRules,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Strategy;

  factory Strategy.fromJson(Map<String, dynamic> json) =>
      _$StrategyFromJson(json);
}

@freezed
class RiskManagement with _$RiskManagement {
  const factory RiskManagement({
    required RiskType riskType,
    required double riskValue, // Fixed lot atau % risk
    double? stopLoss, // in pips/points atau %
    double? takeProfit,
    @Default(false) bool useTrailingStop,
    double? trailingStopDistance,
  }) = _RiskManagement;

  factory RiskManagement.fromJson(Map<String, dynamic> json) =>
      _$RiskManagementFromJson(json);
}

enum RiskType {
  fixedLot,
  percentageRisk,
}

@freezed
class StrategyRule with _$StrategyRule {
  const factory StrategyRule({
    required IndicatorType indicator,
    required ComparisonOperator operator,
    required ConditionValue value,
    LogicalOperator? logicalOperator, // AND/OR untuk chain rules
    String? timeframe, // Opsional: timeframe khusus untuk rule ini (mis. "H1")
  }) = _StrategyRule;

  factory StrategyRule.fromJson(Map<String, dynamic> json) =>
      _$StrategyRuleFromJson(json);
}

enum IndicatorType {
  sma,
  ema,
  rsi,
  macd,
  atr,
  bollingerBands,
  close,
  open,
  high,
  low,
}

enum ComparisonOperator {
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  equals,
  crossAbove,
  crossBelow,
}

enum LogicalOperator {
  and,
  or,
}

@freezed
class ConditionValue with _$ConditionValue {
  const factory ConditionValue.number(double value) = _NumberValue;
  const factory ConditionValue.indicator({
    required IndicatorType type,
    int? period,
  }) = _IndicatorValue;

  factory ConditionValue.fromJson(Map<String, dynamic> json) =>
      _$ConditionValueFromJson(json);
}
