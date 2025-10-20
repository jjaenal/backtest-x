import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/services/auth_service.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Verify mobile email verification handler reacts correctly to AuthChangeEvent.userUpdated
void main() {
  late MockNavigationService nav;
  late MockSnackbarService snackbar;
  late TestAuthService service;

  setUp(() {
    registerServices();
    // Override NavigationService and SnackbarService with mocks for verification
    nav = getAndRegisterNavigationService();
    snackbar = getAndRegisterSnackbarService();

    // Replace AuthService with a controllable test instance
    locator.unregister<AuthService>();
    service = TestAuthService();
    locator.registerSingleton<AuthService>(service);

    // Initialize global listener (mobile only pathway)
    service.setupGlobalPasswordRecoveryListener();
  });

  tearDown(() {
    service.dispose();
    locator.reset();
  });

  test('navigates to Home and shows success when user is logged in', () async {
    service.overrideIsLoggedIn = true;

    service.emit(AuthChangeEvent.userUpdated);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // Verify snackbar shown
    verify(
      snackbar.showSnackbar(
        message:
            argThat(contains('Email berhasil terverifikasi'), named: 'message'),
        duration: anyNamed('duration'),
        title: anyNamed('title'),
      ),
    ).called(1);

    // Verify navigation to Home
    verify(nav.replaceWith(Routes.homeView)).called(1);
  });

  test('navigates to Login and shows prompt when user is not logged in',
      () async {
    service.overrideIsLoggedIn = false;

    service.emit(AuthChangeEvent.userUpdated);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // Verify snackbar shown with prompt to login
    verify(
      snackbar.showSnackbar(
        message: argThat(contains('Silakan login'), named: 'message'),
        duration: anyNamed('duration'),
        title: anyNamed('title'),
      ),
    ).called(1);

    // Verify navigation to Login
    verify(nav.replaceWith(Routes.loginView)).called(1);
  });
}

class TestAuthService extends AuthService {
  final _controller = StreamController<AuthState>.broadcast();
  bool overrideIsLoggedIn = false;

  @override
  Stream<AuthState> get authState => _controller.stream;

  @override
  bool get isLoggedIn => overrideIsLoggedIn;

  void emit(AuthChangeEvent event) {
    _controller.add(AuthState(event, null));
  }

  void dispose() {
    _controller.close();
  }
}
