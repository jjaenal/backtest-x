import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/views/signup/signup_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_constants.dart';
import 'package:backtestx/ui/widgets/verification_banner.dart';

class SignupView extends StackedView<SignupViewModel> {
  const SignupView({super.key});

  @override
  Widget builder(
      BuildContext context, SignupViewModel viewModel, Widget? child) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.signupTitle ?? 'Sign Up')),
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
                  if (viewModel.isBusy) const LinearProgressIndicator(),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: StrategyBuilderConstants.mediumSpacing),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
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
                  if (viewModel.canResendVerification)
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiaryContainer
                          .withValues(alpha: 0.2),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(
                            StrategyBuilderConstants.mediumSpacing),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(
                                    width:
                                        StrategyBuilderConstants.smallSpacing),
                                Expanded(
                                  child: Text(
                                    t?.errorAuthEmailNotConfirmed ??
                                        'Email belum terverifikasi. Cek inbox untuk verifikasi.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: StrategyBuilderConstants.smallSpacing),
                            Wrap(
                              spacing: StrategyBuilderConstants.smallSpacing,
                              runSpacing: StrategyBuilderConstants.microSpacing,
                              children: [
                                TextButton.icon(
                                  onPressed: (viewModel.isBusy ||
                                          !viewModel
                                              .isValidEmail(viewModel.email) ||
                                          viewModel.isResendCooldownActive)
                                      ? null
                                      : viewModel.resendVerificationEmail,
                                  icon: const Icon(Icons.mark_email_unread),
                                  label: Text(
                                    t?.userEmailResend ??
                                        'Kirim Ulang Email Verifikasi',
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: viewModel.isBusy
                                      ? null
                                      : viewModel.dismissVerificationBanner,
                                  icon: const Icon(Icons.close),
                                  label: Text(
                                    t?.errorDismiss ?? 'Tutup',
                                  ),
                                ),
                                if (viewModel.isResendCooldownActive)
                                  Text(
                                    'Tunggu beberapa detik sebelum kirim ulang.',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                if (viewModel.showVerificationBanner)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: StrategyBuilderConstants
                                            .mediumSpacing),
                                    child: VerificationBanner(
                                      isBusy: viewModel.isBusy,
                                      isResendEnabled: !(viewModel.isBusy ||
                                          !viewModel
                                              .isValidEmail(viewModel.email) ||
                                          viewModel.isResendCooldownActive),
                                      resendCooldownActive:
                                          viewModel.isResendCooldownActive,
                                      cooldownRemainingSeconds: viewModel
                                          .resendCooldownRemainingSeconds,
                                      onResend:
                                          viewModel.resendVerificationEmail,
                                      onDismiss:
                                          viewModel.dismissVerificationBanner,
                                      message: t?.errorAuthEmailNotConfirmed,
                                      resendLabel: t?.userEmailResend,
                                      dismissLabel: t?.errorDismiss,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
                      padding: const EdgeInsets.symmetric(
                          vertical: StrategyBuilderConstants.tinySpacing),
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
                        icon: Icon(viewModel.obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: viewModel.toggleObscurePassword,
                      ),
                    ),
                    obscureText: viewModel.obscurePassword,
                    onChanged: (v) => viewModel.password = v,
                  ),
                  if (viewModel.password.isNotEmpty &&
                      viewModel.password.length < 6)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: StrategyBuilderConstants.tinySpacing),
                      child: Text(
                        t?.errorPasswordMinSignup ??
                            'Password minimal 6 karakter untuk pendaftaran.',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  const SizedBox(
                      height: StrategyBuilderConstants.mediumSpacing),
                  TextField(
                    decoration: InputDecoration(
                      labelText: t?.signupConfirmPasswordLabel ??
                          'Konfirmasi Password',
                      suffixIcon: IconButton(
                        icon: Icon(viewModel.obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: viewModel.toggleObscureConfirmPassword,
                      ),
                    ),
                    obscureText: viewModel.obscureConfirmPassword,
                    onChanged: (v) => viewModel.confirmPassword = v,
                  ),
                  if (viewModel.confirmPassword.isNotEmpty &&
                      viewModel.confirmPassword != viewModel.password)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: StrategyBuilderConstants.tinySpacing),
                      child: Text(
                        t?.errorPasswordConfirmMismatch ??
                            'Passwords do not match.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: StrategyBuilderConstants.itemSpacing),
                  OutlinedButton(
                    onPressed: (viewModel.isBusy ||
                            (viewModel.email.isNotEmpty &&
                                !viewModel.isValidEmail(viewModel.email)) ||
                            viewModel.password.length < 6 ||
                            viewModel.password != viewModel.confirmPassword)
                        ? null
                        : viewModel.signUpEmail,
                    child: Text(t?.loginSignUpEmail ?? 'Sign Up with Email'),
                  ),
                  const SizedBox(height: StrategyBuilderConstants.smallSpacing),
                  TextButton.icon(
                    onPressed: viewModel.isBusy
                        ? null
                        : () =>
                            locator<NavigationService>().replaceWithLoginView(),
                    icon: const Icon(Icons.arrow_back),
                    label: Text(t?.homeUserSignIn ?? 'Kembali ke Login'),
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
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}
