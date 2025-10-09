import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'dart:async';
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

  // Autosave
  Timer? _autosaveTimer;
  final Duration _autosaveDebounce = const Duration(seconds: 2);
  String autosaveStatus = '';

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

    // Try restore draft if available (prefer draft over existing state)
    try {
      await restoreDraftIfAvailable();
    } catch (e) {
      debugPrint('Restore draft failed: $e');
    }

    _setupAutosaveListeners();

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
      _scheduleAutosave();
    }
  }

  void addEntryRule() {
    entryRules.add(RuleBuilder());
    notifyListeners();
    _attachRuleListeners(entryRules.last);
    _scheduleAutosave();
  }

  void addExitRule() {
    exitRules.add(RuleBuilder());
    notifyListeners();
    _attachRuleListeners(exitRules.last);
    _scheduleAutosave();
  }

  void removeEntryRule(int index) {
    entryRules[index].dispose();
    entryRules.removeAt(index);
    notifyListeners();
    _scheduleAutosave();
  }

  void removeExitRule(int index) {
    exitRules[index].dispose();
    exitRules.removeAt(index);
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleIndicator(int index, IndicatorType indicator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.indicator = indicator;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleOperator(
      int index, ComparisonOperator operator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.operator = operator;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleValueType(int index, bool isNumber, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.isNumberValue = isNumber;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleNumberValue(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.numberValue = double.tryParse(value);
    _scheduleAutosave();
  }

  void updateRuleCompareIndicator(
      int index, IndicatorType indicator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.compareIndicator = indicator;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRulePeriod(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.period = int.tryParse(value);
    _scheduleAutosave();
  }

  void updateRuleLogicalOperator(
      int index, LogicalOperator? operator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.logicalOperator = operator;
    notifyListeners();
    _scheduleAutosave();
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
      // Clear related draft (autosave) after successful save
      try {
        await _storageService.clearStrategyDraft(
          strategyId: isEditing ? strategyId : null,
        );
      } catch (e) {
        debugPrint('Failed to clear draft: $e');
      }
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
    _scheduleAutosave();
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
    _autosaveTimer?.cancel();
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

  // ================= AUTOSAVE =================
  void _setupAutosaveListeners() {
    nameController.addListener(_scheduleAutosave);
    initialCapitalController.addListener(_scheduleAutosave);
    riskValueController.addListener(_scheduleAutosave);
    stopLossController.addListener(_scheduleAutosave);
    takeProfitController.addListener(_scheduleAutosave);

    // Attach to existing rules
    for (final rule in entryRules) {
      _attachRuleListeners(rule);
    }
    for (final rule in exitRules) {
      _attachRuleListeners(rule);
    }
  }

  void _attachRuleListeners(RuleBuilder rule) {
    rule.numberController.addListener(_scheduleAutosave);
    rule.periodController.addListener(_scheduleAutosave);
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () async {
      await _saveDraft();
    });
  }

  Map<String, dynamic> _buildDraftJson() {
    return {
      'name': nameController.text,
      'initialCapital': initialCapitalController.text,
      'riskType': riskType.name,
      'riskValue': riskValueController.text,
      'stopLoss': stopLossController.text,
      'takeProfit': takeProfitController.text,
      'selectedDataId': selectedDataId,
      'entryRules': entryRules.map((r) => {
            'indicator': r.indicator.name,
            'operator': r.operator.name,
            'isNumberValue': r.isNumberValue,
            'numberValue': r.numberValue,
            'compareIndicator': r.compareIndicator?.name,
            'period': r.period,
            'logicalOperator': r.logicalOperator?.name,
          }).toList(),
      'exitRules': exitRules.map((r) => {
            'indicator': r.indicator.name,
            'operator': r.operator.name,
            'isNumberValue': r.isNumberValue,
            'numberValue': r.numberValue,
            'compareIndicator': r.compareIndicator?.name,
            'period': r.period,
            'logicalOperator': r.logicalOperator?.name,
          }).toList(),
    };
  }

  Future<void> _saveDraft() async {
    try {
      final draft = _buildDraftJson();
      await _storageService.saveStrategyDraft(
        strategyId: isEditing ? strategyId : null,
        draftJson: draft,
      );
      final now = DateTime.now();
      autosaveStatus =
          'Auto-saved ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      notifyListeners();
    } catch (e) {
      debugPrint('Autosave failed: $e');
    }
  }

  Future<void> restoreDraftIfAvailable() async {
    final draft = await _storageService.getStrategyDraft(
      strategyId: isEditing ? strategyId : null,
    );
    if (draft == null) return;

    try {
      nameController.text = (draft['name'] as String?) ?? '';
      initialCapitalController.text =
          (draft['initialCapital'] as String?) ?? initialCapitalController.text;
      final riskTypeName = draft['riskType'] as String?;
      if (riskTypeName != null) {
        riskType = RiskType.values
            .firstWhere((e) => e.name == riskTypeName, orElse: () => riskType);
      }
      riskValueController.text =
          (draft['riskValue'] as String?) ?? riskValueController.text;
      stopLossController.text =
          (draft['stopLoss'] as String?) ?? stopLossController.text;
      takeProfitController.text =
          (draft['takeProfit'] as String?) ?? takeProfitController.text;
      selectedDataId = draft['selectedDataId'] as String?;

      // Restore rules
      List<dynamic> entry = (draft['entryRules'] as List<dynamic>? ?? []);
      List<dynamic> exit = (draft['exitRules'] as List<dynamic>? ?? []);
      for (final r in entryRules) {
        r.dispose();
      }
      for (final r in exitRules) {
        r.dispose();
      }
      entryRules = entry.map((m) => _mapToRuleBuilder(m)).toList();
      exitRules = exit.map((m) => _mapToRuleBuilder(m)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to apply draft: $e');
    }
  }

  RuleBuilder _mapToRuleBuilder(dynamic m) {
    final map = m as Map<String, dynamic>;
    final indicatorName = map['indicator'] as String?;
    final operatorName = map['operator'] as String?;
    final isNumberValue = map['isNumberValue'] as bool? ?? true;
    final numberValue = (map['numberValue'] as num?)?.toDouble();
    final compareIndicatorName = map['compareIndicator'] as String?;
    final period = map['period'] as int?;
    final logicalName = map['logicalOperator'] as String?;

    final indicator = indicatorName != null
        ? IndicatorType.values.firstWhere(
            (e) => e.name == indicatorName,
            orElse: () => IndicatorType.rsi,
          )
        : IndicatorType.rsi;
    final operator = operatorName != null
        ? ComparisonOperator.values.firstWhere(
            (e) => e.name == operatorName,
            orElse: () => ComparisonOperator.lessThan,
          )
        : ComparisonOperator.lessThan;
    final compareIndicator = compareIndicatorName != null
        ? IndicatorType.values.firstWhere(
            (e) => e.name == compareIndicatorName,
            orElse: () => IndicatorType.sma,
          )
        : null;
    final logicalOp = logicalName != null
        ? LogicalOperator.values.firstWhere(
            (e) => e.name == logicalName,
            orElse: () => LogicalOperator.and,
          )
        : null;

    return RuleBuilder(
      indicator: indicator,
      operator: operator,
      isNumberValue: isNumberValue,
      numberValue: numberValue,
      compareIndicator: compareIndicator,
      period: period,
      logicalOperator: logicalOp,
    );
  }
}
