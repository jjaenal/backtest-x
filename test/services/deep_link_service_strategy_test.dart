import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/deep_link_service.dart';

void main() {
  group('DeepLinkService Strategy Links', () {
    test('buildStrategyLink uses hash routing when enabled', () {
      final svc = DeepLinkService(
        baseUrlOverride: 'https://example.com/app',
        useHashRoutingOverride: true,
      );

      final url = svc.buildStrategyLink(strategyId: 'strat 123');
      expect(
        url,
        'https://example.com/app/#/strategy-builder-view?strategyId=strat%20123',
      );
    });

    test('buildStrategyLink uses path routing when disabled', () {
      final svc = DeepLinkService(
        baseUrlOverride: 'https://example.com/app',
        useHashRoutingOverride: false,
      );

      final url = svc.buildStrategyLink(strategyId: 'ABC/xyz');
      expect(
        url,
        'https://example.com/app/strategy-builder-view?strategyId=ABC%2Fxyz',
      );
    });
  });
}
