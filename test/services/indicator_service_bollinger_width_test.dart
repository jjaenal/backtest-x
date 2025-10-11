import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/models/candle.dart';

void main() {
  group('IndicatorService.calculateBollingerWidth', () {
    test('Width equals (upper - lower) and nulls for initial lookback', () {
      final service = IndicatorService();
      final now = DateTime.now();

      // Build simple ascending closes so BB bands are computable
      final candles = List<Candle>.generate(60, (i) {
        final base = 100.0 + i * 0.5;
        return Candle(
          timestamp: now.add(Duration(minutes: i)),
          open: base - 0.2,
          high: base + 0.3,
          low: base - 0.4,
          close: base,
          volume: 1000 + i * 10,
        );
      });

      const period = 20;
      const stdDev = 2.0;
      final width = service.calculateBollingerWidth(candles, period, stdDev);
      final bb = service.calculateBollingerBands(candles, period, stdDev);

      // First period-1 entries should be null
      expect(width.take(period - 1).every((e) => e == null), isTrue);

      // After enough bars, width equals upper - lower
      for (var i = period - 1; i < candles.length; i++) {
        final upper = bb['upper']![i];
        final lower = bb['lower']![i];
        if (upper != null && lower != null) {
          expect(width[i], isNotNull);
          expect(width[i]!.toStringAsFixed(10),
              ((upper - lower).abs()).toStringAsFixed(10));
        }
      }
    });
  });
}