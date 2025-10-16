import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/data_validation_service.dart';
import 'package:backtestx/services/prefs_service_io_impl.dart';
import 'package:backtestx/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:backtestx/ui/bottom_sheets/quick_start_templates/quick_start_templates_sheet.dart';
import 'package:backtestx/ui/bottom_sheets/validation_report/validation_report_sheet.dart';
import 'package:backtestx/ui/bottom_sheets/template_picker/template_picker_sheet.dart';
import 'package:backtestx/ui/dialogs/change_password/change_password_dialog.dart';
import 'package:backtestx/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import 'package:backtestx/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/services/theme_service.dart';
import 'package:backtestx/services/pdf_export_service.dart';
import 'package:backtestx/services/share_service.dart';
import 'package:backtestx/ui/views/data_upload/data_upload_view.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_view.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_view.dart';
import 'package:backtestx/ui/views/workspace/workspace_view.dart';
import 'package:backtestx/ui/views/comparison/comparison_view.dart';
import 'package:backtestx/ui/views/market_analysis/market_analysis_view.dart';
import 'package:backtestx/ui/views/pattern_scanner/pattern_scanner_view.dart';
import 'package:backtestx/ui/bottom_sheets/indicator_settings/indicator_settings_sheet.dart';
import 'package:backtestx/ui/bottom_sheets/candlestick_pattern_guide/candlestick_pattern_guide_sheet.dart';
import 'package:backtestx/ui/bottom_sheets/onboarding/onboarding_sheet.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:backtestx/app/auth_guard.dart';
import 'package:backtestx/ui/views/login/login_view.dart';
import 'package:backtestx/ui/views/signup/signup_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: DataUploadView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: SignupView),
    MaterialRoute(page: StrategyBuilderView, guards: [AuthGuard]),
    MaterialRoute(page: BacktestResultView),
    MaterialRoute(page: WorkspaceView),
    MaterialRoute(page: ComparisonView),
    MaterialRoute(page: MarketAnalysisView),
    MaterialRoute(page: PatternScannerView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: SnackbarService),
    LazySingleton(classType: DataParserService),
    LazySingleton(classType: IndicatorService),
    LazySingleton(classType: BacktestEngineService),
    LazySingleton(classType: StorageService),
    LazySingleton(classType: PrefsService),
    LazySingleton(classType: DataValidationService),
    LazySingleton(classType: DataManager),
    LazySingleton(classType: ThemeService),
    LazySingleton(classType: PdfExportService),
    LazySingleton(classType: ShareService),
    LazySingleton(classType: DeepLinkService),
    LazySingleton(classType: AuthService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: IndicatorSettingsSheet),
    StackedBottomsheet(classType: CandlestickPatternGuideSheet),
    StackedBottomsheet(classType: ValidationReportSheet),
    StackedBottomsheet(classType: OnboardingSheet),
    StackedBottomsheet(classType: QuickStartTemplatesSheet),
    StackedBottomsheet(classType: TemplatePickerSheet),
// @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    StackedDialog(classType: ChangePasswordDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
