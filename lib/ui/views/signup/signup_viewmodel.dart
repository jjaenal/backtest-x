import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class SignupViewModel extends BaseViewModel {
  final _auth = locator<AuthService>();
  final _nav = locator<NavigationService>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String? errorMessage;
  String? infoMessage;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isValidEmail(String value) {
    final emailRegex =
        RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
    return emailRegex.hasMatch(value.trim());
  }

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword = !obscureConfirmPassword;
    notifyListeners();
  }

  Future<void> signUpEmail() async {
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      if (!isValidEmail(email)) {
        throw Exception('Format email tidak valid.');
      }
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter untuk pendaftaran.');
      }
      if (password != confirmPassword) {
        throw Exception('Konfirmasi password tidak cocok.');
      }
      await _auth.signUpWithEmail(email: email, password: password);
      final redirect = _auth.takePostLoginRedirect();
      if (redirect?.route == Routes.strategyBuilderView) {
        final args = redirect!.arguments as StrategyBuilderViewArguments?;
        _nav.replaceWithStrategyBuilderView(strategyId: args?.strategyId);
      } else {
        _nav.replaceWithHomeView();
      }
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  String _friendlyError(Object e) {
    final ctx = _nav.navigatorKey?.currentContext;
    final t = ctx != null ? AppLocalizations.of(ctx) : null;

    if (e is AuthException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials')) {
        return t?.errorAuthInvalidCredentials ?? 'Email atau password salah.';
      }
      if (msg.contains('user already registered')) {
        return t?.errorAuthEmailRegistered ?? 'Email sudah terdaftar.';
      }
      if (msg.contains('email not confirmed')) {
        return t?.errorAuthEmailNotConfirmed ??
            'Email belum terverifikasi. Cek inbox untuk verifikasi.';
      }
      return t?.errorAuthGeneric ??
          'Terjadi kesalahan saat autentikasi. Coba lagi.';
    }

    final s = e.toString().toLowerCase();
    if (s.contains('format email tidak valid')) {
      return t?.errorInvalidEmail ?? 'Format email tidak valid.';
    }
    if (s.contains('password minimal 6')) {
      return t?.errorPasswordMinSignup ??
          'Password minimal 6 karakter untuk pendaftaran.';
    }
    if (s.contains('konfirmasi password tidak cocok') ||
        s.contains('passwords do not match')) {
      return t?.errorPasswordConfirmMismatch ?? 'Passwords do not match.';
    }

    return t?.errorGeneric ?? 'Terjadi kesalahan. Coba lagi.';
  }
}
