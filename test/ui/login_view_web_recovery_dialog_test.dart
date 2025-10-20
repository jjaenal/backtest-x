// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
@TestOn('browser')
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/views/login/login_view.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/deep_link_service.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

class FakeDeepLinkService extends DeepLinkService {
  bool cleared = false;
  @override
  void clearRecoveryMarkersFromUrl() {
    cleared = true;
  }
}

void main() {
  group('LoginView web recovery dialog', () {
    late MockDialogService dialog;
    late MockSnackbarService snackbar;
    late FakeDeepLinkService deepLink;

    setUp(() {
      registerServices();
      // Replace DeepLinkService with a fake to capture clearRecoveryMarkersFromUrl
      deepLink = FakeDeepLinkService();
      locator.unregister<DeepLinkService>();
      locator.registerSingleton<DeepLinkService>(deepLink);

      dialog = locator<DialogService>() as MockDialogService;
      snackbar = locator<SnackbarService>() as MockSnackbarService;

      // Stub dialog to confirm to trigger success branch
      when(
        dialog.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          barrierDismissible: anyNamed('barrierDismissible'),
        ),
      ).thenAnswer((_) async => DialogResponse(confirmed: true));
    });

    tearDown(() {
      locator.reset();
    });

    testWidgets(
        'shows change-password dialog and clears URL when type=recovery',
        (tester) async {
      // Simulate ?type=recovery in URL on web
      html.window.history.pushState(null, '', '/?type=recovery');
      // Also set fragment to ensure detection via Uri.base.fragment
      html.window.location.hash = 'type=recovery';

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: StackedService.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('id')],
          home: const LoginView(),
        ),
      );

      // Allow queued microtask in onViewModelReady to run
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Verify dialog and snackbar shown
      verify(
        dialog.showCustomDialog(
          variant: DialogType.changePassword,
          title: anyNamed('title'),
          description: anyNamed('description'),
          barrierDismissible: anyNamed('barrierDismissible'),
        ),
      ).called(1);

      verify(
        snackbar.showSnackbar(
          message: anyNamed('message'),
          duration: anyNamed('duration'),
          title: anyNamed('title'),
        ),
      ).called(1);

      // Confirm URL cleanup was requested
      expect(deepLink.cleared, isTrue);
    });
  });
}
