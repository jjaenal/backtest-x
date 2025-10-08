import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/price_range.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stacked/stacked.dart';

class CandlestickChartModel extends BaseViewModel {
  List<Candle> _visibleCandles = [];
  List<Candle> get visibleCandles => _visibleCandles;
  PriceRange _priceRange = PriceRange(min: 0, max: 100);
  PriceRange get priceRange => _priceRange;
  double _minVisibleIndex = 0;
  double get minVisibleIndex => _minVisibleIndex;
  double _maxVisibleIndex = 100;
  double get maxVisibleIndex => _maxVisibleIndex;
  int? hoveredIndex;
  // int? get hoveredIndex => _hoveredIndex!;

  void initialize(List<Candle> candles) {
    _maxVisibleIndex = candles.length.toDouble();
    _minVisibleIndex = (_maxVisibleIndex - 100).clamp(0, _maxVisibleIndex);
    _visibleCandles = _getVisibleCandles(candles);
    _priceRange = _calculatePriceRange(_visibleCandles);
  }

  void mainChartTouchCallback(FlTouchEvent event, LineTouchResponse? response) {
    if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
      if (response?.lineBarSpots != null &&
          response!.lineBarSpots!.isNotEmpty) {
        hoveredIndex = response.lineBarSpots!.first.x.toInt();
        notifyListeners();
      }
    }
  }

  void zoomControllOnChanged(double value, List<Candle> candles) {
    final center = (_minVisibleIndex + _maxVisibleIndex) / 2;
    _minVisibleIndex = (center - value / 2).clamp(0, candles.length.toDouble());
    _maxVisibleIndex = (center + value / 2).clamp(0, candles.length.toDouble());
    notifyListeners();
  }

  void zoomIn(List<Candle> candles) {
    final range = _maxVisibleIndex - _minVisibleIndex;
    final center = (_minVisibleIndex + _maxVisibleIndex) / 2;
    final newRange = (range * 0.7).clamp(10, candles.length.toDouble());
    _minVisibleIndex =
        (center - newRange / 2).clamp(0, candles.length.toDouble());
    _maxVisibleIndex =
        (center + newRange / 2).clamp(0, candles.length.toDouble());
    notifyListeners();
  }

  void zoomOut(List<Candle> candles) {
    final range = _maxVisibleIndex - _minVisibleIndex;
    final center = (_minVisibleIndex + _maxVisibleIndex) / 2;
    final newRange = (range * 1.3).clamp(10, candles.length.toDouble());
    _minVisibleIndex =
        (center - newRange / 2).clamp(0, candles.length.toDouble());
    _maxVisibleIndex =
        (center + newRange / 2).clamp(0, candles.length.toDouble());
    notifyListeners();
  }

  void resetZoom(List<Candle> candles) {
    _maxVisibleIndex = candles.length.toDouble();
    _minVisibleIndex = (_maxVisibleIndex - 100).clamp(0, _maxVisibleIndex);
    notifyListeners();
  }

  List<Candle> _getVisibleCandles(List<Candle> candles) {
    final start = _minVisibleIndex.toInt().clamp(0, candles.length);
    final end = _maxVisibleIndex.toInt().clamp(0, candles.length);
    return candles.sublist(start, end);
  }

  PriceRange _calculatePriceRange(List<Candle> candles) {
    if (candles.isEmpty) {
      return PriceRange(min: 0, max: 100);
    }

    double min = candles.first.low;
    double max = candles.first.high;

    for (final candle in candles) {
      if (candle.low < min) min = candle.low;
      if (candle.high > max) max = candle.high;
    }

    // Add padding
    final padding = (max - min) * 0.1;
    return PriceRange(min: min - padding, max: max + padding);
  }

  String formatVolume(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
