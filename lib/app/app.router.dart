// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:backtestx/models/trade.dart' as _i14;
import 'package:backtestx/ui/views/backtest_result/backtest_result_view.dart'
    as _i8;
import 'package:backtestx/ui/views/comparison/comparison_view.dart' as _i10;
import 'package:backtestx/ui/views/data_upload/data_upload_view.dart' as _i4;
import 'package:backtestx/ui/views/home/home_view.dart' as _i2;
import 'package:backtestx/ui/views/login/login_view.dart' as _i5;
import 'package:backtestx/ui/views/market_analysis/market_analysis_view.dart'
    as _i11;
import 'package:backtestx/ui/views/pattern_scanner/pattern_scanner_view.dart'
    as _i12;
import 'package:backtestx/ui/views/signup/signup_view.dart' as _i6;
import 'package:backtestx/ui/views/startup/startup_view.dart' as _i3;
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_view.dart'
    as _i7;
import 'package:backtestx/ui/views/workspace/workspace_view.dart' as _i9;
import 'package:flutter/material.dart' as _i13;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i15;

class Routes {
  static const homeView = '/home-view';

  static const startupView = '/startup-view';

  static const dataUploadView = '/data-upload-view';

  static const loginView = '/login-view';

  static const signupView = '/signup-view';

  static const strategyBuilderView = '/strategy-builder-view';

  static const backtestResultView = '/backtest-result-view';

  static const workspaceView = '/workspace-view';

  static const comparisonView = '/comparison-view';

  static const marketAnalysisView = '/market-analysis-view';

  static const patternScannerView = '/pattern-scanner-view';

  static const all = <String>{
    homeView,
    startupView,
    dataUploadView,
    loginView,
    signupView,
    strategyBuilderView,
    backtestResultView,
    workspaceView,
    comparisonView,
    marketAnalysisView,
    patternScannerView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.homeView,
      page: _i2.HomeView,
    ),
    _i1.RouteDef(
      Routes.startupView,
      page: _i3.StartupView,
    ),
    _i1.RouteDef(
      Routes.dataUploadView,
      page: _i4.DataUploadView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i5.LoginView,
    ),
    _i1.RouteDef(
      Routes.signupView,
      page: _i6.SignupView,
    ),
    _i1.RouteDef(
      Routes.strategyBuilderView,
      page: _i7.StrategyBuilderView,
    ),
    _i1.RouteDef(
      Routes.backtestResultView,
      page: _i8.BacktestResultView,
    ),
    _i1.RouteDef(
      Routes.workspaceView,
      page: _i9.WorkspaceView,
    ),
    _i1.RouteDef(
      Routes.comparisonView,
      page: _i10.ComparisonView,
    ),
    _i1.RouteDef(
      Routes.marketAnalysisView,
      page: _i11.MarketAnalysisView,
    ),
    _i1.RouteDef(
      Routes.patternScannerView,
      page: _i12.PatternScannerView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.HomeView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.HomeView(),
        settings: data,
      );
    },
    _i3.StartupView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i3.StartupView(),
        settings: data,
      );
    },
    _i4.DataUploadView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.DataUploadView(),
        settings: data,
      );
    },
    _i5.LoginView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.LoginView(),
        settings: data,
      );
    },
    _i6.SignupView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.SignupView(),
        settings: data,
      );
    },
    _i7.StrategyBuilderView: (data) {
      final args = data.getArgs<StrategyBuilderViewArguments>(
        orElse: () => const StrategyBuilderViewArguments(),
      );
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i7.StrategyBuilderView(key: args.key, strategyId: args.strategyId),
        settings: data,
      );
    },
    _i8.BacktestResultView: (data) {
      final args = data.getArgs<BacktestResultViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i8.BacktestResultView(key: args.key, result: args.result),
        settings: data,
      );
    },
    _i9.WorkspaceView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.WorkspaceView(),
        settings: data,
      );
    },
    _i10.ComparisonView: (data) {
      final args = data.getArgs<ComparisonViewArguments>(nullOk: false);
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i10.ComparisonView(key: args.key, results: args.results),
        settings: data,
      );
    },
    _i11.MarketAnalysisView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i11.MarketAnalysisView(),
        settings: data,
      );
    },
    _i12.PatternScannerView: (data) {
      return _i13.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.PatternScannerView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class StrategyBuilderViewArguments {
  const StrategyBuilderViewArguments({
    this.key,
    this.strategyId,
  });

  final _i13.Key? key;

  final String? strategyId;

  @override
  String toString() {
    return '{"key": "$key", "strategyId": "$strategyId"}';
  }

  @override
  bool operator ==(covariant StrategyBuilderViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.strategyId == strategyId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ strategyId.hashCode;
  }
}

class BacktestResultViewArguments {
  const BacktestResultViewArguments({
    this.key,
    required this.result,
  });

  final _i13.Key? key;

  final _i14.BacktestResult result;

  @override
  String toString() {
    return '{"key": "$key", "result": "$result"}';
  }

  @override
  bool operator ==(covariant BacktestResultViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.result == result;
  }

  @override
  int get hashCode {
    return key.hashCode ^ result.hashCode;
  }
}

class ComparisonViewArguments {
  const ComparisonViewArguments({
    this.key,
    required this.results,
  });

  final _i13.Key? key;

  final List<_i14.BacktestResult> results;

  @override
  String toString() {
    return '{"key": "$key", "results": "$results"}';
  }

  @override
  bool operator ==(covariant ComparisonViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.results == results;
  }

  @override
  int get hashCode {
    return key.hashCode ^ results.hashCode;
  }
}

extension NavigatorStateExtension on _i15.NavigationService {
  Future<dynamic> navigateToHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDataUploadView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dataUploadView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToSignupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.signupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToStrategyBuilderView({
    _i13.Key? key,
    String? strategyId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.strategyBuilderView,
        arguments:
            StrategyBuilderViewArguments(key: key, strategyId: strategyId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToBacktestResultView({
    _i13.Key? key,
    required _i14.BacktestResult result,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.backtestResultView,
        arguments: BacktestResultViewArguments(key: key, result: result),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToWorkspaceView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.workspaceView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToComparisonView({
    _i13.Key? key,
    required List<_i14.BacktestResult> results,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.comparisonView,
        arguments: ComparisonViewArguments(key: key, results: results),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToMarketAnalysisView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.marketAnalysisView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToPatternScannerView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.patternScannerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.homeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDataUploadView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dataUploadView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithLoginView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.loginView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithSignupView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.signupView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStrategyBuilderView({
    _i13.Key? key,
    String? strategyId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.strategyBuilderView,
        arguments:
            StrategyBuilderViewArguments(key: key, strategyId: strategyId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithBacktestResultView({
    _i13.Key? key,
    required _i14.BacktestResult result,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.backtestResultView,
        arguments: BacktestResultViewArguments(key: key, result: result),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithWorkspaceView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.workspaceView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithComparisonView({
    _i13.Key? key,
    required List<_i14.BacktestResult> results,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.comparisonView,
        arguments: ComparisonViewArguments(key: key, results: results),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithMarketAnalysisView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.marketAnalysisView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithPatternScannerView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.patternScannerView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
