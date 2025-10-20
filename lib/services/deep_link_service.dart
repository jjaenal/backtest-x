import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:backtestx/services/prefs_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Service to build and handle deep links for Backtest-X
class DeepLinkService {
  final String? _baseUrlOverride;
  final bool? _useHashRoutingOverride;

  DeepLinkService({String? baseUrlOverride, bool? useHashRoutingOverride})
      : _baseUrlOverride = baseUrlOverride,
        _useHashRoutingOverride = useHashRoutingOverride;

  /// Build a deep link URL to open Backtest Result view for a given result id
  String buildBacktestResultLink({required String resultId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.backtestResultView; // '/backtest-result-view'
    final encodedId = Uri.encodeComponent(resultId);
    if (useHash) {
      return '$base/#$routePath?id=$encodedId';
    } else {
      return '$base$routePath?id=$encodedId';
    }
  }

  /// Build a deep link URL to open Strategy Builder for a given strategy id
  String buildStrategyLink({required String strategyId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.strategyBuilderView; // '/strategy-builder-view'
    final encodedId = Uri.encodeComponent(strategyId);
    final query = 'strategyId=$encodedId';
    if (useHash) {
      return '$base/#$routePath?$query';
    } else {
      return '$base$routePath?$query';
    }
  }

  /// Build a deep link URL to open Strategy Builder with optional template & data selection (onboarding)
  String buildOnboardingLink({String? templateKey, String? dataId}) {
    final base = _determineBaseUrl();
    final useHash = _determineUseHash();
    const routePath = Routes.strategyBuilderView; // '/strategy-builder-view'
    final params = <String, String>{};
    if (templateKey != null && templateKey.isNotEmpty) {
      params['templateKey'] = Uri.encodeComponent(templateKey);
    }
    if (dataId != null && dataId.isNotEmpty) {
      params['dataId'] = Uri.encodeComponent(dataId);
    }
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    if (useHash) {
      return query.isEmpty ? '$base/#$routePath' : '$base/#$routePath?$query';
    } else {
      return query.isEmpty ? '$base$routePath' : '$base$routePath?$query';
    }
  }

  /// Attempt to handle the initial URL (useful on web) and navigate accordingly
  Future<bool> maybeHandleInitialLink() async {
    if (!kIsWeb) return false;

    final location = html.window.location;
    final href = location.href;
    // If sanitized earlier, sessionStorage may contain an auth error hint
    final storedErr = html.window.sessionStorage['supabase_auth_error'];
    if (storedErr != null && storedErr.isNotEmpty) {
      try {
        final snackbar = locator<SnackbarService>();
        snackbar.showSnackbar(
          message: _mapAuthErrorToFriendlyMessage(null, storedErr),
          duration: const Duration(seconds: 4),
        );
      } catch (_) {}
      // Clear storage flag and tidy URL
      html.window.sessionStorage.remove('supabase_auth_error');
      clearAuthErrorMarkersFromUrl();
      // Route to Login for clarity
      final nav = locator<NavigationService>();
      nav.replaceWith(Routes.loginView);
      return true;
    }

    // Support both hash and path URL strategies
    final uri = Uri.tryParse(href);
    if (uri == null) return false;

    // Supabase password recovery: detect and route to Login
    // Keep this early so we don't accidentally navigate elsewhere first
    try {
      final hasRecoveryParam = (uri.queryParameters['type'] == 'recovery');
      final hasRecoveryInFragment = uri.fragment.contains('type=recovery');
      if (hasRecoveryParam || hasRecoveryInFragment) {
        final nav = locator<NavigationService>();
        nav.replaceWith(Routes.loginView);
        return true;
      }

      // Handle email confirmation (Supabase uses type=signup)
      final hasSignupConfirmParam = (uri.queryParameters['type'] == 'signup');
      final hasSignupConfirmInFragment = uri.fragment.contains('type=signup');
      if (hasSignupConfirmParam || hasSignupConfirmInFragment) {
        final auth = locator<AuthService>();
        final nav = locator<NavigationService>();
        final snackbar = locator<SnackbarService>();
        // Jika sudah login, langsung ke Home
        if (auth.isLoggedIn) {
          snackbar.showSnackbar(
            message: 'Email berhasil terverifikasi. Anda sudah masuk.',
            duration: const Duration(seconds: 3),
          );
          clearAuthErrorMarkersFromUrl();
          nav.replaceWith(Routes.homeView);
          return true;
        }
        // Coba login otomatis menggunakan kredensial yang disimpan sementara saat sign-up
        String? e;
        String? p;
        String? tsStr;
        try {
          e = html.window.sessionStorage['pending_signup_email'];
          p = html.window.sessionStorage['pending_signup_password'];
          tsStr = html.window.sessionStorage['pending_signup_ts'];
        } catch (_) {}
        // Hapus kredensial sementara apapun hasilnya
        try {
          html.window.sessionStorage.remove('pending_signup_email');
          html.window.sessionStorage.remove('pending_signup_password');
          html.window.sessionStorage.remove('pending_signup_ts');
        } catch (_) {}
        DateTime? ts;
        try {
          if (tsStr != null && tsStr.isNotEmpty) {
            ts = DateTime.tryParse(tsStr);
          }
        } catch (_) {}
        final isFresh = ts == null
            ? true
            : DateTime.now().difference(ts).inMinutes < 15; // batas 15 menit
        if (isFresh && e != null && e.isNotEmpty && p != null && p.isNotEmpty) {
          try {
            await auth.signInWithEmail(email: e, password: p);
            snackbar.showSnackbar(
              message: 'Email terverifikasi. Login otomatis berhasil.',
              duration: const Duration(seconds: 3),
            );
            clearAuthErrorMarkersFromUrl();
            nav.replaceWith(Routes.homeView);
            return true;
          } catch (err) {
            // Jika login otomatis gagal, arahkan ke Login
            snackbar.showSnackbar(
              message: 'Verifikasi sukses. Silakan login manual.',
              duration: const Duration(seconds: 4),
            );
            clearAuthErrorMarkersFromUrl();
            nav.replaceWith(Routes.loginView);
            return true;
          }
        }
        // Tanpa kredensial atau sudah lama, minta pengguna login
        snackbar.showSnackbar(
          message: 'Email berhasil terverifikasi. Silakan login.',
          duration: const Duration(seconds: 3),
        );
        clearAuthErrorMarkersFromUrl();
        nav.replaceWith(Routes.loginView);
        return true;
      }
      // Handle auth error redirects, e.g., error=access_denied, error_description=otp_expired
      final err = uri.queryParameters['error'] ??
          (Uri.tryParse(uri.fragment)?.queryParameters['error']);
      final errDesc = uri.queryParameters['error_description'] ??
          (Uri.tryParse(uri.fragment)?.queryParameters['error_description']);
      if (err != null || errDesc != null) {
        final snackbar = locator<SnackbarService>();
        final message = _mapAuthErrorToFriendlyMessage(err, errDesc);
        snackbar.showSnackbar(
          message: message,
          duration: const Duration(seconds: 4),
        );
        clearAuthErrorMarkersFromUrl();
        final nav = locator<NavigationService>();
        nav.replaceWith(Routes.loginView);
        return true;
      }
    } catch (_) {
      // Non-critical; continue normal deep link handling
    }

    // Normalize: extract the path part after hash if present
    String path = uri.path;
    String query = uri.query;
    if (uri.fragment.isNotEmpty) {
      final fragUri = Uri.tryParse(uri.fragment);
      if (fragUri != null) {
        path = fragUri.path;
        query = fragUri.query;
      } else if (uri.fragment.startsWith('/')) {
        // Simple fallback
        final idx = uri.fragment.indexOf('?');
        path = idx == -1 ? uri.fragment : uri.fragment.substring(0, idx);
        query = idx == -1 ? '' : uri.fragment.substring(idx + 1);
      }
    }

    if (path == Routes.backtestResultView) {
      final q = Uri.splitQueryString(query);
      final id = q['id'];
      if (id != null && id.isNotEmpty) {
        return _openBacktestResult(id);
      }
    }
    if (path == Routes.strategyBuilderView) {
      final q = Uri.splitQueryString(query);
      final id = q['strategyId'] ?? q['id'];
      if (id != null && id.isNotEmpty) {
        return _openStrategy(id);
      }
      // Onboarding deep link: apply template & data selection
      final tpl = q['templateKey'];
      final dataId = q['dataId'];
      if ((tpl != null && tpl.isNotEmpty) ||
          (dataId != null && dataId.isNotEmpty)) {
        try {
          final prefs = locator<PrefsService>();
          if (tpl != null && tpl.isNotEmpty) {
            prefs.setString('onboarding.pending_template_key', tpl);
          }
          if (dataId != null && dataId.isNotEmpty) {
            prefs.setString('onboarding.pending_data_id', dataId);
          }
        } catch (_) {}
        final nav = locator<NavigationService>();
        final auth = locator<AuthService>();
        if (!auth.isLoggedIn) {
          auth.setPostLoginRedirect(Routes.strategyBuilderView);
          nav.replaceWith(Routes.loginView);
          return true;
        }
        nav.navigateTo(Routes.strategyBuilderView);
        return true;
      }
    }
    return false;
  }

  String _mapAuthErrorToFriendlyMessage(String? error, String? description) {
    final e = (description ?? error ?? '').toLowerCase();
    if (e.contains('otp_expired')) {
      return 'Tautan verifikasi email sudah kadaluarsa. Kirim ulang email verifikasi dan coba lagi.';
    }
    if (e.contains('access_denied')) {
      return 'Akses ditolak saat verifikasi email. Pastikan tautan valid atau kirim ulang.';
    }
    return 'Terjadi masalah saat verifikasi email. Silakan kirim ulang email verifikasi.';
  }

  Future<bool> _openBacktestResult(String id) async {
    final storage = locator<StorageService>();
    final nav = locator<NavigationService>();
    final result = await storage.getBacktestResult(id);
    if (result == null) return false;
    nav.navigateTo(Routes.backtestResultView,
        arguments: BacktestResultViewArguments(result: result));
    return true;
  }

  Future<bool> _openStrategy(String id) async {
    final nav = locator<NavigationService>();
    final auth = locator<AuthService>();
    // If not logged in, record post-login redirect and route to Login
    if (!auth.isLoggedIn) {
      auth.setPostLoginRedirect(
        Routes.strategyBuilderView,
        arguments: StrategyBuilderViewArguments(strategyId: id),
      );
      nav.replaceWith(Routes.loginView);
      return true;
    }
    // Navigate directly; StrategyBuilderViewModel will load strategy by id
    nav.navigateTo(
      Routes.strategyBuilderView,
      arguments: StrategyBuilderViewArguments(strategyId: id),
    );
    return true;
  }

  String _determineBaseUrl() {
    if (_baseUrlOverride != null) return _baseUrlOverride!;
    if (kIsWeb) {
      final uri = Uri.base;
      final String origin = uri.origin;
      final String basePath = uri.path;
      // Trim trailing slash from basePath and origin
      String base = origin;
      // If hosted under a subpath, preserve it
      if (basePath.isNotEmpty &&
          basePath != '/' &&
          !basePath.endsWith('.html')) {
        // Remove trailing slash
        final trimmed = basePath.endsWith('/')
            ? basePath.substring(0, basePath.length - 1)
            : basePath;
        base = '$origin$trimmed';
      }
      return base;
    }
    // Fallback for non-web: provide a pseudo scheme-based link
    return 'backtestx://app';
  }

  bool _determineUseHash() {
    if (_useHashRoutingOverride != null) return _useHashRoutingOverride!;
    if (!kIsWeb) return false;
    final loc = html.window.location;
    // Heuristic: if there's already a hash pointing to a route, keep using it
    return (loc.hash.isNotEmpty);
  }

  /// Clear recovery markers (`type=recovery`, tokens) from the URL on web
  /// to avoid repeatedly showing recovery UI after password change.
  void clearRecoveryMarkersFromUrl() {
    if (!kIsWeb) return;
    try {
      final loc = html.window.location;
      // Replace current URL without query params
      final newUrl = Uri(
        scheme: loc.protocol.replaceAll(':', ''),
        host: loc.hostname,
        port: loc.port.isNotEmpty ? int.tryParse(loc.port) : null,
        path: loc.pathname,
      ).toString();
      html.window.history.replaceState(null, '', newUrl);

      // If hash contains query (e.g. /#/login?type=recovery...), strip it
      final hash = loc.hash; // includes leading '#'
      if (hash.isNotEmpty) {
        final raw = hash.substring(1);
        final idx = raw.indexOf('?');
        final clean = idx == -1 ? raw : raw.substring(0, idx);
        html.window.location.hash = clean;
      }
    } catch (_) {
      // Non-critical; ignore
    }
  }

  /// Clear auth error markers (error, error_description, tokens) from the URL on web.
  void clearAuthErrorMarkersFromUrl() {
    if (!kIsWeb) return;
    try {
      final loc = html.window.location;
      final baseUri = Uri(
        scheme: loc.protocol.replaceAll(':', ''),
        host: loc.hostname,
        port: loc.port.isNotEmpty ? int.tryParse(loc.port) : null,
        path: loc.pathname,
      );

      // Clean query params
      final current = Uri.parse(loc.href);
      final cleanedQuery = Map<String, String>.from(current.queryParameters)
        ..remove('error')
        ..remove('error_description')
        ..remove('type')
        ..remove('token_hash');

      // Clean fragment params
      String? cleanedFragment;
      if (current.fragment.isNotEmpty) {
        final fragUri = Uri.tryParse(current.fragment);
        if (fragUri != null) {
          final cleanedFragQuery =
              Map<String, String>.from(fragUri.queryParameters)
                ..remove('error')
                ..remove('error_description')
                ..remove('type')
                ..remove('token_hash');
          final fragClean = Uri(
            path: fragUri.path,
            queryParameters: cleanedFragQuery.isEmpty ? null : cleanedFragQuery,
          ).toString();
          cleanedFragment = fragClean.isEmpty ? null : fragClean;
        }
      }

      final newUri = Uri(
        scheme: baseUri.scheme,
        host: baseUri.host,
        port: baseUri.port,
        path: baseUri.path,
        queryParameters: cleanedQuery.isEmpty ? null : cleanedQuery,
        fragment: cleanedFragment,
      ).toString();
      html.window.history.replaceState(null, '', newUri);
    } catch (_) {
      // Non-critical; ignore
    }
  }
}
