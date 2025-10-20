import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.dialogs.dart';
import 'user_viewmodel.dart';

class UserView extends StackedView<UserViewModel> {
  const UserView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, UserViewModel viewModel, Widget? child) {
    final t = AppLocalizations.of(context);
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final isLoggedIn = user != null;
    final email = user?.email ?? '';
    final initials = (email.isNotEmpty) ? email[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: Text(t?.homeUserMenuTooltip ?? 'Account'),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account section
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initials)),
                    title: Text(
                        isLoggedIn ? email : (t?.homeUserUnknown ?? 'Unknown')),
                    subtitle: Text(t?.homeUserMenuTooltip ?? 'Account'),
                  ),
                ),
              ),
              if (isLoggedIn) ...[
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: Text(t?.userEmailVerification ?? 'Email Verification'),
                  subtitle: Text(viewModel.isEmailVerified
                      ? (t?.userEmailStatusVerified ?? 'Verified')
                      : (t?.userEmailStatusUnverified ?? 'Not Verified')),
                  trailing: viewModel.isEmailVerified
                      ? Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary)
                      : TextButton(
                          onPressed: () =>
                              viewModel.resendVerificationEmail(context),
                          child: Text(t?.userEmailResend ??
                              'Resend Verification Email'),
                        ),
                ),
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: Text(t?.changePasswordTitle ?? 'Change Password'),
                  subtitle: Text(t?.changePasswordDescription ??
                      'Update your account password'),
                  onTap: () async {
                    final response =
                        await locator<DialogService>().showCustomDialog(
                      variant: DialogType.changePassword,
                      title: t?.changePasswordTitle,
                      description: t?.changePasswordDescription,
                      barrierDismissible: true,
                    );
                    if (response?.confirmed == true) {
                      locator<SnackbarService>().showSnackbar(
                        message: t?.homeChangePasswordSuccess ??
                            'Password berhasil diubah.',
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    t?.userDeleteAccount ?? 'Delete Account',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onTap: () => viewModel.requestDeleteAccount(context),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(t?.homeUserSignOut ?? 'Sign Out'),
                  onTap: viewModel.signOut,
                ),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t?.homeUserMenuTooltip ?? 'Account',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: viewModel.navigateToLogin,
                              icon: const Icon(Icons.login),
                              label: Text(t?.homeUserSignIn ?? 'Sign In'),
                            ),
                            OutlinedButton.icon(
                              onPressed: viewModel.navigateToSignup,
                              icon: const Icon(Icons.person_add_alt),
                              label: Text(t?.homeUserSignUp ?? 'Sign Up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const Divider(height: 32),

              // Language preferences
              SwitchListTile(
                secondary: const Icon(Icons.language),
                title: Text(t?.languageMenuSystem ?? 'Use System Language'),
                value: viewModel.useSystemLanguage,
                onChanged: (v) => viewModel.setUseSystemLanguage(v),
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: viewModel.currentLocaleCode,
                title: Text(t?.languageMenuEnglish ?? 'English'),
                secondary: const Icon(Icons.translate),
                onChanged: viewModel.useSystemLanguage
                    ? null
                    : (_) => viewModel.setLocaleEnglish(),
              ),
              RadioListTile<String>(
                value: 'id',
                groupValue: viewModel.currentLocaleCode,
                title: Text(t?.languageMenuIndonesian ?? 'Bahasa Indonesia'),
                secondary: const Icon(Icons.translate),
                onChanged: viewModel.useSystemLanguage
                    ? null
                    : (_) => viewModel.setLocaleIndonesian(),
              ),

              const Divider(height: 32),

              // Theme preferences
              SwitchListTile(
                secondary: const Icon(Icons.brightness_auto),
                title: Text(t?.themeMenuSystem ?? 'Use System Theme'),
                value: viewModel.useSystemTheme,
                onChanged: (v) => viewModel.setUseSystemTheme(v),
              ),
              RadioListTile<String>(
                value: 'light',
                groupValue: viewModel.currentThemeSelection,
                title: Text(t?.themeMenuLight ?? 'Light'),
                secondary: const Icon(Icons.light_mode),
                onChanged: viewModel.useSystemTheme
                    ? null
                    : (_) => viewModel.setThemeLight(),
              ),
              RadioListTile<String>(
                value: 'dark',
                groupValue: viewModel.currentThemeSelection,
                title: Text(t?.themeMenuDark ?? 'Dark'),
                secondary: const Icon(Icons.dark_mode),
                onChanged: viewModel.useSystemTheme
                    ? null
                    : (_) => viewModel.setThemeDark(),
              ),

              // Cache controls
              ListTile(
                leading: Icon(viewModel.backgroundWarmupEnabled
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline),
                title: Text(viewModel.backgroundWarmupEnabled
                    ? (t?.homeOptionPauseBg ?? 'Pause Background Loading')
                    : (t?.homeOptionEnableBg ?? 'Enable Background Loading')),
                onTap: () => viewModel.toggleBackgroundWarmup(context),
              ),
              ListTile(
                leading: const Icon(Icons.download_for_offline_outlined),
                title: Text(t?.homeOptionLoadCache ?? 'Load Cache Now'),
                onTap: () => viewModel.warmUpCacheNow(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(t?.homeCacheInfoTitle ?? 'Cache Info'),
                onTap: () => viewModel.showCacheInfo(context),
              ),
              const Divider(height: 32),

              // Onboarding
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(t?.homeHelpOptions ?? 'Help'),
                onTap: viewModel.showOnboarding,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  UserViewModel viewModelBuilder(BuildContext context) => UserViewModel();

  @override
  void onViewModelReady(UserViewModel viewModel) {
    viewModel.initialize();
  }
}
