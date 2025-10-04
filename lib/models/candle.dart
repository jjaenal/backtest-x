import 'package:freezed_annotation/freezed_annotation.dart';

part 'candle.freezed.dart';
part 'candle.g.dart';

@freezed
class Candle with _$Candle {
  const factory Candle({
    required DateTime timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required double volume,
  }) = _Candle;

  factory Candle.fromJson(Map<String, dynamic> json) => _$CandleFromJson(json);

  factory Candle.fromCsvRow(List<dynamic> row, {bool hasHeader = false}) {
    // Expected format: Date/Time, Open, High, Low, Close, Volume
    return Candle(
      timestamp: DateTime.parse(row[0].toString()),
      open: double.parse(row[1].toString()),
      high: double.parse(row[2].toString()),
      low: double.parse(row[3].toString()),
      close: double.parse(row[4].toString()),
      volume: row.length > 5 ? double.parse(row[5].toString()) : 0.0,
    );
  }
}

@freezed
class MarketData with _$MarketData {
  const factory MarketData({
    required String id,
    required String symbol,
    required String timeframe,
    required List<Candle> candles,
    required DateTime uploadedAt,
  }) = _MarketData;

  factory MarketData.fromJson(Map<String, dynamic> json) =>
      _$MarketDataFromJson(json);
}
