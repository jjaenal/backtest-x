import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/helpers/strategy_templates.dart';
import 'package:backtestx/models/strategy.dart';

void main() {
  group('StrategyTemplates Top MVP', () {
    test('breakout_basic template exists and is valid', () {
      final tpl = StrategyTemplates.all['breakout_basic'];
      expect(tpl, isNotNull);
      expect(tpl!.entryRules.isNotEmpty, isTrue);
      expect(tpl.exitRules.isNotEmpty, isTrue);
      expect(tpl.risk.riskType, RiskType.percentageRisk);
      expect(tpl.risk.riskValue, greaterThan(0));
      expect(tpl.risk.stopLoss, isNotNull);
      expect(tpl.risk.takeProfit, isNotNull);
    });

    test('trend_ema_cross template exists and is valid', () {
      final tpl = StrategyTemplates.all['trend_ema_cross'];
      expect(tpl, isNotNull);
      expect(tpl!.entryRules.isNotEmpty, isTrue);
      expect(tpl.exitRules.isNotEmpty, isTrue);
      expect(tpl.risk.riskType, RiskType.percentageRisk);
      expect(tpl.risk.riskValue, greaterThan(0));
      expect(tpl.risk.stopLoss, isNotNull);
      expect(tpl.risk.takeProfit, isNotNull);
    });

    test('ema_ribbon_stack template exists and is valid', () {
      final tpl = StrategyTemplates.all['ema_ribbon_stack'];
      expect(tpl, isNotNull);
      expect(tpl!.entryRules.isNotEmpty, isTrue);
      expect(tpl.exitRules.isNotEmpty, isTrue);
      expect(tpl.risk.riskType, RiskType.percentageRisk);
      expect(tpl.risk.riskValue, greaterThan(0));
      expect(tpl.risk.stopLoss, isNotNull);
      expect(tpl.risk.takeProfit, isNotNull);
    });
  });
}