import 'package:backtestx/models/candle.dart';

int _parseTimeframeToMinutes(String timeframe) {
  final tf = timeframe.toUpperCase();
  if (tf.contains('M1') || tf.contains('1M') || tf.contains('1MIN')) return 1;
  if (tf.contains('M5') || tf.contains('5M')) return 5;
  if (tf.contains('M15') || tf.contains('15M')) return 15;
  if (tf.contains('M30') || tf.contains('30M')) return 30;
  if (tf.contains('H1') || tf.contains('1H')) return 60;
  if (tf.contains('H4') || tf.contains('4H')) return 240;
  if (tf.contains('D1') || tf.contains('1D') || tf.contains('DAILY')) {
    return 1440;
  }
  return 60;
}

DateTime _floorToPeriod(DateTime time, Duration period) {
  final ms = period.inMilliseconds;
  final ts = time.millisecondsSinceEpoch;
  final floored = (ts ~/ ms) * ms;
  return DateTime.fromMillisecondsSinceEpoch(floored);
}

// Public helpers for other modules
int parseTimeframeToMinutes(String timeframe) => _parseTimeframeToMinutes(timeframe);

DateTime floorToTimeframe(DateTime time, String timeframe) {
  final minutes = _parseTimeframeToMinutes(timeframe);
  return _floorToPeriod(time, Duration(minutes: minutes));
}

List<Candle> resampleCandlesByDuration(List<Candle> candles, Duration period) {
  if (candles.isEmpty) return candles;
  final buckets = <DateTime, List<Candle>>{};

  for (final c in candles) {
    final key = _floorToPeriod(c.timestamp, period);
    (buckets[key] ??= []).add(c);
  }

  final result = <Candle>[];
  final keys = buckets.keys.toList()..sort((a, b) => a.compareTo(b));
  for (final k in keys) {
    final group = buckets[k]!;
    group.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final open = group.first.open;
    final close = group.last.close;
    double high = group.first.high;
    double low = group.first.low;
    double volume = 0.0;
    for (final g in group) {
      if (g.high > high) high = g.high;
      if (g.low < low) low = g.low;
      volume += g.volume;
    }
    result.add(Candle(
      timestamp: k,
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume,
    ));
  }
  return result;
}

List<Candle> resampleCandlesToTimeframe(
  List<Candle> candles,
  String targetTimeframe,
) {
  final minutes = _parseTimeframeToMinutes(targetTimeframe);
  return resampleCandlesByDuration(candles, Duration(minutes: minutes));
}

MarketData resampleMarketDataToTimeframe(
  MarketData data,
  String targetTimeframe,
) {
  final resampled = resampleCandlesToTimeframe(data.candles, targetTimeframe);
  return MarketData(
    id: 'resampled_${data.id}_$targetTimeframe',
    symbol: data.symbol,
    timeframe: targetTimeframe,
    candles: resampled,
    uploadedAt: data.uploadedAt,
  );
}