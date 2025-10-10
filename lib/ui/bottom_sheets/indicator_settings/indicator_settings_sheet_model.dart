import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class IndicatorSettingsSheetModel extends BaseViewModel {
  // Visibility toggles
  bool showSMA = true;
  bool showEMA = true;
  bool showBB = false;
  bool showRSI = true;
  bool showMACD = true;

  // Periods
  int smaPeriod = 20;
  int emaPeriod = 50;
  int bbPeriod = 20;
  double bbStdDev = 2.0;
  int rsiPeriod = 14;
  int macdFast = 12;
  int macdSlow = 26;
  int macdSignal = 9;

  // Chart options
  bool highQuality = false;
  bool showVolume = false;

  // Color previews (static presets)
  Color smaColor = Colors.blue;
  Color emaColor = Colors.orange;
  Color bbColor = Colors.purple;

  void resetDefaults() {
    showSMA = true;
    showEMA = true;
    showBB = false;
    showRSI = true;
    showMACD = true;

    smaPeriod = 20;
    emaPeriod = 50;
    bbPeriod = 20;
    bbStdDev = 2.0;
    rsiPeriod = 14;
    macdFast = 12;
    macdSlow = 26;
    macdSignal = 9;

    highQuality = false;
    showVolume = false;
    notifyListeners();
  }
}
