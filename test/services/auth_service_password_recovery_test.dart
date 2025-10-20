import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/auth_service.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

class TestAuthService extends AuthService {
  final _controller = StreamController<AuthState>.broadcast();

  @override
  Stream<AuthState> get authState => _controller.stream;

  void emit(AuthChangeEvent event) {
    _controller.add(AuthState(event, null));
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('AuthService password recovery listener', () {
    late TestAuthService service;
    late MockDialogService dialog;
    late MockSnackbarService snackbar;

    setUp(() {
      registerServices();
      service = TestAuthService();
      // Replace default fake with our testable service
      locator.unregister<AuthService>();
      locator.registerSingleton<AuthService>(service);

      dialog = locator<DialogService>() as MockDialogService;
      snackbar = locator<SnackbarService>() as MockSnackbarService;

      // Confirm the dialog so success branch executes
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
      service.dispose();
      locator.reset();
    });

    test('shows change password dialog on passwordRecovery', () async {
      service.setupGlobalPasswordRecoveryListener();
      service.emit(AuthChangeEvent.passwordRecovery);

      await Future<void>.delayed(const Duration(milliseconds: 20));

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
    });

    test('ignores non-recovery events', () async {
      service.setupGlobalPasswordRecoveryListener();
      service.emit(AuthChangeEvent.tokenRefreshed);

      await Future<void>.delayed(const Duration(milliseconds: 20));

      verifyNever(
        dialog.showCustomDialog(
          variant: anyNamed('variant'),
          title: anyNamed('title'),
          description: anyNamed('description'),
          barrierDismissible: anyNamed('barrierDismissible'),
        ),
      );
    });
  });
}
