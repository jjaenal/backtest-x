import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('IndicatorServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('RSI guards division-by-zero: monotonic uptrend yields 100 (no NaN)',
        () {
      final candles = List.generate(20, (i) {
        final price = 100.0 + i; // strictly increasing
        final ts = DateTime(2024, 1, 1).add(Duration(minutes: i));
        return Candle(
          timestamp: ts,
          open: price,
          high: price,
          low: price,
          close: price,
          volume: 0,
        );
      });

      final svc = IndicatorService();
      final rsi = svc.calculateRSI(candles, 14);

      expect(rsi[14], isNotNull);
      expect(rsi[14], closeTo(100.0, 1e-9));
      for (int i = 14; i < rsi.length; i++) {
        if (rsi[i] != null) {
          expect(rsi[i]!.isFinite, isTrue);
        }
      }
    });

    test('RSI guards division-by-zero: flat market yields 100 (no NaN)', () {
      final candles = List.generate(20, (i) {
        const price = 100.0; // constant
        final ts = DateTime(2024, 1, 1).add(Duration(minutes: i));
        return Candle(
          timestamp: ts,
          open: price,
          high: price,
          low: price,
          close: price,
          volume: 0,
        );
      });

      final svc = IndicatorService();
      final rsi = svc.calculateRSI(candles, 14);

      expect(rsi[14], isNotNull);
      expect(rsi[14], closeTo(100.0, 1e-9));
      for (int i = 14; i < rsi.length; i++) {
        if (rsi[i] != null) {
          expect(rsi[i]!.isFinite, isTrue);
        }
      }
    });
  });
}
