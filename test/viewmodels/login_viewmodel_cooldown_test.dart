import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/ui/views/login/login_viewmodel.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:stacked_services/stacked_services.dart';
import '../helpers/test_helpers.mocks.dart';

class FakeAuthService extends AuthService {
  @override
  Future<void> resendEmailVerification({String? email}) async {
    // Simulasikan panggilan sukses tanpa Supabase
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _CountingAuthService extends AuthService {
  int calls = 0;
  @override
  Future<void> resendEmailVerification({String? email}) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  setUp(() async {
    // Reset dan registrasi service minimum untuk unit test
    await locator.reset();
    locator.registerLazySingleton<SnackbarService>(() => MockSnackbarService());
    locator.registerLazySingleton<AuthService>(() => FakeAuthService());
    locator.registerLazySingleton(() => NavigationService());
    // NavigatorKey dibiarkan null; ViewModel handle fallback saat null
  });

  test('resend cooldown ticker updates remaining seconds over time', () async {
    final vm = LoginViewModel();
    vm.email = 'test@example.com';

    vm.debugStartCooldownNow();
    expect(vm.isResendCooldownActive, isTrue);

    final r1 = vm.resendCooldownRemainingSeconds;
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    final r2 = vm.resendCooldownRemainingSeconds;

    expect(r2, lessThan(r1),
        reason: 'Countdown harus berkurang dari waktu ke waktu');
    vm.dispose();
  });

  test('dismissVerificationBanner hides banner and does not throw', () {
    final vm = LoginViewModel();
    vm.showVerificationBanner = true;
    vm.dismissVerificationBanner();
    expect(vm.showVerificationBanner, isFalse);
    vm.dispose();
  });

  test('cooldown stops automatically and remaining becomes zero', () async {
    final vm = LoginViewModel();
    vm.email = 'test@example.com';

    // Majukan cooldown hingga sisa ~1 detik
    vm.debugSetCooldownElapsedSeconds(
        LoginViewModel.resendCooldown.inSeconds - 1);
    expect(vm.isResendCooldownActive, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    expect(vm.isResendCooldownActive, isFalse,
        reason: 'Cooldown harus berakhir otomatis setelah durasi habis');
    expect(vm.resendCooldownRemainingSeconds, 0,
        reason: 'Sisa detik harus nol setelah cooldown selesai');
    vm.dispose();
  });

  test('resend button disabled during cooldown, enabled when done', () async {
    final vm = LoginViewModel();
    vm.email = 'test@example.com';
    vm.showVerificationBanner = true; // Banner aktif → tombol terlihat

    vm.debugStartCooldownNow();
    expect(vm.canResendVerification, isTrue);
    expect(vm.isResendCooldownActive, isTrue,
        reason: 'Saat cooldown aktif, tombol harus disabled di UI');

    // Biarkan cooldown segera berakhir
    vm.debugSetCooldownElapsedSeconds(
        LoginViewModel.resendCooldown.inSeconds - 1);
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    expect(vm.canResendVerification, isTrue,
        reason: 'Banner masih aktif sehingga tombol tetap terlihat');
    expect(vm.isResendCooldownActive, isFalse,
        reason: 'Cooldown selesai → tombol menjadi enabled di UI');
    vm.dispose();
  });

  test('ticker stops when banner dismissed', () {
    final vm = LoginViewModel();
    vm.email = 'test@example.com';

    vm.debugStartCooldownNow();
    expect(vm.isResendTickerRunning, isTrue);

    vm.dismissVerificationBanner();
    expect(vm.isResendTickerRunning, isFalse,
        reason: 'Ticker harus berhenti setelah banner ditutup');

    vm.dispose();
  });

  test('remaining seconds never negative', () {
    final vm = LoginViewModel();
    vm.email = 'test@example.com';

    vm.debugSetCooldownElapsedSeconds(
        LoginViewModel.resendCooldown.inSeconds + 10);

    expect(vm.isResendCooldownActive, isFalse);
    expect(vm.resendCooldownRemainingSeconds, 0,
        reason: 'Sisa detik tidak boleh negatif');

    vm.dispose();
  });

  test('resend is debounced to single call on rapid clicks', () async {
    final svc = _CountingAuthService();
    locator.unregister<AuthService>();
    locator.registerSingleton<AuthService>(svc);

    final vm = LoginViewModel();
    vm.email = 'test@example.com';
    vm.showVerificationBanner = true;

    final f1 = vm.resendVerificationEmail();
    final f2 = vm.resendVerificationEmail();

    await Future.wait([f1, f2]);

    expect(svc.calls, 1,
        reason: 'Klik cepat harus menghasilkan satu panggilan resend saja');

    vm.dispose();
  });
}
