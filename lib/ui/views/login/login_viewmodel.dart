import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'dart:async';
import 'package:meta/meta.dart' show visibleForTesting;

/// ViewModel untuk login, menangani autentikasi, banner verifikasi email, dan cooldown kirim ulang.
class LoginViewModel extends BaseViewModel {
  final _auth = locator<AuthService>();
  final _nav = locator<NavigationService>();
  final _snackbarService = locator<SnackbarService>();

  String email = '';
  String password = '';
  String? errorMessage;
  String? infoMessage;
  String newPassword = '';
  String confirmPassword = '';
  bool obscureLoginPassword = true;
  bool showVerificationBanner = false;
  DateTime? _lastResendAt;
  static const Duration resendCooldown = Duration(seconds: 20);

  /// True jika cooldown kirim ulang verifikasi masih berjalan.
  bool get isResendCooldownActive {
    if (_lastResendAt == null) return false;
    return DateTime.now().difference(_lastResendAt!) < resendCooldown;
  }

  /// Sisa detik cooldown agar UI bisa menampilkan countdown real-time.
  int get resendCooldownRemainingSeconds {
    if (!isResendCooldownActive) return 0;
    final elapsed = DateTime.now().difference(_lastResendAt!).inSeconds;
    final rem = resendCooldown.inSeconds - elapsed;
    return rem > 0 ? rem : 0;
  }

  Timer? _resendCooldownTimer;

  /// Memulai timer periodik 1 detik untuk memicu `notifyListeners()` hingga cooldown selesai.
  void _startResendCooldownTicker() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isResendCooldownActive) {
        timer.cancel();
        _resendCooldownTimer = null;
      }
      notifyListeners();
    });
  }

  /// Menghentikan timer cooldown dan membersihkan referensi untuk mencegah kebocoran.
  void _stopResendCooldownTicker() {
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = null;
  }

  /// Validasi format email dengan regex sederhana.
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
      if (canResendVerification) {
        showVerificationBanner = true;
      }
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
      // Ambil context dan lokalization sebelum operasi async
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null ? AppLocalizations.of(ctx) : null;
      await _auth.signUpWithEmail(email: email, password: password);

      // Tampilkan info bahwa email verifikasi sudah dikirim dan perlu dicek.
      infoMessage = t?.errorAuthEmailNotConfirmed ??
          'Email belum terverifikasi. Cek inbox untuk verifikasi.';
      showVerificationBanner = true;

      // Jangan navigasi otomatis; tunggu pengguna verifikasi lalu lakukan login.
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

  /// Tampilkan opsi kirim ulang ketika email belum terverifikasi atau banner aktif.
  bool get canResendVerification {
    if (showVerificationBanner) return true;
    final msg = (errorMessage ?? '').toLowerCase();
    return msg.contains('email not confirmed') ||
        msg.contains('email not verified') ||
        msg.contains('email belum terverifikasi');
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
    final ctx = StackedService.navigatorKey?.currentContext;
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

  /// Menutup banner verifikasi dan menghentikan ticker cooldown.
  void dismissVerificationBanner() {
    showVerificationBanner = false;
    _stopResendCooldownTicker();
    notifyListeners();
  }

  @override

  /// Pastikan ticker cooldown dihentikan saat ViewModel dibuang.
  void dispose() {
    _stopResendCooldownTicker();
    super.dispose();
  }

  /// Kirim ulang email verifikasi, tampilkan feedback, dan mulai ticker cooldown.
  Future<void> resendVerificationEmail() async {
    if (isBusy || isResendCooldownActive) {
      return;
    }
    final ctx = StackedService.navigatorKey?.currentContext;
    final t = ctx != null ? AppLocalizations.of(ctx) : null;
    if (email.isEmpty || !isValidEmail(email)) {
      final errMsg = t?.errorInvalidEmail ?? 'Format email tidak valid.';
      errorMessage = errMsg;
      infoMessage = null;
      _snackbarService.showSnackbar(
        message: errMsg,
        duration: const Duration(seconds: 3),
      );
      notifyListeners();
      return;
    }
    setBusy(true);
    errorMessage = null;
    infoMessage = null;
    try {
      await _auth.resendEmailVerification(email: email);
      infoMessage =
          t?.userEmailResendSuccess ?? 'Email verifikasi telah dikirim.';
      showVerificationBanner = true;
      _snackbarService.showSnackbar(
        message: infoMessage!,
        duration: const Duration(seconds: 3),
      );
      _lastResendAt = DateTime.now();
      _startResendCooldownTicker();
    } catch (e) {
      final errMsg =
          t?.userEmailResendError ?? 'Gagal mengirim email verifikasi.';
      errorMessage = errMsg;
      _snackbarService.showSnackbar(
        message: errMsg,
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  @visibleForTesting
  void debugStartCooldownNow() {
    _lastResendAt = DateTime.now();
    _startResendCooldownTicker();
  }

  @visibleForTesting
  void debugSetCooldownElapsedSeconds(int elapsedSeconds) {
    _lastResendAt = DateTime.now().subtract(Duration(seconds: elapsedSeconds));
    _startResendCooldownTicker();
  }

  @visibleForTesting
  bool get isResendTickerRunning => _resendCooldownTimer != null;
}
