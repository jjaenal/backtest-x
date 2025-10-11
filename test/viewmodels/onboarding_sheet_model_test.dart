import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/ui/bottom_sheets/onboarding/onboarding_sheet_model.dart';

void main() {
  group('OnboardingSheetModel - Step navigation', () {
    test('initial step is 0', () {
      final model = OnboardingSheetModel();
      expect(model.step, 0);
    });

    test('next increments until upper bound 3', () {
      final model = OnboardingSheetModel();
      for (var i = 0; i < 10; i++) {
        model.next();
      }
      expect(model.step, 3);
    });

    test('back decrements until lower bound 0', () {
      final model = OnboardingSheetModel();
      // Move forward a few steps first
      for (var i = 0; i < 3; i++) {
        model.next();
      }
      for (var i = 0; i < 10; i++) {
        model.back();
      }
      expect(model.step, 0);
    });
  });
}
