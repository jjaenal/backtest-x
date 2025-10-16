import 'package:backtestx/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/ui/views/login/login_viewmodel.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.loginTitle ?? 'Sign In')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (viewModel.infoMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      viewModel.infoMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                // Recovery flow is handled via dedicated dialog when detected
                if (viewModel.hasPendingRedirect)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      t?.loginPostRedirectBanner ??
                          'Setelah login, kamu akan diarahkan ke halaman yang diminta.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                TextField(
                  decoration: InputDecoration(
                    labelText: t?.loginEmailLabel ?? 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => viewModel.email = v,
                ),
                if (viewModel.email.isNotEmpty &&
                    !viewModel.isValidEmail(viewModel.email))
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: Text(
                      t?.errorInvalidEmail ?? 'Format email tidak valid.',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: t?.loginPasswordLabel ?? 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(viewModel.obscureLoginPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: viewModel.toggleObscureLoginPassword,
                    ),
                  ),
                  obscureText: viewModel.obscureLoginPassword,
                  onChanged: (v) => viewModel.password = v,
                ),
                if (viewModel.password.isNotEmpty &&
                    viewModel.password.length < 6)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 6),
                    child: Text(
                      t?.errorPasswordMinSignup ??
                          'Password minimal 6 karakter untuk pendaftaran.',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () => viewModel.forgotPassword(),
                    child: Text(t?.loginForgotPassword ?? 'Lupa Password?'),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (viewModel.isBusy ||
                          (viewModel.email.isNotEmpty &&
                              !viewModel.isValidEmail(viewModel.email)))
                      ? null
                      : viewModel.signInEmail,
                  child: Text(t?.loginSignInEmail ?? 'Sign In with Email'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: (viewModel.isBusy ||
                          (viewModel.email.isNotEmpty &&
                              !viewModel.isValidEmail(viewModel.email)) ||
                          viewModel.password.length < 6)
                      ? null
                      : viewModel.signUpEmail,
                  child: Text(t?.loginSignUpEmail ?? 'Sign Up with Email'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () =>
                            locator<NavigationService>().navigateToSignupView(),
                    child: Text(t?.homeUserSignUp ?? 'Sign Up'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: viewModel.isBusy ? null : viewModel.signInGoogle,
                  icon: const Icon(Icons.login),
                  label: Text(t?.loginContinueGoogle ?? 'Continue with Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();

  @override
  void onViewModelReady(LoginViewModel viewModel) {
    // If recovery flow is detected, prompt a dedicated dialog for changing password
    if (viewModel.isRecovery) {
      final dialogService = locator<DialogService>();
      final snackbarService = locator<SnackbarService>();
      final deepLinkService = locator<DeepLinkService>();
      final auth = locator<AuthService>();
      final nav = locator<NavigationService>();
      // Show dialog asynchronously to avoid build timing issues
      Future<void>(() async {
        final response = await dialogService.showCustomDialog(
          variant: DialogType.changePassword,
          title: 'Atur Password Baru',
          description:
              'Masukkan password baru dan konfirmasi untuk menyelesaikan pemulihan.',
          barrierDismissible: true,
        );
        if (response?.confirmed == true) {
          // Give user feedback and clear recovery markers from URL
          snackbarService.showSnackbar(
            message:
                'Password berhasil diubah. Silakan login dengan password baru.',
            duration: const Duration(seconds: 3),
          );
          deepLinkService.clearRecoveryMarkersFromUrl();
          // If recovery established a session, send user to Home
          if (auth.isLoggedIn) {
            await nav.replaceWith(Routes.homeView);
          }
        }
      });
    }
  }
}
