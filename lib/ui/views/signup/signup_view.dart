import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/views/signup/signup_viewmodel.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';

class SignupView extends StackedView<SignupViewModel> {
  const SignupView({super.key});

  @override
  Widget builder(
      BuildContext context, SignupViewModel viewModel, Widget? child) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t?.signupTitle ?? 'Sign Up')),
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
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      t?.errorPasswordMinSignup ??
                          'Password minimal 6 karakter untuk pendaftaran.',
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText:
                        t?.signupConfirmPasswordLabel ?? 'Konfirmasi Password',
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
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      t?.errorPasswordConfirmMismatch ??
                          'Passwords do not match.',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 8),
                TextButton(
                  onPressed: viewModel.isBusy
                      ? null
                      : () =>
                          locator<NavigationService>().replaceWithLoginView(),
                  child: Text(t?.homeUserSignIn ?? 'Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  SignupViewModel viewModelBuilder(BuildContext context) => SignupViewModel();
}
