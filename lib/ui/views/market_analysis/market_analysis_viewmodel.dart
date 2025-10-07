import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:stacked/stacked.dart';

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
  final _dataManager = DataManager();

  List<MarketDataInfo> _marketDataList = [];
  List<MarketDataInfo> get marketDataList => _marketDataList;

  MarketDataInfo? _selectedMarketData;
  MarketDataInfo? get selectedMarketData => _selectedMarketData;

  // Analysis data (would come from actual MarketData with candles)
  MarketAnalysisData? _analysisData;
  MarketAnalysisData? get analysisData => _analysisData;

  Future<void> initialize() async {
    await runBusyFuture(loadMarketData());
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

  Future<void> analyzeMarketData() async {
    if (_selectedMarketData == null) return;

    setBusy(true);

    final marketData = _dataManager.getData(_selectedMarketData!.id);
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
}
