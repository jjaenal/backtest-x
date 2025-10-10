import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('PatternScannerViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
    test('Placeholder runs', () {
      expect(true, isTrue);
    });
  });
}
