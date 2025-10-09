import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/helpers/backtest_helper.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _storageService = locator<StorageService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _dataManager = locator<DataManager>();

  bool _isRunningBacktest = false;
  bool get isRunningBacktest => _isRunningBacktest;
  int _strategiesIndex = 0;
  int get strategiesIndex => _strategiesIndex;
  int strategiesCount = 0;
  int dataSetsCount = 0;
  int testsCount = 0;
  List<Strategy> recentStrategies = [];
  BacktestResult? lastResult;
  String? lastResultStrategyName;

  bool get hasResults => testsCount > 0;

  Future<void> initialize() async {
    setBusy(true);

    // Debug: Check cache state on home load
    debugPrint('\n🏠 HomeView initialized');
    _dataManager.debugPrintCache();

    await _loadStats();
    setBusy(false);
  }

  Future<void> _loadStats() async {
    try {
      // Load strategies (now cached!)
      final strategies = await _storageService.getAllStrategies();
      strategiesCount = strategies.length;
      recentStrategies = strategies.take(5).toList();

      // Load market data info (lightweight)
      final marketDataInfo = await _storageService.getAllMarketDataInfo();
      dataSetsCount = marketDataInfo.length;

      // Count total backtest results (optimized)
      int totalTests = 0;
      for (final strategy in strategies) {
        final results =
            await _storageService.getBacktestResultsByStrategy(strategy.id);
        totalTests += results.length;
      }
      testsCount = totalTests;

      // Load latest backtest result (for quick summary in Home)
      lastResult = await _storageService.getLatestBacktestResult();
      if (lastResult != null) {
        // Try resolve strategy name from cache/DB
        final strategy =
            await _storageService.getStrategy(lastResult!.strategyId);
        lastResultStrategyName =
            strategy?.name ?? 'Strategy ${lastResult!.strategyId}';
      } else {
        lastResultStrategyName = null;
      }
      _isRunningBacktest = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  void viewLastResult() {
    if (lastResult == null) return;
    _navigationService.navigateToBacktestResultView(result: lastResult!);
  }

  // Quick access labels for Last Result card
  String? get lastResultSymbol => lastResult == null
      ? null
      : _dataManager.getData(lastResult!.marketDataId)?.symbol;
  String? get lastResultTimeframe => lastResult == null
      ? null
      : _dataManager.getData(lastResult!.marketDataId)?.timeframe;
  String get lastResultStrategyLabel => lastResultStrategyName ?? '';

  void navigateToDataUpload() {
    _navigationService.navigateToDataUploadView().whenComplete(() => refresh());
  }

  void navigateToPatternScanner() {
    _navigationService
        .navigateToPatternScannerView()
        .whenComplete(() => refresh());
  }

  void navigateToStrategyBuilder() {
    _navigationService
        .navigateToStrategyBuilderView()
        .whenComplete(() => refresh());
  }

  void navigateToMarketAnalysis() {
    _navigationService
        .navigateToMarketAnalysisView()
        .whenComplete(() => refresh());
  }

  void navigateToWorkspace() {
    _navigationService.navigateToWorkspaceView().whenComplete(() => refresh());
  }

  Future<void> editStrategy(String strategyId) async {
    _navigationService
        .navigateToStrategyBuilderView(strategyId: strategyId)
        .whenComplete(() => refresh());
  }

  Future<void> runStrategy(String strategyId, int index) async {
    setBusy(true);
    _strategiesIndex = index;
    rebuildUi();
    try {
      debugPrint('\n🎯 Running strategy: $strategyId');

      // Get strategy
      final strategy = await _storageService.getStrategy(strategyId);
      if (strategy == null) {
        debugPrint('❌ Strategy not found');
        _snackbarService.showSnackbar(
          message: 'Strategy not found',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      debugPrint('✅ Strategy loaded: ${strategy.name}');

      // Check available cached data
      debugPrint('\n📊 Checking cached data...');
      final availableData = _dataManager.getAllData();
      debugPrint('Available data in cache: ${availableData.length}');

      for (final data in availableData) {
        debugPrint(
            '  - ${data.id}: ${data.symbol} ${data.timeframe} (${data.candles.length} candles)');
      }

      if (availableData.isEmpty) {
        debugPrint('❌ No data in cache!');

        // Show dialog: No data uploaded
        final response = await _dialogService.showConfirmationDialog(
          title: 'No Data Available',
          description:
              'Please upload market data first before running backtest.\n\nNote: Uploaded data is kept in memory and will be cleared when app restarts.',
          confirmationTitle: 'Upload Data',
          cancelTitle: 'Cancel',
        );

        if (response?.confirmed == true) {
          navigateToDataUpload();
        }
        return;
      }

      debugPrint('✅ Found ${availableData.length} dataset(s) in cache');
      _isRunningBacktest = true;
      rebuildUi();
      await Future.delayed(const Duration(seconds: 1));

      // If only one data, use it directly
      if (availableData.length == 1) {
        debugPrint(
            '\n🚀 Running backtest with: ${availableData.first.symbol} ${availableData.first.timeframe}');

        final helper = BacktestHelper();
        final result = await helper.runBacktestWithCachedData(
          marketDataId: availableData.first.id,
          strategy: strategy,
          saveToDatabase: true,
          navigateToResult: true,
        );

        if (result != null) {
          _isRunningBacktest = false;
          rebuildUi();
        }

        // Refresh stats
        await _loadStats();
        return;
      }

      // Multiple data available - for now use first one
      debugPrint('\n📊 Multiple datasets available, using first one');
      debugPrint(
          '   Selected: ${availableData.first.symbol} ${availableData.first.timeframe}');

      final helper = BacktestHelper();
      final result = await helper.runBacktestWithCachedData(
        marketDataId: availableData.first.id,
        strategy: strategy,
        saveToDatabase: true,
        navigateToResult: true,
      );

      if (result != null) {
        debugPrint('✅ Backtest completed successfully!');
      }

      // Refresh stats
      await _loadStats();
    } catch (e, stackTrace) {
      debugPrint('❌ Error running strategy: $e');
      debugPrint('Stack trace: $stackTrace');
      _snackbarService.showSnackbar(
        message: 'Failed to run backtest: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Refresh data when returning to home
  Future<void> refresh() async {
    await _loadStats();
  }
}
