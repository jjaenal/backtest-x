import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/services/auth_service.dart';

class AuthGuard extends StackedRouteGuard {
  final _authService = locator<AuthService>();
  final _nav = locator<NavigationService>();

  @override
  Future<void> onNavigation(resolver, router) async {
    if (_authService.isLoggedIn) {
      resolver.next(true);
    } else {
      _nav.navigateTo(Routes.loginView);
      resolver.next(false);
    }
  }
}
