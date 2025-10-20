import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:ui' show Locale;
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/services/theme_service.dart';

/// AuthService mengelola autentikasi pengguna dan sesi aplikasi.
///
/// Menyediakan method untuk sign in/out, pendaftaran, reset password,
/// serta listener global untuk event Supabase seperti password recovery
/// dan verifikasi email. Backend yang digunakan adalah Supabase Auth.
///
/// Contoh:
/// ```dart
/// final auth = AuthService();
/// final resp = await auth.signInWithEmail(email: 'user@domain.com', password: 'secret');
/// ```
class AuthService {
  SupabaseClient? _safeClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn {
    final c = _safeClient();
    return c?.auth.currentSession != null;
  }

  User? get currentUser {
    final c = _safeClient();
    return c?.auth.currentUser;
  }

  String? get currentUserEmail => currentUser?.email;

  bool get isEmailVerified {
    final u = currentUser;
    // Supabase sets emailConfirmedAt when the email is verified
    return u?.emailConfirmedAt != null;
  }

  // Subscription to keep global listener alive for app lifetime
  StreamSubscription<AuthState>? _globalAuthSub;

  // Always return a stream; empty if Supabase isn't initialized
  Stream<AuthState> get authState {
    final c = _safeClient();
    return c?.auth.onAuthStateChange ?? const Stream.empty();
  }

  Future<void> signInWithGoogle({String? redirectTo}) async {
    final c = _safeClient();
    if (c == null) return;
    final rt = redirectTo ??
        (kIsWeb ? Uri.base.origin : 'io.supabase.flutter://login-callback');
    await c.auth.signInWithOAuth(OAuthProvider.google, redirectTo: rt);
  }

  Future<AuthResponse> signUpWithEmail(
      {required String email, required String password}) async {
    final c = _safeClient();
    if (c == null) {
      throw const AuthException('Supabase not initialized');
    }
    // Use current origin on Web; use app scheme on mobile.
    final redirectTo =
        kIsWeb ? '${Uri.base.origin}/' : 'io.supabase.flutter://login-callback';
    return c.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectTo,
    );
  }

  Future<void> sendPasswordResetEmail(
      {required String email, String? redirectTo}) async {
    final c = _safeClient();
    if (c == null) {
      throw const AuthException('Supabase not initialized');
    }
    final rt = redirectTo ??
        (kIsWeb ? Uri.base.origin : 'io.supabase.flutter://login-callback');
    await c.auth.resetPasswordForEmail(email, redirectTo: rt);
  }

  Future<void> resendEmailVerification({String? email}) async {
    final c = _safeClient();
    if (c == null) {
      throw const AuthException('Supabase not initialized');
    }
    final e = email ?? c.auth.currentUser?.email;
    if (e == null || e.isEmpty) {
      throw const AuthException('No email found for current user');
    }
    // Match the signup redirect for consistency.
    final redirectTo =
        kIsWeb ? '${Uri.base.origin}/' : 'io.supabase.flutter://login-callback';
    // Resend confirmation email for signup
    await c.auth.resend(
      type: OtpType.signup,
      email: e,
      emailRedirectTo: redirectTo,
    );
  }

  /// Login dengan email dan password.
  ///
  /// Mengembalikan `AuthResponse` jika berhasil.
  /// Melempar `AuthException` jika Supabase belum terinisialisasi.
  Future<AuthResponse> signInWithEmail(
      {required String email, required String password}) async {
    final c = _safeClient();
    if (c == null) {
      throw const AuthException('Supabase not initialized');
    }
    return c.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    final c = _safeClient();
    if (c == null) return;
    await c.auth.signOut();
  }

  /// Mengubah password user yang sedang login.
  ///
  /// Mengembalikan `UserResponse` jika berhasil.
  /// Melempar `AuthException` jika Supabase belum terinisialisasi.
  Future<UserResponse> updatePassword({required String newPassword}) async {
    final c = _safeClient();
    if (c == null) {
      throw const AuthException('Supabase not initialized');
    }
    return c.auth.updateUser(UserAttributes(password: newPassword));
  }

  // ===== Post-login redirect support =====
  // Simple holder for a pending redirect after successful authentication
  PostLoginRedirect? _postLoginRedirect;

  void setPostLoginRedirect(String route, {dynamic arguments}) {
    _postLoginRedirect = PostLoginRedirect(route, arguments: arguments);
  }

  PostLoginRedirect? takePostLoginRedirect() {
    final r = _postLoginRedirect;
    _postLoginRedirect = null;
    return r;
  }

  PostLoginRedirect? getPostLoginRedirect() => _postLoginRedirect;

  // Set up global listener to handle Supabase password recovery event on mobile
  void setupGlobalPasswordRecoveryListener() {
    if (kIsWeb) return; // Avoid duplicate dialogs on Web; handled in LoginView
    _globalAuthSub?.cancel();
    _globalAuthSub = authState.listen((state) async {
      if (state.event == AuthChangeEvent.passwordRecovery) {
        // Show change-password dialog via global DialogService
        final dialog = locator<DialogService>();
        // Fallback locale when ThemeService is not registered in tests
        final Locale locale = locator.isRegistered<ThemeService>()
            ? (locator<ThemeService>().locale.value ?? const Locale('en'))
            : const Locale('en');
        final l10n = await AppLocalizations.delegate.load(locale);
        final successMsg = l10n.homeChangePasswordSuccess;
        final response = await dialog.showCustomDialog(
          variant: DialogType.changePassword,
          title: l10n.changePasswordTitle,
          description: l10n.changePasswordDescription,
          barrierDismissible: true,
        );
        if (response?.confirmed == true) {
          // Feedback
          locator<SnackbarService>().showSnackbar(
            title: l10n.changePasswordTitle,
            message: successMsg,
            duration: const Duration(seconds: 3),
          );
          // Clear recovery markers from URL on web to avoid repeated prompts
          if (kIsWeb && locator.isRegistered<DeepLinkService>()) {
            locator<DeepLinkService>().clearRecoveryMarkersFromUrl();
          }
          // If a session exists after recovery, route to Home
          if (isLoggedIn && locator.isRegistered<NavigationService>()) {
            locator<NavigationService>().replaceWith(Routes.homeView);
          }
        }
      } else if (state.event == AuthChangeEvent.userUpdated) {
        // Handle email verification callback on mobile
        final snackbar = locator<SnackbarService>();
        if (isLoggedIn) {
          snackbar.showSnackbar(
            message: 'Email berhasil terverifikasi. Anda sudah masuk.',
            duration: const Duration(seconds: 3),
          );
          if (locator.isRegistered<NavigationService>()) {
            locator<NavigationService>().replaceWith(Routes.homeView);
          }
        } else {
          snackbar.showSnackbar(
            message: 'Email berhasil terverifikasi. Silakan login.',
            duration: const Duration(seconds: 3),
          );
          if (locator.isRegistered<NavigationService>()) {
            locator<NavigationService>().replaceWith(Routes.loginView);
          }
        }
      } else if (state.event == AuthChangeEvent.signedIn ||
          state.event == AuthChangeEvent.initialSession) {
        // After verification or when session becomes available, leave SignupView
        if (locator.isRegistered<NavigationService>()) {
          locator<NavigationService>().replaceWith(Routes.homeView);
        }
      }
    });
  }
}

class PostLoginRedirect {
  final String route;
  final dynamic arguments;
  PostLoginRedirect(this.route, {this.arguments});
}
