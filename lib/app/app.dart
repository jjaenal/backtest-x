import 'package:backtestx/services/data_validation_service.dart';
import 'package:backtestx/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:backtestx/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import 'package:backtestx/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/views/data_upload/data_upload_view.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_view.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_view.dart';
import 'package:backtestx/ui/views/workspace/workspace_view.dart';
import 'package:backtestx/ui/views/comparison/comparison_view.dart';
import 'package:backtestx/ui/views/market_analysis/market_analysis_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    MaterialRoute(page: DataUploadView),

    MaterialRoute(page: StrategyBuilderView),
    MaterialRoute(page: BacktestResultView),
    MaterialRoute(page: WorkspaceView),
    MaterialRoute(page: ComparisonView),
    MaterialRoute(page: MarketAnalysisView),
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
    LazySingleton(classType: DataValidationService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
