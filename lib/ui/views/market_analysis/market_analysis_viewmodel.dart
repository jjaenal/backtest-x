import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'dart:async';

class MarketAnalysisData {
  final String symbol;
  final String timeframe;
  final int candlesCount;
  final String dateRange;

  // Price
  final double highestPrice;
  final double lowestPrice;
  final double averagePrice;
  final double currentPrice;
  final double priceRange;

  // Movement
  final double totalChange;
  final double totalChangePercent;

  // Trend
  final String trend;
  final String trendStrength;

  // Volatility
  final double atr;
  final String volatility;

  // Volume
  final double totalVolume;
  final double averageVolume;
  final bool hasVolumeData;

  // Quality
  final bool hasGaps;
  final bool isValid;

  MarketAnalysisData({
    required this.symbol,
    required this.timeframe,
    required this.candlesCount,
    required this.dateRange,
    required this.highestPrice,
    required this.lowestPrice,
    required this.averagePrice,
    required this.currentPrice,
    required this.priceRange,
    required this.totalChange,
    required this.totalChangePercent,
    required this.trend,
    required this.trendStrength,
    required this.atr,
    required this.volatility,
    required this.totalVolume,
    required this.averageVolume,
    required this.hasVolumeData,
    required this.hasGaps,
    required this.isValid,
  });
}

class MarketAnalysisViewModel extends BaseViewModel {
  final _storageService = locator<StorageService>();
  final _indicatorService = locator<IndicatorService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dataManager = locator<DataManager>();
  StreamSubscription<MarketDataEvent>? _marketDataSub;
  MarketData? _marketData;
  MarketData? get marketData => _marketData;

  List<double?>? sma20;
  List<double?>? ema50;
  Map<String, List<double?>>? bb;
  List<double?>? rsi;
  Map<String, List<double?>>? macd;
  List<MarketDataInfo> _marketDataList = [];
  List<MarketDataInfo> get marketDataList => _marketDataList;

  MarketDataInfo? _selectedMarketData;
  MarketDataInfo? get selectedMarketData => _selectedMarketData;

  // Analysis data (would come from actual MarketData with candles)
  MarketAnalysisData? _analysisData;
  MarketAnalysisData? get analysisData => _analysisData;

  // Chart scroll state
  int _chartStartIndex = 0;
  int _chartEndIndex = 100;
  int get chartStartIndex => _chartStartIndex;
  int get chartEndIndex => _chartEndIndex;

  Future<void> initialize() async {
    await runBusyFuture(loadMarketData());
    // Subscribe to realtime market data changes to auto-refresh
    _marketDataSub = _storageService.marketDataEvents.listen((event) async {
      // Coalesce refreshes by scheduling in microtask queue
      await refresh();
    });
  }

  Future<void> loadMarketData() async {
    _marketDataList = await _storageService.getAllMarketDataInfo();
    notifyListeners();
  }

  Future<void> selectMarketData(MarketDataInfo data) async {
    _selectedMarketData = data;
    await analyzeMarketData();
    notifyListeners();
  }

  Future<void> refresh() async {
    // Reload list and re-run analysis for selected item if still exists
    await loadMarketData();
    if (_selectedMarketData != null) {
      final exists =
          _marketDataList.any((m) => m.id == _selectedMarketData!.id);
      if (exists) {
        await analyzeMarketData();
      } else {
        _selectedMarketData = null;
        _marketData = null;
      }
    }
    notifyListeners();
  }

  Future<void> analyzeMarketData() async {
    if (_selectedMarketData == null) return;

    setBusy(true);

    _marketData = _dataManager.getData(_selectedMarketData!.id);
    await runBusyFuture(loadIndicatorData(_marketData!));
    _analysisData = _performAnalysis(marketData!);

    setBusy(false);
    notifyListeners();
  }

  MarketAnalysisData _performAnalysis(MarketData marketData) {
    return MarketAnalysisData(
      symbol: marketData.symbol,
      timeframe: marketData.timeframe,
      candlesCount: marketData.candlesCount,
      dateRange: marketData.dateRangeLabel,

      // Price statistics
      highestPrice: marketData.highestPrice,
      lowestPrice: marketData.lowestPrice,
      averagePrice: marketData.averageClose,
      currentPrice: marketData.candles.last.close,
      priceRange: marketData.priceRange,

      // Movement
      totalChange: marketData.totalPriceChange,
      totalChangePercent: marketData.totalPriceChangePercent,

      // Trend
      trend: marketData.isUptrend
          ? 'Uptrend'
          : marketData.isDowntrend
              ? 'Downtrend'
              : 'Sideways',
      trendStrength: _calculateTrendStrength(marketData),

      // Volatility
      atr: marketData.averageTrueRange(),
      volatility: _categorizeVolatility(marketData),

      // Volume
      totalVolume: marketData.totalVolume,
      averageVolume: marketData.averageVolume,
      hasVolumeData: marketData.hasVolumeData,

      // Quality
      hasGaps: marketData.hasGaps,
      isValid: marketData.isValid,
    );
  }

  String _calculateTrendStrength(MarketData marketData) {
    if (marketData.candles.length < 20) return 'Unknown';

    final recentCandles = marketData.getRecentCandles(20);
    int bullishCount = 0;
    int bearishCount = 0;

    for (var candle in recentCandles) {
      if (candle.isBullish) bullishCount++;
      if (candle.isBearish) bearishCount++;
    }

    final dominance =
        (bullishCount - bearishCount).abs() / recentCandles.length;

    if (dominance > 0.6) return 'Strong';
    if (dominance > 0.3) return 'Medium';
    return 'Weak';
  }

  String _categorizeVolatility(MarketData marketData) {
    final atr = marketData.averageTrueRange();
    final avgPrice = marketData.averageClose;

    if (avgPrice == 0) return 'Unknown';

    final atrPercent = (atr / avgPrice) * 100;

    if (atrPercent > 2) return 'High';
    if (atrPercent > 1) return 'Medium';
    return 'Low';
  }

  Future<void> loadIndicatorData(MarketData data) async {
    // Calculate indicators
    sma20 = _indicatorService.calculateSMA(data.candles, 20);
    ema50 = _indicatorService.calculateEMA(data.candles, 50);
    bb = _indicatorService.calculateBollingerBands(data.candles, 20, 2.0);
    rsi = _indicatorService.calculateRSI(data.candles, 14);
    macd = _indicatorService.calculateMACD(data.candles);
    notifyListeners();
  }

  void updateChartRange(int startIndex, int endIndex) {
    _chartStartIndex = startIndex;
    _chartEndIndex = endIndex;
    notifyListeners();
  }

  void showIndicatorSettings() {
    _bottomSheetService
        .showCustomSheet(
      variant: BottomSheetType.indicatorSettings,
      title: 'Chart Indicators',
      barrierDismissible: true,
      isScrollControlled: true,
    )
        .then((response) async {
      if (response?.confirmed == true && _marketData != null) {
        // Recalculate indicators based on user prefs
        final data = response!.data as Map<String, dynamic>;

        // Apply visibility and period preferences
        final smaPeriod = data['smaPeriod'] as int? ?? 20;
        final emaPeriod = data['emaPeriod'] as int? ?? 50;
        final bbPeriod = data['bbPeriod'] as int? ?? 20;
        final bbStdDev = data['bbStdDev'] as double? ?? 2.0;
        final rsiPeriod = data['rsiPeriod'] as int? ?? 14;
        final macdFast = data['macdFast'] as int? ?? 12;
        final macdSlow = data['macdSlow'] as int? ?? 26;
        final macdSignal = data['macdSignal'] as int? ?? 9;

        final candles = _marketData!.candles;
        sma20 = data['showSMA'] == true
            ? _indicatorService.calculateSMA(candles, smaPeriod)
            : null;
        ema50 = data['showEMA'] == true
            ? _indicatorService.calculateEMA(candles, emaPeriod)
            : null;
        bb = data['showBB'] == true
            ? _indicatorService.calculateBollingerBands(
                candles, bbPeriod, bbStdDev)
            : null;
        rsi = data['showRSI'] == true
            ? _indicatorService.calculateRSI(candles, rsiPeriod)
            : null;
        macd = data['showMACD'] == true
            ? _indicatorService.calculateMACD(
                candles,
                fastPeriod: macdFast,
                slowPeriod: macdSlow,
                signalPeriod: macdSignal,
              )
            : null;

        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _marketDataSub?.cancel();
    super.dispose();
  }
}
