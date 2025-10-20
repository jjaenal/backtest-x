import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'change_password_dialog_model.dart';

class ChangePasswordDialog extends StackedView<ChangePasswordDialogModel> {
  final DialogRequest request;
  final Function(DialogResponse) completer;

  const ChangePasswordDialog({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ChangePasswordDialogModel viewModel,
    Widget? child,
  ) {
    final t = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              request.title ?? (t?.changePasswordTitle ?? 'Set New Password'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (viewModel.infoMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  viewModel.infoMessage!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            TextField(
              decoration: InputDecoration(
                labelText: t?.changePasswordNewLabel ?? 'New Password',
                suffixIcon: IconButton(
                  icon: Icon(viewModel.obscureNew
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    viewModel.obscureNew = !viewModel.obscureNew;
                    viewModel.notifyListeners();
                  },
                ),
              ),
              obscureText: viewModel.obscureNew,
              onChanged: (v) => viewModel.updateNewPassword(v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: viewModel.strengthValue,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      viewModel.strengthValue < 0.35
                          ? Colors.red
                          : (viewModel.strengthValue < 0.7
                              ? Colors.orange
                              : Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.strengthValue < 0.35
                      ? (t?.passwordStrengthWeak ?? 'Weak')
                      : (viewModel.strengthValue < 0.7
                          ? (t?.passwordStrengthMedium ?? 'Medium')
                          : (t?.passwordStrengthStrong ?? 'Strong')),
                  style: TextStyle(
                    color: viewModel.strengthValue < 0.35
                        ? Colors.red
                        : (viewModel.strengthValue < 0.7
                            ? Colors.orange
                            : Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                labelText:
                    t?.changePasswordConfirmLabel ?? 'Confirm New Password',
                suffixIcon: IconButton(
                  icon: Icon(viewModel.obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    viewModel.obscureConfirm = !viewModel.obscureConfirm;
                    viewModel.notifyListeners();
                  },
                ),
              ),
              obscureText: viewModel.obscureConfirm,
              onChanged: (v) => viewModel.confirmPassword = v,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        completer(DialogResponse(confirmed: false)),
                    child: Text(t?.commonCancel ?? 'Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModel.isBusy
                        ? null
                        : () async {
                            // Basic validation
                            if (viewModel.newPassword.isEmpty ||
                                viewModel.newPassword.length < 6) {
                              viewModel.errorMessage = t?.errorPasswordMin ??
                                  'Password must be at least 6 characters.';
                              viewModel.infoMessage = null;
                              viewModel.notifyListeners();
                              return;
                            }
                            if (viewModel.newPassword !=
                                viewModel.confirmPassword) {
                              viewModel.errorMessage =
                                  t?.errorPasswordConfirmMismatch ??
                                      'Password confirmation does not match.';
                              viewModel.infoMessage = null;
                              viewModel.notifyListeners();
                              return;
                            }
                            viewModel.setBusy(true);
                            viewModel.errorMessage = null;
                            viewModel.infoMessage = null;
                            try {
                              final auth = locator<AuthService>();
                              await auth.updatePassword(
                                  newPassword: viewModel.newPassword);
                              viewModel.infoMessage =
                                  t?.homeChangePasswordSuccess ??
                                      'Password updated successfully.';
                              viewModel.notifyListeners();
                              // Close dialog after brief feedback
                              await Future.delayed(
                                  const Duration(milliseconds: 300));
                              completer(DialogResponse(confirmed: true));
                            } catch (e) {
                              if (!context.mounted) {
                                // Context no longer valid; update state only
                                viewModel.errorMessage = e.toString();
                                viewModel.notifyListeners();
                              } else {
                                final msg = _friendlyError(context, e);
                                viewModel.errorMessage = msg;
                                // Also show a snackbar for visibility
                                locator<SnackbarService>().showSnackbar(
                                  message: msg,
                                  duration: const Duration(seconds: 3),
                                );
                                viewModel.notifyListeners();
                              }
                            } finally {
                              viewModel.setBusy(false);
                            }
                          },
                    child: viewModel.isBusy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(t?.changePasswordSaving ?? 'Saving...'),
                            ],
                          )
                        : Text(t?.changePasswordSaveButton ?? 'Save Password'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  ChangePasswordDialogModel viewModelBuilder(BuildContext context) =>
      ChangePasswordDialogModel();

  String _friendlyError(BuildContext context, Object e) {
    final t = AppLocalizations.of(context);
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
    if (s.contains('password') && s.contains('least') && s.contains('6')) {
      return t?.errorPasswordMin ?? 'Password minimal 6 karakter.';
    }

    return t?.errorGeneric ?? 'Terjadi kesalahan. Coba lagi.';
  }
}
