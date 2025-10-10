import 'dart:math';
import 'package:backtestx/models/candle.dart';

class IndicatorService {
  // Small epsilon to guard near-zero denominators
  static const double _eps = 1e-12;
  /// Simple Moving Average
  List<double?> calculateSMA(List<Candle> candles, int period) {
    if (period <= 0) {
      return List<double?>.filled(candles.length, null);
    }
    final closes = candles.map((c) => c.close).toList();
    final sma = List<double?>.filled(closes.length, null);

    if (closes.length < period) return sma;

    for (var i = period - 1; i < closes.length; i++) {
      final sum = closes.sublist(i - period + 1, i + 1).reduce((a, b) => a + b);
      sma[i] = sum / period;
    }

    return sma;
  }

  /// Exponential Moving Average
  List<double?> calculateEMA(List<Candle> candles, int period) {
    if (period <= 0) {
      return List<double?>.filled(candles.length, null);
    }
    final closes = candles.map((c) => c.close).toList();
    final ema = List<double?>.filled(closes.length, null);

    if (closes.length < period) return ema;

    final multiplier = 2 / (period + 1);

    // First EMA = SMA
    double sum = 0;
    for (var i = 0; i < period; i++) {
      sum += closes[i];
    }
    ema[period - 1] = sum / period;

    // Calculate EMA
    for (var i = period; i < closes.length; i++) {
      ema[i] = (closes[i] - ema[i - 1]!) * multiplier + ema[i - 1]!;
    }

    return ema;
  }

  /// Relative Strength Index
  List<double?> calculateRSI(List<Candle> candles, int period) {
    if (period <= 0) {
      return List<double?>.filled(candles.length, null);
    }
    final closes = candles.map((c) => c.close).toList();
    final rsi = List<double?>.filled(closes.length, null);

    if (closes.length < period + 1) return rsi;

    double avgGain = 0;
    double avgLoss = 0;

    // First average gain/loss
    for (var i = 1; i <= period; i++) {
      // final change = closes[i] - closes[i - 1];
      final change =
          candles[i].priceChange(candles[i - 1]); // ✅ Using extension
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }
    avgGain /= period;
    avgLoss /= period;

    // Guard division-by-zero and near-zero losses
    if (avgLoss <= _eps) {
      rsi[period] = 100;
    } else {
      rsi[period] = 100 - (100 / (1 + avgGain / avgLoss));
    }

    // Smooth with Wilder's method
    for (var i = period + 1; i < closes.length; i++) {
      // final change = closes[i] - closes[i - 1];
      final change =
          candles[i].priceChange(candles[i - 1]); // ✅ Using extension
      final gain = change > 0 ? change : 0;
      final loss = change < 0 ? change.abs() : 0;

      avgGain = (avgGain * (period - 1) + gain) / period;
      avgLoss = (avgLoss * (period - 1) + loss) / period;

      // Guard division-by-zero and near-zero losses
      if (avgLoss <= _eps) {
        rsi[i] = 100;
      } else {
        rsi[i] = 100 - (100 / (1 + avgGain / avgLoss));
      }
    }

    return rsi;
  }

  /// Average True Range
  List<double?> calculateATR(List<Candle> candles, int period) {
    if (period <= 0) {
      return List<double?>.filled(candles.length, null);
    }
    final atr = List<double?>.filled(candles.length, null);

    if (candles.length < period + 1) return atr;

    final trueRanges = <double>[];

    for (var i = 1; i < candles.length; i++) {
      final high = candles[i].high;
      final low = candles[i].low;
      final prevClose = candles[i - 1].close;

      final tr = max(
        high - low,
        max((high - prevClose).abs(), (low - prevClose).abs()),
      );
      trueRanges.add(tr);
    }

    // First ATR is simple average
    double sum = 0;
    for (var i = 0; i < period; i++) {
      sum += trueRanges[i];
    }
    atr[period] = sum / period;

    // Smooth ATR
    for (var i = period + 1; i < candles.length; i++) {
      atr[i] = (atr[i - 1]! * (period - 1) + trueRanges[i - 1]) / period;
    }

    return atr;
  }

  /// MACD (returns [macdLine, signalLine, histogram])
  Map<String, List<double?>> calculateMACD(
    List<Candle> candles, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    final fastEMA = calculateEMA(candles, fastPeriod);
    final slowEMA = calculateEMA(candles, slowPeriod);

    final macdLine = List<double?>.filled(candles.length, null);

    for (var i = 0; i < candles.length; i++) {
      if (fastEMA[i] != null && slowEMA[i] != null) {
        macdLine[i] = fastEMA[i]! - slowEMA[i]!;
      }
    }

    // Signal line is EMA of MACD
    final signalLine = _emaFromValues(macdLine, signalPeriod);

    // Histogram
    final histogram = List<double?>.filled(candles.length, null);
    for (var i = 0; i < candles.length; i++) {
      if (macdLine[i] != null && signalLine[i] != null) {
        histogram[i] = macdLine[i]! - signalLine[i]!;
      }
    }

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': histogram,
    };
  }

  /// Bollinger Bands (returns [upper, middle, lower])
  Map<String, List<double?>> calculateBollingerBands(
    List<Candle> candles,
    int period,
    double stdDev,
  ) {
    if (period <= 0) {
      final empty = List<double?>.filled(candles.length, null);
      return {
        'upper': empty,
        'middle': empty,
        'lower': empty,
      };
    }
    final sma = calculateSMA(candles, period);
    final closes = candles.map((c) => c.close).toList();

    final upper = List<double?>.filled(candles.length, null);
    final lower = List<double?>.filled(candles.length, null);

    for (var i = period - 1; i < closes.length; i++) {
      final slice = closes.sublist(i - period + 1, i + 1);
      final mean = sma[i]!;
      final variance =
          slice.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / period;
      final sd = sqrt(variance);

      upper[i] = mean + (stdDev * sd);
      lower[i] = mean - (stdDev * sd);
    }

    return {
      'upper': upper,
      'middle': sma,
      'lower': lower,
    };
  }

  // Helper: Calculate EMA from values list
  List<double?> _emaFromValues(List<double?> values, int period) {
    if (period <= 0) {
      return List<double?>.filled(values.length, null);
    }
    final ema = List<double?>.filled(values.length, null);

    final validValues = <double>[];
    int startIdx = 0;

    for (var i = 0; i < values.length; i++) {
      if (values[i] != null) {
        validValues.add(values[i]!);
        if (validValues.length == 1) startIdx = i;
        if (validValues.length >= period) break;
      }
    }

    if (validValues.length < period) return ema;

    final multiplier = 2 / (period + 1);

    // First EMA
    final sum = validValues.sublist(0, period).reduce((a, b) => a + b);
    ema[startIdx + period - 1] = sum / period;

    // Calculate rest
    // int valIdx = period;
    for (var i = startIdx + period; i < values.length; i++) {
      if (values[i] != null && ema[i - 1] != null) {
        ema[i] = (values[i]! - ema[i - 1]!) * multiplier + ema[i - 1]!;
      }
    }

    return ema;
  }
}
