import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_viewmodel.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('Strategy Builder E2E - Anchor byDate', () {
    setUp(() {
      silenceInfoLogsForTests();
      registerServices();
    });

    testWidgets('serialize/deserialize preserves AnchorMode.byDate and date',
        (tester) async {
      String? exportedJson;
      // Register and stub ShareService to capture exported JSON
      final shareService = getAndRegisterShareService();
      when(shareService.shareText(any, subject: anyNamed('subject')))
          .thenAnswer((inv) async {
        exportedJson = inv.positionalArguments[0] as String;
      });

      final vm = StrategyBuilderViewModel(null);
      vm.autosaveEnabled = false; // avoid autosave side-effects in test

      // Setup a rule using Anchored VWAP with byDate
      vm.addEntryRule();
      vm.updateRuleCompareIndicator(0, IndicatorType.anchoredVwap, true);
      vm.updateRuleAnchorMode(0, AnchorMode.byDate, true);
      vm.updateRuleAnchorDate(0, '2024-01-15', true);

      // Serialize to JSON via export (ShareService)
      await vm.exportStrategyJson();
      expect(exportedJson, isNotNull);

      final decoded = jsonDecode(exportedJson!);
      expect(decoded, isA<Map<String, dynamic>>());

      final entryRules = (decoded['entryRules'] as List);
      expect(entryRules.length, 1);
      final r0 = Map<String, dynamic>.from(entryRules.first as Map);
      expect(r0['anchorMode'], 'byDate');
      expect(r0['anchorDate'], isNotNull);
      expect((r0['anchorDate'] as String).startsWith('2024-01-15T00:00:00'),
          isTrue);

      // Deserialize back and verify state restored
      await vm.importStrategyJson(exportedJson!);
      expect(vm.entryRules.length, 1);
      final rule = vm.entryRules.first;
      expect(rule.anchorMode, AnchorMode.byDate);
      expect(rule.anchorDate, isNotNull);
      expect(
          rule.anchorDate!.toIso8601String().startsWith('2024-01-15T00:00:00'),
          isTrue);
    });
  });
}
