import 'package:backtestx/services/prefs_service_io_impl.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/app/app.router.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/app/app.bottomsheets.dart';

class OnboardingSheetModel extends BaseViewModel {
  int _step = 0;
  int get step => _step;

  void next() {
    _step = (_step + 1).clamp(0, 3);
    notifyListeners();
  }

  void back() {
    _step = (_step - 1).clamp(0, 3);
    notifyListeners();
  }

  // Actions
  void goToImportData() {
    locator<NavigationService>().navigateToDataUploadView();
  }

  Future<void> showQuickStartTemplates() async {
    final response = await locator<BottomSheetService>().showCustomSheet(
      variant: BottomSheetType.quickStartTemplates,
      barrierDismissible: true,
      isScrollControlled: true,
    );
    // Jika user memilih template, tutup onboarding lalu navigate ke Strategy Builder
    if (response?.confirmed == true) {
      final templateKey = response?.data as String?;
      if (templateKey != null && templateKey.isNotEmpty) {
        try {
          // Simpan sementara untuk auto-apply saat Builder dibuka
          await locator<PrefsService>()
              .setString('onboarding.pending_template_key', templateKey);
        } catch (_) {}
      }
      // Tutup sheet onboarding terlebih dahulu agar navigasi tidak tertutup overlay
      locator<NavigationService>().back();
      // Navigasi ke Strategy Builder (template akan dipilih manual di builder untuk saat ini)
      locator<NavigationService>().navigateToStrategyBuilderView();
    }
  }

  Future<void> openLearnPanel() async {
    final l10n =
        AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;
    await locator<BottomSheetService>().showCustomSheet(
      variant: BottomSheetType.notice,
      title: l10n.onboardingLearn,
      description: l10n.onboardingCsvTips,
      barrierDismissible: true,
      isScrollControlled: true,
    );
  }

  Future<void> showCsvNotice() async {
    final l10n =
        AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;
    await locator<BottomSheetService>().showCustomSheet(
      variant: BottomSheetType.notice,
      title: l10n.onboardingViewCsvExample,
      description: l10n.onboardingCsvTips,
      barrierDismissible: true,
    );
  }
}
