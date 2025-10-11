import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/models/candle.dart';

void main() {
  group('IndicatorService.calculateAnchoredVWAP', () {
    test('returns nulls before anchor and correct VWAP from anchor onward', () {
      final svc = IndicatorService();

      // Build candles with known typical price and volume
      final candles = <Candle>[
        Candle(
          timestamp: DateTime(2024, 1, 1, 9),
          open: 10,
          high: 11,
          low: 9,
          close: 10,
          volume: 100,
        ), // typical = (11+9+10)/3 = 10, v=100
        Candle(
          timestamp: DateTime(2024, 1, 1, 10),
          open: 10,
          high: 12,
          low: 9,
          close: 11,
          volume: 200,
        ), // typical = (12+9+11)/3 = 10.67, v=200
        Candle(
          timestamp: DateTime(2024, 1, 1, 11),
          open: 11,
          high: 13,
          low: 10,
          close: 12,
          volume: 300,
        ), // typical = (13+10+12)/3 = 11.67, v=300
        Candle(
          timestamp: DateTime(2024, 1, 1, 12),
          open: 12,
          high: 14,
          low: 11,
          close: 13,
          volume: 400,
        ), // typical = (14+11+13)/3 = 12.67, v=400
      ];

      // Anchor at index 2 (third candle)
      final avwap = svc.calculateAnchoredVWAP(candles, 2);

      // Indices before anchor should be null
      expect(avwap[0], isNull);
      expect(avwap[1], isNull);

      // From anchor onward:
      // i=2: typical(candle[2]) since only anchor bar contributes
      final expected2 = candles[2].typical;
      expect(avwap[2], isNotNull);
      expect(avwap[2]!, closeTo(expected2, 1e-9));

      // i=3: sum(typical*v) / sum(v) using exact typical values
      final sumPV = candles[2].typical * candles[2].volume +
          candles[3].typical * candles[3].volume;
      final sumV = candles[2].volume + candles[3].volume;
      final expected3 = sumPV / sumV;
      expect(avwap[3], isNotNull);
      expect(avwap[3]!, closeTo(expected3, 1e-9));
    });

    test('handles out-of-range and negative anchor indices gracefully', () {
      final svc = IndicatorService();
      final candles = <Candle>[
        Candle(
          timestamp: DateTime(2024, 1, 1, 9),
          open: 10,
          high: 11,
          low: 9,
          close: 10,
          volume: 100,
        ),
      ];

      // Negative anchor -> clamp to 0
      final avwapNeg = svc.calculateAnchoredVWAP(candles, -5);
      expect(avwapNeg[0], isNotNull);

      // Anchor beyond length -> all nulls
      final avwapOob = svc.calculateAnchoredVWAP(candles, 10);
      expect(avwapOob[0], isNull);
    });

    test('supports anchor by date mapping to correct index', () {
      final svc = IndicatorService();

      final candles = <Candle>[
        Candle(
          timestamp: DateTime(2024, 1, 1, 9),
          open: 10,
          high: 11,
          low: 9,
          close: 10,
          volume: 100,
        ),
        Candle(
          timestamp: DateTime(2024, 1, 1, 10),
          open: 10,
          high: 12,
          low: 9,
          close: 11,
          volume: 200,
        ),
        Candle(
          timestamp: DateTime(2024, 1, 1, 11),
          open: 11,
          high: 13,
          low: 10,
          close: 12,
          volume: 300,
        ),
        Candle(
          timestamp: DateTime(2024, 1, 1, 12),
          open: 12,
          high: 14,
          low: 11,
          close: 13,
          volume: 400,
        ),
      ];

      // Choose anchorDate equal to the 3rd candle timestamp
      final anchorDate = candles[2].timestamp;
      // Resolve anchorIndex the same way engine does: first ts >= anchorDate
      final anchorIndex =
          candles.indexWhere((c) => !c.timestamp.isBefore(anchorDate));
      expect(anchorIndex, 2);

      final avwapByIndex = svc.calculateAnchoredVWAP(candles, anchorIndex);
      final avwapByDate = svc.calculateAnchoredVWAP(candles, 2);

      for (var i = 0; i < candles.length; i++) {
        final a = avwapByIndex[i];
        final b = avwapByDate[i];
        if (a == null || b == null) {
          expect(a, equals(b));
        } else {
          expect(a, closeTo(b, 1e-9));
        }
      }
    });
  });
}
