// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'candle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CandleImpl _$$CandleImplFromJson(Map<String, dynamic> json) => _$CandleImpl(
      timestamp: DateTime.parse(json['timestamp'] as String),
      open: (json['open'] as num).toDouble(),
      high: (json['high'] as num).toDouble(),
      low: (json['low'] as num).toDouble(),
      close: (json['close'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
    );

Map<String, dynamic> _$$CandleImplToJson(_$CandleImpl instance) =>
    <String, dynamic>{
      'timestamp': instance.timestamp.toIso8601String(),
      'open': instance.open,
      'high': instance.high,
      'low': instance.low,
      'close': instance.close,
      'volume': instance.volume,
    };

_$MarketDataImpl _$$MarketDataImplFromJson(Map<String, dynamic> json) =>
    _$MarketDataImpl(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      timeframe: json['timeframe'] as String,
      candles: (json['candles'] as List<dynamic>)
          .map((e) => Candle.fromJson(e as Map<String, dynamic>))
          .toList(),
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
    );

Map<String, dynamic> _$$MarketDataImplToJson(_$MarketDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbol': instance.symbol,
      'timeframe': instance.timeframe,
      'candles': instance.candles,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
    };
