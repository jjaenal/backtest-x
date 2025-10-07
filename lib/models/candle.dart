import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

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

// Candle extensions
extension CandleX on Candle {
  // Candlestick patterns
  bool get isBullish => close > open;
  bool get isBearish => close < open;
  bool get isDoji => (close - open).abs() < (high - low) * 0.1;

  // Price movements
  double get bodySize => (close - open).abs();
  double get upperWick => high - (isBullish ? close : open);
  double get lowerWick => (isBullish ? open : close) - low;
  double get totalRange => high - low;

  // Body percentage
  double get bodyPercentage =>
      totalRange > 0 ? (bodySize / totalRange) * 100 : 0;

  // Price change
  double priceChange(Candle previousCandle) {
    return close - previousCandle.close;
  }

  double priceChangePercent(Candle previousCandle) {
    if (previousCandle.close == 0) return 0;
    return ((close - previousCandle.close) / previousCandle.close) * 100;
  }

  // Common price levels
  double get typical => (high + low + close) / 3;
  double get median => (high + low) / 2;
  double get weightedClose => (high + low + close + close) / 4;

  // Formatting
  String formatPrice([int decimals = 2]) {
    return close.toStringAsFixed(decimals);
  }

  String formatVolume() {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toStringAsFixed(0);
  }

  // Candlestick patterns (advanced)
  bool get isHammer {
    return isBullish && lowerWick > bodySize * 2 && upperWick < bodySize * 0.5;
  }

  bool get isShootingStar {
    return isBearish && upperWick > bodySize * 2 && lowerWick < bodySize * 0.5;
  }

  bool get isMarubozu {
    return bodyPercentage > 90;
  }

  bool get isSpinningTop {
    return bodyPercentage < 30 && !isDoji;
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

// MarketData extensions
extension MarketDataX on MarketData {
  // Basic info
  int get candlesCount => candles.length;

  DateTime? get firstDate =>
      candles.isNotEmpty ? candles.first.timestamp : null;
  DateTime? get lastDate => candles.isNotEmpty ? candles.last.timestamp : null;

  String get dateRangeLabel {
    if (candles.isEmpty) return 'No data';
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(candles.first.timestamp)} - ${formatter.format(candles.last.timestamp)}';
  }

  String get displayName => '$symbol ($timeframe)';

  // Statistics
  double get highestPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
  }

  double get lowestPrice {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
  }

  double get averageClose {
    if (candles.isEmpty) return 0;
    final sum = candles.map((c) => c.close).reduce((a, b) => a + b);
    return sum / candles.length;
  }

  double get totalVolume {
    if (candles.isEmpty) return 0;
    return candles.map((c) => c.volume).reduce((a, b) => a + b);
  }

  double get averageVolume {
    if (candles.isEmpty) return 0;
    return totalVolume / candles.length;
  }

  // Price movement
  double get totalPriceChange {
    if (candles.length < 2) return 0;
    return candles.last.close - candles.first.close;
  }

  double get totalPriceChangePercent {
    if (candles.length < 2 || candles.first.close == 0) return 0;
    return ((candles.last.close - candles.first.close) / candles.first.close) *
        100;
  }

  // Trend analysis
  bool get isUptrend {
    if (candles.length < 10) return false;
    final recent = candles.sublist(candles.length - 10);
    final firstAvg =
        recent.sublist(0, 5).map((c) => c.close).reduce((a, b) => a + b) / 5;
    final lastAvg =
        recent.sublist(5).map((c) => c.close).reduce((a, b) => a + b) / 5;
    return lastAvg > firstAvg;
  }

  bool get isDowntrend {
    if (candles.length < 10) return false;
    final recent = candles.sublist(candles.length - 10);
    final firstAvg =
        recent.sublist(0, 5).map((c) => c.close).reduce((a, b) => a + b) / 5;
    final lastAvg =
        recent.sublist(5).map((c) => c.close).reduce((a, b) => a + b) / 5;
    return lastAvg < firstAvg;
  }

  // Volatility
  double get priceRange => highestPrice - lowestPrice;

  double averageTrueRange([int period = 14]) {
    if (candles.length < period + 1) return 0;

    double sum = 0;
    for (int i = 1; i < period + 1; i++) {
      final current = candles[candles.length - i];
      final previous = candles[candles.length - i - 1];

      final tr = [
        current.high - current.low,
        (current.high - previous.close).abs(),
        (current.low - previous.close).abs(),
      ].reduce((a, b) => a > b ? a : b);

      sum += tr;
    }

    return sum / period;
  }

  // Get candles in date range
  List<Candle> getCandlesInRange(DateTime start, DateTime end) {
    return candles.where((c) {
      return c.timestamp.isAfter(start) && c.timestamp.isBefore(end);
    }).toList();
  }

  // Get candles by count (most recent)
  List<Candle> getRecentCandles(int count) {
    if (candles.length <= count) return candles;
    return candles.sublist(candles.length - count);
  }

  // Validation
  bool get isValid => candles.isNotEmpty && symbol.isNotEmpty;

  bool get hasVolumeData => candles.any((c) => c.volume > 0);

  // Data quality checks
  bool get hasGaps {
    if (candles.length < 2) return false;

    for (int i = 1; i < candles.length; i++) {
      final diff = candles[i].timestamp.difference(candles[i - 1].timestamp);
      // Check if gap is more than expected (depends on timeframe)
      if (diff.inMinutes > _getExpectedGapMinutes() * 2) {
        return true;
      }
    }
    return false;
  }

  int _getExpectedGapMinutes() {
    // Parse timeframe to get expected gap
    if (timeframe.contains('M1')) return 1;
    if (timeframe.contains('M5')) return 5;
    if (timeframe.contains('M15')) return 15;
    if (timeframe.contains('M30')) return 30;
    if (timeframe.contains('H1')) return 60;
    if (timeframe.contains('H4')) return 240;
    if (timeframe.contains('D1')) return 1440;
    return 60; // Default 1 hour
  }
}

// Note: Import intl package at top for DateFormat functionality
