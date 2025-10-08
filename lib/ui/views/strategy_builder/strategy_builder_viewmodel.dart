import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:uuid/uuid.dart';

class RuleBuilder {
  IndicatorType indicator;
  ComparisonOperator operator;
  bool isNumberValue;
  double? numberValue;
  IndicatorType? compareIndicator;
  int? period;
  LogicalOperator? logicalOperator;

  final TextEditingController numberController;
  final TextEditingController periodController;

  RuleBuilder({
    this.indicator = IndicatorType.rsi,
    this.operator = ComparisonOperator.lessThan,
    this.isNumberValue = true,
    this.numberValue,
    this.compareIndicator,
    this.period,
    this.logicalOperator,
  })  : numberController = TextEditingController(text: numberValue?.toString()),
        periodController = TextEditingController(text: period?.toString());

  void dispose() {
    numberController.dispose();
    periodController.dispose();
  }
}

class StrategyBuilderViewModel extends BaseViewModel {
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _dataManager = locator<DataManager>();
  final _backtestEngine = locator<BacktestEngineService>();
  final _uuid = const Uuid();

  final String? strategyId;
  Strategy? existingStrategy;

  StrategyBuilderViewModel(this.strategyId);

  // Quick backtest preview state
  BacktestResult? previewResult;
  bool isRunningPreview = false;
  String? selectedDataId;
  List<MarketData> availableData = [];

  // Controllers
  final nameController = TextEditingController();
  final initialCapitalController = TextEditingController(text: '10000');
  final riskValueController = TextEditingController(text: '2.0');
  final stopLossController = TextEditingController(text: '100');
  final takeProfitController = TextEditingController(text: '200');

  RiskType riskType = RiskType.percentageRisk;
  List<RuleBuilder> entryRules = [];
  List<RuleBuilder> exitRules = [];

  bool get isEditing => strategyId != null;
  bool get canSave =>
      nameController.text.isNotEmpty &&
      initialCapitalController.text.isNotEmpty &&
      entryRules.isNotEmpty;

  Future<void> initialize() async {
    setBusy(true);

    if (isEditing) {
      await _loadExistingStrategy();
    }

    setBusy(false);
  }

  Future<void> _loadExistingStrategy() async {
    try {
      existingStrategy = await _storageService.getStrategy(strategyId!);

      if (existingStrategy != null) {
        nameController.text = existingStrategy!.name;
        initialCapitalController.text =
            existingStrategy!.initialCapital.toString();
        riskType = existingStrategy!.riskManagement.riskType;
        riskValueController.text =
            existingStrategy!.riskManagement.riskValue.toString();
        stopLossController.text =
            existingStrategy!.riskManagement.stopLoss?.toString() ?? '';
        takeProfitController.text =
            existingStrategy!.riskManagement.takeProfit?.toString() ?? '';

        // Load entry rules
        entryRules =
            existingStrategy!.entryRules.map(_strategyRuleToBuilder).toList();

        // Load exit rules
        exitRules =
            existingStrategy!.exitRules.map(_strategyRuleToBuilder).toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading strategy: $e');
      _snackbarService.showSnackbar(message: 'Failed to load strategy');
    }
  }

  RuleBuilder _strategyRuleToBuilder(StrategyRule rule) {
    return rule.value.when(
      number: (n) => RuleBuilder(
        indicator: rule.indicator,
        operator: rule.operator,
        isNumberValue: true,
        numberValue: n,
        logicalOperator: rule.logicalOperator,
      ),
      indicator: (type, period) => RuleBuilder(
        indicator: rule.indicator,
        operator: rule.operator,
        isNumberValue: false,
        compareIndicator: type,
        period: period,
        logicalOperator: rule.logicalOperator,
      ),
    );
  }

  void setRiskType(RiskType? type) {
    if (type != null) {
      riskType = type;
      notifyListeners();
    }
  }

  void addEntryRule() {
    entryRules.add(RuleBuilder());
    notifyListeners();
  }

  void addExitRule() {
    exitRules.add(RuleBuilder());
    notifyListeners();
  }

  void removeEntryRule(int index) {
    entryRules[index].dispose();
    entryRules.removeAt(index);
    notifyListeners();
  }

  void removeExitRule(int index) {
    exitRules[index].dispose();
    exitRules.removeAt(index);
    notifyListeners();
  }

  void updateRuleIndicator(int index, IndicatorType indicator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.indicator = indicator;
    notifyListeners();
  }

  void updateRuleOperator(
      int index, ComparisonOperator operator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.operator = operator;
    notifyListeners();
  }

  void updateRuleValueType(int index, bool isNumber, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.isNumberValue = isNumber;
    notifyListeners();
  }

  void updateRuleNumberValue(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.numberValue = double.tryParse(value);
  }

  void updateRuleCompareIndicator(
      int index, IndicatorType indicator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.compareIndicator = indicator;
    notifyListeners();
  }

  void updateRulePeriod(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.period = int.tryParse(value);
  }

  void updateRuleLogicalOperator(
      int index, LogicalOperator? operator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.logicalOperator = operator;
    notifyListeners();
  }

  Future<void> saveStrategy(BuildContext context) async {
    if (!canSave) {
      _snackbarService.showSnackbar(
        message: 'Please fill all required fields',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setBusy(true);

    try {
      // Build strategy object
      final strategy = Strategy(
        id: isEditing ? existingStrategy!.id : _uuid.v4(),
        name: nameController.text.trim(),
        initialCapital: double.parse(initialCapitalController.text),
        riskManagement: RiskManagement(
          riskType: riskType,
          riskValue: double.parse(riskValueController.text),
          stopLoss: double.tryParse(stopLossController.text),
          takeProfit: double.tryParse(takeProfitController.text),
        ),
        entryRules: entryRules.map(_builderToStrategyRule).toList(),
        exitRules: exitRules.map(_builderToStrategyRule).toList(),
        createdAt: isEditing ? existingStrategy!.createdAt : DateTime.now(),
        updatedAt: isEditing ? DateTime.now() : null,
      );

      // Save to database
      await _storageService.saveStrategy(strategy);
      // Navigate back
      _navigationService.back();

      _snackbarService.showSnackbar(
        message: isEditing ? 'Strategy updated!' : 'Strategy saved!',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error saving strategy: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to save strategy: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  StrategyRule _builderToStrategyRule(RuleBuilder builder) {
    final value = builder.isNumberValue
        ? ConditionValue.number(builder.numberValue ?? 0)
        : ConditionValue.indicator(
            type: builder.compareIndicator ?? IndicatorType.sma,
            period: builder.period,
          );

    return StrategyRule(
      indicator: builder.indicator,
      operator: builder.operator,
      value: value,
      logicalOperator: builder.logicalOperator,
    );
  }

  Future<void> deleteStrategy(BuildContext context) async {
    if (!isEditing) return;

    final response = await _dialogService.showConfirmationDialog(
      title: 'Delete Strategy',
      description: 'Are you sure you want to delete this strategy?',
      confirmationTitle: 'Delete',
      cancelTitle: 'Cancel',
    );

    if (response?.confirmed == true) {
      try {
        await _storageService.deleteStrategy(strategyId!);
        // Navigate back
        _navigationService.back();
        _snackbarService.showSnackbar(
          message: 'Strategy deleted',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Failed to delete strategy',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  /// Get available market data for quick preview
  void loadAvailableData() {
    availableData = _dataManager.getAllData();
    if (availableData.isNotEmpty && selectedDataId == null) {
      selectedDataId = availableData.first.id;
    }
  }

  /// Set selected market data for preview
  void setSelectedData(String? dataId) {
    selectedDataId = dataId;
    notifyListeners();
  }

  /// Run quick backtest preview without saving strategy
  Future<void> quickPreviewBacktest() async {
    if (!canSave) {
      _snackbarService.showSnackbar(
        message: 'Please fill all required fields before testing',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedDataId == null) {
      _snackbarService.showSnackbar(
        message: 'Please select market data for testing',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Get selected market data
    final marketData = _dataManager.getData(selectedDataId!);
    if (marketData == null) {
      _snackbarService.showSnackbar(
        message: 'Selected market data not found',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    isRunningPreview = true;
    notifyListeners();

    try {
      // Build temporary strategy object for testing
      final strategy = Strategy(
        id: 'temp-preview-${_uuid.v4()}',
        name: nameController.text.trim(),
        initialCapital: double.parse(initialCapitalController.text),
        riskManagement: RiskManagement(
          riskType: riskType,
          riskValue: double.parse(riskValueController.text),
          stopLoss: double.tryParse(stopLossController.text),
          takeProfit: double.tryParse(takeProfitController.text),
        ),
        entryRules: entryRules.map(_builderToStrategyRule).toList(),
        exitRules: exitRules.map(_builderToStrategyRule).toList(),
        createdAt: DateTime.now(),
      );

      // Run backtest
      previewResult = await _backtestEngine.runBacktest(
        marketData: marketData,
        strategy: strategy,
      );

      // Show quick summary
      _snackbarService.showSnackbar(
        message: 'Preview complete! Check results below.',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error running preview backtest: $e');
      _snackbarService.showSnackbar(
        message: 'Failed to run preview: $e',
        duration: const Duration(seconds: 3),
      );
      previewResult = null;
    } finally {
      isRunningPreview = false;
      notifyListeners();
    }
  }

  /// Navigate to full backtest result view with current preview result
  void viewFullResults() {
    if (previewResult == null) return;

    _navigationService.navigateToBacktestResultView(result: previewResult!);
  }

  @override
  void dispose() {
    nameController.dispose();
    initialCapitalController.dispose();
    riskValueController.dispose();
    stopLossController.dispose();
    takeProfitController.dispose();
    for (final rule in entryRules) {
      rule.dispose();
    }
    for (final rule in exitRules) {
      rule.dispose();
    }
    super.dispose();
  }
}
