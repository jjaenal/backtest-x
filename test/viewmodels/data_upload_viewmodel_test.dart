import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/ui/common/ui_helpers.dart';

import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/ui/views/data_upload/data_upload_viewmodel.dart';

import '../helpers/test_helpers.dart';

// Local mock for SnackbarService to avoid UI calls in unit tests
class MockSnackbarService extends Mock implements SnackbarService {}

void main() {
  group('DataUploadViewModel - Error Handling', () {
    setUp(() {
      // Register base mocks
      registerServices();

      // Override DataParserService with real implementation to trigger actual parsing errors
      if (locator.isRegistered<DataParserService>()) {
        locator.unregister<DataParserService>();
      }
      locator.registerSingleton<DataParserService>(DataParserService());

      // Override SnackbarService with mock to suppress UI interactions
      if (locator.isRegistered<SnackbarService>()) {
        locator.unregister<SnackbarService>();
      }
      locator.registerSingleton<SnackbarService>(MockSnackbarService());
    });

    tearDown(() => locator.reset());

    test('Sets detailed parser error message when CSV parsing fails', () async {
      final vm = DataUploadViewModel();
      final mockSnackbar = locator<SnackbarService>() as MockSnackbarService;

      // Prepare a temporary file to satisfy non-web file path requirement
      final tempFile = await File('${Directory.systemTemp.path}/invalid.csv')
          .writeAsString('date,open,high\n2020-01-01,10,11');
      vm.selectedFile = tempFile;
      vm.selectedTimeframe = 'H1';
      vm.symbolController.text = 'TEST';

      // Ensure method completes without throwing; errors handled internally
      await expectLater(vm.uploadData(), completes);

      expect(vm.parserErrorMessage, isNotEmpty);
      expect(vm.parserErrorMessage, contains('Format CSV tidak valid'));
      expect(vm.isBusy, isFalse);

      // Verify error-styled snackbar is shown with the same message
      verify(
        mockSnackbar.showCustomSnackBar(
          variant: SnackbarType.error,
          title: 'Upload gagal',
          message: vm.parserErrorMessage!,
        ),
      ).called(1);
    });
  });
}
