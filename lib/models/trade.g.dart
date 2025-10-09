// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TradeImpl _$$TradeImplFromJson(Map<String, dynamic> json) => _$TradeImpl(
      id: json['id'] as String,
      direction: $enumDecode(_$TradeDirectionEnumMap, json['direction']),
      entryTime: DateTime.parse(json['entryTime'] as String),
      entryPrice: (json['entryPrice'] as num).toDouble(),
      lotSize: (json['lotSize'] as num).toDouble(),
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      exitPrice: (json['exitPrice'] as num?)?.toDouble(),
      stopLoss: (json['stopLoss'] as num?)?.toDouble(),
      takeProfit: (json['takeProfit'] as num?)?.toDouble(),
      status: $enumDecodeNullable(_$TradeStatusEnumMap, json['status']),
      pnl: (json['pnl'] as num?)?.toDouble(),
      pnlPercentage: (json['pnlPercentage'] as num?)?.toDouble(),
      exitReason: json['exitReason'] as String?,
    );

Map<String, dynamic> _$$TradeImplToJson(_$TradeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'direction': _$TradeDirectionEnumMap[instance.direction]!,
      'entryTime': instance.entryTime.toIso8601String(),
      'entryPrice': instance.entryPrice,
      'lotSize': instance.lotSize,
      'exitTime': instance.exitTime?.toIso8601String(),
      'exitPrice': instance.exitPrice,
      'stopLoss': instance.stopLoss,
      'takeProfit': instance.takeProfit,
      'status': _$TradeStatusEnumMap[instance.status],
      'pnl': instance.pnl,
      'pnlPercentage': instance.pnlPercentage,
      'exitReason': instance.exitReason,
    };

const _$TradeDirectionEnumMap = {
  TradeDirection.buy: 'buy',
  TradeDirection.sell: 'sell',
};

const _$TradeStatusEnumMap = {
  TradeStatus.open: 'open',
  TradeStatus.closed: 'closed',
};

_$BacktestResultImpl _$$BacktestResultImplFromJson(Map<String, dynamic> json) =>
    _$BacktestResultImpl(
      id: json['id'] as String,
      strategyId: json['strategyId'] as String,
      marketDataId: json['marketDataId'] as String,
      executedAt: DateTime.parse(json['executedAt'] as String),
      trades: (json['trades'] as List<dynamic>)
          .map((e) => Trade.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary:
          BacktestSummary.fromJson(json['summary'] as Map<String, dynamic>),
      equityCurve: (json['equityCurve'] as List<dynamic>)
          .map((e) => EquityPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$BacktestResultImplToJson(
        _$BacktestResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'strategyId': instance.strategyId,
      'marketDataId': instance.marketDataId,
      'executedAt': instance.executedAt.toIso8601String(),
      'trades': instance.trades,
      'summary': instance.summary,
      'equityCurve': instance.equityCurve,
    };

_$BacktestSummaryImpl _$$BacktestSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$BacktestSummaryImpl(
      totalTrades: (json['totalTrades'] as num).toInt(),
      winningTrades: (json['winningTrades'] as num).toInt(),
      losingTrades: (json['losingTrades'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      totalPnl: (json['totalPnl'] as num).toDouble(),
      totalPnlPercentage: (json['totalPnlPercentage'] as num).toDouble(),
      profitFactor: (json['profitFactor'] as num).toDouble(),
      maxDrawdown: (json['maxDrawdown'] as num).toDouble(),
      maxDrawdownPercentage: (json['maxDrawdownPercentage'] as num).toDouble(),
      sharpeRatio: (json['sharpeRatio'] as num).toDouble(),
      averageWin: (json['averageWin'] as num).toDouble(),
      averageLoss: (json['averageLoss'] as num).toDouble(),
      largestWin: (json['largestWin'] as num).toDouble(),
      largestLoss: (json['largestLoss'] as num).toDouble(),
      expectancy: (json['expectancy'] as num).toDouble(),
      tfStats: (json['tfStats'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Map<String, num>.from(e as Map)),
      ),
    );

Map<String, dynamic> _$$BacktestSummaryImplToJson(
        _$BacktestSummaryImpl instance) =>
    <String, dynamic>{
      'totalTrades': instance.totalTrades,
      'winningTrades': instance.winningTrades,
      'losingTrades': instance.losingTrades,
      'winRate': instance.winRate,
      'totalPnl': instance.totalPnl,
      'totalPnlPercentage': instance.totalPnlPercentage,
      'profitFactor': instance.profitFactor,
      'maxDrawdown': instance.maxDrawdown,
      'maxDrawdownPercentage': instance.maxDrawdownPercentage,
      'sharpeRatio': instance.sharpeRatio,
      'averageWin': instance.averageWin,
      'averageLoss': instance.averageLoss,
      'largestWin': instance.largestWin,
      'largestLoss': instance.largestLoss,
      'expectancy': instance.expectancy,
      'tfStats': instance.tfStats,
    };

_$EquityPointImpl _$$EquityPointImplFromJson(Map<String, dynamic> json) =>
    _$EquityPointImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      equity: (json['equity'] as num).toDouble(),
      drawdown: (json['drawdown'] as num).toDouble(),
    );

Map<String, dynamic> _$$EquityPointImplToJson(_$EquityPointImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'equity': instance.equity,
      'drawdown': instance.drawdown,
    };
