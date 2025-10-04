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
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DataParserService),
    LazySingleton(classType: IndicatorService),
    LazySingleton(classType: BacktestEngineService),
    LazySingleton(classType: StorageService),
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
)
class App {}
