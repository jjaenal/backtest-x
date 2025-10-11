import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_viewmodel.dart';
import 'package:backtestx/models/strategy.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('StrategyBuilderViewModel - applyTemplate', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('Applies RSI mean reversion template fields and rules', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('mean_reversion_rsi');

      expect(vm.nameController.text, 'Mean Reversion — RSI');
      expect(vm.initialCapitalController.text, '10000.0');
      expect(vm.riskType, RiskType.percentageRisk);
      expect(vm.riskValueController.text, '1.0');
      expect(vm.stopLossController.text, '100.0');
      expect(vm.takeProfitController.text, '150.0');

      expect(vm.entryRules.length, 1);
      final er = vm.entryRules.first;
      expect(er.indicator, IndicatorType.rsi);
      expect(er.operator, ComparisonOperator.lessThan);
      expect(er.isNumberValue, isTrue);
      expect(er.numberValue, 30);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.rsi);
      expect(xr.operator, ComparisonOperator.greaterThan);
      expect(xr.isNumberValue, isTrue);
      expect(xr.numberValue, 50);
    });

    test('Applies MACD signal template with cross operator and indicator value',
        () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('macd_signal');

      expect(vm.nameController.text, 'MACD Signal');
      expect(vm.initialCapitalController.text, '10000.0');
      expect(vm.riskType, RiskType.percentageRisk);
      expect(vm.riskValueController.text, '1.5');
      expect(vm.stopLossController.text, '120.0');
      expect(vm.takeProfitController.text, '240.0');

      expect(vm.entryRules.length, 1);
      final er = vm.entryRules.first;
      expect(er.indicator, IndicatorType.macd);
      expect(er.operator, ComparisonOperator.crossAbove);
      expect(er.isNumberValue, isFalse);
      expect(er.compareIndicator, IndicatorType.macdSignal);
      // period may be carried; ensure it's set from template
      expect(er.period, 9);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.macd);
      expect(xr.operator, ComparisonOperator.crossBelow);
      expect(xr.isNumberValue, isFalse);
      expect(xr.compareIndicator, IndicatorType.macdSignal);
      expect(xr.period, 9);
    });

    test('Applies Trend EMA Cross template correctly', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('trend_ema_cross');

      expect(vm.nameController.text, 'Trend Follow — EMA(20/50) Cross');
      expect(vm.entryRules.length, 1);
      final er = vm.entryRules.first;
      expect(er.indicator, IndicatorType.ema);
      expect(er.operator, ComparisonOperator.crossAbove);
      expect(er.isNumberValue, isFalse);
      expect(er.compareIndicator, IndicatorType.ema);
      expect(er.period, 50);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.ema);
      expect(xr.operator, ComparisonOperator.crossBelow);
      expect(xr.isNumberValue, isFalse);
      expect(xr.compareIndicator, IndicatorType.ema);
      expect(xr.period, 50);
    });

    test('Applies Momentum RSI & MACD template correctly', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('momentum_rsi_macd');

      expect(vm.nameController.text, 'Momentum — RSI & MACD');
      expect(vm.entryRules.length, 2);
      final er0 = vm.entryRules[0];
      expect(er0.indicator, IndicatorType.rsi);
      expect(er0.operator, ComparisonOperator.greaterThan);
      expect(er0.isNumberValue, isTrue);
      expect(er0.numberValue, 55);
      expect(er0.logicalOperator, LogicalOperator.and);

      final er1 = vm.entryRules[1];
      expect(er1.indicator, IndicatorType.macd);
      expect(er1.operator, ComparisonOperator.crossAbove);
      expect(er1.isNumberValue, isFalse);
      expect(er1.compareIndicator, IndicatorType.macdSignal);
      expect(er1.period, 9);

      expect(vm.exitRules.length, 2);
      final xr0 = vm.exitRules[0];
      expect(xr0.indicator, IndicatorType.rsi);
      expect(xr0.operator, ComparisonOperator.lessThan);
      expect(xr0.isNumberValue, isTrue);
      expect(xr0.numberValue, 45);
      expect(xr0.logicalOperator, LogicalOperator.or);

      final xr1 = vm.exitRules[1];
      expect(xr1.indicator, IndicatorType.macd);
      expect(xr1.operator, ComparisonOperator.crossBelow);
      expect(xr1.isNumberValue, isFalse);
      expect(xr1.compareIndicator, IndicatorType.macdSignal);
      expect(xr1.period, 9);
    });

    test('Applies Mean Reversion BB + RSI template correctly', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('mean_reversion_bb_rsi');

      expect(vm.nameController.text, 'Mean Reversion — BB Lower + RSI');
      expect(vm.entryRules.length, 2);
      final er0 = vm.entryRules[0];
      expect(er0.indicator, IndicatorType.close);
      expect(er0.operator, ComparisonOperator.lessThan);
      expect(er0.isNumberValue, isFalse);
      expect(er0.compareIndicator, IndicatorType.bollingerBands);
      expect(er0.period, 20);
      expect(er0.logicalOperator, LogicalOperator.and);

      final er1 = vm.entryRules[1];
      expect(er1.indicator, IndicatorType.rsi);
      expect(er1.operator, ComparisonOperator.lessThan);
      expect(er1.isNumberValue, isTrue);
      expect(er1.numberValue, 35);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.rsi);
      expect(xr.operator, ComparisonOperator.greaterThan);
      expect(xr.isNumberValue, isTrue);
      expect(xr.numberValue, 50);
    });

    test('Applies EMA vs SMA Cross template correctly', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('ema_vs_sma_cross');

      expect(vm.nameController.text, 'EMA vs SMA — Cross');
      expect(vm.entryRules.length, 1);
      final er = vm.entryRules.first;
      expect(er.indicator, IndicatorType.ema);
      expect(er.operator, ComparisonOperator.crossAbove);
      expect(er.isNumberValue, isFalse);
      expect(er.compareIndicator, IndicatorType.sma);
      expect(er.period, 50);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.ema);
      expect(xr.operator, ComparisonOperator.crossBelow);
      expect(xr.isNumberValue, isFalse);
      expect(xr.compareIndicator, IndicatorType.sma);
      expect(xr.period, 50);
    });

    test('Applies EMA Ribbon template correctly', () {
      final vm = StrategyBuilderViewModel(null);

      vm.applyTemplate('ema_ribbon_stack');

      expect(
          vm.nameController.text, 'Trend Follow — EMA Ribbon (8/13/21/34/55)');
      expect(vm.entryRules.length, 5);

      final er0 = vm.entryRules[0];
      expect(er0.indicator, IndicatorType.ema);
      expect(er0.operator, ComparisonOperator.greaterThan);
      expect(er0.isNumberValue, isFalse);
      expect(er0.compareIndicator, IndicatorType.ema);
      expect(er0.mainPeriod, 8);
      expect(er0.period, 13);
      expect(er0.logicalOperator, LogicalOperator.and);

      final er1 = vm.entryRules[1];
      expect(er1.indicator, IndicatorType.ema);
      expect(er1.operator, ComparisonOperator.greaterThan);
      expect(er1.isNumberValue, isFalse);
      expect(er1.compareIndicator, IndicatorType.ema);
      expect(er1.mainPeriod, 13);
      expect(er1.period, 21);
      expect(er1.logicalOperator, LogicalOperator.and);

      final er2 = vm.entryRules[2];
      expect(er2.indicator, IndicatorType.ema);
      expect(er2.operator, ComparisonOperator.greaterThan);
      expect(er2.isNumberValue, isFalse);
      expect(er2.compareIndicator, IndicatorType.ema);
      expect(er2.mainPeriod, 21);
      expect(er2.period, 34);
      expect(er2.logicalOperator, LogicalOperator.and);

      final er3 = vm.entryRules[3];
      expect(er3.indicator, IndicatorType.ema);
      expect(er3.operator, ComparisonOperator.greaterThan);
      expect(er3.isNumberValue, isFalse);
      expect(er3.compareIndicator, IndicatorType.ema);
      expect(er3.mainPeriod, 34);
      expect(er3.period, 55);
      expect(er3.logicalOperator, LogicalOperator.and);

      final er4 = vm.entryRules[4];
      expect(er4.indicator, IndicatorType.close);
      expect(er4.operator, ComparisonOperator.greaterThan);
      expect(er4.isNumberValue, isFalse);
      expect(er4.compareIndicator, IndicatorType.ema);
      expect(er4.mainPeriod, isNull);
      expect(er4.period, 21);
      expect(er4.logicalOperator, isNull);

      expect(vm.exitRules.length, 1);
      final xr = vm.exitRules.first;
      expect(xr.indicator, IndicatorType.close);
      expect(xr.operator, ComparisonOperator.lessThan);
      expect(xr.isNumberValue, isFalse);
      expect(xr.compareIndicator, IndicatorType.ema);
      expect(xr.mainPeriod, isNull);
      expect(xr.period, 21);
      expect(xr.logicalOperator, isNull);
    });
  });
}
