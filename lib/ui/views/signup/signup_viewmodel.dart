import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'dart:async';
import 'package:meta/meta.dart' show visibleForTesting;

/// ViewModel untuk signup, menangani pendaftaran, banner verifikasi, dan cooldown kirim ulang.
class SignupViewModel extends BaseViewModel {
  final _auth = locator<AuthService>();
  final _snackbarService = locator<SnackbarService>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String? errorMessage;
  String? infoMessage;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
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
      // Ambil context dan lokalization sebelum operasi async
      final ctx = StackedService.navigatorKey?.currentContext;
      final t = ctx != null ? AppLocalizations.of(ctx) : null;
      await _auth.signUpWithEmail(email: email, password: password);
      // Simpan kredensial sementara di sessionStorage agar bisa auto-login setelah verifikasi
      if (kIsWeb) {
        try {
          html.window.sessionStorage['pending_signup_email'] = email;
          html.window.sessionStorage['pending_signup_password'] = password;
          html.window.sessionStorage['pending_signup_ts'] =
              DateTime.now().toIso8601String();
        } catch (_) {}
      }
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

  /// Menentukan apakah banner verifikasi perlu ditampilkan dan aksi kirim ulang tersedia.
  bool get canResendVerification {
    if (showVerificationBanner) return true;
    final msg = (infoMessage ?? '').toLowerCase();
    if (msg.isEmpty) return false;
    final ctx = StackedService.navigatorKey?.currentContext;
    final t = ctx != null ? AppLocalizations.of(ctx) : null;
    final candidates = [
      (t?.errorAuthEmailNotConfirmed ?? '').toLowerCase(),
      'email belum terverifikasi',
      'email not verified',
    ].where((e) => e.isNotEmpty).toList();
    return candidates.any((k) => msg.contains(k));
  }

  /// Menutup banner verifikasi dan menghentikan ticker cooldown.
  void dismissVerificationBanner() {
    showVerificationBanner = false;
    _stopResendCooldownTicker();
    notifyListeners();
  }

  /// Pastikan ticker cooldown dihentikan saat ViewModel dibuang.
  @override
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
      errorMessage = t?.errorInvalidEmail ?? 'Format email tidak valid.';
      infoMessage = null;
      notifyListeners();
      return;
    }
    setBusy(true);
    errorMessage = null;
    try {
      await _auth.resendEmailVerification(email: email);
      infoMessage =
          t?.userEmailResendSuccess ?? 'Email verifikasi telah dikirim.';
      _snackbarService.showSnackbar(
        message: t?.userEmailResendSuccess ?? 'Email verifikasi telah dikirim.',
        duration: const Duration(seconds: 3),
      );
      // Tetap tampilkan banner sampai pengguna menutupnya.
      showVerificationBanner = true;
      _lastResendAt = DateTime.now();
      _startResendCooldownTicker();
    } catch (e) {
      errorMessage =
          t?.userEmailResendError ?? 'Gagal mengirim email verifikasi.';
      _snackbarService.showSnackbar(
        message: t?.userEmailResendError ?? 'Gagal mengirim email verifikasi.',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  String _friendlyError(Object e) {
    final ctx = StackedService.navigatorKey?.currentContext;
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
