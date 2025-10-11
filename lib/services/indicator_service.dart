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

  /// ATR as percentage of price (ATR / Close)
  /// Useful for volatility filters that are consistent across instruments.
  List<double?> calculateATRPct(List<Candle> candles, int period) {
    if (period <= 0) {
      return List<double?>.filled(candles.length, null);
    }
    final atr = calculateATR(candles, period);
    final atrPct = List<double?>.filled(candles.length, null);

    for (var i = 0; i < candles.length; i++) {
      final a = atr[i];
      final c = candles[i].close;
      if (a != null && c.abs() > _eps) {
        atrPct[i] = a / c;
      }
    }

    return atrPct;
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

  /// Bollinger Width (Upper - Lower)
  /// Uses the same inputs as Bollinger Bands and returns a single series.
  List<double?> calculateBollingerWidth(
    List<Candle> candles,
    int period,
    double stdDev,
  ) {
    final width = List<double?>.filled(candles.length, null);
    if (period <= 0 || candles.isEmpty) return width;

    final bb = calculateBollingerBands(candles, period, stdDev);
    final upper = bb['upper']!;
    final lower = bb['lower']!;

    for (var i = 0; i < candles.length; i++) {
      final u = upper[i];
      final l = lower[i];
      if (u != null && l != null) {
        width[i] = (u - l).abs();
      }
    }
    return width;
  }

  /// Volume Weighted Average Price (rolling window)
  /// Uses typical price (H+L+C)/3 weighted by volume over the last `period` bars.
  List<double?> calculateVWAP(List<Candle> candles, int period) {
    final n = candles.length;
    final vwap = List<double?>.filled(n, null);
    if (period <= 0 || n == 0) return vwap;

    // Precompute typical price and handle volumes
    final typical = candles.map((c) => c.typical).toList();
    final volumes = candles.map((c) => c.volume).toList();

    for (var i = period - 1; i < n; i++) {
      double sumPV = 0.0;
      double sumV = 0.0;
      for (var j = i - period + 1; j <= i; j++) {
        final v = volumes[j];
        sumPV += typical[j] * v;
        sumV += v;
      }
      vwap[i] = sumV.abs() > _eps ? (sumPV / sumV) : null;
    }
    return vwap;
  }

  /// Anchored VWAP (from a fixed anchor index to current)
  /// Uses typical price (H+L+C)/3 weighted by volume from `anchorIndex` forward.
  /// All indices before `anchorIndex` remain null.
  List<double?> calculateAnchoredVWAP(List<Candle> candles, int anchorIndex) {
    final n = candles.length;
    final avwap = List<double?>.filled(n, null);
    if (n == 0) return avwap;
    if (anchorIndex < 0) anchorIndex = 0;
    if (anchorIndex >= n) return avwap;

    double sumPV = 0.0;
    double sumV = 0.0;
    for (var i = anchorIndex; i < n; i++) {
      final tp = candles[i].typical;
      final v = candles[i].volume;
      sumPV += tp * v;
      sumV += v;
      avwap[i] = sumV.abs() > _eps ? (sumPV / sumV) : null;
    }
    return avwap;
  }

  /// Stochastic Oscillator (%K and %D)
  /// %K = 100 * (Close - LL) / (HH - LL) over `kPeriod`
  /// %D = SMA(%K, `dPeriod`) with default `dPeriod = 3`
  Map<String, List<double?>> calculateStochastic(
    List<Candle> candles,
    int kPeriod, {
    int dPeriod = 3,
  }) {
    final n = candles.length;
    final k = List<double?>.filled(n, null);
    final d = List<double?>.filled(n, null);
    if (kPeriod <= 0 || n == 0) {
      return {'k': k, 'd': d};
    }

    // Compute rolling HH and LL inclusive of current bar
    for (var i = kPeriod - 1; i < n; i++) {
      double hh = candles[i - kPeriod + 1].high;
      double ll = candles[i - kPeriod + 1].low;
      for (var j = i - kPeriod + 1; j <= i; j++) {
        if (candles[j].high > hh) hh = candles[j].high;
        if (candles[j].low < ll) ll = candles[j].low;
      }
      final denom = hh - ll;
      if (denom.abs() <= _eps) {
        // Degenerate range: assign mid value to avoid NaN
        k[i] = 50.0;
      } else {
        k[i] = 100.0 * ((candles[i].close - ll) / denom);
      }
    }

    // %D as SMA of %K
    if (dPeriod > 0) {
      final dVals = _smaFromValues(k, dPeriod);
      for (var i = 0; i < n; i++) {
        d[i] = dVals[i];
      }
    }

    return {'k': k, 'd': d};
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

  /// Simple moving average over arbitrary values (nullable input)
  List<double?> _smaFromValues(List<double?> values, int period) {
    final n = values.length;
    final sma = List<double?>.filled(n, null);
    if (period <= 0 || n == 0) return sma;
    for (var i = period - 1; i < n; i++) {
      double sum = 0.0;
      bool hasNull = false;
      for (var j = i - period + 1; j <= i; j++) {
        final v = values[j];
        if (v == null) {
          hasNull = true;
          break;
        }
        sum += v;
      }
      if (!hasNull) sma[i] = sum / period;
    }
    return sma;
  }

  /// Highest High over a rolling window (HH)
  List<double?> calculateHighestHigh(List<Candle> candles, int period) {
    // We compute HH as the highest high over the PREVIOUS `period` bars,
    // excluding the current bar, so it can act as a static breakout threshold.
    // This avoids the moving-target issue where current close can never exceed
    // current HH (since HH includes the current high).
    final hh = List<double?>.filled(candles.length, null);

    if (period <= 1) {
      // Use previous bar's high as the threshold when period == 1
      for (var i = 1; i < candles.length; i++) {
        hh[i] = candles[i - 1].high;
      }
      return hh;
    }

    for (var i = period; i < candles.length; i++) {
      double maxHigh = candles[i - period].high;
      for (var j = i - period; j < i; j++) {
        if (candles[j].high > maxHigh) {
          maxHigh = candles[j].high;
        }
      }
      hh[i] = maxHigh;
    }
    return hh;
  }

  /// Lowest Low over a rolling window (LL)
  List<double?> calculateLowestLow(List<Candle> candles, int period) {
    // Compute LL as the lowest low over the PREVIOUS `period` bars,
    // excluding the current bar.
    final ll = List<double?>.filled(candles.length, null);

    if (period <= 1) {
      // Use previous bar's low as the threshold when period == 1
      for (var i = 1; i < candles.length; i++) {
        ll[i] = candles[i - 1].low;
      }
      return ll;
    }

    for (var i = period; i < candles.length; i++) {
      double minLow = candles[i - period].low;
      for (var j = i - period; j < i; j++) {
        if (candles[j].low < minLow) {
          minLow = candles[j].low;
        }
      }
      ll[i] = minLow;
    }
    return ll;
  }

  /// Average Directional Index (ADX) using Wilder's smoothing
  /// Returns ADX values (0–100). Null for indices before enough data.
  List<double?> calculateADX(List<Candle> candles, int period) {
    final n = candles.length;
    if (n == 0 || period <= 1) {
      return List<double?>.filled(n, null);
    }

    // True Range (TR), +DM, -DM per bar starting from index 1
    final tr = List<double>.filled(n, 0.0);
    final plusDM = List<double>.filled(n, 0.0);
    final minusDM = List<double>.filled(n, 0.0);

    for (var i = 1; i < n; i++) {
      final high = candles[i].high;
      final low = candles[i].low;
      final prevClose = candles[i - 1].close;
      final prevHigh = candles[i - 1].high;
      final prevLow = candles[i - 1].low;

      final tr1 = high - low;
      final tr2 = (high - prevClose).abs();
      final tr3 = (low - prevClose).abs();
      tr[i] = [tr1, tr2, tr3].reduce((a, b) => a > b ? a : b);

      final upMove = high - prevHigh;
      final downMove = prevLow - low;
      plusDM[i] = (upMove > 0 && upMove > downMove) ? upMove : 0.0;
      minusDM[i] = (downMove > 0 && downMove > upMove) ? downMove : 0.0;
    }

    // Wilder smoothing for TR, +DM, -DM
    final trSmooth = List<double?>.filled(n, null);
    final plusDMSmooth = List<double?>.filled(n, null);
    final minusDMSmooth = List<double?>.filled(n, null);

    double trSum = 0.0, plusDMSum = 0.0, minusDMSum = 0.0;
    // Initial sums over first `period` bars (indices 1..period)
    final start = 1;
    final endInit = (period < n) ? period : n - 1;
    for (var i = start; i <= endInit; i++) {
      trSum += tr[i];
      plusDMSum += plusDM[i];
      minusDMSum += minusDM[i];
    }
    if (endInit >= period) {
      trSmooth[period] = trSum;
      plusDMSmooth[period] = plusDMSum;
      minusDMSmooth[period] = minusDMSum;
    }

    for (var i = period + 1; i < n; i++) {
      trSum = (trSmooth[i - 1] ?? trSum) -
          ((trSmooth[i - 1] ?? trSum) / period) +
          tr[i];
      plusDMSum = (plusDMSmooth[i - 1] ?? plusDMSum) -
          ((plusDMSmooth[i - 1] ?? plusDMSum) / period) +
          plusDM[i];
      minusDMSum = (minusDMSmooth[i - 1] ?? minusDMSum) -
          ((minusDMSmooth[i - 1] ?? minusDMSum) / period) +
          minusDM[i];
      trSmooth[i] = trSum;
      plusDMSmooth[i] = plusDMSum;
      minusDMSmooth[i] = minusDMSum;
    }

    // Compute DI+ and DI-
    final diPlus = List<double?>.filled(n, null);
    final diMinus = List<double?>.filled(n, null);
    for (var i = period; i < n; i++) {
      final trS = trSmooth[i] ?? 0.0;
      if (trS <= 0) {
        diPlus[i] = 0.0;
        diMinus[i] = 0.0;
        continue;
      }
      diPlus[i] = 100.0 * ((plusDMSmooth[i] ?? 0.0) / trS);
      diMinus[i] = 100.0 * ((minusDMSmooth[i] ?? 0.0) / trS);
    }

    // DX and ADX
    final dx = List<double?>.filled(n, null);
    for (var i = period; i < n; i++) {
      final p = diPlus[i] ?? 0.0;
      final m = diMinus[i] ?? 0.0;
      final denom = p + m;
      dx[i] = denom == 0 ? 0.0 : 100.0 * ((p - m).abs() / denom);
    }

    final adx = List<double?>.filled(n, null);
    // First ADX as average of first `period` DX values (indices period..(2*period-1))
    if (2 * period < n) {
      double dxSum = 0.0;
      for (var i = period; i < period * 2; i++) {
        dxSum += dx[i] ?? 0.0;
      }
      adx[period * 2] = dxSum / period;

      // Wilder smoothing for subsequent ADX
      for (var i = period * 2 + 1; i < n; i++) {
        adx[i] =
            (((adx[i - 1] ?? 0.0) * (period - 1)) + (dx[i] ?? 0.0)) / period;
      }
    }

    return adx;
  }
}
