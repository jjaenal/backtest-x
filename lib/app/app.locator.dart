// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_services/src/snackbar/snackbar_service.dart';
import 'package:stacked_shared/stacked_shared.dart';

import '../core/data_manager.dart';
import '../services/backtest_engine_service.dart';
import '../services/data_parser_service.dart';
import '../services/data_validation_service.dart';
import '../services/indicator_service.dart';
import '../services/pdf_export_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerLazySingleton(() => DataParserService());
  locator.registerLazySingleton(() => IndicatorService());
  locator.registerLazySingleton(() => BacktestEngineService());
  locator.registerLazySingleton(() => StorageService());
  locator.registerLazySingleton(() => DataValidationService());
  locator.registerLazySingleton(() => DataManager());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => PdfExportService());
}
