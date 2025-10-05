import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/strategy.dart';
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
  final _uuid = const Uuid();

  final String? strategyId;
  Strategy? existingStrategy;

  StrategyBuilderViewModel(this.strategyId);

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
      print('Error loading strategy: $e');
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

      _snackbarService.showSnackbar(
        message: isEditing ? 'Strategy updated!' : 'Strategy saved!',
        duration: const Duration(seconds: 2),
      );

      // Navigate back
      _navigationService.back();
    } catch (e) {
      print('Error saving strategy: $e');
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
        _snackbarService.showSnackbar(
          message: 'Strategy deleted',
          duration: const Duration(seconds: 2),
        );
        _navigationService.back();
      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Failed to delete strategy',
          duration: const Duration(seconds: 2),
        );
      }
    }
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
