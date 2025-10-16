import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class LoginViewModel extends BaseViewModel {
  final _auth = locator<AuthService>();
  final _nav = locator<NavigationService>();

  String email = '';
  String password = '';
  String? errorMessage;
  String? infoMessage;
  String newPassword = '';
  String confirmPassword = '';
  bool obscureLoginPassword = true;

  bool isValidEmail(String value) {
    final emailRegex =
        RegExp(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$");
    return emailRegex.hasMatch(value.trim());
  }

  void toggleObscureLoginPassword() {
    obscureLoginPassword = !obscureLoginPassword;
    notifyListeners();
  }

  Future<void> signInGoogle() async {
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      await _auth.signInWithGoogle();
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

  Future<void> signInEmail() async {
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      if (!isValidEmail(email)) {
        throw Exception('Format email tidak valid.');
      }
      await _auth.signInWithEmail(email: email, password: password);
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

  bool get hasPendingRedirect => _auth.getPostLoginRedirect() != null;

  bool get isRecovery {
    if (!kIsWeb) return false;
    final qp = Uri.base.queryParameters;
    final frag = Uri.base.fragment;
    if (qp['type'] == 'recovery') return true;
    if (frag.contains('type=recovery')) return true;
    return false;
  }

  Future<void> forgotPassword() async {
    if (email.isEmpty) {
      errorMessage = 'Masukkan email dulu untuk reset password.';
      infoMessage = null;
      notifyListeners();
      return;
    }
    if (!isValidEmail(email)) {
      errorMessage = 'Format email tidak valid.';
      infoMessage = null;
      notifyListeners();
      return;
    }
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        redirectTo: kIsWeb ? Uri.base.origin : null,
      );
      infoMessage =
          'Jika email terdaftar, tautan reset password telah dikirim.';
    } catch (e) {
      errorMessage = _friendlyError(e);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> setNewPassword() async {
    if (newPassword.isEmpty || newPassword.length < 6) {
      errorMessage = 'Password baru minimal 6 karakter.';
      infoMessage = null;
      notifyListeners();
      return;
    }
    if (newPassword != confirmPassword) {
      errorMessage = 'Konfirmasi password tidak cocok.';
      infoMessage = null;
      notifyListeners();
      return;
    }
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      await _auth.updatePassword(newPassword: newPassword);
      infoMessage = 'Password berhasil diubah. Kamu bisa login sekarang.';
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

    // Supabase auth exceptions
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

    // String/Exception fallbacks
    final s = e.toString().toLowerCase();
    if (s.contains('format email tidak valid')) {
      return t?.errorInvalidEmail ?? 'Format email tidak valid.';
    }
    if (s.contains('password minimal 6')) {
      return t?.errorPasswordMinSignup ??
          'Password minimal 6 karakter untuk pendaftaran.';
    }

    return t?.errorGeneric ?? 'Terjadi kesalahan. Coba lagi.';
  }
}
