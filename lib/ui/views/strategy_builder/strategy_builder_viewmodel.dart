import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/helpers/timeframe_helper.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/helpers/timeframe_helper.dart' as tf_helper;
import 'dart:async';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:backtestx/ui/common/base_refreshable_viewmodel.dart';
import 'package:backtestx/services/prefs_service.dart';
import 'dart:convert';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:uuid/uuid.dart';
import 'package:backtestx/ui/common/ui_helpers.dart';
import 'package:backtestx/helpers/strategy_templates.dart';
import 'package:backtestx/services/share_service.dart';
import 'package:backtestx/services/clipboard_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:backtestx/helpers/filename_helper.dart';

class RuleBuilder {
  IndicatorType indicator;
  ComparisonOperator operator;
  bool isNumberValue;
  double? numberValue;
  IndicatorType? compareIndicator;
  // Period for comparison indicator (right side)
  int? period;
  // Period for main indicator (left side)
  int? mainPeriod;
  LogicalOperator? logicalOperator;
  String? timeframe;
  // Anchor config for Anchored VWAP (right side)
  AnchorMode? anchorMode;
  DateTime? anchorDate;

  final TextEditingController numberController;
  final TextEditingController periodController;
  final TextEditingController mainPeriodController;
  final TextEditingController anchorDateController;

  RuleBuilder({
    this.indicator = IndicatorType.rsi,
    this.operator = ComparisonOperator.lessThan,
    this.isNumberValue = true,
    this.numberValue,
    this.compareIndicator,
    this.period,
    this.mainPeriod,
    this.logicalOperator,
    this.timeframe,
    this.anchorMode,
    this.anchorDate,
  })  : numberController = TextEditingController(text: numberValue?.toString()),
        periodController = TextEditingController(text: period?.toString()),
        mainPeriodController =
            TextEditingController(text: mainPeriod?.toString()),
        anchorDateController =
            TextEditingController(text: anchorDate?.toIso8601String());

  void dispose() {
    numberController.dispose();
    periodController.dispose();
    mainPeriodController.dispose();
    anchorDateController.dispose();
  }
}

class StrategyBuilderViewModel extends BaseRefreshableViewModel {
  final _storageService = locator<StorageService>();
  final _navigationService = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _dataManager = locator<DataManager>();
  final _backtestEngine = locator<BacktestEngineService>();
  final _uuid = const Uuid();
  final _prefs = PrefsService();
  final _bottomSheetService = locator<BottomSheetService>();

  final String? strategyId;
  Strategy? existingStrategy;

  StrategyBuilderViewModel(this.strategyId);

  // Quick backtest preview state
  BacktestResult? previewResult;
  bool isRunningPreview = false;
  String? selectedDataId;
  List<MarketData> availableData = [];
  // Per‑TF stats from the last preview run
  Map<String, Map<String, num>> previewTfStats = {};
  // Last applied template hint
  String? appliedTemplateName;
  String? appliedTemplateDescription;
  // Recently applied template keys (persisted via PrefsService)
  List<String> recentTemplateKeys = [];
  // Persisted UI state for template picker
  List<String> selectedTemplateCategories = [];
  String selectedTemplateQuery = '';

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
  Timer? _statusTicker;
  final Duration _statusTickInterval = const Duration(seconds: 30);
  final Duration _autosaveDebounce = const Duration(seconds: 2);
  String autosaveStatus = '';
  bool autosaveEnabled = true;
  bool isAutoSaving = false;
  DateTime? lastAutosaveAt;
  bool hasAutosaveDraft = false;

  // Saving state (non-blocking UI)
  bool isSaving = false;

  // Reset builder form to defaults after successful save
  void resetForm() {
    nameController.clear();
    initialCapitalController.text = '10000';
    riskValueController.text = '2.0';
    stopLossController.text = '100';
    takeProfitController.text = '200';

    riskType = RiskType.percentageRisk;
    entryRules = [];
    exitRules = [];

    selectedDataId = null;
    previewResult = null;
    isRunningPreview = false;
    previewTfStats = {};

    appliedTemplateName = null;
    appliedTemplateDescription = null;

    autosaveStatus = '';
    isAutoSaving = false;
    lastAutosaveAt = null;
    hasAutosaveDraft = false;

    notifyListeners();
  }

  // Services
  final _indicatorService = locator<IndicatorService>();

  // Cache for ATR% percentiles per timeframe+period
  final Map<String, List<double>> _atrPctPercentilesCache = {};

  bool get isEditing => strategyId != null;
  bool get canSave =>
      nameController.text.isNotEmpty &&
      initialCapitalController.text.isNotEmpty &&
      entryRules.isNotEmpty;

  bool get hasFatalErrors => getAllFatalErrors().isNotEmpty;

  // ======= VALIDATION =======
  List<String> getRuleWarningsFor(int index, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    final warnings = <String>[];
    final l10n =
        AppLocalizations.of(_navigationService.navigatorKey!.currentContext!)!;

    // Timeframe smaller than base timeframe (if selected)
    if (rule.timeframe != null && selectedDataId != null) {
      final data = _dataManager.getData(selectedDataId!);
      if (data != null) {
        final baseMin = tf_helper.parseTimeframeToMinutes(data.timeframe);
        final ruleMin = tf_helper.parseTimeframeToMinutes(rule.timeframe!);
        if (ruleMin < baseMin) {
          warnings.add(l10n.sbWarningTfGreaterThanBase(data.timeframe));
        }
      }
    }

    // Indicator-specific soft guidance
    if (rule.indicator == IndicatorType.rsi && rule.isNumberValue) {
      final v = rule.numberValue;
      if (v != null && (v < 20 || v > 80)) {
        warnings.add(l10n.sbWarningRsiBetween20And80);
      }
    }

    // Operator guidance
    if (rule.operator == ComparisonOperator.equals) {
      warnings.add(l10n.sbWarningOperatorEqualsNotSupported);
    }
    if ((rule.operator == ComparisonOperator.crossAbove ||
            rule.operator == ComparisonOperator.crossBelow) &&
        !rule.isNumberValue &&
        rule.compareIndicator == IndicatorType.bollingerBands) {
      warnings.add(l10n.sbWarningBbandsSpecifyBand);
    }

    // Main indicator period suggestions
    final indicatorsNeedPeriod = <IndicatorType>{
      IndicatorType.sma,
      IndicatorType.ema,
      IndicatorType.rsi,
      IndicatorType.atr,
      IndicatorType.atrPct,
      IndicatorType.adx,
      IndicatorType.bollingerBands,
      IndicatorType.bollingerWidth,
      IndicatorType.vwap,
      IndicatorType.stochasticK,
      IndicatorType.stochasticD,
    };
    if (indicatorsNeedPeriod.contains(rule.indicator)) {
      if (rule.mainPeriod == null || (rule.mainPeriod ?? 0) <= 0) {
        warnings.add(l10n.sbPeriodMustBeSetGtZero);
      }
    }

    return warnings;
  }

  /// Apply a predefined strategy template by key
  void applyTemplate(String key) {
    final template = StrategyTemplates.all[key];
    if (template == null) {
      _snackbarService.showSnackbar(
        message: 'Template not found',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Clear existing rules
    for (final r in entryRules) {
      r.dispose();
    }
    for (final r in exitRules) {
      r.dispose();
    }

    // Apply details
    nameController.text = template.name;
    initialCapitalController.text = template.initialCapital.toString();
    riskType = template.risk.riskType;
    riskValueController.text = template.risk.riskValue.toString();
    stopLossController.text = template.risk.stopLoss?.toString() ?? '';
    takeProfitController.text = template.risk.takeProfit?.toString() ?? '';

    // Store template hint
    appliedTemplateName = template.name;
    appliedTemplateDescription = template.description;

    // Apply rules
    entryRules = template.entryRules.map(_strategyRuleToBuilder).toList();
    exitRules = template.exitRules.map(_strategyRuleToBuilder).toList();

    // Re-attach listeners for autosave
    for (final rule in entryRules) {
      _attachRuleListeners(rule);
    }
    for (final rule in exitRules) {
      _attachRuleListeners(rule);
    }

    notifyListeners();
    _scheduleAutosave();
    // Update Recently Applied list (persisted)
    try {
      recentTemplateKeys.removeWhere((k) => k == key);
      recentTemplateKeys.insert(0, key);
      if (recentTemplateKeys.length > 6) {
        recentTemplateKeys = recentTemplateKeys.take(6).toList();
      }
      // Persist asynchronously; ignore await to keep UX snappy
      _prefs.setString('recent_templates', jsonEncode(recentTemplateKeys));
    } catch (_) {
      // Non-critical
    }
    _snackbarService.showSnackbar(
      message: 'Template applied: ${template.name}',
      duration: const Duration(seconds: 2),
    );

    // Sinkronkan kategori filter default ke kategori template yang diterapkan
    try {
      final cat = _categorizeTemplateName(template.name);
      setSelectedTemplateCategories([cat]);
    } catch (_) {
      // Non-critical
    }
  }

  String _categorizeTemplateName(String name) {
    final n = name.toLowerCase();
    if (n.contains('breakout')) return 'Breakout';
    if (n.contains('mean reversion')) return 'Mean Reversion';
    if (n.contains('trend')) return 'Trend';
    if (n.contains('momentum')) return 'Momentum';
    return 'Other';
  }

  /// Update persisted template search query
  void setTemplateSearchQuery(String q) {
    selectedTemplateQuery = q;
    try {
      _prefs.setString('template_search_query', q);
    } catch (_) {
      // Non-critical
    }
    // View updates are local to the bottom sheet; notify optional
    notifyListeners();
  }

  /// Update persisted selected template categories
  void setSelectedTemplateCategories(List<String> cats) {
    selectedTemplateCategories = cats;
    try {
      _prefs.setString('template_selected_categories', jsonEncode(cats));
    } catch (_) {
      // Non-critical
    }
    notifyListeners();
  }

  /// Reset template filters (query and categories) and persist the cleared state
  Future<void> resetTemplateFilters() async {
    try {
      // Use existing setters to keep persistence logic unified
      setSelectedTemplateCategories([]);
      setTemplateSearchQuery('');
      // Also persist explicitly to be safe in case notify batching skips
      await _prefs.setString('template_selected_categories', jsonEncode([]));
      await _prefs.setString('template_search_query', '');
    } catch (_) {
      // Non-critical
    }
  }

  List<String> _getRuleFatalErrors(RuleBuilder rule) {
    final errors = <String>[];
    final l10n =
        AppLocalizations.of(_navigationService.navigatorKey!.currentContext!)!;
    // Rising/Falling do not require comparison value
    if (rule.operator == ComparisonOperator.rising ||
        rule.operator == ComparisonOperator.falling) {
      return errors;
    }
    // Main indicator must have valid period for certain indicators
    final indicatorsNeedPeriod = <IndicatorType>{
      IndicatorType.sma,
      IndicatorType.ema,
      IndicatorType.rsi,
      IndicatorType.atr,
      IndicatorType.atrPct,
      IndicatorType.adx,
      IndicatorType.bollingerBands,
      IndicatorType.vwap,
      IndicatorType.stochasticK,
      IndicatorType.stochasticD,
    };
    if (indicatorsNeedPeriod.contains(rule.indicator)) {
      if (rule.mainPeriod == null || (rule.mainPeriod ?? 0) <= 0) {
        errors.add(l10n.sbPeriodMustBeSetGtZero);
      }
    }
    if (rule.isNumberValue) {
      if (rule.numberValue == null) {
        errors.add(l10n.sbErrorValueMustBeSet);
      }
      // Strict bounds for RSI numeric thresholds
      if (rule.indicator == IndicatorType.rsi && rule.numberValue != null) {
        if (rule.numberValue! < 0 || rule.numberValue! > 100) {
          errors.add(l10n.sbErrorRsiBetween0And100);
        }
      }
      // Bounds for ADX numeric thresholds (0–100)
      if (rule.indicator == IndicatorType.adx && rule.numberValue != null) {
        if (rule.numberValue! < 0 || rule.numberValue! > 100) {
          errors.add(l10n.sbErrorAdxBetween0And100);
        }
      }
    } else {
      if (rule.compareIndicator == null) {
        errors.add(l10n.sbErrorPickComparisonIndicator);
      }
      if (rule.period == null || (rule.period ?? 0) <= 0) {
        errors.add(l10n.sbPeriodMustBeSetGtZero);
      }
    }

    // Operator-specific validation
    if (rule.operator == ComparisonOperator.crossAbove ||
        rule.operator == ComparisonOperator.crossBelow) {
      // Cross operators boleh membandingkan terhadap indikator atau ambang angka (mis. zero-line).
      // Cross against Bollinger Bands uses lower band; ensure period present (checked above)
      // Additional semantic checks can be added as needed.
    }
    return errors;
  }

  List<String> getRuleErrorsFor(int index, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    return _getRuleFatalErrors(rule);
  }

  List<String> getAllFatalErrors() {
    final errors = <String>[];
    for (final r in entryRules) {
      errors.addAll(_getRuleFatalErrors(r).map((e) => 'Entry: $e'));
    }
    for (final r in exitRules) {
      errors.addAll(_getRuleFatalErrors(r).map((e) => 'Exit: $e'));
    }
    return errors;
  }

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

    // Load recently applied templates from prefs
    try {
      final s = await _prefs.getString('recent_templates');
      if (s != null && s.isNotEmpty) {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          recentTemplateKeys = decoded.whereType<String>().toList();
        }
      }
    } catch (_) {
      // Non-critical
    }

    // Load persisted UI state for template picker
    try {
      final catsStr = await _prefs.getString('template_selected_categories');
      if (catsStr != null && catsStr.isNotEmpty) {
        final decoded = jsonDecode(catsStr);
        if (decoded is List) {
          selectedTemplateCategories = decoded.whereType<String>().toList();
        }
      }
    } catch (_) {
      // Non-critical
    }
    try {
      final qStr = await _prefs.getString('template_search_query');
      if (qStr != null) {
        selectedTemplateQuery = qStr;
      }
    } catch (_) {
      // Non-critical
    }

    // Ensure available data is loaded early for selection convenience
    try {
      loadAvailableData();
    } catch (_) {}

    // Subscribe to market data events for realtime updates
    _marketDataSub = _storageService.marketDataEvents.listen((event) async {
      loadAvailableData();
      notifyListeners();
    });

    // Auto-apply template if onboarding provided a pending key
    try {
      final pendingKey =
          await _prefs.getString('onboarding.pending_template_key');
      if (pendingKey != null && pendingKey.isNotEmpty) {
        applyTemplate(pendingKey);
        // Clear the pending key to avoid re-applying
        await _prefs.setString('onboarding.pending_template_key', '');
        _snackbarService.showSnackbar(
          message: 'Template applied: $pendingKey',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (_) {
      // Non-critical
    }

    // Auto-select data if onboarding provided a pending data id
    try {
      final pendingDataId =
          await _prefs.getString('onboarding.pending_data_id');
      if (pendingDataId != null && pendingDataId.isNotEmpty) {
        if (availableData.any((d) => d.id == pendingDataId)) {
          setSelectedData(pendingDataId);
          _snackbarService.showSnackbar(
            message: 'Data sample selected: $pendingDataId',
            duration: const Duration(seconds: 2),
          );
        }
        // Clear pending regardless
        await _prefs.setString('onboarding.pending_data_id', '');
      }
    } catch (_) {
      // Non-critical
    }

    setBusy(false);
  }

  // Refresh implementation for consistency
  @override
  Future<void> refresh() async {
    loadAvailableData();
    notifyListeners();
  }

  // Subscriptions
  StreamSubscription? _marketDataSub;

  // Note: dispose handled later in file; ensure subscription is cancelled there

  void clearRecentTemplates() {
    recentTemplateKeys = [];
    // Persist asynchronously
    _prefs.setString('recent_templates', jsonEncode(recentTemplateKeys));
    notifyListeners();
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
        mainPeriod: rule.period,
        logicalOperator: rule.logicalOperator,
        timeframe: rule.timeframe,
      ),
      indicator: (type, period, anchorMode, anchorDate) => RuleBuilder(
        indicator: rule.indicator,
        operator: rule.operator,
        isNumberValue: false,
        compareIndicator: type,
        period: period,
        mainPeriod: rule.period,
        logicalOperator: rule.logicalOperator,
        timeframe: rule.timeframe,
        anchorMode: anchorMode,
        anchorDate: anchorDate,
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

    // If using cross operators, force value type to Indicator and set safe defaults
    if (operator == ComparisonOperator.crossAbove ||
        operator == ComparisonOperator.crossBelow) {
      if (!rule.isNumberValue) {
        // comparing to indicator: set safe defaults
        rule.compareIndicator ??= IndicatorType.sma;
        rule.period ??= 14;
        // keep controllers in sync
        rule.periodController.text = (rule.period ?? 14).toString();
      }
    }

    // For rising/falling, no comparison value needed; normalize to number 0
    if (operator == ComparisonOperator.rising ||
        operator == ComparisonOperator.falling) {
      rule.isNumberValue = true;
      rule.numberValue = 0;
      rule.numberController.text = '0';
      rule.compareIndicator = null;
      rule.period = null;
      rule.periodController.text = '';
    }

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

  void updateRuleAnchorMode(int index, AnchorMode? mode, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.anchorMode = mode;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleAnchorDate(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    // Accept empty to clear
    if (value.trim().isEmpty) {
      rule.anchorDate = null;
    } else {
      // Try ISO first, then YYYY-MM-DD
      DateTime? dt = DateTime.tryParse(value.trim());
      if (dt == null) {
        // Fallback: add T00:00:00Z to date-only strings
        final v = value.trim();
        final isDateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(v);
        if (isDateOnly) {
          dt = DateTime.tryParse('${v}T00:00:00');
        }
      }
      rule.anchorDate = dt;
    }
    _scheduleAutosave();
  }

  void updateRulePeriod(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.period = int.tryParse(value);
    _scheduleAutosave();
  }

  void updateRuleMainPeriod(int index, String value, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.mainPeriod = int.tryParse(value);
    _scheduleAutosave();
  }

  void updateRuleLogicalOperator(
      int index, LogicalOperator? operator, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.logicalOperator = operator;
    notifyListeners();
    _scheduleAutosave();
  }

  void updateRuleTimeframe(int index, String? tf, bool isEntry) {
    final rule = isEntry ? entryRules[index] : exitRules[index];
    rule.timeframe = tf;
    notifyListeners();
    _scheduleAutosave();
  }

  Future<void> saveStrategy(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final fatalErrors = getAllFatalErrors();
    if (!canSave || fatalErrors.isNotEmpty) {
      _snackbarService.showSnackbar(
        message: fatalErrors.isNotEmpty
            ? 'Fix errors before saving:\n• ${fatalErrors.join('\n• ')}'
            : 'Please fill required fields',
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Use non-blocking saving state to keep context visible
    isSaving = true;
    notifyListeners();

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

      _snackbarService.showSnackbar(
        message: isEditing ? loc.sbStrategyUpdated : loc.sbStrategySaved,
        duration: const Duration(seconds: 2),
      );
      // After save: if editing, navigate back; if creating, reset form
      if (isEditing) {
        await Future.delayed(const Duration(seconds: 1));
        _navigationService.back();
      } else {
        resetForm();
        _snackbarService.showSnackbar(
          message: loc.sbFormResetReady,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      debugPrint('Error saving strategy: $e');
      showErrorWithRetry(
        title: 'Failed to save strategy',
        message: e.toString(),
        onRetry: () => saveStrategy(context),
      );
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  StrategyRule _builderToStrategyRule(RuleBuilder builder) {
    final value = builder.isNumberValue
        ? ConditionValue.number(builder.numberValue ?? 0)
        : ConditionValue.indicator(
            type: builder.compareIndicator ?? IndicatorType.sma,
            period: builder.period,
            anchorMode: builder.anchorMode,
            anchorDate: builder.anchorDate,
          );

    return StrategyRule(
      indicator: builder.indicator,
      operator: builder.operator,
      value: value,
      period: builder.mainPeriod,
      logicalOperator: builder.logicalOperator,
      timeframe: builder.timeframe,
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
    if (availableData.isNotEmpty) {
      // Restore persisted selection asynchronously if available
      try {
        _prefs.getString('selected_preview_data_id').then((persisted) {
          if (persisted != null &&
              availableData.any((d) => d.id == persisted)) {
            selectedDataId = persisted;
          } else {
            selectedDataId = availableData.first.id;
          }
          notifyListeners();
        }).catchError((_) {
          // Fallback to first item on error
          selectedDataId = availableData.first.id;
          notifyListeners();
        });
      } catch (_) {
        // Defensive fallback
        selectedDataId = availableData.first.id;
        notifyListeners();
      }
    }
  }

  /// Set selected market data for preview
  void setSelectedData(String? dataId) {
    selectedDataId = dataId;
    notifyListeners();
    _scheduleAutosave();
    // Persist selection for convenience across sessions
    try {
      if (dataId == null) {
        _prefs.remove('selected_preview_data_id');
      } else {
        _prefs.setString('selected_preview_data_id', dataId);
      }
    } catch (_) {
      // Non-critical
    }
  }

  /// Compute ATR% percentiles (P25, P50, P75, P90) for selected data
  /// Returns percentages (0-100 scale) ready for display
  Future<List<double>> getAtrPctPercentiles(
      int period, String? timeframe) async {
    if (selectedDataId == null) return [];
    final marketData = _dataManager.getData(selectedDataId!);
    if (marketData == null) return [];
    final baseTf = marketData.timeframe;
    final tf = (timeframe == null || timeframe.isEmpty) ? baseTf : timeframe;
    final cacheKey =
        '$tf:$period:${marketData.id}:${marketData.candles.length}';
    final cached = _atrPctPercentilesCache[cacheKey];
    if (cached != null && cached.isNotEmpty) return cached;

    final candles = tf == baseTf
        ? marketData.candles
        : resampleCandlesToTimeframe(marketData.candles, tf);
    if (candles.length < period + 10) return [];
    final series = _indicatorService.calculateATRPct(candles, period);
    final values = <double>[];
    for (final v in series) {
      if (v != null && v.isFinite) {
        values.add(v * 100.0); // convert to percent
      }
    }
    if (values.length < 20) return [];
    values.sort();
    double p(double q) {
      final idx = ((q / 100.0) * (values.length - 1)).round();
      return values[idx];
    }

    final result = [p(25), p(50), p(75), p(90)];
    _atrPctPercentilesCache[cacheKey] = result;
    return result;
  }

  /// Run quick backtest preview without saving strategy
  Future<void> quickPreviewBacktest() async {
    final fatalErrors = getAllFatalErrors();
    if (!canSave || fatalErrors.isNotEmpty) {
      _snackbarService.showSnackbar(
        message: fatalErrors.isNotEmpty
            ? 'Fix errors before running:\n• ${fatalErrors.join('\n• ')}'
            : 'Please fill required fields before running',
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
      // Capture per‑TF stats for preview rendering
      previewTfStats = _backtestEngine.lastTfStats;

      // Show quick summary
      _snackbarService.showSnackbar(
        message: 'Preview complete! Check results below.',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error running preview backtest: $e');
      showErrorWithRetry(
        title: 'Preview backtest failed',
        message: e.toString(),
        onRetry: () => quickPreviewBacktest(),
      );
      previewResult = null;
    } finally {
      isRunningPreview = false;
      notifyListeners();
    }
  }

  /// Reset preview state
  void resetPreview() {
    previewResult = null;
    previewTfStats = {};
    isRunningPreview = false;
    notifyListeners();
  }

  /// Navigate to full backtest result view with current preview result
  void viewFullResults() {
    if (previewResult == null) return;

    _navigationService.navigateToBacktestResultView(result: previewResult!);
  }

  /// Show short builder tips via notice sheet
  Future<void> showBuilderTips() async {
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title:
          AppLocalizations.of(_navigationService.navigatorKey!.currentContext!)!
              .sbBuilderTips,
      description:
          '• Use Template for quick run.\n• Adjust period indikator based on timeframe.\n• Anchored VWAP: set Anchor Mode & date.\n• Check Preview on AppBar for quick test.\n• Autosave active: save drafts to prevent data loss.',
      barrierDismissible: true,
      isScrollControlled: false,
    );
  }

  /// Progressive tour: step-by-step coach marks via notice sheets
  Future<void> startBuilderTour() async {
    // Step 1: Entry vs Exit rules
    var resp = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: 'Step 1: Entry vs Exit Rules',
      description:
          'Use the left column for ENTRY (entry signal) and the right column for EXIT (exit position). You can add/remove rules and compose logic with AND/OR.',
      mainButtonTitle: 'Next',
      secondaryButtonTitle: 'Close',
      barrierDismissible: true,
      isScrollControlled: false,
    );
    if (resp == null) return;

    // Step 2: Period di kiri vs Period di kanan
    resp = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: 'Step 2: Main Period vs Comparison Period',
      description:
          'Field "Main Period" sets the main indicator period (left column). Field "Period" in the comparison section (right column) will only appear if you are comparing another indicator. Adjust the period to match the timeframe for accurate results.',
      mainButtonTitle: 'Next',
      secondaryButtonTitle: 'Back',
      barrierDismissible: true,
      isScrollControlled: false,
    );
    if (resp == null) return;

    // Step 3: Operator
    resp = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: 'Step 3: Operator & Tips',
      description:
          'The crossAbove/crossBelow operator requires an indicator comparison (e.g. EMA vs EMA). The rising/falling operator does not require a comparison; use the default 0 value to detect up/down trends.',
      mainButtonTitle: 'Next',
      secondaryButtonTitle: 'Back',
      barrierDismissible: true,
      isScrollControlled: false,
    );
    if (resp == null) return;

    // Step 4: Anchored VWAP
    await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.notice,
      title: 'Step 4: Anchored VWAP',
      description:
          'When selecting Anchored VWAP, set "Anchor Mode". Mode "Start of Backtest" will align to the start of the backtest period. Mode "Anchor by Date" allows you to specify a date (e.g. 2023-01-01) for a specific anchor.',
      mainButtonTitle: 'Finish',
      secondaryButtonTitle: 'Back',
      barrierDismissible: true,
      isScrollControlled: false,
    );
  }

  @override
  void dispose() {
    _marketDataSub?.cancel();
    _autosaveTimer?.cancel();
    _statusTicker?.cancel();
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
    rule.mainPeriodController.addListener(_scheduleAutosave);
    rule.anchorDateController.addListener(_scheduleAutosave);
  }

  void _scheduleAutosave() {
    if (!autosaveEnabled) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDebounce, () async {
      await _saveDraft();
    });
  }

  void _ensureStatusTicker() {
    _statusTicker?.cancel();
    if (!autosaveEnabled) {
      _statusTicker = null;
      return;
    }
    _statusTicker = Timer.periodic(_statusTickInterval, (_) {
      if (!autosaveEnabled) {
        _statusTicker?.cancel();
        _statusTicker = null;
        return;
      }
      if (isAutoSaving || lastAutosaveAt != null || autosaveStatus.isNotEmpty) {
        notifyListeners();
      }
    });
  }

  void _stopStatusTicker() {
    _statusTicker?.cancel();
    _statusTicker = null;
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
      'entryRules': entryRules
          .map((r) => {
                'indicator': r.indicator.name,
                'operator': r.operator.name,
                'isNumberValue': r.isNumberValue,
                'numberValue': r.numberValue,
                'compareIndicator': r.compareIndicator?.name,
                'period': r.period,
                'mainPeriod': r.mainPeriod,
                'logicalOperator': r.logicalOperator?.name,
                'timeframe': r.timeframe,
                // Anchor config for Anchored VWAP (right side)
                'anchorMode': r.anchorMode?.name,
                'anchorDate': r.anchorDate?.toIso8601String(),
              })
          .toList(),
      'exitRules': exitRules
          .map((r) => {
                'indicator': r.indicator.name,
                'operator': r.operator.name,
                'isNumberValue': r.isNumberValue,
                'numberValue': r.numberValue,
                'compareIndicator': r.compareIndicator?.name,
                'period': r.period,
                'mainPeriod': r.mainPeriod,
                'logicalOperator': r.logicalOperator?.name,
                'timeframe': r.timeframe,
                // Anchor config for Anchored VWAP (right side)
                'anchorMode': r.anchorMode?.name,
                'anchorDate': r.anchorDate?.toIso8601String(),
              })
          .toList(),
    };
  }

  Future<void> _saveDraft() async {
    try {
      isAutoSaving = true;
      autosaveStatus = 'Saving…';
      notifyListeners();

      final draft = _buildDraftJson();
      await _storageService.saveStrategyDraft(
        strategyId: isEditing ? strategyId : null,
        draftJson: draft,
      );

      final now = DateTime.now();
      isAutoSaving = false;
      lastAutosaveAt = now;
      autosaveStatus =
          'Auto-saved ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      hasAutosaveDraft = true;
      notifyListeners();
      _ensureStatusTicker();
    } catch (e) {
      isAutoSaving = false;
      autosaveStatus = 'Autosave failed';
      notifyListeners();
      _snackbarService.showSnackbar(
        message: 'Autosave failed',
        duration: const Duration(seconds: 2),
        mainButtonTitle: 'Retry',
        onMainButtonTapped: () => _saveDraft(),
      );
      debugPrint('Autosave failed: $e');
    }
  }

  void toggleAutosave(bool value) {
    autosaveEnabled = value;
    if (!autosaveEnabled) {
      _autosaveTimer?.cancel();
      _stopStatusTicker();
      isAutoSaving = false;
      autosaveStatus = 'Autosave off';
      _snackbarService.showSnackbar(
        message: 'Autosave disabled',
        duration: const Duration(seconds: 2),
      );
    } else {
      _snackbarService.showSnackbar(
        message: 'Autosave enabled',
        duration: const Duration(seconds: 2),
      );
      _scheduleAutosave();
      _ensureStatusTicker();
    }
    notifyListeners();
  }

  Future<void> discardDraft() async {
    try {
      await _storageService.clearStrategyDraft(
        strategyId: isEditing ? strategyId : null,
      );
      autosaveStatus = '';
      lastAutosaveAt = null;
      hasAutosaveDraft = false;
      _stopStatusTicker();
      _snackbarService.showSnackbar(
        message: 'Draft discarded',
        duration: const Duration(seconds: 2),
      );
      notifyListeners();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to discard draft',
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Public method to retry autosave from the View
  void retryAutosave() {
    _saveDraft();
  }

  Future<void> restoreDraftIfAvailable() async {
    final draft = await _storageService.getStrategyDraft(
      strategyId: isEditing ? strategyId : null,
    );
    if (draft == null) return;

    try {
      hasAutosaveDraft = true;
      _applyDraftMap(draft);
    } catch (e) {
      debugPrint('Failed to apply draft: $e');
    }
  }

  /// Apply a draft/template map to current builder state
  void _applyDraftMap(Map<String, dynamic> draft) {
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
    // Ensure selectedDataId exists in availableData to avoid Dropdown assertion
    if (selectedDataId != null) {
      final exists = availableData.any((d) => d.id == selectedDataId);
      if (!exists) {
        selectedDataId = null;
      }
    }

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
    // Re-attach listeners for autosave
    for (final rule in entryRules) {
      _attachRuleListeners(rule);
    }
    for (final rule in exitRules) {
      _attachRuleListeners(rule);
    }
    notifyListeners();
  }

  /// Export current builder state as JSON (share or clipboard fallback)
  Future<void> exportStrategyJson() async {
    try {
      final map = _buildDraftJson();
      final jsonStr = jsonEncode(map);
      try {
        final share = locator<ShareService>();
        await share.shareText(jsonStr, subject: 'BacktestX Strategy Template');
        _snackbarService.showSnackbar(
          message: 'Template JSON shared',
          duration: const Duration(seconds: 2),
        );
      } catch (_) {
        // Fallback to clipboard
        if (locator.isRegistered<ClipboardService>()) {
          await locator<ClipboardService>().copyText(jsonStr);
        } else {
          await Clipboard.setData(ClipboardData(text: jsonStr));
        }
        _snackbarService.showSnackbar(
          message: 'Template JSON copied to clipboard',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Copy current builder JSON to clipboard explicitly
  Future<void> copyStrategyJson() async {
    try {
      final jsonStr = jsonEncode(_buildDraftJson());
      if (locator.isRegistered<ClipboardService>()) {
        await locator<ClipboardService>().copyText(jsonStr);
      } else {
        await Clipboard.setData(ClipboardData(text: jsonStr));
      }
      _snackbarService.showSnackbar(
        message: 'Template JSON copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Copy JSON failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Save current builder JSON to a .json file (non-web platforms)
  Future<void> saveStrategyJsonToFile() async {
    try {
      if (kIsWeb) {
        throw Exception('Save file not supported on Web');
      }
      final jsonStr = jsonEncode(_buildDraftJson());
      final dir = await getApplicationDocumentsDirectory();
      final baseName = nameController.text.trim().isEmpty
          ? 'strategy_template'
          : nameController.text.trim();
      final filename = FilenameHelper.build([baseName], ext: 'json');
      final path = '${dir.path}/$filename';
      final file = io.File(path);
      await file.writeAsString(jsonStr, flush: true);
      _snackbarService.showSnackbar(
        message: 'File saved: $filename',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Save file failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Import builder state from JSON text
  Future<void> importStrategyJson(String jsonText) async {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is! Map) {
        throw Exception('Invalid JSON format');
      }
      // Convert dynamic map to Map<String, dynamic>
      final draft = Map<String, dynamic>.from(decoded);
      // Validate early to provide friendly error messages
      _validateDraftMap(draft);
      _applyDraftMap(draft);
      _snackbarService.showSnackbar(
        message: 'Template JSON applied',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Import failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Check if builder has content differing from initial defaults to prompt confirmation
  bool get hasUnsavedBuilder {
    final isNameEmpty = nameController.text.trim().isEmpty;
    final isRulesEmpty = entryRules.isEmpty && exitRules.isEmpty;
    final isDataUnset = selectedDataId == null;
    final isDefaults = initialCapitalController.text == '10000' &&
        riskValueController.text == '2.0' &&
        stopLossController.text == '100' &&
        takeProfitController.text == '200' &&
        riskType == RiskType.percentageRisk;
    return !(isNameEmpty && isRulesEmpty && isDataUnset && isDefaults);
  }

  RuleBuilder _mapToRuleBuilder(dynamic m) {
    final map = Map<String, dynamic>.from(m as Map);
    String? _asString(dynamic v) => v is String ? v : v?.toString();
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) {
        final p = int.tryParse(v);
        if (p != null) return p;
        final d = double.tryParse(v);
        return d?.toInt();
      }
      return null;
    }

    double? _toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    final indicatorName = _asString(map['indicator']);
    final operatorName = _asString(map['operator']);
    final isNumberValue =
        map['isNumberValue'] is bool ? map['isNumberValue'] as bool : true;
    final numberValue = _toDouble(map['numberValue']);
    final compareIndicatorName = _asString(map['compareIndicator']);
    final period = _toInt(map['period']);
    final mainPeriod = _toInt(map['mainPeriod']);
    final logicalName = _asString(map['logicalOperator']);
    final timeframe = _asString(map['timeframe']);
    final anchorModeName = _asString(map['anchorMode']);
    final anchorDateStr = _asString(map['anchorDate']);

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
    final anchorMode = anchorModeName != null
        ? AnchorMode.values.firstWhere(
            (e) => e.name == anchorModeName,
            orElse: () => AnchorMode.startOfBacktest,
          )
        : null;
    final anchorDate =
        anchorDateStr != null ? DateTime.tryParse(anchorDateStr) : null;

    return RuleBuilder(
      indicator: indicator,
      operator: operator,
      isNumberValue: isNumberValue,
      numberValue: numberValue,
      compareIndicator: compareIndicator,
      period: period,
      mainPeriod: mainPeriod,
      logicalOperator: logicalOp,
      timeframe: timeframe,
      anchorMode: anchorMode,
      anchorDate: anchorDate,
    );
  }

  void _validateDraftMap(Map<String, dynamic> draft) {
    // Validate risk type
    final rtName = draft['riskType'];
    if (rtName is String) {
      final ok = RiskType.values.any((e) => e.name == rtName);
      if (!ok) {
        throw Exception('Unknown risk type: $rtName');
      }
    }
    // Validate rules arrays
    for (final key in ['entryRules', 'exitRules']) {
      final v = draft[key];
      if (v == null) continue;
      if (v is! List) {
        throw Exception('$key must be an array');
      }
      for (final item in v) {
        if (item is! Map) {
          throw Exception('Item $key must be an object');
        }
        final m = Map<String, dynamic>.from(item);
        final ind = m['indicator'];
        final op = m['operator'];
        if (ind is String) {
          final ok = IndicatorType.values.any((e) => e.name == ind);
          if (!ok) throw Exception('Unknown indicator: $ind');
        }
        if (op is String) {
          final ok = ComparisonOperator.values.any((e) => e.name == op);
          if (!ok) throw Exception('Unknown operator: $op');
        }
      }
    }
  }
}
