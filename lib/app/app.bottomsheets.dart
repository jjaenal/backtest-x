// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedBottomsheetGenerator
// **************************************************************************

import 'package:stacked_services/stacked_services.dart';

import 'app.locator.dart';
import '../ui/bottom_sheets/candlestick_pattern_guide/candlestick_pattern_guide_sheet.dart';
import '../ui/bottom_sheets/indicator_settings/indicator_settings_sheet.dart';
import '../ui/bottom_sheets/notice/notice_sheet.dart';
import '../ui/bottom_sheets/validation_report/validation_report_sheet.dart';

enum BottomSheetType {
  notice,
  indicatorSettings,
  candlestickPatternGuide,
  validationReport,
}

void setupBottomSheetUi() {
  final bottomsheetService = locator<BottomSheetService>();

  final Map<BottomSheetType, SheetBuilder> builders = {
    BottomSheetType.notice: (context, request, completer) =>
        NoticeSheet(request: request, completer: completer),
    BottomSheetType.indicatorSettings: (context, request, completer) =>
        IndicatorSettingsSheet(request: request, completer: completer),
    BottomSheetType.candlestickPatternGuide: (context, request, completer) =>
        CandlestickPatternGuideSheet(request: request, completer: completer),
    BottomSheetType.validationReport: (context, request, completer) =>
        ValidationReportSheet(request: request, completer: completer),
  };

  bottomsheetService.setCustomSheetBuilders(builders);
}
