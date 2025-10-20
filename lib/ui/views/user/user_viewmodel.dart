import 'package:backtestx/app/app.bottomsheets.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:backtestx/services/theme_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/prefs_service.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserViewModel extends BaseViewModel {
  final _nav = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _snackbarService = locator<SnackbarService>();
  final _authService = locator<AuthService>();
  final _theme = locator<ThemeService>();
  final _storageService = locator<StorageService>();
  final _data = locator<DataManager>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _prefs = PrefsService();

  bool get isLoggedIn => _authService.isLoggedIn;
  bool get backgroundWarmupEnabled => _data.isBackgroundWarmupEnabled;
  bool get isWarmingUp => _data.isWarmingUp;
  bool get useSystemLanguage => _theme.locale.value == null;
  String? get currentLocaleCode => _theme.locale.value?.languageCode;
  bool get useSystemTheme => _theme.themeMode.value == ThemeMode.system;
  String get currentThemeSelection =>
      _theme.themeMode.value == ThemeMode.light ? 'light' : 'dark';

  bool get isEmailVerified => _authService.isEmailVerified;

  void initialize() {
    // React to locale changes for UI updates
    _theme.locale.addListener(notifyListeners);
    _theme.themeMode.addListener(notifyListeners);

    // React to auth state changes to refresh verification status and related UI
    _authSub = _authService.authState.listen((AuthState state) {
      notifyListeners();
    });
  }

  StreamSubscription<AuthState>? _authSub;

  @override
  void dispose() {
    // Cleanup listeners to avoid memory leaks
    _theme.locale.removeListener(notifyListeners);
    _theme.themeMode.removeListener(notifyListeners);
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    await _nav.replaceWithLoginView();
  }

  Future<void> navigateToLogin() async {
    await _nav.navigateToLoginView();
  }

  // Theme controls
  void setThemeSystem() {
    _theme.setThemeMode(ThemeMode.system);
    notifyListeners();
  }

  void setThemeLight() {
    _theme.setThemeMode(ThemeMode.light);
    _prefs.setString('app.lastManualTheme', 'light');
    notifyListeners();
  }

  void setThemeDark() {
    _theme.setThemeMode(ThemeMode.dark);
    _prefs.setString('app.lastManualTheme', 'dark');
    notifyListeners();
  }

  Future<void> setUseSystemTheme(bool value) async {
    if (value) {
      final current = _theme.themeMode.value;
      if (current == ThemeMode.light) {
        await _prefs.setString('app.lastManualTheme', 'light');
      } else if (current == ThemeMode.dark) {
        await _prefs.setString('app.lastManualTheme', 'dark');
      }
      _theme.setThemeMode(ThemeMode.system);
    } else {
      final saved = await _prefs.getString('app.lastManualTheme');
      if (saved == 'light') {
        _theme.setThemeMode(ThemeMode.light);
      } else {
        _theme.setThemeMode(ThemeMode.dark);
      }
    }
    notifyListeners();
  }

  Future<void> navigateToSignup() async {
    await _nav.navigateToSignupView();
  }

  Future<void> resendVerificationEmail(BuildContext context) async {
    final t = AppLocalizations.of(context);
    try {
      await runBusyFuture(_authService.resendEmailVerification(),
          busyObject: 'resend_verify_email');
      _snackbarService.showSnackbar(
        message: t?.userEmailResendSuccess ?? 'Verification email sent.',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message:
            t?.userEmailResendError ?? 'Failed to send verification email.',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void setLocaleSystem() => _theme.setLocaleCode(null);
  void setLocaleEnglish() {
    _theme.setLocaleCode('en');
    _prefs.setString('app.lastManualLocale', 'en');
  }

  void setLocaleIndonesian() {
    _theme.setLocaleCode('id');
    _prefs.setString('app.lastManualLocale', 'id');
  }

  Future<void> setUseSystemLanguage(bool value) async {
    if (value) {
      final current = _theme.locale.value?.languageCode;
      if (current != null && current.isNotEmpty) {
        await _prefs.setString('app.lastManualLocale', current);
      }
      await _theme.setLocaleCode(null);
    } else {
      final saved = await _prefs.getString('app.lastManualLocale');
      final code = (saved != null && saved.isNotEmpty)
          ? saved
          : (_theme.locale.value?.languageCode ?? 'en');
      await _theme.setLocaleCode(code);
    }
    notifyListeners();
  }

  void toggleBackgroundWarmup(BuildContext context) {
    final next = !_data.isBackgroundWarmupEnabled;
    _data.setBackgroundWarmupEnabled(next);
    final t = AppLocalizations.of(context);
    _snackbarService.showSnackbar(
      message: next
          ? (t?.homeOptionEnableBg ?? 'Enable Background Loading')
          : (t?.homeOptionPauseBg ?? 'Pause Background Loading'),
      duration: const Duration(seconds: 2),
    );
    notifyListeners();
  }

  void warmUpCacheNow(BuildContext context) {
    _data.warmUpCacheInBackground(force: true);
    final t = AppLocalizations.of(context);
    _snackbarService.showSnackbar(
      message: t?.homeLoadingCache ?? 'Loading cache…',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> showCacheInfo(BuildContext context) async {
    try {
      final t = AppLocalizations.of(context);
      final mem = _data.getMemoryUsageFormatted();
      final disk = await _data.getDiskUsageFormatted();
      final datasets = _data.getAllData().length;
      final status = isWarmingUp
          ? (t?.homeCacheWarming ?? 'Warming')
          : (datasets > 0
              ? (t?.homeCacheReady ?? 'Ready')
              : (t?.homeCacheEmpty ?? 'Empty'));
      final desc = StringBuffer()
        ..writeln('Status: $status')
        ..writeln('Datasets: $datasets')
        ..writeln('Memory: $mem')
        ..writeln('Disk: $disk');

      final response = await _bottomSheetService.showBottomSheet(
        title: t?.homeCacheInfoTitle ?? 'Cache Info',
        description: desc.toString(),
        confirmButtonTitle: t?.homeOptionLoadCache ?? 'Load Cache Now',
        cancelButtonTitle: _data.isBackgroundWarmupEnabled
            ? (t?.homeOptionPauseBg ?? 'Pause')
            : (t?.homeOptionEnableBg ?? 'Enable'),
      );
      if (!context.mounted) return;
      if (response?.confirmed == true) {
        warmUpCacheNow(context);
      } else {
        toggleBackgroundWarmup(context);
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Failed to show cache info',
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> showOnboarding() async {
    final response = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.onboarding,
      barrierDismissible: true,
      isScrollControlled: true,
    );
    if (response?.confirmed == true) {
      try {
        await _prefs.setString('onboarding.completed', 'true');
      } catch (_) {}
    }
  }

  // Delete Account flow: show confirm, then offer local data clear or sign out
  Future<void> requestDeleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final response = await _dialogService.showConfirmationDialog(
      title: t?.userDeleteAccountTitle ?? 'Delete Account',
      description: t?.userDeleteAccountDesc ??
          'Direct account deletion is not available in this app. You can clear local data and sign out.',
      confirmationTitle: t?.deleteLabel ?? 'Delete',
      cancelTitle: t?.commonCancel ?? 'Cancel',
    );

    if (response?.confirmed != true) return;

    final sheet = await _bottomSheetService.showBottomSheet(
      title: t?.userDeleteAccountTitle ?? 'Delete Account',
      description: t?.userDeleteNotSupported ??
          'Direct account deletion is not available in this client.',
      confirmButtonTitle: t?.userClearLocalData ?? 'Clear Local Data',
      cancelButtonTitle: t?.homeUserSignOut ?? 'Sign Out',
    );

    if (sheet?.confirmed == true) {
      final confirm = await _dialogService.showConfirmationDialog(
        title: t?.userClearAllConfirmTitle ?? 'Confirm Clear Local Data',
        description: t?.userClearAllConfirmDesc ??
            'This will delete strategies, results, market data, and drafts stored on this device. Continue?',
        confirmationTitle: t?.userClearAllConfirmButton ?? 'Clear',
        cancelTitle: t?.commonCancel ?? 'Cancel',
      );
      if (confirm?.confirmed == true) {
        try {
          await runBusyFuture(_storageService.clearAllData(),
              busyObject: 'clear_all_data');
          await _data.clearAll();
          _snackbarService.showSnackbar(
            message: t?.userClearAllDataSuccess ?? 'Local data cleared.',
            duration: const Duration(seconds: 2),
          );
        } catch (e) {
          _snackbarService.showSnackbar(
            message: t?.userClearAllDataError ?? 'Failed to clear local data.',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } else {
      await signOut();
    }
  }
}
