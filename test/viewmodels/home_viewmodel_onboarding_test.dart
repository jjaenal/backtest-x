import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.bottomsheets.dart';
import 'package:backtestx/services/prefs_service.dart';
import 'package:backtestx/ui/views/home/home_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('HomeViewModel - Onboarding gating & persistence', () {
    setUp(() {
      // Ensure test bindings and a deterministic path_provider
      TestWidgetsFlutterBinding.ensureInitialized();
      mockPathProviderForTests();
    });

    tearDown(() => locator.reset());

    test('showOnboarding marks completion when confirmed', () async {
      // Arrange: BottomSheet returns confirmed: true
      getAndRegisterBottomSheetService<void>(
        showCustomSheetResponse: SheetResponse(confirmed: true),
      );
      registerServices();

      final vm = HomeViewModel();

      // Act
      // Guard against exceptions from async work
      await expectLater(vm.showOnboarding(), completes);

      // Assert: variant used and preference persisted
      final sheet = locator<BottomSheetService>() as MockBottomSheetService;
      verify(
        sheet.showCustomSheet<void, void>(
          variant: BottomSheetType.onboarding,
          barrierDismissible: anyNamed('barrierDismissible'),
          isScrollControlled: anyNamed('isScrollControlled'),
        ),
      ).called(1);

      final prefs = PrefsService();
      final done = await prefs.getString('onboarding.completed');
      expect(done, 'true');
    });

    test('showOnboarding does not mark completion when dismissed', () async {
      // Arrange: BottomSheet returns confirmed: false
      getAndRegisterBottomSheetService<void>(
        showCustomSheetResponse: SheetResponse(confirmed: false),
      );
      registerServices();

      final vm = HomeViewModel();

      // Act
      // Guard against exceptions from async work
      await expectLater(vm.showOnboarding(), completes);

      // Assert: preference remains unset
      final prefs = PrefsService();
      final done = await prefs.getString('onboarding.completed');
      expect(done, isNull);
    });
  });
}
