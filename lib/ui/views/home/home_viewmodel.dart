import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/gold_strategy.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/common/backtest_helper.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _storageService = locator<StorageService>();

  int strategiesCount = 0;
  int dataSetsCount = 0;
  int testsCount = 0;
  List<Strategy> recentStrategies = [];

  bool get hasResults => testsCount > 0;

  Future<void> initialize() async {
    setBusy(true);
    await _loadStats();
    setBusy(false);
  }

  Future<void> _loadStats() async {
    try {
      final strategies = await _storageService.getAllStrategies();
      final marketData = await _storageService.getAllMarketData();

      strategiesCount = strategies.length;
      dataSetsCount = marketData.length;

      // Get recent strategies (max 5)
      recentStrategies = strategies.take(5).toList();

      // Count total backtest results across all strategies
      int totalTests = 0;
      for (final strategy in strategies) {
        final results =
            await _storageService.getBacktestResultsByStrategy(strategy.id);
        totalTests += results.length;
      }
      testsCount = totalTests;

      notifyListeners();
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  void navigateToDataUpload() {
    _navigationService.navigateToDataUploadView();
  }

  void navigateToStrategyBuilder() {
    _navigationService.navigateToStrategyBuilderView();
  }

  void navigateToBacktestResult() async {
    final helper = BacktestTestHelper();
    final marketData = await _storageService.getAllMarketData();

    // await helper.testGoldConservative(marketData.first);
    helper.testEmaCrossover(marketData.first);
    if (hasResults) {
      _navigationService.navigateToBacktestResultView();
    }
  }

  void navigateToWorkspace() {
    // _navigationService.navigateToWorkspaceView();
  }

  Future<void> runStrategy(String strategyId) async {
    // TODO: Implement quick run from home
    // This would show a dialog to select market data and run backtest
    print('Running strategy: $strategyId');
  }
}
