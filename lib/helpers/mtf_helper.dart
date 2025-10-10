import 'package:backtestx/models/candle.dart';
import 'package:backtestx/helpers/timeframe_helper.dart';

/// Build per‑timeframe candle series from a base series.
/// Ensures each requested timeframe has a resampled series (if not base).
Map<String, List<Candle>> buildTimeframeCandles(
  List<Candle> baseCandles,
  String baseTimeframe,
  Set<String> ruleTimeframes,
) {
  final result = <String, List<Candle>>{baseTimeframe: baseCandles};
  for (final tf in ruleTimeframes) {
    if (tf == baseTimeframe) continue;
    result[tf] = resampleCandlesToTimeframe(baseCandles, tf);
  }
  return result;
}

/// Build index mapping from base candles to each timeframe series.
/// For each base index i and timeframe tf, map to index j in tf series where
/// timestamp <= floorToTimeframe(base[i].timestamp, tf). Prevents lookahead.
Map<String, List<int?>> buildTfIndexMap(
  List<Candle> baseCandles,
  String baseTimeframe,
  Map<String, List<Candle>> tfCandles,
) {
  final map = <String, List<int?>>{};
  // Base maps 1:1
  map[baseTimeframe] = List<int?>.generate(baseCandles.length, (i) => i);

  for (final entry in tfCandles.entries) {
    final tf = entry.key;
    if (tf == baseTimeframe) continue;
    final target = entry.value;

    // Build timestamp → index map and sorted timestamps
    final tsToIdx = <DateTime, int>{};
    final tsList = <DateTime>[];
    for (var j = 0; j < target.length; j++) {
      final ts = target[j].timestamp;
      tsToIdx[ts] = j;
      tsList.add(ts);
    }
    tsList.sort((a, b) => a.compareTo(b));

    int? findIndexAtOrBefore(DateTime ts) {
      if (tsList.isEmpty) return null;
      int lo = 0, hi = tsList.length - 1, ans = -1;
      while (lo <= hi) {
        final mid = (lo + hi) >> 1;
        final midTs = tsList[mid];
        if (midTs.isAfter(ts)) {
          hi = mid - 1;
        } else {
          ans = mid;
          lo = mid + 1;
        }
      }
      if (ans < 0) return null;
      return tsToIdx[tsList[ans]];
    }

    final mapList = List<int?>.filled(baseCandles.length, null);
    for (var i = 0; i < baseCandles.length; i++) {
      final bucketTs = floorToTimeframe(baseCandles[i].timestamp, tf);
      mapList[i] = tsToIdx[bucketTs] ?? findIndexAtOrBefore(bucketTs);
    }
    map[tf] = mapList;
  }

  return map;
}