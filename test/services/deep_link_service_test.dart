import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/deep_link_service.dart';

void main() {
  group('DeepLinkService', () {
    test('buildBacktestResultLink uses hash routing when enabled', () {
      final svc = DeepLinkService(
        baseUrlOverride: 'https://example.com',
        useHashRoutingOverride: true,
      );
      final link = svc.buildBacktestResultLink(resultId: 'abc123');
      expect(
          link, equals('https://example.com/#/backtest-result-view?id=abc123'));
    });

    test('buildBacktestResultLink encodes special characters in id', () {
      final svc = DeepLinkService(
        baseUrlOverride: 'https://example.com',
        useHashRoutingOverride: false,
      );
      final link = svc.buildBacktestResultLink(resultId: 'id with space/+/');
      expect(
        link,
        equals(
            'https://example.com/backtest-result-view?id=id%20with%20space%2F%2B%2F'),
      );
    });
  });
}
