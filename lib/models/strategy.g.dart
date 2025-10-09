// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strategy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrategyImpl _$$StrategyImplFromJson(Map<String, dynamic> json) =>
    _$StrategyImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      initialCapital: (json['initialCapital'] as num).toDouble(),
      riskManagement: RiskManagement.fromJson(
          json['riskManagement'] as Map<String, dynamic>),
      entryRules: (json['entryRules'] as List<dynamic>)
          .map((e) => StrategyRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      exitRules: (json['exitRules'] as List<dynamic>)
          .map((e) => StrategyRule.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StrategyImplToJson(_$StrategyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'initialCapital': instance.initialCapital,
      'riskManagement': instance.riskManagement,
      'entryRules': instance.entryRules,
      'exitRules': instance.exitRules,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$RiskManagementImpl _$$RiskManagementImplFromJson(Map<String, dynamic> json) =>
    _$RiskManagementImpl(
      riskType: $enumDecode(_$RiskTypeEnumMap, json['riskType']),
      riskValue: (json['riskValue'] as num).toDouble(),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
      takeProfit: (json['takeProfit'] as num?)?.toDouble(),
      useTrailingStop: json['useTrailingStop'] as bool? ?? false,
      trailingStopDistance: (json['trailingStopDistance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$RiskManagementImplToJson(
        _$RiskManagementImpl instance) =>
    <String, dynamic>{
      'riskType': _$RiskTypeEnumMap[instance.riskType]!,
      'riskValue': instance.riskValue,
      'stopLoss': instance.stopLoss,
      'takeProfit': instance.takeProfit,
      'useTrailingStop': instance.useTrailingStop,
      'trailingStopDistance': instance.trailingStopDistance,
    };

const _$RiskTypeEnumMap = {
  RiskType.fixedLot: 'fixedLot',
  RiskType.percentageRisk: 'percentageRisk',
};

_$StrategyRuleImpl _$$StrategyRuleImplFromJson(Map<String, dynamic> json) =>
    _$StrategyRuleImpl(
      indicator: $enumDecode(_$IndicatorTypeEnumMap, json['indicator']),
      operator: $enumDecode(_$ComparisonOperatorEnumMap, json['operator']),
      value: ConditionValue.fromJson(json['value'] as Map<String, dynamic>),
      logicalOperator: $enumDecodeNullable(
          _$LogicalOperatorEnumMap, json['logicalOperator']),
      timeframe: json['timeframe'] as String?,
    );

Map<String, dynamic> _$$StrategyRuleImplToJson(_$StrategyRuleImpl instance) =>
    <String, dynamic>{
      'indicator': _$IndicatorTypeEnumMap[instance.indicator]!,
      'operator': _$ComparisonOperatorEnumMap[instance.operator]!,
      'value': instance.value,
      'logicalOperator': _$LogicalOperatorEnumMap[instance.logicalOperator],
      'timeframe': instance.timeframe,
    };

const _$IndicatorTypeEnumMap = {
  IndicatorType.sma: 'sma',
  IndicatorType.ema: 'ema',
  IndicatorType.rsi: 'rsi',
  IndicatorType.macd: 'macd',
  IndicatorType.atr: 'atr',
  IndicatorType.bollingerBands: 'bollingerBands',
  IndicatorType.close: 'close',
  IndicatorType.open: 'open',
  IndicatorType.high: 'high',
  IndicatorType.low: 'low',
};

const _$ComparisonOperatorEnumMap = {
  ComparisonOperator.greaterThan: 'greaterThan',
  ComparisonOperator.lessThan: 'lessThan',
  ComparisonOperator.greaterThanOrEqual: 'greaterThanOrEqual',
  ComparisonOperator.lessThanOrEqual: 'lessThanOrEqual',
  ComparisonOperator.equals: 'equals',
  ComparisonOperator.crossAbove: 'crossAbove',
  ComparisonOperator.crossBelow: 'crossBelow',
};

const _$LogicalOperatorEnumMap = {
  LogicalOperator.and: 'and',
  LogicalOperator.or: 'or',
};

_$NumberValueImpl _$$NumberValueImplFromJson(Map<String, dynamic> json) =>
    _$NumberValueImpl(
      (json['value'] as num).toDouble(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$NumberValueImplToJson(_$NumberValueImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'runtimeType': instance.$type,
    };

_$IndicatorValueImpl _$$IndicatorValueImplFromJson(Map<String, dynamic> json) =>
    _$IndicatorValueImpl(
      type: $enumDecode(_$IndicatorTypeEnumMap, json['type']),
      period: (json['period'] as num?)?.toInt(),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$IndicatorValueImplToJson(
        _$IndicatorValueImpl instance) =>
    <String, dynamic>{
      'type': _$IndicatorTypeEnumMap[instance.type]!,
      'period': instance.period,
      'runtimeType': instance.$type,
    };
