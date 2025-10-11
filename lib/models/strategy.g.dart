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
  RiskType.atrBased: 'atrBased',
};

_$StrategyRuleImpl _$$StrategyRuleImplFromJson(Map<String, dynamic> json) =>
    _$StrategyRuleImpl(
      indicator: $enumDecode(_$IndicatorTypeEnumMap, json['indicator']),
      operator: $enumDecode(_$ComparisonOperatorEnumMap, json['operator']),
      value: ConditionValue.fromJson(json['value'] as Map<String, dynamic>),
      period: (json['period'] as num?)?.toInt(),
      logicalOperator: $enumDecodeNullable(
          _$LogicalOperatorEnumMap, json['logicalOperator']),
      timeframe: json['timeframe'] as String?,
    );

Map<String, dynamic> _$$StrategyRuleImplToJson(_$StrategyRuleImpl instance) =>
    <String, dynamic>{
      'indicator': _$IndicatorTypeEnumMap[instance.indicator]!,
      'operator': _$ComparisonOperatorEnumMap[instance.operator]!,
      'value': instance.value,
      'period': instance.period,
      'logicalOperator': _$LogicalOperatorEnumMap[instance.logicalOperator],
      'timeframe': instance.timeframe,
    };

const _$IndicatorTypeEnumMap = {
  IndicatorType.sma: 'sma',
  IndicatorType.ema: 'ema',
  IndicatorType.rsi: 'rsi',
  IndicatorType.macd: 'macd',
  IndicatorType.macdSignal: 'macdSignal',
  IndicatorType.macdHistogram: 'macdHistogram',
  IndicatorType.atr: 'atr',
  IndicatorType.atrPct: 'atrPct',
  IndicatorType.adx: 'adx',
  IndicatorType.bollingerBands: 'bollingerBands',
  IndicatorType.bollingerWidth: 'bollingerWidth',
  IndicatorType.close: 'close',
  IndicatorType.open: 'open',
  IndicatorType.high: 'high',
  IndicatorType.low: 'low',
  IndicatorType.vwap: 'vwap',
  IndicatorType.anchoredVwap: 'anchoredVwap',
  IndicatorType.stochasticK: 'stochasticK',
  IndicatorType.stochasticD: 'stochasticD',
};

const _$ComparisonOperatorEnumMap = {
  ComparisonOperator.greaterThan: 'greaterThan',
  ComparisonOperator.lessThan: 'lessThan',
  ComparisonOperator.greaterThanOrEqual: 'greaterThanOrEqual',
  ComparisonOperator.lessThanOrEqual: 'lessThanOrEqual',
  ComparisonOperator.equals: 'equals',
  ComparisonOperator.crossAbove: 'crossAbove',
  ComparisonOperator.crossBelow: 'crossBelow',
  ComparisonOperator.rising: 'rising',
  ComparisonOperator.falling: 'falling',
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
      anchorMode: $enumDecodeNullable(_$AnchorModeEnumMap, json['anchorMode']),
      anchorDate: json['anchorDate'] == null
          ? null
          : DateTime.parse(json['anchorDate'] as String),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$IndicatorValueImplToJson(
        _$IndicatorValueImpl instance) =>
    <String, dynamic>{
      'type': _$IndicatorTypeEnumMap[instance.type]!,
      'period': instance.period,
      'anchorMode': _$AnchorModeEnumMap[instance.anchorMode],
      'anchorDate': instance.anchorDate?.toIso8601String(),
      'runtimeType': instance.$type,
    };

const _$AnchorModeEnumMap = {
  AnchorMode.startOfBacktest: 'startOfBacktest',
  AnchorMode.byDate: 'byDate',
};
