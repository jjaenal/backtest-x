import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('BacktestEngineServiceTest -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
