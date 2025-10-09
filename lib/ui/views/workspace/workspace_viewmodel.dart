import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/helpers/strategy_stats_helper.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';

class WorkspaceViewModel extends BaseViewModel {
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _dataManager = locator<DataManager>();
  final _backtestEngineService = locator<BacktestEngineService>();

  List<Strategy> _strategies = [];
  List<Strategy> get strategies => _strategies;

  // Results grouped by strategy
  Map<String, List<BacktestResult>> _strategyResults = {};
  Map<String, bool> _expandedStrategies = {};

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  SortType _sortBy = SortType.dateModified;
  SortType get sortBy => _sortBy;

  // Quick run backtest
  List<MarketData> _availableData = [];
  List<MarketData> get availableData => _availableData;
  String? _selectedDataId;
  String? get selectedDataId => _selectedDataId;

  Map<String, BacktestResult?> _quickResults = {};
  BacktestResult? getQuickResult(String strategyId) =>
      _quickResults[strategyId];

  Map<String, bool> _isRunningQuickTest = {};
  bool isRunningQuickTest(String strategyId) =>
      _isRunningQuickTest[strategyId] ?? false;

  // Comparison mode
  bool _isCompareMode = false;
  bool get isCompareMode => _isCompareMode;

  Set<String> _selectedResultIds = {};
  Set<String> get selectedResultIds => _selectedResultIds;
  int get selectedCount => _selectedResultIds.length;
  bool get canCompare => selectedCount >= 2 && selectedCount <= 4;

  Future<void> initialize() async {
    await runBusyFuture(loadData());
    loadAvailableData();
  }

  Future<void> loadData() async {
    // Load all strategies
    _strategies = await _storageService.getAllStrategies();

    // Load results for each strategy (lightweight - no trades/equity)
    for (var strategy in _strategies) {
      _strategyResults[strategy.id] =
          await _storageService.getBacktestResultsByStrategy(strategy.id);
    }

    _sortStrategies();
    notifyListeners();
  }

  // Future<void> loadAvailableData() async {
  //   _availableData = _dataManager.getAllData();
  //   if (_availableData.isNotEmpty && _selectedDataId == null) {
  //     _selectedDataId = _availableData.first.id;
  //   }
  //   notifyListeners();
  // }

  void loadAvailableData() {
    _availableData = _dataManager.getAllData();
    if (availableData.isNotEmpty && selectedDataId == null) {
      _selectedDataId = availableData.first.id;
    }
  }

  void setSelectedData(String dataId) {
    _selectedDataId = dataId;
    notifyListeners();
  }

  Future<void> refresh() async {
    _storageService.clearCache();
    await loadData();
  }

  void _sortStrategies() {
    switch (_sortBy) {
      case SortType.name:
        _strategies.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;

      case SortType.dateCreated:
        _strategies.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SortType.dateModified:
        _strategies.sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt;
          final bDate = b.updatedAt ?? b.createdAt;
          return bDate.compareTo(aDate);
        });
        break;

      case SortType.performance:
        _strategies.sort((a, b) {
          final aResults = _strategyResults[a.id] ?? [];
          final bResults = _strategyResults[b.id] ?? [];

          if (aResults.isEmpty && bResults.isEmpty) return 0;
          if (aResults.isEmpty) return 1;
          if (bResults.isEmpty) return -1;

          final aAvgPnl =
              aResults.map((r) => r.summary.totalPnl).reduce((a, b) => a + b) /
                  aResults.length;
          final bAvgPnl =
              bResults.map((r) => r.summary.totalPnl).reduce((a, b) => a + b) /
                  bResults.length;

          return bAvgPnl.compareTo(aAvgPnl);
        });
        break;

      case SortType.testsRun:
        _strategies.sort((a, b) {
          final aCount = _strategyResults[a.id]?.length ?? 0;
          final bCount = _strategyResults[b.id]?.length ?? 0;
          return bCount.compareTo(aCount);
        });
        break;
    }
  }

  void setSortBy(SortType sortBy) {
    _sortBy = sortBy;
    _sortStrategies();
    notifyListeners();
  }

  // Search
  void searchStrategies(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  List<Strategy> get filteredStrategies {
    if (_searchQuery.isEmpty) return _strategies;

    return _strategies.where((s) {
      return s.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // Expansion state
  bool isExpanded(String strategyId) =>
      _expandedStrategies[strategyId] ?? false;

  void toggleExpand(String strategyId) {
    _expandedStrategies[strategyId] = !isExpanded(strategyId);
    notifyListeners();
  }

  // Get strategy data
  List<BacktestResult> getResults(String strategyId) =>
      _strategyResults[strategyId] ?? [];

  bool hasResults(String strategyId) {
    final results = getResults(strategyId);
    return results.isNotEmpty;
  }

  int getResultsCount(String strategyId) {
    return getResults(strategyId).length;
  }

  // Calculate stats on-the-fly (since we don't store StrategyStats)
  StrategyStatsData getStrategyStats(String strategyId) {
    final results = getResults(strategyId);

    if (results.isEmpty) {
      return StrategyStatsData.empty(strategyId);
    }

    final totalPnl =
        results.map((r) => r.summary.totalPnl).reduce((a, b) => a + b);

    final totalPnlPercent = results
        .map((r) => r.summary.totalPnlPercentage)
        .reduce((a, b) => a + b);

    final totalWinRate =
        results.map((r) => r.summary.winRate).reduce((a, b) => a + b);

    final bestResult = results
        .reduce((a, b) => a.summary.totalPnl > b.summary.totalPnl ? a : b);

    final worstResult = results
        .reduce((a, b) => a.summary.totalPnl < b.summary.totalPnl ? a : b);

    return StrategyStatsData(
      strategyId: strategyId,
      totalBacktests: results.length,
      avgPnl: totalPnl / results.length,
      avgPnlPercent: totalPnlPercent / results.length,
      avgWinRate: totalWinRate / results.length,
      bestPnl: bestResult.summary.totalPnl,
      worstPnl: worstResult.summary.totalPnl,
      lastRunDate: results.first.executedAt,
    );
  }

  // Navigation
  void navigateToCreateStrategy() {
    _navigationService.navigateTo(Routes.strategyBuilderView);
  }

  void navigateToEditStrategy(Strategy strategy) {
    _navigationService.navigateTo(
      Routes.strategyBuilderView,
      arguments: StrategyBuilderViewArguments(strategyId: strategy.id),
    );
  }

  Future<void> runBacktest(Strategy strategy) async {
    // Check if market data exists
    final marketDataList = await _storageService.getAllMarketDataInfo();

    if (marketDataList.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please upload market data first',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // _navigationService.navigateTo(
    //   Routes.backtestRunView,
    //   arguments: BacktestRunViewArguments(strategy: strategy),
    // );
  }

  Future<void> quickRunBacktest(Strategy strategy) async {
    if (_selectedDataId == null || _availableData.isEmpty) {
      _snackbarService.showSnackbar(
        message: 'Please select market data first',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _isRunningQuickTest[strategy.id] = true;
    notifyListeners();

    try {
      // Load candles
      final marketData = _dataManager.getData(_selectedDataId!);

      if (marketData == null) {
        _snackbarService.showSnackbar(
          message: 'Selected market data is empty',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Run backtest
      final result = await _backtestEngineService.runBacktest(
        strategy: strategy,
        marketData: marketData,
      );
      // Store result in memory
      _quickResults[strategy.id] = result;

      // Persist to database so it appears under results list
      try {
        // Ensure strategy exists in storage
        final existing = await _storageService.getStrategy(strategy.id);
        if (existing == null) {
          await _storageService.saveStrategy(strategy);
        }

        // Save summary result to DB
        await _storageService.saveBacktestResult(result);

        // Refresh results for this strategy from DB
        _strategyResults[strategy.id] =
            await _storageService.getBacktestResultsByStrategy(strategy.id);

        _snackbarService.showSnackbar(
          message: 'Quick test saved to database',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('Error saving quick test: $e');
        _snackbarService.showSnackbar(
          message: 'Failed to save quick test: ${e.toString()}',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Error running backtest: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isRunningQuickTest[strategy.id] = false;
      notifyListeners();
    }
  }

  void viewQuickResult(String strategyId) {
    final result = _quickResults[strategyId];
    if (result != null) {
      _navigationService.navigateTo(
        Routes.backtestResultView,
        arguments: BacktestResultViewArguments(result: result),
      );
    }
  }

  void viewResult(BacktestResult result) {
    _navigationService.navigateTo(
      Routes.backtestResultView,
      arguments: BacktestResultViewArguments(result: result),
    );
  }

  // Strategy actions
  Future<void> duplicateStrategy(Strategy strategy) async {
    final duplicate = strategy.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${strategy.name} (Copy)',
      createdAt: DateTime.now(),
      updatedAt: null,
    );

    await runBusyFuture(
      _storageService.saveStrategy(duplicate),
      busyObject: 'duplicate',
    );

    await loadData();

    _snackbarService.showSnackbar(
      message: 'Strategy duplicated',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteStrategy(Strategy strategy) async {
    final resultsCount = getResultsCount(strategy.id);

    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Strategy',
      description: resultsCount > 0
          ? 'Delete "${strategy.name}"?\n\nThis will also delete $resultsCount backtest result(s).'
          : 'Delete "${strategy.name}"?',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed != true) return;

    await runBusyFuture(
      _storageService.deleteStrategy(strategy.id),
      busyObject: 'delete_${strategy.id}',
    );

    await loadData();

    _snackbarService.showSnackbar(
      message: 'Strategy deleted',
      duration: const Duration(seconds: 2),
    );
  }

  // Result actions
  Future<void> deleteResult(BacktestResult result) async {
    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Result',
      description: 'Delete this backtest result?',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed != true) return;

    await runBusyFuture(
      _storageService.deleteBacktestResult(result.id),
      busyObject: 'delete_result',
    );

    await loadData();

    _snackbarService.showSnackbar(
      message: 'Result deleted',
      duration: const Duration(seconds: 2),
    );
  }

  // Comparison mode
  void toggleCompareMode() {
    _isCompareMode = !_isCompareMode;
    if (!_isCompareMode) {
      _selectedResultIds.clear();
    }
    notifyListeners();
  }

  void toggleResultSelection(String resultId) {
    if (_selectedResultIds.contains(resultId)) {
      _selectedResultIds.remove(resultId);
    } else {
      if (_selectedResultIds.length >= 4) {
        _snackbarService.showSnackbar(
          message: 'Maximum 4 results can be compared',
          duration: const Duration(seconds: 2),
        );
        return;
      }
      _selectedResultIds.add(resultId);
    }
    notifyListeners();
  }

  bool isResultSelected(String resultId) =>
      _selectedResultIds.contains(resultId);

  void clearSelection() {
    _selectedResultIds.clear();
    notifyListeners();
  }

  Future<void> compareSelected() async {
    if (!canCompare) {
      _snackbarService.showSnackbar(
        message: 'Select 2-4 results to compare',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Collect selected results from all strategies
    final selectedResults = <BacktestResult>[];
    for (var results in _strategyResults.values) {
      for (var result in results) {
        if (_selectedResultIds.contains(result.id)) {
          selectedResults.add(result);
        }
      }
    }

    if (selectedResults.length < 2) {
      _snackbarService.showSnackbar(
        message: 'Error loading selected results',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _navigationService.navigateTo(
      Routes.comparisonView,
      arguments: ComparisonViewArguments(results: selectedResults),
    );
  }
}

// Sort types
enum SortType {
  name,
  dateCreated,
  dateModified,
  performance,
  testsRun,
}

extension SortTypeX on SortType {
  String get label {
    switch (this) {
      case SortType.name:
        return 'Name';
      case SortType.dateCreated:
        return 'Date Created';
      case SortType.dateModified:
        return 'Last Modified';
      case SortType.performance:
        return 'Performance';
      case SortType.testsRun:
        return 'Tests Run';
    }
  }

  IconData get icon {
    switch (this) {
      case SortType.name:
        return Icons.sort_by_alpha;
      case SortType.dateCreated:
      case SortType.dateModified:
        return Icons.access_time;
      case SortType.performance:
        return Icons.trending_up;
      case SortType.testsRun:
        return Icons.numbers;
    }
  }
}
