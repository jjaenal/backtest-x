import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/helpers/strategy_stats_helper.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/helpers/isolate_backtest.dart';
import 'package:backtestx/services/clipboard_service.dart';
import 'package:backtestx/services/data_validation_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'dart:async';
import 'package:backtestx/ui/common/base_refreshable_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;
import 'dart:io';
import 'package:backtestx/ui/common/ui_helpers.dart';
import 'package:backtestx/services/share_service.dart';
import 'package:backtestx/services/deep_link_service.dart';

class WorkspaceViewModel extends BaseRefreshableViewModel {
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _dataManager = locator<DataManager>();

  final _dataValidationService = locator<DataValidationService>();

  List<Strategy> _strategies = [];
  List<Strategy> get strategies => _strategies;

  // Results grouped by strategy
  final Map<String, List<BacktestResult>> _strategyResults = {};
  final Map<String, bool> _expandedStrategies = {};

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  SortType _sortBy = SortType.dateModified;
  SortType get sortBy => _sortBy;

  // Quick run backtest
  List<MarketData> _availableData = [];
  List<MarketData> get availableData => _availableData;
  String? _selectedDataId;
  String? get selectedDataId => _selectedDataId;

  final Map<String, BacktestResult?> _quickResults = {};
  // Progress percentage per strategy for quick/backtest runs
  final Map<String, double> _quickProgress = {};
  double? getQuickProgress(String strategyId) => _quickProgress[strategyId];

  // Result filters
  bool _filterProfitOnly = false;
  bool get filterProfitOnly => _filterProfitOnly;
  bool _filterPfPositive = false; // PF > 1
  bool get filterPfPositive => _filterPfPositive;
  bool _filterWinRateAbove50 = false; // Win Rate > 50%
  bool get filterWinRateAbove50 => _filterWinRateAbove50;

  // Symbol/Timeframe filters
  String? _selectedSymbolFilter;
  String? get selectedSymbolFilter => _selectedSymbolFilter;
  // Multi-select timeframe filters
  final Set<String> _selectedTimeframeFilters = {};
  Set<String> get selectedTimeframeFilters => _selectedTimeframeFilters;

  // Date range filters
  DateTime? _startDateFilter;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? _endDateFilter;
  DateTime? get endDateFilter => _endDateFilter;

  // Result list sorting per strategy
  final Map<String, ResultSortKey> _resultSortKeyByStrategy = {};
  ResultSortKey getResultSortKey(String strategyId) =>
      _resultSortKeyByStrategy[strategyId] ?? ResultSortKey.executedAtDesc;
  void setResultSortKey(String strategyId, ResultSortKey key) {
    _resultSortKeyByStrategy[strategyId] = key;
    // Reset pagination for this strategy when sort changes
    _resultsItemsToShow[strategyId] = resultsPageSize;
    notifyListeners();
  }

  void toggleFilterProfitOnly() {
    _filterProfitOnly = !_filterProfitOnly;
    notifyListeners();
  }

  /// Copy a strategy deep link to clipboard
  Future<void> copyStrategyLinkToClipboard(Strategy strategy) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final deepLinks = locator<DeepLinkService>();
      final url = deepLinks.buildStrategyLink(strategyId: strategy.id);
      if (locator.isRegistered<ClipboardService>()) {
        await locator<ClipboardService>().copyText(url);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
      }
      _snackbarService.showSnackbar(
        message:
            t?.copyStrategyLinkCopied ?? 'Strategy link copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.copyFailed(e.toString()) ?? 'Failed to copy link: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Copy a backtest result deep link to clipboard
  Future<void> copyResultLinkToClipboard(BacktestResult result) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final deepLinks = locator<DeepLinkService>();
      final url = deepLinks.buildBacktestResultLink(resultId: result.id);
      if (locator.isRegistered<ClipboardService>()) {
        await locator<ClipboardService>().copyText(url);
      } else {
        await Clipboard.setData(ClipboardData(text: url));
      }
      _snackbarService.showSnackbar(
        message: t?.copyResultLinkCopied ??
            'Backtest result link copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.copyFailed(e.toString()) ?? 'Failed to copy link: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void toggleFilterPfPositive() {
    _filterPfPositive = !_filterPfPositive;
    notifyListeners();
  }

  void toggleFilterWinRate50() {
    _filterWinRateAbove50 = !_filterWinRateAbove50;
    notifyListeners();
  }

  void clearFilters() {
    _filterProfitOnly = false;
    _filterPfPositive = false;
    _filterWinRateAbove50 = false;
    _selectedSymbolFilter = null;
    _selectedTimeframeFilters.clear();
    _startDateFilter = null;
    _endDateFilter = null;
    // Reset pagination for all strategies when filters cleared
    _resetAllResultsPagination();
    notifyListeners();
  }

  BacktestResult? getQuickResult(String strategyId) =>
      _quickResults[strategyId];

  final Map<String, bool> _isRunningQuickTest = {};
  bool isRunningQuickTest(String strategyId) =>
      _isRunningQuickTest[strategyId] ?? false;

  // Batch quick test state per strategy
  final Map<String, bool> _isRunningBatchQuickTest = {};
  bool isRunningBatchQuickTest(String strategyId) =>
      _isRunningBatchQuickTest[strategyId] ?? false;

  // Comparison mode
  bool _isCompareMode = false;
  bool get isCompareMode => _isCompareMode;

  final Set<String> _selectedResultIds = {};
  Set<String> get selectedResultIds => _selectedResultIds;
  int get selectedCount => _selectedResultIds.length;
  bool get canCompare => selectedCount >= 2 && selectedCount <= 4;

  Future<void> initialize() async {
    await runBusyFuture(loadData());
    loadAvailableData();
    // Realtime subscriptions
    _strategySub = _storageService.strategyEvents.listen((event) async {
      // Ignore non-data-changing signals to prevent refresh loops
      if (event.type == StrategyEventType.saved ||
          event.type == StrategyEventType.deleted ||
          event.type == StrategyEventType.cleared) {
        await refresh();
      }
    });
    _backtestSub = _storageService.backtestEvents.listen((event) async {
      if (event.type == BacktestResultEventType.saved ||
          event.type == BacktestResultEventType.deleted ||
          event.type == BacktestResultEventType.cleared) {
        await refresh();
      }
    });
    _marketDataSub = _storageService.marketDataEvents.listen((event) async {
      // Update available data list for quick actions
      loadAvailableData();
      notifyListeners();
    });
    // Progress subscription for long-running backtests
    _progressSub = _storageService.backtestProgress.listen((event) {
      // Track percentage per-strategy and refresh UI
      _quickProgress[event.strategyId] = event.progress;
      notifyListeners();
    });
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

  bool _isRefreshing = false;
  @override
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      _storageService.clearCache();
      await loadData();
    } finally {
      _isRefreshing = false;
    }
  }

  // Subscriptions
  StreamSubscription? _strategySub;
  StreamSubscription? _backtestSub;
  StreamSubscription? _marketDataSub;
  StreamSubscription? _progressSub;

  @override
  void dispose() {
    _strategySub?.cancel();
    _backtestSub?.cancel();
    _marketDataSub?.cancel();
    _progressSub?.cancel();
    super.dispose();
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
    if (_expandedStrategies[strategyId] == true) {
      // Initialize pagination for this strategy on expand
      _resultsItemsToShow[strategyId] = resultsPageSize;

      // Ensure active filters remain valid for the expanded strategy
      // 1) Symbol filter: reset to null if not available in this strategy
      final symbols = getAvailableSymbols(strategyId);
      if (_selectedSymbolFilter != null &&
          !symbols.contains(_selectedSymbolFilter)) {
        _selectedSymbolFilter = null;
      }

      // 2) Timeframe filters: remove any TF not present for this strategy
      final availableTfs = getAvailableTimeframes(strategyId).toSet();
      _selectedTimeframeFilters.removeWhere((tf) => !availableTfs.contains(tf));
    }
    notifyListeners();
  }

  // Get strategy data
  List<BacktestResult> getResults(String strategyId) =>
      _strategyResults[strategyId] ?? [];

  // Get filtered results for a strategy based on current filters
  List<BacktestResult> getFilteredResults(String strategyId) {
    final base = getResults(strategyId);
    final filtered = base.where((r) {
      final s = r.summary;
      final md = _dataManager.getData(r.marketDataId);
      if (_filterProfitOnly && s.totalPnl <= 0) return false;
      if (_filterPfPositive && s.profitFactor <= 1) return false;
      if (_filterWinRateAbove50 && s.winRate <= 50) return false;
      if (_selectedSymbolFilter != null &&
          (md?.symbol ?? 'Unknown') != _selectedSymbolFilter) {
        return false;
      }
      if (_selectedTimeframeFilters.isNotEmpty) {
        final tf = md?.timeframe ?? 'Unknown';
        if (!_selectedTimeframeFilters.contains(tf)) return false;
      }
      if (_startDateFilter != null &&
          r.executedAt.isBefore(_startDateFilter!)) {
        return false;
      }
      if (_endDateFilter != null && r.executedAt.isAfter(_endDateFilter!)) {
        return false;
      }
      return true;
    }).toList();

    // Sort according to per-strategy result sort key
    final sortKey = getResultSortKey(strategyId);
    filtered.sort((a, b) {
      switch (sortKey) {
        case ResultSortKey.executedAtDesc:
          return b.executedAt.compareTo(a.executedAt);
        case ResultSortKey.pnlDesc:
          return b.summary.totalPnl.compareTo(a.summary.totalPnl);
        case ResultSortKey.winRateDesc:
          return b.summary.winRate.compareTo(a.summary.winRate);
        case ResultSortKey.profitFactorDesc:
          return b.summary.profitFactor.compareTo(a.summary.profitFactor);
      }
    });

    return filtered;
  }

  // --- Lazy loading / pagination for results list ---
  static const int resultsPageSize = 20;
  final Map<String, int> _resultsItemsToShow = {};

  /// Get paged/limited results to render lazily
  List<BacktestResult> getPagedFilteredResults(String strategyId) {
    final filtered = getFilteredResults(strategyId);
    final toShow = _resultsItemsToShow[strategyId] ?? resultsPageSize;
    if (filtered.length <= toShow) return filtered;
    return filtered.take(toShow).toList();
  }

  /// Return count of items currently shown for a strategy
  int getResultsShownCount(String strategyId) {
    final filtered = getFilteredResults(strategyId);
    final toShow = _resultsItemsToShow[strategyId] ?? resultsPageSize;
    return filtered.length < toShow ? filtered.length : toShow;
  }

  /// Whether there are more items available to load
  bool isMoreResultsAvailable(String strategyId) {
    final filteredCount = getFilteredResults(strategyId).length;
    final shown = _resultsItemsToShow[strategyId] ?? resultsPageSize;
    return shown < filteredCount;
  }

  /// Load next page of results
  void loadMoreResults(String strategyId) {
    final current = _resultsItemsToShow[strategyId] ?? resultsPageSize;
    _resultsItemsToShow[strategyId] = current + resultsPageSize;
    notifyListeners();
  }

  /// Reset pagination for a specific strategy
  void resetResultsPagination(String strategyId) {
    _resultsItemsToShow[strategyId] = resultsPageSize;
    notifyListeners();
  }

  void _resetAllResultsPagination() {
    for (final id in _strategyResults.keys) {
      _resultsItemsToShow[id] = resultsPageSize;
    }
  }

  // Available filter options derived from results
  List<String> getAvailableSymbols(String strategyId) {
    final set = <String>{};
    for (final r in getResults(strategyId)) {
      final md = _dataManager.getData(r.marketDataId);
      final sym = md?.symbol;
      if (sym != null && sym.isNotEmpty) set.add(sym);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> getAvailableTimeframes(String strategyId) {
    final set = <String>{};
    for (final r in getResults(strategyId)) {
      final md = _dataManager.getData(r.marketDataId);
      final tf = md?.timeframe;
      if (tf != null && tf.isNotEmpty) set.add(tf);
    }
    final list = set.toList()..sort();
    return list;
  }

  // Calculate counts per timeframe applying all filters except timeframe filter
  Map<String, int> getTimeframeCounts(String strategyId) {
    final Map<String, int> counts = {};
    for (final r in getResults(strategyId)) {
      final md = _dataManager.getData(r.marketDataId);
      if (!_passesNonTimeframeFilters(r, md)) continue;
      final tf = md?.timeframe ?? 'Unknown';
      counts[tf] = (counts[tf] ?? 0) + 1;
    }
    return counts;
  }

  bool _passesNonTimeframeFilters(BacktestResult r, MarketData? md) {
    final s = r.summary;
    if (_filterProfitOnly && s.totalPnl <= 0) return false;
    if (_filterPfPositive && s.profitFactor <= 1) return false;
    if (_filterWinRateAbove50 && s.winRate <= 50) return false;
    if (_selectedSymbolFilter != null &&
        (md?.symbol ?? 'Unknown') != _selectedSymbolFilter) {
      return false;
    }
    if (_startDateFilter != null && r.executedAt.isBefore(_startDateFilter!)) {
      return false;
    }
    if (_endDateFilter != null && r.executedAt.isAfter(_endDateFilter!)) {
      return false;
    }
    return true;
  }

  void setSelectedSymbolFilter(String? symbol) {
    _selectedSymbolFilter = symbol;
    notifyListeners();
  }

  // For backward compatibility with previous single-select dropdown.
  // Passing null clears all selected TFs; passing a value sets it as the only selected TF.
  void setSelectedTimeframeFilter(String? timeframe) {
    _selectedTimeframeFilters.clear();
    if (timeframe != null) {
      _selectedTimeframeFilters.add(timeframe);
    }
    notifyListeners();
  }

  // Toggle multi-select timeframe chip
  void toggleTimeframeFilter(String timeframe) {
    if (_selectedTimeframeFilters.contains(timeframe)) {
      _selectedTimeframeFilters.remove(timeframe);
    } else {
      _selectedTimeframeFilters.add(timeframe);
    }
    notifyListeners();
  }

  void setStartDateFilter(DateTime? date) {
    _startDateFilter = date;
    // Normalize order when both dates set
    if (_startDateFilter != null && _endDateFilter != null) {
      if (_startDateFilter!.isAfter(_endDateFilter!)) {
        final tmp = _startDateFilter;
        _startDateFilter = _endDateFilter;
        _endDateFilter = tmp;
      }
    }
    notifyListeners();
  }

  void setEndDateFilter(DateTime? date) {
    _endDateFilter = date;
    if (_startDateFilter != null && _endDateFilter != null) {
      if (_startDateFilter!.isAfter(_endDateFilter!)) {
        final tmp = _startDateFilter;
        _startDateFilter = _endDateFilter;
        _endDateFilter = tmp;
      }
    }
    notifyListeners();
  }

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

  Future<void> quickRunBacktest(Strategy strategy) async {
    // Jika tidak ada data tersedia sama sekali, arahkan untuk upload
    if (_availableData.isEmpty) {
      final response = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.notice,
        title: 'Market Data Diperlukan',
        description:
            'Unggah data pasar terlebih dahulu sebelum menjalankan Quick Test.',
        mainButtonTitle: 'Upload Data',
        secondaryButtonTitle: 'Batal',
        barrierDismissible: true,
        isScrollControlled: true,
      );
      if (response?.confirmed == true) {
        _navigationService.navigateToDataUploadView();
      }
      return;
    }

    // Jika data tersedia namun belum dipilih, tampilkan picker
    if (_selectedDataId == null) {
      final options = _availableData
          .map((d) => {
                'label': d.symbol,
                'value': d.id,
              })
          .toList();
      final response = await _bottomSheetService.showCustomSheet(
        variant: BottomSheetType.notice,
        title: 'Pilih Data Pasar',
        description: 'Pilih data yang akan digunakan untuk Quick Test.',
        mainButtonTitle: 'Gunakan Data Ini',
        secondaryButtonTitle: 'Upload Baru',
        barrierDismissible: true,
        isScrollControlled: true,
        data: {
          'options': options,
        },
      );
      if (response?.confirmed == true) {
        final selected = response?.data as String?;
        if (selected != null && selected.isNotEmpty) {
          setSelectedData(selected);
        } else {
          return;
        }
      } else {
        return;
      }
    }

    _isRunningQuickTest[strategy.id] = true;
    _quickProgress[strategy.id] = 0.0;
    notifyListeners();

    try {
      // Load candles
      final marketData = _dataManager.getData(_selectedDataId!);

      if (marketData == null) {
        final ctx = StackedService.navigatorKey?.currentContext;
        final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
        await _bottomSheetService.showCustomSheet(
          variant: BottomSheetType.notice,
          title: t?.mdEmptyTitle ?? 'Data Tidak Ditemukan',
          description: t?.mdEmptyDesc ??
              'Data pasar yang dipilih kosong atau tidak tersedia. Coba pilih data lain atau upload baru.',
          mainButtonTitle: t?.mdGoToUpload ?? 'Ke Upload Data',
          secondaryButtonTitle: t?.commonClose ?? 'Tutup',
          barrierDismissible: true,
          isScrollControlled: true,
        );
        return;
      }

      // Quick validation before running
      final isValid = _dataValidationService.quickValidate(marketData);
      if (!isValid) {
        final ctx = StackedService.navigatorKey?.currentContext;
        final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
        final report = _dataValidationService.validateMarketData(marketData);
        await _bottomSheetService.showCustomSheet(
          variant: BottomSheetType.validationReport,
          title: t?.dataValidationReportTitle ?? 'Data Validation Report',
          description: report.summary,
          data: {
            'errors': report.errors.map((i) => i.message).toList(),
            'warningsIssues':
                report.warningsIssues.map((i) => i.message).toList(),
            'warningsText': report.warnings,
          },
        );
        return;
      }

      // Run backtest in isolate to avoid UI blocking
      final result = await IsolateBacktest.run(
        strategy: strategy,
        marketData: marketData,
      );
      // Store result in memory
      _quickResults[strategy.id] = result;

      // Show quick summary snackbar for immediate feedback
      try {
        final ctx = StackedService.navigatorKey?.currentContext;
        final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
        final s = result.summary;
        final pf = s.profitFactor.toStringAsFixed(2);
        final wr = s.winRate.toStringAsFixed(2);
        final msg = t?.qtSnackbarSummary(pf, wr) ??
            'Quick test completed — PF $pf, WinRate $wr%';
        _snackbarService.showSnackbar(
          message: msg,
          duration: const Duration(seconds: 3),
        );
      } catch (_) {
        // Non-critical UI feedback; ignore errors
      }

      // Prompt to view full results
      try {
        final s = result.summary;
        if (s.totalTrades == 0) {
          final ctx = StackedService.navigatorKey?.currentContext;
          final t =
              ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
          await _bottomSheetService.showCustomSheet(
            variant: BottomSheetType.notice,
            title: t?.qtZeroTradeTitle ?? 'Quick Test: 0 Trade',
            description: t?.qtZeroTradeDesc ??
                'No trades generated for this strategy and data. Result will not be saved and detail view is unavailable.',
            mainButtonTitle: t?.commonClose ?? 'Close',
            barrierDismissible: true,
            isScrollControlled: true,
          );
        } else {
          final ctx = StackedService.navigatorKey?.currentContext;
          final t =
              ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
          final pf = s.profitFactor.toStringAsFixed(2);
          final wr = s.winRate.toStringAsFixed(2);
          final response = await _bottomSheetService.showCustomSheet(
            variant: BottomSheetType.notice,
            title: t?.qtDoneTitle ?? 'Quick Test Completed',
            description: t?.qtDoneDesc(pf, wr) ??
                'Profit Factor $pf, Win Rate $wr%. View full results?',
            mainButtonTitle: t?.sbViewFullResults ?? 'View Full Results',
            secondaryButtonTitle: t?.commonClose ?? 'Close',
            barrierDismissible: true,
            isScrollControlled: true,
          );
          if (response?.confirmed == true) {
            viewResult(result);
          }
        }
      } catch (_) {
        // Optional UX; ignore errors
      }

      // Persist to database asynchronously to avoid UI jank
      Future<void>(() async {
        try {
          // Ensure strategy exists in storage
          final existing = await _storageService.getStrategy(strategy.id);
          if (existing == null) {
            await _storageService.saveStrategy(strategy);
          }

          // Skip saving if no trades to avoid downstream chart errors
          if (result.summary.totalTrades == 0) {
            final ctx = StackedService.navigatorKey?.currentContext;
            final t =
                ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
            _snackbarService.showSnackbar(
              message: t?.qtNotSavedZeroTrade ??
                  'Quick test result not saved (0 trade)',
              duration: const Duration(seconds: 2),
            );
            return;
          }
          // Save summary result to DB
          await _storageService.saveBacktestResult(result);

          // Refresh results for this strategy from DB
          _strategyResults[strategy.id] =
              await _storageService.getBacktestResultsByStrategy(strategy.id);

          _snackbarService.showSnackbar(
            message: (AppLocalizations.of(
                        StackedService.navigatorKey!.currentContext!)
                    ?.qtSavedToDb ??
                'Quick test saved to database'),
            duration: const Duration(seconds: 2),
          );
          notifyListeners();
        } catch (e) {
          debugPrint('Error saving quick test: $e');
          showErrorWithRetry(
            title: (AppLocalizations.of(
                        StackedService.navigatorKey!.currentContext!)
                    ?.qtSaveFailedTitle ??
                'Quick test save failed'),
            message: e.toString(),
            onRetry: () async {
              try {
                final existing = await _storageService.getStrategy(strategy.id);
                if (existing == null) {
                  await _storageService.saveStrategy(strategy);
                }
                if (result.summary.totalTrades == 0) {
                  _snackbarService.showSnackbar(
                    message: (AppLocalizations.of(
                                StackedService.navigatorKey!.currentContext!)
                            ?.qtNotSavedZeroTrade ??
                        'Quick test result not saved (0 trade)'),
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }
                await _storageService.saveBacktestResult(result);
                _strategyResults[strategy.id] = await _storageService
                    .getBacktestResultsByStrategy(strategy.id);
                _snackbarService.showSnackbar(
                  message: (AppLocalizations.of(
                              StackedService.navigatorKey!.currentContext!)
                          ?.qtSavedToDb ??
                      'Quick test saved to database'),
                  duration: const Duration(seconds: 2),
                );
                notifyListeners();
              } catch (_) {}
            },
          );
        }
      });
    } catch (e) {
      debugPrint('Error running quick test: $e');
      showErrorWithRetry(
        title:
            (AppLocalizations.of(StackedService.navigatorKey!.currentContext!)
                    ?.qtRunFailedTitle ??
                'Quick test failed'),
        message: e.toString(),
        onRetry: () => quickRunBacktest(strategy),
      );
    } finally {
      _isRunningQuickTest[strategy.id] = false;
      _quickProgress.remove(strategy.id);
      notifyListeners();
    }
  }

  Future<void> quickRunBacktestBatch(Strategy strategy, {int? maxCount}) async {
    // Ensure we have data
    if (_availableData.isEmpty) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.pleaseUploadMarketData ?? 'Please upload market data first',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Prevent parallel runs per strategy
    if (isRunningBatchQuickTest(strategy.id)) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message:
            t?.batchAlreadyRunning ?? 'Batch already running for this strategy',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    _isRunningBatchQuickTest[strategy.id] = true;
    notifyListeners();

    try {
      final list = List<MarketData>.from(_availableData);
      final total =
          maxCount == null ? list.length : (maxCount.clamp(1, list.length));
      int completed = 0;
      int skipped = 0;

      for (int i = 0; i < total; i++) {
        final marketData = list[i];
        try {
          // Validate each dataset quickly; skip invalid
          if (!_dataValidationService.quickValidate(marketData)) {
            skipped++;
            continue;
          }

          final result = await IsolateBacktest.run(
            strategy: strategy,
            marketData: marketData,
          );

          // Save to DB
          try {
            final existing = await _storageService.getStrategy(strategy.id);
            if (existing == null) {
              await _storageService.saveStrategy(strategy);
            }
            await _storageService.saveBacktestResult(result);
            completed++;

            // Update in-memory results incrementally
            _strategyResults[strategy.id] =
                await _storageService.getBacktestResultsByStrategy(strategy.id);
            notifyListeners();
          } catch (e) {
            debugPrint('Error saving batch result: $e');
          }
        } catch (e) {
          debugPrint('Batch run error: $e');
        }
      }

      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final msg = skipped > 0
          ? (t?.batchCompleteSavedSkipped(
                  completed.toString(), total.toString(), skipped.toString()) ??
              'Batch complete: $completed/$total saved (skipped $skipped invalid)')
          : (t?.batchCompleteSaved(completed.toString(), total.toString()) ??
              'Batch complete: $completed/$total saved');
      _snackbarService.showSnackbar(
        message: msg,
        duration: const Duration(seconds: 3),
      );
    } finally {
      _isRunningBatchQuickTest[strategy.id] = false;
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

  /// Export filtered backtest results (summary rows) for a strategy to CSV
  Future<void> exportFilteredStrategyResultsCsv(Strategy strategy) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final results = getFilteredResults(strategy.id);
      if (results.isEmpty) {
        _snackbarService.showSnackbar(
          message:
              t?.noResultsToExport ?? 'No results to export for this strategy',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final List<List<dynamic>> rows = [];
      rows.add([
        'Strategy',
        'Symbol',
        'Timeframe',
        'Executed At',
        'Total Trades',
        'Win Rate %',
        'Profit Factor',
        'Total PnL',
        'Total PnL %',
        'Max Drawdown',
        'Max DD %',
        'Sharpe',
      ]);

      for (final result in results) {
        final marketData = _dataManager.getData(result.marketDataId);
        final summary = result.summary;
        rows.add([
          strategy.name,
          marketData?.symbol ?? '-',
          marketData?.timeframe ?? '-',
          result.executedAt.toIso8601String(),
          summary.totalTrades,
          summary.winRate.toStringAsFixed(2),
          summary.profitFactor.toStringAsFixed(2),
          summary.totalPnl.toStringAsFixed(2),
          summary.totalPnlPercentage.toStringAsFixed(2),
          summary.maxDrawdown.toStringAsFixed(2),
          summary.maxDrawdownPercentage.toStringAsFixed(2),
          summary.sharpeRatio.toStringAsFixed(2),
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final fileName = '${strategy.name}_results_summary.csv';

      if (kIsWeb) {
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);
        final share = locator<ShareService>();
        final deepLinks = locator<DeepLinkService>();
        final link = deepLinks.buildStrategyLink(strategyId: strategy.id);
        final text = 'BacktestX Results Summary — ${strategy.name}\n'
            'Open in Strategy Builder: $link';
        await share.shareFilePath(
          path,
          text: text,
          mimeType: 'text/csv',
          filename: fileName,
        );
      }

      _snackbarService.showSnackbar(
        message:
            t?.strategyResultsExported ?? 'Strategy results exported to CSV',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.exportFailed(e.toString()) ?? 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Export per-timeframe stats for filtered results of a strategy to CSV
  Future<void> exportFilteredStrategyTfStatsCsv(Strategy strategy) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final results = getFilteredResults(strategy.id);
      if (results.isEmpty) {
        _snackbarService.showSnackbar(
          message:
              t?.noResultsToExport ?? 'No results to export for this strategy',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final List<List<dynamic>> rows = [];
      rows.add([
        'Strategy',
        'Symbol',
        'Base Timeframe',
        'Executed At',
        'TF',
        'Signals',
        'Trades',
        'Wins',
        'Win Rate %',
      ]);

      for (final result in results) {
        final marketData = _dataManager.getData(result.marketDataId);
        final summary = result.summary;
        final tfStats = summary.tfStats ?? {};
        if (tfStats.isEmpty) continue;

        final entries = tfStats.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        for (final e in entries) {
          final tf = e.key;
          final m = e.value;
          final signals = (m['signals'] ?? 0).toInt();
          final trades = (m['trades'] ?? 0).toInt();
          final wins = (m['wins'] ?? 0).toInt();
          final winRate = ((m['winRate'] ?? 0)).toDouble();

          rows.add([
            strategy.name,
            marketData?.symbol ?? '-',
            marketData?.timeframe ?? '-',
            result.executedAt.toIso8601String(),
            tf,
            signals,
            trades,
            wins,
            winRate.toStringAsFixed(2),
          ]);
        }
      }

      if (rows.length == 1) {
        _snackbarService.showSnackbar(
          message: t?.noPerTfStatsFound ?? 'No per-timeframe stats found',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final csv = const ListToCsvConverter().convert(rows);
      final fileName = '${strategy.name}_results_tfstats.csv';

      if (kIsWeb) {
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);
        final share = locator<ShareService>();
        await share.shareFilePath(
          path,
          text: 'BacktestX Results Per-Timeframe Stats',
        );
      }

      _snackbarService.showSnackbar(
        message: t?.tfStatsExported ?? 'TF Stats exported to CSV',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.exportFailed(e.toString()) ?? 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // removed alias for cleanliness; use exportFilteredStrategyResultsCsv

  /// Export ALL trades across all results for a strategy to a single CSV
  Future<void> exportStrategyTradesCsv(Strategy strategy) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final results = getResults(strategy.id);
      if (results.isEmpty) {
        _snackbarService.showSnackbar(
          message:
              t?.noResultsToExport ?? 'No results to export for this strategy',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final List<List<dynamic>> rows = [];
      rows.add([
        'Strategy',
        'Symbol',
        'Timeframe',
        'Executed At',
        'Direction',
        'Entry Date',
        'Exit Date',
        'Entry Price',
        'Exit Price',
        'Lot Size',
        'Stop Loss',
        'Take Profit',
        'PnL',
        'PnL %',
        'Duration',
      ]);

      int tradeCount = 0;
      for (final r in results) {
        final marketData = _dataManager.getData(r.marketDataId);
        if (marketData == null) {
          // Skip if data not available in cache
          continue;
        }

        // Re-run backtest to get full trades (DB stores summary only)
        final reResult = await IsolateBacktest.run(
          marketData: marketData,
          strategy: strategy,
        );

        for (final trade in reResult.trades) {
          String duration = '-';
          if (trade.exitTime != null) {
            final diff = trade.exitTime!.difference(trade.entryTime).inHours;
            duration = '${diff ~/ 24}d ${diff % 24}h';
          }

          rows.add([
            strategy.name,
            marketData.symbol,
            marketData.timeframe,
            r.executedAt.toIso8601String(),
            trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
            trade.entryTime.toIso8601String(),
            trade.exitTime?.toIso8601String() ?? '-',
            trade.entryPrice.toStringAsFixed(4),
            trade.exitPrice?.toStringAsFixed(4) ?? '-',
            trade.lotSize.toStringAsFixed(2),
            trade.stopLoss?.toStringAsFixed(4) ?? '-',
            trade.takeProfit?.toStringAsFixed(4) ?? '-',
            trade.pnl?.toStringAsFixed(2) ?? '-',
            trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
            duration,
          ]);
          tradeCount++;
        }
      }

      if (tradeCount == 0) {
        _snackbarService.showSnackbar(
          message: t?.noTradesFoundOrCache ??
              'No trades found or data missing in cache',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      final csv = const ListToCsvConverter().convert(rows);
      final fileName = '${strategy.name}_all_trades.csv';

      if (kIsWeb) {
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);
        final share = locator<ShareService>();
        final deepLinks = locator<DeepLinkService>();
        final link = deepLinks.buildStrategyLink(strategyId: strategy.id);
        final text = 'BacktestX Trades Export — ${strategy.name}\n'
            'Open in Strategy Builder: $link';
        await share.shareFilePath(
          path,
          text: text,
          mimeType: 'text/csv',
          filename: fileName,
        );
      }

      final ctx2 = StackedService.navigatorKey?.currentContext;
      final t2 =
          ctx2 != null && ctx2.mounted ? AppLocalizations.of(ctx2)! : null;
      _snackbarService.showSnackbar(
        message: t2?.tradesExported ?? 'All trades exported to CSV',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.exportFailed(e.toString()) ?? 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Export single backtest result trades to CSV (web/mobile/desktop)
  Future<void> exportResultCsv(BacktestResult result) async {
    try {
      final marketData = _dataManager.getData(result.marketDataId);
      String strategyName = 'Strategy ${result.strategyId}';
      try {
        strategyName =
            _strategies.firstWhere((s) => s.id == result.strategyId).name;
      } catch (_) {}

      final List<List<dynamic>> rows = [];
      rows.add([
        'Strategy',
        'Symbol',
        'Timeframe',
        'Direction',
        'Entry Date',
        'Exit Date',
        'Entry Price',
        'Exit Price',
        'Lot Size',
        'Stop Loss',
        'Take Profit',
        'PnL',
        'PnL %',
        'Duration',
      ]);

      for (final trade in result.trades) {
        String duration = '-';
        if (trade.exitTime != null) {
          final diff = trade.exitTime!.difference(trade.entryTime).inHours;
          duration = '${diff ~/ 24}d ${diff % 24}h';
        }

        rows.add([
          strategyName,
          marketData?.symbol ?? '-',
          marketData?.timeframe ?? '-',
          trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
          trade.entryTime.toIso8601String(),
          trade.exitTime?.toIso8601String() ?? '-',
          trade.entryPrice.toStringAsFixed(4),
          trade.exitPrice?.toStringAsFixed(4) ?? '-',
          trade.lotSize.toStringAsFixed(2),
          trade.stopLoss?.toStringAsFixed(4) ?? '-',
          trade.takeProfit?.toStringAsFixed(4) ?? '-',
          trade.pnl?.toStringAsFixed(2) ?? '-',
          trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
          duration,
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      final fileName = '${strategyName}_backtest_results.csv';

      if (kIsWeb) {
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);
        final share = locator<ShareService>();
        final deepLinks = locator<DeepLinkService>();
        final link = deepLinks.buildBacktestResultLink(resultId: result.id);
        final text = 'BacktestX Results — $strategyName\n'
            'Open Backtest Result: $link';
        await share.shareFilePath(
          path,
          text: text,
          mimeType: 'text/csv',
          filename: fileName,
        );
      }

      // Show export-complete snackbar
      final ctx2 = StackedService.navigatorKey?.currentContext;
      final t2 =
          ctx2 != null && ctx2.mounted ? AppLocalizations.of(ctx2)! : null;
      _snackbarService.showSnackbar(
        message: t2?.workspaceExportFilteredResultsCsv ??
            'Filtered results exported to CSV',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.exportFailed(e.toString()) ?? 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Copy single result summary to clipboard
  Future<void> copyResultSummaryToClipboard(BacktestResult result) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final marketData = _dataManager.getData(result.marketDataId);
      String strategyName = 'Strategy ${result.strategyId}';
      try {
        strategyName =
            _strategies.firstWhere((s) => s.id == result.strategyId).name;
      } catch (_) {}

      final summary = result.summary;
      final buffer = StringBuffer();
      buffer.writeln('Backtest Summary - $strategyName');
      buffer.writeln(
          'Symbol: ${marketData?.symbol ?? '-'} | Timeframe: ${marketData?.timeframe ?? '-'}');
      buffer.writeln('Executed: ${result.executedAt.toIso8601String()}');
      buffer.writeln('');
      buffer.writeln('Total Trades: ${summary.totalTrades}');
      buffer.writeln('Win Rate: ${summary.winRate.toStringAsFixed(2)}%');
      buffer
          .writeln('Profit Factor: ${summary.profitFactor.toStringAsFixed(2)}');
      buffer.writeln('Total PnL: ${summary.totalPnl.toStringAsFixed(2)}');
      buffer.writeln(
          'Total PnL %: ${summary.totalPnlPercentage.toStringAsFixed(2)}%');
      buffer.writeln(
          'Max Drawdown: ${summary.maxDrawdown.toStringAsFixed(2)} (${summary.maxDrawdownPercentage.toStringAsFixed(2)}%)');
      buffer.writeln('Sharpe Ratio: ${summary.sharpeRatio.toStringAsFixed(2)}');

      // Append per-timeframe stats if available
      final tfStats = summary.tfStats ?? {};
      if (tfStats.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('Per-Timeframe Stats:');
        final entries = tfStats.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        for (final e in entries) {
          final tf = e.key;
          final m = e.value;
          final signals = (m['signals'] ?? 0).toInt();
          final trades = (m['trades'] ?? 0).toInt();
          final wins = (m['wins'] ?? 0).toInt();
          final winRate = ((m['winRate'] ?? 0)).toDouble();
          final line =
              '- $tf: ${signals}S, ${trades}T, ${wins}W, ${winRate.toStringAsFixed(2)}% WR';
          buffer.writeln(line);
        }
      }

      final text = buffer.toString();
      if (locator.isRegistered<ClipboardService>()) {
        await locator<ClipboardService>().copyText(text);
      } else {
        await Clipboard.setData(ClipboardData(text: text));
      }
      _snackbarService.showSnackbar(
        message: t?.summaryCopied ?? 'Summary copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.copyFailed(e.toString()) ?? 'Copy failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Copy trades table as CSV to clipboard for a single result
  Future<void> copyTradesCsvToClipboard(BacktestResult result) async {
    try {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      final closedTrades =
          result.trades.where((t) => t.status == TradeStatus.closed).toList();

      final List<List<dynamic>> rows = [];
      rows.add([
        'Direction',
        'Entry Date',
        'Exit Date',
        'Entry Price',
        'Exit Price',
        'Lot Size',
        'Stop Loss',
        'Take Profit',
        'PnL',
        'PnL %',
        'Duration',
      ]);

      for (final trade in closedTrades) {
        String duration = '-';
        if (trade.exitTime != null) {
          final diff = trade.exitTime!.difference(trade.entryTime).inHours;
          duration = '${diff ~/ 24}d ${diff % 24}h';
        }

        rows.add([
          trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
          trade.entryTime.toIso8601String(),
          trade.exitTime?.toIso8601String() ?? '-',
          trade.entryPrice.toStringAsFixed(4),
          trade.exitPrice?.toStringAsFixed(4) ?? '-',
          trade.lotSize.toStringAsFixed(2),
          trade.stopLoss?.toStringAsFixed(4) ?? '-',
          trade.takeProfit?.toStringAsFixed(4) ?? '-',
          trade.pnl?.toStringAsFixed(2) ?? '-',
          trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
          duration,
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      if (locator.isRegistered<ClipboardService>()) {
        await locator<ClipboardService>().copyText(csv);
      } else {
        await Clipboard.setData(ClipboardData(text: csv));
      }
      _snackbarService.showSnackbar(
        message: t?.tradesCsvCopied ?? 'Trades CSV copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message: t?.copyFailed(e.toString()) ?? 'Copy failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
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

    final ctx = StackedService.navigatorKey?.currentContext;
    final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
    _snackbarService.showSnackbar(
      message: t?.strategyDuplicated ?? 'Strategy duplicated',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> deleteStrategy(Strategy strategy) async {
    final resultsCount = getResultsCount(strategy.id);

    final ctx = StackedService.navigatorKey?.currentContext;
    final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
    final response = await _dialogService.showConfirmationDialog(
      title: t?.deleteStrategyTitle ?? 'Delete Strategy',
      description: resultsCount > 0
          ? (t?.deleteStrategyDesc(strategy.name, resultsCount.toString()) ??
              'Delete "${strategy.name}"?\n\nThis will also delete $resultsCount backtest result(s).')
          : (t?.deleteStrategyDescNoResults(strategy.name) ??
              'Delete "${strategy.name}"?'),
      confirmationTitle: t?.deleteLabel ?? 'Delete',
      cancelTitle: t?.commonCancel ?? 'Cancel',
    );

    if (response?.confirmed != true) return;

    await runBusyFuture(
      _storageService.deleteStrategy(strategy.id),
      busyObject: 'delete_${strategy.id}',
    );

    await loadData();

    _snackbarService.showSnackbar(
      message: t?.strategyDeleted ?? 'Strategy deleted',
      duration: const Duration(seconds: 2),
    );
  }

  // Result actions
  Future<void> deleteResult(BacktestResult result) async {
    final ctx = StackedService.navigatorKey?.currentContext;
    final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
    final response = await _dialogService.showConfirmationDialog(
      title: t?.deleteTitle ?? 'Delete Result',
      description: t?.deleteResultDesc ?? 'Delete this backtest result?',
      confirmationTitle: t?.deleteLabel ?? 'Delete',
      cancelTitle: t?.commonCancel ?? 'Cancel',
    );

    if (response?.confirmed != true) return;

    await runBusyFuture(
      _storageService.deleteBacktestResult(result.id),
      busyObject: 'delete_result',
    );

    await loadData();

    _snackbarService.showSnackbar(
      message: t?.resultDeleted ?? 'Result deleted',
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
        final ctx = StackedService.navigatorKey?.currentContext;
        final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
        _snackbarService.showSnackbar(
          message: t?.maximumCompare ?? 'Maximum 4 results can be compared',
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
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null ? AppLocalizations.of(ctx) : null;
      _snackbarService.showSnackbar(
        message:
            (t?.workspaceCompareBannerText ?? 'Select 2-4 results to compare'),
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
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null && ctx.mounted ? AppLocalizations.of(ctx)! : null;
      _snackbarService.showSnackbar(
        message:
            t?.errorLoadingSelectedResults ?? 'Error loading selected results',
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

// Result list sorting per strategy
enum ResultSortKey {
  executedAtDesc,
  pnlDesc,
  winRateDesc,
  profitFactorDesc,
}

extension ResultSortKeyX on ResultSortKey {
  String get label {
    switch (this) {
      case ResultSortKey.executedAtDesc:
        return 'Latest';
      case ResultSortKey.pnlDesc:
        return 'P&L';
      case ResultSortKey.winRateDesc:
        return 'Win Rate';
      case ResultSortKey.profitFactorDesc:
        return 'Profit Factor';
    }
  }

  IconData get icon {
    switch (this) {
      case ResultSortKey.executedAtDesc:
        return Icons.schedule;
      case ResultSortKey.pnlDesc:
        return Icons.attach_money;
      case ResultSortKey.winRateDesc:
        return Icons.percent;
      case ResultSortKey.profitFactorDesc:
        return Icons.trending_up;
    }
  }
}

// Store selected result sort key per strategy
// Moved into WorkspaceViewModel class
