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
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_constants.dart';
import 'package:backtestx/ui/widgets/verification_banner.dart';
import 'package:backtestx/services/theme_service.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
      BuildContext context, LoginViewModel viewModel, Widget? child) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.loginTitle ?? 'Sign In')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.all(StrategyBuilderConstants.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: StrategyBuilderConstants.mediumSpacing),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  // Unverified email banner with resend action
                  if (viewModel.canResendVerification)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: StrategyBuilderConstants.mediumSpacing),
                      child: VerificationBanner(
                        isBusy: viewModel.isBusy,
                        isResendEnabled: !(viewModel.isBusy ||
                            !viewModel.isValidEmail(viewModel.email) ||
                            viewModel.isResendCooldownActive),
                        resendCooldownActive: viewModel.isResendCooldownActive,
                        cooldownRemainingSeconds:
                            viewModel.resendCooldownRemainingSeconds,
                        onResend: viewModel.resendVerificationEmail,
                        onDismiss: viewModel.dismissVerificationBanner,
                        message: t?.errorAuthEmailNotConfirmed,
                        resendLabel: t?.userEmailResend,
                        dismissLabel: t?.errorDismiss,
                      ),
                    ),
                  if (viewModel.infoMessage != null &&
                      !viewModel.canResendVerification)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: StrategyBuilderConstants.mediumSpacing),
                      child: Text(
                        viewModel.infoMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  // Loading indicator during auth operations
                  if (viewModel.isBusy)
                    const Padding(
                      padding: EdgeInsets.only(
                          bottom: StrategyBuilderConstants.smallSpacing),
                      child: LinearProgressIndicator(),
                    ),
                  // Recovery flow is handled via dedicated dialog when detected
                  if (viewModel.hasPendingRedirect)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: StrategyBuilderConstants.mediumSpacing),
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
                      padding: const EdgeInsets.only(
                          top: StrategyBuilderConstants.tinySpacing,
                          bottom: StrategyBuilderConstants.tinySpacing),
                      child: Text(
                        t?.errorInvalidEmail ?? 'Format email tidak valid.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(
                      height: StrategyBuilderConstants.mediumSpacing),
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
                      padding: const EdgeInsets.only(
                          top: StrategyBuilderConstants.tinySpacing,
                          bottom: StrategyBuilderConstants.tinySpacing),
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
                  const SizedBox(height: StrategyBuilderConstants.itemSpacing),
                  ElevatedButton(
                    onPressed: (viewModel.isBusy ||
                            (viewModel.email.isNotEmpty &&
                                !viewModel.isValidEmail(viewModel.email)))
                        ? null
                        : viewModel.signInEmail,
                    child: Text(t?.loginSignInEmail ?? 'Sign In with Email'),
                  ),
                  const SizedBox(height: StrategyBuilderConstants.smallSpacing),
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
                    child: TextButton.icon(
                      onPressed: viewModel.isBusy
                          ? null
                          : () => locator<NavigationService>()
                              .navigateToSignupView(),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(t?.homeUserSignUp ?? 'Daftar Akun Baru'),
                    ),
                  ),
                  const SizedBox(
                      height: StrategyBuilderConstants.sectionSpacing),
                  ElevatedButton.icon(
                    onPressed: viewModel.isBusy ? null : viewModel.signInGoogle,
                    icon: const Icon(Icons.login),
                    label:
                        Text(t?.loginContinueGoogle ?? 'Continue with Google'),
                  ),
                  const SizedBox(height: StrategyBuilderConstants.smallSpacing),
                  OutlinedButton.icon(
                    onPressed: viewModel.isBusy ? null : viewModel.signInGithub,
                    icon: const Icon(Icons.code),
                    label: const Text('Continue with GitHub'),
                  ),
                  const SizedBox(height: StrategyBuilderConstants.smallSpacing),
                  OutlinedButton.icon(
                    onPressed: viewModel.isBusy ? null : viewModel.signInApple,
                    icon: const Icon(Icons.phone_iphone),
                    label: const Text('Continue with Apple'),
                  ),
                ],
              ),
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
        final theme = locator<ThemeService>();
        final locale = theme.locale.value ?? const Locale('en');
        final l10n = await AppLocalizations.delegate.load(locale);
        final successMsg = l10n.homeChangePasswordSuccess;
        final response = await dialogService.showCustomDialog(
          variant: DialogType.changePassword,
          title: l10n.changePasswordTitle,
          description: l10n.changePasswordDescription,
          barrierDismissible: true,
        );
        if (response?.confirmed == true) {
          snackbarService.showSnackbar(
            message: successMsg,
            duration: const Duration(seconds: 3),
          );
          deepLinkService.clearRecoveryMarkersFromUrl();
          if (auth.isLoggedIn) {
            nav.replaceWith(Routes.homeView);
          }
        }
      });
    }
  }
}
