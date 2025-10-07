import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class PatternMatch {
  final Candle candle;
  final String pattern;
  final String signal;
  final PatternStrength strength;
  final String description;

  PatternMatch({
    required this.candle,
    required this.pattern,
    required this.signal,
    required this.strength,
    required this.description,
  });

  Color get signalColor {
    if (signal.contains('Bullish')) return Colors.green;
    if (signal.contains('Bearish')) return Colors.red;
    return Colors.orange;
  }

  IconData get signalIcon {
    if (signal.contains('Bullish')) return Icons.trending_up;
    if (signal.contains('Bearish')) return Icons.trending_down;
    return Icons.remove;
  }
}

enum PatternStrength { weak, medium, strong }

extension PatternStrengthX on PatternStrength {
  String get label {
    switch (this) {
      case PatternStrength.weak:
        return 'Weak';
      case PatternStrength.medium:
        return 'Medium';
      case PatternStrength.strong:
        return 'Strong';
    }
  }

  Color get color {
    switch (this) {
      case PatternStrength.weak:
        return Colors.grey;
      case PatternStrength.medium:
        return Colors.orange;
      case PatternStrength.strong:
        return Colors.green;
    }
  }
}

class PatternScannerViewModel extends BaseViewModel {
  final _storageService = locator<StorageService>();
  final _dataManager = DataManager();

  List<MarketDataInfo> _marketDataList = [];
  List<MarketDataInfo> get marketDataList => _marketDataList;

  MarketDataInfo? _selectedMarketData;
  MarketDataInfo? get selectedMarketData => _selectedMarketData;

  List<PatternMatch> _patterns = [];
  List<PatternMatch> get patterns => _patterns;

  // Filters
  bool _showBullish = true;
  bool _showBearish = true;
  bool _showIndecision = true;

  bool get showBullish => _showBullish;
  bool get showBearish => _showBearish;
  bool get showIndecision => _showIndecision;

  List<PatternMatch> get filteredPatterns {
    return _patterns.where((p) {
      if (p.signal.contains('Bullish') && !_showBullish) return false;
      if (p.signal.contains('Bearish') && !_showBearish) return false;
      if (p.signal.contains('Indecision') && !_showIndecision) return false;
      return true;
    }).toList();
  }

  Future<void> initialize() async {
    await runBusyFuture(loadMarketData());
  }

  Future<void> loadMarketData() async {
    _marketDataList = await _storageService.getAllMarketDataInfo();
    notifyListeners();
  }

  Future<void> selectMarketData(MarketDataInfo data) async {
    _selectedMarketData = data;
    await scanPatterns();
    notifyListeners();
  }

  Future<void> scanPatterns() async {
    if (_selectedMarketData == null) return;

    setBusy(true);

    // Note: In real implementation, you need to load full MarketData with candles
    // This is simplified - you should have a method to load full candles
    // For now, we'll show the structure

    _patterns = [];

    // TODO: Load actual candles from storage or CSV
    final marketData = _dataManager.getData(_selectedMarketData!.id);
    // final marketData = await _storageService.loadFullMarketData(_selectedMarketData!.id);
    _patterns = _scanCandlesForPatterns(marketData!.candles);

    setBusy(false);
    notifyListeners();
  }

  List<PatternMatch> _scanCandlesForPatterns(List<Candle> candles) {
    final matches = <PatternMatch>[];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Hammer
      if (candle.isHammer) {
        matches.add(PatternMatch(
          candle: candle,
          pattern: 'Hammer',
          signal: 'Bullish Reversal',
          strength: _calculateStrength(candle),
          description: 'Long lower wick with small body at top. '
              'Indicates potential reversal from downtrend.',
        ));
      }

      // Shooting Star
      if (candle.isShootingStar) {
        matches.add(PatternMatch(
          candle: candle,
          pattern: 'Shooting Star',
          signal: 'Bearish Reversal',
          strength: _calculateStrength(candle),
          description: 'Long upper wick with small body at bottom. '
              'Indicates potential reversal from uptrend.',
        ));
      }

      // Doji
      if (candle.isDoji) {
        matches.add(PatternMatch(
          candle: candle,
          pattern: 'Doji',
          signal: 'Indecision',
          strength: PatternStrength.medium,
          description: 'Open and close are nearly equal. '
              'Indicates market indecision and potential reversal.',
        ));
      }

      // Marubozu
      if (candle.isMarubozu) {
        matches.add(PatternMatch(
          candle: candle,
          pattern: 'Marubozu',
          signal: candle.isBullish
              ? 'Strong Bullish Continuation'
              : 'Strong Bearish Continuation',
          strength: PatternStrength.strong,
          description: 'Little to no wicks. Strong momentum in one direction. '
              'Indicates continuation of current trend.',
        ));
      }

      // Spinning Top
      if (candle.isSpinningTop) {
        matches.add(PatternMatch(
          candle: candle,
          pattern: 'Spinning Top',
          signal: 'Indecision',
          strength: PatternStrength.weak,
          description: 'Small body with long wicks on both sides. '
              'Indicates uncertainty and potential reversal.',
        ));
      }
    }

    return matches;
  }

  PatternStrength _calculateStrength(Candle candle) {
    final bodyPercent = candle.bodyPercentage;

    if (bodyPercent > 70) return PatternStrength.strong;
    if (bodyPercent > 40) return PatternStrength.medium;
    return PatternStrength.weak;
  }

  void toggleBullishFilter() {
    _showBullish = !_showBullish;
    notifyListeners();
  }

  void toggleBearishFilter() {
    _showBearish = !_showBearish;
    notifyListeners();
  }

  void toggleIndecisionFilter() {
    _showIndecision = !_showIndecision;
    notifyListeners();
  }
}
